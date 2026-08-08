import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:encello/application/study_session_controller.dart';
import 'package:encello/core/utils/enums.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:encello/data/repositories/study_repository.dart';
import 'package:encello/data/repositories/wordbook_repository.dart';
import 'package:encello/domain/usecases/study_queue_builder.dart';
import 'package:encello/providers/providers.dart';
import 'package:encello/ui/screens/session_result_screen.dart';
import 'package:encello/ui/screens/spell_study_screen.dart';
import 'package:encello/ui/widgets/english_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';
import '../helpers/study_fixture.dart';
import '../helpers/test_database.dart';

/// M3 の完了条件（[Docs/09_roadmap.md]）:
/// スペルで20問のセッションを完走でき、翌日に復習として出てくる。
/// **学習画面に `EditableText` が1つも無い。**
void main() {
  late AppDatabase db;
  late Profile me;

  setUp(() async {
    db = newTestDatabase();
    me = await createTestProfile(db, name: 'たろう');
  });

  /// セッションを開始してスペル画面を描画する。
  Future<ProviderContainer> pumpStudy(
    WidgetTester tester, {
    Map<String, String> words = const {'apple': 'りんご'},
    int limit = 20,
    Size size = const Size(390, 900),
    double textScale = 1.0,
    DateTime? now,
  }) async {
    final seeded = await seedStudyTarget(db, me, headwords: words);
    final profile = seeded.profile;
    final container = await pumpWithProviders(
      tester,
      db: db,
      child: const SpellStudyScreen(),
      activeProfile: profile,
      size: size,
      textScale: textScale,
      clock: now == null ? null : () => now,
    );
    await container
        .read(studySessionProvider.notifier)
        .start(
          profile: profile,
          mode: StudyMode.spell,
          policy: QueuePolicy.reviewFirst,
          limit: limit,
        );
    await tester.pumpAndSettle();
    return container;
  }

  /// 画面上のキーボードで綴りを打つ。
  Future<void> type(WidgetTester tester, String text) async {
    for (final ch in text.split('')) {
      await tester.tap(find.widgetWithText(GestureDetector, ch).first);
      await tester.pump();
    }
  }

  group('OS キーボードを出さない（回帰テスト）', () {
    testWidgets('出題中に EditableText が1つも無い', (tester) async {
      await pumpStudy(tester);
      expect(find.byType(EditableText), findsNothing);
      expect(find.byType(EnglishKeyboard), findsOneWidget);
    });

    testWidgets('入力中も EditableText が1つも無い', (tester) async {
      await pumpStudy(tester);
      await type(tester, 'app');
      expect(find.byType(EditableText), findsNothing);
    });

    testWidgets('フィードバック中も EditableText が1つも無い', (tester) async {
      final container = await pumpStudy(tester);
      await type(tester, 'apple');
      await tester.tap(find.text('答え合わせ'));
      await tester.pumpAndSettle();

      expect(container.read(studySessionProvider)!.phase, StudyPhase.feedback);
      expect(find.byType(EditableText), findsNothing);
    });
  });

  group('入力', () {
    testWidgets('打った文字がタイルに出る', (tester) async {
      final container = await pumpStudy(tester);
      await type(tester, 'app');
      expect(container.read(studySessionProvider)!.typed, 'app');
    });

    testWidgets('正解の文字数を超えて打てない', (tester) async {
      final container = await pumpStudy(tester);
      await type(tester, 'applexyz');
      expect(container.read(studySessionProvider)!.typed, 'apple');
    });

    testWidgets('⌫ で末尾から消える', (tester) async {
      final container = await pumpStudy(tester);
      await type(tester, 'app');
      await tester.tap(find.widgetWithText(GestureDetector, '⌫').first);
      await tester.pump();
      expect(container.read(studySessionProvider)!.typed, 'ap');
    });

    testWidgets('0文字では ⌫ を押しても何も起きない', (tester) async {
      final container = await pumpStudy(tester);
      await tester.tap(find.widgetWithText(GestureDetector, '⌫').first);
      await tester.pump();
      expect(container.read(studySessionProvider)!.typed, '');
    });

    testWidgets('未入力では「答え合わせ」が無効', (tester) async {
      await pumpStudy(tester);
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, '答え合わせ'),
      );
      expect(button.onPressed, isNull);

      await type(tester, 'a');
      final enabled = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, '答え合わせ'),
      );
      expect(enabled.onPressed, isNotNull);
    });

    testWidgets('ヒントで先頭から1文字ずつ開示される', (tester) async {
      final container = await pumpStudy(tester);
      await tester.tap(find.text('ヒント'));
      await tester.pump();
      expect(container.read(studySessionProvider)!.typed, 'a');
      expect(container.read(studySessionProvider)!.hintUsed, 1);

      await tester.tap(find.text('ヒント (1)'));
      await tester.pump();
      expect(container.read(studySessionProvider)!.typed, 'ap');
      expect(container.read(studySessionProvider)!.hintUsed, 2);
    });
  });

  group('判定とフィードバック', () {
    testWidgets('正解すると正解の帯が出て、学習状態が作られる', (tester) async {
      await pumpStudy(tester, now: DateTime(2026, 8, 3, 22));
      await type(tester, 'apple');
      await tester.tap(find.text('答え合わせ'));
      await tester.pumpAndSettle();

      expect(find.text('正解'), findsOneWidget);
      final review = await db.select(db.wordReviews).getSingle();
      expect(review.totalCorrect, 1);
      // 22:00 の正解 → 翌日 04:00 が期限。
      expect(review.dueAt, DateTime(2026, 8, 4, 4));
    });

    testWidgets('1文字違いは「惜しい」と出るが正解にはしない', (tester) async {
      await pumpStudy(tester);
      await type(tester, 'appla');
      await tester.tap(find.text('答え合わせ'));
      await tester.pumpAndSettle();

      expect(find.text('惜しい'), findsOneWidget);
      expect(find.text('あなた'), findsOneWidget);
      final review = await db.select(db.wordReviews).getSingle();
      expect(review.totalCorrect, 0);
      expect(review.totalIncorrect, 1);
    });

    testWidgets('「わからない」で即座に不正解として確定する', (tester) async {
      await pumpStudy(tester);
      await tester.tap(find.text('わからない'));
      await tester.pumpAndSettle();

      expect(find.text('不正解'), findsOneWidget);
      final log = await db.select(db.learningLogs).getSingle();
      expect(log.grade, 0);
      expect(log.isCorrect, isFalse);
    });

    testWidgets('正解しても自動では進まない（既定）', (tester) async {
      final container = await pumpStudy(
        tester,
        words: const {'apple': 'りんご', 'banana': 'バナナ'},
      );
      await type(
        tester,
        container.read(studySessionProvider)!.currentWord!.headword,
      );
      await tester.tap(find.text('答え合わせ'));
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 3));
      expect(container.read(studySessionProvider)!.phase, StudyPhase.feedback);
    });

    // 今回の変更の目的そのもの（[Docs/03_data_model.md] §2.4「表示」）。
    testWidgets('例文は学習中の単語帳のものを出す', (tester) async {
      // 同じ語を2冊が別々の例文で収録し、学習対象は TOEIC の1冊だけにする。
      final books = WordbookRepository(db);
      final jhs = await books.create(name: '中学英単語', emoji: '🏫', colorSeed: 1);
      final toeic = await books.create(
        name: 'TOEIC 基礎',
        emoji: '💼',
        colorSeed: 6,
      );
      await (db.update(db.wordbooks)..where((t) => t.id.equals(jhs))).write(
        const WordbooksCompanion(presetId: Value('jhs_v1')),
      );
      await (db.update(db.wordbooks)..where((t) => t.id.equals(toeic))).write(
        const WordbooksCompanion(presetId: Value('toeic_basic_v1')),
      );

      final wordId = await db
          .into(db.words)
          .insert(
            WordsCompanion.insert(
              headword: 'apple',
              partOfSpeech: PartOfSpeech.noun.value,
              meaning: 'りんご',
            ),
          );
      await books.addWord(jhs, wordId);
      await books.addWord(toeic, wordId);
      for (final e in const [
        (source: 'jhs_v1', order: 10, en: 'I ate an apple.'),
        (source: 'toeic_basic_v1', order: 60, en: 'The apple is on sale.'),
      ]) {
        await db
            .into(db.wordExamples)
            .insert(
              WordExamplesCompanion.insert(
                wordId: wordId,
                exampleEn: e.en,
                exampleJa: const Value('和訳'),
                sourcePresetId: Value(e.source),
                sortOrder: Value(e.order),
              ),
            );
      }
      await books.setStudyTarget(me, toeic, selected: true);
      final profile = await (db.select(
        db.profiles,
      )..where((t) => t.id.equals(me.id))).getSingle();

      final container = await pumpWithProviders(
        tester,
        db: db,
        child: const SpellStudyScreen(),
        activeProfile: profile,
        size: const Size(390, 900),
      );
      await container
          .read(studySessionProvider.notifier)
          .start(
            profile: profile,
            mode: StudyMode.spell,
            policy: QueuePolicy.reviewFirst,
            limit: 20,
          );
      await tester.pumpAndSettle();

      await type(tester, 'apple');
      await tester.tap(find.text('答え合わせ'));
      await tester.pumpAndSettle();

      // 学習中の単語帳（TOEIC）の例文だけを出す。`sortOrder` の先頭ではない。
      expect(find.text('The apple is on sale.'), findsOneWidget);
      expect(find.text('I ate an apple.'), findsNothing);
    });

    testWidgets('学習中の単語帳に例文が無ければ sortOrder の先頭を出す', (tester) async {
      final seeded = await seedStudyTarget(
        db,
        me,
        exampleEn: 'I ate an apple.',
        exampleJa: 'りんごを食べました。',
      );
      final container = await pumpWithProviders(
        tester,
        db: db,
        child: const SpellStudyScreen(),
        activeProfile: seeded.profile,
        size: const Size(390, 900),
      );
      await container
          .read(studySessionProvider.notifier)
          .start(
            profile: seeded.profile,
            mode: StudyMode.spell,
            policy: QueuePolicy.reviewFirst,
            limit: 20,
          );
      await tester.pumpAndSettle();

      await type(tester, 'apple');
      await tester.tap(find.text('答え合わせ'));
      await tester.pumpAndSettle();

      expect(find.text('I ate an apple.'), findsOneWidget);
    });
  });

  group('セッションの完走', () {
    testWidgets('20問を解き切ると結果画面へ進む', (tester) async {
      // 見出し語は英字だけにする（数字・記号はキーボードに無く、最初から表示される）。
      const alphabet = 'abcdefghijklmnopqrst';
      final words = {for (var i = 0; i < 20; i++) 'word${alphabet[i]}': '訳$i'};
      final container = await pumpStudy(tester, words: words, limit: 20);

      expect(container.read(studySessionProvider)!.totalCount, 20);

      for (var i = 0; i < 20; i++) {
        final session = container.read(studySessionProvider)!;
        await type(tester, session.currentWord!.headword);
        await tester.tap(find.text('答え合わせ'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(i == 19 ? '結果を見る' : '次へ'));
        await tester.pumpAndSettle();
      }

      expect(find.byType(SessionResultScreen), findsOneWidget);
      expect(find.text('20 / 20 問正解'), findsOneWidget);

      final session = await db.select(db.studySessions).getSingle();
      expect(session.answeredCount, 20);
      expect(session.correctCount, 20);
      expect(session.finishedAt, isNotNull);
      expect(await db.select(db.wordReviews).get(), hasLength(20));
    });

    testWidgets('翌日には復習として期限が来ている', (tester) async {
      await pumpStudy(tester, now: DateTime(2026, 8, 3, 22));
      await type(tester, 'apple');
      await tester.tap(find.text('答え合わせ'));
      await tester.pumpAndSettle();

      // DB のストリームは擬似時間の外で回す（購読が残ってテストが止まらないように）。
      await tester.runAsync(() async {
        final profile = await (db.select(
          db.profiles,
        )..where((t) => t.id.equals(me.id))).getSingle();
        final study = StudyRepository(db);

        // 当日中はまだ期限が来ていない。
        expect(
          await study
              .watchDueCount(profile, () => DateTime(2026, 8, 3, 23))
              .first,
          0,
        );
        // 翌朝には復習として出てくる。
        expect(
          await study
              .watchDueCount(profile, () => DateTime(2026, 8, 4, 8))
              .first,
          1,
        );
      });
    });

    testWidgets('誤答した語はセッション中にもう一度出る', (tester) async {
      final container = await pumpStudy(tester, limit: 1);
      expect(container.read(studySessionProvider)!.totalCount, 1);

      await type(tester, 'zzzzz');
      await tester.tap(find.text('答え合わせ'));
      await tester.pumpAndSettle();

      // 末尾へ戻されたぶんキューが伸びる。
      expect(container.read(studySessionProvider)!.totalCount, 2);
      expect(find.text('次へ'), findsOneWidget);

      await tester.tap(find.text('次へ'));
      await tester.pumpAndSettle();
      expect(
        container.read(studySessionProvider)!.currentWord!.headword,
        'apple',
      );

      // 2回目も誤答したら、もう戻さない（セッションが終わらなくなる）。
      await type(tester, 'zzzzz');
      await tester.tap(find.text('答え合わせ'));
      await tester.pumpAndSettle();
      expect(container.read(studySessionProvider)!.totalCount, 2);
    });
  });

  group('オーバーフロー・マトリクス（学習画面）', () {
    // [Docs/07_testing_strategy.md] §3.1。長い見出し語・長い和訳で回す。
    const widths = <double>[320, 390, 768];
    const scales = <double>[1.0, 1.3, 1.6];

    for (final width in widths) {
      for (final scale in scales) {
        testWidgets('スペル学習 幅$width × textScaler$scale', (tester) async {
          await pumpStudy(
            tester,
            words: const {
              'internationalization': '〜を国際化する；〜に国際的な性格を与える；国際管理下に置く',
            },
            size: Size(width, 900),
            textScale: scale,
          );
          expect(tester.takeException(), isNull, reason: '出題中に溢れた');

          await type(tester, 'inter');
          expect(tester.takeException(), isNull, reason: '入力中に溢れた');

          // フィードバック帯（差分表示つき）でも溢れないことを見る。
          await tester.tap(find.text('答え合わせ'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'フィードバックで溢れた');
        });

        testWidgets('結果画面 幅$width × textScaler$scale', (tester) async {
          await pumpStudy(
            tester,
            words: const {
              'internationalization': '〜を国際化する；〜に国際的な性格を与える；国際管理下に置く',
            },
            size: Size(width, 900),
            textScale: scale,
            limit: 1,
          );
          // 誤答して「間違えた語」カードのある結果画面にする。
          await type(tester, 'x');
          await tester.tap(find.text('答え合わせ'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('次へ'));
          await tester.pumpAndSettle();
          await type(tester, 'x');
          await tester.tap(find.text('答え合わせ'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('結果を見る'));
          await tester.pumpAndSettle();

          expect(find.byType(SessionResultScreen), findsOneWidget);
          expect(tester.takeException(), isNull, reason: '結果画面で溢れた');
        });
      }
    }
  });
}
