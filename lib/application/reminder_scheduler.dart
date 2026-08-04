import '../core/utils/study_date.dart';
import '../data/database/app_database.dart';
import '../data/repositories/stats_repository.dart';
import '../data/repositories/study_repository.dart';
import '../domain/services/reminder_service.dart';
import '../domain/usecases/reminder_plan_builder.dart';
import '../domain/usecases/streak_calculator.dart';

/// 学習リマインダーの予約し直し（[Docs/06_features/reminders.md] §3.1）。
///
/// 予約内容は「その時点の見込み」なので、アプリを開いたとき・セッションを終えたとき・
/// 設定を変えたときに作り直す。7日先までしか予約しない。
class ReminderScheduler {
  final ReminderService _service;
  final StudyRepository _study;
  final StatsRepository _stats;

  const ReminderScheduler(this._service, this._study, this._stats);

  /// [profile] の通知を作り直す。
  ///
  /// リマインダーが OFF、または通知が許可されていない場合は**取り消すだけ**にする。
  /// ON に見せかけて鳴らない状態を作らない。
  Future<void> reschedule(Profile profile, {required DateTime now}) async {
    if (!profile.reminderEnabled) {
      await _service.cancel(profile.id);
      return;
    }
    if (!await _service.hasPermission()) {
      await _service.cancel(profile.id);
      return;
    }
    await _service.reschedule(profile.id, await buildPlan(profile, now: now));
  }

  /// 予約内容を組み立てる（テストから内容だけを検証できるよう分けている）。
  Future<ReminderPlan> buildPlan(Profile profile, {required DateTime now}) async {
    final today = studyDateOf(now);
    final daily = await _stats.dailyStats(profile.id);
    final streak = StreakCalculator.calculate(
      daily.map((d) => DailyGoalMark(studyDate: d.studyDate, goalMet: d.goalMet)),
      today: today,
    );
    final goalMetToday = daily.any((d) => d.studyDate == today && d.goalMet);

    // 予約する最終日の通知時刻までに期限が来る復習を一度で取り、日ごとに数える。
    final horizon = DateTime(
      now.year,
      now.month,
      now.day + ReminderPlanBuilder.scheduleDays,
      profile.reminderHour,
      profile.reminderMinute,
    );
    final dueDates = await _study.dueDatesUntil(profile, horizon);

    return ReminderPlanBuilder.build(
      profileName: profile.name,
      hour: profile.reminderHour,
      minute: profile.reminderMinute,
      now: now,
      goalMetToday: goalMetToday,
      streakDays: streak.current,
      dueCountAt: (at) =>
          dueDates.where((d) => !d.isAfter(at)).length,
    );
  }

  /// 設定画面の「テスト通知を送る」。5秒後に1通出す。
  Future<void> sendTest(Profile profile, {required DateTime now}) async {
    final dueDates = await _study.dueDatesUntil(profile, now);
    await _service.sendTest(
      profile.id,
      ReminderPlanBuilder.title,
      ReminderPlanBuilder.bodyOf(
        profileName: profile.name,
        dueCount: dueDates.length,
        streakDays: 0,
      ),
    );
  }

  /// 学習者を削除したときに、その人の通知を取り消す。
  Future<void> cancel(int profileId) => _service.cancel(profileId);
}
