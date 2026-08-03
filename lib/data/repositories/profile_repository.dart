import 'package:drift/drift.dart';

import '../../core/utils/enums.dart';
import '../../core/utils/study_date.dart';
import '../../domain/usecases/streak_calculator.dart';
import '../database/app_database.dart';
import '../database/dao/profile_dao.dart';

/// 一覧・プロファイルゲートに出す1人分の表示データ。
class ProfileOverview {
  final Profile profile;
  final ProfileSummary summary;
  final StreakResult streak;

  const ProfileOverview({
    required this.profile,
    required this.summary,
    required this.streak,
  });
}

/// 学習者の作成・更新・削除（[Docs/06_features/profiles.md]）。
///
/// 学習者の作成は「`profiles` の行」と「その人のマイ単語帳」を同時に満たす必要がある
/// （[my_words.md] §2）。画面に分散させず、ここで1トランザクションにまとめる。
class ProfileRepository {
  final AppDatabase _db;

  ProfileRepository(this._db);

  ProfileDao get _dao => _db.profileDao;

  Stream<List<Profile>> watchAll() => _dao.watchAll();

  Future<List<Profile>> getAll() => _dao.getAll();

  Future<int> count() => _dao.count();

  Future<Profile?> findById(int id) => _dao.findById(id);

  /// 学習者を作り、その人のマイ単語帳を1冊作る。作成した学習者を返す。
  Future<Profile> create({
    required String name,
    required String emoji,
    required int colorSeed,
    required String paletteId,
  }) async {
    return _db.transaction(() async {
      final id = await _dao.insertProfile(
        ProfilesCompanion.insert(
          name: name,
          emoji: Value(emoji),
          colorSeed: colorSeed,
          palette: Value(paletteId),
        ),
      );
      await _db
          .into(_db.wordbooks)
          .insert(
            WordbooksCompanion.insert(
              name: 'マイ単語',
              emoji: '📝',
              colorSeed: colorSeed,
              category: WordbookCategory.myWords.value,
              source: WordbookSource.user.value,
              ownerProfileId: Value(id),
              // プリセット単語帳より後ろに置く。
              sortOrder: const Value(1000),
            ),
          );
      final created = await _dao.findById(id);
      if (created == null) {
        throw StateError('作成した学習者を読み出せませんでした（id=$id）');
      }
      return created;
    });
  }

  /// 識別（名前・絵文字・色）の変更。
  Future<void> updateIdentity(
    int id, {
    required String name,
    required String emoji,
    required int colorSeed,
  }) {
    return _dao.updateProfile(
      id,
      ProfilesCompanion(
        name: Value(name),
        emoji: Value(emoji),
        colorSeed: Value(colorSeed),
      ),
    );
  }

  /// 表示設定・学習設定・音声設定の変更（設定画面から呼ぶ）。
  Future<void> updateSettings(int id, ProfilesCompanion patch) =>
      _dao.updateProfile(id, patch);

  Future<ProfileDeletionImpact> deletionImpact(int id) =>
      _dao.deletionImpact(id);

  /// 学習者を削除する。**最後の1人は削除できない**（FR-62）。
  /// 学習記録とマイ単語は外部キーの cascade で一緒に消える。
  Future<void> delete(int id) async {
    if (await _dao.count() <= 1) {
      throw StateError('学習者は1人以上必要です。');
    }
    await _dao.deleteProfile(id);
  }

  /// 一覧・ゲートに出す表示データ（学習中の語数・今日の進捗・ストリーク）。
  Future<List<ProfileOverview>> overviews(
    List<Profile> targets, {
    required DateTime now,
  }) async {
    final today = studyDateOf(now);
    final result = <ProfileOverview>[];
    for (final profile in targets) {
      final summary = await _dao.summaryOf(profile, today);
      final marks = await _dao.goalMarksOf(profile.id);
      result.add(
        ProfileOverview(
          profile: profile,
          summary: summary,
          streak: StreakCalculator.calculate(
            marks.map(
              (m) => DailyGoalMark(studyDate: m.studyDate, goalMet: m.goalMet),
            ),
            today: today,
          ),
        ),
      );
    }
    return result;
  }
}
