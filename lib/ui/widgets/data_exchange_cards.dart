import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/database/app_database.dart';
import '../../data/services/export_import_service.dart';
import '../../providers/providers.dart';
import '../dialogs/backup_preview_sheet.dart';
import '../screens/csv_import_screen.dart';
import 'soft_card.dart';
import 'soft_dropdown.dart';

/// バックアップの書き出しと復元（[Docs/06_features/export_import.md] §1・§2）。
class BackupCard extends ConsumerStatefulWidget {
  const BackupCard({super.key});

  @override
  ConsumerState<BackupCard> createState() => _BackupCardState();
}

class _BackupCardState extends ConsumerState<BackupCard> {
  bool _busy = false;

  Future<void> _export() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final now = ref.read(clockProvider)();
      final payload = await ref
          .read(exportImportServiceProvider)
          .collectBackup(exportedAt: now);
      // JSON への変換は別 isolate（語数が多くても UI を止めない）。
      final json = await ref.read(backupEncoderProvider)(payload);
      final path = await ref
          .read(fileExchangeServiceProvider)
          .save(suggestedName: _backupFileName(now), contents: json);
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
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final picked = await ref
          .read(fileExchangeServiceProvider)
          .pick(extensions: const ['json']);
      if (picked == null) return;

      final service = ref.read(exportImportServiceProvider);
      // バックアップは UTF-8 で書き出している。コード単位のまま読むと日本語が壊れる。
      final preview = await service.inspect(utf8.decode(picked.bytes));
      if (!mounted) return;

      final mode = await showBackupPreviewSheet(context, preview: preview);
      if (mode == null || !mounted) return;

      final result = await service.apply(preview, mode: mode);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '単語${result.wordCount}件・学習記録${result.logCount}件を取り込みました',
          ),
        ),
      );
    } on BackupFormatException catch (e) {
      if (!mounted) return;
      // 何も取り込んでいないことが分かるよう、理由を全部見せる。
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('取り込めませんでした'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(e.message, style: AppText.body()),
                if (e.details.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  for (final d in e.details)
                    Text('・$d', style: AppText.caption()),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('閉じる'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('取り込みに失敗しました: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static String _backupFileName(DateTime now) {
    String two(int v) => v.toString().padLeft(2, '0');
    return 'encello_backup_${now.year}${two(now.month)}${two(now.day)}'
        '_${two(now.hour)}${two(now.minute)}.json';
  }

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('バックアップ', style: AppText.sectionTitle()),
          const SizedBox(height: 4),
          Text(
            '学習者・単語帳・単語・学習の記録をまとめて1つのファイルに書き出します。'
            '音声パックは含まれません。ZIP を別に保管してください。',
            style: AppText.caption(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _export,
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: const Text(
                    '書き出す',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _import,
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text(
                    '復元する',
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

/// 単語帳単位の CSV 入出力（[Docs/06_features/export_import.md] §1・§3）。
class CsvCard extends ConsumerStatefulWidget {
  final Profile profile;

  const CsvCard({super.key, required this.profile});

  @override
  ConsumerState<CsvCard> createState() => _CsvCardState();
}

class _CsvCardState extends ConsumerState<CsvCard> {
  int? _selectedId;
  bool _busy = false;

  Future<void> _export(Wordbook book) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final csv = await ref
          .read(exportImportServiceProvider)
          .collectCsv(book.id);
      final now = ref.read(clockProvider)();
      String two(int v) => v.toString().padLeft(2, '0');
      final path = await ref
          .read(fileExchangeServiceProvider)
          .save(
            suggestedName:
                'encello_${book.name}_${now.year}${two(now.month)}${two(now.day)}.csv',
            contents: csv,
          );
      if (!mounted || path == null) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('CSV を書き出しました')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('書き出しに失敗しました: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(wordbooksProvider(widget.profile.id)).value;
    // 単語帳が読めるまでは操作を出さない（押せるのに何も起きないボタンを置かない）。
    if (books == null || books.isEmpty) return const SizedBox.shrink();

    final selected = books.firstWhere(
      (b) => b.wordbook.id == _selectedId,
      orElse: () => books.first,
    );

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('単語帳の CSV', style: AppText.sectionTitle()),
          const SizedBox(height: 4),
          Text(
            '単語だけを表計算で扱える形にします。学習の記録は含まれません。',
            style: AppText.caption(),
          ),
          const SizedBox(height: 12),
          SoftDropdown<int>(
            value: selected.wordbook.id,
            hint: '単語帳',
            items: [
              for (final b in books)
                (
                  value: b.wordbook.id,
                  label: '${b.wordbook.emoji} ${b.wordbook.name}（${b.wordCount}語）',
                ),
            ],
            onChanged: (id) => setState(() => _selectedId = id),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : () => _export(selected.wordbook),
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: const Text(
                    '書き出す',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy
                      ? null
                      : () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                CsvImportScreen(wordbook: selected.wordbook),
                          ),
                        ),
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text(
                    '取り込む',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '取り込み先: ${selected.wordbook.name}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.caption(color: AppColors.ink2),
          ),
        ],
      ),
    );
  }
}
