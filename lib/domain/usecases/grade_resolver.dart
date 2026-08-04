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
  ///
  /// [meaningRevealed] はリスニングで「訳を見る」を押した回。音だけでは思い出せて
  /// いないため、grade の上限を 3 にする（[Docs/06_features/listening_mode.md] §2）。
  static int forSpell({
    required StudyMode mode,
    required SpellVerdict verdict,
    required int elapsedMs,
    required int hintUsed,
    required bool gaveUp,
    bool meaningRevealed = false,
  }) {
    if (gaveUp) return 0;
    final grade = switch (verdict) {
      SpellCorrect() when hintUsed > 0 => 3,
      SpellCorrect() => elapsedMs <= _fastThreshold(mode) ? 5 : 4,
      SpellNearMiss() => 2,
      SpellWrong() => 1,
    };
    return meaningRevealed && grade > 3 ? 3 : grade;
  }

  /// 4択（`choice` / `parts` / `confusion`）の grade。
  ///
  /// **4択で 5 を出さない。** 25% が当てずっぽうで当たるため、綴りモードと同じ強さで
  /// 間隔を伸ばすと、定着していない語がマスター判定に入り込む
  /// （[Docs/06_features/srs_scheduler.md] §2）。
  static int forChoice({required bool isCorrect}) => isCorrect ? 4 : 1;

  /// スピードモードの grade。
  ///
  /// **時間切れは学習状態を更新しない**（[noUpdate]）。「知らない」ではなく「遅い」ので、
  /// 間隔の判断材料にしない。誤答扱いにすると、知っている語の間隔が不当に縮み、
  /// 復習キューが「知っているが遅い語」で埋まってしまう
  /// （[Docs/06_features/speed_mode.md] §4）。
  static int forSpeed({required bool timedOut, required bool isCorrect}) {
    if (timedOut) return noUpdate;
    return isCorrect ? 4 : 1;
  }

  /// フラッシュカードの自己評価。押さなければ更新しない（FR-26）。
  static int forFlashcard({required bool? remembered}) => switch (remembered) {
    null => noUpdate,
    true => 4,
    false => 2,
  };

  static int _fastThreshold(StudyMode mode) => switch (mode) {
    StudyMode.listening => listeningFastMs,
    _ => spellFastMs,
  };
}
