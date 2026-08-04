import 'package:drift/drift.dart';
import 'package:meta/meta.dart';

import '../core/utils/enums.dart';
import '../core/utils/study_date.dart';
import '../data/database/app_database.dart';
import '../data/repositories/stats_repository.dart';
import '../data/repositories/study_repository.dart';
import '../domain/usecases/streak_calculator.dart';
import '../domain/usecases/xp_calculator.dart';
import 'achievement_evaluator.dart';
import 'study_launcher.dart' show kSpeedQuestionCount;

/// セッションの成績（結果画面が見る値）。
@immutable
class SessionSummary {
  final StudySession session;

  /// 間違えた語（惜しいを含む）。出題順。
  final List<Word> missedWords;

  /// このセッションで解除された実績（結果画面にカードで出す）。
  final List<AchievementDef> unlockedAchievements;

  /// 更新後のストリーク。デイリー目標を達成した回はここで伸びる。
  final StreakResult streak;

  /// この回にデイリー目標を達成したか。
  final bool goalMetToday;

  const SessionSummary({
    required this.session,
    required this.missedWords,
    this.unlockedAchievements = const [],
    this.streak = StreakResult.zero,
    this.goalMetToday = false,
  });

  int get answeredCount => session.answeredCount;

  int get correctCount => session.correctCount;

  /// 正解率（0.0〜1.0）。1問も解いていなければ null。
  double? get accuracy =>
      answeredCount == 0 ? null : correctCount / answeredCount;

  Duration get elapsed =>
      (session.finishedAt ?? session.startedAt).difference(session.startedAt);
}

/// セッションの確定（[Docs/02_architecture.md] §1.1）。
///
/// 「セッション記録の確定」「スピードの全問時間内ボーナス」「実績の解除判定」を
/// 1つのユースケースにまとめる。中断で終わったセッションは `finishedAt` を
/// null のままにする。
///
/// リマインダーの予約し直しは通知の権限に触れるため、UI 側の
/// `ReminderScheduler` が結果画面で呼ぶ（DB だけを触るここには入れない）。
class SessionFinalizer {
  final AppDatabase _db;
  final StudyRepository _study;
  final StatsRepository _stats;

  SessionFinalizer(this._db)
    : _study = StudyRepository(_db),
      _stats = StatsRepository(_db);

  /// セッションを終了として確定し、結果画面に出す成績を返す。
  Future<SessionSummary> finish({
    required String sessionId,
    required DateTime finishedAt,

    /// スピードモードでのみ。時間内正解だけの平均反応時間（ミリ秒）。
    int? avgReactionMs,
  }) async {
    await (_db.update(_db.studySessions)..where((t) => t.id.equals(sessionId)))
        .write(
          StudySessionsCompanion(
            finishedAt: Value(finishedAt),
            avgReactionMs: Value(avgReactionMs),
          ),
        );
    await _applySpeedPerfectBonus(sessionId, finishedAt);

    final session = await _requireSession(sessionId);
    final today = studyDateOf(finishedAt);
    final marks = await _stats.dailyStats(session.profileId);
    final streak = StreakCalculator.calculate(
      marks.map((m) => DailyGoalMark(studyDate: m.studyDate, goalMet: m.goalMet)),
      today: today,
    );
    final unlocked = await _unlockAchievements(
      profileId: session.profileId,
      longestStreak: streak.longest,
      at: finishedAt,
    );

    final base = await summarize(sessionId);
    return SessionSummary(
      session: base.session,
      missedWords: base.missedWords,
      unlockedAchievements: unlocked,
      streak: streak,
      goalMetToday: marks.any((m) => m.studyDate == today && m.goalMet),
    );
  }

  /// 途中で中断したセッション。すでに解答した分は保存済みなので破棄しない。
  /// `finishedAt` を入れないことで「中断のまま終わった」と分かるようにする。
  Future<void> abort(String sessionId) async {
    // 1問も解いていない中断は記録として意味が無いため行ごと消す。
    final session = await _study.findSession(sessionId);
    if (session == null) return;
    if (session.answeredCount == 0) {
      await (_db.delete(_db.studySessions)
            ..where((t) => t.id.equals(sessionId)))
          .go();
    }
  }

  Future<SessionSummary> summarize(String sessionId) async {
    final session = await _requireSession(sessionId);
    final logs = await _study.logsOf(sessionId);

    // 同じ語を2回出題した場合（誤答の再出題）、最後の解答で判断する。
    final lastByWord = <int, LearningLog>{};
    for (final log in logs) {
      final wordId = log.wordId;
      if (wordId != null) lastByWord[wordId] = log;
    }
    final missedIds = [
      for (final entry in lastByWord.entries)
        if (!entry.value.isCorrect) entry.key,
    ];
    final words = await _study.loadWords(missedIds);

    return SessionSummary(
      session: session,
      missedWords: [
        for (final id in missedIds)
          if (words[id] != null) words[id]!,
      ],
    );
  }

  Future<StudySession> _requireSession(String sessionId) async {
    final session = await _study.findSession(sessionId);
    if (session == null) {
      throw StateError('セッションが見つかりません（id=$sessionId）');
    }
    return session;
  }

  /// スピードモードで50問すべてを時間内に正解したときの +50 XP
  /// （[Docs/06_features/gamification.md] §3）。セッションと日次集計の両方に足す。
  Future<void> _applySpeedPerfectBonus(
    String sessionId,
    DateTime finishedAt,
  ) async {
    final session = await _requireSession(sessionId);
    if (StudyMode.fromValue(session.mode) != StudyMode.speed) return;
    if (session.answeredCount < kSpeedQuestionCount) return;
    if (session.correctCount != session.answeredCount) return;

    await _db.transaction(() async {
      await (_db.update(_db.studySessions)
            ..where((t) => t.id.equals(sessionId)))
          .write(
            StudySessionsCompanion(
              xpEarned: Value(session.xpEarned + XpCalculator.speedPerfectXp),
            ),
          );
      final studyDate = studyDateOf(finishedAt);
      final daily =
          await (_db.select(_db.dailyStats)..where(
                (t) =>
                    t.profileId.equals(session.profileId) &
                    t.studyDate.equals(studyDate),
              ))
              .getSingleOrNull();
      // 解答が1問でもあれば行は存在する（ボーナスだけの行は作らない）。
      if (daily == null) return;
      await (_db.update(_db.dailyStats)..where(
            (t) =>
                t.profileId.equals(session.profileId) &
                t.studyDate.equals(studyDate),
          ))
          .write(
            DailyStatsCompanion(
              xp: Value(daily.xp + XpCalculator.speedPerfectXp),
            ),
          );
    });
  }

  /// 条件を満たした未解除の実績を記録し、新しく解除したものを返す。
  Future<List<AchievementDef>> _unlockAchievements({
    required int profileId,
    required int longestStreak,
    required DateTime at,
  }) async {
    final stats = await _stats.achievementStats(
      profileId,
      longestStreak: longestStreak,
    );
    final already = await _stats.unlockedAchievements(profileId);
    final fresh = AchievementEvaluator.newlyUnlocked(
      stats,
      unlockedCodes: already.keys.toSet(),
    );
    if (fresh.isEmpty) return const [];
    await _stats.unlockAchievements(
      profileId,
      fresh.map((d) => d.code),
      at: at,
    );
    return fresh;
  }
}
