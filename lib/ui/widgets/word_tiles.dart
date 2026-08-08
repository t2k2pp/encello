import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/repositories/word_repository.dart';
import 'mastery_badge.dart';
import 'soft_card.dart';
import 'word_thumb.dart';

/// 語の状態を示す小さなバッジ（下書き・除外中・編集済み）。
/// 状態が無ければ何も描かない。
class _StateChips extends StatelessWidget {
  final DictionaryEntry entry;

  const _StateChips({required this.entry});

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      if (entry.word.isDraft)
        _chip('下書き', AppColors.accentSoft, AppColors.ink2),
      if (entry.word.isExcluded) _chip('除外中', AppColors.chipBg, AppColors.ink3),
      if (entry.word.isEdited) _chip('編集済み', AppColors.chipBg, AppColors.ink2),
    ];
    if (chips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Wrap(spacing: 4, runSpacing: 2, children: chips),
    );
  }

  Widget _chip(String label, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppText.caption(color: fg),
    ),
  );
}

/// 辞書・単語帳の中身のリスト行（[Docs/06_features/dictionary.md] §1.4）。
class WordListTile extends StatelessWidget {
  final DictionaryEntry entry;
  final VoidCallback onTap;

  /// 行の右端に置く追加の操作（単語帳の中身では「この単語帳から外す」）。
  final Widget? trailing;

  const WordListTile({
    super.key,
    required this.entry,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final word = entry.word;
    final subtitle = [
      entry.partOfSpeech.label,
      if (word.phonetic != null) word.phonetic!,
    ].join(' ・ ');

    return SoftCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          WordThumb(
            headword: word.headword,
            colorSeed: entry.wordbookColorSeed,
            mastery: entry.mastery,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word.headword,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.style(size: 15, weight: FontWeight.w700),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption(),
                ),
                _StateChips(entry: entry),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  word.meaning.isEmpty ? '（訳が未入力）' : word.meaning,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: AppText.body(
                    color: word.meaning.isEmpty ? AppColors.ink3 : null,
                  ),
                ),
                const SizedBox(height: 4),
                MasteryBadge(mastery: entry.mastery),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// 辞書・単語帳の中身のグリッドタイル（[Docs/06_features/dictionary.md] §1.4）。
class WordGridTile extends StatelessWidget {
  final DictionaryEntry entry;
  final VoidCallback onTap;

  const WordGridTile({super.key, required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final word = entry.word;
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 長い見出し語（internationalization 等）でも1行に収める。
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              word.headword,
              maxLines: 1,
              style: AppText.style(size: 18, weight: FontWeight.w700),
            ),
          ),
          Text(
            entry.partOfSpeech.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.caption(),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              word.meaning.isEmpty ? '（訳が未入力）' : word.meaning,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppText.body(
                color: word.meaning.isEmpty ? AppColors.ink3 : null,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(child: _StateChips(entry: entry)),
              MasteryDot(mastery: entry.mastery),
            ],
          ),
        ],
      ),
    );
  }
}
