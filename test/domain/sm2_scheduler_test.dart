import 'package:encello/domain/entities/review_state.dart';
import 'package:encello/domain/usecases/sm2_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 22:00 に解答した想定（学習日の起点は同日 04:00）。
  final answeredAt = DateTime(2026, 8, 3, 22);

  ReviewState apply(
    ReviewState state, {
    required int grade,
    bool? isCorrect,
    DateTime? at,
  }) {
    return Sm2Scheduler.apply(
      state,
      grade: grade,
      isCorrect: isCorrect ?? grade >= 3,
      answeredAt: at ?? answeredAt,
    );
  }

  group('容易度係数（EF）', () {
    const table = {5: 0.10, 4: 0.0, 3: -0.14, 2: -0.32, 1: -0.54, 0: -0.80};

    for (final entry in table.entries) {
      test('grade ${entry.key} で ${entry.value} 増減する', () {
        final next = apply(ReviewState.initial, grade: entry.key);
        expect(next.easeFactor, closeTo(2.5 + entry.value, 0.0001));
      });
    }

    test('下限 1.3 を下回らない', () {
      var state = ReviewState.initial;
      for (var i = 0; i < 10; i++) {
        state = apply(state, grade: 0);
      }
      expect(state.easeFactor, Sm2Scheduler.minEaseFactor);
    });

    test('grade が範囲外なら例外', () {
      expect(
        () => apply(ReviewState.initial, grade: 6),
        throwsArgumentError,
      );
    });
  });

  group('出題間隔', () {
    test('repetition 0→1→2 で 1日 → 6日 → 6×EF 日', () {
      final first = apply(ReviewState.initial, grade: 4);
      expect(first.repetition, 1);
      expect(first.intervalDays, 1.0);

      final second = apply(first, grade: 4);
      expect(second.repetition, 2);
      expect(second.intervalDays, 6.0);

      final third = apply(second, grade: 4);
      expect(third.repetition, 3);
      expect(third.intervalDays, (6.0 * second.easeFactor).roundToDouble());
    });

    test('grade < 3 で repetition が 0、間隔が 1日 に戻る', () {
      var state = apply(ReviewState.initial, grade: 4);
      state = apply(state, grade: 4);
      state = apply(state, grade: 4);
      expect(state.intervalDays, greaterThan(6));

      final lapsed = apply(state, grade: 1, isCorrect: false);
      expect(lapsed.repetition, 0);
      expect(lapsed.intervalDays, 1.0);
    });

    test('365日を超えない', () {
      var state = ReviewState.initial;
      for (var i = 0; i < 20; i++) {
        state = apply(state, grade: 5);
      }
      expect(state.intervalDays, lessThanOrEqualTo(365.0));
      expect(state.intervalDays, 365.0);
    });
  });

  group('次回出題日', () {
    test('22:00 に解いた語の interval 1日 は翌日 04:00 になる', () {
      final next = apply(ReviewState.initial, grade: 4);
      expect(next.dueAt, DateTime(2026, 8, 4, 4));
    });

    test('深夜2時の解答は前日を起点に数える', () {
      final next = apply(
        ReviewState.initial,
        grade: 4,
        at: DateTime(2026, 8, 4, 2),
      );
      // 学習日は 8/3 なので、その起点 8/3 04:00 + 1日。
      expect(next.dueAt, DateTime(2026, 8, 4, 4));
    });
  });

  group('付随する値', () {
    test('lapses は一度定着した語の誤答でだけ増える', () {
      final first = apply(ReviewState.initial, grade: 1, isCorrect: false);
      expect(first.lapses, 0);

      var state = apply(ReviewState.initial, grade: 4);
      expect(apply(state, grade: 1, isCorrect: false).lapses, 0);

      state = apply(state, grade: 4); // repetition 2
      expect(apply(state, grade: 1, isCorrect: false).lapses, 1);
    });

    test('correctStreak は grade>=3 で増え、それ以外で 0 に戻る', () {
      var state = apply(ReviewState.initial, grade: 4);
      state = apply(state, grade: 3);
      expect(state.correctStreak, 2);
      expect(apply(state, grade: 2, isCorrect: false).correctStreak, 0);
    });

    test('firstLearnedAt は最初に grade>=3 になったときだけ入る', () {
      final wrong = apply(ReviewState.initial, grade: 1, isCorrect: false);
      expect(wrong.firstLearnedAt, isNull);

      final learned = apply(wrong, grade: 4, at: DateTime(2026, 8, 5, 10));
      expect(learned.firstLearnedAt, DateTime(2026, 8, 5, 10));

      final later = apply(learned, grade: 4, at: DateTime(2026, 8, 9, 10));
      expect(later.firstLearnedAt, DateTime(2026, 8, 5, 10));
    });

    test('通算の正解・不正解は isCorrect で数える', () {
      // ヒントを使った正解（grade 3）は正解として数える。
      final hinted = apply(ReviewState.initial, grade: 3, isCorrect: true);
      expect(hinted.totalCorrect, 1);
      expect(hinted.totalIncorrect, 0);

      // 惜しい（grade 2）は不正解として数える。
      final near = apply(hinted, grade: 2, isCorrect: false);
      expect(near.totalCorrect, 1);
      expect(near.totalIncorrect, 1);
    });

    test('lastReviewedAt は毎回更新される', () {
      final next = apply(ReviewState.initial, grade: 4);
      expect(next.lastReviewedAt, answeredAt);
    });
  });
}
