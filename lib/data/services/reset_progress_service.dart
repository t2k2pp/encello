import 'package:drift/drift.dart';
import 'package:meta/meta.dart';

import '../database/app_database.dart';

/// リセットで消える件数（二段確認の1段目に出す。
/// [Docs/06_features/export_import.md] §5）。
@immutable
class ResetProgressCounts {
  final int wordReviews;
  final int partReviews;
  final int learningLogs;
  final int studySessions;
  final int dailyStats;
  final int achievements;
  final int vocabSizeTests;
  final int resolvedConfusions;

  const ResetProgressCounts({
    required this.wordReviews,
    required this.partReviews,
    required this.learningLogs,
    required this.studySessions,
    required this.dailyStats,
    required this.achievements,
    required this.vocabSizeTests,
    required this.resolvedConfusions,
  });

  int get total =>
      wordReviews +
      partReviews +
      learningLogs +
      studySessions +
      dailyStats +
      achievements +
      vocabSizeTests +
      resolvedConfusions;
}

/// 学習状態のリセット（[Docs/06_features/export_import.md] §5）。
///
/// **現在の学習者の分だけ**を消す。`word_reviews` / `part_reviews` /
/// `learning_logs` / `study_sessions` / `daily_stats` / `achievements` /
/// `vocab_size_tests` / `resolved_confusions` を削除し、`words` / `wordbooks` /
/// マイ単語は残す。他の学習者の記録には触れない。
class ResetProgressService {
  final AppDatabase _db;

  const ResetProgressService(this._db);

  Future<ResetProgressCounts> inspect(int profileId) async {
    return ResetProgressCounts(
      wordReviews: await _count('word_reviews', profileId),
      partReviews: await _count('part_reviews', profileId),
      learningLogs: await _count('learning_logs', profileId),
      studySessions: await _count('study_sessions', profileId),
      dailyStats: await _count('daily_stats', profileId),
      achievements: await _count('achievements', profileId),
      vocabSizeTests: await _count('vocab_size_tests', profileId),
      resolvedConfusions: await _count('resolved_confusions', profileId),
    );
  }

  Future<int> _count(String table, int profileId) async {
    final row = await _db
        .customSelect(
          'SELECT COUNT(*) AS c FROM $table WHERE profile_id = ?',
          variables: [Variable<int>(profileId)],
        )
        .getSingle();
    return row.read<int>('c');
  }

  Future<void> reset(int profileId) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.wordReviews,
      )..where((t) => t.profileId.equals(profileId))).go();
      await (_db.delete(
        _db.partReviews,
      )..where((t) => t.profileId.equals(profileId))).go();
      await (_db.delete(
        _db.learningLogs,
      )..where((t) => t.profileId.equals(profileId))).go();
      await (_db.delete(
        _db.studySessions,
      )..where((t) => t.profileId.equals(profileId))).go();
      await (_db.delete(
        _db.dailyStats,
      )..where((t) => t.profileId.equals(profileId))).go();
      await (_db.delete(
        _db.achievements,
      )..where((t) => t.profileId.equals(profileId))).go();
      await (_db.delete(
        _db.vocabSizeTests,
      )..where((t) => t.profileId.equals(profileId))).go();
      await (_db.delete(
        _db.resolvedConfusions,
      )..where((t) => t.profileId.equals(profileId))).go();
    });
  }
}
