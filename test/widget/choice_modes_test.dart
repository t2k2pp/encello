import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:encello/application/study_launcher.dart';
import 'package:encello/application/study_session_controller.dart'
    show StudyPhase, StudyStartFailure;
import 'package:encello/core/utils/enums.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:encello/domain/usecases/study_queue_builder.dart';
import 'package:encello/providers/audio.dart';
import 'package:encello/providers/providers.dart';
import 'package:encello/ui/screens/choice_study_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';
import '../helpers/study_fixture.dart';
import '../helpers/test_database.dart';

/// 4択・スピード・取り違えの出し分けと記録
/// （[Docs/06_features/quiz_mode.md] / [speed_mode.md] / [confusion_drill.md]）。
void main() {
  late AppDatabase db;
  late Profile me;

  setUp(() async {
    db = newTestDatabase();
    me = await createTestProfile(db, name: 'たろう');
  });

  Map<String, String> wordsOf(int count) => {
    for (var i = 0; i < count; i++)
      'word${String.fromCharCode(97 + i ~/ 26)}${String.fromCharCode(97 + i % 26)}':
          '訳$i',
  };

  Future<ProviderContainer> pump(
    WidgetTester tester,
    Profile profile,
  ) async {
    final container = await pumpWithProviders(
      tester,
      db: db,
      child: const ChoiceStudyScreen(),
      activeProfile: profile,
      size: const Size(390, 900),
    );
    return container;
  }

  group('4択クイズ', () {
    testWidgets('候補が4語未満なら開始できない（ダミーで埋めない）', (tester) async {
      final seeded = await seedStudyTarget(
        db,
        me,
        headwords: const {'apple': 'りんご', 'banana': 'バナナ'},
      );
      final container = await pump(tester, seeded.profile);

      await expectLater(
        container
            .read(studyLauncherProvider)
            .start(
              profile: seeded.profile,
              mode: StudyMode.choice,
              policy: QueuePolicy.reviewFirst,
              limit: 10,
            ),
        throwsA(isA<StudyStartFailure>()),
      );
    });

    testWidgets('4択で解答すると記録され、正解でも grade は 4 まで', (tester) async {
      final seeded = await seedStudyTarget(db, me, headwords: wordsOf(6));
      final container = await pump(tester, seeded.profile);

      await container
          .read(studyLauncherProvider)
          .start(
            profile: seeded.profile,
            mode: StudyMode.choice,
            policy: QueuePolicy.reviewFirst,
            limit: 3,
          );
      await tester.pumpAndSettle();

      final session = container.read(choiceSessionProvider)!;
      expect(session.totalCount, 3);
      expect(session.current!.options, hasLength(4));

      await container
          .read(choiceSessionProvider.notifier)
          .answer(session.current!.answerIndex);
      await tester.pumpAndSettle();

      final log = await db.select(db.learningLogs).getSingle();
      expect(log.mode, StudyMode.choice.value);
      expect(log.isCorrect, isTrue);
      expect(log.grade, 4);
      // 選んだ選択肢を残す（後から取り違え検出に使う）。
      expect(log.answeredText, isNotNull);
    });

    testWidgets('誤答を選ぶと正解と誤答の両方が示される', (tester) async {
      final seeded = await seedStudyTarget(db, me, headwords: wordsOf(6));
      final container = await pump(tester, seeded.profile);
      await container
          .read(studyLauncherProvider)
          .start(
            profile: seeded.profile,
            mode: StudyMode.choice,
            policy: QueuePolicy.reviewFirst,
            limit: 1,
          );
      await tester.pumpAndSettle();

      final question = container.read(choiceSessionProvider)!.current!;
      final wrongIndex = (question.answerIndex + 1) % 4;
      await container.read(choiceSessionProvider.notifier).answer(wrongIndex);
      await tester.pumpAndSettle();

      // 正解を ✓ で、選んだ誤答を ✕ で示す（✕ は中断ボタンにもあるので2つ）。
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNWidgets(2));
      final after = container.read(choiceSessionProvider)!;
      expect(after.phase, StudyPhase.feedback);
      expect(after.selectedIndex, wrongIndex);
      expect(after.correctCount, 0);
    });
  });

  group('スピードモード', () {
    testWidgets('学習済みが20語未満なら選択肢に出ない', (tester) async {
      final seeded = await seedStudyTarget(db, me, headwords: wordsOf(30));
      final container = await pump(tester, seeded.profile);

      final modes = await container.read(
        availableModesProvider(seeded.profile).future,
      );
      expect(modes, contains(StudyMode.choice));
      // まだ1語も学習していないのでスピードは出ない。
      expect(modes, isNot(contains(StudyMode.speed)));
    });

    testWidgets('学習済みが20語あれば選べる', (tester) async {
      final seeded = await seedStudyTarget(db, me, headwords: wordsOf(25));
      final words = await db.select(db.words).get();
      for (final w in words.take(20)) {
        await db
            .into(db.wordReviews)
            .insert(
              WordReviewsCompanion.insert(
                profileId: me.id,
                wordId: w.id,
                dueAt: DateTime(2026, 8, 4, 4),
                masteryLevel: const Value(1),
              ),
            );
      }
      final container = await pump(tester, seeded.profile);

      final modes = await container.read(
        availableModesProvider(seeded.profile).future,
      );
      expect(modes, contains(StudyMode.speed));
    });

    testWidgets('時間切れは学習状態を更新せず、ログには grade -1 で残す', (tester) async {
      final seeded = await seedStudyTarget(db, me, headwords: wordsOf(25));
      final words = await db.select(db.words).get();
      for (final w in words.take(20)) {
        await db
            .into(db.wordReviews)
            .insert(
              WordReviewsCompanion.insert(
                profileId: me.id,
                wordId: w.id,
                dueAt: DateTime(2026, 8, 4, 4),
                masteryLevel: const Value(1),
              ),
            );
      }
      final container = await pump(tester, seeded.profile);
      await container
          .read(studyLauncherProvider)
          .start(
            profile: seeded.profile,
            mode: StudyMode.speed,
            policy: QueuePolicy.reviewFirst,
            limit: 50,
          );
      await tester.pumpAndSettle();

      final before = await db.select(db.wordReviews).get();
      await container
          .read(choiceSessionProvider.notifier)
          .answer(null, timedOut: true);
      await tester.pumpAndSettle();

      final log = await db.select(db.learningLogs).getSingle();
      expect(log.grade, -1);
      expect(log.isCorrect, isFalse);

      // 学習状態は動かない（「知らない」ではなく「遅い」ため）。
      final after = await db.select(db.wordReviews).get();
      expect(after.length, before.length);
      expect(
        after.map((r) => r.dueAt).toList(),
        before.map((r) => r.dueAt).toList(),
      );
      // 平均は時間内に正解した問題だけで取るので、まだ null。
      expect(container.read(choiceSessionProvider)!.averageReactionMs, isNull);
    });

    testWidgets('未学習の語は出題されない', (tester) async {
      final seeded = await seedStudyTarget(db, me, headwords: wordsOf(25));
      final words = await db.select(db.words).get();
      final learned = words.take(20).map((w) => w.id).toSet();
      for (final id in learned) {
        await db
            .into(db.wordReviews)
            .insert(
              WordReviewsCompanion.insert(
                profileId: me.id,
                wordId: id,
                dueAt: DateTime(2026, 8, 4, 4),
                masteryLevel: const Value(1),
              ),
            );
      }
      final container = await pump(tester, seeded.profile);
      await container
          .read(studyLauncherProvider)
          .start(
            profile: seeded.profile,
            mode: StudyMode.speed,
            policy: QueuePolicy.reviewFirst,
            limit: 50,
          );
      await tester.pumpAndSettle();

      final session = container.read(choiceSessionProvider)!;
      expect(
        session.questions.every((q) => learned.contains(q.wordId)),
        isTrue,
      );
    });
  });

  group('取り違えドリル', () {
    /// affect / effect を2回取り違えた履歴を作る。
    Future<Profile> seedConfusion() async {
      final seeded = await seedStudyTarget(
        db,
        me,
        headwords: const {
          'affect': '〜に影響を与える',
          'effect': '影響・効果',
          'accept': '受け入れる',
          'except': '〜を除いて',
        },
      );
      final words = await db.select(db.words).get();
      final affect = words.firstWhere((w) => w.headword == 'affect');

      await db
          .into(db.studySessions)
          .insert(
            StudySessionsCompanion.insert(
              id: 'past',
              profileId: me.id,
              mode: StudyMode.choice.value,
              startedAt: DateTime(2026, 8, 1),
            ),
          );
      for (var i = 0; i < 2; i++) {
        await db
            .into(db.learningLogs)
            .insert(
              LearningLogsCompanion.insert(
                profileId: me.id,
                sessionId: 'past',
                wordId: Value(affect.id),
                mode: StudyMode.choice.value,
                direction: StudyDirection.enToJa.value,
                isCorrect: false,
                grade: 1,
                answeredText: const Value('影響・効果'),
                elapsedMs: 3000,
                answeredAt: DateTime(2026, 8, 2),
              ),
            );
      }
      return seeded.profile;
    }

    testWidgets('組が0件ならモード選択に出ない', (tester) async {
      final seeded = await seedStudyTarget(db, me, headwords: wordsOf(6));
      final container = await pump(tester, seeded.profile);
      final modes = await container.read(
        availableModesProvider(seeded.profile).future,
      );
      expect(modes, isNot(contains(StudyMode.confusion)));
    });

    testWidgets('組があれば2択で出題され、両方の訳が示される', (tester) async {
      final profile = await seedConfusion();
      final container = await pumpWithProviders(
        tester,
        db: db,
        child: const ChoiceStudyScreen(),
        activeProfile: profile,
        size: const Size(390, 900),
        clock: () => DateTime(2026, 8, 4),
      );

      final modes = await container.read(
        availableModesProvider(profile).future,
      );
      expect(modes, contains(StudyMode.confusion));

      await container
          .read(studyLauncherProvider)
          .start(
            profile: profile,
            mode: StudyMode.confusion,
            policy: QueuePolicy.reviewFirst,
            limit: 10,
          );
      await tester.pumpAndSettle();

      final session = container.read(choiceSessionProvider)!;
      // 2語を必ず並べて出す。
      expect(session.current!.options, hasLength(2));
      // 両方向を対で出す。
      expect(session.totalCount, 2);

      await container
          .read(choiceSessionProvider.notifier)
          .answer(session.current!.answerIndex);
      await tester.pumpAndSettle();

      // 解答後に両方の語の訳と品詞を並べて示す。
      expect(find.textContaining('affect'), findsWidgets);
      expect(find.textContaining('effect'), findsWidgets);
    });

    testWidgets('誤答すると両方の語の学習状態が下がる', (tester) async {
      final profile = await seedConfusion();
      final container = await pumpWithProviders(
        tester,
        db: db,
        child: const ChoiceStudyScreen(),
        activeProfile: profile,
        size: const Size(390, 900),
        clock: () => DateTime(2026, 8, 4),
      );
      await container
          .read(studyLauncherProvider)
          .start(
            profile: profile,
            mode: StudyMode.confusion,
            policy: QueuePolicy.reviewFirst,
            limit: 10,
          );
      await tester.pumpAndSettle();

      final question = container.read(choiceSessionProvider)!.current!;
      final wrongIndex = (question.answerIndex + 1) % 2;
      await container.read(choiceSessionProvider.notifier).answer(wrongIndex);
      await tester.pumpAndSettle();

      // 出題した語と相手の語の両方が更新される。
      final reviews = await db.select(db.wordReviews).get();
      expect(reviews, hasLength(2));
      expect(reviews.every((r) => r.totalIncorrect == 1), isTrue);
      // ログは出題した語の分だけ（解答は1回だから）。
      final logs =
          await (db.select(db.learningLogs)
                ..where((t) => t.mode.equals(StudyMode.confusion.value)))
              .get();
      expect(logs, hasLength(1));
    });
  });
}
