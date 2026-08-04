import 'package:encello/core/utils/enums.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:encello/data/seeds/sample_data.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

/// サンプルデータの投入・削除（[Docs/06_features/export_import.md] §4、§6）。
void main() {
  late AppDatabase db;
  late Profile taro;
  late SampleDataService service;

  DateTime now() => DateTime(2026, 8, 5, 21, 0);

  setUp(() async {
    db = newTestDatabase();
    taro = await createTestProfile(db, name: 'たろう');
    service = SampleDataService(db);
  });

  group('投入', () {
    test('単語帳1冊・30語・14日分の記録ができる', () async {
      final result = await service.install(profileId: taro.id, now: now());

      expect(result.wordCount, 30);
      expect(result.logCount, 14 * 20);

      final book = await (db.select(
        db.wordbooks,
      )..where((t) => t.presetId.equals(kSampleWordbookPresetId))).getSingle();
      expect(book.name, isNotEmpty);
      expect(book.source, WordbookSource.preset.value);

      final entries = await (db.select(
        db.wordbookEntries,
      )..where((t) => t.wordbookId.equals(book.id))).get();
      expect(entries, hasLength(30));

      final dailyStats =
          await (db.select(db.dailyStats)
                ..where((t) => t.profileId.equals(taro.id)))
              .get();
      expect(dailyStats, hasLength(14));
      expect(dailyStats.every((d) => d.goalMet), isTrue);

      final reviews =
          await (db.select(db.wordReviews)
                ..where((t) => t.profileId.equals(taro.id)))
              .get();
      expect(reviews, hasLength(30));
      // 習熟度に幅がある（統計の内訳がすぐ分かる）。
      final masteryLevels = reviews.map((r) => r.masteryLevel).toSet();
      expect(masteryLevels, {1, 2, 3});
    });

    test('二重投入されない', () async {
      await service.install(profileId: taro.id, now: now());

      await expectLater(
        service.install(profileId: taro.id, now: now()),
        throwsStateError,
      );

      final words = await db.select(db.words).get();
      expect(words, hasLength(30));
      expect(await service.isInstalled(), isTrue);
    });

    test('他の学習者の記録が触れられない', () async {
      final jiro = await createTestProfile(db, name: 'じろう');
      await service.install(profileId: taro.id, now: now());

      final jiroStats =
          await (db.select(db.dailyStats)
                ..where((t) => t.profileId.equals(jiro.id)))
              .get();
      final jiroReviews =
          await (db.select(db.wordReviews)
                ..where((t) => t.profileId.equals(jiro.id)))
              .get();
      expect(jiroStats, isEmpty);
      expect(jiroReviews, isEmpty);
    });
  });

  group('削除', () {
    test('sample_v1 の語が消える', () async {
      await service.install(profileId: taro.id, now: now());

      final result = await service.delete();

      expect(result.deletedWordCount, 30);
      expect(result.keptWordCount, 0);
      expect(await db.select(db.words).get(), isEmpty);
      expect(await service.isInstalled(), isFalse);
      // 学習記録も cascade で消える。
      final reviews = await db.select(db.wordReviews).get();
      expect(reviews, isEmpty);
    });

    test('他の単語帳にも属する語は残り、残した件数を報告する', () async {
      await service.install(profileId: taro.id, now: now());

      final sampleWord = (await (db.select(
        db.words,
      )..limit(1)).get()).single;
      final otherBookId = await db
          .into(db.wordbooks)
          .insert(
            WordbooksCompanion.insert(
              name: '実データの単語帳',
              emoji: '📗',
              colorSeed: 1,
              category: WordbookCategory.custom.value,
              source: WordbookSource.user.value,
            ),
          );
      await db
          .into(db.wordbookEntries)
          .insert(
            WordbookEntriesCompanion.insert(
              wordbookId: otherBookId,
              wordId: sampleWord.id,
            ),
          );

      final preview = await service.inspectDelete();
      expect(preview.deletableWordCount, 29);
      expect(preview.keptWordCount, 1);

      final result = await service.delete();
      expect(result.deletedWordCount, 29);
      expect(result.keptWordCount, 1);

      final remaining = await db.select(db.words).get();
      expect(remaining, hasLength(1));
      expect(remaining.single.id, sampleWord.id);
    });
  });
}
