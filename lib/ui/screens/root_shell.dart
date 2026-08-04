import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/database/app_database.dart';
import '../../providers/providers.dart';
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
class RootShell extends ConsumerWidget {
  /// 現在の学習者。
  final Profile profile;

  const RootShell({super.key, required this.profile});

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
  Widget build(BuildContext context, WidgetRef ref) {
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
            const StatsScreen(),
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
      floatingActionButton: studyable == 0
          ? null
          : FloatingActionButton.extended(
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
