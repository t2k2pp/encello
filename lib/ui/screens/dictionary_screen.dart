import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/enums.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/word_repository.dart';
import '../../data/repositories/wordbook_repository.dart';
import '../../providers/dictionary_listing.dart';
import '../../providers/providers.dart';
import '../dialogs/upsert_word_sheet.dart';
import '../widgets/empty_state.dart';
import '../widgets/search_field.dart';
import '../widgets/soft_dropdown.dart';
import '../widgets/word_list_body.dart';
import 'word_detail_screen.dart';
import 'wordbooks_screen.dart';

/// SCR-08 辞書（[STYLE_GUIDE §3] の一覧画面の型、
/// [Docs/06_features/dictionary.md]）。
///
/// 一覧に出るのは **共有の語 ＋ 自分のマイ単語**。習熟度は現在の学習者のもので、
/// 学習者を切り替えると同じ語の表示が変わる。
class DictionaryScreen extends ConsumerStatefulWidget {
  final Profile profile;

  const DictionaryScreen({super.key, required this.profile});

  @override
  ConsumerState<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends ConsumerState<DictionaryScreen> {
  /// 入力中の文字列（検索欄に出す値）。クエリへは [_debounce] 後に渡す。
  String _input = '';
  Timer? _debounce;

  late DictionaryQuery _query = DictionaryQuery(
    profileId: widget.profile.id,
    searchExamples: widget.profile.searchExamples,
    selectedWordbookIds: decodeIdList(widget.profile.selectedWordbookIds),
  );

  /// 現在の学習者。表示切替・列数はこの人の設定を読み書きする。
  /// **`ref.watch` した値を使う**（`read` では設定変更後に再描画されない）。
  Profile get _currentProfile =>
      ref.watch(activeProfileProvider) ?? widget.profile;

  ListViewMode get _viewMode =>
      ListViewMode.fromValue(_currentProfile.dictViewMode);

  int? get _gridColumns {
    final v = _currentProfile.dictGridColumns;
    return v == 'auto' ? null : int.parse(v);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// 検索欄の入力は 250ms デバウンスしてからクエリへ渡す
  /// （[Docs/06_features/dictionary.md] §1.5）。
  void _onSearchChanged(String value) {
    setState(() => _input = value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _query = _query.copyWith(search: value));
    });
  }

  bool get _filterActive =>
      _input.isNotEmpty ||
      _query.wordbook != WordbookFilter.all ||
      _query.mastery != MasteryFilter.all;

  void _reset() {
    _debounce?.cancel();
    setState(() {
      _input = '';
      _query = _query.copyWith(
        search: '',
        wordbook: WordbookFilter.all,
        mastery: MasteryFilter.all,
        sort: DictionarySort.headword,
        ascending: true,
      );
    });
  }

  /// 表示切替・列数は学習者ごとに永続化する（[STYLE_GUIDE §3.6]）。
  Future<void> _patchProfile(ProfilesCompanion patch) async {
    final id = ref.read(activeProfileProvider)?.id ?? widget.profile.id;
    await ref.read(profileRepositoryProvider).updateSettings(id, patch);
    await ref.read(activeProfileProvider.notifier).reload();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final books = ref.watch(wordbooksProvider(widget.profile.id)).value ?? const [];
    final counts = ref.watch(dictionaryCountsProvider(_query)).value;
    // 学習対象の選択が変わったら「学習対象のみ」の結果も追従させる。
    final selected = decodeIdList(_currentProfile.selectedWordbookIds);
    if (!_sameIds(selected, _query.selectedWordbookIds)) {
      _query = _query.copyWith(selectedWordbookIds: selected);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context, spacing, counts),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.screenPadding.left),
          child: SearchField(
            value: _input,
            hintText: '英単語・日本語で検索',
            onChanged: _onSearchChanged,
          ),
        ),
        const SizedBox(height: 8),
        _buildFilters(spacing, books),
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
            emptyState: EmptyState(
              emoji: '🔤',
              message: 'まだ単語がありません',
              subMessage: '単語帳を選ぶと、収録されている語がここに並びます。',
              actionLabel: '単語帳を選ぶ',
              onAction: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => WordbooksScreen(profile: widget.profile),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppSpacing spacing,
    DictionaryCounts? counts,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        spacing.screenPadding.left,
        12,
        spacing.screenPadding.right - 4,
        4,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '辞書',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.title(),
                ),
                Text(
                  counts == null
                      ? ' '
                      : '${counts.total}語 ・ 学習中 ${counts.learning}語',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption(),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: _viewMode == ListViewMode.grid ? 'リスト表示' : 'グリッド表示',
            onPressed: () => _patchProfile(
              ProfilesCompanion(
                dictViewMode: Value(
                  _viewMode == ListViewMode.list
                      ? ListViewMode.grid.value
                      : ListViewMode.list.value,
                ),
              ),
            ),
            icon: Icon(
              _viewMode == ListViewMode.grid ? Icons.view_list : Icons.grid_view,
            ),
          ),
          if (_viewMode == ListViewMode.grid)
            PopupMenuButton<int>(
              tooltip: '列数',
              icon: const Icon(Icons.view_column),
              onSelected: (n) => _patchProfile(
                ProfilesCompanion(
                  dictGridColumns: Value(n == 0 ? 'auto' : '$n'),
                ),
              ),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 0, child: Text('自動')),
                PopupMenuItem(value: 2, child: Text('2列')),
                PopupMenuItem(value: 3, child: Text('3列')),
                PopupMenuItem(value: 4, child: Text('4列')),
              ],
            ),
          // 条件が初期状態のときは出さない（出ている＝何か絞られているサイン）。
          if (_filterActive)
            IconButton(
              tooltip: '絞り込みをリセット',
              onPressed: _reset,
              icon: const Icon(Icons.filter_alt_off),
            ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onPressed: () =>
                showUpsertWordSheet(context, profile: widget.profile),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('単語'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(AppSpacing spacing, List<WordbookWithCount> books) {
    // 選択肢の並びは登録件数の多い順（[STYLE_GUIDE §3.3]）。
    final ordered = [...books]
      ..sort((a, b) => b.wordCount.compareTo(a.wordCount));
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.screenPadding.left),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SoftDropdown<WordbookFilter>(
                  value: _query.wordbook,
                  hint: '単語帳: すべて',
                  items: [
                    (value: WordbookFilter.all, label: '単語帳: すべて'),
                    (value: WordbookFilter.studyTarget, label: '単語帳: 学習対象のみ'),
                    (value: WordbookFilter.myWords, label: '単語帳: マイ単語'),
                    for (final b in ordered)
                      (
                        value: WordbookFilter.book(b.wordbook.id),
                        label: '${b.wordbook.emoji} ${b.wordbook.name}',
                      ),
                  ],
                  onChanged: (v) =>
                      setState(() => _query = _query.copyWith(wordbook: v)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SoftDropdown<MasteryFilter>(
                  value: _query.mastery,
                  hint: '習熟度: すべて',
                  items: [
                    for (final m in MasteryFilter.values)
                      (value: m, label: '習熟度: ${m.label}'),
                  ],
                  onChanged: (m) =>
                      setState(() => _query = _query.copyWith(mastery: m)),
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
                onChanged: (v) =>
                    setState(() => _query = _query.copyWith(ascending: v)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static bool _sameIds(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
