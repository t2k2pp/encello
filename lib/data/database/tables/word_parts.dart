import 'package:drift/drift.dart';

import 'words.dart';

/// 語の部品（接頭辞・語根・接尾辞。[Docs/06_features/word_parts.md] §2）。
///
/// 部品自身も学習状態（`part_reviews`）を持つ。
@TableIndex(name: 'word_parts_form_type', columns: {#form, #type}, unique: true)
class WordParts extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 表記（例 `port`）。
  TextColumn get form => text().withLength(min: 1, max: 30)();

  /// 種別（`WordPartType`: prefix / root / suffix）。
  TextColumn get type => text()();

  /// 意味（例「運ぶ」）。
  TextColumn get meaning => text()();

  /// 語源（例「ラテン語 portare」）。
  TextColumn get origin => text().nullable()();
  TextColumn get note => text().nullable()();

  /// 難易度 1〜5。
  IntColumn get level => integer().withDefault(const Constant(1))();
}

/// 単語と語の部品の紐付け（[Docs/06_features/word_parts.md] §2）。
///
/// `partId` の単独インデックスは「部品→単語」の逆引きに使う。
@TableIndex(name: 'word_part_links_part_id', columns: {#partId})
class WordPartLinks extends Table {
  IntColumn get wordId =>
      integer().references(Words, #id, onDelete: KeyAction.cascade)();
  IntColumn get partId =>
      integer().references(WordParts, #id, onDelete: KeyAction.cascade)();

  /// 語の中での並び（接頭辞→語根→接尾辞）。
  IntColumn get position => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {wordId, partId};
}
