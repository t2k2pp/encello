import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:encello/core/utils/enums.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:encello/data/repositories/wordbook_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late WordbookRepository repo;
  late Profile me;
  late Profile other;

  setUp(() async {
    db = newTestDatabase();
    repo = WordbookRepository(db);
    me = await createTestProfile(db, name: 'わたし', colorSeed: 0);
    other = await createTestProfile(db, name: 'ほかのひと', colorSeed: 1);
  });

  Future<Profile> reload(Profile p) async =>
      (db.select(db.profiles)..where((t) => t.id.equals(p.id))).getSingle();

  group('可視範囲', () {
    test('自分のマイ単語帳は出るが、他の学習者のマイ単語帳は出ない', () async {
      final visible = await repo.watchVisible(me.id).first;
      expect(visible, hasLength(1));
      expect(visible.single.wordbook.ownerProfileId, me.id);
      expect(visible.single.category, WordbookCategory.myWords);
    });

    test('ユーザー単語帳は全学習者に見える', () async {
      await repo.create(name: '共有の単語帳', emoji: '📗', colorSeed: 2);
      expect(await repo.watchVisible(me.id).first, hasLength(2));
      expect(await repo.watchVisible(other.id).first, hasLength(2));
    });

    test('収録語数が付いてくる', () async {
      final id = await repo.create(name: '単語帳', emoji: '📗', colorSeed: 2);
      final w1 = await createSharedWord(db, headword: 'apple');
      final w2 = await createSharedWord(db, headword: 'banana');
      await repo.addWord(id, w1);
      await repo.addWord(id, w2);

      final book = (await repo.watchVisible(me.id).first).firstWhere(
        (b) => b.wordbook.id == id,
      );
      expect(book.wordCount, 2);
    });
  });

  group('学習対象の選択', () {
    test('学習者ごとに別々に持つ', () async {
      final id = await repo.create(name: '単語帳', emoji: '📗', colorSeed: 2);
      await repo.setStudyTarget(me, id, selected: true);

      expect(decodeIdList((await reload(me)).selectedWordbookIds), [id]);
      expect(decodeIdList((await reload(other)).selectedWordbookIds), isEmpty);
    });

    test('外すと選択から消える', () async {
      final id = await repo.create(name: '単語帳', emoji: '📗', colorSeed: 2);
      await repo.setStudyTarget(me, id, selected: true);
      await repo.setStudyTarget(await reload(me), id, selected: false);
      expect(decodeIdList((await reload(me)).selectedWordbookIds), isEmpty);
    });

    test('学習対象にしている学習者の名前を数えられる', () async {
      final id = await repo.create(name: '単語帳', emoji: '📗', colorSeed: 2);
      await repo.setStudyTarget(me, id, selected: true);
      expect(await repo.profilesStudying(id), ['わたし']);
    });
  });

  group('削除', () {
    test('所属だけが外れ、単語と学習状態は残る', () async {
      final id = await repo.create(name: '単語帳', emoji: '📗', colorSeed: 2);
      final wordId = await createSharedWord(db, headword: 'apple');
      await repo.addWord(id, wordId);
      await db
          .into(db.wordReviews)
          .insert(
            WordReviewsCompanion.insert(
              profileId: me.id,
              wordId: wordId,
              dueAt: DateTime(2026, 8, 4, 4),
            ),
          );

      await repo.delete(id);

      expect(await db.select(db.wordbooks).get(), hasLength(2)); // マイ単語帳が2冊
      expect(await db.select(db.words).get(), hasLength(1));
      expect(await db.select(db.wordReviews).get(), hasLength(1));
      expect(await db.select(db.wordbookEntries).get(), isEmpty);
    });

    test('学習対象にしていた学習者の選択からも外れる', () async {
      final id = await repo.create(name: '単語帳', emoji: '📗', colorSeed: 2);
      await repo.setStudyTarget(me, id, selected: true);
      await repo.delete(id);
      expect(decodeIdList((await reload(me)).selectedWordbookIds), isEmpty);
    });

    test('マイ単語帳は削除できない', () async {
      final mine = (await repo.watchVisible(me.id).first).single.wordbook;
      await expectLater(repo.delete(mine.id), throwsStateError);
      expect(await db.select(db.wordbooks).get(), hasLength(2));
    });

    test('プリセット単語帳は削除できない', () async {
      final id = await db
          .into(db.wordbooks)
          .insert(
            WordbooksCompanion.insert(
              name: '中学英単語',
              emoji: '🏫',
              colorSeed: 1,
              category: WordbookCategory.juniorHigh.value,
              source: WordbookSource.preset.value,
              presetId: const Value('jhs_v1'),
            ),
          );
      await expectLater(repo.delete(id), throwsStateError);
    });
  });

  group('語の所属', () {
    test('同じ語を2回追加しても所属は1件のまま', () async {
      final id = await repo.create(name: '単語帳', emoji: '📗', colorSeed: 2);
      final wordId = await createSharedWord(db, headword: 'apple');
      await repo.addWord(id, wordId);
      await repo.addWord(id, wordId);
      expect(await db.select(db.wordbookEntries).get(), hasLength(1));
      expect(await db.select(db.words).get(), hasLength(1));
    });

    test('外しても単語そのものは残る', () async {
      final id = await repo.create(name: '単語帳', emoji: '📗', colorSeed: 2);
      final wordId = await createSharedWord(db, headword: 'apple');
      await repo.addWord(id, wordId);
      await repo.removeWord(id, wordId);
      expect(await db.select(db.wordbookEntries).get(), isEmpty);
      expect(await db.select(db.words).get(), hasLength(1));
    });

    test('同じ語が複数の単語帳に属せる', () async {
      final a = await repo.create(name: '単語帳A', emoji: '📗', colorSeed: 2);
      final b = await repo.create(name: '単語帳B', emoji: '📘', colorSeed: 3);
      final wordId = await createSharedWord(db, headword: 'apple');
      await repo.addWord(a, wordId);
      await repo.addWord(b, wordId);

      expect(await db.select(db.words).get(), hasLength(1));
      expect(await repo.watchWordbooksOf(wordId, me.id).first, hasLength(2));
    });
  });
}
