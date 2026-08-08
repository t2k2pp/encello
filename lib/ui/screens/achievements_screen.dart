import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/achievement_evaluator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../data/database/app_database.dart';
import '../../providers/stats.dart';
import '../widgets/centered_content.dart';
import '../widgets/empty_state.dart';
import '../widgets/soft_card.dart';

/// SCR-14 実績（[Docs/06_features/gamification.md] §4）。
///
/// 未解除の実績も条件と進捗（`7 / 30日`）を見せる。隠さない。
class AchievementsScreen extends ConsumerWidget {
  final Profile profile;

  const AchievementsScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = AppSpacing.of(context);
    final async = ref.watch(achievementProgressProvider(profile.id));

    return Scaffold(
      appBar: AppBar(title: const Text('実績')),
      body: CenteredContent(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => EmptyState(
            emoji: '⚠️',
            message: '実績を読み込めませんでした',
            subMessage: '$e',
          ),
          data: (list) {
            final unlocked = list.where((a) => a.isUnlocked).length;
            return ListView(
              padding: spacing.screenPadding.copyWith(bottom: 32),
              children: [
                Text(
                  '$unlocked / ${list.length} 個を解除しています',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption(),
                ),
                SizedBox(height: spacing.gap),
                for (final item in list) ...[
                  _AchievementTile(item: item),
                  SizedBox(height: spacing.gap),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final AchievementProgress item;

  const _AchievementTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final def = item.def;
    return SoftCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 未解除も同じ形で並べる（伏せ字にしない）。解除済みだけ色を付ける。
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.isUnlocked ? AppColors.accentSoft : AppColors.chipBg,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              def.emoji,
              textScaler: TextScaler.noScaling,
              style: const TextStyle(fontSize: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  def.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.style(size: 15, weight: FontWeight.w700),
                ),
                Text(
                  def.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption(),
                ),
                const SizedBox(height: 6),
                if (item.isUnlocked)
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.correct,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${_formatDate(item.unlockedAt!)} に解除',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.caption(color: AppColors.correctText),
                        ),
                      ),
                    ],
                  )
                else ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: item.ratio,
                      minHeight: 6,
                      backgroundColor: AppColors.masteryTrack,
                      valueColor: AlwaysStoppedAnimation(AppColors.accent),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.current} / ${def.target}${def.unit}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) => '${d.year}/${d.month}/${d.day}';
}
