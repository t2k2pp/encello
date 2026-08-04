import 'package:meta/meta.dart';

import '../core/utils/study_date.dart';
import '../data/database/app_database.dart';

/// 1日ぶんの学習量（統計カード3・4、ホームの直近の成績）。
@immutable
class DailyPoint {
  /// 学習日（`YYYY-MM-DD`）。
  final String studyDate;
  final int answeredCount;
  final int correctCount;

  /// その日に適用されていた目標。記録が無い日は現在の設定値を入れる。
  final int goalCount;
  final bool goalMet;

  const DailyPoint({
    required this.studyDate,
    required this.answeredCount,
    required this.correctCount,
    required this.goalCount,
    required this.goalMet,
  });

  /// 正解率（0.0〜1.0）。**解答が 0 の日は null**。
  /// 0% として繋ぐと「その日は全部間違えた」に見えるため、線を切る
  /// （[Docs/06_features/stats.md] §5）。
  double? get accuracy =>
      answeredCount == 0 ? null : correctCount / answeredCount;
}

/// 統計の集計（[Docs/06_features/stats.md] §11）。
///
/// SQL で完結しない「組み合わせの計算」をここに純粋関数として置く。
/// ウィジェットの `build` の中で計算しない。
abstract final class StatsAggregates {
  /// 直近 [days] 日ぶんの系列を作る。
  ///
  /// **学習していない日もバー0で描く**（日付を詰めない）。空白があること自体が
  /// 情報になるため（[Docs/06_features/stats.md] §4）。
  static List<DailyPoint> dailySeries(
    Iterable<DailyStat> stats, {
    required String today,
    required int currentGoal,
    int days = 30,
  }) {
    final byDate = {for (final s in stats) s.studyDate: s};
    final result = <DailyPoint>[];
    for (var i = days - 1; i >= 0; i--) {
      final date = addStudyDays(today, -i);
      final stat = byDate[date];
      result.add(
        DailyPoint(
          studyDate: date,
          answeredCount: stat?.answeredCount ?? 0,
          correctCount: stat?.correctCount ?? 0,
          goalCount: stat?.goalCount ?? currentGoal,
          goalMet: stat?.goalMet ?? false,
        ),
      );
    }
    return result;
  }

  /// 直近 [days] 日の正解率（解答が1問も無ければ null）。
  /// ホームの「直近の成績」カードに出す。
  static double? recentAccuracy(
    Iterable<DailyStat> stats, {
    required String today,
    int days = 7,
  }) {
    final from = addStudyDays(today, -(days - 1));
    var answered = 0;
    var correct = 0;
    for (final s in stats) {
      if (s.studyDate.compareTo(from) < 0) continue;
      answered += s.answeredCount;
      correct += s.correctCount;
    }
    return answered == 0 ? null : correct / answered;
  }

  /// 直近 [days] 日の解答数の合計。
  static int recentAnswered(
    Iterable<DailyStat> stats, {
    required String today,
    int days = 7,
  }) {
    final from = addStudyDays(today, -(days - 1));
    var answered = 0;
    for (final s in stats) {
      if (s.studyDate.compareTo(from) < 0) continue;
      answered += s.answeredCount;
    }
    return answered;
  }
}
