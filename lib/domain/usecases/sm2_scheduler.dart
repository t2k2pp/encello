import 'dart:math' as math;

import '../../core/utils/study_date.dart';
import '../entities/review_state.dart';

/// SM-2 による次回出題日の算出（[Docs/06_features/srs_scheduler.md] §3・§4）。純粋関数。
abstract final class Sm2Scheduler {
  /// 容易度係数の下限。
  static const minEaseFactor = 1.3;

  /// 出題間隔の上限（日）。これ以上伸ばしても学習体験に差が出ず、
  /// 端末を替えたときに「一生出てこない語」が生まれる。
  static const maxIntervalDays = 365.0;

  /// grade がこの値以上なら「思い出せた」扱い（SM-2 原典の閾値）。
  static const recallThreshold = 3;

  /// [state] に grade を適用した新しい学習状態を返す。
  ///
  /// [isCorrect] は SM-2 の grade とは別に、利用者の解答が正解だったかを表す
  /// （「惜しい」は grade 2 かつ不正解、ヒントを使った正解は grade 3 かつ正解）。
  static ReviewState apply(
    ReviewState state, {
    required int grade,
    required bool isCorrect,
    required DateTime answeredAt,
  }) {
    if (grade < 0 || grade > 5) {
      throw ArgumentError.value(grade, 'grade', 'grade は 0〜5');
    }

    // EF は grade によらず毎回更新する（SM-2 原典どおり）。
    final q = 5 - grade;
    final ease = math.max(
      minEaseFactor,
      state.easeFactor + (0.1 - q * (0.08 + q * 0.02)),
    );

    final recalled = grade >= recallThreshold;
    final repetition = recalled ? state.repetition + 1 : 0;
    final interval = recalled
        ? math.min(maxIntervalDays, switch (state.repetition) {
            0 => 1.0,
            1 => 6.0,
            _ => (state.intervalDays * ease).roundToDouble(),
          })
        // 思い出せなかった語は翌日に必ずもう一度出す。
        : 1.0;

    // 解答した時刻ではなく**学習日の起点**に間隔を足す。22時に解いた語の
    // interval=1 を「翌日22時」にすると、翌朝の学習で出てこないため。
    final dueAt = studyDayStart(
      answeredAt,
    ).add(Duration(days: interval.round()));

    return state.copyWith(
      repetition: repetition,
      intervalDays: interval,
      easeFactor: ease,
      dueAt: dueAt,
      // 一度は定着していた語を落としたときだけ lapse を数える。
      lapses: !recalled && state.repetition >= 2
          ? state.lapses + 1
          : state.lapses,
      correctStreak: recalled ? state.correctStreak + 1 : 0,
      totalCorrect: isCorrect ? state.totalCorrect + 1 : state.totalCorrect,
      totalIncorrect: isCorrect
          ? state.totalIncorrect
          : state.totalIncorrect + 1,
      firstLearnedAt: state.firstLearnedAt ?? (recalled ? answeredAt : null),
      lastReviewedAt: answeredAt,
    );
  }
}
