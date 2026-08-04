import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/enums.dart';
import '../../data/database/app_database.dart';
import '../../domain/entities/mastery.dart';
import '../../providers/dictionary_listing.dart';
import '../widgets/centered_content.dart';
import '../widgets/empty_state.dart';
import '../widgets/mastery_badge.dart';
import '../widgets/soft_card.dart';
import 'word_detail_screen.dart';

/// SCR-16 語の部品の詳細（[Docs/06_features/word_parts.md] §4）。
class WordPartDetailScreen extends ConsumerWidget {
  final WordPart part;
  final Profile profile;

  const WordPartDetailScreen({
    super.key,
    required this.part,
    required this.profile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = AppSpacing.of(context);
    final async = ref.watch(
      wordsOfPartProvider((partId: part.id, profileId: profile.id)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('語のつくり')),
      body: CenteredContent(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => EmptyState(
            emoji: '⚠️',
            message: '読み込めませんでした',
            subMessage: '$e',
          ),
          data: (words) => ListView(
            padding: spacing.screenPadding.copyWith(bottom: 32),
            children: [
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              part.form,
                              maxLines: 1,
                              style: AppText.headword(),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.chipBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            WordPartType.fromValue(part.type).label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.caption(color: AppColors.ink2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(part.meaning, style: AppText.body()),
                    // 由来と補足は空を許す。無ければ行ごと出さない。
                    if (part.origin != null) ...[
                      const SizedBox(height: 4),
                      Text('由来: ${part.origin}', style: AppText.caption()),
                    ],
                    if (part.note != null) ...[
                      const SizedBox(height: 4),
                      Text(part.note!, style: AppText.caption()),
                    ],
                  ],
                ),
              ),
              SizedBox(height: spacing.gap),
              _WordsCard(words: words, profile: profile, form: part.form),
            ],
          ),
        ),
      ),
    );
  }
}

class _WordsCard extends ConsumerWidget {
  final List<({Word word, Mastery mastery})> words;
  final Profile profile;
  final String form;

  const _WordsCard({
    required this.words,
    required this.profile,
    required this.form,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final learned = words
        .where((w) => w.mastery != Mastery.unlearned)
        .length;
    // 未学習を上に並べる（次に埋めるべき穴が見える）。
    final ordered = [...words]
      ..sort((a, b) => a.mastery.level.compareTo(b.mastery.level));

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$form の仲間', style: AppText.sectionTitle()),
          const SizedBox(height: 2),
          Text(
            '${words.length}語のうち、$learned語を覚えています',
            style: AppText.caption(),
          ),
          const SizedBox(height: 8),
          for (final entry in ordered)
            InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => WordDetailScreen(
                    wordId: entry.word.id,
                    profile: profile,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.word.headword,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.style(
                          size: 15,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.word.meaning,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: AppText.caption(),
                      ),
                    ),
                    const SizedBox(width: 6),
                    MasteryBadge(mastery: entry.mastery),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
