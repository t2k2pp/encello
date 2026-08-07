import 'package:encello/core/utils/enums.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:encello/data/repositories/study_repository.dart';
import 'package:encello/data/repositories/word_repository.dart';
import 'package:encello/data/repositories/wordbook_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

/// マイ単語のテスト観点（[Docs/06_features/my_words.md] §8）。
void main() {
  late AppDatabase db;
  late WordRepository words;
  late WordbookRepository wordbooks;
  late Profile brother;
  late Profile sister;

  setUp(() async {
    db = newTestDatabase();
    words = WordRepository(db);
    wordbooks = WordbookRepository(db);
    brother = await createTestProfile(db, name: 'あに', colorSeed: 0);
    sister = await createTestProfile(db, name: 'いもうと', colorSeed: 1);
  });

  group('可視範囲', () {
    test('兄のマイ単語が弟の辞書一覧に出ない', () async {
      await words.createOwned(
        ownerProfileId: brother.id,
        headword: 'secret',
        partOfSpeech: PartOfSpeech.noun,
        meaning: 'ひみつ',
      );

      final entries = await words
          .watchDictionary(DictionaryQuery(profileId: sister.id))
          .first;
      expect(entries, isEmpty);

      final own = await words
          .watchDictionary(DictionaryQuery(profileId: brother.id))
          .first;
      expect(own, hasLength(1));
    });

    test('同じ (headword, partOfSpeech) を2人が登録すると2行になる', () async {
      await words.createOwned(
        ownerProfileId: brother.id,
        headword: 'apple',
        partOfSpeech: PartOfSpeech.noun,
        meaning: 'りんご（にい）',
      );
      await words.createOwned(
        ownerProfileId: sister.id,
        headword: 'apple',
        partOfSpeech: PartOfSpeech.noun,
        meaning: 'りんご（いもうと）',
      );

      final all = await db.select(db.words).get();
      expect(all.where((w) => w.headword == 'apple'), hasLength(2));
    });
  });

  group('下書き', () {
    test('isDraft = true かつ meaning が空で保存できる', () async {
      final id = await words.createOwned(
        ownerProfileId: brother.id,
        headword: 'mystery',
        partOfSpeech: PartOfSpeech.noun,
      );
      final word = (await words.findById(id))!;
      expect(word.isDraft, isTrue);
      expect(word.meaning, isEmpty);
    });

    test('訳を入れると isDraft が false になり、空にすると true に戻る', () async {
      final id = await words.createOwned(
        ownerProfileId: brother.id,
        headword: 'mystery',
        partOfSpeech: PartOfSpeech.noun,
      );
      var word = (await words.findById(id))!;
      expect(word.isDraft, isTrue);

      await words.updateWord(
        word,
        headword: 'mystery',
        partOfSpeech: PartOfSpeech.noun,
        meaning: 'なぞ',
        level: 1,
      );
      word = (await words.findById(id))!;
      expect(word.isDraft, isFalse);

      await words.updateWord(
        word,
        headword: 'mystery',
        partOfSpeech: PartOfSpeech.noun,
        meaning: '',
        level: 1,
      );
      word = (await words.findById(id))!;
      expect(word.isDraft, isTrue);
    });

    // クイック登録は和訳を聞かない（[Docs/06_features/my_words.md] §4.1）。
    test('「出会った文」は和訳が無くても自分の文として残り、訳を書いても消えない', () async {
      final id = await words.createOwned(
        ownerProfileId: brother.id,
        headword: 'mystery',
        partOfSpeech: PartOfSpeech.noun,
        exampleEn: 'It was a mystery to me.',
      );

      final drafts = await words.draftWords(brother.id);
      final draft = drafts.single;
      expect(draft.example, isNotNull);
      expect(draft.example!.exampleEn, 'It was a mystery to me.');
      expect(draft.example!.sourcePresetId, isNull);

      // 「訳を書く」は訳だけを書き換え、書き残した文はそのまま渡す。
      await words.updateWord(
        draft.word,
        headword: 'mystery',
        partOfSpeech: PartOfSpeech.noun,
        meaning: 'なぞ',
        exampleEn: draft.example!.exampleEn,
        exampleJa: draft.example!.exampleJa,
        level: 1,
      );

      final example = (await words.examplesOf(id)).single;
      expect(example.exampleEn, 'It was a mystery to me.');
      expect((await words.findById(id))!.isDraft, isFalse);
    });

    test('共有の語は訳が空でも下書きにしない（下書きはマイ単語だけの状態）', () async {
      final id = await createSharedWord(db, headword: 'shared', meaning: 'いみ');
      final word = (await words.findById(id))!;

      await words.updateWord(
        word,
        headword: 'shared',
        partOfSpeech: PartOfSpeech.noun,
        meaning: '',
        level: 1,
      );

      expect((await words.findById(id))!.isDraft, isFalse);
    });

    test('下書きの語がキュー生成に含まれない', () async {
      final bookId = await wordbooks.create(
        name: 'テスト単語帳',
        emoji: '📗',
        colorSeed: 2,
      );
      final draftId = await words.createOwned(
        ownerProfileId: brother.id,
        headword: 'draftword',
        partOfSpeech: PartOfSpeech.noun,
      );
      await wordbooks.addWord(bookId, draftId);
      final readyId = await words.createOwned(
        ownerProfileId: brother.id,
        headword: 'readyword',
        partOfSpeech: PartOfSpeech.noun,
        meaning: 'できた語',
      );
      await wordbooks.addWord(bookId, readyId);
      await wordbooks.setStudyTarget(brother, bookId, selected: true);
      final updated =
          await (db.select(db.profiles)..where((t) => t.id.equals(brother.id)))
              .getSingle();

      final study = StudyRepository(db);
      final candidates = await study.loadCandidates(updated);
      expect(candidates.map((c) => c.wordId), [readyId]);
    });

    test('watchDraftCount が自分の下書きだけを数える', () async {
      await words.createOwned(
        ownerProfileId: brother.id,
        headword: 'one',
        partOfSpeech: PartOfSpeech.noun,
      );
      await words.createOwned(
        ownerProfileId: brother.id,
        headword: 'two',
        partOfSpeech: PartOfSpeech.noun,
      );
      // 訳ありなので下書きではない。
      await words.createOwned(
        ownerProfileId: brother.id,
        headword: 'three',
        partOfSpeech: PartOfSpeech.noun,
        meaning: 'さん',
      );
      // 別の学習者の下書き。数えない。
      await words.createOwned(
        ownerProfileId: sister.id,
        headword: 'four',
        partOfSpeech: PartOfSpeech.noun,
      );

      expect(await words.watchDraftCount(brother.id).first, 2);
      expect(await words.watchDraftCount(sister.id).first, 1);
    });
  });

  group('保存先', () {
    test('マイ単語帳（自分のもの）へ自動で所属する', () async {
      final myBook = await wordbooks.myWordsBookOf(brother.id);
      final id = await words.createOwned(
        ownerProfileId: brother.id,
        headword: 'stored',
        partOfSpeech: PartOfSpeech.noun,
        meaning: 'しまわれた',
      );
      final entries = await (db.select(db.wordbookEntries)
            ..where((t) => t.wordbookId.equals(myBook.id)))
          .get();
      expect(entries.map((e) => e.wordId), contains(id));
    });

    test('(headword, partOfSpeech, ownerProfileId) が衝突すると例外になる', () async {
      await words.createOwned(
        ownerProfileId: brother.id,
        headword: 'dup',
        partOfSpeech: PartOfSpeech.noun,
        meaning: 'かさなる',
      );
      await expectLater(
        words.createOwned(
          ownerProfileId: brother.id,
          headword: 'dup',
          partOfSpeech: PartOfSpeech.noun,
          meaning: '別の訳',
        ),
        throwsA(anything),
      );
    });
  });
}
