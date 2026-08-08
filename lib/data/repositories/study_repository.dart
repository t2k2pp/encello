import 'package:drift/drift.dart';

import '../../domain/entities/review_state.dart';
import '../../domain/usecases/study_queue_builder.dart';
import '../database/app_database.dart';
import 'wordbook_repository.dart';

/// 学習セッションのための読み書き（[Docs/06_features/srs_scheduler.md] §6・§7）。
///
/// 学習に関わるメソッドは `profileId` を必須引数にする（NFR-11）。
class StudyRepository {
  final AppDatabase _db;

  StudyRepository(this._db);

  /// 出題キューの候補プール（§6.1）。
  ///
  /// [profile] が選んでいる単語帳に属し、可視範囲にあり、除外でも下書きでもない語。
  /// 同じ語が複数の単語帳に属していても、キュー生成側で1件にまとめる。
  Future<List<StudyCandidate>> loadCandidates(Profile profile) async {
    final wordbookIds = decodeIdList(profile.selectedWordbookIds);
    if (wordbookIds.isEmpty) return const [];

    final placeholders = List.filled(wordbookIds.length, '?').join(', ');
    final rows = await _db
        .customSelect(
          '''
SELECT w.id AS word_id,
       MIN(we.sort_order) AS sort_order,
       w.owner_profile_id AS owner_profile_id,
       w.created_at AS created_at,
       r.repetition AS repetition,
       r.interval_days AS interval_days,
       r.ease_factor AS ease_factor,
       r.due_at AS due_at,
       r.lapses AS lapses,
       r.correct_streak AS correct_streak,
       r.total_correct AS total_correct,
       r.total_incorrect AS total_incorrect,
       r.first_learned_at AS first_learned_at,
       r.last_reviewed_at AS last_reviewed_at
  FROM words w
  JOIN wordbook_entries we ON we.word_id = w.id
  LEFT JOIN word_reviews r ON r.word_id = w.id AND r.profile_id = ?
 WHERE we.wordbook_id IN ($placeholders)
   AND (w.owner_profile_id IS NULL OR w.owner_profile_id = ?)
   AND w.is_excluded = 0
   AND w.is_draft = 0
 GROUP BY w.id
''',
          variables: [
            Variable<int>(profile.id),
            ...wordbookIds.map(Variable<int>.new),
            Variable<int>(profile.id),
          ],
          readsFrom: {_db.words, _db.wordbookEntries, _db.wordReviews},
        )
        .get();

    return [
      for (final row in rows)
        StudyCandidate(
          wordId: row.read<int>('word_id'),
          sortOrder: row.read<int>('sort_order'),
          isOwned: row.read<int?>('owner_profile_id') != null,
          createdAt: row.read<DateTime>('created_at'),
          review: row.read<DateTime?>('due_at') == null
              ? null
              : ReviewState(
                  repetition: row.read<int>('repetition'),
                  intervalDays: row.read<double>('interval_days'),
                  easeFactor: row.read<double>('ease_factor'),
                  dueAt: row.read<DateTime>('due_at'),
                  lapses: row.read<int>('lapses'),
                  correctStreak: row.read<int>('correct_streak'),
                  totalCorrect: row.read<int>('total_correct'),
                  totalIncorrect: row.read<int>('total_incorrect'),
                  firstLearnedAt: row.read<DateTime?>('first_learned_at'),
                  lastReviewedAt: row.read<DateTime?>('last_reviewed_at'),
                ),
        ),
    ];
  }

  /// 「今日の復習 N語」の件数（§7）。候補プールのうち期限が来ている語の数。
  /// 上限を設けず実数を出す（「99+」で丸めない）。
  Stream<int> watchDueCount(Profile profile, DateTime Function() clock) {
    final wordbookIds = decodeIdList(profile.selectedWordbookIds);
    if (wordbookIds.isEmpty) return Stream.value(0);

    final placeholders = List.filled(wordbookIds.length, '?').join(', ');
    return _db
        .customSelect(
          '''
SELECT COUNT(DISTINCT w.id) AS c
  FROM words w
  JOIN wordbook_entries we ON we.word_id = w.id
  JOIN word_reviews r ON r.word_id = w.id AND r.profile_id = ?
 WHERE we.wordbook_id IN ($placeholders)
   AND (w.owner_profile_id IS NULL OR w.owner_profile_id = ?)
   AND w.is_excluded = 0
   AND w.is_draft = 0
   AND r.due_at <= ?
''',
          variables: [
            Variable<int>(profile.id),
            ...wordbookIds.map(Variable<int>.new),
            Variable<int>(profile.id),
            Variable<DateTime>(clock()),
          ],
          readsFrom: {_db.words, _db.wordbookEntries, _db.wordReviews},
        )
        .watch()
        .map((rows) => rows.single.read<int>('c'));
  }

  /// [until] までに期限が来る復習の `dueAt`（リマインダーの件数見込みに使う）。
  ///
  /// 日ごとの件数は Dart 側で数える。7日分を7回クエリしない。
  Future<List<DateTime>> dueDatesUntil(Profile profile, DateTime until) async {
    final wordbookIds = decodeIdList(profile.selectedWordbookIds);
    if (wordbookIds.isEmpty) return const [];

    final placeholders = List.filled(wordbookIds.length, '?').join(', ');
    final rows = await _db
        .customSelect(
          '''
SELECT r.due_at AS due_at
  FROM words w
  JOIN wordbook_entries we ON we.word_id = w.id
  JOIN word_reviews r ON r.word_id = w.id AND r.profile_id = ?
 WHERE we.wordbook_id IN ($placeholders)
   AND (w.owner_profile_id IS NULL OR w.owner_profile_id = ?)
   AND w.is_excluded = 0
   AND w.is_draft = 0
   AND r.due_at <= ?
 GROUP BY w.id
''',
          variables: [
            Variable<int>(profile.id),
            ...wordbookIds.map(Variable<int>.new),
            Variable<int>(profile.id),
            Variable<DateTime>(until),
          ],
          readsFrom: {_db.words, _db.wordbookEntries, _db.wordReviews},
        )
        .get();
    return [for (final row in rows) row.read<DateTime>('due_at')];
  }

  /// キューに並んだ語を id → 単語で引く（出題のたびに DB を叩かない）。
  Future<Map<int, Word>> loadWords(Iterable<int> wordIds) async {
    final ids = wordIds.toList();
    if (ids.isEmpty) return const {};
    final rows = await (_db.select(
      _db.words,
    )..where((t) => t.id.isIn(ids))).get();
    return {for (final w in rows) w.id: w};
  }

  /// セッションを開始し、その行を返す。
  Future<StudySession> startSession({
    required String sessionId,
    required Profile profile,
    required String mode,
    required List<int> wordbookIds,
    required int plannedCount,
    required DateTime startedAt,
  }) async {
    await _db
        .into(_db.studySessions)
        .insert(
          StudySessionsCompanion.insert(
            id: sessionId,
            profileId: profile.id,
            mode: mode,
            wordbookIds: Value(encodeIdList(wordbookIds)),
            startedAt: startedAt,
            plannedCount: Value(plannedCount),
          ),
        );
    return (_db.select(
      _db.studySessions,
    )..where((t) => t.id.equals(sessionId))).getSingle();
  }

  Future<StudySession?> findSession(String sessionId) => (_db.select(
    _db.studySessions,
  )..where((t) => t.id.equals(sessionId))).getSingleOrNull();

  /// その語の、その学習者の学習状態。行が無ければ null（未学習）。
  Future<WordReview?> findReview(int wordId, int profileId) =>
      (_db.select(_db.wordReviews)..where(
            (t) => t.wordId.equals(wordId) & t.profileId.equals(profileId),
          ))
          .getSingleOrNull();

  /// セッションの解答履歴（結果画面の「間違えた語」に使う）。
  Future<List<LearningLog>> logsOf(String sessionId) =>
      (_db.select(_db.learningLogs)
            ..where((t) => t.sessionId.equals(sessionId))
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .get();
}

/// `WordReview`（Drift 生成クラス）と `ReviewState`（domain の値オブジェクト）の変換。
/// [Docs/02_architecture.md] §1.3。
extension WordReviewMapping on WordReview {
  ReviewState toReviewState() => ReviewState(
    repetition: repetition,
    intervalDays: intervalDays,
    easeFactor: easeFactor,
    dueAt: dueAt,
    lapses: lapses,
    correctStreak: correctStreak,
    totalCorrect: totalCorrect,
    totalIncorrect: totalIncorrect,
    firstLearnedAt: firstLearnedAt,
    lastReviewedAt: lastReviewedAt,
  );
}
