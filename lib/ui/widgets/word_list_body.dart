import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/enums.dart';
import '../../data/repositories/word_repository.dart';
import '../../providers/dictionary_listing.dart';
import 'empty_state.dart';
import 'word_tiles.dart';

/// 辞書（SCR-08）と単語帳の中身（SCR-13）で共通の本文
/// （[STYLE_GUIDE §3.6]、[Docs/06_features/dictionary.md] §1.4）。
///
/// リストとグリッドの両方を実装し、グリッドの列数は 自動/2/3/4 から選ぶ。
/// 遅延構築（`ListView.builder` / `GridView.builder`）で1万語でも詰まらせない（NFR-02）。
class WordListBody extends ConsumerWidget {
  final DictionaryQuery query;
  final ListViewMode viewMode;

  /// null = 自動（最小タイル幅 200 基準）。
  final int? gridColumns;
  final ValueChanged<DictionaryEntry> onTapWord;

  /// 行の右端に置く追加操作（単語帳の中身の「外す」）。
  final Widget Function(DictionaryEntry entry)? trailingBuilder;

  /// 絞り込みが効いているか。空状態を「未登録」と「該当ゼロ件」で分けるために使う。
  final bool filterActive;
  final VoidCallback? onClearFilters;

  /// 1語も無いとき（絞り込みなし）に出す空状態。
  final Widget emptyState;

  const WordListBody({
    super.key,
    required this.query,
    required this.viewMode,
    required this.gridColumns,
    required this.onTapWord,
    required this.filterActive,
    required this.emptyState,
    this.trailingBuilder,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dictionaryEntriesProvider(query));
    final spacing = AppSpacing.of(context);

    return async.when(
      // 初回ロード中に「まだありません」をフラッシュさせない（[STYLE_GUIDE §3.7]）。
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          EmptyState(emoji: '⚠️', message: '単語を読み込めませんでした', subMessage: '$e'),
      data: (entries) {
        if (entries.isEmpty) {
          if (!filterActive) return emptyState;
          return EmptyState(
            emoji: '🔍',
            message: '条件に一致する単語がありません',
            subMessage: '検索語・単語帳・習熟度の絞り込みを見直してください',
            actionLabel: onClearFilters == null ? null : '絞り込みを解除',
            onAction: onClearFilters,
          );
        }

        final padding = spacing.screenPadding.copyWith(top: 8, bottom: 96);
        if (viewMode == ListViewMode.list) {
          return ListView.separated(
            padding: padding,
            itemCount: entries.length,
            separatorBuilder: (_, _) => SizedBox(height: spacing.gap),
            itemBuilder: (_, i) => WordListTile(
              entry: entries[i],
              onTap: () => onTapWord(entries[i]),
              trailing: trailingBuilder?.call(entries[i]),
            ),
          );
        }

        // タイル高さは端末の文字拡大に追従させる（[STYLE_GUIDE §3.6]）。
        final scale = MediaQuery.textScalerOf(context).scale(1.0);
        final extent = 36 + 100 * scale;
        return GridView.builder(
          padding: padding,
          gridDelegate: gridColumns == null
              ? SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  mainAxisSpacing: spacing.gap,
                  crossAxisSpacing: spacing.gap,
                  mainAxisExtent: extent,
                )
              : SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridColumns!,
                  mainAxisSpacing: spacing.gap,
                  crossAxisSpacing: spacing.gap,
                  mainAxisExtent: extent,
                ),
          itemCount: entries.length,
          itemBuilder: (_, i) => WordGridTile(
            entry: entries[i],
            onTap: () => onTapWord(entries[i]),
          ),
        );
      },
    );
  }
}
