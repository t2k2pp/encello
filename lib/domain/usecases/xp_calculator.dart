import 'dart:math' as math;

import '../../core/utils/enums.dart';

/// XP の算出（[Docs/06_features/gamification.md] §3）。純粋関数。
///
/// モード係数はスペル系（綴りを産出するもの）を高くする。綴りを書けることが
/// このアプリの到達点なので、4択を回すだけでレベルが上がらないようにする。
abstract final class XpCalculator {
  /// 正解の基本点。
  static const baseCorrect = 10;

  /// 「惜しい」の点（不正解だが 0 にはしない）。
  static const nearMissXp = 3;

  /// 開示した1文字あたりの減点。
  static const hintPenalty = 3;

  /// セッション内の連続正解ボーナス（この問数ごとに加算）。
  static const streakBonusEvery = 5;
  static const streakBonusXp = 10;

  /// デイリー目標の達成ボーナス（その日1回だけ）。
  static const goalBonusXp = 50;

  /// スピードモードで全問を時間内に正解したときのボーナス（セッション終了時に1回）。
  static const speedPerfectXp = 50;

  static double modeFactor(StudyMode mode) => switch (mode) {
    StudyMode.spell || StudyMode.listening || StudyMode.family => 1.5,
    StudyMode.speed => 1.2,
    StudyMode.choice || StudyMode.parts || StudyMode.confusion => 1.0,
    StudyMode.flashcard => 0.8,
  };

  /// 1問ぶんの XP。
  ///
  /// [isNearMiss] は綴り系だけが立てる（不正解のうち「惜しい」だったもの）。
  /// [sessionCorrectStreak] はこの解答を含めたセッション内の連続正解数。
  static int forAnswer({
    required StudyMode mode,
    required bool isCorrect,
    bool isNearMiss = false,
    int hintUsed = 0,
    int sessionCorrectStreak = 0,
  }) {
    if (!isCorrect) return isNearMiss ? nearMissXp : 0;

    final base = (baseCorrect * modeFactor(mode)).round();
    final afterHint = math.max(0, base - hintUsed * hintPenalty);
    final bonus =
        sessionCorrectStreak > 0 && sessionCorrectStreak % streakBonusEvery == 0
        ? streakBonusXp
        : 0;
    return afterHint + bonus;
  }

  /// 累計 XP からレベルを出す。1→2 に 100XP、9→10 に 1,900XP。
  static int levelOf(int totalXp) =>
      math.sqrt(math.max(0, totalXp) / 100).floor() + 1;
}
