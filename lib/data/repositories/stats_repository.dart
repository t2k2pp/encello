import 'package:drift/drift.dart';

import '../../core/utils/enums.dart';
import '../../domain/entities/achievement_stats.dart';
import '../../domain/entities/mastery.dart';
import '../../domain/usecases/study_queue_builder.dart';
import '../database/app_database.dart';
import 'wordbook_repository.dart' show decodeIdList;

/// 習熟度ごとの語数（統計カード2）。
class MasteryCounts {
  /// 習熟度 → 語数。0件の習熟度も 0 で入れる。
  final Map<Mastery, int> byMastery;

  const MasteryCounts(this.byMastery);

  int get total => byMastery.values.fold(0, (a, b) => a + b);

  /// 一度でも学習した語（未学習以外）。
  int get learned => total - (byMastery[Mastery.unlearned] ?? 0);
}

/// 語族単位の内訳（[Docs/06_features/word_families.md] §6）。
class FamilyMasteryCounts {
  /// 1語も学習していない語族。
  final int untouched;

  /// 一部だけ学習している語族。
  final int partial;

  /// 全語がマスターの語族。
  final int complete;

  const FamilyMasteryCounts({
    required this.untouched,
    required this.partial,
    required this.complete,
  });

  int get total => untouched + partial + complete;
}

/// 苦手単語トップ20の1行（統計カード7）。
class WeakWord {
  final Word word;
  final int totalAnswered;
  final int totalCorrect;
  final Mastery mastery;

  const WeakWord({
    required this.word,
    required this.totalAnswered,
    required this.totalCorrect,
    required this.mastery,
  });

  double get accuracy => totalAnswered == 0 ? 0 : totalCorrect / totalAnswered;
}

/// 反応時間の集計に渡す1解答（スピードモードのログ）。
class SpeedAnswer {
  final DateTime answeredAt;
  final int elapsedMs;
  final bool isCorrect;

  const SpeedAnswer({
    required this.answeredAt,
    required this.elapsedMs,
    required this.isCorrect,
  });
}

/// 統計・実績のための集計（[Docs/06_features/stats.md] §11）。
///
/// SQL で完結する集計だけをここに置く。複数の結果を組み合わせる計算
/// （欠損日の 0 埋め・正解率・ストリーク・反応時間の平均）は
/// `providers/stats_aggregates.dart` の純粋関数で行う。
///
/// すべてのメソッドは `profileId` を必須引数にする（NFR-11）。
class StatsRepository {
  final AppDatabase _db;

  StatsRepository(this._db);

  /// 日次集計を学習日の昇順で読む。[from] 以降（`YYYY-MM-DD` の文字列比較）。
  Future<List<DailyStat>> dailyStats(int profileId, {String? from}) {
    final query = _db.select(_db.dailyStats)
      ..where((t) => t.profileId.equals(profileId))
      ..orderBy([(t) => OrderingTerm.asc(t.studyDate)]);
    if (from != null) {
      query.where((t) => t.studyDate.isBiggerOrEqualValue(from));
    }
    return query.get();
  }

  /// 日次集計の変化に追従させたい画面（ホーム・統計）のためのストリーム。
  Stream<List<DailyStat>> watchDailyStats(int profileId, {String? from}) {
    final query = _db.select(_db.dailyStats)
      ..where((t) => t.profileId.equals(profileId))
      ..orderBy([(t) => OrderingTerm.asc(t.studyDate)]);
    if (from != null) {
      query.where((t) => t.studyDate.isBiggerOrEqualValue(from));
    }
    return query.watch();
  }

  /// 累計 XP（`daily_stats.xp` の総和。別テーブルに持たない）。
  Future<int> totalXp(int profileId) async {
    final sum = _db.dailyStats.xp.sum();
    final row =
        await (_db.selectOnly(_db.dailyStats)
              ..addColumns([sum])
              ..where(_db.dailyStats.profileId.equals(profileId)))
            .getSingle();
    return row.read(sum) ?? 0;
  }

  /// 習熟度の内訳。**選択中の単語帳**に限る（[Docs/06_features/gamification.md] §5）。
  Future<MasteryCounts> masteryCounts(Profile profile) async {
    final wordbookIds = decodeIdList(profile.selectedWordbookIds);
    final counts = {for (final m in Mastery.values) m: 0};
    if (wordbookIds.isEmpty) return MasteryCounts(counts);

    final placeholders = List.filled(wordbookIds.length, '?').join(', ');
    final rows = await _db
        .customSelect(
          '''
SELECT COALESCE(r.mastery_level, 0) AS level, COUNT(DISTINCT w.id) AS c
  FROM words w
  JOIN wordbook_entries we ON we.word_id = w.id
  LEFT JOIN word_reviews r ON r.word_id = w.id AND r.profile_id = ?
 WHERE we.wordbook_id IN ($placeholders)
   AND (w.owner_profile_id IS NULL OR w.owner_profile_id = ?)
 GROUP BY level
''',
          variables: [
            Variable<int>(profile.id),
            ...wordbookIds.map(Variable<int>.new),
            Variable<int>(profile.id),
          ],
          readsFrom: {_db.words, _db.wordbookEntries, _db.wordReviews},
        )
        .get();
    for (final row in rows) {
      counts[Mastery.fromLevel(row.read<int>('level'))] = row.read<int>('c');
    }
    return MasteryCounts(counts);
  }

  /// 語族単位の内訳。選択中の単語帳に属する語だけで語族をまとめる。
  Future<FamilyMasteryCounts> familyMasteryCounts(Profile profile) async {
    final wordbookIds = decodeIdList(profile.selectedWordbookIds);
    if (wordbookIds.isEmpty) {
      return const FamilyMasteryCounts(untouched: 0, partial: 0, complete: 0);
    }

    final placeholders = List.filled(wordbookIds.length, '?').join(', ');
    final rows = await _db
        .customSelect(
          '''
SELECT w.family_id AS family_id,
       COUNT(DISTINCT w.id) AS total,
       SUM(CASE WHEN COALESCE(r.mastery_level, 0) >= 1 THEN 1 ELSE 0 END) AS touched,
       SUM(CASE WHEN COALESCE(r.mastery_level, 0) >= 3 THEN 1 ELSE 0 END) AS mastered
  FROM words w
  JOIN wordbook_entries we ON we.word_id = w.id
  LEFT JOIN word_reviews r ON r.word_id = w.id AND r.profile_id = ?
 WHERE we.wordbook_id IN ($placeholders)
   AND (w.owner_profile_id IS NULL OR w.owner_profile_id = ?)
   AND w.family_id IS NOT NULL
 GROUP BY w.family_id
''',
          variables: [
            Variable<int>(profile.id),
            ...wordbookIds.map(Variable<int>.new),
            Variable<int>(profile.id),
          ],
          readsFrom: {_db.words, _db.wordbookEntries, _db.wordReviews},
        )
        .get();

    var untouched = 0;
    var partial = 0;
    var complete = 0;
    for (final row in rows) {
      final total = row.read<int>('total');
      final touched = row.read<int>('touched');
      final mastered = row.read<int>('mastered');
      // 「全部」は**全語がマスター**の語族だけ（[Docs/06_features/stats.md] §12）。
      if (mastered == total) {
        complete++;
      } else if (touched == 0) {
        untouched++;
      } else {
        partial++;
      }
    }
    return FamilyMasteryCounts(
      untouched: untouched,
      partial: partial,
      complete: complete,
    );
  }

  /// 苦手単語（解答10回以上かつ正解率60%未満）。正解率の昇順、同率なら解答数の降順。
  /// **選択中の単語帳**に限る。
  Future<List<WeakWord>> weakWords(Profile profile, {int limit = 20}) async {
    final wordbookIds = decodeIdList(profile.selectedWordbookIds);
    if (wordbookIds.isEmpty) return const [];

    final placeholders = List.filled(wordbookIds.length, '?').join(', ');
    final rows = await _db
        .customSelect(
          '''
SELECT w.id AS word_id,
       r.total_correct AS total_correct,
       r.total_incorrect AS total_incorrect,
       r.mastery_level AS mastery_level
  FROM words w
  JOIN wordbook_entries we ON we.word_id = w.id
  JOIN word_reviews r ON r.word_id = w.id AND r.profile_id = ?
 WHERE we.wordbook_id IN ($placeholders)
   AND (w.owner_profile_id IS NULL OR w.owner_profile_id = ?)
   AND (r.total_correct + r.total_incorrect) >= ?
   AND (r.total_correct * 1.0) / (r.total_correct + r.total_incorrect) < ?
 GROUP BY w.id
 ORDER BY (r.total_correct * 1.0) / (r.total_correct + r.total_incorrect) ASC,
          (r.total_correct + r.total_incorrect) DESC
 LIMIT ?
''',
          variables: [
            Variable<int>(profile.id),
            ...wordbookIds.map(Variable<int>.new),
            Variable<int>(profile.id),
            const Variable<int>(StudyQueueBuilder.weakMinAnswered),
            const Variable<double>(StudyQueueBuilder.weakMaxAccuracy),
            Variable<int>(limit),
          ],
          readsFrom: {_db.words, _db.wordbookEntries, _db.wordReviews},
        )
        .get();
    if (rows.isEmpty) return const [];

    final words = await loadWords(rows.map((r) => r.read<int>('word_id')));
    return [
      for (final row in rows)
        if (words[row.read<int>('word_id')] != null)
          WeakWord(
            word: words[row.read<int>('word_id')]!,
            totalAnswered:
                row.read<int>('total_correct') +
                row.read<int>('total_incorrect'),
            totalCorrect: row.read<int>('total_correct'),
            mastery: Mastery.fromLevel(row.read<int>('mastery_level')),
          ),
    ];
  }

  /// スピードモードの解答（反応時間の集計に使う）。
  Future<List<SpeedAnswer>> speedAnswers(
    int profileId, {
    required DateTime since,
  }) async {
    final rows =
        await (_db.select(_db.learningLogs)
              ..where(
                (t) =>
                    t.profileId.equals(profileId) &
                    t.mode.equals(StudyMode.speed.value) &
                    t.answeredAt.isBiggerOrEqualValue(since),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.answeredAt)]))
            .get();
    return [
      for (final row in rows)
        SpeedAnswer(
          answeredAt: row.answeredAt,
          elapsedMs: row.elapsedMs,
          isCorrect: row.isCorrect,
        ),
    ];
  }

  /// スピードモードを一度でも実施したか（カードを出すかの判定）。
  Future<bool> hasSpeedSessions(int profileId) async {
    final row =
        await (_db.select(_db.studySessions)
              ..where(
                (t) =>
                    t.profileId.equals(profileId) &
                    t.mode.equals(StudyMode.speed.value),
              )
              ..limit(1))
            .getSingleOrNull();
    return row != null;
  }

  /// 学習履歴（SCR-15）。開始が新しい順にページングする。
  Future<List<StudySession>> sessions(
    int profileId, {
    int limit = 50,
    int offset = 0,
  }) =>
      (_db.select(_db.studySessions)
            ..where((t) => t.profileId.equals(profileId))
            ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
            ..limit(limit, offset: offset))
          .get();

  /// セッションの解答一覧（履歴行を開いたときに出す）。
  Future<List<LearningLog>> sessionLogs(String sessionId) =>
      (_db.select(_db.learningLogs)
            ..where((t) => t.sessionId.equals(sessionId))
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .get();

  Future<Map<int, Word>> loadWords(Iterable<int> wordIds) async {
    final ids = wordIds.toSet().toList();
    if (ids.isEmpty) return const {};
    final rows = await (_db.select(
      _db.words,
    )..where((t) => t.id.isIn(ids))).get();
    return {for (final w in rows) w.id: w};
  }

  /// 解除済みの実績（code → 解除日時）。
  Future<Map<String, DateTime>> unlockedAchievements(int profileId) async {
    final rows = await (_db.select(
      _db.achievements,
    )..where((t) => t.profileId.equals(profileId))).get();
    return {for (final r in rows) r.code: r.unlockedAt};
  }

  /// 実績を解除済みとして記録する。すでに解除済みのものは触らない
  /// （解除日時を上書きして二重に祝わない）。
  Future<void> unlockAchievements(
    int profileId,
    Iterable<String> codes, {
    required DateTime at,
  }) async {
    for (final code in codes) {
      await _db
          .into(_db.achievements)
          .insert(
            AchievementsCompanion.insert(
              profileId: profileId,
              code: code,
              unlockedAt: at,
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }

  /// 実績の判定に要る集計をまとめて取る。
  ///
  /// [longestStreak] はストリークの計算結果（`daily_stats` から純粋関数で出す）を
  /// 呼び出し側から渡す。SQL で連続日数を数えない。
  Future<AchievementStats> achievementStats(
    int profileId, {
    required int longestStreak,
  }) async {
    final sessions =
        await (_db.select(_db.studySessions)..where(
              (t) => t.profileId.equals(profileId) & t.finishedAt.isNotNull(),
            ))
            .get();

    var bestPerfect = 0;
    int? bestSpeed;
    final modes = <StudyMode>{};
    for (final s in sessions) {
      modes.add(StudyMode.fromValue(s.mode));
      if (s.answeredCount > 0 && s.correctCount == s.answeredCount) {
        if (s.answeredCount > bestPerfect) bestPerfect = s.answeredCount;
      }
      final avg = s.avgReactionMs;
      if (avg != null && (bestSpeed == null || avg < bestSpeed)) {
        bestSpeed = avg;
      }
    }

    return AchievementStats(
      completedSessions: sessions.length,
      longestStreak: longestStreak,
      touchedWords: await _countRows(
        _db.wordReviews,
        _db.wordReviews.profileId.equals(profileId),
      ),
      masteredWords: await _countRows(
        _db.wordReviews,
        _db.wordReviews.profileId.equals(profileId) &
            _db.wordReviews.masteryLevel.equals(Mastery.mastered.level),
      ),
      bestPerfectAnswered: bestPerfect,
      spellCorrect: await _countRows(
        _db.learningLogs,
        _db.learningLogs.profileId.equals(profileId) &
            _db.learningLogs.mode.equals(StudyMode.spell.value) &
            _db.learningLogs.isCorrect.equals(true),
      ),
      familyCorrect: await _countRows(
        _db.learningLogs,
        _db.learningLogs.profileId.equals(profileId) &
            _db.learningLogs.mode.equals(StudyMode.family.value) &
            _db.learningLogs.isCorrect.equals(true),
      ),
      nightAnswers: await _countByHour(profileId, from: 0, to: 4),
      morningAnswers: await _countByHour(profileId, from: 4, to: 7),
      completedModes: modes,
      masteredParts: await _countRows(
        _db.partReviews,
        _db.partReviews.profileId.equals(profileId) &
            _db.partReviews.masteryLevel.equals(Mastery.mastered.level),
      ),
      resolvedConfusions: await _countRows(
        _db.resolvedConfusions,
        _db.resolvedConfusions.profileId.equals(profileId),
      ),
      bestSpeedAvgMs: bestSpeed,
      bestVocabSize: await _maxVocabSize(profileId),
    );
  }

  Future<int> _countRows(
    TableInfo<Table, dynamic> table,
    Expression<bool> where,
  ) async {
    final expr = countAll();
    final row =
        await (_db.selectOnly(table)
              ..addColumns([expr])
              ..where(where))
            .getSingle();
    return row.read(expr) ?? 0;
  }

  /// 時刻帯（[from] 時以上 [to] 時未満）に解いた回数。
  Future<int> _countByHour(
    int profileId, {
    required int from,
    required int to,
  }) async {
    final rows = await _db
        .customSelect(
          "SELECT COUNT(*) AS c FROM learning_logs "
          "WHERE profile_id = ? "
          "  AND CAST(strftime('%H', answered_at, 'unixepoch', 'localtime') AS INTEGER) >= ? "
          "  AND CAST(strftime('%H', answered_at, 'unixepoch', 'localtime') AS INTEGER) < ?",
          variables: [
            Variable<int>(profileId),
            Variable<int>(from),
            Variable<int>(to),
          ],
          readsFrom: {_db.learningLogs},
        )
        .getSingle();
    return rows.read<int>('c');
  }

  Future<int> _maxVocabSize(int profileId) async {
    final expr = _db.vocabSizeTests.estimatedSize.max();
    final row =
        await (_db.selectOnly(_db.vocabSizeTests)
              ..addColumns([expr])
              ..where(_db.vocabSizeTests.profileId.equals(profileId)))
            .getSingle();
    return row.read(expr) ?? 0;
  }
}
