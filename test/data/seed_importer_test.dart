import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:encello/data/database/app_database.dart';
import 'package:encello/data/seeds/seed_importer.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_asset_bundle.dart';
import '../helpers/test_database.dart';

const _assetPath = 'assets/wordbooks/jhs_v1.json';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = newTestDatabase();
  });

  SeedImporter importerWith(String json) =>
      SeedImporter(db, FakeAssetBundle({_assetPath: json}));

  group('初回投入', () {
    test('単語帳・単語・所属が作られる', () async {
      final importer = importerWith(
        presetJson(
          words: [
            presetWordJson(headword: 'apple', meaning: 'りんご'),
            presetWordJson(
              headword: 'run',
              partOfSpeech: 'verb',
              meaning: '走る',
            ),
          ],
        ),
      );

      final result = await importer.importIfNeeded(installedVersion: 0);

      expect(result.applied, isTrue);
      expect(result.installedVersion, 1);
      expect(result.wordCount, 2);

      final book = await db.select(db.wordbooks).getSingle();
      expect(book.presetId, 'jhs_v1');
      expect(book.name, '中学英単語');
      expect(book.seedVersion, 1);
      expect(book.bandSize, 1600);
      // 投入しただけでは学習対象にしない（学習者ごとに選ばせる）。
      expect(book.ownerProfileId, isNull);

      final words = await db.select(db.words).get();
      expect(words.map((w) => w.headword), containsAll(['apple', 'run']));
      expect(words.every((w) => w.ownerProfileId == null), isTrue);
      expect(words.every((w) => w.presetId != null), isTrue);

      expect(await db.select(db.wordbookEntries).get(), hasLength(2));
    });

    test('見出し語は小文字で正規化される', () async {
      final importer = importerWith(
        presetJson(words: [presetWordJson(headword: 'Apple')]),
      );
      await importer.importIfNeeded(installedVersion: 0);
      expect((await db.select(db.words).getSingle()).headword, 'apple');
    });

    test('空の発音記号・例文は null で入る', () async {
      final importer = importerWith(
        presetJson(
          words: [presetWordJson(headword: 'apple', phonetic: '', exampleEn: '')],
        ),
      );
      await importer.importIfNeeded(installedVersion: 0);
      final word = await db.select(db.words).getSingle();
      expect(word.phonetic, isNull);
      expect(word.exampleEn, isNull);
    });
  });

  group('冪等・差分適用', () {
    test('同じ版なら何もしない', () async {
      final json = presetJson(words: [presetWordJson(headword: 'apple')]);
      await importerWith(json).importIfNeeded(installedVersion: 0);

      final result = await importerWith(json).importIfNeeded(installedVersion: 1);

      expect(result.applied, isFalse);
      expect(await db.select(db.words).get(), hasLength(1));
      expect(await db.select(db.wordbooks).get(), hasLength(1));
    });

    test('版を上げて同じ内容を入れ直しても行が増えない', () async {
      await importerWith(
        presetJson(words: [presetWordJson(headword: 'apple')]),
      ).importIfNeeded(installedVersion: 0);

      await importerWith(
        presetJson(
          seedVersion: 2,
          words: [presetWordJson(headword: 'apple', meaning: 'りんご（更新）')],
        ),
      ).importIfNeeded(installedVersion: 1);

      final words = await db.select(db.words).get();
      expect(words, hasLength(1));
      expect(words.single.meaning, 'りんご（更新）');
      expect(await db.select(db.wordbookEntries).get(), hasLength(1));
    });

    test('isEdited の語はプリセット再投入で上書きされない', () async {
      await importerWith(
        presetJson(words: [presetWordJson(headword: 'apple', meaning: 'りんご')]),
      ).importIfNeeded(installedVersion: 0);

      final id = (await db.select(db.words).getSingle()).id;
      await (db.update(db.words)..where((t) => t.id.equals(id))).write(
        const WordsCompanion(
          meaning: Value('わたしの訳'),
          isEdited: Value(true),
        ),
      );

      await importerWith(
        presetJson(
          seedVersion: 2,
          words: [presetWordJson(headword: 'apple', meaning: 'りんご（更新）')],
        ),
      ).importIfNeeded(installedVersion: 1);

      final word = await db.select(db.words).getSingle();
      expect(word.meaning, 'わたしの訳');
      expect(word.isEdited, isTrue);
    });

    test('アセットから消えた語は所属だけが外れ、学習状態は残る', () async {
      await importerWith(
        presetJson(
          words: [
            presetWordJson(headword: 'apple'),
            presetWordJson(headword: 'banana'),
          ],
        ),
      ).importIfNeeded(installedVersion: 0);

      final profile = await createTestProfile(db, name: 'A');
      final banana =
          await (db.select(db.words)
                ..where((t) => t.headword.equals('banana')))
              .getSingle();
      await db
          .into(db.wordReviews)
          .insert(
            WordReviewsCompanion.insert(
              profileId: profile.id,
              wordId: banana.id,
              dueAt: DateTime(2026, 8, 4, 4),
            ),
          );

      await importerWith(
        presetJson(seedVersion: 2, words: [presetWordJson(headword: 'apple')]),
      ).importIfNeeded(installedVersion: 1);

      // 語の行と学習状態は残る（学習履歴を消さない）。
      expect(await db.select(db.words).get(), hasLength(2));
      expect(await db.select(db.wordReviews).get(), hasLength(1));
      // 所属だけが外れる。
      final entries = await db.select(db.wordbookEntries).get();
      expect(entries, hasLength(1));
      expect(entries.single.wordId, isNot(banana.id));
    });
  });

  group('失敗時', () {
    test('壊れたアセットでは1件も入らない', () async {
      final importer = importerWith('{"presetId": "jhs_v1"}');
      await expectLater(
        importer.importIfNeeded(installedVersion: 0),
        throwsFormatException,
      );
      expect(await db.select(db.wordbooks).get(), isEmpty);
      expect(await db.select(db.words).get(), isEmpty);
    });

    test('level が範囲外の語があれば1件も入らない', () async {
      final importer = importerWith(
        presetJson(
          words: [
            presetWordJson(headword: 'apple'),
            presetWordJson(headword: 'banana', level: 9),
          ],
        ),
      );
      await expectLater(
        importer.importIfNeeded(installedVersion: 0),
        throwsFormatException,
      );
      expect(await db.select(db.words).get(), isEmpty);
    });
  });

  group('同梱アセット', () {
    test('assets/wordbooks/jhs_v1.json が読めて投入できる', () async {
      final importer = SeedImporter(db, rootBundle);
      final result = await importer.importIfNeeded(installedVersion: 0);

      expect(result.applied, isTrue);
      expect(result.wordbookCount, 1);
      expect(result.wordCount, greaterThan(100));

      final book = await db.select(db.wordbooks).getSingle();
      expect(book.presetId, 'jhs_v1');
      expect(book.category, 'juniorHigh');

      // 収録語は訳を必ず持ち、下書きではない。
      final words = await db.select(db.words).get();
      expect(words.every((w) => w.meaning.isNotEmpty), isTrue);
      expect(words.every((w) => !w.isDraft), isTrue);
    });

    test('presetId からアセットの語を引き直せる（元に戻す用）', () async {
      final importer = SeedImporter(db, rootBundle);
      final word = await importer.findPresetWord('jhs_v1:apple:noun');
      expect(word, isNotNull);
      expect(word!.headword, 'apple');
      expect(word.meaning, isNotEmpty);

      expect(await importer.findPresetWord('jhs_v1:nope:noun'), isNull);
    });
  });
}
