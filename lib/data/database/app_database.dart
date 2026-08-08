import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

import '../../core/utils/app_data_dir.dart';
import 'dao/profile_dao.dart';
import 'tables/audio.dart';
import 'tables/profiles.dart';
import 'tables/reviews.dart';
import 'tables/study.dart';
import 'tables/word_parts.dart';
import 'tables/wordbooks.dart';
import 'tables/words.dart';

part 'app_database.g.dart';

/// 端末内 DB（[Docs/03_data_model.md]）。
///
/// 初期データ（プリセット単語帳・語の部品・擬似語）はここでは投入しない。
/// アセットの `seedVersion` を見て差分適用する `SeedImporter` が起動ゲートから行う
/// （[Docs/02_architecture.md] §4）。最初の学習者も初回起動時に UI から作らせる。
@DriftDatabase(
  tables: [
    Profiles,
    WordFamilies,
    Words,
    WordExamples,
    Wordbooks,
    WordbookEntries,
    WordParts,
    WordPartLinks,
    WordReviews,
    PartReviews,
    ResolvedConfusions,
    StudySessions,
    LearningLogs,
    DailyStats,
    Achievements,
    VocabSizeTests,
    AudioPacks,
    WordAudios,
  ],
  daos: [ProfileDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor? executor) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await _migrateExamplesToWordExamples(m);
      }
    },
    beforeOpen: (details) async {
      // 学習者の削除で学習記録とマイ単語を確実に消すため、外部キーを有効にする。
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// v1 → v2: 単数の `words.exampleEn` / `exampleJa` を `word_examples` に移す
  /// （[Docs/03_data_model.md] §2.4・§9）。
  ///
  /// 移してから列を落とす。順序を逆にすると例文が失われる。
  Future<void> _migrateExamplesToWordExamples(Migrator m) async {
    await m.createTable(wordExamples);
    await m.createIndex(wordExamplesWordId);
    await m.createIndex(wordExamplesSourceUnique);
    await m.createIndex(wordExamplesUserUnique);

    // `sourcePresetId` は `words.presetId`（`<presetId>:<headword>:<partOfSpeech>`）の
    // 先頭要素。マイ単語（`presetId` が null）はユーザーの文として null にする。
    //
    // 和訳の要否は出どころで変わる（[Docs/03_data_model.md] §2.4）。
    // プリセット由来は和訳が必須なので、欠けている語は行を作らない。
    // ユーザーの文は和訳が任意なので、無いときは **null** で移す（空文字を入れない）。
    //
    // `sortOrder` はユーザーの文が 0、プリセット由来はその単語帳の `sortOrder`。
    // 単語帳は `wordbooks.preset_id` で引く。対応する単語帳が無ければ 0。
    await customStatement('''
      WITH src AS (
        SELECT
          id,
          example_en,
          NULLIF(example_ja, '') AS example_ja,
          CASE
            WHEN preset_id IS NULL THEN NULL
            WHEN instr(preset_id, ':') = 0 THEN preset_id
            ELSE substr(preset_id, 1, instr(preset_id, ':') - 1)
          END AS source_preset_id
        FROM words
        WHERE example_en IS NOT NULL AND example_en <> ''
      )
      INSERT INTO word_examples
        (word_id, example_en, example_ja, source_preset_id, sort_order)
      SELECT
        src.id,
        src.example_en,
        src.example_ja,
        src.source_preset_id,
        CASE
          WHEN src.source_preset_id IS NULL THEN 0
          ELSE COALESCE(
            (
              SELECT b.sort_order FROM wordbooks b
              WHERE b.preset_id = src.source_preset_id
            ),
            0
          )
        END
      FROM src
      WHERE src.source_preset_id IS NULL OR src.example_ja IS NOT NULL
    ''');

    // 例文を移し終えてから2列を落とす。SQLite は列の削除ができないため、
    // drift の 12 ステップ手順（表の作り直し）に任せる。
    await m.alterTable(TableMigration(words));
  }

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dir = await appDataDirectory();
      final file = File(p.join(dir.path, 'encello.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
