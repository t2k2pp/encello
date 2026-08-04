import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/enums.dart';
import '../../core/utils/study_date.dart';
import '../database/app_database.dart';

/// サンプル単語帳・サンプル語を区別する識別子
/// （[Docs/06_features/export_import.md] §4）。
const kSampleWordbookPresetId = 'sample_v1';

/// 投入結果（SnackBar の報告用）。
@immutable
class SampleDataInstallResult {
  final int wordbookId;
  final int wordCount;
  final int logCount;

  const SampleDataInstallResult({
    required this.wordbookId,
    required this.wordCount,
    required this.logCount,
  });
}

/// 削除前に見せる件数（確認ダイアログ用）。
@immutable
class SampleDataDeletePreview {
  /// 削除できる語（このサンプル単語帳にしか属していない語）。
  final int deletableWordCount;

  /// 他の単語帳にも属しているため残す語。
  final int keptWordCount;

  const SampleDataDeletePreview({
    required this.deletableWordCount,
    required this.keptWordCount,
  });
}

/// 削除の結果（SnackBar の報告用）。
@immutable
class SampleDataDeleteResult {
  final int deletedWordCount;
  final int keptWordCount;

  const SampleDataDeleteResult({
    required this.deletedWordCount,
    required this.keptWordCount,
  });
}

/// サンプルデータの投入・削除（[Docs/06_features/export_import.md] §4）。
///
/// 単語帳（30語）は `source = preset` / `presetId = sample_v1` の共有マスタとして
/// 全学習者で1つだけ持つ。学習履歴・日次集計は**投入した学習者のもの**として作る。
class SampleDataService {
  final AppDatabase _db;

  const SampleDataService(this._db);

  /// サンプル単語帳が投入済みか。
  Future<bool> isInstalled() async {
    final book = await _findBook();
    return book != null;
  }

  /// 投入済みかを監視する（データタブの投入ボタンの活性/非活性に使う）。
  Stream<bool> watchInstalled() {
    final query = _db.select(_db.wordbooks)
      ..where((t) => t.presetId.equals(kSampleWordbookPresetId));
    return query.watch().map((rows) => rows.isNotEmpty);
  }

  Future<Wordbook?> _findBook() =>
      (_db.select(_db.wordbooks)
            ..where((t) => t.presetId.equals(kSampleWordbookPresetId)))
          .getSingleOrNull();

  /// [profileId] の学習者に対して投入する。すでに投入済みなら例外にする
  /// （投入ボタンは投入済みなら無効化するため、通常はここに到達しない）。
  Future<SampleDataInstallResult> install({
    required int profileId,
    required DateTime now,
  }) {
    return _db.transaction(() async {
      if (await _findBook() != null) {
        throw StateError('サンプルデータはすでに投入されています。');
      }

      final wordbookId = await _db
          .into(_db.wordbooks)
          .insert(
            WordbooksCompanion.insert(
              name: 'サンプル単語帳',
              emoji: '🧪',
              colorSeed: 0,
              category: WordbookCategory.custom.value,
              source: WordbookSource.preset.value,
              presetId: const Value(kSampleWordbookPresetId),
              sortOrder: const Value(500),
            ),
          );

      final wordIds = <int>[];
      for (var i = 0; i < _kSampleWords.length; i++) {
        final w = _kSampleWords[i];
        final wordId = await _db
            .into(_db.words)
            .insert(
              WordsCompanion.insert(
                headword: w.headword,
                partOfSpeech: w.partOfSpeech.value,
                meaning: w.meaning,
                exampleEn: Value(w.exampleEn),
                level: const Value(1),
                presetId: Value(
                  '$kSampleWordbookPresetId:${w.headword}:${w.partOfSpeech.value}',
                ),
              ),
            );
        wordIds.add(wordId);
        await _db
            .into(_db.wordbookEntries)
            .insert(
              WordbookEntriesCompanion.insert(
                wordbookId: wordbookId,
                wordId: wordId,
                sortOrder: Value(i),
              ),
            );
      }

      final logCount = await _seedHistory(
        profileId: profileId,
        wordIds: wordIds,
        now: now,
      );

      return SampleDataInstallResult(
        wordbookId: wordbookId,
        wordCount: wordIds.length,
        logCount: logCount,
      );
    });
  }

  /// 直近14日分の学習履歴・日次集計と、習熟度に幅を持たせた学習状態を作る
  /// （統計とストリークの見え方がすぐ分かる分量。§4）。
  ///
  /// ここで作る値は実際のプレイを再現したものではなく、表示確認用の代表値。
  Future<int> _seedHistory({
    required int profileId,
    required List<int> wordIds,
    required DateTime now,
  }) async {
    const days = 14;
    const answeredPerDay = 20;
    const correctPerDay = 16;
    const uuid = Uuid();
    final today = studyDateOf(now);

    var logCount = 0;
    for (var d = days - 1; d >= 0; d--) {
      final studyDate = addStudyDays(today, -d);
      final dayStart = studyDayStartOfDate(studyDate).add(const Duration(hours: 14));
      final sessionId = uuid.v4();

      await _db
          .into(_db.studySessions)
          .insert(
            StudySessionsCompanion.insert(
              id: sessionId,
              profileId: profileId,
              mode: StudyMode.spell.value,
              startedAt: dayStart,
              finishedAt: Value(dayStart.add(const Duration(minutes: 10))),
              plannedCount: const Value(answeredPerDay),
              answeredCount: const Value(answeredPerDay),
              correctCount: const Value(correctPerDay),
              xpEarned: Value(correctPerDay * 15),
              avgReactionMs: const Value(3000),
            ),
          );

      for (var i = 0; i < answeredPerDay; i++) {
        // 5問に1問だけ不正解にする（80%程度の正答率に見せる）。
        final isCorrect = i % 5 != 4;
        final wordId = wordIds[(d * answeredPerDay + i) % wordIds.length];
        await _db
            .into(_db.learningLogs)
            .insert(
              LearningLogsCompanion.insert(
                profileId: profileId,
                sessionId: sessionId,
                wordId: Value(wordId),
                mode: StudyMode.spell.value,
                direction: StudyDirection.jaToEn.value,
                isCorrect: isCorrect,
                grade: isCorrect ? 4 : 2,
                elapsedMs: 3000,
                answeredAt: dayStart.add(Duration(seconds: i * 10)),
              ),
            );
        logCount++;
      }

      await _db
          .into(_db.dailyStats)
          .insert(
            DailyStatsCompanion.insert(
              profileId: profileId,
              studyDate: studyDate,
              answeredCount: const Value(answeredPerDay),
              correctCount: const Value(correctPerDay),
              xp: Value(correctPerDay * 15),
              studySeconds: const Value(600),
              goalCount: answeredPerDay,
              goalMet: const Value(true),
            ),
          );
    }

    // 習熟度に幅を持たせる（[Docs/06_features/srs_scheduler.md] §5）。
    // 10語ずつ マスター / 定着 / 学習中 に振り分け、統計の内訳がすぐ分かるようにする。
    for (var i = 0; i < wordIds.length; i++) {
      final bucket = i ~/ 10;
      final wordId = wordIds[i];
      final _ReviewSeed seed = switch (bucket) {
        0 => const _ReviewSeed(
          intervalDays: 120,
          correctStreak: 5,
          totalCorrect: 9,
          totalIncorrect: 1,
          masteryLevel: 3,
          dueInDays: 120,
        ),
        1 => const _ReviewSeed(
          intervalDays: 30,
          correctStreak: 2,
          totalCorrect: 6,
          totalIncorrect: 2,
          masteryLevel: 2,
          dueInDays: 10,
        ),
        _ => const _ReviewSeed(
          intervalDays: 3,
          correctStreak: 1,
          totalCorrect: 3,
          totalIncorrect: 3,
          masteryLevel: 1,
          dueInDays: 0,
        ),
      };
      await _db
          .into(_db.wordReviews)
          .insert(
            WordReviewsCompanion.insert(
              profileId: profileId,
              wordId: wordId,
              dueAt: now.add(Duration(days: seed.dueInDays)),
              repetition: Value(seed.correctStreak),
              intervalDays: Value(seed.intervalDays),
              easeFactor: const Value(2.4),
              lastReviewedAt: Value(now.subtract(const Duration(days: 1))),
              firstLearnedAt: Value(now.subtract(Duration(days: days))),
              correctStreak: Value(seed.correctStreak),
              totalCorrect: Value(seed.totalCorrect),
              totalIncorrect: Value(seed.totalIncorrect),
              masteryLevel: Value(seed.masteryLevel),
            ),
          );
    }

    return logCount;
  }

  /// 削除で消える件数を事前に数える（[STYLE_GUIDE §4.3]）。
  Future<SampleDataDeletePreview> inspectDelete() async {
    final partition = await _partitionWords();
    return SampleDataDeletePreview(
      deletableWordCount: partition.deletable.length,
      keptWordCount: partition.kept,
    );
  }

  /// サンプル単語帳と、**そこにしか属さない語**・その学習状態・履歴を削除する。
  /// 他の単語帳にも属している語は残す（§4）。
  Future<SampleDataDeleteResult> delete() {
    return _db.transaction(() async {
      final partition = await _partitionWords();
      if (partition.bookId == null) {
        throw StateError('サンプルデータが見つかりません。');
      }

      // 単語帳を消す（wordbook_entries は cascade で消える）。
      await (_db.delete(
        _db.wordbooks,
      )..where((t) => t.id.equals(partition.bookId!))).go();

      if (partition.deletable.isNotEmpty) {
        await (_db.delete(
          _db.words,
        )..where((t) => t.id.isIn(partition.deletable))).go();
      }

      return SampleDataDeleteResult(
        deletedWordCount: partition.deletable.length,
        keptWordCount: partition.kept,
      );
    });
  }

  /// サンプル単語帳の収録語を「このサンプルにしか属さない語（削除できる）」と
  /// 「他の単語帳にも属している語（残す）」に分ける。
  Future<_WordPartition> _partitionWords() async {
    final book = await _findBook();
    if (book == null) return const _WordPartition(bookId: null, deletable: [], kept: 0);

    final entries = await (_db.select(
      _db.wordbookEntries,
    )..where((t) => t.wordbookId.equals(book.id))).get();

    final deletable = <int>[];
    var kept = 0;
    for (final entry in entries) {
      final others =
          await (_db.select(_db.wordbookEntries)..where(
                (t) =>
                    t.wordId.equals(entry.wordId) &
                    t.wordbookId.equals(book.id).not(),
              ))
              .get();
      if (others.isEmpty) {
        deletable.add(entry.wordId);
      } else {
        kept++;
      }
    }
    return _WordPartition(bookId: book.id, deletable: deletable, kept: kept);
  }
}

@immutable
class _WordPartition {
  final int? bookId;
  final List<int> deletable;
  final int kept;

  const _WordPartition({
    required this.bookId,
    required this.deletable,
    required this.kept,
  });
}

@immutable
class _ReviewSeed {
  final double intervalDays;
  final int correctStreak;
  final int totalCorrect;
  final int totalIncorrect;
  final int masteryLevel;
  final int dueInDays;

  const _ReviewSeed({
    required this.intervalDays,
    required this.correctStreak,
    required this.totalCorrect,
    required this.totalIncorrect,
    required this.masteryLevel,
    required this.dueInDays,
  });
}

@immutable
class _SampleWord {
  final String headword;
  final PartOfSpeech partOfSpeech;
  final String meaning;
  final String? exampleEn;

  const _SampleWord({
    required this.headword,
    this.partOfSpeech = PartOfSpeech.noun,
    required this.meaning,
    this.exampleEn,
  });
}

/// サンプル単語帳の30語。統計の見え方を確認しやすいよう平易な語を選んだ。
const _kSampleWords = <_SampleWord>[
  _SampleWord(headword: 'apple', meaning: 'りんご', exampleEn: 'I ate an apple.'),
  _SampleWord(headword: 'book', meaning: '本', exampleEn: 'This is my book.'),
  _SampleWord(headword: 'cat', meaning: '猫', exampleEn: 'The cat is sleeping.'),
  _SampleWord(headword: 'dog', meaning: '犬', exampleEn: 'My dog is friendly.'),
  _SampleWord(headword: 'egg', meaning: '卵', exampleEn: 'I had an egg for breakfast.'),
  _SampleWord(headword: 'fish', meaning: '魚', exampleEn: 'We caught a fish.'),
  _SampleWord(headword: 'garden', meaning: '庭', exampleEn: 'She works in the garden.'),
  _SampleWord(headword: 'house', meaning: '家', exampleEn: 'They live in a big house.'),
  _SampleWord(headword: 'ice', meaning: '氷', exampleEn: 'The lake turned to ice.'),
  _SampleWord(
    headword: 'jump',
    partOfSpeech: PartOfSpeech.verb,
    meaning: 'とぶ',
    exampleEn: 'The rabbit can jump high.',
  ),
  _SampleWord(headword: 'kite', meaning: 'たこ', exampleEn: 'We flew a kite.'),
  _SampleWord(headword: 'lemon', meaning: 'レモン', exampleEn: 'This lemon is sour.'),
  _SampleWord(headword: 'moon', meaning: '月', exampleEn: 'The moon is bright tonight.'),
  _SampleWord(headword: 'nest', meaning: '巣', exampleEn: 'A bird built a nest.'),
  _SampleWord(headword: 'orange', meaning: 'オレンジ', exampleEn: 'I like orange juice.'),
  _SampleWord(headword: 'pencil', meaning: '鉛筆', exampleEn: 'Use a pencil to write.'),
  _SampleWord(headword: 'queen', meaning: '女王', exampleEn: 'The queen wore a crown.'),
  _SampleWord(headword: 'rain', meaning: '雨', exampleEn: 'It began to rain.'),
  _SampleWord(headword: 'sun', meaning: '太陽', exampleEn: 'The sun rises in the east.'),
  _SampleWord(headword: 'tree', meaning: '木', exampleEn: 'A tall tree stands here.'),
  _SampleWord(headword: 'umbrella', meaning: '傘', exampleEn: 'Take an umbrella today.'),
  _SampleWord(headword: 'van', meaning: 'バン', exampleEn: 'The van is parked outside.'),
  _SampleWord(headword: 'water', meaning: '水', exampleEn: 'Drink plenty of water.'),
  _SampleWord(headword: 'box', meaning: '箱', exampleEn: 'Put it in the box.'),
  _SampleWord(
    headword: 'yellow',
    partOfSpeech: PartOfSpeech.adjective,
    meaning: '黄色い',
    exampleEn: 'The flower is yellow.',
  ),
  _SampleWord(headword: 'zoo', meaning: '動物園', exampleEn: 'We went to the zoo.'),
  _SampleWord(headword: 'bird', meaning: '鳥', exampleEn: 'A bird sang in the tree.'),
  _SampleWord(headword: 'chair', meaning: '椅子', exampleEn: 'Please sit on the chair.'),
  _SampleWord(headword: 'door', meaning: 'ドア', exampleEn: 'Close the door quietly.'),
  _SampleWord(headword: 'elephant', meaning: '象', exampleEn: 'An elephant is very large.'),
];
