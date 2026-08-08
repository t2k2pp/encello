import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show AssetBundle;

import '../database/app_database.dart';
import '../repositories/word_repository.dart';
import 'preset_wordbook.dart';

/// プリセット投入の結果（起動ゲートのログ・テスト用）。
class SeedImportResult {
  /// 実際に投入・更新したか。false = 版が同じで何もしなかった。
  final bool applied;

  /// 投入後の版（`seed.installedVersion` に書いた値）。
  final int installedVersion;

  /// 追加・更新した単語帳の数。
  final int wordbookCount;

  /// 追加・更新した語の延べ数。
  final int wordCount;

  const SeedImportResult({
    required this.applied,
    required this.installedVersion,
    required this.wordbookCount,
    required this.wordCount,
  });
}

/// プリセット単語帳の投入（[Docs/06_features/wordbooks.md] §3.1）。
///
/// アセットの最大 `seedVersion` が投入済みの版より新しいときだけ、差分を適用する。
/// 投入は端末に1回だけで、学習者を増やしても再投入しない
/// （学習対象の選択は `profiles.selectedWordbookIds` で学習者ごとに持つ）。
class SeedImporter {
  final AppDatabase _db;
  final AssetBundle _bundle;

  /// このインスタンスが読むアセット。既定は [assetPaths]。
  final List<String> paths;

  /// 同梱するプリセット単語帳のアセットパス。`sortOrder`（易→難）の順に並べる。
  ///
  /// アセット一覧の走査ではなく明示列挙にする。列挙漏れは投入されないことで
  /// すぐ気付けるが、走査だと意図しないファイルが混ざっても気付けないため。
  static const assetPaths = <String>[
    'assets/wordbooks/jhs_v1.json',
    'assets/wordbooks/hs_basic_v1.json',
    'assets/wordbooks/hs_advanced_v1.json',
    'assets/wordbooks/eiken_pre2_v1.json',
    'assets/wordbooks/eiken_2_v1.json',
    'assets/wordbooks/toeic_basic_v1.json',
  ];

  /// [paths] は差し替え可能にしてある。テストが1冊だけを投入して
  /// 差分適用のふるまいを確かめられるようにするため。
  const SeedImporter(this._db, this._bundle, {this.paths = assetPaths});

  /// アセット側の版（同梱プリセットの最大 `seedVersion`）。
  Future<int> assetVersion() async {
    final books = await loadPresets();
    return books.map((b) => b.seedVersion).reduce((a, b) => a > b ? a : b);
  }

  /// 同梱プリセットをすべて読む。壊れていれば例外を投げる（起動ゲートが再試行を出す）。
  Future<List<PresetWordbook>> loadPresets() async {
    final books = <PresetWordbook>[];
    for (final path in paths) {
      final raw = await _bundle.loadString(path);
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) {
        throw FormatException('$path がオブジェクトではありません');
      }
      books.add(PresetWordbook.fromJson(json));
    }
    return books;
  }

  /// 投入済みの版より新しいときだけ投入する。
  ///
  /// 途中で失敗したらすべて巻き戻し、`installedVersion` も進めない。
  /// 半分だけ入った単語帳を残さないため、全単語帳を1トランザクションで適用する。
  Future<SeedImportResult> importIfNeeded({
    required int installedVersion,
  }) async {
    final books = await loadPresets();
    final version = books
        .map((b) => b.seedVersion)
        .reduce((a, b) => a > b ? a : b);
    if (installedVersion >= version) {
      return SeedImportResult(
        applied: false,
        installedVersion: installedVersion,
        wordbookCount: 0,
        wordCount: 0,
      );
    }

    var wordCount = 0;
    await _db.transaction(() async {
      for (final book in books) {
        wordCount += await _applyWordbook(book);
      }
    });

    return SeedImportResult(
      applied: true,
      installedVersion: version,
      wordbookCount: books.length,
      wordCount: wordCount,
    );
  }

  /// 単語帳1冊を適用し、収録語数を返す。
  Future<int> _applyWordbook(PresetWordbook book) async {
    final wordbookId = await _upsertWordbook(book);

    final wordIds = <int>[];
    for (final word in book.words) {
      final upserted = await _upsertWord(word);
      wordIds.add(upserted.id);
      // ユーザーが編集した語は例文も上書きしない（語と同じ扱い。§3.1）。
      if (!upserted.isEdited) await _upsertExample(book, word, upserted.id);
    }

    // アセットから消えた語は**所属だけ**を外す。`words` の行と `word_reviews` は
    // 残す（学習履歴を消さない。[Docs/06_features/wordbooks.md] §3.1）。
    await (_db.delete(_db.wordbookEntries)..where(
          (t) => t.wordbookId.equals(wordbookId) & t.wordId.isNotIn(wordIds),
        ))
        .go();

    for (var i = 0; i < wordIds.length; i++) {
      await _db
          .into(_db.wordbookEntries)
          .insertOnConflictUpdate(
            WordbookEntriesCompanion.insert(
              wordbookId: wordbookId,
              wordId: wordIds[i],
              sortOrder: Value(i),
            ),
          );
    }
    return wordIds.length;
  }

  Future<int> _upsertWordbook(PresetWordbook book) async {
    final existing = await (_db.select(
      _db.wordbooks,
    )..where((t) => t.presetId.equals(book.presetId))).getSingleOrNull();

    if (existing == null) {
      return _db
          .into(_db.wordbooks)
          .insert(
            WordbooksCompanion.insert(
              name: book.name,
              emoji: book.emoji,
              colorSeed: book.colorSeed,
              category: book.category.value,
              source: 'preset',
              presetId: Value(book.presetId),
              seedVersion: Value(book.seedVersion),
              bandSize: Value(book.bandSize),
              note: Value(book.note),
              sortOrder: Value(book.sortOrder),
            ),
          );
    }

    await (_db.update(
      _db.wordbooks,
    )..where((t) => t.id.equals(existing.id))).write(
      WordbooksCompanion(
        name: Value(book.name),
        emoji: Value(book.emoji),
        colorSeed: Value(book.colorSeed),
        category: Value(book.category.value),
        seedVersion: Value(book.seedVersion),
        bandSize: Value(book.bandSize),
        note: Value(book.note),
        sortOrder: Value(book.sortOrder),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return existing.id;
  }

  /// 共有の語（`ownerProfileId = null`）を `(headword, partOfSpeech)` で upsert し、
  /// id と「ユーザーが編集済みか」を返す。
  ///
  /// **`isEdited = true` の語は上書きしない**（ユーザーの編集を消さない）。
  Future<({int id, bool isEdited})> _upsertWord(PresetWord word) async {
    final existing =
        await (_db.select(_db.words)..where(
              (t) =>
                  t.headword.equals(word.headword) &
                  t.partOfSpeech.equals(word.partOfSpeech.value) &
                  t.ownerProfileId.isNull(),
            ))
            .getSingleOrNull();

    if (existing == null) {
      final id = await _db
          .into(_db.words)
          .insert(
            WordsCompanion.insert(
              headword: word.headword,
              partOfSpeech: word.partOfSpeech.value,
              phonetic: Value(word.phonetic),
              meaning: word.meaning,
              level: Value(word.level),
              presetId: Value(word.presetId),
            ),
          );
      return (id: id, isEdited: false);
    }

    if (existing.isEdited) return (id: existing.id, isEdited: true);

    await (_db.update(_db.words)..where((t) => t.id.equals(existing.id))).write(
      WordsCompanion(
        phonetic: Value(word.phonetic),
        meaning: Value(word.meaning),
        level: Value(word.level),
        presetId: Value(word.presetId),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return (id: existing.id, isEdited: false);
  }

  /// 例文を `(wordId, sourcePresetId)` で upsert する
  /// （[Docs/06_features/wordbooks.md] §3.1、[Docs/03_data_model.md] §2.4）。
  ///
  /// `sourcePresetId` は**投入中の単語帳の `presetId`**（`jhs_v1` など）。
  /// こうしないと、同じ語を複数の単語帳が持つとき、最後に投入した単語帳の例文で
  /// 上書きされてしまう。`sortOrder` はその単語帳の `sortOrder`（易→難）。
  ///
  /// 例文か和訳のどちらかが欠けている語には行を作らない
  /// （`word_examples` は例文と和訳を必ず対で持つ）。
  Future<void> _upsertExample(
    PresetWordbook book,
    PresetWord word,
    int wordId,
  ) async {
    final en = word.exampleEn;
    final ja = word.exampleJa;
    if (en == null || ja == null) return;

    await WordRepository(_db).upsertSourcedExample(
      wordId: wordId,
      sourcePresetId: book.presetId,
      exampleEn: en,
      exampleJa: ja,
      sortOrder: book.sortOrder,
    );
  }

  /// `words.presetId` からアセットの語を引き直す（詳細画面の「元に戻す」）。
  /// アセットに該当 id が無ければ null（プリセットの改版で語が消えた場合）。
  Future<PresetWord?> findPresetWord(String presetId) async {
    for (final book in await loadPresets()) {
      for (final word in book.words) {
        if (word.presetId == presetId) return word;
      }
    }
    return null;
  }
}
