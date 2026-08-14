import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:encello/application/flashcard_controller.dart';
import 'package:encello/core/utils/enums.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:encello/domain/entities/spell_verdict.dart';
import 'package:encello/domain/usecases/spell_judge.dart';
import 'package:encello/domain/usecases/study_queue_builder.dart';
import 'package:encello/providers/providers.dart';
import 'package:encello/ui/screens/flashcard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';
import '../helpers/study_fixture.dart';
import '../helpers/test_database.dart';

/// フラッシュカードの「流し見ラウンド → 確認テスト」
/// （[Docs/06_features/flashcard_mode.md]）。
///
/// 自己評価は持たないので、成績が動くのは確認テストを解いたときだけになる。
void main() {
  late AppDatabase db;
  late Profile me;

  setUp(() async {
    db = newTestDatabase();
    me = await createTestProfile(db, name: 'たろう');
  });

  /// [count] 語（`worda`〜）の学習対象を作る。4択の誤答選択肢を組むには
  /// 同じ品詞の語が4つ以上要る。
  Map<String, String> wordsOf(int count) => {
    for (var i = 0; i < count; i++)
      'word${String.fromCharCode(97 + i)}': '訳$i',
  };

  Future<Profile> patchProfile(Profile profile, ProfilesCompanion patch) async {
    await (db.update(
      db.profiles,
    )..where((t) => t.id.equals(profile.id))).write(patch);
    return (db.select(
      db.profiles,
    )..where((t) => t.id.equals(profile.id))).getSingle();
  }

  Future<ProviderContainer> pump(WidgetTester tester, Profile profile) {
    return pumpWithProviders(
      tester,
      db: db,
      child: const FlashcardScreen(),
      activeProfile: profile,
      size: const Size(390, 900),
    );
  }

  /// 流し見のカードを最後まで送る（[FlashcardController.advance] を繰り返す）。
  /// ラウンドの末尾まで来ると確認テストへ入るのでそこで止まる。
  void browseRound(ProviderContainer container) {
    final notifier = container.read(flashcardProvider.notifier);
    while (container.read(flashcardProvider)!.phase == FlashcardPhase.showing) {
      notifier.advance();
    }
  }

  Future<int> countLogs() async =>
      (await db.select(db.learningLogs).get()).length;

  group('ラウンドと確認テスト', () {
    testWidgets('ラウンドの末尾で確認テストに入り、そのラウンドの語だけが出る', (tester) async {
      final seeded = await seedStudyTarget(db, me, headwords: wordsOf(9));
      final profile = await patchProfile(
        seeded.profile,
        const ProfilesCompanion(flashcardRoundSize: Value(3)),
      );
      final container = await pump(tester, profile);

      await container
          .read(flashcardProvider.notifier)
          .start(
            profile: profile,
            mode: FlashcardMode.silentAuto,
            testFormat: FlashcardTestFormat.choice,
            policy: QueuePolicy.reviewFirst,
            limit: 9,
          );

      final started = container.read(flashcardProvider)!;
      expect(started.roundTotal, 3);
      // 1ラウンド目に見せた語を控えておく。
      final firstRound = [
        for (var i = 0; i < 3; i++) started.queue[i].wordId,
      ];

      browseRound(container);

      final testing = container.read(flashcardProvider)!;
      expect(testing.phase, FlashcardPhase.testing);
      expect(testing.testQueue, isNotEmpty);
      // 出題は「そのラウンドで見せた語」だけ。後のラウンドの語は混ざらない。
      expect(
        testing.testQueue.map((q) => q.wordId),
        everyElement(isIn(firstRound)),
      );
    });

    testWidgets('最後のラウンドが半端な枚数でも確認テストが出る', (tester) async {
      // 8語をラウンド3で回すと 3 / 3 / 2 になる。
      final seeded = await seedStudyTarget(db, me, headwords: wordsOf(8));
      final profile = await patchProfile(
        seeded.profile,
        const ProfilesCompanion(flashcardRoundSize: Value(3)),
      );
      final container = await pump(tester, profile);
      final notifier = container.read(flashcardProvider.notifier);

      await notifier.start(
        profile: profile,
        mode: FlashcardMode.silentAuto,
        testFormat: FlashcardTestFormat.choice,
        policy: QueuePolicy.reviewFirst,
        limit: 8,
      );

      // 3ラウンド目の先頭まで進める。
      for (var round = 0; round < 2; round++) {
        browseRound(container);
        final test = container.read(flashcardProvider)!;
        expect(test.phase, FlashcardPhase.testing);
        // テストを飛ばさず解いて次のラウンドへ。
        while (container.read(flashcardProvider)!.phase ==
            FlashcardPhase.testing) {
          await notifier.answerChoice(0);
          notifier.next();
        }
      }

      final last = container.read(flashcardProvider)!;
      expect(last.roundNumber, 3);
      // 最後のラウンドは2枚しか無い。
      expect(last.roundEnd - last.roundStart + 1, 2);

      browseRound(container);
      final testing = container.read(flashcardProvider)!;
      expect(testing.phase, FlashcardPhase.testing);
      expect(testing.testQueue.length, 2);
    });

    testWidgets('テストなしは確認テストに入らず、何も記録しない', (tester) async {
      final seeded = await seedStudyTarget(db, me, headwords: wordsOf(6));
      final profile = await patchProfile(
        seeded.profile,
        const ProfilesCompanion(flashcardRoundSize: Value(3)),
      );
      final container = await pump(tester, profile);
      final notifier = container.read(flashcardProvider.notifier);

      await notifier.start(
        profile: profile,
        mode: FlashcardMode.silentAuto,
        testFormat: FlashcardTestFormat.none,
        policy: QueuePolicy.reviewFirst,
        limit: 6,
      );

      // 最後まで送っても testing を一度も通らない。
      while (container.read(flashcardProvider)!.phase !=
          FlashcardPhase.finished) {
        expect(
          container.read(flashcardProvider)!.phase,
          isNot(FlashcardPhase.testing),
        );
        notifier.advance();
      }

      // 眺めただけの語は学習状態を動かさない（FR-26）。
      expect(await countLogs(), 0);
      expect(await db.select(db.wordReviews).get(), isEmpty);
      expect(await db.select(db.dailyStats).get(), isEmpty);

      // 結果に出す枚数は「流し見した枚数」。解いた問題は0のまま。
      final session = await db.select(db.studySessions).getSingle();
      expect(session.plannedCount, 6);
      expect(session.answeredCount, 0);
    });

    testWidgets('記録が動くのは確認テストを解いたときだけ', (tester) async {
      final seeded = await seedStudyTarget(db, me, headwords: wordsOf(6));
      final profile = await patchProfile(
        seeded.profile,
        const ProfilesCompanion(flashcardRoundSize: Value(3)),
      );
      final container = await pump(tester, profile);
      final notifier = container.read(flashcardProvider.notifier);

      await notifier.start(
        profile: profile,
        mode: FlashcardMode.silentAuto,
        testFormat: FlashcardTestFormat.choice,
        policy: QueuePolicy.reviewFirst,
        limit: 6,
      );

      // 流し見の間は1件も書かれない。
      browseRound(container);
      expect(await countLogs(), 0);

      final testing = container.read(flashcardProvider)!;
      final question = testing.currentQuestion! as FlashcardChoiceQuestion;
      await notifier.answerChoice(question.question.answerIndex);

      final logs = await db.select(db.learningLogs).get();
      expect(logs.length, 1);
      // 統計上はフラッシュカードの成績として残す（§6）。
      expect(logs.single.mode, StudyMode.flashcard.value);
      expect(logs.single.isCorrect, isTrue);
      expect(logs.single.wordId, question.wordId);

      final review = await (db.select(
        db.wordReviews,
      )..where((t) => t.wordId.equals(question.wordId))).getSingle();
      expect(review.repetition, greaterThan(0));
    });

    testWidgets('スペル形式の判定は SpellJudge と一致する', (tester) async {
      final seeded = await seedStudyTarget(
        db,
        me,
        headwords: const {'apple': 'りんご'},
      );
      final profile = await patchProfile(
        seeded.profile,
        const ProfilesCompanion(flashcardRoundSize: Value(1)),
      );
      final container = await pump(tester, profile);
      final notifier = container.read(flashcardProvider.notifier);

      await notifier.start(
        profile: profile,
        mode: FlashcardMode.silentAuto,
        testFormat: FlashcardTestFormat.spell,
        policy: QueuePolicy.reviewFirst,
        limit: 1,
      );

      browseRound(container);
      expect(container.read(flashcardProvider)!.phase, FlashcardPhase.testing);

      // 1文字違いは「惜しい」。スペルモードと同じ判定を通す。
      for (final letter in 'appla'.split('')) {
        notifier.typeLetter(letter);
      }
      await notifier.submitSpell();

      final state = container.read(flashcardProvider)!;
      expect(state.verdict, SpellJudge.judge('appla', 'apple'));
      expect(state.verdict, isA<SpellNearMiss>());

      final log = await db.select(db.learningLogs).getSingle();
      expect(log.mode, StudyMode.flashcard.value);
      expect(log.answeredText, 'appla');
    });
  });
}
