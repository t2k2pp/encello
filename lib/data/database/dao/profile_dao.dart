import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/profiles.dart';
import '../tables/reviews.dart';
import '../tables/study.dart';
import '../tables/words.dart';

part 'profile_dao.g.dart';

/// 学習者の削除で失われる記録の内訳（削除確認に件数を明記するため。FR-63）。
class ProfileDeletionImpact {
  /// 学習状態（`word_reviews`）の行数。
  final int reviews;

  /// 解答履歴（`learning_logs`）の行数。
  final int logs;

  /// マイ単語（`words.ownerProfileId` が一致する語）の数。
  final int myWords;

  const ProfileDeletionImpact({
    required this.reviews,
    required this.logs,
    required this.myWords,
  });

  /// 「学習記録 N件」として1つの数で示すときの合計。
  int get totalRecords => reviews + logs;
}

/// 学習者の要約（一覧・プロファイルゲートに出す）。
class ProfileSummary {
  /// 学習状態のある語数（`masteryLevel >= 1`）。
  final int learningWords;

  /// 今日（学習日 04:00 区切り）の解答数と目標。
  final int todayAnswered;
  final int todayGoal;

  const ProfileSummary({
    required this.learningWords,
    required this.todayAnswered,
    required this.todayGoal,
  });
}

/// `profiles` への読み書き（[Docs/06_features/profiles.md]）。
@DriftAccessor(tables: [Profiles, WordReviews, LearningLogs, DailyStats, Words])
class ProfileDao extends DatabaseAccessor<AppDatabase> with _$ProfileDaoMixin {
  ProfileDao(super.db);

  /// 作成順の学習者一覧。
  Stream<List<Profile>> watchAll() =>
      (select(profiles)..orderBy([(t) => OrderingTerm.asc(t.id)])).watch();

  Future<List<Profile>> getAll() =>
      (select(profiles)..orderBy([(t) => OrderingTerm.asc(t.id)])).get();

  Future<Profile?> findById(int id) =>
      (select(profiles)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> count() async {
    final expr = profiles.id.count();
    final row = await (selectOnly(profiles)..addColumns([expr])).getSingle();
    return row.read(expr)!;
  }

  Future<int> insertProfile(ProfilesCompanion entry) =>
      into(profiles).insert(entry);

  /// 学習者の設定を書き換える。`updatedAt` は常にここで更新する。
  Future<void> updateProfile(int id, ProfilesCompanion patch) async {
    final updated = await (update(profiles)..where((t) => t.id.equals(id)))
        .write(patch.copyWith(updatedAt: Value(DateTime.now())));
    if (updated == 0) {
      throw StateError('更新対象の学習者が見つかりません（id=$id）');
    }
  }

  Future<void> deleteProfile(int id) async {
    final deleted = await (delete(
      profiles,
    )..where((t) => t.id.equals(id))).go();
    if (deleted == 0) {
      throw StateError('削除対象の学習者が見つかりません（id=$id）');
    }
  }

  /// 削除で失われる記録の件数を数える（確認ダイアログに出す）。
  Future<ProfileDeletionImpact> deletionImpact(int profileId) async {
    final reviewCount = wordReviews.wordId.count();
    final reviewRow =
        await (selectOnly(wordReviews)
              ..addColumns([reviewCount])
              ..where(wordReviews.profileId.equals(profileId)))
            .getSingle();

    final logCount = learningLogs.id.count();
    final logRow =
        await (selectOnly(learningLogs)
              ..addColumns([logCount])
              ..where(learningLogs.profileId.equals(profileId)))
            .getSingle();

    final wordCount = words.id.count();
    final wordRow =
        await (selectOnly(words)
              ..addColumns([wordCount])
              ..where(words.ownerProfileId.equals(profileId)))
            .getSingle();

    return ProfileDeletionImpact(
      reviews: reviewRow.read(reviewCount)!,
      logs: logRow.read(logCount)!,
      myWords: wordRow.read(wordCount)!,
    );
  }

  /// 学習者ごとの要約（学習中の語数と今日の進捗）。
  Future<ProfileSummary> summaryOf(Profile profile, String today) async {
    final learning = wordReviews.wordId.count();
    final learningRow =
        await (selectOnly(wordReviews)
              ..addColumns([learning])
              ..where(
                wordReviews.profileId.equals(profile.id) &
                    wordReviews.masteryLevel.isBiggerOrEqualValue(1),
              ))
            .getSingle();

    final todayRow =
        await (select(dailyStats)..where(
              (t) => t.profileId.equals(profile.id) & t.studyDate.equals(today),
            ))
            .getSingleOrNull();

    return ProfileSummary(
      learningWords: learningRow.read(learning)!,
      todayAnswered: todayRow?.answeredCount ?? 0,
      // その日の目標は記録済みなら当時の値、まだ記録が無ければ現在の設定。
      todayGoal: todayRow?.goalCount ?? profile.dailyGoal,
    );
  }

  /// ストリーク計算のもとになる `(studyDate, goalMet)` の一覧。
  Future<List<DailyStat>> goalMarksOf(int profileId) =>
      (select(dailyStats)
            ..where((t) => t.profileId.equals(profileId))
            ..orderBy([(t) => OrderingTerm.asc(t.studyDate)]))
          .get();
}
