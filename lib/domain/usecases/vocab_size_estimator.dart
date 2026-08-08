import 'package:meta/meta.dart';

/// 語彙力測定の帯（級帯）1つ分の解答集計（[Docs/06_features/vocab_size_test.md] §3）。
///
/// 帯は一般的な頻度帯（1000語ごと）ではなく、このアプリが持っている**級帯**
/// （`wordbooks.bandSize` を持つ単語帳）で取る。結果がそのまま行動に繋がるため。
@immutable
class VocabBandAnswers {
  /// 帯にした単語帳の id。
  final int wordbookId;

  /// 表示名（「中学英単語」など）。
  final String name;

  /// この帯の語数（目安）。`wordbooks.bandSize`。
  final int bandSize;

  /// 出題した実在語の数。
  final int asked;

  /// 「わかる」と答えた数。
  final int known;

  const VocabBandAnswers({
    required this.wordbookId,
    required this.name,
    required this.bandSize,
    required this.asked,
    required this.known,
  });
}

/// 補正後の帯ごとの結果。
@immutable
class VocabBandResult {
  final int wordbookId;
  final String name;
  final int bandSize;
  final int asked;
  final int known;

  /// 擬似語の当てずっぽう率で補正した到達率（0.0〜1.0）。
  final double corrected;

  const VocabBandResult({
    required this.wordbookId,
    required this.name,
    required this.bandSize,
    required this.asked,
    required this.known,
    required this.corrected,
  });

  /// この帯で知っていると推定される語数。
  int get estimatedWords => (bandSize * corrected).round();

  /// 到達までに残っている語数（帯の語数 − 推定語数）。
  int get remainingWords => bandSize - estimatedWords;

  Map<String, dynamic> toJson() => {
    'wordbookId': wordbookId,
    'name': name,
    'bandSize': bandSize,
    'asked': asked,
    'known': known,
    'corrected': corrected,
  };

  factory VocabBandResult.fromJson(Map<String, dynamic> json) =>
      VocabBandResult(
        wordbookId: json['wordbookId'] as int,
        name: json['name'] as String,
        bandSize: json['bandSize'] as int,
        asked: json['asked'] as int,
        known: json['known'] as int,
        corrected: (json['corrected'] as num).toDouble(),
      );
}

/// 測定1回分の推定結果。
@immutable
class VocabSizeEstimate {
  /// 易しい帯から順に並んだ結果。
  final List<VocabBandResult> bands;

  /// 擬似語に「わかる」と答えた率（テスト全体で1つ）。
  final double falseAlarmRate;

  /// 出題した擬似語の数と、そのうち「わかる」と答えた数。
  final int pseudoAsked;
  final int pseudoKnown;

  const VocabSizeEstimate({
    required this.bands,
    required this.falseAlarmRate,
    required this.pseudoAsked,
    required this.pseudoKnown,
  });

  /// 推定語彙数 = Σ（帯の語数 × その帯の補正済み到達率）。
  ///
  /// 帯ごとの表示値（[VocabBandResult.estimatedWords]）の合計と一致させるため、
  /// 丸めは帯ごとに行う。
  int get estimatedSize => bands.fold(0, (sum, b) => sum + b.estimatedWords);

  /// 次に取り組むとよい帯（[Docs/06_features/vocab_size_test.md] §5.1）。
  ///
  /// 補正済み到達率が **0.9 未満で最も易しい帯**。「9割方知っている帯」は取り組む
  /// 価値が薄く、難しい帯へ飛ばすと未知語だらけで続かない。
  /// 該当が無い（全帯が 0.9 以上）ときは最上位の帯を返す。
  VocabBandResult? get recommendedBand {
    if (bands.isEmpty) return null;
    for (final b in bands) {
      if (b.corrected < VocabSizeEstimator.recommendThreshold) return b;
    }
    return bands.last;
  }

  /// 全帯が 0.9 以上（推奨する帯が「これ以上易しいものが無い」状態）か。
  /// 結果画面で「かなり仕上がっています」を添えるかの判定に使う。
  bool get isAllBandsHigh =>
      bands.isNotEmpty &&
      bands.every((b) => b.corrected >= VocabSizeEstimator.recommendThreshold);
}

/// Yes/No 方式＋擬似語による当てずっぽう補正（[Docs/06_features/vocab_size_test.md] §2.1）。
///
/// 純粋関数。DB もアセットも触らない。
abstract final class VocabSizeEstimator {
  /// 推奨単語帳を決める到達率のしきい値。
  static const recommendThreshold = 0.9;

  /// 推定値に対する誤差の目安（前回差をこの割合未満なら「ほぼ同じ」とする）。
  static const noiseRatio = 0.1;

  /// 帯ごとの到達率を、擬似語の誤警報率で補正する。
  ///
  /// ```
  /// h = その帯の実在語で「わかる」と答えた率
  /// f = 擬似語で「わかる」と答えた率
  /// corrected = f < 1 ? clamp((h - f) / (1 - f), 0, 1) : 0
  /// ```
  ///
  /// `f` が高い（擬似語にも「わかる」と答えた）人ほど、実在語の正答も割り引かれる。
  static double correct({
    required double hitRate,
    required double falseAlarmRate,
  }) {
    if (falseAlarmRate >= 1) return 0;
    final value = (hitRate - falseAlarmRate) / (1 - falseAlarmRate);
    return value.clamp(0.0, 1.0);
  }

  /// 測定の解答から推定結果を作る。
  ///
  /// [bands] は易しい順に並べて渡す（推奨単語帳の決定に順序を使う）。
  /// 擬似語を1問も出していない場合、補正は行われない（`f = 0`）。
  static VocabSizeEstimate estimate({
    required List<VocabBandAnswers> bands,
    required int pseudoAsked,
    required int pseudoKnown,
  }) {
    final f = pseudoAsked == 0 ? 0.0 : pseudoKnown / pseudoAsked;
    return VocabSizeEstimate(
      bands: [
        for (final b in bands)
          VocabBandResult(
            wordbookId: b.wordbookId,
            name: b.name,
            bandSize: b.bandSize,
            asked: b.asked,
            known: b.known,
            // 1問も出せなかった帯は推定しない（0問の割合を1.0にしない）。
            corrected: b.asked == 0
                ? 0
                : correct(hitRate: b.known / b.asked, falseAlarmRate: f),
          ),
      ],
      falseAlarmRate: f,
      pseudoAsked: pseudoAsked,
      pseudoKnown: pseudoKnown,
    );
  }

  /// 前回差が推定誤差の範囲に収まっているか（[Docs/06_features/vocab_size_test.md] §8）。
  ///
  /// true のときは「+320語」ではなく「前回とほぼ同じです」と出す。
  /// 誤差を成長として見せない。
  static bool isWithinNoise({required int current, required int previous}) =>
      (current - previous).abs() < current * noiseRatio;
}
