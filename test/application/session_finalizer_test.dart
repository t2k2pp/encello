import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:encello/application/answer_submission_service.dart';
import 'package:encello/application/session_finalizer.dart';
import 'package:encello/application/study_launcher.dart'
    show kSpeedQuestionCount;
import 'package:encello/core/utils/enums.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:encello/data/repositories/study_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

/// セッション確定時のボーナスと実績解除
/// （[Docs/06_features/gamification.md] §3・§4）。
void main() {
  late AppDatabase db;
  late AnswerSubmissionService service;
  late StudyRepository study;
  late SessionFinalizer finalizer;
  late Profile me;
  late int wordId;

  final startedAt = DateTime(2026, 8, 4, 20);

  setUp(() async {
    db = newTestDatabase();
    service = AnswerSubmissionService(db);
    study = StudyRepository(db);
    finalizer = SessionFinalizer(db);
    me = await createTestProfile(db, name: 'たろう');
    wordId = await createSharedWord(db, headword: 'apple', meaning: 'りんご');
  });

  /// [mode] のセッションを1つ始める。
  Future<String> startSession(StudyMode mode, {int planned = 20}) async {
    final id = 'session-${mode.value}';
    await study.startSession(
      sessionId: id,
      profile: me,
      mode: mode.value,
      wordbookIds: const [],
      plannedCount: planned,
      startedAt: startedAt,
    );
    return id;
  }

  /// [count] 問を解く。
  Future<void> answerAll(
    String sessionId, {
    required StudyMode mode,
    required int count,
    bool isCorrect = true,
    int elapsedMs = 900,
  }) async {
    for (var i = 0; i < count; i++) {
      await service.submit(
        profile: me,
        sessionId: sessionId,
        record: AnswerRecord(
          wordId: wordId,
          mode: mode,
          direction: StudyDirection.enToJa,
          isCorrect: isCorrect,
          grade: isCorrect ? 4 : 1,
          elapsedMs: elapsedMs,
        ),
        answeredAt: startedAt,
        sessionCorrectStreak: isCorrect ? i + 1 : 0,
      );
    }
  }

  group('スピードの全問時間内ボーナス', () {
    test('50問すべて正解ならセッションと日次集計に +50 が付く', () async {
      final id = await startSession(
        StudyMode.speed,
        planned: kSpeedQuestionCount,
      );
      await answerAll(id, mode: StudyMode.speed, count: kSpeedQuestionCount);

      final before = (await db.select(db.studySessions).getSingle()).xpEarned;
      final dailyBefore = (await db.select(db.dailyStats).getSingle()).xp;

      await finalizer.finish(
        sessionId: id,
        finishedAt: startedAt.add(const Duration(minutes: 3)),
        avgReactionMs: 900,
      );

      expect(
        (await db.select(db.studySessions).getSingle()).xpEarned,
        before + 50,
      );
      expect((await db.select(db.dailyStats).getSingle()).xp, dailyBefore + 50);
    });

    test('1問でも落とすとボーナスは付かない', () async {
      final id = await startSession(
        StudyMode.speed,
        planned: kSpeedQuestionCount,
      );
      await answerAll(
        id,
        mode: StudyMode.speed,
        count: kSpeedQuestionCount - 1,
      );
      await answerAll(id, mode: StudyMode.speed, count: 1, isCorrect: false);

      final before = (await db.select(db.studySessions).getSingle()).xpEarned;
      await finalizer.finish(sessionId: id, finishedAt: startedAt);

      expect((await db.select(db.studySessions).getSingle()).xpEarned, before);
    });

    test('スピード以外のモードでは付かない', () async {
      final id = await startSession(StudyMode.choice);
      await answerAll(id, mode: StudyMode.choice, count: kSpeedQuestionCount);

      final before = (await db.select(db.studySessions).getSingle()).xpEarned;
      await finalizer.finish(sessionId: id, finishedAt: startedAt);

      expect((await db.select(db.studySessions).getSingle()).xpEarned, before);
    });
  });

  group('実績の解除', () {
    test('初回のセッション完了で first_session が記録される', () async {
      final id = await startSession(StudyMode.spell);
      await answerAll(id, mode: StudyMode.spell, count: 1);

      final summary = await finalizer.finish(
        sessionId: id,
        finishedAt: startedAt,
      );

      expect(
        summary.unlockedAchievements.map((d) => d.code),
        contains('first_session'),
      );
      final rows = await db.select(db.achievements).get();
      expect(rows.map((r) => r.code), contains('first_session'));
      expect(rows.every((r) => r.profileId == me.id), isTrue);
    });

    test('2回目のセッションでは同じ実績を二重に解除しない', () async {
      final first = await startSession(StudyMode.spell);
      await answerAll(first, mode: StudyMode.spell, count: 1);
      await finalizer.finish(sessionId: first, finishedAt: startedAt);

      await study.startSession(
        sessionId: 'session-2',
        profile: me,
        mode: StudyMode.spell.value,
        wordbookIds: const [],
        plannedCount: 20,
        startedAt: startedAt,
      );
      await answerAll('session-2', mode: StudyMode.spell, count: 1);
      final summary = await finalizer.finish(
        sessionId: 'session-2',
        finishedAt: startedAt,
      );

      expect(
        summary.unlockedAchievements.map((d) => d.code),
        isNot(contains('first_session')),
      );
      expect(
        (await db.select(db.achievements).get())
            .where((r) => r.code == 'first_session')
            .length,
        1,
      );
    });

    test('20問を全問正解すると perfect_20 も同時に解除される', () async {
      final id = await startSession(StudyMode.spell);
      await answerAll(id, mode: StudyMode.spell, count: 20);

      final summary = await finalizer.finish(
        sessionId: id,
        finishedAt: startedAt,
      );

      expect(
        summary.unlockedAchievements.map((d) => d.code),
        containsAll(['first_session', 'perfect_20']),
      );
    });
  });

  group('結果に出すストリーク', () {
    test('目標を達成した回はストリークと達成が返る', () async {
      await db.profileDao.updateProfile(
        me.id,
        const ProfilesCompanion(dailyGoal: Value(2)),
      );
      final profile = (await db.profileDao.findById(me.id))!;
      final id = await startSession(StudyMode.spell);
      for (var i = 0; i < 2; i++) {
        await service.submit(
          profile: profile,
          sessionId: id,
          record: AnswerRecord(
            wordId: wordId,
            mode: StudyMode.spell,
            direction: StudyDirection.enToJa,
            isCorrect: true,
            grade: 4,
            elapsedMs: 1000,
          ),
          answeredAt: startedAt,
          sessionCorrectStreak: i + 1,
        );
      }

      final summary = await finalizer.finish(
        sessionId: id,
        finishedAt: startedAt,
      );

      expect(summary.goalMetToday, isTrue);
      expect(summary.streak.current, 1);
    });

    test('未達の回は達成として返さない', () async {
      final id = await startSession(StudyMode.spell);
      await answerAll(id, mode: StudyMode.spell, count: 1);

      final summary = await finalizer.finish(
        sessionId: id,
        finishedAt: startedAt,
      );

      expect(summary.goalMetToday, isFalse);
      expect(summary.streak.current, 0);
    });
  });
}
