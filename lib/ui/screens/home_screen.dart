import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../data/database/app_database.dart';
import '../../providers/providers.dart';
import '../widgets/empty_state.dart';
import '../widgets/profile_avatar.dart';

/// SCR-01 ホーム（[Docs/04_screens_and_flows.md] §4.1）。
///
/// 現時点では単語帳が1冊も無いため、[EmptyState] だけを出す。
/// 今日のカード・モードカード・語彙力カードは、それぞれの機能が入った時点で足す。
class HomeScreen extends StatelessWidget {
  /// 現在の学習者。
  final Profile profile;

  const HomeScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: spacing.screenPadding.copyWith(bottom: 0),
          child: _HomeHeader(profile: profile),
        ),
        const Expanded(
          child: EmptyState(
            emoji: '📚',
            message: '学習する単語帳がありません',
            subMessage: '単語帳を入れると、ここに今日の進捗と学習モードが並びます。',
          ),
        ),
      ],
    );
  }
}

/// ホームの見出し行。右上に現在の学習者のアバターを置き、タップで切り替える
/// （学習者が1人だけのときも表示する。自分の色と絵文字が見えることに意味がある）。
class _HomeHeader extends ConsumerWidget {
  final Profile profile;

  const _HomeHeader({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ホーム',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.title(),
              ),
              Text(
                '${profile.name} さん',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.caption(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: '学習者を切り替える',
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => ref.read(activeProfileProvider.notifier).clear(),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: ProfileAvatar(
                emoji: profile.emoji,
                colorSeed: profile.colorSeed,
                selected: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
