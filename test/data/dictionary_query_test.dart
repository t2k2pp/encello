import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:encello/data/database/app_database.dart';
import 'package:encello/data/repositories/word_repository.dart';
import 'package:encello/data/repositories/wordbook_repository.dart';
import 'package:encello/domain/entities/mastery.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late WordRepository words;
  late WordbookRepository wordbooks;
  late Profile me;
  late Profile other;
  late int bookId;

  /// 共有の語を作り、テスト用単語帳へ所属させて id を返す。
  Future<int> addWord({
    required String headword,
    String partOfSpeech = 'noun',
    String meaning = 'いみ',
    String? exampleEn,
    String? exampleJa,
    bool inBook = true,
  }) async {
    final id = await db
        .into(db.words)
        .insert(
          WordsCompanion.insert(
            headword: headword,
            partOfSpeech: partOfSpeech,
            meaning: meaning,
          ),
        );
    // 例文は `word_examples` に持つ（[Docs/03_data_model.md] §2.4）。
    if (exampleEn != null) {
      await db
          .into(db.wordExamples)
          .insert(
            WordExamplesCompanion.insert(
              wordId: id,
              exampleEn: exampleEn,
              exampleJa: exampleJa ?? '',
            ),
          );
    }
    if (inBook) await wordbooks.addWord(bookId, id);
    return id;
  }

  Future<void> setReview(
    int wordId,
    Profile profile, {
    required Mastery mastery,
    DateTime? lastReviewedAt,
    int totalCorrect = 0,
    int totalIncorrect = 0,
  }) {
    return db
        .into(db.wordReviews)
        .insert(
          WordReviewsCompanion.insert(
            profileId: profile.id,
            wordId: wordId,
            dueAt: DateTime(2026, 8, 4, 4),
            masteryLevel: Value(mastery.level),
            lastReviewedAt: Value(lastReviewedAt),
            totalCorrect: Value(totalCorrect),
            totalIncorrect: Value(totalIncorrect),
          ),
        );
  }

  setUp(() async {
    db = newTestDatabase();
    words = WordRepository(db);
    wordbooks = WordbookRepository(db);
    me = await createTestProfile(db, name: 'わたし', colorSeed: 0);
    other = await createTestProfile(db, name: 'ほかのひと', colorSeed: 1);
    bookId = await wordbooks.create(name: 'テスト単語帳', emoji: '📗', colorSeed: 2);
  });

  DictionaryQuery queryOf({
    String search = '',
    bool searchExamples = false,
    WordbookFilter wordbook = WordbookFilter.all,
    MasteryFilter mastery = MasteryFilter.all,
    DictionarySort sort = DictionarySort.headword,
    bool ascending = true,
    List<int> selected = const [],
  }) {
    return DictionaryQuery(
      profileId: me.id,
      search: search,
      searchExamples: searchExamples,
      wordbook: wordbook,
      mastery: mastery,
      sort: sort,
      ascending: ascending,
      selectedWordbookIds: selected,
    );
  }

  Future<List<String>> headwordsOf(DictionaryQuery q) async {
    final entries = await words.watchDictionary(q).first;
    return entries.map((e) => e.word.headword).toList();
  }

  group('検索（英日を横断する）', () {
    setUp(() async {
      await addWord(headword: 'apple', meaning: 'りんご');
      await addWord(headword: 'pineapple', meaning: 'パイナップル');
      await addWord(
        headword: 'orange',
        meaning: 'オレンジ',
        exampleEn: 'I like apple pie.',
        exampleJa: 'りんごのパイが好きです。',
      );
    });

    test('英語でも日本語でも同じ欄で引ける', () async {
      expect(await headwordsOf(queryOf(search: 'apple')), [
        'apple',
        'pineapple',
      ]);
      expect(await headwordsOf(queryOf(search: 'りんご')), ['apple']);
    });

    test('前方一致の結果が中間一致より上に並ぶ', () async {
      // 中間一致だけの pineapple より、前方一致の apple が先。
      expect(await headwordsOf(queryOf(search: 'apple')), [
        'apple',
        'pineapple',
      ]);
    });

    test('例文検索が OFF のとき、例文だけに含まれる語はヒットしない', () async {
      expect(await headwordsOf(queryOf(search: 'pie')), isEmpty);
    });

    test('例文検索が ON なら例文からもヒットする', () async {
      expect(
        await headwordsOf(queryOf(search: 'pie', searchExamples: true)),
        ['orange'],
      );
    });

    test('大文字で入力しても引ける', () async {
      expect(await headwordsOf(queryOf(search: 'APPLE')), [
        'apple',
        'pineapple',
      ]);
    });

    test('LIKE のワイルドカードは文字として扱う', () async {
      // 「%」を打っても全件は返らない。
      expect(await headwordsOf(queryOf(search: '%')), isEmpty);
    });
  });

  group('可視範囲', () {
    test('他の学習者のマイ単語は出ない', () async {
      await addWord(headword: 'shared');
      final mine = await db
          .into(db.words)
          .insert(
            WordsCompanion.insert(
              headword: 'mine',
              partOfSpeech: 'noun',
              meaning: 'わたしの語',
              ownerProfileId: Value(me.id),
            ),
          );
      await wordbooks.addWord(bookId, mine);
      final theirs = await db
          .into(db.words)
          .insert(
            WordsCompanion.insert(
              headword: 'theirs',
              partOfSpeech: 'noun',
              meaning: 'ほかのひとの語',
              ownerProfileId: Value(other.id),
            ),
          );
      await wordbooks.addWord(bookId, theirs);

      expect(await headwordsOf(queryOf()), ['mine', 'shared']);
    });
  });

  group('フィルタ', () {
    late int appleId;

    setUp(() async {
      appleId = await addWord(headword: 'apple');
      await addWord(headword: 'banana');
      // 単語帳に属さない語。
      await addWord(headword: 'orphan', inBook: false);
    });

    test('単語帳で絞ると、その単語帳の語だけが出る', () async {
      expect(
        await headwordsOf(queryOf(wordbook: WordbookFilter.book(bookId))),
        ['apple', 'banana'],
      );
    });

    test('学習対象が1冊も無いときは0件（全件に化けない）', () async {
      expect(
        await headwordsOf(queryOf(wordbook: WordbookFilter.studyTarget)),
        isEmpty,
      );
    });

    test('学習対象のみで絞れる', () async {
      expect(
        await headwordsOf(
          queryOf(
            wordbook: WordbookFilter.studyTarget,
            selected: [bookId],
          ),
        ),
        ['apple', 'banana'],
      );
    });

    test('未学習フィルタは学習状態の行が無い語だけを出す', () async {
      await setReview(appleId, me, mastery: Mastery.learning);
      expect(
        await headwordsOf(queryOf(mastery: MasteryFilter.unlearned)),
        ['banana', 'orphan'],
      );
      expect(
        await headwordsOf(queryOf(mastery: MasteryFilter.learning)),
        ['apple'],
      );
    });

    test('習熟度は学習者ごとに違う', () async {
      await setReview(appleId, other, mastery: Mastery.mastered);
      // わたしから見れば apple は未学習のまま。
      expect(
        await headwordsOf(queryOf(mastery: MasteryFilter.mastered)),
        isEmpty,
      );
      final entries = await words.watchDictionary(queryOf()).first;
      expect(
        entries.firstWhere((e) => e.word.headword == 'apple').mastery,
        Mastery.unlearned,
      );
    });

    test('苦手は解答10回以上かつ正解率60%未満', () async {
      // 10回・正解5回（50%）→ 苦手
      await setReview(
        appleId,
        me,
        mastery: Mastery.learning,
        totalCorrect: 5,
        totalIncorrect: 5,
      );
      final banana =
          await (db.select(db.words)
                ..where((t) => t.headword.equals('banana')))
              .getSingle();
      // 10回・正解7回（70%）→ 苦手ではない
      await setReview(
        banana.id,
        me,
        mastery: Mastery.learning,
        totalCorrect: 7,
        totalIncorrect: 3,
      );
      expect(await headwordsOf(queryOf(mastery: MasteryFilter.weak)), [
        'apple',
      ]);
    });

    test('下書きのみで訳が未入力の語を絞れる', () async {
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
      await wordbooks.addWord(bookId, draft);
      expect(await headwordsOf(queryOf(mastery: MasteryFilter.draft)), [
        'draft',
      ]);
    });
  });

  group('並べ替え', () {
    test('見出し語の昇順・降順', () async {
      await addWord(headword: 'cherry');
      await addWord(headword: 'apple');
      await addWord(headword: 'banana');
      expect(await headwordsOf(queryOf()), ['apple', 'banana', 'cherry']);
      expect(await headwordsOf(queryOf(ascending: false)), [
        'cherry',
        'banana',
        'apple',
      ]);
    });

    test('最終学習日の昇順で未学習が末尾に来る', () async {
      final a = await addWord(headword: 'apple');
      final b = await addWord(headword: 'banana');
      await addWord(headword: 'cherry'); // 未学習
      await setReview(
        a,
        me,
        mastery: Mastery.learning,
        lastReviewedAt: DateTime(2026, 8, 2),
      );
      await setReview(
        b,
        me,
        mastery: Mastery.learning,
        lastReviewedAt: DateTime(2026, 8, 1),
      );

      expect(await headwordsOf(queryOf(sort: DictionarySort.lastReviewed)), [
        'banana',
        'apple',
        'cherry',
      ]);
      // 降順でも未学習は末尾のまま。
      expect(
        await headwordsOf(
          queryOf(sort: DictionarySort.lastReviewed, ascending: false),
        ),
        ['apple', 'banana', 'cherry'],
      );
    });

    test('習熟度の昇順は 未学習 → マスター', () async {
      final a = await addWord(headword: 'apple');
      final b = await addWord(headword: 'banana');
      await addWord(headword: 'cherry'); // 未学習
      await setReview(a, me, mastery: Mastery.mastered);
      await setReview(b, me, mastery: Mastery.learning);

      expect(await headwordsOf(queryOf(sort: DictionarySort.mastery)), [
        'cherry',
        'banana',
        'apple',
      ]);
    });
  });

  group('件数', () {
    test('総数と学習中の数を返す', () async {
      final a = await addWord(headword: 'apple');
      await addWord(headword: 'banana');
      await setReview(a, me, mastery: Mastery.settled);

      final counts = await words.watchCounts(queryOf()).first;
      expect(counts.total, 2);
      expect(counts.learning, 1);
    });
  });

  group('サムネの単語帳色', () {
    test('所属単語帳の色シードを返し、未所属では null になる', () async {
      await addWord(headword: 'apple');
      await addWord(headword: 'orphan', inBook: false);

      final entries = await words.watchDictionary(queryOf()).first;
      expect(
        entries.firstWhere((e) => e.word.headword == 'apple').wordbookColorSeed,
        2,
      );
      expect(
        entries.firstWhere((e) => e.word.headword == 'orphan').wordbookColorSeed,
        isNull,
      );
    });
  });
}
