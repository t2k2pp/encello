import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:encello/data/database/app_database.dart';
import 'package:encello/data/repositories/wordbook_repository.dart';
import 'package:encello/data/seeds/pseudoword_assets.dart';
import 'package:encello/ui/screens/vocab_test_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_asset_bundle.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_database.dart';

/// SCR-18 語彙力測定の1周
/// （[Docs/04_screens_and_flows.md] §4.13、[Docs/06_features/vocab_size_test.md]）。
void main() {
  late AppDatabase db;
  late Profile me;
  late int bandId;

  DateTime now() => DateTime(2026, 8, 4, 20);

  /// 擬似語は実アセットではなくテスト用の10語に差し替える。
  ///
  /// `CachingAssetBundle` は読み込んだ Future を持ち続けるため、テストごとに
  /// 作り直す（使い回すと2件目以降で解決しない Future を待ち続ける）。
  late PseudowordAssets pseudowords;

  setUp(() async {
    pseudowords = PseudowordAssets(
      FakeAssetBundle({
        PseudowordAssets.assetPath: jsonEncode({
          'formatVersion': 1,
          'words': [for (var i = 0; i < 10; i++) 'zzpseudo$i'],
        }),
      }),
    );
    db = newTestDatabase();
    me = await createTestProfile(db, name: 'たろう');
    bandId = await db
        .into(db.wordbooks)
        .insert(
          WordbooksCompanion.insert(
            name: '中学英単語',
            emoji: '🏫',
            colorSeed: 1,
            category: 'juniorHigh',
            source: 'preset',
            presetId: const Value('jhs_v1'),
            bandSize: const Value(1600),
            sortOrder: const Value(10),
          ),
        );
    for (var i = 0; i < 12; i++) {
      final wordId = await createSharedWord(db, headword: 'word$i');
      await WordbookRepository(db).addWord(bandId, wordId);
    }
  });

  Future<void> pumpTest(WidgetTester tester) async {
    await pumpWithProviders(
      tester,
      db: db,
      child: VocabTestScreen(profile: me),
      activeProfile: me,
      clock: now,
      size: const Size(390, 900),
      pseudowords: pseudowords,
    );
    await tester.pumpAndSettle();
  }

  /// 残りの問題にすべて [label] で答える。
  Future<void> answerAll(WidgetTester tester, String label) async {
    // 帯8問＋擬似語10問。押すたびに次の問題へ進む（送りの演出は入れない）。
    for (var i = 0; i < 18; i++) {
      final button = find.widgetWithText(
        label == 'わかる' ? FilledButton : OutlinedButton,
        label,
      );
      if (button.evaluate().isEmpty) break;
      await tester.tap(button);
      await tester.pumpAndSettle();
    }
  }

  testWidgets('18問（帯8＋擬似語10）を出し、擬似語であることは伏せる', (tester) async {
    await pumpTest(tester);

    expect(find.text('1 / 18'), findsOneWidget);
    expect(find.text('意味が言えますか？'), findsOneWidget);
    // 出題中に擬似語の存在を明かさない。
    expect(find.textContaining('実在しない語'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'わかる'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 18'), findsOneWidget);
  });

  testWidgets('最後まで答えると結果が出て、測定が保存される', (tester) async {
    await pumpTest(tester);
    await answerAll(tester, 'わかる');

    expect(find.text('あなたの語彙力'), findsOneWidget);
    // 実在語8問すべてに「わかる」、擬似語10問すべてにも「わかる」→ f = 1 で 0 語。
    expect(find.textContaining('推定 0 語'), findsOneWidget);
    expect(find.textContaining('実在しない語が10問混ざっていました'), findsOneWidget);

    final saved = await db.select(db.vocabSizeTests).getSingle();
    expect(saved.profileId, me.id);
    expect(saved.falseAlarmRate, 1);
    expect(saved.takenAt, now());
  });

  testWidgets('測定しても word_reviews は作られない（測定は学習ではない）', (tester) async {
    await pumpTest(tester);
    await answerAll(tester, 'わかる');

    expect(await db.select(db.wordReviews).get(), isEmpty);
  });

  testWidgets('推奨単語帳をそのまま学習対象にできる', (tester) async {
    await pumpTest(tester);
    // 実在語には「わからない」、擬似語にも「わからない」→ f = 0 で帯は 0%。
    await answerAll(tester, 'わからない');

    expect(find.text('次に取り組むとよい単語帳'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.widgetWithText(FilledButton, 'この単語帳を学習対象にする'),
      200,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'この単語帳を学習対象にする'));
    await tester.pumpAndSettle();

    final updated = await (db.select(
      db.profiles,
    )..where((t) => t.id.equals(me.id))).getSingle();
    expect(decodeIdList(updated.selectedWordbookIds), contains(bandId));
    // 押したあとは二度押させない。
    expect(find.text('学習対象にしました'), findsOneWidget);
  });

  testWidgets('押さなければ学習対象は変わらない', (tester) async {
    await pumpTest(tester);
    await answerAll(tester, 'わからない');

    final updated = await (db.select(
      db.profiles,
    )..where((t) => t.id.equals(me.id))).getSingle();
    expect(decodeIdList(updated.selectedWordbookIds), isEmpty);
  });

  testWidgets('途中でやめると測定は保存されない', (tester) async {
    await pumpTest(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'わかる'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'やめる'));
    await tester.pumpAndSettle();

    expect(await db.select(db.vocabSizeTests).get(), isEmpty);
  });

  testWidgets('帯の語が足りなければ測定を始めない', (tester) async {
    // 帯の語を2語だけにする（下限は8語）。
    final words = await db.select(db.words).get();
    for (final word in words.skip(2)) {
      await (db.delete(
        db.wordbookEntries,
      )..where((t) => t.wordId.equals(word.id))).go();
    }

    await pumpTest(tester);
    expect(find.textContaining('まだ語彙力を測れません'), findsOneWidget);
  });
}
