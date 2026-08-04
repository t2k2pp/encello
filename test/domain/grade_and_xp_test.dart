import 'package:encello/core/utils/enums.dart';
import 'package:encello/domain/entities/spell_verdict.dart';
import 'package:encello/domain/usecases/grade_resolver.dart';
import 'package:encello/domain/usecases/xp_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GradeResolver.forSpell', () {
    int gradeOf({
      SpellVerdict verdict = const SpellCorrect(),
      int elapsedMs = 3000,
      int hintUsed = 0,
      bool gaveUp = false,
      StudyMode mode = StudyMode.spell,
    }) {
      return GradeResolver.forSpell(
        mode: mode,
        verdict: verdict,
        elapsedMs: elapsedMs,
        hintUsed: hintUsed,
        gaveUp: gaveUp,
      );
    }

    test('速い正解は 5', () {
      expect(gradeOf(elapsedMs: 7999), 5);
    });

    test('遅い正解は 4', () {
      expect(gradeOf(elapsedMs: 8001), 4);
    });

    test('閾値ちょうどは速い扱い', () {
      expect(gradeOf(elapsedMs: 8000), 5);
    });

    test('リスニングの閾値は 10 秒', () {
      expect(gradeOf(mode: StudyMode.listening, elapsedMs: 9000), 5);
      expect(gradeOf(mode: StudyMode.listening, elapsedMs: 11000), 4);
    });

    test('ヒントを使った正解は速くても 3', () {
      expect(gradeOf(elapsedMs: 1000, hintUsed: 1), 3);
    });

    test('惜しいは 2', () {
      expect(gradeOf(verdict: const SpellNearMiss([1])), 2);
    });

    test('不正解は 1', () {
      expect(gradeOf(verdict: const SpellWrong()), 1);
    });

    test('「わからない」は判定より優先して 0', () {
      expect(gradeOf(gaveUp: true), 0);
      expect(gradeOf(verdict: const SpellWrong(), gaveUp: true), 0);
    });
  });

  group('XpCalculator', () {
    test('スペルの正解は基本点 10 × 係数 1.5 = 15', () {
      expect(
        XpCalculator.forAnswer(mode: StudyMode.spell, isCorrect: true),
        15,
      );
    });

    test('4択の正解は 10、フラッシュカードは 8', () {
      expect(
        XpCalculator.forAnswer(mode: StudyMode.choice, isCorrect: true),
        10,
      );
      expect(
        XpCalculator.forAnswer(mode: StudyMode.flashcard, isCorrect: true),
        8,
      );
    });

    test('ヒント1文字につき 3 減り、下限は 0', () {
      expect(
        XpCalculator.forAnswer(
          mode: StudyMode.spell,
          isCorrect: true,
          hintUsed: 2,
        ),
        9,
      );
      expect(
        XpCalculator.forAnswer(
          mode: StudyMode.spell,
          isCorrect: true,
          hintUsed: 99,
        ),
        0,
      );
    });

    test('惜しいは 3、ただの不正解は 0', () {
      expect(
        XpCalculator.forAnswer(
          mode: StudyMode.spell,
          isCorrect: false,
          isNearMiss: true,
        ),
        3,
      );
      expect(
        XpCalculator.forAnswer(mode: StudyMode.spell, isCorrect: false),
        0,
      );
    });

    test('5問連続正解ごとに +10', () {
      expect(
        XpCalculator.forAnswer(
          mode: StudyMode.spell,
          isCorrect: true,
          sessionCorrectStreak: 4,
        ),
        15,
      );
      expect(
        XpCalculator.forAnswer(
          mode: StudyMode.spell,
          isCorrect: true,
          sessionCorrectStreak: 5,
        ),
        25,
      );
      expect(
        XpCalculator.forAnswer(
          mode: StudyMode.spell,
          isCorrect: true,
          sessionCorrectStreak: 10,
        ),
        25,
      );
    });

    test('レベルは累計 XP から出す', () {
      expect(XpCalculator.levelOf(0), 1);
      expect(XpCalculator.levelOf(99), 1);
      expect(XpCalculator.levelOf(100), 2);
      expect(XpCalculator.levelOf(1900), 5);
      expect(XpCalculator.levelOf(8100), 10);
    });
  });
}
