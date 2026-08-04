import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:encello/core/utils/enums.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:encello/data/repositories/wordbook_repository.dart';
import 'package:encello/domain/usecases/study_queue_builder.dart';
import 'package:encello/ui/screens/stats_screen.dart';
import 'package:encello/ui/widgets/donut_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_database.dart';

/// SCR-10 統計（[Docs/06_features/stats.md] §12 のテスト観点）。
void main() {
  late AppDatabase db;
  late Profile me;
  late int wordbookId;

  DateTime now() => DateTime(2026, 8, 4, 20);

  setUp(() async {
    db = newTestDatabase();
    me = await createTestProfile(db, name: 'たろう');
    wordbookId = await WordbookRepository(db).create(
      name: 'テスト単語帳',
      emoji: '📗',
      colorSeed: 1,
    );
  });

  /// 単語を1語足し、学習状態を（指定があれば）作る。
  Future<int> addWord(
    String headword, {
    int? masteryLevel,
    int totalCorrect = 0,
    int totalIncorrect = 0,
  }) async {
    final wordId = await createSharedWord(db, headword: headword);
    await WordbookRepository(db).addWord(wordbookId, wordId);
    if (masteryLevel != null) {
      await db
          .into(db.wordReviews)
          .insert(
            WordReviewsCompanion.insert(
              profileId: me.id,
              wordId: wordId,
              dueAt: now(),
              masteryLevel: Value(masteryLevel),
              totalCorrect: Value(totalCorrect),
              totalIncorrect: Value(totalIncorrect),
            ),
          );
    }
    return wordId;
  }

  /// 学習対象に設定した最新のプロファイルを返す。
  Future<Profile> selectWordbook() async {
    await WordbookRepository(db).setStudyTarget(me, wordbookId, selected: true);
    return (db.select(db.profiles)..where((t) => t.id.equals(me.id)))
        .getSingle();
  }

  Future<void> pumpStats(WidgetTester tester, Profile profile) async {
    await pumpWithProviders(
      tester,
      db: db,
      child: StatsScreen(profile: profile),
      activeProfile: profile,
      wrapInScaffold: true,
      size: const Size(390, 1400),
      clock: now,
    );
    await tester.pumpAndSettle();
  }

  /// 苦手単語カードは下の方にあるため、検証の前にそこまでスクロールする。
  Future<void> scrollToWeakWords(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.textContaining('苦手単語'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('学習が0件のとき、習熟度カードが空状態になる', (tester) async {
    await addWord('apple');
    await pumpStats(tester, await selectWordbook());

    expect(find.textContaining('まだ学習の記録がありません'), findsOneWidget);
    // 円は描かない（未学習100%のドーナツを見せない）。
    expect(find.byType(DonutChart), findsNothing);
  });

  testWidgets('学習すると習熟度カードがドーナツになる', (tester) async {
    await addWord('apple', masteryLevel: 1);
    await addWord('banana');
    await pumpStats(tester, await selectWordbook());

    expect(find.byType(DonutChart), findsOneWidget);
    expect(find.textContaining('学習対象の単語帳のみ'), findsWidgets);
  });

  testWidgets('一度も測定していないとき、語彙力カードが空状態になる', (tester) async {
    await addWord('apple', masteryLevel: 1);
    await pumpStats(tester, await selectWordbook());

    expect(find.textContaining('まだ測定していません'), findsOneWidget);
  });

  testWidgets('スピードモード未実施のとき、反応の速さカードが存在しない', (tester) async {
    await addWord('apple', masteryLevel: 1);
    await pumpStats(tester, await selectWordbook());

    expect(find.text('反応の速さ'), findsNothing);
  });

  testWidgets('スピードモードを実施していれば反応の速さカードが出る', (tester) async {
    final wordId = await addWord('apple', masteryLevel: 1);
    await db
        .into(db.studySessions)
        .insert(
          StudySessionsCompanion.insert(
            id: 'speed-1',
            profileId: me.id,
            mode: StudyMode.speed.value,
            startedAt: now(),
            finishedAt: Value(now()),
            answeredCount: const Value(50),
            correctCount: const Value(48),
            avgReactionMs: const Value(950),
          ),
        );
    await db
        .into(db.learningLogs)
        .insert(
          LearningLogsCompanion.insert(
            profileId: me.id,
            sessionId: 'speed-1',
            wordId: Value(wordId),
            mode: StudyMode.speed.value,
            direction: StudyDirection.enToJa.value,
            isCorrect: true,
            grade: 4,
            elapsedMs: 900,
            answeredAt: now(),
          ),
        );

    await pumpStats(tester, await selectWordbook());
    expect(find.text('反応の速さ'), findsOneWidget);
  });

  testWidgets('取り違えの組が0件のとき、取り違えカードが存在しない', (tester) async {
    await addWord('apple', masteryLevel: 1);
    await pumpStats(tester, await selectWordbook());

    expect(find.text('よく取り違える組'), findsNothing);
  });

  group('苦手単語の条件（解答10回以上・正解率60%未満）', () {
    testWidgets('解答9回では出ない', (tester) async {
      await addWord('apple', masteryLevel: 1, totalCorrect: 3, totalIncorrect: 6);
      await pumpStats(tester, await selectWordbook());
      await scrollToWeakWords(tester);

      expect(find.textContaining('苦手な単語はありません'), findsOneWidget);
    });

    testWidgets('解答10回・正解率59%（10回中5正解）なら出る', (tester) async {
      await addWord('apple', masteryLevel: 1, totalCorrect: 5, totalIncorrect: 5);
      await pumpStats(tester, await selectWordbook());
      await scrollToWeakWords(tester);

      expect(find.textContaining('苦手単語トップ1'), findsOneWidget);
      expect(find.textContaining('10回中5正解'), findsOneWidget);
    });

    testWidgets('正解率60%ちょうどでは出ない', (tester) async {
      await addWord('apple', masteryLevel: 1, totalCorrect: 6, totalIncorrect: 4);
      await pumpStats(tester, await selectWordbook());
      await scrollToWeakWords(tester);

      expect(find.textContaining('苦手な単語はありません'), findsOneWidget);
      expect(
        StudyQueueBuilder.weakMaxAccuracy,
        0.6,
        reason: '条件を緩めていないこと',
      );
    });
  });

  testWidgets('学習対象の単語帳を外すと習熟度と苦手単語が変わる', (tester) async {
    await addWord('apple', masteryLevel: 1, totalCorrect: 5, totalIncorrect: 5);
    final selected = await selectWordbook();
    await pumpStats(tester, selected);
    await scrollToWeakWords(tester);
    expect(find.textContaining('10回中5正解'), findsOneWidget);

    await WordbookRepository(db).setStudyTarget(
      selected,
      wordbookId,
      selected: false,
    );
    final cleared =
        await (db.select(db.profiles)..where((t) => t.id.equals(me.id)))
            .getSingle();
    await pumpStats(tester, cleared);
    await scrollToWeakWords(tester);

    expect(find.textContaining('10回中5正解'), findsNothing);
    expect(find.textContaining('苦手な単語はありません'), findsOneWidget);
  });
}
