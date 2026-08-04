import 'package:drift/drift.dart';
import 'package:meta/meta.dart';

import '../core/utils/enums.dart';
import '../core/utils/study_date.dart';
import '../data/database/app_database.dart';
import '../data/repositories/study_repository.dart';
import '../domain/entities/mastery.dart';
import '../domain/entities/review_state.dart';
import '../domain/usecases/grade_resolver.dart';
import '../domain/usecases/sm2_scheduler.dart';
import '../domain/usecases/xp_calculator.dart';

/// 1問ぶんの解答（画面から渡す値）。
@immutable
class AnswerRecord {
  final int wordId;
  final StudyMode mode;
  final StudyDirection direction;
  final bool isCorrect;

  /// 「惜しい」だったか。XP の算出にだけ使う（正解には数えない）。
  final bool isNearMiss;

  /// SM-2 に渡す grade。`GradeResolver.noUpdate`（-1）なら学習状態を更新しない。
  final int grade;

  /// 入力した文字列／選んだ選択肢（正規化前）。取り違え検出に使う。
  final String? answeredText;
  final int hintUsed;
  final int replayCount;

  /// 出題表示から解答確定までの時間（ミリ秒）。
  final int elapsedMs;

  const AnswerRecord({
    required this.wordId,
    required this.mode,
    required this.direction,
    required this.isCorrect,
    required this.grade,
    required this.elapsedMs,
    this.isNearMiss = false,
    this.answeredText,
    this.hintUsed = 0,
    this.replayCount = 0,
  });

  /// 学習状態を更新するか（時間切れ・自己評価なしは更新しない）。
  bool get updatesReview => grade != GradeResolver.noUpdate;
}

/// 1問の確定結果（画面へ返す値）。
@immutable
class AnswerOutcome {
  final int xpEarned;

  /// 更新後の学習状態。更新しなかった場合は null。
  final ReviewState? review;

  /// この解答でデイリー目標を達成したか（達成した瞬間だけ true）。
  final bool goalJustMet;

  const AnswerOutcome({
    required this.xpEarned,
    required this.review,
    required this.goalJustMet,
  });
}

/// 1問の解答を**1トランザクション**で確定する（[Docs/02_architecture.md] §1.1）。
///
/// 「解答履歴の追加」「学習状態の更新」「日次集計の更新」「セッションの加算」は
/// 同時に満たす必要がある。画面に分散させず、ここに集約する。
class AnswerSubmissionService {
  final AppDatabase _db;
  final StudyRepository _study;

  AnswerSubmissionService(this._db) : _study = StudyRepository(_db);

  Future<AnswerOutcome> submit({
    required Profile profile,
    required String sessionId,
    required AnswerRecord record,
    required DateTime answeredAt,

    /// この解答を含めたセッション内の連続正解数（XP のボーナス判定に使う）。
    required int sessionCorrectStreak,
  }) {
    return _db.transaction(() async {
      await _db
          .into(_db.learningLogs)
          .insert(
            LearningLogsCompanion.insert(
              profileId: profile.id,
              sessionId: sessionId,
              wordId: Value(record.wordId),
              mode: record.mode.value,
              direction: record.direction.value,
              isCorrect: record.isCorrect,
              grade: record.grade,
              answeredText: Value(record.answeredText),
              hintUsed: Value(record.hintUsed),
              replayCount: Value(record.replayCount),
              elapsedMs: record.elapsedMs,
              answeredAt: answeredAt,
            ),
          );

      final review = record.updatesReview
          ? await _applyReview(profile, record, answeredAt)
          : null;

      final xp = XpCalculator.forAnswer(
        mode: record.mode,
        isCorrect: record.isCorrect,
        isNearMiss: record.isNearMiss,
        hintUsed: record.hintUsed,
        sessionCorrectStreak: sessionCorrectStreak,
      );

      final goalJustMet = await _applyDailyStats(
        profile,
        record,
        answeredAt,
        xp,
      );
      await _applySessionTotals(sessionId, record, xp);

      return AnswerOutcome(
        xpEarned: xp,
        review: review,
        goalJustMet: goalJustMet,
      );
    });
  }

  /// 学習状態を SM-2 で進める。`masteryLevel` も**同じトランザクションで**必ず一緒に
  /// 書き換える（[Docs/03_data_model.md] §2.5）。
  Future<ReviewState> _applyReview(
    Profile profile,
    AnswerRecord record,
    DateTime answeredAt,
  ) async {
    final existing = await _study.findReview(record.wordId, profile.id);
    final next = Sm2Scheduler.apply(
      existing?.toReviewState() ?? ReviewState.initial,
      grade: record.grade,
      isCorrect: record.isCorrect,
      answeredAt: answeredAt,
    );
    await _db
        .into(_db.wordReviews)
        .insertOnConflictUpdate(
          WordReviewsCompanion.insert(
            profileId: profile.id,
            wordId: record.wordId,
            dueAt: next.dueAt!,
            repetition: Value(next.repetition),
            intervalDays: Value(next.intervalDays),
            easeFactor: Value(next.easeFactor),
            lastReviewedAt: Value(next.lastReviewedAt),
            firstLearnedAt: Value(next.firstLearnedAt),
            lapses: Value(next.lapses),
            correctStreak: Value(next.correctStreak),
            totalCorrect: Value(next.totalCorrect),
            totalIncorrect: Value(next.totalIncorrect),
            masteryLevel: Value(Mastery.from(next).level),
          ),
        );
    return next;
  }

  /// 日次集計を積み上げる。`learning_logs` から毎回集計し直さない
  /// （[Docs/03_data_model.md] §2.9）。
  Future<bool> _applyDailyStats(
    Profile profile,
    AnswerRecord record,
    DateTime answeredAt,
    int xp,
  ) async {
    final studyDate = studyDateOf(answeredAt);
    final existing =
        await (_db.select(_db.dailyStats)..where(
              (t) =>
                  t.profileId.equals(profile.id) &
                  t.studyDate.equals(studyDate),
            ))
            .getSingleOrNull();

    final answered = (existing?.answeredCount ?? 0) + 1;
    final correct = (existing?.correctCount ?? 0) + (record.isCorrect ? 1 : 0);
    // その日に適用されていた目標を使う（後から目標を変えても過去を動かさない）。
    final goal = existing?.goalCount ?? profile.dailyGoal;
    final wasMet = existing?.goalMet ?? false;
    // 達成した時点で true。以後 false に戻さない。
    final nowMet = wasMet || answered >= goal;

    await _db
        .into(_db.dailyStats)
        .insertOnConflictUpdate(
          DailyStatsCompanion.insert(
            profileId: profile.id,
            studyDate: studyDate,
            goalCount: goal,
            answeredCount: Value(answered),
            correctCount: Value(correct),
            xp: Value((existing?.xp ?? 0) + xp),
            studySeconds: Value(
              (existing?.studySeconds ?? 0) + (record.elapsedMs / 1000).round(),
            ),
            goalMet: Value(nowMet),
          ),
        );
    return nowMet && !wasMet;
  }

  Future<void> _applySessionTotals(
    String sessionId,
    AnswerRecord record,
    int xp,
  ) async {
    final session = await _study.findSession(sessionId);
    if (session == null) {
      throw StateError('解答の対象セッションが見つかりません（id=$sessionId）');
    }
    await (_db.update(_db.studySessions)
          ..where((t) => t.id.equals(sessionId)))
        .write(
          StudySessionsCompanion(
            answeredCount: Value(session.answeredCount + 1),
            correctCount: Value(
              session.correctCount + (record.isCorrect ? 1 : 0),
            ),
            xpEarned: Value(session.xpEarned + xp),
          ),
        );
  }
}
