import 'package:encello/domain/usecases/streak_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

List<DailyGoalMark> _marks(Map<String, bool> byDate) => [
  for (final e in byDate.entries)
    DailyGoalMark(studyDate: e.key, goalMet: e.value),
];

void main() {
  group('StreakCalculator', () {
    test('記録が無ければ 0', () {
      final r = StreakCalculator.calculate(const [], today: '2026-08-04');
      expect(r.current, 0);
      expect(r.longest, 0);
    });

    test('達成が1件も無ければ 0', () {
      final r = StreakCalculator.calculate(
        _marks({'2026-08-03': false, '2026-08-04': false}),
        today: '2026-08-04',
      );
      expect(r.current, 0);
    });

    test('今日まで3日連続なら 3', () {
      final r = StreakCalculator.calculate(
        _marks({
          '2026-08-02': true,
          '2026-08-03': true,
          '2026-08-04': true,
        }),
        today: '2026-08-04',
      );
      expect(r.current, 3);
      expect(r.longest, 3);
    });

    test('今日がまだ未達でも、昨日まで連続していれば切れていない', () {
      final r = StreakCalculator.calculate(
        _marks({
          '2026-08-02': true,
          '2026-08-03': true,
          '2026-08-04': false,
        }),
        today: '2026-08-04',
      );
      expect(r.current, 2);
    });

    test('昨日も未達なら 0 に戻る', () {
      final r = StreakCalculator.calculate(
        _marks({'2026-08-01': true, '2026-08-02': true}),
        today: '2026-08-04',
      );
      expect(r.current, 0);
      expect(r.longest, 2);
    });

    test('最長は全期間の最大連続日数を返す', () {
      final r = StreakCalculator.calculate(
        _marks({
          '2026-07-01': true,
          '2026-07-02': true,
          '2026-07-03': true,
          '2026-07-04': true,
          // 中断
          '2026-08-03': true,
          '2026-08-04': true,
        }),
        today: '2026-08-04',
      );
      expect(r.current, 2);
      expect(r.longest, 4);
    });

    test('月をまたぐ連続も途切れない', () {
      final r = StreakCalculator.calculate(
        _marks({
          '2026-07-30': true,
          '2026-07-31': true,
          '2026-08-01': true,
        }),
        today: '2026-08-01',
      );
      expect(r.current, 3);
      expect(r.longest, 3);
    });

    test('達成した日だけを数え、未達の日は連続を切る', () {
      final r = StreakCalculator.calculate(
        _marks({
          '2026-08-01': true,
          '2026-08-02': false,
          '2026-08-03': true,
          '2026-08-04': true,
        }),
        today: '2026-08-04',
      );
      expect(r.current, 2);
      expect(r.longest, 2);
    });
  });
}
