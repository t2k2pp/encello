import 'package:encello/domain/usecases/vocab_size_estimator.dart';
import 'package:flutter_test/flutter_test.dart';

/// [Docs/06_features/vocab_size_test.md] §9 のテスト観点。
void main() {
  VocabBandAnswers band({
    required int id,
    required String name,
    required int bandSize,
    required int asked,
    required int known,
  }) => VocabBandAnswers(
    wordbookId: id,
    name: name,
    bandSize: bandSize,
    asked: asked,
    known: known,
  );

  group('補正式', () {
    test('f = 0 のとき corrected = h', () {
      expect(
        VocabSizeEstimator.correct(hitRate: 0.75, falseAlarmRate: 0),
        closeTo(0.75, 1e-9),
      );
    });

    test('f = 0.5、h = 0.75 のとき corrected = 0.5', () {
      expect(
        VocabSizeEstimator.correct(hitRate: 0.75, falseAlarmRate: 0.5),
        closeTo(0.5, 1e-9),
      );
    });

    test('f = 1（擬似語全部にわかると答えた）なら 0', () {
      expect(
        VocabSizeEstimator.correct(hitRate: 1, falseAlarmRate: 1),
        0,
      );
    });

    test('h < f でも負にならず 0 に丸められる', () {
      expect(
        VocabSizeEstimator.correct(hitRate: 0.2, falseAlarmRate: 0.5),
        0,
      );
    });
  });

  group('推定', () {
    test('擬似語全部にわかると答えたら、全帯が 0 になる', () {
      final estimate = VocabSizeEstimator.estimate(
        bands: [band(id: 1, name: '中学', bandSize: 1600, asked: 8, known: 8)],
        pseudoAsked: 10,
        pseudoKnown: 10,
      );
      expect(estimate.falseAlarmRate, 1);
      expect(estimate.bands.single.corrected, 0);
      expect(estimate.estimatedSize, 0);
    });

    test('推定語彙数が Σ(帯語数 × corrected) と一致する', () {
      final estimate = VocabSizeEstimator.estimate(
        bands: [
          band(id: 1, name: '中学', bandSize: 1600, asked: 8, known: 8),
          band(id: 2, name: '高校基礎', bandSize: 1200, asked: 8, known: 4),
          band(id: 3, name: '高校応用', bandSize: 1300, asked: 8, known: 2),
        ],
        pseudoAsked: 10,
        pseudoKnown: 0,
      );
      // f = 0 なので corrected = h。1600 + 600 + 325 = 2525。
      expect(estimate.estimatedSize, 1600 + 600 + 325);
      expect(
        estimate.estimatedSize,
        estimate.bands.fold(0, (s, b) => s + b.estimatedWords),
      );
    });

    test('1問も出せなかった帯は 0 にする（0問の割合を 1.0 にしない）', () {
      final estimate = VocabSizeEstimator.estimate(
        bands: [band(id: 1, name: '英検2級', bandSize: 1100, asked: 0, known: 0)],
        pseudoAsked: 10,
        pseudoKnown: 0,
      );
      expect(estimate.bands.single.corrected, 0);
      expect(estimate.estimatedSize, 0);
    });

    test('擬似語を1問も出していなければ補正しない', () {
      final estimate = VocabSizeEstimator.estimate(
        bands: [band(id: 1, name: '中学', bandSize: 100, asked: 4, known: 2)],
        pseudoAsked: 0,
        pseudoKnown: 0,
      );
      expect(estimate.falseAlarmRate, 0);
      expect(estimate.bands.single.corrected, closeTo(0.5, 1e-9));
    });
  });

  group('推奨単語帳', () {
    test('0.9 未満で最も易しい帯を推奨する', () {
      final estimate = VocabSizeEstimator.estimate(
        bands: [
          band(id: 1, name: '中学', bandSize: 1600, asked: 10, known: 10),
          band(id: 2, name: '高校基礎', bandSize: 1200, asked: 10, known: 5),
          band(id: 3, name: '高校応用', bandSize: 1300, asked: 10, known: 1),
        ],
        pseudoAsked: 10,
        pseudoKnown: 0,
      );
      expect(estimate.recommendedBand!.name, '高校基礎');
      expect(estimate.isAllBandsHigh, isFalse);
    });

    test('9割ちょうどの帯は推奨しない（0.9 未満が条件）', () {
      final estimate = VocabSizeEstimator.estimate(
        bands: [
          band(id: 1, name: '中学', bandSize: 1600, asked: 10, known: 9),
          band(id: 2, name: '高校基礎', bandSize: 1200, asked: 10, known: 8),
        ],
        pseudoAsked: 10,
        pseudoKnown: 0,
      );
      expect(estimate.recommendedBand!.name, '高校基礎');
    });

    test('全帯が 0.9 以上なら最上位を推奨する', () {
      final estimate = VocabSizeEstimator.estimate(
        bands: [
          band(id: 1, name: '中学', bandSize: 1600, asked: 10, known: 10),
          band(id: 2, name: '英検2級', bandSize: 1100, asked: 10, known: 10),
        ],
        pseudoAsked: 10,
        pseudoKnown: 0,
      );
      expect(estimate.recommendedBand!.name, '英検2級');
      expect(estimate.isAllBandsHigh, isTrue);
    });

    test('帯が1つも無ければ推奨しない', () {
      final estimate = VocabSizeEstimator.estimate(
        bands: const [],
        pseudoAsked: 10,
        pseudoKnown: 1,
      );
      expect(estimate.recommendedBand, isNull);
      expect(estimate.isAllBandsHigh, isFalse);
    });
  });

  group('前回差', () {
    test('推定値の10%未満の差は「ほぼ同じ」とみなす', () {
      expect(
        VocabSizeEstimator.isWithinNoise(current: 2000, previous: 1900),
        isTrue,
      );
    });

    test('10%以上の差は成長として扱う', () {
      expect(
        VocabSizeEstimator.isWithinNoise(current: 2000, previous: 1800),
        isFalse,
      );
    });

    test('減っている場合も絶対値で判定する', () {
      expect(
        VocabSizeEstimator.isWithinNoise(current: 2000, previous: 2100),
        isTrue,
      );
      expect(
        VocabSizeEstimator.isWithinNoise(current: 2000, previous: 2400),
        isFalse,
      );
    });
  });
}
