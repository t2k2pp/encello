import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/profile_repository.dart';
import '../../providers/providers.dart';
import '../../providers/stats.dart';
import '../dialogs/confirm_dialog.dart';
import '../dialogs/upsert_profile_sheet.dart';
import '../widgets/centered_content.dart';
import '../widgets/empty_state.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/soft_card.dart';

/// SCR-22 学習者管理（[STYLE_GUIDE §4.1] のマスタ管理画面の型、
/// [Docs/06_features/profiles.md] §6）。
class ProfilesScreen extends ConsumerWidget {
  const ProfilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(profileOverviewsProvider);
    final currentId = ref.watch(activeProfileProvider)?.id;
    final spacing = AppSpacing.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('学習者管理')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        tooltip: '学習者を追加',
        onPressed: () => showUpsertProfileSheet(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: CenteredContent(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => EmptyState(
            emoji: '⚠️',
            message: '学習者を読み込めませんでした',
            subMessage: '$e',
          ),
          data: (all) {
            if (all.isEmpty) {
              return const EmptyState(emoji: '🙂', message: '学習者がありません');
            }
            return ListView.separated(
              padding: spacing.screenPadding.copyWith(bottom: 96),
              itemCount: all.length,
              separatorBuilder: (_, _) => SizedBox(height: spacing.gap),
              itemBuilder: (_, i) => _ProfileRow(
                overview: all[i],
                isCurrent: all[i].profile.id == currentId,
                canDelete: all.length > 1,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileRow extends ConsumerWidget {
  final ProfileOverview overview;
  final bool isCurrent;

  /// 最後の1人は削除できない（FR-62）。
  final bool canDelete;

  const _ProfileRow({
    required this.overview,
    required this.isCurrent,
    required this.canDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = overview.profile;
    final streak = overview.streak.current;
    return SoftCard(
      onTap: () => showUpsertProfileSheet(context, editing: p),
      child: Row(
        children: [
          ProfileAvatar(emoji: p.emoji, colorSeed: p.colorSeed),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(),
                ),
                Text(
                  '学習中 ${overview.summary.learningWords}語 ・ ストリーク $streak日',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption(),
                ),
              ],
            ),
          ),
          if (isCurrent)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Tooltip(
                message: 'いま学習中の学習者',
                child: Icon(Icons.check_circle, size: 18, color: AppColors.accent),
              ),
            ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppColors.ink3),
            tooltip: '学習者を削除',
            onPressed: () => _delete(context, ref, p),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Profile profile,
  ) async {
    // 参照の有無は確認より前に判定し、確定後に失敗させない（[STYLE_GUIDE §4.3]）。
    if (!canDelete) {
      await showCannotDelete(
        context,
        title: '削除できません',
        message: '学習者は1人以上必要です。',
      );
      return;
    }

    final repo = ref.read(profileRepositoryProvider);
    final impact = await repo.deletionImpact(profile.id);
    if (!context.mounted) return;

    final ok = await confirmDestructive(
      context,
      title: '学習者を削除',
      message:
          '${profile.name}さんの学習記録 ${impact.totalRecords}件がすべて消えます。'
          '${profile.name}さんが登録したマイ単語 ${impact.myWords}語も一緒に消えます。\n\n'
          '消したくない記録があるときは、先に 設定 > データ からエクスポートしてください。',
    );
    if (!ok || !context.mounted) return;

    try {
      await repo.delete(profile.id);
      // その人あての通知も取り消す（[Docs/06_features/reminders.md] §3.1）。
      await ref.read(reminderSchedulerProvider).cancel(profile.id);
      // 削除したのが現在の学習者なら、選び直させる。
      if (ref.read(activeProfileProvider)?.id == profile.id) {
        ref.read(activeProfileProvider.notifier).clear();
        return;
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('削除に失敗しました: $e')));
      return;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${profile.name}さんを削除しました')),
    );
  }
}
