import '../../core/utils/enums.dart';
import '../entities/spell_verdict.dart';

/// 解答から SM-2 の grade（0〜5）を決める（[Docs/06_features/srs_scheduler.md] §2）。
///
/// モードごとに決め方が違うため、モード別の入口を分けて持つ。
/// 各モードの入口は、そのモードを実装するマイルストーンで足す。
abstract final class GradeResolver {
  /// 学習状態を更新しないことを表す grade（`learning_logs.grade` にもこの値を書く）。
  static const noUpdate = -1;

  /// 「速い」と見なす閾値（ミリ秒）。
  static const spellFastMs = 8000;
  static const listeningFastMs = 10000;

  /// スペル入力系（`spell` / `listening` / `family`）の grade。
  ///
  /// | 条件 | grade |
  /// |---|---|
  /// | 正解 かつ 速い | 5 |
  /// | 正解 | 4 |
  /// | 正解 だが ヒントを使った | 3 |
  /// | 惜しい（編集距離1） | 2 |
  /// | 不正解 | 1 |
  /// | 「わからない」を押した | 0 |
  static int forSpell({
    required StudyMode mode,
    required SpellVerdict verdict,
    required int elapsedMs,
    required int hintUsed,
    required bool gaveUp,
  }) {
    if (gaveUp) return 0;
    return switch (verdict) {
      SpellCorrect() when hintUsed > 0 => 3,
      SpellCorrect() => elapsedMs <= _fastThreshold(mode) ? 5 : 4,
      SpellNearMiss() => 2,
      SpellWrong() => 1,
    };
  }

  static int _fastThreshold(StudyMode mode) => switch (mode) {
    StudyMode.listening => listeningFastMs,
    _ => spellFastMs,
  };
}
