import 'package:meta/meta.dart';

import '../../core/utils/study_date.dart';

/// 1日分の目標達成記録（`daily_stats` の `(studyDate, goalMet)`）。
@immutable
class DailyGoalMark {
  /// 学習日（`YYYY-MM-DD`。04:00 区切り）。
  final String studyDate;
  final bool goalMet;

  const DailyGoalMark({required this.studyDate, required this.goalMet});
}

/// ストリーク（連続達成日数）の計算結果。
@immutable
class StreakResult {
  /// 今日（未達なら昨日）から遡って `goalMet = true` が連続する日数。
  final int current;

  /// 全期間での最大連続日数。
  final int longest;

  const StreakResult({required this.current, required this.longest});

  static const zero = StreakResult(current: 0, longest: 0);
}

/// ストリークを `daily_stats` から計算する純粋関数（[Docs/06_features/gamification.md] §2）。
///
/// **今日がまだ未達でもストリークは切れていない**。昨日まで連続していればその値を出し、
/// 日付が変わって「昨日も未達」になった時点で 0 になる。
/// 救済（フリーズ・チケット）は用意しない。切れたら切れたと示す。
abstract final class StreakCalculator {
  /// [marks] は達成の有無を持つ日だけでよい（欠けている日は未達として扱う）。
  /// [today] は現在時刻が属する学習日（`studyDateOf(now)`）。
  static StreakResult calculate(
    Iterable<DailyGoalMark> marks, {
    required String today,
  }) {
    final metDates = <String>{
      for (final m in marks)
        if (m.goalMet) m.studyDate,
    };
    if (metDates.isEmpty) return StreakResult.zero;

    final sorted = metDates.toList()..sort();

    // 最長: 日付が1日ずつ繋がっている区間の最大長。
    var longest = 1;
    var run = 1;
    for (var i = 1; i < sorted.length; i++) {
      final isNextDay = studyDayDifference(sorted[i - 1], sorted[i]) == 1;
      run = isNextDay ? run + 1 : 1;
      if (run > longest) longest = run;
    }

    // 現在: 今日から遡る。今日が未達なら昨日を起点にする（まだ切れていない）。
    var cursor = metDates.contains(today) ? today : addStudyDays(today, -1);
    var current = 0;
    while (metDates.contains(cursor)) {
      current++;
      cursor = addStudyDays(cursor, -1);
    }

    return StreakResult(current: current, longest: longest);
  }
}
