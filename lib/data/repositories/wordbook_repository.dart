import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/utils/enums.dart';
import '../database/app_database.dart';

/// 単語帳と収録語数（一覧に出す）。
class WordbookWithCount {
  final Wordbook wordbook;

  /// 収録語数（`wordbook_entries` の行数）。
  final int wordCount;

  const WordbookWithCount({required this.wordbook, required this.wordCount});

  WordbookCategory get category =>
      WordbookCategory.fromValue(wordbook.category);

  WordbookSource get source => WordbookSource.fromValue(wordbook.source);

  /// プリセット単語帳とマイ単語帳は削除できない（[Docs/06_features/wordbooks.md] §4）。
  bool get canDelete =>
      source != WordbookSource.preset && category != WordbookCategory.myWords;
}

/// 単語帳の読み書き（[Docs/06_features/wordbooks.md]）。
class WordbookRepository {
  final AppDatabase _db;

  WordbookRepository(this._db);

  /// [profileId] から見える単語帳（共有の単語帳＋自分のマイ単語帳）を並び順で返す。
  /// 他の学習者のマイ単語帳は出さない。
  Stream<List<WordbookWithCount>> watchVisible(int profileId) {
    final count = _db.wordbookEntries.wordId.count();
    final query = _db.select(_db.wordbooks).join([
      leftOuterJoin(
        _db.wordbookEntries,
        _db.wordbookEntries.wordbookId.equalsExp(_db.wordbooks.id),
        useColumns: false,
      ),
    ]);
    query
      ..addColumns([count])
      ..where(
        _db.wordbooks.ownerProfileId.isNull() |
            _db.wordbooks.ownerProfileId.equals(profileId),
      )
      ..groupBy([_db.wordbooks.id])
      ..orderBy([
        OrderingTerm.asc(_db.wordbooks.sortOrder),
        OrderingTerm.asc(_db.wordbooks.id),
      ]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          WordbookWithCount(
            wordbook: row.readTable(_db.wordbooks),
            wordCount: row.read(count) ?? 0,
          ),
      ],
    );
  }

  Future<Wordbook?> findById(int id) => (_db.select(
    _db.wordbooks,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  /// `presetId` → 単語帳。例文がどの単語帳のものかを名前で示すために使う
  /// （`word_examples.sourcePresetId`。[Docs/03_data_model.md] §2.4）。
  Stream<Map<String, Wordbook>> watchByPresetId() {
    final query = _db.select(_db.wordbooks)
      ..where((t) => t.presetId.isNotNull());
    return query.watch().map((rows) => {for (final b in rows) b.presetId!: b});
  }

  /// [profileId] のマイ単語帳（`category = myWords`）を返す。
  /// プロファイル作成時に必ず1冊作られる（[Docs/06_features/my_words.md] §2）ため、
  /// 見つからない場合はデータ不整合として例外にする。
  Future<Wordbook> myWordsBookOf(int profileId) async {
    final book =
        await (_db.select(_db.wordbooks)..where(
              (t) =>
                  t.ownerProfileId.equals(profileId) &
                  t.category.equals(WordbookCategory.myWords.value),
            ))
            .getSingleOrNull();
    if (book == null) {
      throw StateError('マイ単語帳が見つかりません（profileId=$profileId）');
    }
    return book;
  }

  /// ユーザー単語帳を作る。全学習者で共有する（`ownerProfileId` は null）。
  Future<int> create({
    required String name,
    required String emoji,
    required int colorSeed,
    String? note,
  }) async {
    final maxOrder = _db.wordbooks.sortOrder.max();
    final row = await (_db.selectOnly(
      _db.wordbooks,
    )..addColumns([maxOrder])).getSingle();
    return _db
        .into(_db.wordbooks)
        .insert(
          WordbooksCompanion.insert(
            name: name,
            emoji: emoji,
            colorSeed: colorSeed,
            category: WordbookCategory.custom.value,
            source: WordbookSource.user.value,
            note: Value(note),
            sortOrder: Value((row.read(maxOrder) ?? 0) + 1),
          ),
        );
  }

  Future<void> update(
    int id, {
    required String name,
    required String emoji,
    required int colorSeed,
    String? note,
  }) async {
    final updated =
        await (_db.update(_db.wordbooks)..where((t) => t.id.equals(id))).write(
          WordbooksCompanion(
            name: Value(name),
            emoji: Value(emoji),
            colorSeed: Value(colorSeed),
            note: Value(note),
            updatedAt: Value(DateTime.now()),
          ),
        );
    if (updated == 0) throw StateError('更新対象の単語帳が見つかりません（id=$id）');
  }

  /// この単語帳を学習対象にしている学習者の名前（削除確認に出す）。
  Future<List<String>> profilesStudying(int wordbookId) async {
    final profiles = await _db.select(_db.profiles).get();
    return [
      for (final p in profiles)
        if (decodeIdList(p.selectedWordbookIds).contains(wordbookId)) p.name,
    ];
  }

  /// 単語帳を削除する。**所属（`wordbook_entries`）だけを消し、`words` と
  /// `word_reviews` は残す**（他の単語帳にも属している可能性があるため。
  /// どこにも属さなくなった語は 設定 > データ から手動で整理する）。
  ///
  /// 学習対象にしている学習者があれば、その選択からも外す。
  Future<void> delete(int id) async {
    await _db.transaction(() async {
      final book = await findById(id);
      if (book == null) throw StateError('削除対象の単語帳が見つかりません（id=$id）');
      if (WordbookSource.fromValue(book.source) == WordbookSource.preset) {
        throw StateError('プリセット単語帳は削除できません。');
      }
      if (WordbookCategory.fromValue(book.category) ==
          WordbookCategory.myWords) {
        throw StateError('マイ単語帳は削除できません。');
      }

      for (final p in await _db.select(_db.profiles).get()) {
        final ids = decodeIdList(p.selectedWordbookIds);
        if (!ids.contains(id)) continue;
        await (_db.update(_db.profiles)..where((t) => t.id.equals(p.id))).write(
          ProfilesCompanion(
            selectedWordbookIds: Value(encodeIdList(ids.where((e) => e != id))),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
      // wordbook_entries は cascade delete で外れる（words は残る）。
      await (_db.delete(_db.wordbooks)..where((t) => t.id.equals(id))).go();
    });
  }

  /// 学習対象の単語帳を学習者ごとに設定する（FR-04）。
  Future<void> setStudyTarget(
    Profile profile,
    int wordbookId, {
    required bool selected,
  }) async {
    final ids = decodeIdList(profile.selectedWordbookIds).toSet();
    if (selected) {
      ids.add(wordbookId);
    } else {
      ids.remove(wordbookId);
    }
    await (_db.update(
      _db.profiles,
    )..where((t) => t.id.equals(profile.id))).write(
      ProfilesCompanion(
        selectedWordbookIds: Value(encodeIdList(ids)),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// 語を単語帳へ所属させる。すでに所属していれば並び順だけを保つ。
  Future<void> addWord(int wordbookId, int wordId) async {
    final maxOrder = _db.wordbookEntries.sortOrder.max();
    final row =
        await (_db.selectOnly(_db.wordbookEntries)
              ..addColumns([maxOrder])
              ..where(_db.wordbookEntries.wordbookId.equals(wordbookId)))
            .getSingle();
    await _db
        .into(_db.wordbookEntries)
        .insertOnConflictUpdate(
          WordbookEntriesCompanion.insert(
            wordbookId: wordbookId,
            wordId: wordId,
            sortOrder: Value((row.read(maxOrder) ?? -1) + 1),
          ),
        );
  }

  /// 語の所属を外す（語そのものと学習状態は残す）。
  Future<void> removeWord(int wordbookId, int wordId) async {
    await (_db.delete(_db.wordbookEntries)..where(
          (t) => t.wordbookId.equals(wordbookId) & t.wordId.equals(wordId),
        ))
        .go();
  }

  /// ある語が属している単語帳（詳細のチップ用）。
  /// 所属の増減にその場で追従させるためストリームで返す。
  Stream<List<Wordbook>> watchWordbooksOf(int wordId, int profileId) {
    final query = _db.select(_db.wordbooks).join([
      innerJoin(
        _db.wordbookEntries,
        _db.wordbookEntries.wordbookId.equalsExp(_db.wordbooks.id),
        useColumns: false,
      ),
    ]);
    query
      ..where(
        _db.wordbookEntries.wordId.equals(wordId) &
            (_db.wordbooks.ownerProfileId.isNull() |
                _db.wordbooks.ownerProfileId.equals(profileId)),
      )
      ..orderBy([OrderingTerm.asc(_db.wordbooks.sortOrder)]);
    return query.map((row) => row.readTable(_db.wordbooks)).watch();
  }
}

/// `profiles.selectedWordbookIds` / `audioPackIds` の JSON 配列を読む。
///
/// 壊れた値（配列でない・数値でない）は推測で補わず例外にする。
List<int> decodeIdList(String json) {
  final decoded = jsonDecode(json);
  if (decoded is! List) {
    throw FormatException('id の配列ではありません: $json');
  }
  return [
    for (final e in decoded)
      if (e is int) e else throw FormatException('id が整数ではありません: $e'),
  ];
}

/// id の配列を `profiles` の列へ書く形にする。
String encodeIdList(Iterable<int> ids) => jsonEncode(ids.toList());
