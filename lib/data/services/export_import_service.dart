import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:meta/meta.dart';

import '../../core/utils/app_version.dart';
import '../../core/utils/enums.dart';
import '../../domain/usecases/wordbook_csv_codec.dart';
import '../database/app_database.dart';
import '../repositories/word_repository.dart';
import '../repositories/wordbook_repository.dart' show decodeIdList, encodeIdList;

/// バックアップの中身。**プレーンなデータだけ**で作る（isolate へ渡せる形）。
typedef BackupPayload = Map<String, dynamic>;

/// サポートするバックアップの版（[Docs/03_data_model.md] §10）。
const kBackupFormatVersion = 1;

/// JSON への変換。**別 isolate（`compute`）から呼ぶための最上位関数**
/// （[Docs/06_features/export_import.md] §1）。DB には触らない。
String encodeBackupJson(BackupPayload payload) =>
    const JsonEncoder.withIndent('  ').convert(payload);

/// 取り込みの失敗。利用者に見せる1行を [message]、詳細（不足のある行など）を
/// [details] に入れる（[Docs/06_features/export_import.md] §2.3）。
class BackupFormatException implements Exception {
  final String message;
  final List<String> details;

  const BackupFormatException(this.message, [this.details = const []]);

  @override
  String toString() => message;
}

/// 取り込みモード（[Docs/06_features/export_import.md] §2.1）。
enum ImportMode {
  /// 既存データを消さずに取り込む。衝突は §2.2 の規則で解決する。
  merge,

  /// 既存の全データを削除してから取り込む。二段確認を要する。
  replace,
}

/// 取り込み前のプレビュー（[Docs/06_features/export_import.md] §2.4）。
@immutable
class BackupPreview {
  /// 検証を通った中身。そのまま [ExportImportService.apply] へ渡す。
  final BackupPayload payload;

  final DateTime? exportedAt;
  final String appVersion;

  /// 学習者名 → 新規かどうか。
  final Map<String, bool> profiles;

  final int wordbookCount;
  final int wordCount;
  final int newWordCount;
  final int myWordCount;
  final int logCount;
  final int newLogCount;
  final int vocabTestCount;
  final int achievementCount;

  const BackupPreview({
    required this.payload,
    required this.exportedAt,
    required this.appVersion,
    required this.profiles,
    required this.wordbookCount,
    required this.wordCount,
    required this.newWordCount,
    required this.myWordCount,
    required this.logCount,
    required this.newLogCount,
    required this.vocabTestCount,
    required this.achievementCount,
  });
}

/// 取り込みの結果（SnackBar の報告に使う）。
@immutable
class ImportResult {
  final int profileCount;
  final int wordCount;
  final int logCount;

  const ImportResult({
    required this.profileCount,
    required this.wordCount,
    required this.logCount,
  });
}

/// JSON バックアップの書き出しと取り込み（[Docs/06_features/export_import.md]）。
///
/// 数値 id は端末間で一致しないため、**すべて自然キーで解決する**（§2.2）。
/// 取り込みは1トランザクションで行い、途中で失敗したら巻き戻す。
class ExportImportService {
  final AppDatabase _db;

  ExportImportService(this._db);

  // ---------------------------------------------------------------- エクスポート

  /// バックアップの中身を組み立てる。**音声パックは含めない**（§1）。
  ///
  /// Drift の読み出しはここ（ルート isolate）で済ませ、返すのはプレーンなデータだけ。
  /// JSON 文字列にするのは [encodeBackupJson]。
  Future<BackupPayload> collectBackup({required DateTime exportedAt}) async {
    final words = await _db.select(_db.words).get();
    final examples = await _examplesByWord();
    final families = await _db.select(_db.wordFamilies).get();
    final parts = await _db.select(_db.wordParts).get();
    final partLinks = await _db.select(_db.wordPartLinks).get();
    final wordbooks = await _db.select(_db.wordbooks).get();
    final entries = await _db.select(_db.wordbookEntries).get();
    final profiles = await _db.select(_db.profiles).get();

    final wordById = {for (final w in words) w.id: w};
    final familyById = {for (final f in families) f.id: f};
    final partById = {for (final p in parts) p.id: p};
    final linksByWord = <int, List<WordPartLink>>{};
    for (final link in partLinks) {
      linksByWord.putIfAbsent(link.wordId, () => []).add(link);
    }

    // 共有の語だけを words に出す。マイ単語は持ち主のプロファイルに入れる（§2.2）。
    final sharedWords = words.where((w) => w.ownerProfileId == null).toList();

    return {
      'formatVersion': kBackupFormatVersion,
      'appVersion': kAppVersion,
      'exportedAt': exportedAt.toIso8601String(),
      'profiles': [
        for (final profile in profiles)
          await _profileJson(
            profile,
            wordById,
            partById,
            familyById,
            examples,
          ),
      ],
      'wordbooks': [
        for (final book in wordbooks)
          if (book.ownerProfileId == null)
            {
              'presetId': book.presetId,
              'name': book.name,
              'emoji': book.emoji,
              'colorSeed': book.colorSeed,
              'category': book.category,
              'source': book.source,
              'bandSize': book.bandSize,
              'note': book.note,
              'sortOrder': book.sortOrder,
              'words': [
                for (final e in entries)
                  if (e.wordbookId == book.id && wordById[e.wordId] != null)
                    _wordKeyOf(wordById[e.wordId]!),
              ],
            },
      ],
      'words': [
        for (final w in sharedWords)
          _wordJson(
            w,
            familyById,
            linksByWord[w.id] ?? const [],
            partById,
            examples[w.id] ?? const [],
          ),
      ],
      'wordParts': [
        for (final p in parts)
          {
            'form': p.form,
            'type': p.type,
            'meaning': p.meaning,
            'origin': p.origin,
            'note': p.note,
            'level': p.level,
          },
      ],
      'wordFamilies': [
        for (final f in families) {'baseForm': f.baseForm, 'note': f.note},
      ],
    };
  }

  /// 語 id → その語の例文（表示順）。エクスポートは**全件**を持ち回る
  /// （[Docs/03_data_model.md] §10）。
  Future<Map<int, List<WordExample>>> _examplesByWord() async {
    final rows =
        await (_db.select(_db.wordExamples)..orderBy([
              (t) => OrderingTerm.asc(t.sortOrder),
              (t) => OrderingTerm.asc(t.id),
            ]))
            .get();
    final result = <int, List<WordExample>>{};
    for (final e in rows) {
      result.putIfAbsent(e.wordId, () => []).add(e);
    }
    return result;
  }

  Future<Map<String, dynamic>> _profileJson(
    Profile profile,
    Map<int, Word> wordById,
    Map<int, WordPart> partById,
    Map<int, WordFamily> familyById,
    Map<int, List<WordExample>> examples,
  ) async {
    final reviews =
        await (_db.select(_db.wordReviews)
              ..where((t) => t.profileId.equals(profile.id)))
            .get();
    final partReviews =
        await (_db.select(_db.partReviews)
              ..where((t) => t.profileId.equals(profile.id)))
            .get();
    final sessions =
        await (_db.select(_db.studySessions)
              ..where((t) => t.profileId.equals(profile.id)))
            .get();
    final logs =
        await (_db.select(_db.learningLogs)
              ..where((t) => t.profileId.equals(profile.id)))
            .get();
    final dailyStats =
        await (_db.select(_db.dailyStats)
              ..where((t) => t.profileId.equals(profile.id)))
            .get();
    final achievements =
        await (_db.select(_db.achievements)
              ..where((t) => t.profileId.equals(profile.id)))
            .get();
    final vocabTests =
        await (_db.select(_db.vocabSizeTests)
              ..where((t) => t.profileId.equals(profile.id)))
            .get();
    final confusions =
        await (_db.select(_db.resolvedConfusions)
              ..where((t) => t.profileId.equals(profile.id)))
            .get();
    final myWords =
        await (_db.select(_db.words)
              ..where((t) => t.ownerProfileId.equals(profile.id)))
            .get();

    return {
      'name': profile.name,
      'emoji': profile.emoji,
      'colorSeed': profile.colorSeed,
      'palette': profile.palette,
      'textScale': profile.textScale,
      'density': profile.density,
      'dictViewMode': profile.dictViewMode,
      'dictGridColumns': profile.dictGridColumns,
      'searchExamples': profile.searchExamples,
      'dailyGoal': profile.dailyGoal,
      'sessionSize': profile.sessionSize,
      'keyboardLayout': profile.keyboardLayout,
      'autoNextOnCorrect': profile.autoNextOnCorrect,
      'flashcardMode': profile.flashcardMode,
      'flashcardSeconds': profile.flashcardSeconds,
      'choiceDirection': profile.choiceDirection,
      'speedLimitMs': profile.speedLimitMs,
      'audioSource': profile.audioSource,
      'ttsRate': profile.ttsRate,
      'ttsPitch': profile.ttsPitch,
      'reminderEnabled': profile.reminderEnabled,
      'reminderHour': profile.reminderHour,
      'reminderMinute': profile.reminderMinute,
      // 学習対象の単語帳は id ではなく名前で書き出す（端末間で id が変わるため）。
      'selectedWordbooks': await _selectedWordbookNames(profile),
      'reviews': [
        for (final r in reviews)
          if (wordById[r.wordId] != null)
            {
              ..._wordRefJson(wordById[r.wordId]!),
              'repetition': r.repetition,
              'intervalDays': r.intervalDays,
              'easeFactor': r.easeFactor,
              'dueAt': r.dueAt.toIso8601String(),
              'lastReviewedAt': r.lastReviewedAt?.toIso8601String(),
              'firstLearnedAt': r.firstLearnedAt?.toIso8601String(),
              'lapses': r.lapses,
              'correctStreak': r.correctStreak,
              'totalCorrect': r.totalCorrect,
              'totalIncorrect': r.totalIncorrect,
              'masteryLevel': r.masteryLevel,
            },
      ],
      'partReviews': [
        for (final r in partReviews)
          if (partById[r.partId] != null)
            {
              'form': partById[r.partId]!.form,
              'type': partById[r.partId]!.type,
              'repetition': r.repetition,
              'intervalDays': r.intervalDays,
              'easeFactor': r.easeFactor,
              'dueAt': r.dueAt.toIso8601String(),
              'lastReviewedAt': r.lastReviewedAt?.toIso8601String(),
              'firstLearnedAt': r.firstLearnedAt?.toIso8601String(),
              'lapses': r.lapses,
              'correctStreak': r.correctStreak,
              'totalCorrect': r.totalCorrect,
              'totalIncorrect': r.totalIncorrect,
              'masteryLevel': r.masteryLevel,
            },
      ],
      'sessions': [
        for (final s in sessions)
          {
            'id': s.id,
            'mode': s.mode,
            'startedAt': s.startedAt.toIso8601String(),
            'finishedAt': s.finishedAt?.toIso8601String(),
            'plannedCount': s.plannedCount,
            'answeredCount': s.answeredCount,
            'correctCount': s.correctCount,
            'xpEarned': s.xpEarned,
            'avgReactionMs': s.avgReactionMs,
          },
      ],
      'logs': [
        for (final l in logs)
          {
            'sessionId': l.sessionId,
            if (l.wordId != null && wordById[l.wordId] != null)
              ..._wordRefJson(wordById[l.wordId]!),
            if (l.partId != null && partById[l.partId] != null) ...{
              'form': partById[l.partId]!.form,
              'type': partById[l.partId]!.type,
            },
            'mode': l.mode,
            'direction': l.direction,
            'isCorrect': l.isCorrect,
            'grade': l.grade,
            'answeredText': l.answeredText,
            'hintUsed': l.hintUsed,
            'replayCount': l.replayCount,
            'elapsedMs': l.elapsedMs,
            'answeredAt': l.answeredAt.toIso8601String(),
          },
      ],
      'dailyStats': [
        for (final d in dailyStats)
          {
            'studyDate': d.studyDate,
            'answeredCount': d.answeredCount,
            'correctCount': d.correctCount,
            'xp': d.xp,
            'studySeconds': d.studySeconds,
            'goalCount': d.goalCount,
            'goalMet': d.goalMet,
          },
      ],
      'achievements': [
        for (final a in achievements)
          {'code': a.code, 'unlockedAt': a.unlockedAt.toIso8601String()},
      ],
      'vocabSizeTests': [
        for (final v in vocabTests)
          {
            'takenAt': v.takenAt.toIso8601String(),
            'estimatedSize': v.estimatedSize,
            'falseAlarmRate': v.falseAlarmRate,
            'bandResults': v.bandResults,
            'askedWordIds': v.askedWordIds,
          },
      ],
      'resolvedConfusions': [
        for (final c in confusions)
          if (wordById[c.wordIdA] != null && wordById[c.wordIdB] != null)
            {
              'a': _wordRefJson(wordById[c.wordIdA]!),
              'b': _wordRefJson(wordById[c.wordIdB]!),
              'resolvedAt': c.resolvedAt.toIso8601String(),
            },
      ],
      'myWords': [
        for (final w in myWords)
          _wordJson(
            w,
            familyById,
            const [],
            partById,
            examples[w.id] ?? const [],
          ),
      ],
    };
  }

  Future<List<String>> _selectedWordbookNames(Profile profile) async {
    final ids = decodeIdList(profile.selectedWordbookIds);
    if (ids.isEmpty) return const [];
    final books =
        await (_db.select(_db.wordbooks)..where((t) => t.id.isIn(ids))).get();
    return [for (final b in books) b.name];
  }

  Map<String, dynamic> _wordJson(
    Word w,
    Map<int, WordFamily> familyById,
    List<WordPartLink> links,
    Map<int, WordPart> partById,
    List<WordExample> examples,
  ) {
    return {
      'headword': w.headword,
      'partOfSpeech': w.partOfSpeech,
      'phonetic': w.phonetic,
      'meaning': w.meaning,
      // 例文は全件。`sourcePresetId` はそのまま持ち回る（§10）。
      'examples': [
        for (final e in examples)
          {
            'en': e.exampleEn,
            'ja': e.exampleJa,
            'sourcePresetId': e.sourcePresetId,
            'sortOrder': e.sortOrder,
          },
      ],
      'partsNote': w.partsNote,
      'confusionNote': w.confusionNote,
      'familyBase': w.familyId == null
          ? null
          : familyById[w.familyId]?.baseForm,
      'level': w.level,
      'presetId': w.presetId,
      'isDraft': w.isDraft,
      'isEdited': w.isEdited,
      'isExcluded': w.isExcluded,
      'parts': [
        for (final link in links)
          if (partById[link.partId] != null)
            {
              'form': partById[link.partId]!.form,
              'type': partById[link.partId]!.type,
              'position': link.position,
            },
      ],
    };
  }

  static Map<String, dynamic> _wordRefJson(Word w) => {
    'headword': w.headword,
    'partOfSpeech': w.partOfSpeech,
  };

  static String _wordKeyOf(Word w) => '${w.headword}:${w.partOfSpeech}';

  // ------------------------------------------------------------------- CSV

  /// 単語帳1冊を CSV にする。**学習状態は含めない**（[Docs/06_features/export_import.md] §1）。
  ///
  /// CSV は1語1行なので**例文は1つだけ**出す。出すのは**その単語帳の例文**で、
  /// 無ければ `sortOrder` の先頭（[Docs/03_data_model.md] §10）。
  Future<String> collectCsv(int wordbookId) async {
    final query = _db.select(_db.words).join([
      innerJoin(
        _db.wordbookEntries,
        _db.wordbookEntries.wordId.equalsExp(_db.words.id),
        useColumns: false,
      ),
    ])
      ..where(_db.wordbookEntries.wordbookId.equals(wordbookId))
      ..orderBy([OrderingTerm.asc(_db.wordbookEntries.sortOrder)]);
    final words = await query.map((row) => row.readTable(_db.words)).get();

    final examples = await WordRepository(_db).preferredExamples(
      words.map((w) => w.id),
      wordbookIds: [wordbookId],
    );

    return WordbookCsvCodec.encode([
      for (final w in words)
        CsvWord(
          headword: w.headword,
          partOfSpeech: PartOfSpeech.fromValue(w.partOfSpeech),
          phonetic: w.phonetic,
          meaning: w.meaning,
          exampleEn: examples[w.id]?.exampleEn,
          exampleJa: examples[w.id]?.exampleJa,
          level: w.level,
        ),
    ]);
  }

  /// 検証を通った CSV の語を単語帳へ取り込む。
  ///
  /// 既存の共有語と `(headword, partOfSpeech)` が一致したら**行を増やさず所属だけ足す**
  /// （学習状態を分けない。[Docs/06_features/wordbooks.md] §4）。既存の訳は上書きしない。
  ///
  /// 取り込んだ例文は `sourcePresetId = null`（取り込み先はユーザー単語帳のため。
  /// [Docs/03_data_model.md] §10）。
  Future<({int added, int reused})> importCsv(
    int wordbookId,
    List<CsvWord> words,
  ) {
    final repo = WordRepository(_db);
    return _db.transaction(() async {
      final maxOrder = _db.wordbookEntries.sortOrder.max();
      final row =
          await (_db.selectOnly(_db.wordbookEntries)
                ..addColumns([maxOrder])
                ..where(_db.wordbookEntries.wordbookId.equals(wordbookId)))
              .getSingle();
      var order = (row.read(maxOrder) ?? -1) + 1;

      var added = 0;
      var reused = 0;
      for (final w in words) {
        final existing =
            await (_db.select(_db.words)..where(
                  (t) =>
                      t.headword.equals(w.headword) &
                      t.partOfSpeech.equals(w.partOfSpeech.value) &
                      t.ownerProfileId.isNull(),
                ))
                .getSingleOrNull();
        final int wordId;
        if (existing != null) {
          wordId = existing.id;
          reused++;
        } else {
          wordId = await _db
              .into(_db.words)
              .insert(
                WordsCompanion.insert(
                  headword: w.headword,
                  partOfSpeech: w.partOfSpeech.value,
                  meaning: w.meaning,
                  phonetic: Value(w.phonetic),
                  level: Value(w.level),
                ),
              );
          // 既存語の例文は上書きしない（既存の訳を上書きしないのと同じ扱い）。
          await repo.setUserExample(
            wordId,
            exampleEn: w.exampleEn,
            exampleJa: w.exampleJa,
          );
          added++;
        }
        await _db
            .into(_db.wordbookEntries)
            .insertOnConflictUpdate(
              WordbookEntriesCompanion.insert(
                wordbookId: wordbookId,
                wordId: wordId,
                sortOrder: Value(order++),
              ),
            );
      }
      return (added: added, reused: reused);
    });
  }

  // ------------------------------------------------------------------ 検証

  /// 取り込む前に全体を検証し、プレビューに出す値を数える（§2.3・§2.4）。
  ///
  /// **1件でも致命的な問題があれば例外**にして、何も取り込ませない。
  Future<BackupPreview> inspect(String raw) async {
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      throw const BackupFormatException('ファイルを読み取れません');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const BackupFormatException('バックアップの形式が不正です');
    }

    final version = decoded['formatVersion'];
    if (version is! int) {
      throw const BackupFormatException('バックアップの形式が不正です: formatVersion がありません');
    }
    if (version > kBackupFormatVersion) {
      throw BackupFormatException(
        'このバックアップは新しいバージョンで作られています（v$version）。アプリを更新してください',
      );
    }
    if (version < kBackupFormatVersion) {
      throw BackupFormatException('このバックアップは古い形式です（v$version）');
    }

    for (final key in ['profiles', 'wordbooks', 'words']) {
      if (decoded[key] is! List) {
        throw BackupFormatException('バックアップの形式が不正です: $key が見つかりません');
      }
    }

    final words = (decoded['words'] as List).cast<Object?>();
    final profiles = (decoded['profiles'] as List).cast<Object?>();

    // 単語の必須項目（headword / partOfSpeech / meaning）を全件見る。
    final missing = <String>[];
    void checkWords(List<Object?> list, String where) {
      for (var i = 0; i < list.length; i++) {
        final w = list[i];
        if (w is! Map<String, dynamic>) {
          missing.add('$where ${i + 1}件目: 形式が不正です');
          continue;
        }
        final headword = w['headword'];
        final pos = w['partOfSpeech'];
        final meaning = w['meaning'];
        final label = headword is String && headword.isNotEmpty
            ? '「$headword」'
            : '${i + 1}件目';
        if (headword is! String || headword.isEmpty) {
          missing.add('$where ${i + 1}件目: 見出し語がありません');
        } else if (pos is! String || !_isKnownPartOfSpeech(pos)) {
          missing.add('$where $label: 品詞が不正です');
        } else if (meaning is! String ||
            (meaning.isEmpty && w['isDraft'] != true)) {
          missing.add('$where $label: 日本語訳がありません');
        }
      }
    }

    checkWords(words, '単語');
    for (final p in profiles) {
      if (p is! Map<String, dynamic>) {
        throw const BackupFormatException('バックアップの形式が不正です: 学習者の形式が不正です');
      }
      if (p['name'] is! String || (p['name'] as String).isEmpty) {
        throw const BackupFormatException('バックアップの形式が不正です: 学習者の名前がありません');
      }
      final myWords = p['myWords'];
      if (myWords is List) {
        checkWords(myWords.cast<Object?>(), 'マイ単語（${p['name']}）');
      }
    }

    if (missing.isNotEmpty) {
      throw BackupFormatException(
        '${missing.length}件の単語に不足があります',
        missing.take(10).toList(),
      );
    }

    // ここから先はプレビューの数え上げ（DB を読むだけで書かない）。
    final existingNames = {
      for (final p in await _db.select(_db.profiles).get()) p.name,
    };
    final existingWordKeys = {
      for (final w in await _db.select(_db.words).get())
        if (w.ownerProfileId == null) _wordKeyOf(w),
    };
    final existingSessionIds = {
      for (final s in await _db.select(_db.studySessions).get()) s.id,
    };

    var newWords = 0;
    for (final w in words.cast<Map<String, dynamic>>()) {
      if (!existingWordKeys.contains(
        '${w['headword']}:${w['partOfSpeech']}',
      )) {
        newWords++;
      }
    }

    var myWordCount = 0;
    var logCount = 0;
    var newLogCount = 0;
    var vocabTestCount = 0;
    var achievementCount = 0;
    final profileNames = <String, bool>{};
    for (final p in profiles.cast<Map<String, dynamic>>()) {
      final name = p['name'] as String;
      profileNames[name] = !existingNames.contains(name);
      myWordCount += (p['myWords'] as List? ?? const []).length;
      final logs = (p['logs'] as List? ?? const []).cast<Object?>();
      logCount += logs.length;
      for (final l in logs) {
        if (l is Map<String, dynamic> &&
            !existingSessionIds.contains(l['sessionId'])) {
          newLogCount++;
        }
      }
      vocabTestCount += (p['vocabSizeTests'] as List? ?? const []).length;
      achievementCount += (p['achievements'] as List? ?? const []).length;
    }

    final exportedAt = decoded['exportedAt'];
    return BackupPreview(
      payload: decoded,
      exportedAt: exportedAt is String ? DateTime.tryParse(exportedAt) : null,
      appVersion: decoded['appVersion'] is String
          ? decoded['appVersion'] as String
          : '不明',
      profiles: profileNames,
      wordbookCount: (decoded['wordbooks'] as List).length,
      wordCount: words.length,
      newWordCount: newWords,
      myWordCount: myWordCount,
      logCount: logCount,
      newLogCount: newLogCount,
      vocabTestCount: vocabTestCount,
      achievementCount: achievementCount,
    );
  }

  static bool _isKnownPartOfSpeech(String value) =>
      PartOfSpeech.values.any((p) => p.value == value);

  // -------------------------------------------------------------- 取り込み

  /// 検証済みの中身を取り込む。**全体を1トランザクション**で行い、
  /// 途中で失敗したら1件も残さない（§2.3）。
  Future<ImportResult> apply(
    BackupPreview preview, {
    required ImportMode mode,
  }) {
    final payload = preview.payload;
    return _db.transaction(() async {
      if (mode == ImportMode.replace) await _deleteEverything();

      final familyIds = await _importFamilies(payload);
      final partIds = await _importParts(payload);
      final wordIds = await _importSharedWords(payload, familyIds, partIds);
      await _importWordbooks(payload, wordIds);

      var logCount = 0;
      final profiles = (payload['profiles'] as List).cast<Map<String, dynamic>>();
      for (final json in profiles) {
        final profile = await _resolveProfile(json);
        await _importMyWords(json, profile, familyIds, wordIds);
        await _importReviews(json, profile, wordIds);
        await _importPartReviews(json, profile, partIds);
        logCount += await _importSessionsAndLogs(json, profile, wordIds, partIds);
        await _importDailyStats(json, profile);
        await _importAchievements(json, profile);
        await _importVocabTests(json, profile);
        await _importResolvedConfusions(json, profile, wordIds);
        await _applySelectedWordbooks(json, profile);
      }

      return ImportResult(
        profileCount: profiles.length,
        wordCount: wordIds.length,
        logCount: logCount,
      );
    });
  }

  /// 置換の前処理。単語・単語帳・学習者を消すと、学習記録は外部キーの
  /// cascade で一緒に消える。
  Future<void> _deleteEverything() async {
    await _db.delete(_db.wordbookEntries).go();
    await _db.delete(_db.wordPartLinks).go();
    await _db.delete(_db.words).go();
    await _db.delete(_db.wordParts).go();
    await _db.delete(_db.wordFamilies).go();
    await _db.delete(_db.wordbooks).go();
    await _db.delete(_db.profiles).go();
  }

  /// 語族は `baseForm` で解決する。既存の説明は上書きしない。
  Future<Map<String, int>> _importFamilies(BackupPayload payload) async {
    final result = <String, int>{};
    for (final f in await _db.select(_db.wordFamilies).get()) {
      result[f.baseForm] = f.id;
    }
    for (final json in (payload['wordFamilies'] as List? ?? const [])
        .cast<Map<String, dynamic>>()) {
      final baseForm = json['baseForm'] as String;
      if (result.containsKey(baseForm)) continue;
      result[baseForm] = await _db
          .into(_db.wordFamilies)
          .insert(
            WordFamiliesCompanion.insert(
              baseForm: baseForm,
              note: Value(json['note'] as String?),
            ),
          );
    }
    return result;
  }

  /// 語の部品は `(form, type)` で解決する。既存の意味は上書きしない。
  Future<Map<String, int>> _importParts(BackupPayload payload) async {
    final result = <String, int>{};
    for (final p in await _db.select(_db.wordParts).get()) {
      result['${p.form}:${p.type}'] = p.id;
    }
    for (final json in (payload['wordParts'] as List? ?? const [])
        .cast<Map<String, dynamic>>()) {
      final key = '${json['form']}:${json['type']}';
      if (result.containsKey(key)) continue;
      result[key] = await _db
          .into(_db.wordParts)
          .insert(
            WordPartsCompanion.insert(
              form: json['form'] as String,
              type: json['type'] as String,
              meaning: json['meaning'] as String? ?? '',
              origin: Value(json['origin'] as String?),
              note: Value(json['note'] as String?),
              level: Value(json['level'] as int? ?? 1),
            ),
          );
    }
    return result;
  }

  /// 共有の語は `(headword, partOfSpeech)` で解決する。
  /// **既存があれば上書きしない**（手元の編集を優先する。§2.2）。
  Future<Map<String, int>> _importSharedWords(
    BackupPayload payload,
    Map<String, int> familyIds,
    Map<String, int> partIds,
  ) async {
    final result = <String, int>{};
    for (final w in await _db.select(_db.words).get()) {
      if (w.ownerProfileId == null) result[_wordKeyOf(w)] = w.id;
    }
    for (final json
        in (payload['words'] as List).cast<Map<String, dynamic>>()) {
      final key = '${json['headword']}:${json['partOfSpeech']}';
      if (result.containsKey(key)) continue;
      final id = await _insertWord(json, familyIds, ownerProfileId: null);
      result[key] = id;
      await _linkParts(json, id, partIds);
    }
    return result;
  }

  Future<int> _insertWord(
    Map<String, dynamic> json,
    Map<String, int> familyIds, {
    required int? ownerProfileId,
  }) async {
    final familyBase = json['familyBase'] as String?;
    final id = await _db
        .into(_db.words)
        .insert(
          WordsCompanion.insert(
            headword: (json['headword'] as String).toLowerCase(),
            partOfSpeech: json['partOfSpeech'] as String,
            meaning: json['meaning'] as String? ?? '',
            phonetic: Value(json['phonetic'] as String?),
            partsNote: Value(json['partsNote'] as String?),
            confusionNote: Value(json['confusionNote'] as String?),
            familyId: Value(familyBase == null ? null : familyIds[familyBase]),
            level: Value(json['level'] as int? ?? 1),
            presetId: Value(json['presetId'] as String?),
            ownerProfileId: Value(ownerProfileId),
            isDraft: Value(json['isDraft'] as bool? ?? false),
            isEdited: Value(json['isEdited'] as bool? ?? false),
            isExcluded: Value(json['isExcluded'] as bool? ?? false),
          ),
        );
    await _insertExamples(json, id);
    return id;
  }

  /// `words[].examples` を全件入れる（[Docs/03_data_model.md] §10）。
  /// `sourcePresetId` はそのまま持ち回る。
  ///
  /// 語を新しく作ったときだけ呼ぶ（既存語は上書きしない。§2.2）。
  Future<void> _insertExamples(Map<String, dynamic> json, int wordId) async {
    final seenSources = <String?>{};
    for (final e
        in (json['examples'] as List? ?? const []).cast<Map<String, dynamic>>()) {
      final en = e['en'] as String?;
      final ja = e['ja'] as String?;
      // 例文と和訳は必ず対で持つ（`word_examples` は両方 not null）。
      if (en == null || en.isEmpty || ja == null) continue;
      final source = e['sourcePresetId'] as String?;
      // 同じ `sourcePresetId` は語ごとに1件（部分ユニーク索引に合わせる）。
      if (!seenSources.add(source)) continue;
      await _db
          .into(_db.wordExamples)
          .insert(
            WordExamplesCompanion.insert(
              wordId: wordId,
              exampleEn: en,
              exampleJa: ja,
              sourcePresetId: Value(source),
              sortOrder: Value(e['sortOrder'] as int? ?? 0),
            ),
          );
    }
  }

  Future<void> _linkParts(
    Map<String, dynamic> json,
    int wordId,
    Map<String, int> partIds,
  ) async {
    for (final link
        in (json['parts'] as List? ?? const []).cast<Map<String, dynamic>>()) {
      final partId = partIds['${link['form']}:${link['type']}'];
      if (partId == null) continue;
      await _db
          .into(_db.wordPartLinks)
          .insertOnConflictUpdate(
            WordPartLinksCompanion.insert(
              wordId: wordId,
              partId: partId,
              position: Value(link['position'] as int? ?? 0),
            ),
          );
    }
  }

  /// 単語帳は `presetId`、無ければ `name` で解決する。所属は和集合を取る。
  Future<void> _importWordbooks(
    BackupPayload payload,
    Map<String, int> wordIds,
  ) async {
    final existing = await _db.select(_db.wordbooks).get();
    final byPreset = {
      for (final b in existing)
        if (b.presetId != null) b.presetId!: b.id,
    };
    final byName = {for (final b in existing) b.name: b.id};

    for (final json
        in (payload['wordbooks'] as List).cast<Map<String, dynamic>>()) {
      final presetId = json['presetId'] as String?;
      final name = json['name'] as String;
      var id = presetId != null ? byPreset[presetId] : byName[name];
      id ??= await _db
          .into(_db.wordbooks)
          .insert(
            WordbooksCompanion.insert(
              name: name,
              emoji: json['emoji'] as String? ?? '📗',
              colorSeed: json['colorSeed'] as int? ?? 0,
              category: json['category'] as String? ??
                  WordbookCategory.custom.value,
              source: json['source'] as String? ?? WordbookSource.imported.value,
              presetId: Value(presetId),
              bandSize: Value(json['bandSize'] as int?),
              note: Value(json['note'] as String?),
              sortOrder: Value(json['sortOrder'] as int? ?? 100),
            ),
          );
      if (presetId != null) byPreset[presetId] = id;
      byName[name] = id;

      final maxOrder = _db.wordbookEntries.sortOrder.max();
      final row =
          await (_db.selectOnly(_db.wordbookEntries)
                ..addColumns([maxOrder])
                ..where(_db.wordbookEntries.wordbookId.equals(id)))
              .getSingle();
      var order = (row.read(maxOrder) ?? -1) + 1;
      for (final key in (json['words'] as List? ?? const []).cast<String>()) {
        final wordId = wordIds[key];
        if (wordId == null) continue;
        await _db
            .into(_db.wordbookEntries)
            .insertOnConflictUpdate(
              WordbookEntriesCompanion.insert(
                wordbookId: id,
                wordId: wordId,
                sortOrder: Value(order++),
              ),
            );
      }
    }
  }

  /// 学習者は `name` で解決する。**既存の設定は上書きしない**（§2.2）。
  Future<Profile> _resolveProfile(Map<String, dynamic> json) async {
    final name = json['name'] as String;
    final existing =
        await (_db.select(_db.profiles)..where((t) => t.name.equals(name)))
            .getSingleOrNull();
    if (existing != null) return existing;

    final id = await _db
        .into(_db.profiles)
        .insert(
          ProfilesCompanion.insert(
            name: name,
            emoji: Value(json['emoji'] as String? ?? '🙂'),
            colorSeed: json['colorSeed'] as int? ?? 0,
            palette: Value(json['palette'] as String? ?? 'pink'),
            textScale: Value(json['textScale'] as String? ?? 'medium'),
            density: Value(json['density'] as String? ?? 'standard'),
            dictViewMode: Value(json['dictViewMode'] as String? ?? 'list'),
            dictGridColumns: Value(json['dictGridColumns'] as String? ?? 'auto'),
            searchExamples: Value(json['searchExamples'] as bool? ?? false),
            dailyGoal: Value(json['dailyGoal'] as int? ?? 20),
            sessionSize: Value(json['sessionSize'] as int? ?? 20),
            keyboardLayout: Value(json['keyboardLayout'] as String? ?? 'qwerty'),
            autoNextOnCorrect: Value(json['autoNextOnCorrect'] as bool? ?? false),
            flashcardMode: Value(json['flashcardMode'] as String? ?? 'silentAuto'),
            flashcardSeconds: Value(json['flashcardSeconds'] as int? ?? 3),
            choiceDirection: Value(json['choiceDirection'] as String? ?? 'random'),
            speedLimitMs: Value(json['speedLimitMs'] as int? ?? 3000),
            audioSource: Value(json['audioSource'] as String? ?? 'fileFirst'),
            ttsRate: Value((json['ttsRate'] as num?)?.toDouble() ?? 0.5),
            ttsPitch: Value((json['ttsPitch'] as num?)?.toDouble() ?? 1.0),
            reminderEnabled: Value(json['reminderEnabled'] as bool? ?? false),
            reminderHour: Value(json['reminderHour'] as int? ?? 19),
            reminderMinute: Value(json['reminderMinute'] as int? ?? 0),
          ),
        );
    // マイ単語帳は学習者と対で存在する（[Docs/06_features/my_words.md] §2）。
    await _db
        .into(_db.wordbooks)
        .insert(
          WordbooksCompanion.insert(
            name: 'マイ単語',
            emoji: '📝',
            colorSeed: json['colorSeed'] as int? ?? 0,
            category: WordbookCategory.myWords.value,
            source: WordbookSource.user.value,
            ownerProfileId: Value(id),
            sortOrder: const Value(1000),
          ),
        );
    return (_db.select(_db.profiles)..where((t) => t.id.equals(id)))
        .getSingle();
  }

  /// マイ単語は `(headword, partOfSpeech, 学習者)` で解決する。
  Future<void> _importMyWords(
    Map<String, dynamic> json,
    Profile profile,
    Map<String, int> familyIds,
    Map<String, int> wordIds,
  ) async {
    final mine =
        await (_db.select(_db.words)
              ..where((t) => t.ownerProfileId.equals(profile.id)))
            .get();
    final existing = {for (final w in mine) _wordKeyOf(w)};
    final myBook =
        await (_db.select(_db.wordbooks)..where(
              (t) =>
                  t.ownerProfileId.equals(profile.id) &
                  t.category.equals(WordbookCategory.myWords.value),
            ))
            .getSingleOrNull();

    for (final w in (json['myWords'] as List? ?? const [])
        .cast<Map<String, dynamic>>()) {
      final key = '${w['headword']}:${w['partOfSpeech']}';
      if (existing.contains(key)) continue;
      final id = await _insertWord(w, familyIds, ownerProfileId: profile.id);
      existing.add(key);
      // マイ単語はその人のマイ単語帳に属させる（辞書とキューから見えるように）。
      if (myBook != null) {
        await _db
            .into(_db.wordbookEntries)
            .insertOnConflictUpdate(
              WordbookEntriesCompanion.insert(
                wordbookId: myBook.id,
                wordId: id,
              ),
            );
      }
    }
  }

  /// 学習状態は `lastReviewedAt` が**新しい方**を採用する（合算しない。§2.2）。
  Future<void> _importReviews(
    Map<String, dynamic> json,
    Profile profile,
    Map<String, int> wordIds,
  ) async {
    // マイ単語の学習状態も解決できるよう、その人の語も引けるようにする。
    final owned =
        await (_db.select(_db.words)
              ..where((t) => t.ownerProfileId.equals(profile.id)))
            .get();
    final keys = {...wordIds, for (final w in owned) _wordKeyOf(w): w.id};

    for (final r in (json['reviews'] as List? ?? const [])
        .cast<Map<String, dynamic>>()) {
      final wordId = keys['${r['headword']}:${r['partOfSpeech']}'];
      if (wordId == null) continue;
      final incomingLast = _parseDate(r['lastReviewedAt']);
      final existing =
          await (_db.select(_db.wordReviews)..where(
                (t) =>
                    t.profileId.equals(profile.id) & t.wordId.equals(wordId),
              ))
              .getSingleOrNull();
      if (existing != null && !_isNewer(incomingLast, existing.lastReviewedAt)) {
        continue;
      }
      await _db
          .into(_db.wordReviews)
          .insertOnConflictUpdate(
            WordReviewsCompanion.insert(
              profileId: profile.id,
              wordId: wordId,
              dueAt: _parseDate(r['dueAt']) ?? DateTime.now(),
              repetition: Value(r['repetition'] as int? ?? 0),
              intervalDays: Value((r['intervalDays'] as num?)?.toDouble() ?? 0),
              easeFactor: Value((r['easeFactor'] as num?)?.toDouble() ?? 2.5),
              lastReviewedAt: Value(incomingLast),
              firstLearnedAt: Value(_parseDate(r['firstLearnedAt'])),
              lapses: Value(r['lapses'] as int? ?? 0),
              correctStreak: Value(r['correctStreak'] as int? ?? 0),
              totalCorrect: Value(r['totalCorrect'] as int? ?? 0),
              totalIncorrect: Value(r['totalIncorrect'] as int? ?? 0),
              masteryLevel: Value(r['masteryLevel'] as int? ?? 0),
            ),
          );
    }
  }

  Future<void> _importPartReviews(
    Map<String, dynamic> json,
    Profile profile,
    Map<String, int> partIds,
  ) async {
    for (final r in (json['partReviews'] as List? ?? const [])
        .cast<Map<String, dynamic>>()) {
      final partId = partIds['${r['form']}:${r['type']}'];
      if (partId == null) continue;
      final incomingLast = _parseDate(r['lastReviewedAt']);
      final existing =
          await (_db.select(_db.partReviews)..where(
                (t) =>
                    t.profileId.equals(profile.id) & t.partId.equals(partId),
              ))
              .getSingleOrNull();
      if (existing != null && !_isNewer(incomingLast, existing.lastReviewedAt)) {
        continue;
      }
      await _db
          .into(_db.partReviews)
          .insertOnConflictUpdate(
            PartReviewsCompanion.insert(
              profileId: profile.id,
              partId: partId,
              dueAt: _parseDate(r['dueAt']) ?? DateTime.now(),
              repetition: Value(r['repetition'] as int? ?? 0),
              intervalDays: Value((r['intervalDays'] as num?)?.toDouble() ?? 0),
              easeFactor: Value((r['easeFactor'] as num?)?.toDouble() ?? 2.5),
              lastReviewedAt: Value(incomingLast),
              firstLearnedAt: Value(_parseDate(r['firstLearnedAt'])),
              lapses: Value(r['lapses'] as int? ?? 0),
              correctStreak: Value(r['correctStreak'] as int? ?? 0),
              totalCorrect: Value(r['totalCorrect'] as int? ?? 0),
              totalIncorrect: Value(r['totalIncorrect'] as int? ?? 0),
              masteryLevel: Value(r['masteryLevel'] as int? ?? 0),
            ),
          );
    }
  }

  /// 履歴は `sessionId` が既存に無いセッションの分だけ取り込む（§2.2）。
  Future<int> _importSessionsAndLogs(
    Map<String, dynamic> json,
    Profile profile,
    Map<String, int> wordIds,
    Map<String, int> partIds,
  ) async {
    final existingIds = {
      for (final s in await _db.select(_db.studySessions).get()) s.id,
    };
    final imported = <String>{};
    for (final s in (json['sessions'] as List? ?? const [])
        .cast<Map<String, dynamic>>()) {
      final id = s['id'] as String;
      if (existingIds.contains(id)) continue;
      await _db
          .into(_db.studySessions)
          .insert(
            StudySessionsCompanion.insert(
              id: id,
              profileId: profile.id,
              mode: s['mode'] as String,
              startedAt: _parseDate(s['startedAt']) ?? DateTime.now(),
              finishedAt: Value(_parseDate(s['finishedAt'])),
              plannedCount: Value(s['plannedCount'] as int? ?? 0),
              answeredCount: Value(s['answeredCount'] as int? ?? 0),
              correctCount: Value(s['correctCount'] as int? ?? 0),
              xpEarned: Value(s['xpEarned'] as int? ?? 0),
              avgReactionMs: Value(s['avgReactionMs'] as int?),
            ),
          );
      imported.add(id);
    }

    final owned =
        await (_db.select(_db.words)
              ..where((t) => t.ownerProfileId.equals(profile.id)))
            .get();
    final keys = {...wordIds, for (final w in owned) _wordKeyOf(w): w.id};

    var count = 0;
    for (final l
        in (json['logs'] as List? ?? const []).cast<Map<String, dynamic>>()) {
      final sessionId = l['sessionId'] as String;
      if (!imported.contains(sessionId)) continue;
      final wordId = l['headword'] == null
          ? null
          : keys['${l['headword']}:${l['partOfSpeech']}'];
      final partId = l['form'] == null
          ? null
          : partIds['${l['form']}:${l['type']}'];
      // wordId と partId はどちらか一方だけが非 null（[Docs/03_data_model.md] §2.7）。
      if ((wordId == null) == (partId == null)) continue;
      await _db
          .into(_db.learningLogs)
          .insert(
            LearningLogsCompanion.insert(
              profileId: profile.id,
              sessionId: sessionId,
              wordId: Value(wordId),
              partId: Value(partId),
              mode: l['mode'] as String,
              direction: l['direction'] as String,
              isCorrect: l['isCorrect'] as bool? ?? false,
              grade: l['grade'] as int? ?? 0,
              answeredText: Value(l['answeredText'] as String?),
              hintUsed: Value(l['hintUsed'] as int? ?? 0),
              replayCount: Value(l['replayCount'] as int? ?? 0),
              elapsedMs: l['elapsedMs'] as int? ?? 0,
              answeredAt: _parseDate(l['answeredAt']) ?? DateTime.now(),
            ),
          );
      count++;
    }
    return count;
  }

  /// 日次集計だけは**合算**する。回数の記録なので足し合わせて正しい（§2.2）。
  Future<void> _importDailyStats(
    Map<String, dynamic> json,
    Profile profile,
  ) async {
    for (final d in (json['dailyStats'] as List? ?? const [])
        .cast<Map<String, dynamic>>()) {
      final studyDate = d['studyDate'] as String;
      final existing =
          await (_db.select(_db.dailyStats)..where(
                (t) =>
                    t.profileId.equals(profile.id) &
                    t.studyDate.equals(studyDate),
              ))
              .getSingleOrNull();
      await _db
          .into(_db.dailyStats)
          .insertOnConflictUpdate(
            DailyStatsCompanion.insert(
              profileId: profile.id,
              studyDate: studyDate,
              goalCount: existing?.goalCount ?? (d['goalCount'] as int? ?? 20),
              answeredCount: Value(
                (existing?.answeredCount ?? 0) + (d['answeredCount'] as int? ?? 0),
              ),
              correctCount: Value(
                (existing?.correctCount ?? 0) + (d['correctCount'] as int? ?? 0),
              ),
              xp: Value((existing?.xp ?? 0) + (d['xp'] as int? ?? 0)),
              studySeconds: Value(
                (existing?.studySeconds ?? 0) + (d['studySeconds'] as int? ?? 0),
              ),
              // 達成は OR。片方でも達成していればその日は達成。
              goalMet: Value(
                (existing?.goalMet ?? false) || (d['goalMet'] as bool? ?? false),
              ),
            ),
          );
    }
  }

  /// 実績は和集合。`unlockedAt` は**古い方**を残す（先に取った事実を消さない）。
  Future<void> _importAchievements(
    Map<String, dynamic> json,
    Profile profile,
  ) async {
    for (final a in (json['achievements'] as List? ?? const [])
        .cast<Map<String, dynamic>>()) {
      final code = a['code'] as String;
      final unlockedAt = _parseDate(a['unlockedAt']) ?? DateTime.now();
      final existing =
          await (_db.select(_db.achievements)..where(
                (t) => t.profileId.equals(profile.id) & t.code.equals(code),
              ))
              .getSingleOrNull();
      if (existing != null && !existing.unlockedAt.isAfter(unlockedAt)) continue;
      await _db
          .into(_db.achievements)
          .insertOnConflictUpdate(
            AchievementsCompanion.insert(
              profileId: profile.id,
              code: code,
              unlockedAt: unlockedAt,
            ),
          );
    }
  }

  /// 語彙力測定は `takenAt` が既存に無い分だけ取り込む。
  Future<void> _importVocabTests(
    Map<String, dynamic> json,
    Profile profile,
  ) async {
    final existing = {
      for (final v in await (_db.select(_db.vocabSizeTests)
                ..where((t) => t.profileId.equals(profile.id)))
              .get())
        v.takenAt.toIso8601String(),
    };
    for (final v in (json['vocabSizeTests'] as List? ?? const [])
        .cast<Map<String, dynamic>>()) {
      final takenAt = _parseDate(v['takenAt']);
      if (takenAt == null) continue;
      if (existing.contains(takenAt.toIso8601String())) continue;
      await _db
          .into(_db.vocabSizeTests)
          .insert(
            VocabSizeTestsCompanion.insert(
              profileId: profile.id,
              takenAt: takenAt,
              estimatedSize: v['estimatedSize'] as int? ?? 0,
              falseAlarmRate: (v['falseAlarmRate'] as num?)?.toDouble() ?? 0,
              bandResults: Value(v['bandResults'] as String? ?? '[]'),
              askedWordIds: Value(v['askedWordIds'] as String? ?? '[]'),
            ),
          );
      existing.add(takenAt.toIso8601String());
    }
  }

  /// 解消した取り違えは和集合。`resolvedAt` は古い方を残す。
  Future<void> _importResolvedConfusions(
    Map<String, dynamic> json,
    Profile profile,
    Map<String, int> wordIds,
  ) async {
    final owned =
        await (_db.select(_db.words)
              ..where((t) => t.ownerProfileId.equals(profile.id)))
            .get();
    final keys = {...wordIds, for (final w in owned) _wordKeyOf(w): w.id};

    for (final c in (json['resolvedConfusions'] as List? ?? const [])
        .cast<Map<String, dynamic>>()) {
      final a = c['a'] as Map<String, dynamic>;
      final b = c['b'] as Map<String, dynamic>;
      final idA = keys['${a['headword']}:${a['partOfSpeech']}'];
      final idB = keys['${b['headword']}:${b['partOfSpeech']}'];
      if (idA == null || idB == null) continue;
      // 必ず wordIdA < wordIdB に正規化する（[Docs/03_data_model.md] §2.14）。
      final low = idA < idB ? idA : idB;
      final high = idA < idB ? idB : idA;
      final resolvedAt = _parseDate(c['resolvedAt']) ?? DateTime.now();
      final existing =
          await (_db.select(_db.resolvedConfusions)..where(
                (t) =>
                    t.profileId.equals(profile.id) &
                    t.wordIdA.equals(low) &
                    t.wordIdB.equals(high),
              ))
              .getSingleOrNull();
      if (existing != null && !existing.resolvedAt.isAfter(resolvedAt)) continue;
      await _db
          .into(_db.resolvedConfusions)
          .insertOnConflictUpdate(
            ResolvedConfusionsCompanion.insert(
              profileId: profile.id,
              wordIdA: low,
              wordIdB: high,
              resolvedAt: Value(resolvedAt),
            ),
          );
    }
  }

  /// 学習対象の単語帳は名前で解決する。既存の選択は消さず、和集合にする。
  Future<void> _applySelectedWordbooks(
    Map<String, dynamic> json,
    Profile profile,
  ) async {
    final names = (json['selectedWordbooks'] as List? ?? const []).cast<String>();
    if (names.isEmpty) return;
    final books = await _db.select(_db.wordbooks).get();
    final ids = decodeIdList(profile.selectedWordbookIds).toSet();
    for (final name in names) {
      final match = books.where((b) => b.name == name);
      if (match.isEmpty) continue;
      ids.add(match.first.id);
    }
    await (_db.update(_db.profiles)..where((t) => t.id.equals(profile.id)))
        .write(
          ProfilesCompanion(
            selectedWordbookIds: Value(encodeIdList(ids)),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  static DateTime? _parseDate(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;

  /// 取り込む側が新しいか。片方が null なら**非 null を採用**する（§2.2）。
  static bool _isNewer(DateTime? incoming, DateTime? existing) {
    if (incoming == null) return false;
    if (existing == null) return true;
    return incoming.isAfter(existing);
  }
}
