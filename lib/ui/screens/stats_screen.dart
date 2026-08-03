import 'package:flutter/material.dart';

import '../widgets/empty_state.dart';

/// SCR-10 統計（[Docs/04_screens_and_flows.md] §4.9）。
///
/// 習熟度内訳・学習量推移・苦手単語などは、学習の記録が生まれる段階で実装する。
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      emoji: '📊',
      message: 'まだ学習の記録がありません',
      subMessage: '学習を始めると、習熟度の内訳や学習量の推移がここに出ます。',
    );
  }
}
