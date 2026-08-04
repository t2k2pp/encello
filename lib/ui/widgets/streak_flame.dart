import 'package:flutter/material.dart';

import '../../core/theme/app_text.dart';

/// 🔥＋連続日数（[Docs/05_design_system.md] §3.2）。
///
/// **0日のときは炎を描かない**。灰色の炎で「失っている」ことを強調せず、
/// 「今日から始めましょう」と出す（[Docs/06_features/gamification.md] §2）。
class StreakFlame extends StatelessWidget {
  final int days;

  /// 0日のときに出す文言。
  final String zeroLabel;

  const StreakFlame({
    super.key,
    required this.days,
    this.zeroLabel = '今日から始めましょう',
  });

  @override
  Widget build(BuildContext context) {
    if (days <= 0) {
      return Text(
        zeroLabel,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppText.caption(),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '🔥',
          textScaler: TextScaler.noScaling,
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(width: 4),
        Text(
          '$days日',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.style(size: 16, weight: FontWeight.w800),
        ),
      ],
    );
  }
}
