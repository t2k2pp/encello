import 'package:drift/drift.dart';

import 'profiles.dart';

/// 派生語ファミリー（[Docs/06_features/word_families.md]）。
/// 所属は `words.familyId` で表す。
@TableIndex(name: 'word_families_base_form', columns: {#baseForm}, unique: true)
class WordFamilies extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 語族の代表形（例 `decide`）。
  TextColumn get baseForm => text().withLength(min: 1, max: 60)();
  TextColumn get note => text().nullable()();
}

/// 単語（[Docs/03_data_model.md] §2.3）。
///
/// 単語は**単語帳に属さない独立したマスタ**にする。同じ語が複数の単語帳に載っていても
/// 実体は1つで、学習状態も（学習者ごとに）1つになる。
///
/// 一意制約は「共有の語は全体で1つ」「マイ単語は人ごとに独立」の2本立て。
/// SQLite の UNIQUE は NULL 同士を別物として扱うため、1本の
/// `UNIQUE(headword, partOfSpeech, ownerProfileId)` では共有の語の重複を防げない。
/// そのため部分インデックスを2本に分ける。
@TableIndex.sql('''
  CREATE UNIQUE INDEX words_shared_unique ON words (headword, part_of_speech)
    WHERE owner_profile_id IS NULL
''')
@TableIndex.sql('''
  CREATE UNIQUE INDEX words_owned_unique
    ON words (headword, part_of_speech, owner_profile_id)
    WHERE owner_profile_id IS NOT NULL
''')
@TableIndex(name: 'words_headword', columns: {#headword})
@TableIndex(name: 'words_owner_profile_id', columns: {#ownerProfileId})
@TableIndex(name: 'words_family_id', columns: {#familyId})
@TableIndex(name: 'words_preset_id', columns: {#presetId})
class Words extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 見出し語。**小文字で正規化して保存する**。
  TextColumn get headword => text().withLength(min: 1, max: 60)();

  /// 品詞（`PartOfSpeech`）。
  TextColumn get partOfSpeech => text()();

  TextColumn get phonetic => text().nullable()();

  /// 日本語訳。`isDraft = true` のときだけ空文字を許す。
  TextColumn get meaning => text()();

  /// 英語例文（マイ単語では「見つけた文」）。
  TextColumn get exampleEn => text().nullable()();
  TextColumn get exampleJa => text().nullable()();

  /// 語のつくりの説明1行（[Docs/06_features/word_parts.md] §3.1）。
  TextColumn get partsNote => text().nullable()();

  /// 取り違えやすい語との区別の覚え方。
  TextColumn get confusionNote => text().nullable()();

  IntColumn get familyId =>
      integer().nullable().references(WordFamilies, #id)();

  /// 難易度 1〜5。
  IntColumn get level => integer().withDefault(const Constant(1))();

  /// 頻度順位。ライセンス条件を確認できた頻度リストを持つ語にだけ入れる
  /// （[Docs/03_data_model.md] §7）。値が無い間は「頻度順」のソート項目を出さない。
  IntColumn get frequencyRank => integer().nullable()();

  /// プリセット由来ならアセット内の識別子。編集前の値を DB に二重に持たず、
  /// これでアセットを引き直して「元に戻す」を実現する（FR-06）。
  TextColumn get presetId => text().nullable()();

  /// マイ単語の持ち主。共有の語は null。
  IntColumn get ownerProfileId => integer()
      .nullable()
      .references(Profiles, #id, onDelete: KeyAction.cascade)();

  /// 訳が未入力のマイ単語（出題されない）。
  BoolColumn get isDraft => boolean().withDefault(const Constant(false))();

  /// プリセット語をユーザーが編集した。
  BoolColumn get isEdited => boolean().withDefault(const Constant(false))();

  /// 出題から除外する。
  BoolColumn get isExcluded => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
