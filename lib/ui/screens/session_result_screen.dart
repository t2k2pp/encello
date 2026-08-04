import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/achievement_evaluator.dart';
import '../../application/session_finalizer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../data/database/app_database.dart';
import '../../providers/providers.dart';
import '../../providers/stats.dart';
import '../widgets/centered_content.dart';
import '../widgets/empty_state.dart';
import '../widgets/progress_ring.dart';
import '../widgets/soft_card.dart';
import 'word_detail_screen.dart';

/// SCR-07 セッション結果（[Docs/04_screens_and_flows.md] §4.6）。
class SessionResultScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const SessionResultScreen({super.key, required this.sessionId});

  @override
  ConsumerState<SessionResultScreen> createState() =>
      _SessionResultScreenState();
}

class _SessionResultScreenState extends ConsumerState<SessionResultScreen> {
  late final Future<SessionSummary> _summary = _finish();
  late final Profile? _profile = ref.read(activeProfileProvider);

  Future<SessionSummary> _finish() async {
    final summary = await ref
        .read(sessionFinalizerProvider)
        .finish(
          sessionId: widget.sessionId,
          finishedAt: ref.read(clockProvider)(),
        );
    // 通知の件数は解いた分だけ減る。セッションを終えたら予約を作り直す
    // （[Docs/06_features/reminders.md] §3.1）。
    final profile = _profile;
    if (profile != null) {
      await ref
          .read(reminderSchedulerProvider)
          .reschedule(profile, now: ref.read(clockProvider)());
    }
    return summary;
  }

  void _close() {
    ref.read(studySessionProvider.notifier).clear();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('学習の結果'),
        ),
        body: CenteredContent(
          child: FutureBuilder<SessionSummary>(
            future: _summary,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return EmptyState(
                  emoji: '⚠️',
                  message: '結果を読み込めませんでした',
                  subMessage: '${snapshot.error}',
                );
              }
              final summary = snapshot.data;
              if (summary == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView(
                padding: spacing.screenPadding.copyWith(bottom: 32),
                children: [
                  _ScoreCard(summary: summary),
                  SizedBox(height: spacing.gap),
                  if (summary.goalMetToday) ...[
                    _GoalMetCard(streak: summary.streak.current),
                    SizedBox(height: spacing.gap),
                  ],
                  // 解除した実績はカード1枚として示す（全画面の演出は挟まない）。
                  // 同時に複数解除したときは縦に並べる。
                  for (final def in summary.unlockedAchievements) ...[
                    _AchievementCard(def: def),
                    SizedBox(height: spacing.gap),
                  ],
                  if (summary.missedWords.isNotEmpty) ...[
                    _MissedCard(
                      words: summary.missedWords,
                      profile: _profile,
                    ),
                    SizedBox(height: spacing.gap),
                  ],
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: _close,
                    child: const Text('終わる'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final SessionSummary summary;

  const _ScoreCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final accuracy = summary.accuracy ?? 0;
    return SoftCard(
      child: Column(
        children: [
          ProgressRing(
            value: accuracy,
            size: 120,
            child: RingLabel(
              value: '${(accuracy * 100).round()}%',
              caption: '正解率',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${summary.correctCount} / ${summary.answeredCount} 問正解',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.sectionTitle(),
          ),
          const SizedBox(height: 4),
          Text(
            '+${summary.session.xpEarned} XP ・ ${_formatDuration(summary.elapsed)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.caption(),
          ),
        ],
      ),
    );
  }

  static String _formatDuration(Duration d) {
    if (d.inMinutes < 1) return '${d.inSeconds}秒';
    return '${d.inMinutes}分${d.inSeconds % 60}秒';
  }
}

/// デイリー目標を達成した回に出すカード（[Docs/04_screens_and_flows.md] §4.6）。
/// ストリークが伸びたことをここで示す。
class _GoalMetCard extends StatelessWidget {
  final int streak;

  const _GoalMetCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: AppColors.accentSoft,
      child: Row(
        children: [
          const Text(
            '🔥',
            textScaler: TextScaler.noScaling,
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('今日の目標を達成しました', style: AppText.sectionTitle()),
                Text(
                  streak > 1 ? '$streak日続いています' : '明日も続けると連続日数が伸びます',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 解除した実績（[Docs/06_features/gamification.md] §4）。
class _AchievementCard extends StatelessWidget {
  final AchievementDef def;

  const _AchievementCard({required this.def});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Row(
        children: [
          Text(
            def.emoji,
            textScaler: TextScaler.noScaling,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '実績を解除: ${def.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.sectionTitle(),
                ),
                Text(
                  def.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MissedCard extends StatelessWidget {
  final List<Word> words;
  final Profile? profile;

  const _MissedCard({required this.words, required this.profile});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('間違えた語（${words.length}）', style: AppText.sectionTitle()),
          const SizedBox(height: 8),
          for (final word in words)
            InkWell(
              onTap: profile == null
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => WordDetailScreen(
                          wordId: word.id,
                          profile: profile!,
                        ),
                      ),
                    ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        word.headword,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.style(
                          size: 15,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        word.meaning,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: AppText.caption(),
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 18, color: AppColors.ink3),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
