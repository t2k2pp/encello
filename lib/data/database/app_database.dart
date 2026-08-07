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
    // 例文と和訳は必ず対で持つため（`word_examples` は両方 not null）、
    // 片方でも欠けている語は行を作らない。
    await customStatement('''
      INSERT INTO word_examples
        (word_id, example_en, example_ja, source_preset_id, sort_order)
      SELECT
        id,
        example_en,
        example_ja,
        CASE
          WHEN preset_id IS NULL THEN NULL
          WHEN instr(preset_id, ':') = 0 THEN preset_id
          ELSE substr(preset_id, 1, instr(preset_id, ':') - 1)
        END,
        0
      FROM words
      WHERE example_en IS NOT NULL AND example_en <> ''
        AND example_ja IS NOT NULL AND example_ja <> ''
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
