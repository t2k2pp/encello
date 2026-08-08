import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:encello/application/answer_submission_service.dart';
import 'package:encello/application/session_finalizer.dart';
import 'package:encello/core/utils/enums.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:encello/data/repositories/study_repository.dart';
import 'package:encello/data/repositories/wordbook_repository.dart';
import 'package:encello/domain/entities/mastery.dart';
import 'package:encello/domain/usecases/grade_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late AnswerSubmissionService service;
  late StudyRepository study;
  late Profile me;
  late Profile other;
  late int wordId;
  const sessionId = 'session-1';

  final answeredAt = DateTime(2026, 8, 3, 22);

  setUp(() async {
    db = newTestDatabase();
    service = AnswerSubmissionService(db);
    study = StudyRepository(db);
    me = await createTestProfile(db, name: 'わたし', colorSeed: 0);
    other = await createTestProfile(db, name: 'ほかのひと', colorSeed: 1);
    wordId = await createSharedWord(db, headword: 'apple', meaning: 'りんご');
    await study.startSession(
      sessionId: sessionId,
      profile: me,
      mode: StudyMode.spell.value,
      wordbookIds: const [],
      plannedCount: 20,
      startedAt: answeredAt,
    );
  });

  AnswerRecord recordOf({
    bool isCorrect = true,
    int grade = 4,
    bool isNearMiss = false,
    int hintUsed = 0,
    int elapsedMs = 3000,
    String? answeredText = 'apple',
  }) {
    return AnswerRecord(
      wordId: wordId,
      mode: StudyMode.spell,
      direction: StudyDirection.jaToEn,
      isCorrect: isCorrect,
      grade: grade,
      isNearMiss: isNearMiss,
      hintUsed: hintUsed,
      elapsedMs: elapsedMs,
      answeredText: answeredText,
    );
  }

  Future<AnswerOutcome> submit({
    AnswerRecord? record,
    int sessionCorrectStreak = 1,
    DateTime? at,
  }) {
    return service.submit(
      profile: me,
      sessionId: sessionId,
      record: record ?? recordOf(),
      answeredAt: at ?? answeredAt,
      sessionCorrectStreak: sessionCorrectStreak,
    );
  }

  group('1問1トランザクション', () {
    test('ログ・学習状態・日次集計・セッションが同時に書かれる', () async {
      final outcome = await submit();

      final log = await db.select(db.learningLogs).getSingle();
      expect(log.profileId, me.id);
      expect(log.wordId, wordId);
      expect(log.partId, isNull);
      expect(log.mode, StudyMode.spell.value);
      expect(log.grade, 4);
      expect(log.answeredText, 'apple');

      final review = await db.select(db.wordReviews).getSingle();
      expect(review.profileId, me.id);
      expect(review.repetition, 1);
      expect(review.intervalDays, 1.0);
      expect(review.dueAt, DateTime(2026, 8, 4, 4));
      expect(review.masteryLevel, Mastery.learning.level);
      expect(review.totalCorrect, 1);

      final stats = await db.select(db.dailyStats).getSingle();
      expect(stats.studyDate, '2026-08-03');
      expect(stats.answeredCount, 1);
      expect(stats.correctCount, 1);
      expect(stats.goalCount, 20);
      expect(stats.goalMet, isFalse);
      expect(stats.xp, outcome.xpEarned);

      final session = await db.select(db.studySessions).getSingle();
      expect(session.answeredCount, 1);
      expect(session.correctCount, 1);
      expect(session.xpEarned, outcome.xpEarned);
    });

    test('セッションが存在しなければ何も書かれない（外部キーで弾かれ、巻き戻る）', () async {
      await expectLater(
        service.submit(
          profile: me,
          sessionId: 'missing',
          record: recordOf(),
          answeredAt: answeredAt,
          sessionCorrectStreak: 1,
        ),
        throwsA(anything),
      );
      expect(await db.select(db.learningLogs).get(), isEmpty);
      expect(await db.select(db.wordReviews).get(), isEmpty);
      expect(await db.select(db.dailyStats).get(), isEmpty);
    });
  });

  group('学習状態', () {
    test('grade -1（時間切れ等）では学習状態を更新しない', () async {
      final outcome = await submit(
        record: recordOf(grade: GradeResolver.noUpdate, isCorrect: false),
      );
      expect(outcome.review, isNull);
      expect(await db.select(db.wordReviews).get(), isEmpty);
      // ログと集計は書く。
      expect(await db.select(db.learningLogs).get(), hasLength(1));
      expect((await db.select(db.dailyStats).getSingle()).answeredCount, 1);
    });

    test('2回目の正解で間隔が伸びる', () async {
      await submit();
      await submit(at: DateTime(2026, 8, 4, 10));

      final review = await db.select(db.wordReviews).getSingle();
      expect(review.repetition, 2);
      expect(review.intervalDays, 6.0);
      expect(review.dueAt, DateTime(2026, 8, 10, 4));
    });

    test('惜しいは不正解として数え、間隔が戻る', () async {
      await submit();
      await submit(
        record: recordOf(isCorrect: false, grade: 2, isNearMiss: true),
        at: DateTime(2026, 8, 4, 10),
      );

      final review = await db.select(db.wordReviews).getSingle();
      expect(review.repetition, 0);
      expect(review.intervalDays, 1.0);
      expect(review.totalCorrect, 1);
      expect(review.totalIncorrect, 1);
    });

    test('他の学習者の学習状態は変わらない', () async {
      await db
          .into(db.wordReviews)
          .insert(
            WordReviewsCompanion.insert(
              profileId: other.id,
              wordId: wordId,
              dueAt: DateTime(2026, 12, 1),
              masteryLevel: const Value(3),
            ),
          );

      await submit();

      final theirs = await (db.select(
        db.wordReviews,
      )..where((t) => t.profileId.equals(other.id))).getSingle();
      expect(theirs.dueAt, DateTime(2026, 12, 1));
      expect(theirs.masteryLevel, 3);
    });
  });

  group('XP と目標', () {
    test('ヒントを使うと XP が減る', () async {
      final plain = await submit();
      expect(plain.xpEarned, 15);

      final hinted = await submit(record: recordOf(hintUsed: 2));
      expect(hinted.xpEarned, 9);
    });

    test('5問連続正解でボーナスが付く', () async {
      final outcome = await submit(sessionCorrectStreak: 5);
      expect(outcome.xpEarned, 25);
    });

    test('目標に到達した瞬間だけ goalJustMet が立つ', () async {
      await db.profileDao.updateProfile(
        me.id,
        const ProfilesCompanion(dailyGoal: Value(2)),
      );
      final profile = (await db.profileDao.findById(me.id))!;

      Future<AnswerOutcome> answer() => service.submit(
        profile: profile,
        sessionId: sessionId,
        record: recordOf(),
        answeredAt: answeredAt,
        sessionCorrectStreak: 1,
      );

      expect((await answer()).goalJustMet, isFalse);
      expect((await answer()).goalJustMet, isTrue);
      // 達成後も false に戻らないが、通知は1回だけ。
      expect((await answer()).goalJustMet, isFalse);
      expect((await db.select(db.dailyStats).getSingle()).goalMet, isTrue);
    });

    test('目標を達成した解答に +50 のボーナスが付く（その日1回だけ）', () async {
      await db.profileDao.updateProfile(
        me.id,
        const ProfilesCompanion(dailyGoal: Value(2)),
      );
      final profile = (await db.profileDao.findById(me.id))!;

      Future<AnswerOutcome> answer() => service.submit(
        profile: profile,
        sessionId: sessionId,
        record: recordOf(),
        answeredAt: answeredAt,
        sessionCorrectStreak: 1,
      );

      // spell の正解は 15 XP。達成した問だけ +50 になる。
      expect((await answer()).xpEarned, 15);
      expect((await answer()).xpEarned, 65);
      expect((await answer()).xpEarned, 15);

      // 日次集計とセッションにもボーナス込みで積まれる。
      expect((await db.select(db.dailyStats).getSingle()).xp, 95);
      expect((await db.select(db.studySessions).getSingle()).xpEarned, 95);
    });

    test('その日の目標は最初の解答時点の値を使い続ける', () async {
      await submit();
      await db.profileDao.updateProfile(
        me.id,
        const ProfilesCompanion(dailyGoal: Value(100)),
      );
      final updated = (await db.profileDao.findById(me.id))!;
      await service.submit(
        profile: updated,
        sessionId: sessionId,
        record: recordOf(),
        answeredAt: answeredAt,
        sessionCorrectStreak: 2,
      );

      expect((await db.select(db.dailyStats).getSingle()).goalCount, 20);
    });

    test('学習日は 04:00 区切りで積む', () async {
      // 8/4 の深夜2時 → 学習日は 8/3。
      await submit(at: DateTime(2026, 8, 4, 2));
      expect(
        (await db.select(db.dailyStats).getSingle()).studyDate,
        '2026-08-03',
      );
    });
  });

  group('セッションの確定', () {
    test('間違えた語を結果としてまとめる', () async {
      final banana = await createSharedWord(db, headword: 'banana');
      await submit();
      await service.submit(
        profile: me,
        sessionId: sessionId,
        record: AnswerRecord(
          wordId: banana,
          mode: StudyMode.spell,
          direction: StudyDirection.jaToEn,
          isCorrect: false,
          grade: 1,
          elapsedMs: 5000,
        ),
        answeredAt: answeredAt,
        sessionCorrectStreak: 0,
      );

      final summary = await SessionFinalizer(db).finish(
        sessionId: sessionId,
        finishedAt: answeredAt.add(const Duration(minutes: 5)),
      );

      expect(summary.answeredCount, 2);
      expect(summary.correctCount, 1);
      expect(summary.accuracy, 0.5);
      expect(summary.missedWords.map((w) => w.headword), ['banana']);
      expect(summary.session.finishedAt, isNotNull);
      expect(summary.elapsed, const Duration(minutes: 5));
    });

    test('同じ語を出し直して正解したら間違えた語に残さない', () async {
      await submit(record: recordOf(isCorrect: false, grade: 1));
      await submit();

      final summary = await SessionFinalizer(
        db,
      ).finish(sessionId: sessionId, finishedAt: answeredAt);
      expect(summary.missedWords, isEmpty);
    });

    test('1問も解かずに中断したセッションは記録に残さない', () async {
      await SessionFinalizer(db).abort(sessionId);
      expect(await db.select(db.studySessions).get(), isEmpty);
    });

    test('解答済みの中断は残し、finishedAt を入れない', () async {
      await submit();
      await SessionFinalizer(db).abort(sessionId);

      final session = await db.select(db.studySessions).getSingle();
      expect(session.answeredCount, 1);
      expect(session.finishedAt, isNull);
    });
  });

  group('候補プールと復習件数', () {
    test('選んだ単語帳の語だけを候補にし、期限到来を数える', () async {
      final wordbooks = WordbookRepository(db);
      final bookId = await wordbooks.create(
        name: '単語帳',
        emoji: '📗',
        colorSeed: 2,
      );
      await wordbooks.addWord(bookId, wordId);
      await wordbooks.setStudyTarget(me, bookId, selected: true);
      final profile = (await db.profileDao.findById(me.id))!;

      expect(await study.loadCandidates(profile), hasLength(1));
      expect(await study.watchDueCount(profile, () => answeredAt).first, 0);

      await service.submit(
        profile: profile,
        sessionId: sessionId,
        record: recordOf(),
        answeredAt: answeredAt,
        sessionCorrectStreak: 1,
      );

      // 翌日 04:00 が期限。翌日の朝には期限到来として数える。
      expect(
        await study.watchDueCount(profile, () => DateTime(2026, 8, 4, 7)).first,
        1,
      );
      expect(
        await study.watchDueCount(profile, () => DateTime(2026, 8, 4, 3)).first,
        0,
      );
    });
  });
}
