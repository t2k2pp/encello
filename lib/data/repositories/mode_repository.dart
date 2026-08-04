import 'package:drift/drift.dart';

import '../../core/utils/enums.dart';
import '../../domain/entities/mastery.dart';
import '../../domain/usecases/choice_distractors.dart';
import '../../domain/usecases/confusion_pair_finder.dart';
import '../database/app_database.dart';
import 'wordbook_repository.dart' show decodeIdList;

/// 学習モードごとに要る読み出し（4択の候補・取り違えの組など）。
class ModeRepository {
  final AppDatabase _db;

  ModeRepository(this._db);

  /// 4択の候補プール。学習対象の単語帳にある、出題できる語。
  Future<List<ChoiceCandidate>> loadChoiceCandidates(
    Profile profile, {
    /// スピードモードは**すでに学習した語だけ**を対象にする
    /// （[Docs/06_features/speed_mode.md] §3）。
    bool learnedOnly = false,
  }) async {
    final wordbookIds = decodeIdList(profile.selectedWordbookIds);
    if (wordbookIds.isEmpty) return const [];

    final placeholders = List.filled(wordbookIds.length, '?').join(', ');
    final rows = await _db
        .customSelect(
          '''
SELECT w.id AS word_id, w.headword, w.part_of_speech, w.meaning,
       we.wordbook_id AS wordbook_id,
       COALESCE(r.mastery_level, 0) AS mastery_level
  FROM words w
  JOIN wordbook_entries we ON we.word_id = w.id
  LEFT JOIN word_reviews r ON r.word_id = w.id AND r.profile_id = ?
 WHERE we.wordbook_id IN ($placeholders)
   AND (w.owner_profile_id IS NULL OR w.owner_profile_id = ?)
   AND w.is_excluded = 0 AND w.is_draft = 0
   ${learnedOnly ? 'AND COALESCE(r.mastery_level, 0) >= 1' : ''}
''',
          variables: [
            Variable<int>(profile.id),
            ...wordbookIds.map(Variable<int>.new),
            Variable<int>(profile.id),
          ],
          readsFrom: {_db.words, _db.wordbookEntries, _db.wordReviews},
        )
        .get();

    // 同じ語が複数の単語帳にあれば、所属をまとめて1件にする。
    final byId = <int, ChoiceCandidate>{};
    final books = <int, Set<int>>{};
    for (final row in rows) {
      final id = row.read<int>('word_id');
      books.putIfAbsent(id, () => {}).add(row.read<int>('wordbook_id'));
      byId[id] = ChoiceCandidate(
        wordId: id,
        headword: row.read<String>('headword'),
        meaning: row.read<String>('meaning'),
        partOfSpeech: PartOfSpeech.fromValue(row.read<String>('part_of_speech')),
        wordbookIds: books[id]!,
      );
    }
    return byId.values.toList();
  }

  /// 取り違えの検出に使う、直近の解答ログ。
  Future<List<AnsweredLog>> loadRecentLogs(
    int profileId, {
    required DateTime since,
  }) async {
    final rows =
        await (_db.select(_db.learningLogs)..where(
              (t) =>
                  t.profileId.equals(profileId) &
                  t.isCorrect.equals(false) &
                  t.answeredAt.isBiggerOrEqualValue(since),
            ))
            .get();
    return [
      for (final row in rows)
        if (row.wordId != null)
          AnsweredLog(
            wordId: row.wordId!,
            mode: StudyMode.fromValue(row.mode),
            direction: StudyDirection.fromValue(row.direction),
            isCorrect: row.isCorrect,
            answeredText: row.answeredText,
            answeredAt: row.answeredAt,
          ),
    ];
  }

  /// 逆引きに使う語（現在の学習者から見える範囲）。
  Future<List<ConfusionWord>> loadConfusionWords(int profileId) async {
    final rows =
        await (_db.select(_db.words)..where(
              (t) =>
                  t.ownerProfileId.isNull() |
                  t.ownerProfileId.equals(profileId),
            ))
            .get();
    return [
      for (final w in rows)
        ConfusionWord(
          wordId: w.id,
          headword: w.headword,
          meaning: w.meaning,
          isStudiable: !w.isExcluded && !w.isDraft,
        ),
    ];
  }

  /// 解消済みの取り違えの組。
  Future<Set<({int a, int b})>> loadResolvedConfusions(int profileId) async {
    final rows =
        await (_db.select(_db.resolvedConfusions)
              ..where((t) => t.profileId.equals(profileId)))
            .get();
    return {for (final r in rows) (a: r.wordIdA, b: r.wordIdB)};
  }

  /// 取り違えドリルの出題に要る語の付随情報（品詞ラベルと覚え方のメモ）。
  Future<({Map<int, String> labels, Map<int, String?> notes})>
  loadConfusionDetails(Iterable<int> wordIds) async {
    final ids = wordIds.toList();
    if (ids.isEmpty) return (labels: <int, String>{}, notes: <int, String?>{});
    final rows = await (_db.select(_db.words)
          ..where((t) => t.id.isIn(ids)))
        .get();
    return (
      labels: {
        for (final w in rows)
          w.id: PartOfSpeech.fromValue(w.partOfSpeech).label,
      },
      notes: {for (final w in rows) w.id: w.confusionNote},
    );
  }

  /// その学習者の取り違えの組を数える（モード選択に出すかの判定に使う）。
  Future<List<ConfusionPair>> findConfusionPairs(
    int profileId, {
    required DateTime now,
  }) async {
    final logs = await loadRecentLogs(
      profileId,
      since: now.subtract(
        const Duration(days: ConfusionPairFinder.withinDays),
      ),
    );
    if (logs.isEmpty) return const [];
    return ConfusionPairFinder.find(
      logs: logs,
      words: await loadConfusionWords(profileId),
      now: now,
      resolved: await loadResolvedConfusions(profileId),
    );
  }

  /// 取り違えの組で5回連続正解したら解消済みにする（§6）。
  /// 解消後にまた誤答したら記録を消して復活させる。
  Future<void> updateConfusionResolution({
    required int profileId,
    required int wordIdA,
    required int wordIdB,
    required bool isCorrect,
    required DateTime now,
  }) async {
    final key = ConfusionPairFinder.normalize(wordIdA, wordIdB);
    if (!isCorrect) {
      await (_db.delete(_db.resolvedConfusions)..where(
            (t) =>
                t.profileId.equals(profileId) &
                t.wordIdA.equals(key.a) &
                t.wordIdB.equals(key.b),
          ))
          .go();
      return;
    }

    // 直近の連続正解数を、その組の出題ログから数える。
    final logs =
        await (_db.select(_db.learningLogs)
              ..where(
                (t) =>
                    t.profileId.equals(profileId) &
                    t.mode.equals(StudyMode.confusion.value) &
                    (t.wordId.equals(key.a) | t.wordId.equals(key.b)),
              )
              ..orderBy([
                (t) => OrderingTerm.desc(t.id),
              ])
              ..limit(kConfusionResolveStreak))
            .get();
    if (logs.length < kConfusionResolveStreak) return;
    if (logs.any((l) => !l.isCorrect)) return;

    await _db
        .into(_db.resolvedConfusions)
        .insertOnConflictUpdate(
          ResolvedConfusionsCompanion.insert(
            profileId: profileId,
            wordIdA: key.a,
            wordIdB: key.b,
            resolvedAt: Value(now),
          ),
        );
  }

  /// 語の習熟度（スピードの対象判定などに使う）。
  Future<Map<int, Mastery>> masteryOf(int profileId) async {
    final rows =
        await (_db.select(_db.wordReviews)
              ..where((t) => t.profileId.equals(profileId)))
            .get();
    return {
      for (final r in rows) r.wordId: Mastery.fromLevel(r.masteryLevel),
    };
  }
}

/// 何回連続で正解したら組を解消済みにするか（[Docs/06_features/confusion_drill.md] §6）。
const kConfusionResolveStreak = 5;
