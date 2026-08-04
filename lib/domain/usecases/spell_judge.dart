import 'dart:math' as math;

import '../entities/spell_verdict.dart';

/// 綴りの判定（[Docs/06_features/spell_mode.md] §3）。純粋関数。
abstract final class SpellJudge {
  /// 判定前に入力と正解へ同じ正規化をかける。
  ///
  /// 1. 前後の空白を除去 2. 小文字化 3. 連続する空白を1つにまとめる
  /// 4. Unicode のアポストロフィ（U+2019）を ASCII の `'` に統一
  ///
  /// アクセント記号（`café` の `é`）は**除去しない**。別の綴りとして扱う。
  static String normalize(String input) => input
      .replaceAll('’', "'")
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), ' ');

  /// 「惜しい」を成立させる正解の最小長。`cat` と `car` は別の語であり惜しくない。
  static const nearMissMinLength = 4;

  static SpellVerdict judge(String input, String answer) {
    final a = normalize(input);
    final b = normalize(answer);
    if (a == b) return const SpellCorrect();
    if (b.length >= nearMissMinLength && _levenshteinIsOne(a, b)) {
      return SpellNearMiss(_diffIndexes(a, b));
    }
    return const SpellWrong();
  }

  /// レーベンシュタイン距離がちょうど1か。
  ///
  /// 距離1の判定だけが要るので、全表を作らず長さ差で場合分けする。
  static bool _levenshteinIsOne(String a, String b) {
    final diff = a.length - b.length;
    if (diff.abs() > 1) return false;

    if (diff == 0) {
      // 置換1回でそろうか。
      var mismatches = 0;
      for (var i = 0; i < a.length; i++) {
        if (a[i] != b[i] && ++mismatches > 1) return false;
      }
      return mismatches == 1;
    }

    // 1文字の挿入/削除でそろうか（長い方から1文字落とす）。
    final longer = a.length > b.length ? a : b;
    final shorter = a.length > b.length ? b : a;
    var i = 0;
    var j = 0;
    var skipped = false;
    while (i < longer.length && j < shorter.length) {
      if (longer[i] == shorter[j]) {
        i++;
        j++;
        continue;
      }
      if (skipped) return false;
      skipped = true;
      i++;
    }
    return true;
  }

  /// **正解側**のどの位置が入力と食い違うかを返す（差分の強調に使う）。
  ///
  /// - 置換: 食い違った1文字の位置
  /// - 挿入（入力が1文字多い）: 食い違いが始まる正解の位置（余分な文字に押し出された
  ///   文字）。入力の末尾に余分がある場合は指す位置が無いため空を返す
  /// - 削除（入力が1文字足りない）: 抜けている正解の位置
  static List<int> _diffIndexes(String input, String answer) {
    if (input.length == answer.length) {
      for (var i = 0; i < answer.length; i++) {
        if (input[i] != answer[i]) return [i];
      }
      return const [];
    }

    // 先頭から一致している長さ＝食い違いが始まる位置。
    final common = math.min(input.length, answer.length);
    var i = 0;
    while (i < common && input[i] == answer[i]) {
      i++;
    }
    if (input.length < answer.length) {
      // 正解の i 文字目が抜けている。
      return [i];
    }
    // 入力に余分な文字がある。正解側では i の位置が対応する（末尾なら指せない）。
    return i < answer.length ? [i] : const [];
  }
}
