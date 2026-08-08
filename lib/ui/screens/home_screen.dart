import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// StateProvider は Riverpod 3 で legacy 扱い（語彙力カードの「閉じる」で使用）。
import 'package:flutter_riverpod/legacy.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/enums.dart';
import '../../core/utils/study_date.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/vocab_test_repository.dart';
import '../../data/repositories/wordbook_repository.dart';
import '../../domain/usecases/study_queue_builder.dart';
import '../../domain/usecases/vocab_size_estimator.dart';
import '../../providers/audio.dart';
import '../../providers/providers.dart';
import '../../providers/stats.dart';
import '../../providers/stats_aggregates.dart';
import '../dialogs/start_study_sheet.dart';
import '../widgets/empty_state.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/progress_ring.dart';
import '../widgets/soft_card.dart';
import '../widgets/streak_flame.dart';
import 'achievements_screen.dart';
import 'my_words_screen.dart';
import 'vocab_test_screen.dart';
import 'wordbooks_screen.dart';

/// 語彙力カードを閉じた学習者（起動中だけ覚える）。
///
/// 「測りませんか」の案内は断れる（[Docs/06_features/vocab_size_test.md] §6）。
/// 次に起動したときはまた出す。永続化するほどの設定ではない。
final dismissedVocabPromptProvider = StateProvider<Set<int>>((ref) => {});

/// 前回の測定からこの日数が経つと、ホームに測り直しの案内を出す。
const kVocabRemeasureDays = 30;

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
              ? _FirstRunBody(profile: current)
              : ListView(
                  padding: spacing.screenPadding.copyWith(bottom: 96),
                  children: [
                    _TodayCard(profile: current),
                    SizedBox(height: spacing.gap),
                    _ModeCards(profile: current),
                    SizedBox(height: spacing.gap),
                    _RecentScoreCard(profile: current),
                    SizedBox(height: spacing.gap),
                    _VocabPromptCard(profile: current),
                    _DraftCard(profile: current),
                    _NextAchievementCard(profile: current),
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

/// 初回起動（学習対象の単語帳が未選択）。
///
/// 勝手にどれかを選んだことにせず、測ってから選ぶ導線と、自分で選ぶ導線を並べる
/// （[Docs/04_screens_and_flows.md] §4.1）。
class _FirstRunBody extends ConsumerWidget {
  final Profile profile;

  const _FirstRunBody({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = AppSpacing.of(context);
    return ListView(
      padding: spacing.screenPadding.copyWith(bottom: 96),
      children: [
        const SizedBox(height: 24),
        const EmptyState(
          emoji: '📚',
          message: '学習する単語帳を選びましょう',
          subMessage: '選んだ単語帳の語が、辞書と学習の対象になります。あとから何度でも変えられます。',
        ),
        const SizedBox(height: 8),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accent,
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: () => openVocabTest(context, ref, profile: profile),
          child: const Text('語彙力を測ってレベルに合う単語帳を選ぶ'),
        ),
        SizedBox(height: spacing.gap),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => WordbooksScreen(profile: profile),
            ),
          ),
          child: const Text('自分で単語帳を選ぶ'),
        ),
      ],
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
    final stats = ref
        .watch(dailyStatsProvider((profile: profile, studyDate: today)))
        .value;
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '今日の学習',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.sectionTitle(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // ストリークが 0 のときは炎を出さない。
                        Flexible(
                          child: StreakFlame(
                            days: ref.watch(streakProvider(profile.id)).current,
                          ),
                        ),
                      ],
                    ),
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

/// 直近の成績カード（[Docs/04_screens_and_flows.md] §4.1）。
/// 直近7日の正解率と学習量。タップで統計タブへ。
class _RecentScoreCard extends ConsumerWidget {
  final Profile profile;

  const _RecentScoreCard({required this.profile});

  /// 集計する日数。
  static const days = 7;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dailyStatsHistoryProvider(profile.id)).value;
    // 判明するまでは出さない（あとから値が変わるカードを見せない）。
    if (stats == null) return const SizedBox.shrink();

    final today = studyDateOf(ref.watch(clockProvider)());
    final answered = StatsAggregates.recentAnswered(
      stats,
      today: today,
      days: days,
    );
    final accuracy = StatsAggregates.recentAccuracy(
      stats,
      today: today,
      days: days,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.of(context).gap),
      child: SoftCard(
        // 統計タブへ移す（画面を積まない）。
        onTap: () => ref.read(rootTabIndexProvider.notifier).state = 2,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('直近$days日の成績', style: AppText.sectionTitle()),
                  const SizedBox(height: 4),
                  Text(
                    answered == 0
                        ? 'この$days日はまだ解いていません。'
                        : '$answered問 ・ 正解率 ${((accuracy ?? 0) * 100).round()}%',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption(),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.ink3),
          ],
        ),
      ),
    );
  }
}

/// 語彙力カード（[Docs/04_screens_and_flows.md] §4.1）。
///
/// 一度も測っていない人には案内を、30日以上測っていない人には測り直しを出す。
/// どちらも**閉じられる**。測定済みで日が浅いときは、結果と次の単語帳だけを見せる。
class _VocabPromptCard extends ConsumerWidget {
  final Profile profile;

  const _VocabPromptCard({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(vocabHistoryProvider(profile.id)).value;
    if (history == null) return const SizedBox.shrink();
    final dismissed = ref
        .watch(dismissedVocabPromptProvider)
        .contains(profile.id);

    final latest = history.isEmpty ? null : history.first;
    final elapsedDays = latest == null
        ? null
        : ref.watch(clockProvider)().difference(latest.takenAt).inDays;
    final promptsRemeasure =
        latest == null || elapsedDays! >= kVocabRemeasureDays;
    if (promptsRemeasure && dismissed) return const SizedBox.shrink();

    final recommended = latest == null
        ? null
        : VocabSizeEstimate(
            bands: VocabTestRepository.decodeBands(latest.bandResults),
            falseAlarmRate: latest.falseAlarmRate,
            pseudoAsked: 0,
            pseudoKnown: 0,
          ).recommendedBand;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.of(context).gap),
      child: SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    latest == null
                        ? '語彙力を測りませんか'
                        : promptsRemeasure
                        ? '語彙力を測り直しませんか'
                        : '語彙力',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.sectionTitle(),
                  ),
                ),
                if (promptsRemeasure)
                  IconButton(
                    tooltip: '閉じる',
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () =>
                        ref
                            .read(dismissedVocabPromptProvider.notifier)
                            .state = {
                          ...ref.read(dismissedVocabPromptProvider),
                          profile.id,
                        },
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              latest == null
                  ? '3分ほどの測定で、いまの語彙力とレベルに合う単語帳が分かります。'
                  : '推定 ${latest.estimatedSize} 語'
                        '${recommended == null ? '' : ' ・ 次は「${recommended.name}」'}'
                        '${promptsRemeasure ? '（前回の測定から$elapsedDays日）' : ''}',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppText.caption(),
            ),
            if (promptsRemeasure) ...[
              const SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () => openVocabTest(context, ref, profile: profile),
                child: Text(latest == null ? '語彙力を測る' : '測り直す'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 下書きカード（[Docs/04_screens_and_flows.md] §4.1、
/// [Docs/06_features/my_words.md] §3）。
///
/// マイ単語の下書き（訳が未入力の語）が**3語以上**たまったら出す。0〜2語では
/// 出さない（実績カード等と同じく、判明するまでは出さない）。
class _DraftCard extends ConsumerWidget {
  final Profile profile;

  const _DraftCard({required this.profile});

  /// この件数未満では出さない。
  static const kMinCount = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(myWordsDraftCountProvider(profile.id)).value;
    if (count == null || count < kMinCount) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.of(context).gap),
      child: SoftCard(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                MyWordsScreen(profile: profile, initialDraftOnly: true),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'マイ単語の下書き',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.sectionTitle(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '訳が空の単語が$count語あります。',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption(),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.ink3),
          ],
        ),
      ),
    );
  }
}

/// 未達の実績カード（[Docs/04_screens_and_flows.md] §4.1）。
/// 次に解除できる実績を1つだけ出す。タップで SCR-14。
class _NextAchievementCard extends ConsumerWidget {
  final Profile profile;

  const _NextAchievementCard({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final next = ref.watch(nextAchievementProvider(profile.id)).value;
    if (next == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.of(context).gap),
      child: SoftCard(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => AchievementsScreen(profile: profile),
          ),
        ),
        child: Row(
          children: [
            Text(
              next.def.emoji,
              textScaler: TextScaler.noScaling,
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '次の実績: ${next.def.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.sectionTitle(),
                  ),
                  Text(
                    '${next.def.description}（${next.current} / '
                    '${next.def.target}${next.def.unit}）',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption(),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.ink3),
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
