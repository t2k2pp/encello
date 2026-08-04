import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/enums.dart';
import '../../core/utils/study_date.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/vocab_test_repository.dart';
import '../../domain/entities/mastery.dart';
import '../../domain/usecases/study_queue_builder.dart';
import '../../domain/usecases/vocab_size_estimator.dart';
import '../../providers/providers.dart';
import '../../providers/reaction_time_stats.dart';
import '../../providers/stats.dart';
import '../dialogs/start_study_sheet.dart';
import '../widgets/band_progress_bar.dart';
import '../widgets/bar_chart.dart';
import '../widgets/donut_chart.dart';
import '../widgets/empty_state.dart';
import '../widgets/mastery_badge.dart';
import '../widgets/soft_card.dart';
import '../widgets/streak_calendar.dart';
import 'session_history_screen.dart';
import 'vocab_test_screen.dart';
import 'word_detail_screen.dart';

/// SCR-10 統計（[Docs/04_screens_and_flows.md] §4.9、[Docs/06_features/stats.md]）。
///
/// すべてのカードは**現在の学習者**のデータだけを対象にする。
/// 習熟度と苦手単語だけは**選択中の単語帳**に限る（[gamification.md] §5）。
/// その違いはカードの caption に明示する。
class StatsScreen extends ConsumerWidget {
  final Profile profile;

  const StatsScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = AppSpacing.of(context);
    // 単語帳の選択は他画面からも変わるため、最新の学習者を見る。
    final current = ref.watch(activeProfileProvider) ?? profile;
    final hasSpeed = ref.watch(hasSpeedSessionsProvider(current.id)).value ?? false;
    final pairs = ref.watch(confusionPairsProvider(current.id)).value ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: spacing.screenPadding.copyWith(bottom: 8),
          child: Text('統計', style: AppText.title()),
        ),
        Expanded(
          child: ListView(
            padding: spacing.screenPadding.copyWith(top: 0, bottom: 96),
            children: [
              _VocabCard(profile: current),
              SizedBox(height: spacing.gap),
              _MasteryCard(profile: current),
              SizedBox(height: spacing.gap),
              _VolumeCard(profile: current),
              SizedBox(height: spacing.gap),
              _AccuracyCard(profile: current),
              if (hasSpeed) ...[
                SizedBox(height: spacing.gap),
                _ReactionCard(profile: current),
              ],
              SizedBox(height: spacing.gap),
              _StreakCard(profile: current),
              SizedBox(height: spacing.gap),
              _WeakWordsCard(profile: current),
              if (pairs.isNotEmpty) ...[
                SizedBox(height: spacing.gap),
                _ConfusionCard(profile: current),
              ],
              SizedBox(height: spacing.gap),
              SoftCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => SessionHistoryScreen(profile: current),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.history, color: AppColors.accent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '学習履歴を見る',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.ink3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// カード見出し（タイトル＋任意の caption）。
class _CardHeader extends StatelessWidget {
  final String title;
  final String? caption;

  const _CardHeader({required this.title, this.caption});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.sectionTitle(),
              ),
            ),
          ],
        ),
        if (caption != null)
          Text(caption!, maxLines: 2, style: AppText.caption()),
      ],
    );
  }
}

/// カード1: 語彙力（[Docs/06_features/stats.md] §2）。
class _VocabCard extends ConsumerWidget {
  final Profile profile;

  const _VocabCard({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(vocabHistoryProvider(profile.id)).value;
    if (history == null) {
      return const SoftCard(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (history.isEmpty) {
      return SoftCard(
        child: EmptyState(
          emoji: '📏',
          message: 'まだ測定していません',
          subMessage: '3分ほどの測定で、いまの語彙力とレベルに合う単語帳が分かります。',
          actionLabel: '語彙力を測る',
          onAction: () => openVocabTest(context, ref, profile: profile),
        ),
      );
    }

    final latest = history.first;
    final bands = VocabTestRepository.decodeBands(latest.bandResults);
    final previous = history.length > 1 ? history[1] : null;

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            title: '語彙力',
            caption: '40問前後からの推定値です。±10%程度の幅があります。',
          ),
          const SizedBox(height: 8),
          Text(
            '推定 ${latest.estimatedSize} 語',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.style(size: 24, weight: FontWeight.w800),
          ),
          if (previous != null)
            Text(
              VocabSizeEstimator.isWithinNoise(
                    current: latest.estimatedSize,
                    previous: previous.estimatedSize,
                  )
                  ? '前回とほぼ同じです'
                  : '前回から ${latest.estimatedSize - previous.estimatedSize > 0 ? '+' : ''}'
                        '${latest.estimatedSize - previous.estimatedSize} 語',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.caption(),
            ),
          const SizedBox(height: 8),
          for (final band in bands)
            BandProgressBar(
              label: band.name,
              ratio: band.corrected,
              estimatedWords: band.estimatedWords,
            ),
          if (history.length > 1) ...[
            const SizedBox(height: 12),
            Text('推定語彙数の推移', style: AppText.caption()),
            const SizedBox(height: 4),
            LineChart(
              // 測定日そのものを横軸ラベルにする（等間隔ではなく実日付）。
              values: [
                for (final t in history.reversed) t.estimatedSize.toDouble(),
              ],
              labels: [
                for (final t in history.reversed) studyDateOf(t.takenAt),
              ],
              height: 110,
            ),
          ],
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => openVocabTest(context, ref, profile: profile),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('測り直す'),
          ),
        ],
      ),
    );
  }
}

/// カード2: 習熟度の内訳（[Docs/06_features/stats.md] §3）。
class _MasteryCard extends ConsumerStatefulWidget {
  final Profile profile;

  const _MasteryCard({required this.profile});

  @override
  ConsumerState<_MasteryCard> createState() => _MasteryCardState();
}

class _MasteryCardState extends ConsumerState<_MasteryCard> {
  bool _byFamily = false;

  @override
  Widget build(BuildContext context) {
    final counts = ref.watch(masteryCountsProvider(widget.profile)).value;
    final families = ref.watch(familyMasteryProvider(widget.profile)).value;
    if (counts == null) {
      return const SoftCard(child: Center(child: CircularProgressIndicator()));
    }

    // まだ何も学習していないときは円ではなく空状態にする。
    if (counts.learned == 0) {
      return SoftCard(
        child: EmptyState(
          emoji: '📊',
          message: 'まだ学習の記録がありません',
          subMessage: '1回学習すると、習熟度の内訳がここに出ます。',
          actionLabel: '学習をはじめる',
          onAction: () =>
              showStartStudySheet(context, profile: widget.profile),
        ),
      );
    }

    final segments = _byFamily
        ? [
            DonutSegment(
              label: '手つかず',
              value: families?.untouched ?? 0,
              color: AppColors.line,
            ),
            DonutSegment(
              label: '一部',
              value: families?.partial ?? 0,
              color: AppColors.accent,
            ),
            DonutSegment(
              label: '全部',
              value: families?.complete ?? 0,
              color: AppColors.mastered,
            ),
          ]
        : [
            for (final m in Mastery.values)
              DonutSegment(
                label: m.label,
                value: counts.byMastery[m] ?? 0,
                color: masteryColor(m),
              ),
          ];
    final total = segments.fold(0, (s, e) => s + e.value);

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(title: '習熟度の内訳', caption: '学習対象の単語帳のみ'),
          // 語族に属する語が1つも無い状態では切替を出さない。
          if ((families?.total ?? 0) > 0) ...[
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
              segments: const [
                ButtonSegment(value: false, label: Text('語単位')),
                ButtonSegment(value: true, label: Text('語族単位')),
              ],
              selected: {_byFamily},
              onSelectionChanged: (s) => setState(() => _byFamily = s.first),
            ),
          ],
          const SizedBox(height: 12),
          Center(
            child: DonutChart(
              segments: segments,
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _byFamily
                        ? '${families?.complete ?? 0} / $total'
                        : '${counts.learned} / $total',
                    maxLines: 1,
                    style: AppText.style(size: 18, weight: FontWeight.w800),
                  ),
                  Text(
                    _byFamily ? '語族' : '学習した語',
                    maxLines: 1,
                    style: AppText.caption(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          DonutLegend(segments: segments, unit: _byFamily ? '語族' : '語'),
        ],
      ),
    );
  }
}

/// カード3: 直近30日の学習量（[Docs/06_features/stats.md] §4）。
class _VolumeCard extends ConsumerWidget {
  final Profile profile;

  const _VolumeCard({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(dailySeriesProvider(profile));
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            title: '直近30日の学習量',
            caption: '破線はデイリー目標。達成した日は色が付きます。',
          ),
          const SizedBox(height: 12),
          BarChart(
            data: [
              for (final p in series)
                BarDatum(
                  label: p.studyDate,
                  value: p.answeredCount.toDouble(),
                  highlighted: p.goalMet,
                ),
            ],
            goalLine: profile.dailyGoal.toDouble(),
          ),
        ],
      ),
    );
  }
}

/// カード4: 正解率の推移（[Docs/06_features/stats.md] §5）。
class _AccuracyCard extends ConsumerWidget {
  final Profile profile;

  const _AccuracyCard({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(dailySeriesProvider(profile));
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            title: '正解率の推移',
            caption: '解答が無かった日は線を切っています（0% ではありません）。',
          ),
          const SizedBox(height: 12),
          LineChart(
            values: [
              for (final p in series)
                p.accuracy == null ? null : p.accuracy! * 100,
            ],
            labels: [for (final p in series) p.studyDate],
            // 縦軸は 0〜100% 固定。データに合わせて伸縮させない。
            maxValue: 100,
          ),
        ],
      ),
    );
  }
}

/// カード5: 反応の速さ（[Docs/06_features/stats.md] §6）。
class _ReactionCard extends ConsumerWidget {
  final Profile profile;

  const _ReactionCard({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final answers = ref.watch(speedAnswersProvider(profile.id)).value;
    if (answers == null) {
      return const SoftCard(child: Center(child: CircularProgressIndicator()));
    }
    final series = ReactionTimeStats.dailySeries(
      answers,
      today: studyDateOf(ref.watch(clockProvider)()),
    );
    final average = ReactionTimeStats.average(answers);

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            title: '反応の速さ',
            caption: average == null
                ? '時間内に正解した問題だけで平均を取ります。'
                : '直近30日の平均 ${(average / 1000).toStringAsFixed(2)} 秒'
                      '（時間内に正解した問題のみ）',
          ),
          const SizedBox(height: 12),
          LineChart(
            values: [
              for (final p in series)
                p.averageMs == null ? null : p.averageMs! / 1000,
            ],
            labels: [for (final p in series) p.studyDate],
            guideLine: profile.speedLimitMs / 1000,
          ),
        ],
      ),
    );
  }
}

/// カード6: ストリーク（[Docs/06_features/stats.md] §7）。
class _StreakCard extends ConsumerStatefulWidget {
  final Profile profile;

  const _StreakCard({required this.profile});

  @override
  ConsumerState<_StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends ConsumerState<_StreakCard> {
  /// 表示中の月（既定は今月）。
  DateTime? _month;

  @override
  Widget build(BuildContext context) {
    final now = ref.watch(clockProvider)();
    final month = _month ?? DateTime(now.year, now.month);
    final streak = ref.watch(streakProvider(widget.profile.id));
    final stats =
        ref.watch(dailyStatsHistoryProvider(widget.profile.id)).value ??
        const <DailyStat>[];

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(title: 'ストリーク'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      streak.current > 0 ? '🔥 ${streak.current}日' : '今日から始めましょう',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.style(size: 22, weight: FontWeight.w800),
                    ),
                    Text(
                      '最長 ${streak.longest}日',
                      maxLines: 1,
                      style: AppText.caption(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StreakCalendar(
            month: month,
            today: studyDateOf(now),
            states: {
              for (final s in stats)
                s.studyDate: s.goalMet
                    ? StreakDayState.met
                    : s.answeredCount > 0
                    ? StreakDayState.studied
                    : StreakDayState.none,
            },
            onPrevMonth: () => setState(
              () => _month = DateTime(month.year, month.month - 1),
            ),
            onNextMonth: () => setState(
              () => _month = DateTime(month.year, month.month + 1),
            ),
          ),
        ],
      ),
    );
  }
}

/// カード7: 苦手単語トップ20（[Docs/06_features/stats.md] §8）。
class _WeakWordsCard extends ConsumerWidget {
  final Profile profile;

  const _WeakWordsCard({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final words = ref.watch(weakWordsProvider(profile)).value;
    if (words == null) {
      return const SoftCard(child: Center(child: CircularProgressIndicator()));
    }
    if (words.isEmpty) {
      return SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _CardHeader(title: '苦手単語', caption: '学習対象の単語帳のみ'),
            const SizedBox(height: 8),
            // 条件を緩めて無理に20語埋めない。
            Text(
              '苦手な単語はありません。'
              '${StudyQueueBuilder.weakMinAnswered}回以上解いて正解率が'
              '${(StudyQueueBuilder.weakMaxAccuracy * 100).round()}%未満の語がここに出ます。',
              style: AppText.caption(),
            ),
          ],
        ),
      );
    }

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(title: '苦手単語トップ${words.length}', caption: '学習対象の単語帳のみ'),
          const SizedBox(height: 4),
          for (final w in words)
            InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => WordDetailScreen(
                    wordId: w.word.id,
                    profile: profile,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            w.word.headword,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.style(
                              size: 15,
                              weight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            w.word.meaning,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.caption(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${w.totalAnswered}回中${w.totalCorrect}正解'
                          '（${(w.accuracy * 100).round()}%）',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.caption(),
                        ),
                        const SizedBox(height: 2),
                        MasteryBadge(mastery: w.mastery),
                      ],
                    ),
                  ],
                ),
              ),
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
              initialPolicy: QueuePolicy.weakOnly,
            ),
            child: Text('苦手だけ復習（${words.length}語）'),
          ),
        ],
      ),
    );
  }
}

/// カード8: よく取り違える組（[Docs/06_features/stats.md] §9）。
class _ConfusionCard extends ConsumerWidget {
  final Profile profile;

  const _ConfusionCard({required this.profile});

  /// 出す組の上限。
  static const maxPairs = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pairs = ref.watch(confusionPairsProvider(profile.id)).value ?? const [];
    final resolved = ref.watch(resolvedConfusionCountProvider(profile.id)).value ?? 0;
    final shown = pairs.take(maxPairs).toList();

    return SoftCard(
      child: FutureBuilder<Map<int, Word>>(
        future: ref
            .watch(statsRepositoryProvider)
            .loadWords([
              for (final p in shown) ...[p.wordIdA, p.wordIdB],
            ]),
        builder: (context, snapshot) {
          final words = snapshot.data;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _CardHeader(title: 'よく取り違える組'),
              const SizedBox(height: 4),
              if (words == null)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                for (final pair in shown)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${words[pair.wordIdA]?.headword ?? '?'} ⇄ '
                            '${words[pair.wordIdB]?.headword ?? '?'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.body(),
                          ),
                        ),
                        Text(
                          '${pair.count}回',
                          maxLines: 1,
                          style: AppText.caption(),
                        ),
                      ],
                    ),
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
                  initialMode: StudyMode.confusion,
                ),
                child: Text('まとめて練習（${shown.length}組）'),
              ),
              if (resolved > 0) ...[
                const SizedBox(height: 6),
                Text('解消した組 $resolved件', style: AppText.caption()),
              ],
            ],
          );
        },
      ),
    );
  }
}
