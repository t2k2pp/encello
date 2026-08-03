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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    beforeOpen: (details) async {
      // 学習者の削除で学習記録とマイ単語を確実に消すため、外部キーを有効にする。
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dir = await appDataDirectory();
      final file = File(p.join(dir.path, 'encello.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
