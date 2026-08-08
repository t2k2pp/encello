import 'package:drift/drift.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show SqliteException;

import '../helpers/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = newTestDatabase();
  });

  Future<int> insertWord({
    required String headword,
    String partOfSpeech = 'noun',
    int? ownerProfileId,
  }) {
    return db
        .into(db.words)
        .insert(
          WordsCompanion.insert(
            headword: headword,
            partOfSpeech: partOfSpeech,
            meaning: 'いみ',
            ownerProfileId: Value(ownerProfileId),
          ),
        );
  }

  group('words の一意制約（[Docs/03_data_model.md] §2.3）', () {
    test('共有の語は 見出し語＋品詞 で全体に1つ', () async {
      await insertWord(headword: 'apple');
      await expectLater(
        insertWord(headword: 'apple'),
        throwsA(isA<SqliteException>()),
      );
    });

    test('同じ見出し語でも品詞が違えば共有の語として2つ持てる', () async {
      await insertWord(headword: 'run', partOfSpeech: 'noun');
      await insertWord(headword: 'run', partOfSpeech: 'verb');
      expect(await db.select(db.words).get(), hasLength(2));
    });

    test('マイ単語は学習者ごとに独立する（兄と弟が同じ語を登録できる）', () async {
      final a = await createTestProfile(db, name: 'あに');
      final b = await createTestProfile(db, name: 'おとうと');

      await insertWord(headword: 'apple', ownerProfileId: a.id);
      await insertWord(headword: 'apple', ownerProfileId: b.id);
      // 共有の語も別枠で持てる。
      await insertWord(headword: 'apple');

      expect(await db.select(db.words).get(), hasLength(3));
    });

    test('同じ学習者が同じ語を二重に登録することはできない', () async {
      final a = await createTestProfile(db, name: 'あに');
      await insertWord(headword: 'apple', ownerProfileId: a.id);
      await expectLater(
        insertWord(headword: 'apple', ownerProfileId: a.id),
        throwsA(isA<SqliteException>()),
      );
    });
  });

  group('cascade', () {
    test('単語を消すと所属・学習状態も消える', () async {
      final profile = await createTestProfile(db, name: 'A');
      final wordId = await insertWord(headword: 'apple');
      final bookId = (await db.select(db.wordbooks).getSingle()).id;

      await db
          .into(db.wordbookEntries)
          .insert(
            WordbookEntriesCompanion.insert(wordbookId: bookId, wordId: wordId),
          );
      await db
          .into(db.wordReviews)
          .insert(
            WordReviewsCompanion.insert(
              profileId: profile.id,
              wordId: wordId,
              dueAt: DateTime(2026, 8, 4, 4),
            ),
          );

      await (db.delete(db.words)..where((t) => t.id.equals(wordId))).go();

      expect(await db.select(db.wordbookEntries).get(), isEmpty);
      expect(await db.select(db.wordReviews).get(), isEmpty);
    });
  });
}
