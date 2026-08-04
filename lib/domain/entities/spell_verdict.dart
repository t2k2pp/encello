import 'package:meta/meta.dart';

/// 綴りの判定結果（[Docs/06_features/spell_mode.md] §3）。
///
/// **[NearMiss] は不正解として扱う**（FR-19）。綴り学習アプリで綴り誤りを正解にすると
/// 目的が壊れる。「惜しい」は、打ち間違いなのか覚えていないのかを利用者が区別するための
/// 表示にとどめる。
@immutable
sealed class SpellVerdict {
  const SpellVerdict();

  /// 正解として数えるか。`NearMiss` は false。
  bool get isCorrect => this is SpellCorrect;
}

/// 正規化後に完全一致した。
@immutable
class SpellCorrect extends SpellVerdict {
  const SpellCorrect();

  @override
  bool operator ==(Object other) => other is SpellCorrect;

  @override
  int get hashCode => (SpellCorrect).hashCode;
}

/// 編集距離1（正解の長さが4以上）。惜しいが不正解。
@immutable
class SpellNearMiss extends SpellVerdict {
  /// 正解のどの位置が入力と食い違うか（差分の強調に使う）。
  final List<int> diffIndexes;

  const SpellNearMiss(this.diffIndexes);

  @override
  bool operator ==(Object other) =>
      other is SpellNearMiss &&
      other.diffIndexes.length == diffIndexes.length &&
      Object.hashAll(other.diffIndexes) == Object.hashAll(diffIndexes);

  @override
  int get hashCode => Object.hashAll(diffIndexes);

  @override
  String toString() => 'SpellNearMiss($diffIndexes)';
}

/// 不正解。
@immutable
class SpellWrong extends SpellVerdict {
  const SpellWrong();

  @override
  bool operator ==(Object other) => other is SpellWrong;

  @override
  int get hashCode => (SpellWrong).hashCode;
}
