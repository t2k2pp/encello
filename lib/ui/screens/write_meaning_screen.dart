import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/enums.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/word_repository.dart';
import '../../providers/providers.dart';
import '../widgets/centered_content.dart';
import '../widgets/empty_state.dart';
import '../widgets/soft_card.dart';

/// 「訳を書く」モード（[Docs/06_features/my_words.md] §5）。
///
/// 下書き（訳が未入力のマイ単語）を1語ずつ出し、見出し語と「見つけた文」を上に、
/// 訳の入力欄を下に置いて次々に埋める。保存すると `isDraft` が false になり
/// 出題対象に入る。「あとで」で飛ばし、全部終わったら完了表示にする。
class WriteMeaningScreen extends ConsumerStatefulWidget {
  final Profile profile;

  const WriteMeaningScreen({super.key, required this.profile});

  @override
  ConsumerState<WriteMeaningScreen> createState() =>
      _WriteMeaningScreenState();
}

class _WriteMeaningScreenState extends ConsumerState<WriteMeaningScreen> {
  late final Future<List<DraftWord>> _plan = _load();
  final _meaningCtrl = TextEditingController();
  int _index = 0;
  bool _saving = false;

  /// 下書きを一度だけ読む。ストリームの `.first` は使わない
  /// （一度も流れないと待ち続けるため。[Docs/07_testing_strategy.md] §4）。
  Future<List<DraftWord>> _load() =>
      ref.read(wordRepositoryProvider).draftWords(widget.profile.id);

  @override
  void dispose() {
    _meaningCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveAndNext(List<DraftWord> drafts) async {
    final meaning = _meaningCtrl.text.trim();
    if (meaning.isEmpty || _saving) return;
    final draft = drafts[_index];
    final word = draft.word;
    setState(() => _saving = true);
    try {
      await ref
          .read(wordRepositoryProvider)
          .updateWord(
            word,
            headword: word.headword,
            partOfSpeech: PartOfSpeech.fromValue(word.partOfSpeech),
            meaning: meaning,
            phonetic: word.phonetic,
            // ここで書き換えるのは訳だけ。書き残した「出会った文」はそのまま渡す。
            exampleEn: draft.example?.exampleEn,
            exampleJa: draft.example?.exampleJa,
            level: word.level,
          );
      if (!mounted) return;
      _advance();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('保存できませんでした: $e')));
    }
  }

  void _skip() => _advance();

  void _advance() {
    setState(() {
      _saving = false;
      _meaningCtrl.clear();
      _index++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('訳を書く')),
      body: SafeArea(
        child: CenteredContent(
          child: FutureBuilder<List<DraftWord>>(
            future: _plan,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return EmptyState(
                  emoji: '⚠️',
                  message: '読み込めませんでした',
                  subMessage: '${snapshot.error}',
                );
              }
              final drafts = snapshot.data;
              if (drafts == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (drafts.isEmpty || _index >= drafts.length) {
                return _DoneView(total: drafts.length);
              }
              return _QuestionView(
                draft: drafts[_index],
                index: _index,
                total: drafts.length,
                controller: _meaningCtrl,
                busy: _saving,
                onSave: () => _saveAndNext(drafts),
                onSkip: _skip,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _QuestionView extends StatelessWidget {
  final DraftWord draft;
  final int index;
  final int total;
  final TextEditingController controller;
  final bool busy;
  final VoidCallback onSave;
  final VoidCallback onSkip;

  const _QuestionView({
    required this.draft,
    required this.index,
    required this.total,
    required this.controller,
    required this.busy,
    required this.onSave,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final word = draft.word;
    // 下書きはマイ単語なので、出るのは自分で書き残した「出会った文」。
    final example = draft.example;
    return Padding(
      padding: spacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${index + 1} / $total',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.caption(),
          ),
          SizedBox(height: spacing.gap),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    word.headword,
                    maxLines: 1,
                    style: AppText.headword(),
                  ),
                ),
                // 見つけた文が無い語もある（任意入力のため）。
                if (example != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    example.exampleEn,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(color: AppColors.ink2),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: spacing.gap),
          TextField(
            controller: controller,
            autofocus: true,
            maxLines: 2,
            decoration: const InputDecoration(labelText: '訳'),
          ),
          SizedBox(height: spacing.gap),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final canSave = !busy && value.text.trim().isNotEmpty;
              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: busy ? null : onSkip,
                      child: const Text(
                        'あとで',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: canSave ? onSave : null,
                      child: const Text(
                        '保存して次へ',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DoneView extends StatelessWidget {
  final int total;

  const _DoneView({required this.total});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      emoji: '✅',
      message: total == 0 ? '下書きの単語はありません' : 'すべての訳を書き終えました',
      subMessage: total == 0 ? null : '$total語の訳を入力しました。',
      actionLabel: '閉じる',
      onAction: () => Navigator.of(context).pop(),
    );
  }
}
