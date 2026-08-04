import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/database/app_database.dart';
import '../../providers/data_management.dart';
import '../../providers/providers.dart';
import '../dialogs/confirm_dialog.dart';
import 'soft_card.dart';

/// サンプルデータの投入・削除（[Docs/06_features/export_import.md] §4、
/// [STYLE_GUIDE §5.1]）。投入 / 削除を横並び2列の `OutlinedButton.icon` で置く。
class SampleDataCard extends ConsumerStatefulWidget {
  final Profile profile;

  const SampleDataCard({super.key, required this.profile});

  @override
  ConsumerState<SampleDataCard> createState() => _SampleDataCardState();
}

class _SampleDataCardState extends ConsumerState<SampleDataCard> {
  bool _busy = false;

  Future<void> _install() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final now = ref.read(clockProvider)();
      final result = await ref
          .read(sampleDataServiceProvider)
          .install(profileId: widget.profile.id, now: now);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'サンプルデータを投入しました（単語${result.wordCount}語・記録${result.logCount}件）',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('投入に失敗しました: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    if (_busy) return;
    final service = ref.read(sampleDataServiceProvider);
    final preview = await service.inspectDelete();
    if (!mounted) return;

    final message = preview.keptWordCount > 0
        ? 'サンプルの単語帳と、そこにしか属さない語${preview.deletableWordCount}語・'
              '学習の記録を削除します。他の単語帳にも属する語${preview.keptWordCount}語は残します。'
        : 'サンプルの単語帳と、収録された${preview.deletableWordCount}語・学習の記録を削除します。';
    final ok = await confirmDestructive(
      context,
      title: 'サンプルデータを削除しますか',
      message: message,
    );
    if (!ok || !mounted) return;

    setState(() => _busy = true);
    try {
      final result = await service.delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.keptWordCount > 0
                ? '${result.deletedWordCount}語を削除しました'
                      '（他の単語帳にも属する${result.keptWordCount}語は残しました）'
                : '${result.deletedWordCount}語を削除しました',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('削除に失敗しました: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final installed = ref.watch(sampleDataInstalledProvider).value ?? false;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('サンプルデータ', style: AppText.sectionTitle()),
          const SizedBox(height: 4),
          Text(
            '30語の単語帳と直近14日分の学習記録を試しに入れます。'
            '統計やストリークの見え方をすぐ確認できます。',
            style: AppText.caption(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: (_busy || installed) ? null : _install,
                  icon: const Icon(Icons.science_outlined, size: 18),
                  label: const Text(
                    'サンプル投入',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentDeep,
                  ),
                  onPressed: (_busy || !installed) ? null : _delete,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text(
                    'サンプル削除',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
