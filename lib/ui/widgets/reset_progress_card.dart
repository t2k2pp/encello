import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/database/app_database.dart';
import '../../data/services/reset_progress_service.dart';
import '../../providers/data_management.dart';
import '../../providers/providers.dart';
import '../dialogs/confirm_dialog.dart';
import 'data_exchange_cards.dart';
import 'soft_card.dart';

/// 学習状態のリセット（[Docs/06_features/export_import.md] §5）。
///
/// **現在の学習者の分だけ**を消す。**二段確認**を要し、1段目で消える対象と件数を
/// 列挙して「先にバックアップを書き出す」導線を置き、2段目で確定する
/// （[STYLE_GUIDE §4.3]）。
class ResetProgressCard extends ConsumerStatefulWidget {
  final Profile profile;

  const ResetProgressCard({super.key, required this.profile});

  @override
  ConsumerState<ResetProgressCard> createState() => _ResetProgressCardState();
}

class _ResetProgressCardState extends ConsumerState<ResetProgressCard> {
  bool _busy = false;

  Future<void> _exportBackup(BuildContext dialogContext) async {
    try {
      final now = ref.read(clockProvider)();
      final payload = await ref
          .read(exportImportServiceProvider)
          .collectBackup(exportedAt: now);
      final json = await ref.read(backupEncoderProvider)(payload);
      final path = await ref
          .read(fileExchangeServiceProvider)
          .save(suggestedName: backupFileName(now), contents: json);
      if (!mounted) return;
      if (path == null) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('バックアップを書き出しました')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('書き出しに失敗しました: $e')));
    }
  }

  Future<bool?> _showFirstStepDialog(
    BuildContext context,
    ResetProgressCounts counts,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${widget.profile.name}さんの学習状態をリセット'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('次を削除します（単語帳・単語・マイ単語は残ります）。', style: AppText.body()),
              const SizedBox(height: 8),
              Text('・解答履歴 ${counts.learningLogs}件', style: AppText.caption()),
              Text('・学習セッション ${counts.studySessions}件', style: AppText.caption()),
              Text('・単語の学習状態 ${counts.wordReviews}件', style: AppText.caption()),
              Text('・語の部品の学習状態 ${counts.partReviews}件', style: AppText.caption()),
              Text('・日次集計 ${counts.dailyStats}件', style: AppText.caption()),
              Text('・実績 ${counts.achievements}件', style: AppText.caption()),
              Text('・語彙力測定 ${counts.vocabSizeTests}件', style: AppText.caption()),
              Text('・解消した取り違え ${counts.resolvedConfusions}件', style: AppText.caption()),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _exportBackup(ctx),
                icon: const Icon(Icons.upload_file, size: 18),
                label: const Text(
                  '先にバックアップを書き出す',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.accentDeep),
            child: const Text('次へ'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndReset() async {
    if (_busy) return;
    final service = ref.read(resetProgressServiceProvider);
    final counts = await service.inspect(widget.profile.id);
    if (!mounted) return;

    if (counts.total == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('リセットする学習記録がありません')));
      return;
    }

    final first = await _showFirstStepDialog(context, counts);
    if (first != true || !mounted) return;

    final second = await confirmDestructive(
      context,
      title: '本当にリセットしますか',
      message: 'この操作は取り消せません。消えた記録は元に戻せません。',
      confirmLabel: '本当にリセットする',
    );
    if (!second || !mounted) return;

    setState(() => _busy = true);
    try {
      await service.reset(widget.profile.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('学習状態をリセットしました')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('リセットに失敗しました: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('学習状態をリセット', style: AppText.sectionTitle()),
          const SizedBox(height: 4),
          Text(
            '${widget.profile.name}さんの学習記録（解答履歴・学習状態・実績など）だけを消します。'
            '単語帳・単語・マイ単語は残ります。',
            style: AppText.caption(),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accentDeep,
              minimumSize: const Size.fromHeight(44),
            ),
            onPressed: _busy ? null : _confirmAndReset,
            icon: const Icon(Icons.restart_alt, size: 18),
            label: const Text(
              '学習状態をリセットする',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
