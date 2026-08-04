import 'package:meta/meta.dart';

import '../core/utils/study_date.dart';
import '../data/repositories/stats_repository.dart';

/// 1日ぶんの平均反応時間（統計カード5）。
@immutable
class ReactionPoint {
  final String studyDate;

  /// 平均反応時間（ミリ秒）。その日にスピードモードの**時間内正解**が無ければ null。
  /// null の日は点を打たず線を切る（[Docs/06_features/stats.md] §6）。
  final int? averageMs;

  /// 平均の母数になった解答数。
  final int sampleCount;

  const ReactionPoint({
    required this.studyDate,
    required this.averageMs,
    required this.sampleCount,
  });
}

/// 反応時間の集計（[Docs/06_features/stats.md] §6・§11）。純粋関数。
///
/// 平均は**時間内に正解した問題だけ**で取る。時間切れを混ぜると、制限時間を
/// 変えたときに平均が動いて回どうしを比べられなくなる
/// （時間切れは `isCorrect = false` で記録される）。
abstract final class ReactionTimeStats {
  static List<ReactionPoint> dailySeries(
    Iterable<SpeedAnswer> answers, {
    required String today,
    int days = 30,
  }) {
    final sums = <String, int>{};
    final counts = <String, int>{};
    for (final a in answers) {
      if (!a.isCorrect) continue;
      final date = studyDateOf(a.answeredAt);
      sums[date] = (sums[date] ?? 0) + a.elapsedMs;
      counts[date] = (counts[date] ?? 0) + 1;
    }

    final result = <ReactionPoint>[];
    for (var i = days - 1; i >= 0; i--) {
      final date = addStudyDays(today, -i);
      final count = counts[date] ?? 0;
      result.add(
        ReactionPoint(
          studyDate: date,
          averageMs: count == 0 ? null : (sums[date]! / count).round(),
          sampleCount: count,
        ),
      );
    }
    return result;
  }

  /// 全期間の平均（単語詳細の「平均反応時間」に使う）。時間内正解が無ければ null。
  static int? average(Iterable<SpeedAnswer> answers) {
    var sum = 0;
    var count = 0;
    for (final a in answers) {
      if (!a.isCorrect) continue;
      sum += a.elapsedMs;
      count++;
    }
    return count == 0 ? null : (sum / count).round();
  }
}
