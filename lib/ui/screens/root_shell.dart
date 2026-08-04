import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/database/app_database.dart';
import '../../providers/providers.dart';
import '../../providers/stats.dart';
import '../dialogs/quick_add_word_sheet.dart';
import '../dialogs/start_study_sheet.dart';
import '../widgets/centered_content.dart';
import 'dictionary_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

/// シェル（[Docs/04_screens_and_flows.md] §1）。
///
/// `NavigationBar` の4タブ（最後は設定）。画面幅 840px 以上では `NavigationRail`
/// に切り替える。共通 FAB は「学習をはじめる」。
///
/// 現在の学習者はルート（`app.dart`）から受け取り、各タブへ明示的に渡す
/// （[Docs/02_architecture.md] §1.2）。
class RootShell extends ConsumerStatefulWidget {
  /// 現在の学習者。
  final Profile profile;

  const RootShell({super.key, required this.profile});

  @override
  ConsumerState<RootShell> createState() => _RootShellState();
}

class _RootShellState extends ConsumerState<RootShell> {
  Profile get profile => widget.profile;

  @override
  void initState() {
    super.initState();
    // アプリを開いたとき（学習者の切り替えを含む）にリマインダーを作り直す。
    // 通知本文には件数が入るため、内容は予約時点の見込みになる
    // （[Docs/06_features/reminders.md] §3.1）。
    WidgetsBinding.instance.addPostFrameCallback((_) => _rescheduleReminders());
  }

  Future<void> _rescheduleReminders() async {
    try {
      await ref
          .read(reminderSchedulerProvider)
          .reschedule(profile, now: ref.read(clockProvider)());
    } catch (e) {
      // 予約に失敗したことは伏せない（鳴らないまま ON に見せかけない）。
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('学習リマインダーの予約に失敗しました: $e')),
      );
    }
  }

  static const _destinations = <_ShellDestination>[
    _ShellDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'ホーム',
    ),
    _ShellDestination(
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book,
      label: '辞書',
    ),
    _ShellDestination(
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights,
      label: '統計',
    ),
    _ShellDestination(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: '設定',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(rootTabIndexProvider);
    final wide = MediaQuery.sizeOf(context).width >= 840;
    // 出題できる語が1語も無いうちは学習を始められないため、FAB を出さない
    // （押せるのに始まらないボタンを置かない。[STYLE_GUIDE §0-4]）。
    final studyable =
        ref.watch(studyableWordCountProvider(profile)).value ?? 0;
    // 期限到来の復習がある間は件数をバッジで出す（[Docs/04_screens_and_flows.md] §1）。
    final due = ref.watch(dueCountProvider(profile)).value ?? 0;

    final body = SafeArea(
      child: CenteredContent(
        child: IndexedStack(
          index: index,
          children: [
            HomeScreen(profile: profile),
            DictionaryScreen(profile: profile),
            StatsScreen(profile: profile),
            SettingsScreen(profile: profile),
          ],
        ),
      ),
    );

    return Scaffold(
      body: wide
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: index,
                  onDestinationSelected: (i) =>
                      ref.read(rootTabIndexProvider.notifier).state = i,
                  backgroundColor: AppColors.card,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final d in _destinations)
                      NavigationRailDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selectedIcon),
                        label: Text(d.label),
                      ),
                  ],
                ),
                Expanded(child: body),
              ],
            )
          : body,
      // 長押しでクイック登録（マイ単語）を開く（[Docs/06_features/my_words.md] §4.1）。
      floatingActionButton: studyable == 0
          ? null
          : GestureDetector(
              onLongPress: () =>
                  showQuickAddWordSheet(context, profile: profile),
              child: FloatingActionButton.extended(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                onPressed: () =>
                    showStartStudySheet(context, profile: profile),
                icon: Badge(
                  isLabelVisible: due > 0,
                  label: Text('$due'),
                  child: const Icon(Icons.play_arrow),
                ),
                label: const Text('学習をはじめる'),
              ),
            ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (i) =>
                  ref.read(rootTabIndexProvider.notifier).state = i,
              backgroundColor: AppColors.card,
              indicatorColor: AppColors.accentSoft,
              destinations: [
                for (final d in _destinations)
                  NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: d.label,
                  ),
              ],
            ),
    );
  }

}

class _ShellDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _ShellDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
