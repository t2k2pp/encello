import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/enums.dart';
import '../../core/utils/study_date.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/wordbook_repository.dart';
import '../../domain/usecases/study_queue_builder.dart';
import '../../providers/audio.dart';
import '../../providers/providers.dart';
import '../dialogs/start_study_sheet.dart';
import '../widgets/empty_state.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/progress_ring.dart';
import '../widgets/soft_card.dart';
import 'wordbooks_screen.dart';

/// SCR-01 ホーム（[Docs/04_screens_and_flows.md] §4.1）。
///
/// 学習対象の単語帳が1冊も選ばれていない間は、案内と単語帳選びへの導線だけを出す
/// （勝手にどれかを選んだことにしない。[Docs/06_features/wordbooks.md] §6）。
/// 今日のカード・モードカード・語彙力カードは、それぞれの機能が入った時点で足す。
class HomeScreen extends ConsumerWidget {
  /// 現在の学習者。
  final Profile profile;

  const HomeScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = AppSpacing.of(context);
    // 単語帳の選択は他画面からも変わるため、最新の学習者を見る。
    final current = ref.watch(activeProfileProvider) ?? profile;
    final selected = decodeIdList(current.selectedWordbookIds).toSet();
    final books = ref.watch(wordbooksProvider(current.id)).value;
    final studying = books
        ?.where((b) => selected.contains(b.wordbook.id))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: spacing.screenPadding.copyWith(bottom: 0),
          child: _HomeHeader(profile: current),
        ),
        Expanded(
          child: studying == null
              ? const Center(child: CircularProgressIndicator())
              : studying.isEmpty
              ? EmptyState(
                  emoji: '📚',
                  message: '学習する単語帳を選びましょう',
                  subMessage: '選んだ単語帳の語が、辞書と学習の対象になります。あとから何度でも変えられます。',
                  actionLabel: '自分で単語帳を選ぶ',
                  onAction: () => _openWordbooks(context, current),
                )
              : ListView(
                  padding: spacing.screenPadding.copyWith(bottom: 96),
                  children: [
                    _TodayCard(profile: current),
                    SizedBox(height: spacing.gap),
                    _ModeCards(profile: current),
                    SizedBox(height: spacing.gap),
                    _StudyTargetCard(
                      books: studying,
                      onEdit: () => _openWordbooks(context, current),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  void _openWordbooks(BuildContext context, Profile profile) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WordbooksScreen(profile: profile),
      ),
    );
  }
}

/// 今日のカード（[Docs/04_screens_and_flows.md] §4.1）。
/// 今日の進捗と、期限到来の復習件数から始められる導線を出す。
class _TodayCard extends ConsumerWidget {
  final Profile profile;

  const _TodayCard({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = studyDateOf(ref.watch(clockProvider)());
    final stats = ref.watch(dailyStatsProvider((profile: profile, studyDate: today))).value;
    final due = ref.watch(dueCountProvider(profile)).value ?? 0;
    final answered = stats?.answeredCount ?? 0;
    final goal = stats?.goalCount ?? profile.dailyGoal;

    return SoftCard(
      child: Column(
        children: [
          Row(
            children: [
              ProgressRing(
                value: goal == 0 ? 0 : answered / goal,
                size: 84,
                strokeWidth: 8,
                child: RingLabel(value: '$answered', caption: '/ $goal 問'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('今日の学習', style: AppText.sectionTitle()),
                    const SizedBox(height: 4),
                    Text(
                      due > 0 ? '復習の期限が来ている語が $due 語あります。' : '期限が来ている復習はありません。',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.caption(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: () => showStartStudySheet(
              context,
              profile: profile,
              // 復習が無いときは新規語から始める方が自然。
              initialPolicy: due > 0
                  ? QueuePolicy.reviewFirst
                  : QueuePolicy.newOnly,
            ),
            // 復習が 0 件でもボタンは消さず、文言を変える。
            child: Text(due > 0 ? '今日の復習 $due語をはじめる' : '新しい単語を学ぶ'),
          ),
        ],
      ),
    );
  }
}

/// モードカード（[Docs/04_screens_and_flows.md] §4.1）。
///
/// **利用できないモードはカードごと非表示**にする（[STYLE_GUIDE §0-4]）。
/// 学習を始めたばかりの人には少ししか出ず、進むにつれて増える。
/// 使えないモードを先に見せて期待させない。
class _ModeCards extends ConsumerWidget {
  final Profile profile;

  const _ModeCards({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modes = ref.watch(availableModesProvider(profile)).value;
    // 判明するまでは出さない（あとから消えるカードを見せない）。
    if (modes == null || modes.isEmpty) return const SizedBox.shrink();

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('学習モード', style: AppText.sectionTitle()),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final mode in modes)
                _ModeChip(
                  mode: mode,
                  onTap: () => showStartStudySheet(
                    context,
                    profile: profile,
                    initialMode: mode,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final StudyMode mode;
  final VoidCallback onTap;

  const _ModeChip({required this.mode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 96, maxWidth: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.chipBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              mode.emoji,
              textScaler: TextScaler.noScaling,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                mode.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.body(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 学習対象にしている単語帳のまとめ。
class _StudyTargetCard extends StatelessWidget {
  final List<WordbookWithCount> books;
  final VoidCallback onEdit;

  const _StudyTargetCard({required this.books, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final total = books.fold(0, (sum, b) => sum + b.wordCount);
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('学習する単語帳', style: AppText.sectionTitle())),
              TextButton(onPressed: onEdit, child: const Text('変更')),
            ],
          ),
          Text('${books.length}冊 ・ のべ$total語', style: AppText.caption()),
          const SizedBox(height: 8),
          for (final b in books)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Text(
                    b.wordbook.emoji,
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      b.wordbook.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body(),
                    ),
                  ),
                  Text('${b.wordCount}語', style: AppText.caption()),
                ],
              ),
            ),
        ],
      ),
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
