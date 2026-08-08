import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../data/database/app_database.dart';
import '../../providers/providers.dart';
import '../widgets/centered_content.dart';
import '../widgets/soft_card.dart';
import 'paste_import_screen.dart';

/// SCR-25 AI への頼み方（[Docs/04_screens_and_flows.md] §4.16、
/// [Docs/06_features/ai_import.md] §4）。
///
/// ①→②→③ の順にカードを並べ、最後に共通の「アプリに貼り付ける」手順を置く。
/// テーマ・語数・レベルの入力欄は ① と ③ の**各カード内**に置く（②には置かない）。
class PromptGuideScreen extends StatelessWidget {
  final Profile profile;

  const PromptGuideScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('AI への頼み方')),
      body: CenteredContent(
        child: ListView(
          padding: spacing.screenPadding.copyWith(bottom: 32),
          children: [
            Text(
              '生成AI に単語帳を作ってもらい、結果をこのアプリに持ち帰ります。'
              'アプリから AI へは通信しません。',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppText.caption(),
            ),
            SizedBox(height: spacing.gap * 2),
            const _AskWordbookCard(),
            SizedBox(height: spacing.gap),
            const _ConvertCard(),
            SizedBox(height: spacing.gap),
            const _AskForImportCard(),
            SizedBox(height: spacing.gap * 2),
            _PasteStepCard(profile: profile),
          ],
        ),
      ),
    );
  }
}

/// 生成AI にコピーした文を貼り付け、返ってきた内容をこのアプリへ貼り付けるまでの共通手順。
class _PasteStepCard extends StatelessWidget {
  final Profile profile;

  const _PasteStepCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'アプリに貼り付ける',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.sectionTitle(),
          ),
          const SizedBox(height: 4),
          Text(
            'コピーした文を AI に貼り付けて実行し、返ってきた内容をコピーします。'
            'このアプリに戻り、「貼り付けて取り込む」からその内容を貼り付けてください。',
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: AppText.caption(),
          ),
          const SizedBox(height: 12),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PasteImportScreen(profile: profile),
              ),
            ),
            child: const Text('貼り付けて取り込む'),
          ),
        ],
      ),
    );
  }
}

/// テーマ・語数・レベルを入力する共通フォーム（① と ③ のカード内で使う）。
class _PromptForm extends StatefulWidget {
  final String title;
  final String description;
  final Future<String> Function(
    WidgetRef ref,
    String theme,
    int count,
    String level,
  )
  buildPrompt;

  const _PromptForm({
    required this.title,
    required this.description,
    required this.buildPrompt,
  });

  @override
  State<_PromptForm> createState() => _PromptFormState();
}

class _PromptFormState extends State<_PromptForm> {
  final _themeCtrl = TextEditingController();
  final _levelCtrl = TextEditingController();
  int _count = 20;

  static const _countChoices = [10, 20, 30, 50];

  @override
  void dispose() {
    _themeCtrl.dispose();
    _levelCtrl.dispose();
    super.dispose();
  }

  Future<void> _copy(WidgetRef ref) async {
    final theme = _themeCtrl.text.trim().isEmpty
        ? '英単語'
        : _themeCtrl.text.trim();
    final level = _levelCtrl.text.trim().isEmpty
        ? '指定なし'
        : _levelCtrl.text.trim();
    final prompt = await widget.buildPrompt(ref, theme, _count, level);
    await Clipboard.setData(ClipboardData(text: prompt));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('コピーしました')));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.sectionTitle(),
              ),
              const SizedBox(height: 4),
              Text(
                widget.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppText.caption(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _themeCtrl,
                decoration: const InputDecoration(
                  labelText: 'テーマ',
                  hintText: '例: 看護実習で使う英単語',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '語数（1回につき最大50語）',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.caption(),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  for (final n in _countChoices)
                    ChoiceChip(
                      label: Text('$n語'),
                      selected: _count == n,
                      onSelected: (_) => setState(() => _count = n),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _levelCtrl,
                decoration: const InputDecoration(
                  labelText: 'レベル',
                  hintText: '例: 中学2年生、TOEIC600点くらい',
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _copy(ref),
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('コピー'),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ① 単語帳を作ってもらう。
class _AskWordbookCard extends StatelessWidget {
  const _AskWordbookCard();

  @override
  Widget build(BuildContext context) {
    return _PromptForm(
      title: '① 単語帳を作ってもらう',
      description: 'テーマ・語数・レベルを指定して、単語帳をゼロから作ってもらいます。',
      buildPrompt: (ref, theme, count, level) => ref
          .read(promptAssetsProvider)
          .askWordbook(theme: theme, count: count, level: level),
    );
  }
}

/// ② 直前のやりとりを取込用に変換してもらう。
class _ConvertCard extends StatelessWidget {
  const _ConvertCard();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '② 直前のやりとりを取込用に変換してもらう',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.sectionTitle(),
              ),
              const SizedBox(height: 4),
              Text(
                'すでに AI と会話して語を挙げてもらった後から使います。'
                'そのやりとりに続けて、コピーした文を貼り付けてください。',
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: AppText.caption(),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final prompt = await ref
                      .read(promptAssetsProvider)
                      .convertToWordbook();
                  await Clipboard.setData(ClipboardData(text: prompt));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('コピーしました')));
                },
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('コピー'),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ③ 統合（①＋②を1回で。おすすめの導線）。
class _AskForImportCard extends StatelessWidget {
  const _AskForImportCard();

  @override
  Widget build(BuildContext context) {
    return _PromptForm(
      title: '③ まとめて1回で頼む（おすすめ）',
      description: 'テーマ・語数・レベルを指定して、単語の選び方まで細かく指示します。',
      buildPrompt: (ref, theme, count, level) => ref
          .read(promptAssetsProvider)
          .askWordbookForImport(theme: theme, count: count, level: level),
    );
  }
}
