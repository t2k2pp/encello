import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/enums.dart';
import '../../data/database/app_database.dart';
import '../../providers/stats.dart';
import '../widgets/centered_content.dart';
import '../widgets/empty_state.dart';
import '../widgets/soft_card.dart';

/// SCR-15 学習履歴（[Docs/06_features/stats.md] §10）。
///
/// 中断したセッション（`finishedAt` が null）は「中断」バッジを付けて残す。消さない。
class SessionHistoryScreen extends ConsumerStatefulWidget {
  final Profile profile;

  const SessionHistoryScreen({super.key, required this.profile});

  @override
  ConsumerState<SessionHistoryScreen> createState() =>
      _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends ConsumerState<SessionHistoryScreen> {
  /// 1回に読む件数（[Docs/06_features/stats.md] §10）。
  static const pageSize = 50;

  final _sessions = <StudySession>[];
  bool _loading = false;
  bool _reachedEnd = false;
  Object? _error;

  /// 展開中のセッション（解答一覧を出す）。
  String? _expandedId;

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || _reachedEnd) return;
    setState(() => _loading = true);
    try {
      final page = await ref
          .read(statsRepositoryProvider)
          .sessions(
            widget.profile.id,
            limit: pageSize,
            offset: _sessions.length,
          );
      if (!mounted) return;
      setState(() {
        _sessions.addAll(page);
        _reachedEnd = page.length < pageSize;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final error = _error;

    return Scaffold(
      appBar: AppBar(title: const Text('学習履歴')),
      body: CenteredContent(
        child: error != null
            ? EmptyState(
                emoji: '⚠️',
                message: '履歴を読み込めませんでした',
                subMessage: '$error',
              )
            : _sessions.isEmpty
            ? _loading
                  ? const Center(child: CircularProgressIndicator())
                  : const EmptyState(
                      emoji: '🗒',
                      message: 'まだ学習の記録がありません',
                      subMessage: '学習を1回終えると、ここに残ります。',
                    )
            : NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                    _loadMore();
                  }
                  return false;
                },
                child: ListView.separated(
                  padding: spacing.screenPadding.copyWith(bottom: 32),
                  itemCount: _sessions.length + (_reachedEnd ? 0 : 1),
                  separatorBuilder: (_, _) => SizedBox(height: spacing.gap),
                  itemBuilder: (context, index) {
                    if (index >= _sessions.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final session = _sessions[index];
                    return _SessionTile(
                      session: session,
                      expanded: _expandedId == session.id,
                      onTap: () => setState(
                        () => _expandedId =
                            _expandedId == session.id ? null : session.id,
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class _SessionTile extends ConsumerWidget {
  final StudySession session;
  final bool expanded;
  final VoidCallback onTap;

  const _SessionTile({
    required this.session,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = StudyMode.fromValue(session.mode);
    final aborted = session.finishedAt == null;
    final elapsed = (session.finishedAt ?? session.startedAt).difference(
      session.startedAt,
    );

    return SoftCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                mode.emoji,
                textScaler: TextScaler.noScaling,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_formatDateTime(session.startedAt)} ・ ${mode.label}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body(),
                    ),
                    Text(
                      '${session.correctCount}/${session.answeredCount} 正解 ・ '
                      '${_formatDuration(elapsed)} ・ +${session.xpEarned} XP',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.caption(),
                    ),
                  ],
                ),
              ),
              if (aborted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.chipBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('中断', maxLines: 1, style: AppText.caption()),
                ),
              Icon(
                expanded ? Icons.expand_less : Icons.expand_more,
                color: AppColors.ink3,
              ),
            ],
          ),
          if (expanded) ...[
            const SizedBox(height: 8),
            _SessionLogs(sessionId: session.id),
          ],
        ],
      ),
    );
  }

  static String _formatDateTime(DateTime d) =>
      '${d.month}/${d.day} ${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';

  static String _formatDuration(Duration d) {
    if (d.inMinutes < 1) return '${d.inSeconds}秒';
    return '${d.inMinutes}分${d.inSeconds % 60}秒';
  }
}

/// 展開したセッションの解答一覧（単語・正誤・入力内容・所要時間）。
class _SessionLogs extends ConsumerWidget {
  final String sessionId;

  const _SessionLogs({required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(statsRepositoryProvider);
    return FutureBuilder<List<LearningLog>>(
      future: repo.sessionLogs(sessionId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            '解答を読み込めませんでした: ${snapshot.error}',
            style: AppText.caption(color: AppColors.accentDeep),
          );
        }
        final logs = snapshot.data;
        if (logs == null) {
          return const Padding(
            padding: EdgeInsets.all(8),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (logs.isEmpty) {
          return Text('解答の記録がありません', style: AppText.caption());
        }
        return FutureBuilder<Map<int, Word>>(
          future: repo.loadWords([
            for (final l in logs)
              if (l.wordId != null) l.wordId!,
          ]),
          builder: (context, wordSnapshot) {
            final words = wordSnapshot.data ?? const <int, Word>{};
            return Column(
              children: [
                for (final log in logs)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Icon(
                          log.isCorrect ? Icons.check : Icons.close,
                          size: 16,
                          color: log.isCorrect
                              ? AppColors.correct
                              : AppColors.wrong,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            words[log.wordId]?.headword ?? '語のつくり',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.body(),
                          ),
                        ),
                        if (log.answeredText != null &&
                            log.answeredText!.isNotEmpty) ...[
                          Flexible(
                            child: Text(
                              log.answeredText!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.caption(),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          '${(log.elapsedMs / 1000).toStringAsFixed(1)}秒',
                          maxLines: 1,
                          style: AppText.caption(),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
