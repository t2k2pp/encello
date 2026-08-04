import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

/// 語彙力測定の級帯ごとの到達率（[Docs/05_design_system.md] §3.2）。
///
/// ラベル＋10分割のバー＋パーセント＋概算語数。「推定 3,200語」より
/// 「準2級の語彙を41%知っています」の方が次の行動に繋がる
/// （[Docs/06_features/vocab_size_test.md] §3）。
class BandProgressBar extends StatelessWidget {
  /// 帯の名前（単語帳名）。
  final String label;

  /// 到達率（0.0〜1.0）。
  final double ratio;

  /// その帯で知っていると推定される語数。
  final int estimatedWords;

  /// 推奨する帯（次に取り組むとよい帯）を強調する。
  final bool highlighted;

  const BandProgressBar({
    super.key,
    required this.label,
    required this.ratio,
    required this.estimatedWords,
    this.highlighted = false,
  });

  /// バーの分割数。
  static const segments = 10;

  @override
  Widget build(BuildContext context) {
    final filled = (ratio * segments).round().clamp(0, segments);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: highlighted
                      ? AppText.body(color: AppColors.accentDeep)
                      : AppText.body(),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(ratio * 100).round()}%',
                maxLines: 1,
                style: AppText.body(),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 76,
                child: Text(
                  '約$estimatedWords語',
                  maxLines: 1,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              for (var i = 0; i < segments; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: i < filled
                            ? AppColors.accent
                            : AppColors.masteryTrack,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
