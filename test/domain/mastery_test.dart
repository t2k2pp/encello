import 'package:encello/domain/entities/mastery.dart';
import 'package:encello/domain/entities/review_state.dart';
import 'package:flutter_test/flutter_test.dart';

ReviewState _state({required double intervalDays, required int correctStreak}) {
  return ReviewState.initial.copyWith(
    intervalDays: intervalDays,
    correctStreak: correctStreak,
  );
}

void main() {
  group('Mastery.from（境界値）', () {
    test('間隔 20.9 日は 学習中', () {
      expect(
        Mastery.from(_state(intervalDays: 20.9, correctStreak: 9)),
        Mastery.learning,
      );
    });

    test('間隔 21.0 日で 定着', () {
      expect(
        Mastery.from(_state(intervalDays: 21, correctStreak: 1)),
        Mastery.settled,
      );
    });

    test('間隔 89.9 日は 定着 のまま', () {
      expect(
        Mastery.from(_state(intervalDays: 89.9, correctStreak: 9)),
        Mastery.settled,
      );
    });

    test('間隔 90 日でも 連続正解 2 なら 定着', () {
      expect(
        Mastery.from(_state(intervalDays: 90, correctStreak: 2)),
        Mastery.settled,
      );
    });

    test('間隔 90 日かつ 連続正解 3 で マスター', () {
      expect(
        Mastery.from(_state(intervalDays: 90, correctStreak: 3)),
        Mastery.mastered,
      );
    });

    test('行があれば最低でも 学習中（未学習にはならない）', () {
      expect(Mastery.from(ReviewState.initial), Mastery.learning);
    });
  });

  group('Mastery.fromLevel', () {
    test('0〜3 が4段階に対応する', () {
      expect(Mastery.fromLevel(0), Mastery.unlearned);
      expect(Mastery.fromLevel(1), Mastery.learning);
      expect(Mastery.fromLevel(2), Mastery.settled);
      expect(Mastery.fromLevel(3), Mastery.mastered);
    });

    test('未知の値は黙って倒さず例外にする', () {
      expect(() => Mastery.fromLevel(4), throwsFormatException);
    });
  });
}
