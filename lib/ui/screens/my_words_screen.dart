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
import '../dialogs/quick_add_word_sheet.dart';
import '../widgets/centered_content.dart';
import '../widgets/empty_state.dart';
import '../widgets/search_field.dart';
import '../widgets/soft_dropdown.dart';
import '../widgets/word_list_body.dart';
import 'word_detail_screen.dart';
import 'write_meaning_screen.dart';

/// SCR-17 マイ単語（[Docs/04_screens_and_flows.md] §4.17、
/// [Docs/06_features/my_words.md] §5）。
///
/// 辞書と同じ一覧の型（[STYLE_GUIDE §3]）を流用する。単語帳フィルタは
/// `WordbookFilter.myWords` に固定し、フィルタは「習熟度」「下書きのみ」の2つ。
///
/// 一括操作（まとめて学習対象にする／まとめて削除）は**このバージョンのスコープ外**
/// （[Docs/06_features/my_words.md] §5 に理由を記載）。実装しない。
class MyWordsScreen extends ConsumerStatefulWidget {
  final Profile profile;

  /// ホームの下書きカードから開いたときは true（下書きのみで絞った状態で開く）。
  final bool initialDraftOnly;

  const MyWordsScreen({
    super.key,
    required this.profile,
    this.initialDraftOnly = false,
  });

  @override
  ConsumerState<MyWordsScreen> createState() => _MyWordsScreenState();
}

class _MyWordsScreenState extends ConsumerState<MyWordsScreen> {
  late DictionaryQuery _query = DictionaryQuery(
    profileId: widget.profile.id,
    wordbook: WordbookFilter.myWords,
  );

  /// 「下書きのみ」トグル。ON のときは [_mastery] の選択に関わらず
  /// `MasteryFilter.draft` で絞る（習熟度と下書きは別の軸として見せる）。
  bool _draftOnly = false;
  ListViewMode _viewMode = ListViewMode.list;
  int? _gridColumns;

  @override
  void initState() {
    super.initState();
    _draftOnly = widget.initialDraftOnly;
  }

  /// 実際にクエリへ渡す習熟度（下書きのみ ON のときは強制的に draft）。
  DictionaryQuery get _effectiveQuery => _query.copyWith(
    mastery: _draftOnly ? MasteryFilter.draft : _query.mastery,
  );

  bool get _filterActive =>
      _query.search.isNotEmpty ||
      _query.mastery != MasteryFilter.all ||
      _draftOnly;

  void _reset() {
    setState(() {
      _draftOnly = false;
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
    final counts = ref.watch(dictionaryCountsProvider(_effectiveQuery)).value;
    final draftCount =
        ref.watch(myWordsDraftCountProvider(widget.profile.id)).value ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('マイ単語')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        tooltip: '単語を追加',
        onPressed: () =>
            showQuickAddWordSheet(context, profile: widget.profile),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      // 下書きが1語以上あるときだけ「訳を書く」を出す（[Docs/06_features/my_words.md] §5）。
      // `bottomNavigationBar` に置くと Scaffold が FAB との重なりを避けて配置してくれる。
      bottomNavigationBar: draftCount == 0
          ? null
          : SafeArea(
              child: Padding(
                padding: spacing.screenPadding.copyWith(top: 8),
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          WriteMeaningScreen(profile: widget.profile),
                    ),
                  ),
                  icon: const Icon(Icons.edit_note),
                  label: Text(
                    '訳を書く（$draftCount語）',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
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
                  Row(
                    children: [
                      Expanded(
                        child: SoftDropdown<MasteryFilter>(
                          value: _query.mastery,
                          hint: '習熟度: すべて',
                          items: [
                            for (final m in MasteryFilter.values)
                              if (m != MasteryFilter.draft)
                                (value: m, label: '習熟度: ${m.label}'),
                          ],
                          onChanged: (m) => setState(
                            () => _query = _query.copyWith(mastery: m),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SoftDropdown<bool>(
                          value: _draftOnly,
                          hint: '下書き: すべて',
                          items: const [
                            (value: false, label: '下書き: すべて'),
                            (value: true, label: '下書き: 下書きのみ'),
                          ],
                          onChanged: (v) => setState(() => _draftOnly = v),
                        ),
                      ),
                    ],
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
                query: _effectiveQuery,
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
                emptyState: EmptyState(
                  emoji: '📝',
                  message: 'まだマイ単語がありません',
                  subMessage: '見出し語だけでも登録できます。訳はあとから書けます。',
                  actionLabel: '単語を追加',
                  onAction: () =>
                      showQuickAddWordSheet(context, profile: widget.profile),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
