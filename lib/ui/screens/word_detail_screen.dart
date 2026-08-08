import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/enums.dart';
import '../../data/database/app_database.dart';
import '../../domain/entities/mastery.dart';
import '../../providers/dictionary_listing.dart';
import '../../providers/providers.dart';
import '../dialogs/confirm_dialog.dart';
import '../dialogs/upsert_word_sheet.dart';
import '../widgets/centered_content.dart';
import '../widgets/empty_state.dart';
import '../widgets/mastery_badge.dart';
import '../widgets/soft_card.dart';
import '../widgets/speak_button.dart';
import 'word_part_detail_screen.dart';
import 'wordbook_detail_screen.dart';

/// SCR-09 単語詳細（[Docs/04_screens_and_flows.md] §4.8、
/// [Docs/06_features/dictionary.md] §2）。
///
/// 条件を満たさないカードは**カードごと出さない**（空のカードを置かない）。
/// 語のつくり・語族・取り違えの各カードは、それぞれの機能が入った時点で足す。
class WordDetailScreen extends ConsumerWidget {
  final int wordId;
  final Profile profile;

  const WordDetailScreen({
    super.key,
    required this.wordId,
    required this.profile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(wordByIdProvider(wordId));
    return Scaffold(
      appBar: AppBar(title: const Text('単語')),
      body: CenteredContent(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => EmptyState(
            emoji: '⚠️',
            message: '単語を読み込めませんでした',
            subMessage: '$e',
          ),
          data: (word) {
            if (word == null) {
              // 他の画面から削除された直後にここへ残ることがある。
              return const EmptyState(emoji: '🗑️', message: 'この単語は削除されました');
            }
            return _WordDetailBody(word: word, profile: profile);
          },
        ),
      ),
    );
  }
}

class _WordDetailBody extends ConsumerWidget {
  final Word word;
  final Profile profile;

  const _WordDetailBody({required this.word, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = AppSpacing.of(context);
    final review = ref
        .watch(wordReviewProvider((wordId: word.id, profileId: profile.id)))
        .value;

    return ListView(
      padding: spacing.screenPadding.copyWith(bottom: 32),
      children: [
        _HeadwordCard(word: word, profile: profile),
        SizedBox(height: spacing.gap),
        _MeaningCard(word: word, profile: profile),
        // 例文が0件の語では例文カードごと出さない。
        _ExamplesCard(word: word, profile: profile, gap: spacing.gap),
        // 部品の紐付けが無い語ではカードごと出さない。
        _WordPartsCard(word: word, profile: profile, gap: spacing.gap),
        // 語族に自分しかいない語ではカードごと出さない。
        _WordFamilyCard(word: word, profile: profile, gap: spacing.gap),
        SizedBox(height: spacing.gap),
        _ReviewCard(review: review),
        SizedBox(height: spacing.gap),
        _ActionsCard(word: word, profile: profile),
      ],
    );
  }
}

class _HeadwordCard extends ConsumerWidget {
  final Word word;
  final Profile profile;

  const _HeadwordCard({required this.word, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final owning =
        ref
            .watch(
              wordbooksOfWordProvider((wordId: word.id, profileId: profile.id)),
            )
            .value ??
        const <Wordbook>[];
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                // 長い見出し語（internationalization 等）でも1行に収める。
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    word.headword,
                    maxLines: 1,
                    style: AppText.headword(),
                  ),
                ),
              ),
              // 鳴らせない語ではボタンごと出ない。
              SpeakWordButton(
                profile: profile,
                word: word,
                lang: SpeechLang.en,
                size: 44,
              ),
            ],
          ),
          if (word.phonetic != null)
            Text(
              word.phonetic!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.phonetic(),
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _Pill(
                label: PartOfSpeech.fromValue(word.partOfSpeech).label,
                background: AppColors.chipBg,
              ),
              _Pill(label: 'レベル ${word.level}', background: AppColors.chipBg),
              if (word.isEdited)
                _Pill(label: '編集済み', background: AppColors.accentSoft),
              if (word.isExcluded)
                _Pill(label: '除外中', background: AppColors.chipBg),
              if (word.isDraft)
                _Pill(label: '下書き', background: AppColors.accentSoft),
            ],
          ),
          // どの単語帳にも属していない語ではチップの行ごと出さない。
          if (owning.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final b in owning)
                    _WordbookChip(
                      wordbook: b,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => WordbookDetailScreen(
                            wordbookId: b.id,
                            profile: profile,
                          ),
                        ),
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

class _MeaningCard extends StatelessWidget {
  final Word word;
  final Profile profile;

  const _MeaningCard({required this.word, required this.profile});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('意味', style: AppText.sectionTitle())),
              if (word.meaning.isNotEmpty)
                SpeakTextButton(
                  profile: profile,
                  text: word.meaning,
                  lang: SpeechLang.ja,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            word.meaning.isEmpty ? '訳がまだ入力されていません。' : word.meaning,
            style: AppText.body(
              color: word.meaning.isEmpty ? AppColors.ink3 : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// 例文カード（[Docs/03_data_model.md] §2.4「表示」）。
///
/// 単語詳細は**全件**を表示順に並べ、どの単語帳の例文かを添える。
/// 例文が0件の語ではカードごと出さない（空のカードを置かない）。
class _ExamplesCard extends ConsumerWidget {
  final Word word;
  final Profile profile;
  final double gap;

  const _ExamplesCard({
    required this.word,
    required this.profile,
    required this.gap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examples = ref.watch(wordExamplesProvider(word.id)).value;
    if (examples == null || examples.isEmpty) return const SizedBox.shrink();
    final books = ref.watch(wordbooksByPresetIdProvider).value ?? const {};

    return Padding(
      padding: EdgeInsets.only(top: gap),
      child: SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('例文', style: AppText.sectionTitle()),
            for (var i = 0; i < examples.length; i++)
              _ExampleRow(
                example: examples[i],
                profile: profile,
                // 出どころの単語帳が端末から消えていることもある。
                // その場合は名前を出さず、無いものを推測で埋めない。
                sourceLabel: _sourceLabelOf(examples[i], books),
                topPadding: i == 0 ? 6 : 12,
              ),
          ],
        ),
      ),
    );
  }

  static String? _sourceLabelOf(
    WordExample example,
    Map<String, Wordbook> books,
  ) {
    final source = example.sourcePresetId;
    // ユーザーが書いた文は `sourcePresetId` が null。
    if (source == null) return '自分で書いた文';
    final book = books[source];
    return book == null ? null : '${book.emoji} ${book.name}';
  }
}

class _ExampleRow extends StatelessWidget {
  final WordExample example;
  final Profile profile;
  final String? sourceLabel;
  final double topPadding;

  const _ExampleRow({
    required this.example,
    required this.profile,
    required this.sourceLabel,
    required this.topPadding,
  });

  @override
  Widget build(BuildContext context) {
    final label = sourceLabel;
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: label == null
                    ? const SizedBox.shrink()
                    : Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.caption(color: AppColors.ink3),
                      ),
              ),
              // 例文は常に合成音声で読む（音声ファイルを持たせない）。
              SpeakTextButton(
                profile: profile,
                text: example.exampleEn,
                lang: SpeechLang.en,
              ),
            ],
          ),
          Text(example.exampleEn, style: AppText.body()),
          // 和訳を書いていない「出会った文」もある（[my_words.md] §4.1）。
          // 無い和訳は null（[Docs/03_data_model.md] §2.4）。
          if (example.exampleJa != null) ...[
            const SizedBox(height: 4),
            Text(example.exampleJa!, style: AppText.caption()),
          ],
        ],
      ),
    );
  }
}

/// 学習状態カード。行が無い語では 0 の羅列を並べず、1行だけを出す
/// （[Docs/06_features/dictionary.md] §2）。
class _ReviewCard extends StatelessWidget {
  final WordReview? review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final r = review;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('学習状態', style: AppText.sectionTitle())),
              MasteryBadge(
                mastery: r == null
                    ? Mastery.unlearned
                    : Mastery.fromLevel(r.masteryLevel),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (r == null)
            Text('まだ学習していません。', style: AppText.body(color: AppColors.ink2))
          else ...[
            _row('次回の出題', DateFormat('yyyy/MM/dd').format(r.dueAt)),
            _row('通算', '正解 ${r.totalCorrect}回 ・ 不正解 ${r.totalIncorrect}回'),
            _row('連続正解', '${r.correctStreak}回'),
            if (r.totalCorrect + r.totalIncorrect > 0)
              _row(
                '正解率',
                '${(r.totalCorrect * 100 / (r.totalCorrect + r.totalIncorrect)).round()}%',
              ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(top: 2),
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.body(),
          ),
        ),
      ],
    ),
  );
}

class _ActionsCard extends ConsumerWidget {
  final Word word;
  final Profile profile;

  const _ActionsCard({required this.word, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('この単語', style: AppText.sectionTitle()),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () =>
                showUpsertWordSheet(context, profile: profile, editing: word),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('編集'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => ref
                .read(wordRepositoryProvider)
                .setExcluded(word.id, excluded: !word.isExcluded),
            icon: Icon(
              word.isExcluded ? Icons.visibility_outlined : Icons.block,
              size: 18,
            ),
            label: Text(word.isExcluded ? '除外を解除する' : '出題から除外する'),
          ),
          // プリセット語を編集済みのときだけ「元に戻す」を出す（FR-06）。
          if (word.isEdited && word.presetId != null) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _restore(context, ref),
              icon: const Icon(Icons.restore, size: 18),
              label: const Text('編集前に戻す'),
            ),
          ],
          const SizedBox(height: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accentDeep,
            ),
            onPressed: () => _delete(context, ref),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('削除'),
          ),
        ],
      ),
    );
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final preset = await ref
        .read(seedImporterProvider)
        .findPresetWord(word.presetId!);
    if (!context.mounted) return;
    if (preset == null) {
      // プリセットの改版で語が消えた場合。推測で埋めず、できないことを示す。
      await showCannotDelete(
        context,
        title: '元に戻せません',
        message: 'この語は同梱の単語帳から外れているため、編集前の内容を引き直せません。',
      );
      return;
    }
    await ref
        .read(wordRepositoryProvider)
        .restorePreset(
          word.id,
          headword: preset.headword,
          partOfSpeech: preset.partOfSpeech,
          meaning: preset.meaning,
          phonetic: preset.phonetic,
          level: preset.level,
        );
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('編集前の内容に戻しました')));
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await confirmDestructive(
      context,
      title: '単語を削除',
      message:
          '「${word.headword}」を削除します。'
          'すべての学習者の学習状態と解答履歴、所属している単語帳からの登録も一緒に消えます。',
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(wordRepositoryProvider).delete(word.id);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('削除に失敗しました: $e')));
      return;
    }
    if (context.mounted) Navigator.of(context).pop();
  }
}

/// 語のつくりカード（[Docs/06_features/word_parts.md] §3）。
/// 紐付けが1つも無い語では、このカードを出さない。
class _WordPartsCard extends ConsumerWidget {
  final Word word;
  final Profile profile;
  final double gap;

  const _WordPartsCard({
    required this.word,
    required this.profile,
    required this.gap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parts = ref.watch(wordPartsProvider(word.id)).value;
    if (parts == null || parts.isEmpty) return const SizedBox.shrink();
    final breakdown = ref.watch(wordBreakdownProvider(word.id)).value;

    return Padding(
      padding: EdgeInsets.only(top: gap),
      child: SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('語のつくり', style: AppText.sectionTitle()),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final part in parts)
                  InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            WordPartDetailScreen(part: part, profile: profile),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentSoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${part.form}（${part.meaning}）',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.caption(color: AppColors.ink2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // 説明文は書かれている語にだけ出す。**機械生成しない**。
            Text(word.partsNote ?? breakdown ?? '', style: AppText.body()),
          ],
        ),
      ),
    );
  }
}

/// 語族カード（[Docs/06_features/word_families.md] §3）。
/// 語族に自分しかいない場合はカードを出さない。
class _WordFamilyCard extends ConsumerWidget {
  final Word word;
  final Profile profile;
  final double gap;

  const _WordFamilyCard({
    required this.word,
    required this.profile,
    required this.gap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref
        .watch(wordFamilyProvider((wordId: word.id, profileId: profile.id)))
        .value;
    if (members == null || members.length < 2) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: gap),
      child: SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('語族', style: AppText.sectionTitle()),
            const SizedBox(height: 8),
            for (final m in members)
              Container(
                // 現在の語を淡いアクセントで示す。
                color: m.wordId == word.id ? AppColors.accentSoft : null,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: InkWell(
                  onTap: m.wordId == word.id
                      ? null
                      : () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => WordDetailScreen(
                              wordId: m.wordId,
                              profile: profile,
                            ),
                          ),
                        ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 52,
                        child: Text(
                          m.partOfSpeech.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.caption(),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          m.headword,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.body(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          m.meaning,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: AppText.caption(),
                        ),
                      ),
                      const SizedBox(width: 6),
                      MasteryBadge(mastery: m.mastery),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color background;

  const _Pill({required this.label, required this.background});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppText.caption(color: AppColors.ink2),
      ),
    );
  }
}

/// 所属単語帳のピル（[Docs/05_design_system.md] §3.2）。`Wrap` で折り返す。
class _WordbookChip extends StatelessWidget {
  final Wordbook wordbook;
  final VoidCallback onTap;

  const _WordbookChip({required this.wordbook, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        constraints: const BoxConstraints(maxWidth: 220),
        decoration: BoxDecoration(
          color: AppColors.seedColor(
            wordbook.colorSeed,
          ).withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              wordbook.emoji,
              textScaler: TextScaler.noScaling,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                wordbook.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.caption(color: AppColors.ink2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
