import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/enums.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/wordbook_repository.dart';
import '../../providers/providers.dart';
import '../dialogs/confirm_dialog.dart';
import '../dialogs/upsert_wordbook_sheet.dart';
import '../widgets/centered_content.dart';
import '../widgets/empty_state.dart';
import '../widgets/soft_card.dart';
import 'wordbook_detail_screen.dart';

/// SCR-12 単語帳管理（[STYLE_GUIDE §4.1] のマスタ管理画面の型、
/// [Docs/06_features/wordbooks.md] §4・§6）。
///
/// 学習対象の選択は**学習者ごと**（`profiles.selectedWordbookIds`）。
class WordbooksScreen extends ConsumerWidget {
  final Profile profile;

  const WordbooksScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(wordbooksProvider(profile.id));
    final spacing = AppSpacing.of(context);
    // 学習対象は現在の学習者の設定を見る（他の画面での変更に追従させる）。
    final current = ref.watch(activeProfileProvider) ?? profile;
    final selected = decodeIdList(current.selectedWordbookIds).toSet();

    return Scaffold(
      appBar: AppBar(title: const Text('単語帳管理')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        tooltip: '単語帳を追加',
        onPressed: () => showUpsertWordbookSheet(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: CenteredContent(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => EmptyState(
            emoji: '⚠️',
            message: '単語帳を読み込めませんでした',
            subMessage: '$e',
          ),
          data: (books) {
            if (books.isEmpty) {
              return const EmptyState(emoji: '📚', message: '単語帳がありません');
            }
            return ListView.separated(
              padding: spacing.screenPadding.copyWith(bottom: 96),
              itemCount: books.length,
              separatorBuilder: (_, _) => SizedBox(height: spacing.gap),
              itemBuilder: (_, i) => _WordbookRow(
                item: books[i],
                profile: current,
                isStudyTarget: selected.contains(books[i].wordbook.id),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WordbookRow extends ConsumerWidget {
  final WordbookWithCount item;
  final Profile profile;
  final bool isStudyTarget;

  const _WordbookRow({
    required this.item,
    required this.profile,
    required this.isStudyTarget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = item.wordbook;
    return SoftCard(
      // 行タップ＝編集シート。プリセット単語帳は編集できないため、収録語へ進む。
      onTap: () => item.source == WordbookSource.preset
          ? _openDetail(context)
          : showUpsertWordbookSheet(context, editing: book),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.seedColor(
                book.colorSeed,
              ).withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              book.emoji,
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
                  book.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(),
                ),
                Text(
                  '${item.wordCount}語 ・ ${item.category.label}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption(),
                ),
              ],
            ),
          ),
          Tooltip(
            message: isStudyTarget ? '学習対象から外す' : '学習対象にする',
            child: Switch(
              value: isStudyTarget,
              activeThumbColor: AppColors.accent,
              onChanged: (v) => ref
                  .read(wordbookRepositoryProvider)
                  .setStudyTarget(profile, book.id, selected: v)
                  .then(
                    (_) => ref.read(activeProfileProvider.notifier).reload(),
                  ),
            ),
          ),
          if (item.canDelete)
            IconButton(
              icon: Icon(Icons.delete_outline, color: AppColors.ink3),
              tooltip: '単語帳を削除',
              onPressed: () => _delete(context, ref),
            )
          else
            IconButton(
              icon: Icon(Icons.chevron_right, color: AppColors.ink3),
              tooltip: '収録語を見る',
              onPressed: () => _openDetail(context),
            ),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WordbookDetailScreen(
          wordbookId: item.wordbook.id,
          profile: profile,
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(wordbookRepositoryProvider);
    final studying = await repo.profilesStudying(item.wordbook.id);
    if (!context.mounted) return;

    final ok = await confirmDestructive(
      context,
      title: '単語帳を削除',
      message: [
        '「${item.wordbook.name}」を削除します。',
        '収録している${item.wordCount}語そのものと学習の記録は残り、この単語帳への所属だけが外れます。',
        if (studying.isNotEmpty) '${studying.join('さん・')}さんが学習対象にしています。',
      ].join('\n'),
    );
    if (!ok || !context.mounted) return;

    try {
      await repo.delete(item.wordbook.id);
      await ref.read(activeProfileProvider.notifier).reload();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('削除に失敗しました: $e')));
      return;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('「${item.wordbook.name}」を削除しました')));
  }
}
