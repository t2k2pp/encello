import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/services/export_import_service.dart';
import '../widgets/soft_card.dart';
import 'confirm_dialog.dart';

/// バックアップの中身を見せて、取り込み方を選ばせる
/// （[Docs/06_features/export_import.md] §2.4）。
///
/// 「置き換える」は**二段確認**を挟む（[STYLE_GUIDE §4.3]）。
/// キャンセルや確認の取り下げでは null を返し、何も取り込まない。
Future<ImportMode?> showBackupPreviewSheet(
  BuildContext context, {
  required BackupPreview preview,
}) {
  return showModalBottomSheet<ImportMode>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => _BackupPreviewSheet(preview: preview),
  );
}

class _BackupPreviewSheet extends StatelessWidget {
  final BackupPreview preview;

  const _BackupPreviewSheet({required this.preview});

  @override
  Widget build(BuildContext context) {
    final newProfiles = [
      for (final e in preview.profiles.entries)
        e.value ? '${e.key}（新規）' : e.key,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('バックアップの内容', style: AppText.sectionTitle()),
            const SizedBox(height: 12),
            SoftCard(
              child: Column(
                children: [
                  _Row(
                    label: '作成日時',
                    value: preview.exportedAt == null
                        ? '不明'
                        : _formatDateTime(preview.exportedAt!),
                  ),
                  _Row(label: 'アプリ版', value: preview.appVersion),
                  _Row(label: '学習者', value: newProfiles.join(' / ')),
                  _Row(label: '単語帳', value: '${preview.wordbookCount}冊'),
                  _Row(
                    label: '単語',
                    value:
                        '${preview.wordCount}件'
                        '（うち新規 ${preview.newWordCount}件）',
                  ),
                  _Row(label: 'マイ単語', value: '${preview.myWordCount}件'),
                  _Row(
                    label: '学習記録',
                    value:
                        '${preview.logCount}件'
                        '（うち新しい ${preview.newLogCount}件）',
                  ),
                  _Row(label: '語彙力測定', value: '${preview.vocabTestCount}件'),
                  _Row(label: '実績', value: '${preview.achievementCount}件'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () => Navigator.pop(context, ImportMode.merge),
              child: const Text('追加で取り込む'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accentDeep,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () => _confirmReplace(context),
              child: const Text('置き換える'),
            ),
            const SizedBox(height: 8),
            Text(
              '「追加」は手元の記録を残したまま取り込みます。'
              '「置き換える」は手元の学習者・単語・記録をすべて消してから取り込みます。',
              style: AppText.caption(),
            ),
          ],
        ),
      ),
    );
  }

  /// 置換は二段確認（[Docs/06_features/export_import.md] §2.1）。
  Future<void> _confirmReplace(BuildContext context) async {
    final first = await confirmDestructive(
      context,
      title: 'すべて置き換えますか',
      message:
          'いまの端末にある学習者・単語帳・単語・学習記録がすべて消えます。'
          'その後にバックアップの内容を取り込みます。',
      confirmLabel: '次へ',
    );
    if (!first || !context.mounted) return;

    final second = await confirmDestructive(
      context,
      title: '本当に置き換えますか',
      message: 'この操作は取り消せません。消えた記録は元に戻せません。',
      confirmLabel: '本当に置き換える',
    );
    if (!second || !context.mounted) return;
    Navigator.pop(context, ImportMode.replace);
  }

  static String _formatDateTime(DateTime d) =>
      '${d.year}/${d.month}/${d.day} '
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.caption(),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppText.body(),
            ),
          ),
        ],
      ),
    );
  }
}
