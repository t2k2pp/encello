import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../data/database/app_database.dart';
import '../../data/services/text_charset.dart';
import '../../domain/usecases/wordbook_csv_codec.dart';
import '../../providers/providers.dart';
import '../widgets/centered_content.dart';
import '../widgets/soft_card.dart';

/// 単語帳への CSV 取り込み（[Docs/06_features/wordbooks.md] §5）。
///
/// ヘッダ行の有無は**自動判定しない**。利用者がチェックで明示する。
/// 弾いた行は行番号と理由を全件出し、「正しい行だけ取り込む」か「やめる」を選ばせる。
class CsvImportScreen extends ConsumerStatefulWidget {
  final Wordbook wordbook;

  const CsvImportScreen({super.key, required this.wordbook});

  @override
  ConsumerState<CsvImportScreen> createState() => _CsvImportScreenState();
}

class _CsvImportScreenState extends ConsumerState<CsvImportScreen> {
  /// プレビューに出す行数。
  static const previewRows = 20;

  bool _hasHeader = true;
  bool _busy = false;
  String? _fileName;
  String? _text;
  TextCharset? _charset;
  CsvDecodeResult? _result;
  String? _error;

  Future<void> _pick() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final picked = await ref
          .read(fileExchangeServiceProvider)
          .pick(extensions: const ['csv']);
      if (picked == null) return;
      final decoded = decodeTextFile(picked.bytes);
      if (decoded == null) {
        setState(() {
          _error = '文字コードを判別できません。UTF-8 で保存し直してください。';
          _text = null;
          _result = null;
        });
        return;
      }
      setState(() {
        _fileName = picked.name;
        _text = decoded.text;
        _charset = decoded.charset;
        _result = WordbookCsvCodec.decode(decoded.text, hasHeader: _hasHeader);
      });
    } catch (e) {
      setState(() => _error = 'ファイルを読み込めませんでした: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _setHasHeader(bool value) {
    setState(() {
      _hasHeader = value;
      final text = _text;
      if (text != null) {
        _result = WordbookCsvCodec.decode(text, hasHeader: value);
      }
    });
  }

  Future<void> _import() async {
    final result = _result;
    if (result == null || result.words.isEmpty || _busy) return;
    setState(() => _busy = true);
    try {
      final counts = await ref
          .read(exportImportServiceProvider)
          .importCsv(widget.wordbook.id, result.words);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${result.words.length}語を取り込みました'
            '（新しく増えたのは ${counts.added}語）',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('取り込みに失敗しました: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final result = _result;

    return Scaffold(
      appBar: AppBar(title: Text('${widget.wordbook.name} に取り込む')),
      body: CenteredContent(
        child: ListView(
          padding: spacing.screenPadding.copyWith(bottom: 32),
          children: [
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ファイル', style: AppText.sectionTitle()),
                  const SizedBox(height: 4),
                  Text(
                    _fileName == null
                        ? '列は 見出し語 / 品詞 / 発音記号 / 訳 / 例文 / 例文の訳 / レベル の順です。'
                        : '$_fileName（${_charset?.label ?? ''}）',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption(),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _pick,
                    icon: const Icon(Icons.folder_open, size: 18),
                    label: const Text('ファイルを選ぶ'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                  // ListTile 系は `SoftCard` の背景の上ではインクが見えなくなるため使わない。
                  Row(
                    children: [
                      Checkbox(
                        value: _hasHeader,
                        activeColor: AppColors.accent,
                        onChanged: (v) => _setHasHeader(v ?? false),
                      ),
                      Expanded(
                        child: Text(
                          '1行目は見出し（ヘッダ）',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.body(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_error != null) ...[
              SizedBox(height: spacing.gap),
              SoftCard(
                child: Text(
                  _error!,
                  style: AppText.body(color: AppColors.accentDeep),
                ),
              ),
            ],
            if (result != null) ...[
              SizedBox(height: spacing.gap),
              _PreviewCard(result: result, previewRows: previewRows),
              if (result.issues.isNotEmpty) ...[
                SizedBox(height: spacing.gap),
                _IssuesCard(issues: result.issues),
              ],
              SizedBox(height: spacing.gap),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: result.words.isEmpty || _busy ? null : _import,
                child: Text(
                  result.issues.isEmpty
                      ? '${result.words.length}語を取り込む'
                      : '正しい${result.words.length}語だけ取り込む',
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('やめる'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final CsvDecodeResult result;
  final int previewRows;

  const _PreviewCard({required this.result, required this.previewRows});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('取り込む語（${result.words.length}）', style: AppText.sectionTitle()),
          const SizedBox(height: 8),
          if (result.words.isEmpty)
            Text('取り込める語がありませんでした。', style: AppText.caption())
          else
            for (final w in result.words.take(previewRows))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        w.headword,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 56,
                      child: Text(
                        w.partOfSpeech.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.caption(),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        w.meaning,
                        maxLines: 1,
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.caption(),
                      ),
                    ),
                  ],
                ),
              ),
          if (result.words.length > previewRows) ...[
            const SizedBox(height: 4),
            Text(
              'ほか ${result.words.length - previewRows}語',
              style: AppText.caption(),
            ),
          ],
        ],
      ),
    );
  }
}

class _IssuesCard extends StatelessWidget {
  final List<CsvIssue> issues;

  const _IssuesCard({required this.issues});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('取り込めない行（${issues.length}）', style: AppText.sectionTitle()),
          const SizedBox(height: 4),
          Text('推測で補わず、そのまま飛ばします。', style: AppText.caption()),
          const SizedBox(height: 8),
          for (final issue in issues)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                issue.display,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.caption(color: AppColors.accentDeep),
              ),
            ),
        ],
      ),
    );
  }
}
