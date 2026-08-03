import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/database/app_database.dart';
import '../../providers/providers.dart';
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
      // 共通 FAB「学習をはじめる」はモード選択シート（SCR-02）と対で入れる。
      // 押しても何も始まらないボタンは置かない（[STYLE_GUIDE §0-4]）。
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
