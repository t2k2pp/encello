import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/achievement_evaluator.dart';
import '../application/reminder_scheduler.dart';
import '../core/utils/study_date.dart';
import '../data/database/app_database.dart';
import '../data/repositories/stats_repository.dart';
import '../data/repositories/vocab_test_repository.dart';
import '../data/seeds/pseudoword_assets.dart';
import '../data/services/notification_service.dart';
import '../domain/entities/achievement_stats.dart';
import '../domain/services/reminder_service.dart';
import '../domain/usecases/confusion_pair_finder.dart';
import '../domain/usecases/streak_calculator.dart';
import 'providers.dart';
import 'stats_aggregates.dart';

/// 統計・実績の集計（[Docs/06_features/stats.md] §11）。
final statsRepositoryProvider = Provider<StatsRepository>(
  (ref) => StatsRepository(ref.watch(databaseProvider)),
);

final vocabTestRepositoryProvider = Provider<VocabTestRepository>(
  (ref) => VocabTestRepository(ref.watch(databaseProvider)),
);

/// 擬似語アセット（[Docs/06_features/vocab_size_test.md] §4）。
final pseudowordAssetsProvider = Provider<PseudowordAssets>(
  (ref) => PseudowordAssets(rootBundle),
);

/// 学習リマインダー（[Docs/06_features/reminders.md] §7）。
/// テストではフェイクに差し替え、実機の通知に依存させない。
final reminderServiceProvider = Provider<ReminderService>(
  (ref) => NotificationService(),
);

/// リマインダーの予約し直し。アプリを開いたとき・セッション終了時・設定変更時に呼ぶ。
final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => ReminderScheduler(
    ref.watch(reminderServiceProvider),
    ref.watch(studyRepositoryProvider),
    ref.watch(statsRepositoryProvider),
  ),
);

/// 通知が許可されているか（設定のトグルが見る）。
final notificationPermissionProvider = FutureProvider<bool>(
  (ref) => ref.watch(reminderServiceProvider).hasPermission(),
);

/// その学習者の日次集計（全期間）。ストリーク・学習量・正解率のもとになる。
final dailyStatsHistoryProvider = StreamProvider.family<List<DailyStat>, int>(
  (ref, profileId) =>
      ref.watch(statsRepositoryProvider).watchDailyStats(profileId),
);

/// ストリーク（[Docs/06_features/gamification.md] §2）。
///
/// 今日が未達でも、昨日まで連続していれば切れていない。
final streakProvider = Provider.family<StreakResult, int>((ref, profileId) {
  final stats = ref.watch(dailyStatsHistoryProvider(profileId)).value;
  if (stats == null) return StreakResult.zero;
  return StreakCalculator.calculate(
    stats.map((s) => DailyGoalMark(studyDate: s.studyDate, goalMet: s.goalMet)),
    today: studyDateOf(ref.watch(clockProvider)()),
  );
});

/// 直近30日の学習量（欠損日は 0 で埋める）。
final dailySeriesProvider = Provider.family<List<DailyPoint>, Profile>((
  ref,
  profile,
) {
  final stats =
      ref.watch(dailyStatsHistoryProvider(profile.id)).value ?? const [];
  return StatsAggregates.dailySeries(
    stats,
    today: studyDateOf(ref.watch(clockProvider)()),
    currentGoal: profile.dailyGoal,
  );
});

/// 累計 XP（`daily_stats.xp` の総和）とレベル。
final totalXpProvider = FutureProvider.family<int, int>(
  (ref, profileId) => ref.watch(statsRepositoryProvider).totalXp(profileId),
);

/// 習熟度の内訳（**選択中の単語帳**に限る）。
final masteryCountsProvider = FutureProvider.family<MasteryCounts, Profile>(
  (ref, profile) => ref.watch(statsRepositoryProvider).masteryCounts(profile),
);

/// 語族単位の内訳。
final familyMasteryProvider =
    FutureProvider.family<FamilyMasteryCounts, Profile>(
      (ref, profile) =>
          ref.watch(statsRepositoryProvider).familyMasteryCounts(profile),
    );

/// 苦手単語トップ20（**選択中の単語帳**に限る）。
final weakWordsProvider = FutureProvider.family<List<WeakWord>, Profile>(
  (ref, profile) => ref.watch(statsRepositoryProvider).weakWords(profile),
);

/// 直近30日のスピードモードの解答（反応時間の集計に使う）。
final speedAnswersProvider = FutureProvider.family<List<SpeedAnswer>, int>((
  ref,
  profileId,
) {
  final now = ref.watch(clockProvider)();
  return ref
      .watch(statsRepositoryProvider)
      .speedAnswers(profileId, since: now.subtract(const Duration(days: 30)));
});

/// スピードモードを一度でも実施したか（未実施ならカードごと出さない）。
final hasSpeedSessionsProvider = FutureProvider.family<bool, int>(
  (ref, profileId) =>
      ref.watch(statsRepositoryProvider).hasSpeedSessions(profileId),
);

/// よく取り違える組（[Docs/06_features/confusion_drill.md] §2）。
final confusionPairsProvider = FutureProvider.family<List<ConfusionPair>, int>(
  (ref, profileId) => ref
      .watch(modeRepositoryProvider)
      .findConfusionPairs(profileId, now: ref.watch(clockProvider)()),
);

/// 解消した取り違えの組の数（減っていることも成果として見せる）。
final resolvedConfusionCountProvider = FutureProvider.family<int, int>((
  ref,
  profileId,
) async {
  final resolved = await ref
      .watch(modeRepositoryProvider)
      .loadResolvedConfusions(profileId);
  return resolved.length;
});

/// 語彙力測定の履歴（新しい順）。
final vocabHistoryProvider = FutureProvider.family<List<VocabSizeTest>, int>(
  (ref, profileId) => ref.watch(vocabTestRepositoryProvider).history(profileId),
);

/// 実績の判定に要る集計。
final achievementStatsProvider = FutureProvider.family<AchievementStats, int>((
  ref,
  profileId,
) {
  final streak = ref.watch(streakProvider(profileId));
  return ref
      .watch(statsRepositoryProvider)
      .achievementStats(profileId, longestStreak: streak.longest);
});

/// 解除済みの実績（code → 解除日時）。
final unlockedAchievementsProvider =
    FutureProvider.family<Map<String, DateTime>, int>(
      (ref, profileId) =>
          ref.watch(statsRepositoryProvider).unlockedAchievements(profileId),
    );

/// 実績一覧（SCR-14）。未解除も条件と進捗つきで見せる。
final achievementProgressProvider =
    FutureProvider.family<List<AchievementProgress>, int>((
      ref,
      profileId,
    ) async {
      final stats = await ref.watch(achievementStatsProvider(profileId).future);
      final unlocked = await ref.watch(
        unlockedAchievementsProvider(profileId).future,
      );
      return AchievementEvaluator.progressList(stats, unlockedAt: unlocked);
    });

/// ホームの「未達の実績カード」に出す1件。
final nextAchievementProvider =
    FutureProvider.family<AchievementProgress?, int>((ref, profileId) async {
      final stats = await ref.watch(achievementStatsProvider(profileId).future);
      final unlocked = await ref.watch(
        unlockedAchievementsProvider(profileId).future,
      );
      return AchievementEvaluator.nextTarget(
        stats,
        unlockedCodes: unlocked.keys.toSet(),
      );
    });
