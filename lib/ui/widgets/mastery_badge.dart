import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../domain/entities/mastery.dart';

/// 習熟度に対応する色（[Docs/05_design_system.md] §1.3）。
///
/// 未学習と学習中はテーマ配色に追従し、定着とマスターは意味が固定なので
/// semantic 側の定数を使う。
Color masteryColor(Mastery mastery) => switch (mastery) {
  Mastery.unlearned => AppColors.line,
  Mastery.learning => AppColors.accent,
  Mastery.settled => AppColors.settled,
  Mastery.mastered => AppColors.mastered,
};

/// 習熟度のピル。**色だけに頼らず**必ずラベルを添える
/// （[Docs/05_design_system.md] §3.2）。
class MasteryBadge extends StatelessWidget {
  final Mastery mastery;

  const MasteryBadge({super.key, required this.mastery});

  @override
  Widget build(BuildContext context) {
    final color = masteryColor(mastery);
    final isUnlearned = mastery == Mastery.unlearned;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isUnlearned ? AppColors.chipBg : color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        mastery.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        // 未学習の色（line）は文字には薄すぎるため、文字色は ink2 にする。
        style: AppText.caption(color: isUnlearned ? AppColors.ink2 : color),
      ),
    );
  }
}

/// 習熟度の小さなドット（グリッドタイルの右下）。単独では意味が伝わらないため、
/// 必ず `Tooltip` でラベルを添える。
class MasteryDot extends StatelessWidget {
  final Mastery mastery;
  final double size;

  const MasteryDot({super.key, required this.mastery, this.size = 10});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: mastery.label,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: masteryColor(mastery),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
