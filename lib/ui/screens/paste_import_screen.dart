import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/ai_import_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../data/database/app_database.dart';
import '../../domain/usecases/wordbook_json_codec.dart';
import '../../providers/providers.dart';
import '../widgets/centered_content.dart';
import '../widgets/soft_card.dart';
import '../widgets/soft_dropdown.dart';
import 'wordbook_detail_screen.dart';

enum _Destination { create, addToExisting }

enum _Stage {
  /// 貼り付け・取り込み先の入力中。まだ確認していない。
  editing,

  /// 単語帳そのものが作れない致命的な問題（版違い・名前なし等）。
  fatalError,

  /// 一部の語を弾いたが、残りは取り込める。「正しい語だけ取り込む」か「やめる」を選ばせる。
  partialChoice,

  /// プレビューを読み込み中（DB 参照が終わるまでの一瞬）。
  loadingPreview,

  /// 取り込み前のプレビュー。
  preview,
}

/// SCR-24 貼り付け取込（[Docs/04_screens_and_flows.md] §4.16、
/// [Docs/06_features/ai_import.md] §3・§5）。
///
/// 順番: 貼り付け欄 → 取り込み先 → プレビュー → 実行。
/// 失敗しても貼り付けたテキストは消さない（§5）。画面の文言に「JSON」「インポート」
/// 「パース」は出さない（§1.1）。
class PasteImportScreen extends ConsumerStatefulWidget {
  final Profile profile;

  const PasteImportScreen({super.key, required this.profile});

  @override
  ConsumerState<PasteImportScreen> createState() => _PasteImportScreenState();
}

class _PasteImportScreenState extends ConsumerState<PasteImportScreen> {
  final _textCtrl = TextEditingController();
  _Destination _destination = _Destination.create;
  int? _targetWordbookId;

  WordbookDecodeResult? _decoded;
  AiImportPreview? _preview;
  bool _busy = false;

  _Stage get _stage {
    if (_preview != null) return _Stage.preview;
    final decoded = _decoded;
    if (decoded == null) return _Stage.editing;
    if (decoded.book == null) return _Stage.fatalError;
    if (decoded.issues.isNotEmpty) return _Stage.partialChoice;
    return _Stage.loadingPreview;
  }

  @override
  void initState() {
    super.initState();
    // 「確認する」の活性状態はテキストの有無で決まるため、入力の変化を検知して
    // 再描画する（TextField の変更は親の setState を自動では呼ばない）。
    _textCtrl.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (!mounted) return;
    setState(() {
      if (_decoded != null || _preview != null) {
        _decoded = null;
        _preview = null;
      }
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    final text = data?.text;
    if (text == null || text.isEmpty || !mounted) return;
    // 変更通知で再描画される（[_onTextChanged]）。
    _textCtrl.text = text;
  }

  Future<void> _confirm() async {
    final decoded = WordbookJsonCodec.decode(_textCtrl.text);
    setState(() {
      _decoded = decoded;
      _preview = null;
    });
    if (decoded.isClean) await _loadPreview(decoded.book!);
  }

  Future<void> _usePartial() async {
    final book = _decoded?.book;
    if (book == null) return;
    await _loadPreview(book);
  }

  void _cancelPartial() {
    setState(() {
      _decoded = null;
      _preview = null;
    });
  }

  Future<void> _loadPreview(ParsedWordbook book) async {
    setState(() => _busy = true);
    try {
      final preview = await ref.read(aiImportServiceProvider).preview(book);
      if (!mounted) return;
      setState(() {
        _preview = preview;
        _busy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('確認できませんでした: $e')));
    }
  }

  Future<void> _copyFixPrompt() async {
    final issues = _decoded?.issues ?? const <ImportIssue>[];
    final prompt = await ref
        .read(promptAssetsProvider)
        .fixWordbook(
          errors: WordbookJsonCodec.describeIssues(issues),
          source: _textCtrl.text,
        );
    await Clipboard.setData(ClipboardData(text: prompt));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('直してもらう文をコピーしました')));
  }

  Future<void> _import() async {
    final book = _decoded?.book;
    if (book == null || _busy) return;
    if (_destination == _Destination.addToExisting &&
        _targetWordbookId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('足す先の単語帳を選んでください')));
      return;
    }
    setState(() => _busy = true);
    try {
      final result = await ref
          .read(aiImportServiceProvider)
          .import(
            book,
            targetWordbookId: _destination == _Destination.addToExisting
                ? _targetWordbookId
                : null,
          );
      if (!mounted) return;
      final profile = widget.profile;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => WordbookDetailScreen(
            wordbookId: result.wordbookId,
            profile: profile,
          ),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${result.totalCount}語のうち、${result.newWordCount}語を新しく取り込みました',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('取り込めませんでした: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final stage = _stage;

    return Scaffold(
      appBar: AppBar(title: const Text('貼り付けて取り込む')),
      body: CenteredContent(
        child: ListView(
          padding: spacing.screenPadding.copyWith(bottom: 32),
          children: [
            Text(
              'AI に作ってもらった単語帳を貼り付けて取り込みます。',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppText.caption(),
            ),
            SizedBox(height: spacing.gap),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '貼り付け欄',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.sectionTitle(),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _pasteFromClipboard,
                        icon: const Icon(Icons.content_paste, size: 18),
                        label: const Text('貼り付け'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _textCtrl,
                    minLines: 6,
                    maxLines: 12,
                    decoration: const InputDecoration(
                      hintText: 'ここに AI の出力を貼り付けてください',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.gap),
            _DestinationCard(
              profile: widget.profile,
              destination: _destination,
              targetWordbookId: _targetWordbookId,
              enabled: stage != _Stage.preview,
              onDestinationChanged: (d) => setState(() => _destination = d),
              onTargetChanged: (id) => setState(() => _targetWordbookId = id),
            ),
            SizedBox(height: spacing.gap),
            ..._buildStageContent(stage, spacing),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStageContent(_Stage stage, AppSpacing spacing) {
    switch (stage) {
      case _Stage.editing:
        return [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: _busy || _textCtrl.text.trim().isEmpty ? null : _confirm,
            child: const Text('確認する'),
          ),
        ];
      case _Stage.fatalError:
        return [
          _IssueList(issues: _decoded!.issues),
          SizedBox(height: spacing.gap),
          OutlinedButton.icon(
            onPressed: _copyFixPrompt,
            icon: const Icon(Icons.auto_fix_high, size: 18),
            label: const Text('AI に直してもらう文をコピー'),
          ),
        ];
      case _Stage.partialChoice:
        return [
          _IssueList(issues: _decoded!.issues),
          SizedBox(height: spacing.gap),
          Text(
            '正しく読み取れた語だけを取り込むか、いったんやめるかを選べます。',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.caption(),
          ),
          SizedBox(height: spacing.gap),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : _cancelPartial,
                  child: const Text('やめる'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                  ),
                  onPressed: _busy ? null : _usePartial,
                  child: const Text('正しい語だけ取り込む'),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.gap),
          OutlinedButton.icon(
            onPressed: _copyFixPrompt,
            icon: const Icon(Icons.auto_fix_high, size: 18),
            label: const Text('AI に直してもらう文をコピー'),
          ),
        ];
      case _Stage.loadingPreview:
        return const [Center(child: CircularProgressIndicator())];
      case _Stage.preview:
        final preview = _preview!;
        final decoded = _decoded!;
        return [
          if (decoded.issues.isNotEmpty) ...[
            _IssueList(issues: decoded.issues),
            SizedBox(height: spacing.gap),
          ],
          _PreviewCard(preview: preview),
          SizedBox(height: spacing.gap),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: _busy ? null : _import,
            child: Text('${preview.totalCount}語を取り込む'),
          ),
        ];
    }
  }
}

/// 取り込み先（新しく作る / 既存の単語帳に足す。§4.1 の分割取り込み導線）。
class _DestinationCard extends ConsumerWidget {
  final Profile profile;
  final _Destination destination;
  final int? targetWordbookId;
  final bool enabled;
  final ValueChanged<_Destination> onDestinationChanged;
  final ValueChanged<int?> onTargetChanged;

  const _DestinationCard({
    required this.profile,
    required this.destination,
    required this.targetWordbookId,
    required this.enabled,
    required this.onDestinationChanged,
    required this.onTargetChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(wordbooksProvider(profile.id)).value ?? const [];
    // プリセット・マイ単語帳は足す先に選べない（[Docs/06_features/wordbooks.md] §4 の
    // 「削除できる単語帳」と同じ範囲。プリセットは同梱内容を固定し、マイ単語帳は
    // 個人の語だけを持つため、AI 取り込みの共有語を混ぜる先にしない）。
    final eligible = books.where((b) => b.canDelete).toList();

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '取り込み先',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.sectionTitle(),
          ),
          const SizedBox(height: 8),
          SegmentedButton<_Destination>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: _Destination.create, label: Text('新しく作る')),
              ButtonSegment(
                value: _Destination.addToExisting,
                label: Text('既存の単語帳に足す'),
              ),
            ],
            selected: {destination},
            onSelectionChanged: enabled
                ? (s) => onDestinationChanged(s.first)
                : null,
          ),
          if (destination == _Destination.addToExisting) ...[
            const SizedBox(height: 8),
            if (eligible.isEmpty)
              Text(
                '足せる単語帳がまだありません。',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.caption(),
              )
            else
              SoftDropdown<int?>(
                value: targetWordbookId,
                hint: '単語帳を選ぶ',
                items: [
                  for (final b in eligible)
                    (value: b.wordbook.id, label: b.wordbook.name),
                ],
                onChanged: enabled ? onTargetChanged : (_) {},
              ),
          ],
        ],
      ),
    );
  }
}

/// エラーの全件一覧（§3.1）。最初の1件で打ち切らない。
class _IssueList extends StatelessWidget {
  final List<ImportIssue> issues;

  const _IssueList({required this.issues});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: AppColors.chipBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${issues.length}件の問題が見つかりました',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.sectionTitle(),
          ),
          const SizedBox(height: 8),
          for (final issue in issues)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                issue.display,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppText.body(color: AppColors.wrong),
              ),
            ),
        ],
      ),
    );
  }
}

/// 取り込み前のプレビュー（§3.2）。単語帳名・語数・先頭20語。
class _PreviewCard extends StatelessWidget {
  final AiImportPreview preview;

  const _PreviewCard({required this.preview});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                preview.emoji,
                textScaler: TextScaler.noScaling,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  preview.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.sectionTitle(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${preview.totalCount}語のうち、新しく増えるのは${preview.newCount}語です',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.caption(),
          ),
          const SizedBox(height: 12),
          for (final w in preview.words)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          w.headword,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.body(),
                        ),
                        Text(
                          '${w.partOfSpeech.label} ・ ${w.meaning}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.caption(),
                        ),
                      ],
                    ),
                  ),
                  if (w.isExisting)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.chipBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'すでにある語',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.caption(),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
