import 'dart:math';

import 'package:encello/core/utils/enums.dart';
import 'package:encello/domain/entities/mastery.dart';
import 'package:encello/domain/usecases/choice_distractors.dart';
import 'package:encello/domain/usecases/confusion_pair_finder.dart';
import 'package:encello/domain/usecases/family_quiz_builder.dart';
import 'package:encello/domain/usecases/grade_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChoiceDistractors', () {
    ChoiceCandidate word(
      int id,
      String headword,
      String meaning, {
      PartOfSpeech pos = PartOfSpeech.noun,
      Set<int> books = const {1},
    }) => ChoiceCandidate(
      wordId: id,
      headword: headword,
      meaning: meaning,
      partOfSpeech: pos,
      wordbookIds: books,
    );

    final apple = word(1, 'apple', 'りんご');

    test('誤答に正解そのものが混ざらない', () {
      final picked = ChoiceDistractors.pick(
        correct: apple,
        pool: [
          apple,
          word(2, 'banana', 'バナナ'),
          word(3, 'cherry', 'さくらんぼ'),
          word(4, 'grape', 'ぶどう'),
        ],
        direction: StudyDirection.enToJa,
        random: Random(1),
      );
      expect(picked, hasLength(3));
      expect(picked.any((c) => c.wordId == apple.wordId), isFalse);
    });

    test('訳が正解と同一の語は誤答に入らない', () {
      final picked = ChoiceDistractors.pick(
        correct: apple,
        pool: [
          word(2, 'ringo', 'りんご'),
          word(3, 'banana', 'バナナ'),
          word(4, 'cherry', 'さくらんぼ'),
          word(5, 'grape', 'ぶどう'),
        ],
        direction: StudyDirection.enToJa,
        random: Random(1),
      );
      expect(picked.any((c) => c.meaning == 'りんご'), isFalse);
    });

    test('同じ品詞の候補が3つ以上あれば誤答はすべて同じ品詞になる', () {
      final picked = ChoiceDistractors.pick(
        correct: apple,
        pool: [
          word(2, 'banana', 'バナナ'),
          word(3, 'cherry', 'さくらんぼ'),
          word(4, 'grape', 'ぶどう'),
          word(5, 'run', '走る', pos: PartOfSpeech.verb),
          word(6, 'walk', '歩く', pos: PartOfSpeech.verb),
        ],
        direction: StudyDirection.enToJa,
        random: Random(3),
      );
      expect(picked.every((c) => c.partOfSpeech == PartOfSpeech.noun), isTrue);
    });

    test('候補が足りなければ空を返す（ダミーで埋めない）', () {
      final picked = ChoiceDistractors.pick(
        correct: apple,
        pool: [apple, word(2, 'banana', 'バナナ')],
        direction: StudyDirection.enToJa,
        random: Random(1),
      );
      expect(picked, isEmpty);
    });

    test('日本語→英語では先頭文字が同じ語を入れようとする', () {
      final picked = ChoiceDistractors.pick(
        correct: apple,
        pool: [
          word(2, 'apply', '申し込む'),
          word(3, 'banana', 'バナナ'),
          word(4, 'cherry', 'さくらんぼ'),
          word(5, 'grape', 'ぶどう'),
        ],
        direction: StudyDirection.jaToEn,
        random: Random(1),
      );
      expect(picked.any((c) => c.headword.startsWith('a')), isTrue);
    });

    test('正解の位置は直前と同じにならない', () {
      final distractors = [
        word(2, 'banana', 'バナナ'),
        word(3, 'cherry', 'さくらんぼ'),
        word(4, 'grape', 'ぶどう'),
      ];
      for (var seed = 0; seed < 20; seed++) {
        final options = ChoiceDistractors.arrange(
          correct: apple,
          distractors: distractors,
          random: Random(seed),
          avoidIndex: 2,
        );
        expect(options, hasLength(4));
        expect(options.indexWhere((c) => c.wordId == apple.wordId), isNot(2));
      }
    });
  });

  group('GradeResolver（4択・スピード・フラッシュカード）', () {
    test('4択は正解でも 4 を超えない', () {
      expect(GradeResolver.forChoice(isCorrect: true), 4);
      expect(GradeResolver.forChoice(isCorrect: false), 1);
    });

    test('スピードの時間切れは学習状態を更新しない', () {
      expect(
        GradeResolver.forSpeed(timedOut: true, isCorrect: false),
        GradeResolver.noUpdate,
      );
      expect(GradeResolver.forSpeed(timedOut: false, isCorrect: true), 4);
      expect(GradeResolver.forSpeed(timedOut: false, isCorrect: false), 1);
    });

    // フラッシュカード専用の grade 解決は持たない。確認テストの grade は、その
    // 形式の入口（4択なら forChoice、スペルなら forSpell）をそのまま使う
    // （[Docs/06_features/flashcard_mode.md] §6）。流し見だけのカードは解答が
    // 無いので grade を決める場面が無い。進行そのものは
    // test/widget/flashcard_round_test.dart で検証する。
  });

  group('ConfusionPairFinder', () {
    final now = DateTime(2026, 8, 4);
    final words = [
      const ConfusionWord(wordId: 1, headword: 'affect', meaning: '〜に影響を与える'),
      const ConfusionWord(wordId: 2, headword: 'effect', meaning: '影響・効果'),
      const ConfusionWord(wordId: 3, headword: 'thought', meaning: '考え'),
      const ConfusionWord(wordId: 4, headword: 'though', meaning: '〜だけれども'),
    ];

    AnsweredLog log({
      int wordId = 1,
      StudyMode mode = StudyMode.choice,
      StudyDirection direction = StudyDirection.enToJa,
      String? answeredText = '影響・効果',
      DateTime? at,
    }) => AnsweredLog(
      wordId: wordId,
      mode: mode,
      direction: direction,
      isCorrect: false,
      answeredText: answeredText,
      answeredAt: at ?? now.subtract(const Duration(days: 1)),
    );

    test('4択の誤答2回で組が成立し、1回では成立しない', () {
      expect(
        ConfusionPairFinder.find(logs: [log()], words: words, now: now),
        isEmpty,
      );
      final pairs = ConfusionPairFinder.find(
        logs: [log(), log()],
        words: words,
        now: now,
      );
      expect(pairs, hasLength(1));
      expect(pairs.single.wordIdA, 1);
      expect(pairs.single.wordIdB, 2);
      expect(pairs.single.count, 2);
    });

    test('(A,B) と (B,A) は同じ組として合算する', () {
      final pairs = ConfusionPairFinder.find(
        logs: [
          log(),
          log(wordId: 2, answeredText: '〜に影響を与える'),
        ],
        words: words,
        now: now,
      );
      expect(pairs, hasLength(1));
      expect(pairs.single.count, 2);
    });

    test('綴りで別の実在語を打った誤答は組になる', () {
      final pairs = ConfusionPairFinder.find(
        logs: [
          log(wordId: 3, mode: StudyMode.spell, answeredText: 'though'),
          log(wordId: 3, mode: StudyMode.spell, answeredText: 'though'),
        ],
        words: words,
        now: now,
      );
      expect(pairs, hasLength(1));
      expect(pairs.single.wordIdA, 3);
      expect(pairs.single.wordIdB, 4);
    });

    test('実在しない綴りの誤答は組にしない（単なる打ち間違い）', () {
      final pairs = ConfusionPairFinder.find(
        logs: [
          log(wordId: 3, mode: StudyMode.spell, answeredText: 'thouht'),
          log(wordId: 3, mode: StudyMode.spell, answeredText: 'thouht'),
        ],
        words: words,
        now: now,
      );
      expect(pairs, isEmpty);
    });

    test('91日前の誤答は数えない', () {
      final old = now.subtract(const Duration(days: 91));
      final pairs = ConfusionPairFinder.find(
        logs: [
          log(at: old),
          log(at: old),
        ],
        words: words,
        now: now,
      );
      expect(pairs, isEmpty);
    });

    test('除外された語を含む組は作らない', () {
      final pairs = ConfusionPairFinder.find(
        logs: [log(), log()],
        words: [
          words.first,
          const ConfusionWord(
            wordId: 2,
            headword: 'effect',
            meaning: '影響・効果',
            isStudiable: false,
          ),
          ...words.skip(2),
        ],
        now: now,
      );
      expect(pairs, isEmpty);
    });

    test('解消済みの組は出さない', () {
      final pairs = ConfusionPairFinder.find(
        logs: [log(), log()],
        words: words,
        now: now,
        resolved: {ConfusionPairFinder.normalize(1, 2)},
      );
      expect(pairs, isEmpty);
    });

    test('正解のログは組にしない', () {
      final pairs = ConfusionPairFinder.find(
        logs: [
          AnsweredLog(
            wordId: 1,
            mode: StudyMode.choice,
            direction: StudyDirection.enToJa,
            isCorrect: true,
            answeredText: '影響・効果',
            answeredAt: now,
          ),
        ],
        words: words,
        now: now,
      );
      expect(pairs, isEmpty);
    });
  });

  group('FamilyQuizBuilder', () {
    FamilyMember member(
      int id,
      String headword,
      PartOfSpeech pos, {
      Mastery mastery = Mastery.learning,
      int familyId = 1,
    }) => FamilyMember(
      wordId: id,
      familyId: familyId,
      headword: headword,
      meaning: '$headword の訳',
      partOfSpeech: pos,
      mastery: mastery,
    );

    test('既習の語から、品詞が一意な語を答えさせる問題を作る', () {
      final questions = FamilyQuizBuilder.build([
        member(1, 'decide', PartOfSpeech.verb),
        member(2, 'decision', PartOfSpeech.noun, mastery: Mastery.unlearned),
      ]);
      expect(questions, hasLength(1));
      expect(questions.single.prompt.headword, 'decide');
      expect(questions.single.answer.headword, 'decision');
      expect(questions.single.targetPartOfSpeech, PartOfSpeech.noun);
    });

    test('求める品詞の語が2つある語族は出題しない', () {
      final questions = FamilyQuizBuilder.build([
        member(1, 'decide', PartOfSpeech.verb),
        member(2, 'decision', PartOfSpeech.noun),
        member(3, 'decisiveness', PartOfSpeech.noun),
      ]);
      // 名詞は答えにできない。動詞（1つだけ）は答えにできる。
      expect(
        questions.every((q) => q.answer.partOfSpeech == PartOfSpeech.verb),
        isTrue,
      );
    });

    test('提示語が未学習の語族は出題対象から外れる', () {
      final questions = FamilyQuizBuilder.build([
        member(1, 'decide', PartOfSpeech.verb, mastery: Mastery.unlearned),
        member(2, 'decision', PartOfSpeech.noun, mastery: Mastery.unlearned),
      ]);
      expect(questions, isEmpty);
    });

    test('語族に1語しかなければ出題しない', () {
      final questions = FamilyQuizBuilder.build([
        member(1, 'decide', PartOfSpeech.verb),
      ]);
      expect(questions, isEmpty);
    });

    test('提示語と答えが同じ品詞の組は作らない', () {
      final questions = FamilyQuizBuilder.build([
        member(1, 'decide', PartOfSpeech.verb),
        member(2, 'decision', PartOfSpeech.noun),
        member(3, 'decisive', PartOfSpeech.adjective),
      ]);
      expect(
        questions.every((q) => q.prompt.partOfSpeech != q.answer.partOfSpeech),
        isTrue,
      );
      expect(questions, isNotEmpty);
    });
  });
}
