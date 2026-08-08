import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/usecases/vocab_size_estimator.dart';
import '../../domain/usecases/vocab_test_builder.dart';
import '../database/app_database.dart';

/// 語彙力測定の読み書き（[Docs/06_features/vocab_size_test.md] §7）。
///
/// **測定の結果は `word_reviews` に一切書かない**。測定は学習ではないため、
/// 「わかる」と答えただけの語を既習にすると学習状態が実態から離れる。
class VocabTestRepository {
  final AppDatabase _db;

  VocabTestRepository(this._db);

  /// 帯に使える単語帳（`bandSize` を持つ単語帳）を易しい順に読む。
  ///
  /// 帯の語は、除外・下書きでない共有の語に限る（マイ単語は人によって中身が
  /// 違うため、帯の到達率の基準にしない）。
  Future<List<VocabBandSource>> loadBands() async {
    final books =
        await (_db.select(_db.wordbooks)
              ..where((t) => t.bandSize.isNotNull())
              ..orderBy([
                (t) => OrderingTerm.asc(t.sortOrder),
                (t) => OrderingTerm.asc(t.id),
              ]))
            .get();
    if (books.isEmpty) return const [];

    final sources = <VocabBandSource>[];
    for (final book in books) {
      final query =
          _db.select(_db.words).join([
            innerJoin(
              _db.wordbookEntries,
              _db.wordbookEntries.wordId.equalsExp(_db.words.id),
              useColumns: false,
            ),
          ])..where(
            _db.wordbookEntries.wordbookId.equals(book.id) &
                _db.words.ownerProfileId.isNull() &
                _db.words.isExcluded.equals(false) &
                _db.words.isDraft.equals(false),
          );
      final rows = await query.map((r) => r.readTable(_db.words)).get();
      if (rows.isEmpty) continue;
      sources.add(
        VocabBandSource(
          wordbookId: book.id,
          name: book.name,
          bandSize: book.bandSize!,
          words: [for (final w in rows) (wordId: w.id, headword: w.headword)],
        ),
      );
    }
    return sources;
  }

  /// 直近 [count] 回の測定で出した語の id（次回の出題で優先度を下げる）。
  Future<Set<int>> recentlyAskedWordIds(int profileId, {int count = 1}) async {
    final rows = await _recentTests(profileId, limit: count);
    return {for (final row in rows) ..._decodeIds(row.askedWordIds)};
  }

  /// 測定の履歴（新しい順）。統計の「語彙力の推移」と前回差に使う。
  Future<List<VocabSizeTest>> history(int profileId, {int limit = 50}) =>
      (_db.select(_db.vocabSizeTests)
            ..where((t) => t.profileId.equals(profileId))
            ..orderBy([(t) => OrderingTerm.desc(t.takenAt)])
            ..limit(limit))
          .get();

  /// 最新の測定。1度も測っていなければ null。
  Future<VocabSizeTest?> latest(int profileId) async {
    final rows = await _recentTests(profileId, limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<VocabSizeTest>> _recentTests(
    int profileId, {
    required int limit,
  }) =>
      (_db.select(_db.vocabSizeTests)
            ..where((t) => t.profileId.equals(profileId))
            ..orderBy([(t) => OrderingTerm.desc(t.takenAt)])
            ..limit(limit))
          .get();

  /// 測定1回を保存する。途中で ✕ を押した測定はここへ来ない（部分的な結果を保存しない）。
  Future<int> save({
    required int profileId,
    required DateTime takenAt,
    required VocabSizeEstimate estimate,
    required Iterable<int> askedWordIds,
  }) {
    return _db
        .into(_db.vocabSizeTests)
        .insert(
          VocabSizeTestsCompanion.insert(
            profileId: profileId,
            takenAt: takenAt,
            estimatedSize: estimate.estimatedSize,
            falseAlarmRate: estimate.falseAlarmRate,
            bandResults: Value(
              jsonEncode([for (final b in estimate.bands) b.toJson()]),
            ),
            askedWordIds: Value(jsonEncode(askedWordIds.toList())),
          ),
        );
  }

  /// 保存済みの帯ごとの結果を読む（統計・結果画面の再表示用）。
  static List<VocabBandResult> decodeBands(String json) {
    final decoded = jsonDecode(json);
    if (decoded is! List) {
      throw FormatException('bandResults が配列ではありません: $json');
    }
    return [
      for (final e in decoded)
        VocabBandResult.fromJson(e as Map<String, dynamic>),
    ];
  }

  static List<int> _decodeIds(String json) {
    final decoded = jsonDecode(json);
    if (decoded is! List) {
      throw FormatException('askedWordIds が配列ではありません: $json');
    }
    return [
      for (final e in decoded)
        if (e is int) e else throw FormatException('id が整数ではありません: $e'),
    ];
  }
}
