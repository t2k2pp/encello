import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../data/repositories/profile_repository.dart';
import '../../providers/providers.dart';
import '../dialogs/upsert_profile_sheet.dart';
import '../widgets/centered_content.dart';
import '../widgets/empty_state.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/soft_card.dart';

/// SCR-00 プロファイルゲート（[Docs/04_screens_and_flows.md] §4.12）。
///
/// 学習者が0人なら作成を促し、1人ならそのまま開始する（余計な操作を挟まない）。
/// 2人以上のときだけ「だれが学習する？」を出す。PIN・パスワードは設けない
/// （[Docs/06_features/profiles.md] §4）。
class ProfileGateScreen extends ConsumerStatefulWidget {
  const ProfileGateScreen({super.key});

  @override
  ConsumerState<ProfileGateScreen> createState() => _ProfileGateScreenState();
}

class _ProfileGateScreenState extends ConsumerState<ProfileGateScreen> {
  /// 1人だけのときの自動選択を1回に留めるためのガード。
  bool _autoSelected = false;

  void _select(ProfileOverview overview) {
    ref.read(activeProfileProvider.notifier).select(overview.profile);
  }

  Future<void> _add() async {
    final created = await showUpsertProfileSheet(context);
    if (created == null || !mounted) return;
    // 作った直後はその人で始める（選び直させない）。
    ref.read(activeProfileProvider.notifier).select(created);
  }

  /// 前回使った人を先頭に置く（[Docs/04_screens_and_flows.md] §4.12）。
  List<ProfileOverview> _ordered(List<ProfileOverview> all, int? lastId) {
    if (lastId == null) return all;
    final index = all.indexWhere((o) => o.profile.id == lastId);
    if (index <= 0) return all;
    return [all[index], ...all.where((o) => o.profile.id != lastId)];
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(profileOverviewsProvider);
    final lastId = ref.watch(lastActiveProfileIdProvider);

    return Scaffold(
      body: SafeArea(
        child: CenteredContent(
          child: async.when(
            // 初回ロード中に「学習者がいません」をフラッシュさせない（[STYLE_GUIDE §3.7]）。
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => EmptyState(
              emoji: '⚠️',
              message: '学習者を読み込めませんでした',
              subMessage: '$e',
            ),
            data: (all) {
              if (all.isEmpty) return _buildFirstRun(context);

              if (all.length == 1) {
                // 1人なら選択画面を出さずそのまま開始する。build 中に状態を
                // 変えないよう、フレーム後に選ぶ。
                if (!_autoSelected) {
                  _autoSelected = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _select(all.first);
                  });
                }
                return const Center(child: CircularProgressIndicator());
              }

              return _buildChooser(context, _ordered(all, lastId), lastId);
            },
          ),
        ),
      ),
    );
  }

  /// 学習者が1人もいないとき（初回起動）。
  Widget _buildFirstRun(BuildContext context) {
    return EmptyState(
      emoji: '📖',
      message: 'encello へようこそ',
      subMessage: 'まず学習者を登録します。1台の端末を家族で使うときは、あとから何人でも追加できます。',
      actionLabel: '学習者を登録する',
      onAction: _add,
    );
  }

  /// 学習者が2人以上のとき。
  Widget _buildChooser(
    BuildContext context,
    List<ProfileOverview> ordered,
    int? lastId,
  ) {
    final spacing = AppSpacing.of(context);
    return ListView(
      padding: spacing.screenPadding.copyWith(top: 32, bottom: 32),
      children: [
        Text('だれが学習しますか？', style: AppText.title()),
        const SizedBox(height: 20),
        for (final o in ordered) ...[
          _ProfileCard(
            overview: o,
            isLastActive: o.profile.id == lastId,
            onTap: () => _select(o),
          ),
          SizedBox(height: spacing.gap + 4),
        ],
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _add,
          icon: const Icon(Icons.person_add_alt, size: 18),
          label: const Text('学習者を追加'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      ],
    );
  }
}

/// ゲートに並べる学習者カード。誰の番かの手がかりとして、その人のストリークと
/// 今日の進捗を小さく添える。
class _ProfileCard extends StatelessWidget {
  final ProfileOverview overview;
  final bool isLastActive;
  final VoidCallback onTap;

  const _ProfileCard({
    required this.overview,
    required this.isLastActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = overview.profile;
    final s = overview.summary;
    final streak = overview.streak.current;
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ProfileAvatar(emoji: p.emoji, colorSeed: p.colorSeed, size: 72),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLastActive) ...[
                  Text('前回', style: AppText.caption()),
                  const SizedBox(height: 2),
                ],
                Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.sectionTitle(),
                ),
                const SizedBox(height: 4),
                Text(
                  // ストリークが 0 のときは炎を出さない（灰色の炎で「失っている」
                  // ことを強調しない。[Docs/06_features/gamification.md] §2）。
                  streak > 0
                      ? '🔥 $streak日 ・ 今日 ${s.todayAnswered} / ${s.todayGoal} 問'
                      : '今日 ${s.todayAnswered} / ${s.todayGoal} 問',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption(),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.ink3),
        ],
      ),
    );
  }
}
