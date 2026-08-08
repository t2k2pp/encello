import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:encello/core/utils/enums.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:encello/data/repositories/word_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late WordRepository repo;
  late Profile me;

  setUp(() async {
    db = newTestDatabase();
    repo = WordRepository(db);
    me = await createTestProfile(db, name: 'わたし');
  });

  Future<Word> reload(int id) async => (await repo.findById(id))!;

  group('追加', () {
    test('見出し語は小文字で正規化される', () async {
      final id = await repo.createShared(
        headword: '  Apple ',
        partOfSpeech: PartOfSpeech.noun,
        meaning: 'りんご',
      );
      expect((await reload(id)).headword, 'apple');
    });

    test('空の発音記号は null で入り、空の例文は行を作らない', () async {
      final id = await repo.createShared(
        headword: 'apple',
        partOfSpeech: PartOfSpeech.noun,
        meaning: 'りんご',
        phonetic: '   ',
        exampleEn: '',
      );
      final word = await reload(id);
      expect(word.phonetic, isNull);
      expect(await repo.examplesOf(id), isEmpty);
    });

    test('書いた例文はユーザーの文（sourcePresetId = null）として入る', () async {
      final id = await repo.createShared(
        headword: 'apple',
        partOfSpeech: PartOfSpeech.noun,
        meaning: 'りんご',
        exampleEn: 'I ate an apple.',
        exampleJa: 'りんごを食べました。',
      );
      final example = (await repo.examplesOf(id)).single;
      expect(example.exampleEn, 'I ate an apple.');
      expect(example.exampleJa, 'りんごを食べました。');
      expect(example.sourcePresetId, isNull);
      expect(example.sortOrder, WordRepository.userExampleSortOrder);
    });

    test('和訳を書かなかったユーザーの文は空文字ではなく null で入る', () async {
      // 出会った文をその場で書き残すのが目的なので和訳は任意
      // （[Docs/03_data_model.md] §2.4、[Docs/06_features/my_words.md] §3.1）。
      final id = await repo.createShared(
        headword: 'apple',
        partOfSpeech: PartOfSpeech.noun,
        meaning: 'りんご',
        exampleEn: 'I ate an apple.',
        exampleJa: '   ',
      );
      expect((await repo.examplesOf(id)).single.exampleJa, isNull);

      // あとから書いた和訳を消したときも、空文字を残さない。
      await repo.setUserExample(
        id,
        exampleEn: 'I ate an apple.',
        exampleJa: 'りんごを食べました。',
      );
      expect((await repo.examplesOf(id)).single.exampleJa, 'りんごを食べました。');
      await repo.setUserExample(id, exampleEn: 'I ate an apple.');
      expect((await repo.examplesOf(id)).single.exampleJa, isNull);
    });
  });

  group('既存語の解決', () {
    test('共有の語を見つけられる', () async {
      await repo.createShared(
        headword: 'apple',
        partOfSpeech: PartOfSpeech.noun,
        meaning: 'りんご',
      );
      final found = await repo.findByHeadword(
        'Apple',
        PartOfSpeech.noun,
        profileId: me.id,
      );
      expect(found, isNotNull);
      expect(found!.headword, 'apple');
    });

    test('品詞が違えば別の語として扱う', () async {
      await repo.createShared(
        headword: 'run',
        partOfSpeech: PartOfSpeech.noun,
        meaning: '走ること',
      );
      expect(
        await repo.findByHeadword('run', PartOfSpeech.verb, profileId: me.id),
        isNull,
      );
    });

    test('他の学習者のマイ単語は見つからない', () async {
      final other = await createTestProfile(db, name: 'ほかのひと', colorSeed: 1);
      await db
          .into(db.words)
          .insert(
            WordsCompanion.insert(
              headword: 'theirs',
              partOfSpeech: 'noun',
              meaning: 'かれらの語',
              ownerProfileId: Value(other.id),
            ),
          );
      expect(
        await repo.findByHeadword(
          'theirs',
          PartOfSpeech.noun,
          profileId: me.id,
        ),
        isNull,
      );
    });
  });

  group('編集', () {
    test('プリセット語を編集すると編集済みになる', () async {
      final id = await db
          .into(db.words)
          .insert(
            WordsCompanion.insert(
              headword: 'apple',
              partOfSpeech: 'noun',
              meaning: 'りんご',
              presetId: const Value('jhs_v1:apple:noun'),
            ),
          );
      await repo.updateWord(
        await reload(id),
        headword: 'apple',
        partOfSpeech: PartOfSpeech.noun,
        meaning: 'わたしの訳',
        level: 1,
      );
      final word = await reload(id);
      expect(word.meaning, 'わたしの訳');
      expect(word.isEdited, isTrue);
    });

    test('ユーザーが作った語は編集済みにならない', () async {
      final id = await repo.createShared(
        headword: 'apple',
        partOfSpeech: PartOfSpeech.noun,
        meaning: 'りんご',
      );
      await repo.updateWord(
        await reload(id),
        headword: 'apple',
        partOfSpeech: PartOfSpeech.noun,
        meaning: 'りんご（訂正）',
        level: 1,
      );
      expect((await reload(id)).isEdited, isFalse);
    });

    test('見出し語と品詞が他の語と衝突する変更は保存されない', () async {
      await repo.createShared(
        headword: 'apple',
        partOfSpeech: PartOfSpeech.noun,
        meaning: 'りんご',
      );
      final bananaId = await repo.createShared(
        headword: 'banana',
        partOfSpeech: PartOfSpeech.noun,
        meaning: 'バナナ',
      );

      await expectLater(
        repo.updateWord(
          await reload(bananaId),
          headword: 'apple',
          partOfSpeech: PartOfSpeech.noun,
          meaning: 'バナナ',
          level: 1,
        ),
        throwsStateError,
      );
      expect((await reload(bananaId)).headword, 'banana');
    });

    test('自分自身への変更（品詞だけ変える等）は衝突扱いにしない', () async {
      final id = await repo.createShared(
        headword: 'run',
        partOfSpeech: PartOfSpeech.noun,
        meaning: '走ること',
      );
      await repo.updateWord(
        await reload(id),
        headword: 'run',
        partOfSpeech: PartOfSpeech.verb,
        meaning: '走る',
        level: 1,
      );
      expect((await reload(id)).partOfSpeech, 'verb');
    });

    test('プリセット語を編集前の内容へ戻せる', () async {
      final id = await db
          .into(db.words)
          .insert(
            WordsCompanion.insert(
              headword: 'apple',
              partOfSpeech: 'noun',
              meaning: 'わたしの訳',
              presetId: const Value('jhs_v1:apple:noun'),
              isEdited: const Value(true),
            ),
          );
      // 単語帳由来の例文は `word_examples` にあり、編集では壊れない。
      await db
          .into(db.wordExamples)
          .insert(
            WordExamplesCompanion.insert(
              wordId: id,
              exampleEn: 'I ate an apple.',
              exampleJa: const Value('りんごを食べました。'),
              sourcePresetId: const Value('jhs_v1'),
              sortOrder: const Value(10),
            ),
          );
      await repo.restorePreset(
        id,
        headword: 'apple',
        partOfSpeech: PartOfSpeech.noun,
        meaning: 'りんご',
        phonetic: '/ˈæpəl/',
        level: 1,
      );
      final word = await reload(id);
      expect(word.meaning, 'りんご');
      expect(word.phonetic, '/ˈæpəl/');
      expect(word.isEdited, isFalse);
      // 単語帳の例文は消さない。
      expect((await repo.examplesOf(id)).single.sourcePresetId, 'jhs_v1');
    });
  });

  group('除外', () {
    test('除外しても辞書には残り、学習状態も保持される', () async {
      final id = await repo.createShared(
        headword: 'apple',
        partOfSpeech: PartOfSpeech.noun,
        meaning: 'りんご',
      );
      await db
          .into(db.wordReviews)
          .insert(
            WordReviewsCompanion.insert(
              profileId: me.id,
              wordId: id,
              dueAt: DateTime(2026, 8, 4, 4),
            ),
          );

      await repo.setExcluded(id, excluded: true);

      expect((await reload(id)).isExcluded, isTrue);
      expect(await db.select(db.words).get(), hasLength(1));
      expect(await db.select(db.wordReviews).get(), hasLength(1));
    });
  });

  group('出題できる語の数', () {
    test('除外語と下書きは数えず、単語帳をまたぐ重複も1回だけ数える', () async {
      final books = await db.select(db.wordbooks).get();
      final myWordsBook = books.single.id;
      final second = await db
          .into(db.wordbooks)
          .insert(
            WordbooksCompanion.insert(
              name: '別の単語帳',
              emoji: '📘',
              colorSeed: 3,
              category: WordbookCategory.custom.value,
              source: WordbookSource.user.value,
            ),
          );

      final normal = await repo.createShared(
        headword: 'apple',
        partOfSpeech: PartOfSpeech.noun,
        meaning: 'りんご',
      );
      final excluded = await repo.createShared(
        headword: 'banana',
        partOfSpeech: PartOfSpeech.noun,
        meaning: 'バナナ',
      );
      await repo.setExcluded(excluded, excluded: true);
      final draft = await db
          .into(db.words)
          .insert(
            WordsCompanion.insert(
              headword: 'draft',
              partOfSpeech: 'noun',
              meaning: '',
              ownerProfileId: Value(me.id),
              isDraft: const Value(true),
            ),
          );

      for (final bookId in [myWordsBook, second]) {
        for (final wordId in [normal, excluded, draft]) {
          await db
              .into(db.wordbookEntries)
              .insert(
                WordbookEntriesCompanion.insert(
                  wordbookId: bookId,
                  wordId: wordId,
                ),
              );
        }
      }

      final profile = await (db.select(
        db.profiles,
      )..where((t) => t.id.equals(me.id))).getSingle();
      await (db.update(db.profiles)..where((t) => t.id.equals(me.id))).write(
        ProfilesCompanion(
          selectedWordbookIds: Value(
            encodeIdListForTest([myWordsBook, second]),
          ),
        ),
      );
      final updated = await (db.select(
        db.profiles,
      )..where((t) => t.id.equals(me.id))).getSingle();

      expect(await repo.countStudyable(profile), 0); // まだ1冊も選んでいない
      expect(await repo.countStudyable(updated), 1); // apple だけ
    });
  });
}

/// テストから `profiles.selectedWordbookIds` を組み立てる。
String encodeIdListForTest(List<int> ids) => '[${ids.join(',')}]';
