import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../providers/audio.dart';
import '../../providers/data_management.dart';
import '../dialogs/confirm_dialog.dart';
import 'soft_card.dart';

/// バイト数を KB/MB の読める形にする（[Docs/06_features/export_import.md] §5.2）。
String formatBytes(int bytes) {
  if (bytes >= 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
  if (bytes >= 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)}KB';
  }
  return '${bytes}B';
}

/// 未所属の単語の整理（[Docs/06_features/export_import.md] §5.1）。
/// **自動では走らせない**。手動トリガーのみ。
class OrphanWordsCleanupCard extends ConsumerStatefulWidget {
  const OrphanWordsCleanupCard({super.key});

  @override
  ConsumerState<OrphanWordsCleanupCard> createState() =>
      _OrphanWordsCleanupCardState();
}

class _OrphanWordsCleanupCardState
    extends ConsumerState<OrphanWordsCleanupCard> {
  bool _busy = false;

  Future<void> _run() async {
    if (_busy) return;
    final service = ref.read(cleanupServiceProvider);
    final inspection = await service.inspectOrphanWords();
    if (!mounted) return;

    if (inspection.wordCount == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('未所属の単語はありません')));
      return;
    }

    final message = [
      'どの単語帳にも属さない語が${inspection.wordCount}語あります。',
      if (inspection.withProgressCount > 0)
        'うち学習状態が付いている語が${inspection.withProgressCount}語あります。'
            '削除すると学習状態・履歴も一緒に消えます。',
      // この整理は端末全体が対象。ほかの学習者のマイ単語も消えることを伝える。
      if (inspection.myWordCount > 0)
        'うち${inspection.myWordCount}語は、だれかのマイ単語です'
            '（この整理は端末全体が対象で、ほかの学習者の語も消えます）。',
    ].join();
    final ok = await confirmDestructive(
      context,
      title: '未所属の単語を削除しますか',
      message: message,
    );
    if (!ok || !mounted) return;

    setState(() => _busy = true);
    try {
      final deleted = await service.deleteOrphanWords();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$deleted語を削除しました')));
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
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('未所属の単語を整理', style: AppText.sectionTitle()),
          const SizedBox(height: 4),
          Text(
            '単語帳を削除したあとに残った、どこにも属さない語をまとめて削除します。'
            '自動では実行しません。',
            style: AppText.caption(),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accentDeep,
              minimumSize: const Size.fromHeight(44),
            ),
            onPressed: _busy ? null : _run,
            icon: const Icon(Icons.auto_delete_outlined, size: 18),
            label: const Text(
              '未所属の単語を整理する',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// 使われていない音声ファイルの整理（[Docs/06_features/export_import.md] §5.2、
/// [Docs/06_features/pronunciation.md] §3.3）。**起動時に自動で走らせない**。
class UnusedAudioCleanupCard extends ConsumerStatefulWidget {
  const UnusedAudioCleanupCard({super.key});

  @override
  ConsumerState<UnusedAudioCleanupCard> createState() =>
      _UnusedAudioCleanupCardState();
}

class _UnusedAudioCleanupCardState
    extends ConsumerState<UnusedAudioCleanupCard> {
  bool _busy = false;

  Future<void> _run() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final service = ref.read(cleanupServiceProvider);
      final documentsPath = await ref.read(documentsPathProvider.future);
      final inspection = await service.inspectUnusedAudioFiles(documentsPath);
      if (!mounted) return;

      if (inspection.fileCount == 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('使われていない音声ファイルはありません')));
        return;
      }

      final ok = await confirmDestructive(
        context,
        title: '使われていない音声ファイルを削除しますか',
        message:
            'どの単語にも紐付いていない音声ファイルが${inspection.fileCount}件あります。'
            '削除すると ${formatBytes(inspection.freedBytes)} の容量が解放されます。',
      );
      if (!ok || !mounted) return;

      final result = await service.deleteUnusedAudioFiles(documentsPath);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${result.fileCount}件を削除し、${formatBytes(result.freedBytes)} を解放しました',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('整理に失敗しました: $e')));
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
          Text('使われていない音声ファイルを整理', style: AppText.sectionTitle()),
          const SizedBox(height: 4),
          Text(
            'どの単語にも紐付いていない音声ファイルをまとめて削除します。'
            '自動では実行しません。',
            style: AppText.caption(),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accentDeep,
              minimumSize: const Size.fromHeight(44),
            ),
            onPressed: _busy ? null : _run,
            icon: const Icon(Icons.cleaning_services_outlined, size: 18),
            label: const Text(
              '使われていない音声ファイルを整理する',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
