import 'package:drift/drift.dart';

import 'profiles.dart';
import 'words.dart';

/// 単語帳（[Docs/03_data_model.md] §2.2）。
///
/// マイ単語帳（`category = myWords`）は学習者の作成時に自動で作り、削除できない。
@TableIndex(name: 'wordbooks_preset_id', columns: {#presetId}, unique: true)
class Wordbooks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 40)();
  TextColumn get emoji => text()();

  /// 識別色の割当シード（`AppColors.seedColor(colorSeed)`）。
  IntColumn get colorSeed => integer()();

  /// 区分（`WordbookCategory`）。
  TextColumn get category => text()();

  /// 由来（`WordbookSource`）。
  TextColumn get source => text()();

  /// `source = preset` のときアセット側の識別子（例 `jhs_v1`）。
  TextColumn get presetId => text().nullable()();

  /// マイ単語帳の持ち主。それ以外は null。
  IntColumn get ownerProfileId => integer().nullable().references(
    Profiles,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// 投入済みプリセットの版（[Docs/06_features/wordbooks.md] §3）。
  IntColumn get seedVersion => integer().withDefault(const Constant(0))();

  /// 語彙力測定で帯として使うときの語数（[Docs/06_features/vocab_size_test.md] §3）。
  IntColumn get bandSize => integer().nullable()();

  TextColumn get note => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// 単語の単語帳への所属（[Docs/03_data_model.md] §2.4）。
///
/// `wordId` の単独インデックスは「単語→所属単語帳」の逆引きに使う。
@TableIndex(name: 'wordbook_entries_word_id', columns: {#wordId})
class WordbookEntries extends Table {
  IntColumn get wordbookId =>
      integer().references(Wordbooks, #id, onDelete: KeyAction.cascade)();
  IntColumn get wordId =>
      integer().references(Words, #id, onDelete: KeyAction.cascade)();

  /// 単語帳内の並び。
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {wordbookId, wordId};
}
