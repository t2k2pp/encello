import 'package:encello/core/utils/study_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('studyDateOf（学習日は 04:00 区切り）', () {
    test('04:00 ちょうどはその日', () {
      expect(studyDateOf(DateTime(2026, 8, 4, 4)), '2026-08-04');
    });

    test('03:59 は前日の続きとして数える', () {
      expect(studyDateOf(DateTime(2026, 8, 4, 3, 59)), '2026-08-03');
    });

    test('深夜0時は前日', () {
      expect(studyDateOf(DateTime(2026, 8, 4)), '2026-08-03');
    });

    test('23:59 はその日', () {
      expect(studyDateOf(DateTime(2026, 8, 4, 23, 59)), '2026-08-04');
    });

    test('月をまたぐ深夜も前日になる', () {
      expect(studyDateOf(DateTime(2026, 9, 1, 1)), '2026-08-31');
    });
  });

  group('studyDayStart', () {
    test('22:00 に解いた語の起点はその日の 04:00', () {
      expect(studyDayStart(DateTime(2026, 8, 3, 22)), DateTime(2026, 8, 3, 4));
    });

    test('深夜2時に解いた語の起点は前日の 04:00', () {
      expect(studyDayStart(DateTime(2026, 8, 4, 2)), DateTime(2026, 8, 3, 4));
    });

    test('22:00 の解答に interval 1 日を足すと翌日 04:00 になる', () {
      final due = studyDayStart(
        DateTime(2026, 8, 3, 22),
      ).add(const Duration(days: 1));
      expect(due, DateTime(2026, 8, 4, 4));
    });
  });

  test('studyDayStartOfDate は学習日の 04:00 を返す', () {
    expect(studyDayStartOfDate('2026-08-04'), DateTime(2026, 8, 4, 4));
  });
}
