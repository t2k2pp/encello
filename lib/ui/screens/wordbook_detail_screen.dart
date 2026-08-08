import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/enums.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/word_repository.dart';
import '../../providers/dictionary_listing.dart';
import '../../providers/providers.dart';
import '../dialogs/confirm_dialog.dart';
import '../dialogs/upsert_word_sheet.dart';
import '../widgets/centered_content.dart';
import '../widgets/empty_state.dart';
import '../widgets/search_field.dart';
import '../widgets/soft_dropdown.dart';
import '../widgets/word_list_body.dart';
import 'word_detail_screen.dart';

/// SCR-13 単語帳の中身（[Docs/04_screens_and_flows.md] §4.11）。
///
/// 辞書と同じ一覧の型を使う。フィルタは「習熟度」のみ（単語帳はこの1冊に固定）。
class WordbookDetailScreen extends ConsumerStatefulWidget {
  final int wordbookId;
  final Profile profile;

  const WordbookDetailScreen({
    super.key,
    required this.wordbookId,
    required this.profile,
  });

  @override
  ConsumerState<WordbookDetailScreen> createState() =>
      _WordbookDetailScreenState();
}

class _WordbookDetailScreenState extends ConsumerState<WordbookDetailScreen> {
  late DictionaryQuery _query = DictionaryQuery(
    profileId: widget.profile.id,
    wordbook: WordbookFilter.book(widget.wordbookId),
  );
  ListViewMode _viewMode = ListViewMode.list;
  int? _gridColumns;

  bool get _filterActive =>
      _query.search.isNotEmpty || _query.mastery != MasteryFilter.all;

  void _reset() {
    setState(() {
      _query = _query.copyWith(
        search: '',
        mastery: MasteryFilter.all,
        sort: DictionarySort.headword,
        ascending: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final book = ref
        .watch(wordbooksProvider(widget.profile.id))
        .value
        ?.where((b) => b.wordbook.id == widget.wordbookId)
        .firstOrNull;
    final counts = ref.watch(dictionaryCountsProvider(_query)).value;

    return Scaffold(
      appBar: AppBar(title: Text(book?.wordbook.name ?? '単語帳')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        tooltip: '単語を追加',
        onPressed: () => showUpsertWordSheet(
          context,
          profile: widget.profile,
          wordbookId: widget.wordbookId,
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: CenteredContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.screenPadding.left,
                8,
                spacing.screenPadding.right,
                4,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      counts == null
                          ? ' '
                          : '${counts.total}語 ・ 学習中 ${counts.learning}語',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.caption(),
                    ),
                  ),
                  IconButton(
                    tooltip: _viewMode == ListViewMode.grid
                        ? 'リスト表示'
                        : 'グリッド表示',
                    onPressed: () => setState(() {
                      _viewMode = _viewMode == ListViewMode.list
                          ? ListViewMode.grid
                          : ListViewMode.list;
                    }),
                    icon: Icon(
                      _viewMode == ListViewMode.grid
                          ? Icons.view_list
                          : Icons.grid_view,
                    ),
                  ),
                  if (_viewMode == ListViewMode.grid)
                    PopupMenuButton<int>(
                      tooltip: '列数',
                      icon: const Icon(Icons.view_column),
                      onSelected: (n) =>
                          setState(() => _gridColumns = n == 0 ? null : n),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 0, child: Text('自動')),
                        PopupMenuItem(value: 2, child: Text('2列')),
                        PopupMenuItem(value: 3, child: Text('3列')),
                        PopupMenuItem(value: 4, child: Text('4列')),
                      ],
                    ),
                  if (_filterActive)
                    IconButton(
                      tooltip: '絞り込みをリセット',
                      onPressed: _reset,
                      icon: const Icon(Icons.filter_alt_off),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.screenPadding.left,
              ),
              child: SearchField(
                value: _query.search,
                hintText: '英単語・日本語で検索',
                onChanged: (v) =>
                    setState(() => _query = _query.copyWith(search: v)),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.screenPadding.left,
              ),
              child: Column(
                children: [
                  SoftDropdown<MasteryFilter>(
                    value: _query.mastery,
                    hint: '習熟度: すべて',
                    items: [
                      for (final m in MasteryFilter.values)
                        (value: m, label: '習熟度: ${m.label}'),
                    ],
                    onChanged: (m) =>
                        setState(() => _query = _query.copyWith(mastery: m)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: SoftDropdown<DictionarySort>(
                          value: _query.sort,
                          hint: '並び替え',
                          items: [
                            for (final s in DictionarySort.values)
                              (value: s, label: s.label),
                          ],
                          onChanged: (s) =>
                              setState(() => _query = _query.copyWith(sort: s)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SortDirectionToggle(
                        ascending: _query.ascending,
                        onChanged: (v) => setState(
                          () => _query = _query.copyWith(ascending: v),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: WordListBody(
                query: _query,
                viewMode: _viewMode,
                gridColumns: _gridColumns,
                filterActive: _filterActive,
                onClearFilters: _reset,
                onTapWord: (entry) => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => WordDetailScreen(
                      wordId: entry.word.id,
                      profile: widget.profile,
                    ),
                  ),
                ),
                trailingBuilder: (entry) => IconButton(
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: AppColors.ink3,
                  ),
                  tooltip: 'この単語帳から外す',
                  onPressed: () => _remove(entry),
                ),
                emptyState: const EmptyState(
                  emoji: '📖',
                  message: 'この単語帳にはまだ単語がありません',
                  subMessage: '右下の＋から単語を追加できます。',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _remove(DictionaryEntry entry) async {
    final ok = await confirmDestructive(
      context,
      title: 'この単語帳から外す',
      message:
          '「${entry.word.headword}」をこの単語帳から外します。'
          '単語そのものと学習の記録は残り、他の単語帳での扱いも変わりません。',
      confirmLabel: '外す',
    );
    if (!ok || !mounted) return;
    await ref
        .read(wordbookRepositoryProvider)
        .removeWord(widget.wordbookId, entry.word.id);
  }
}
