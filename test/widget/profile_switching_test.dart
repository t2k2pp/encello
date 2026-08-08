import 'package:drift/drift.dart' show Value;
import 'package:encello/app.dart';
import 'package:encello/core/theme/app_colors.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:encello/providers/providers.dart';
import 'package:encello/ui/screens/home_screen.dart';
import 'package:encello/ui/screens/profile_gate_screen.dart';
import 'package:encello/ui/screens/root_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_database.dart';

/// M1 の完了条件（[Docs/09_roadmap.md]）:
/// 学習者を2人作って切り替えると、配色と設定が入れ替わる。
void main() {
  late AppDatabase db;

  setUp(() {
    db = newTestDatabase();
    // SharedPreferences の実装を待って無言で止まらないよう必ずモック初期化する。
    SharedPreferences.setMockInitialValues({});
  });

  Future<ProviderContainer> pumpApp(
    WidgetTester tester, {
    Map<String, Object> prefs = const {},
  }) async {
    SharedPreferences.setMockInitialValues(prefs);
    final sharedPrefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        sharedPrefsProvider.overrideWithValue(sharedPrefs),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const EncelloApp(),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  group('プロファイルゲート（SCR-00）', () {
    testWidgets('学習者が0人なら登録を促す', (tester) async {
      await pumpApp(tester);
      expect(find.text('encello へようこそ'), findsOneWidget);
      expect(find.text('学習者を登録する'), findsOneWidget);
    });

    testWidgets('学習者が1人なら選択画面を出さずホームへ進む', (tester) async {
      await createTestProfile(db, name: 'ひとり');
      final container = await pumpApp(tester);

      expect(find.byType(ProfileGateScreen), findsNothing);
      expect(find.byType(RootShell), findsOneWidget);
      expect(container.read(activeProfileProvider)!.name, 'ひとり');
    });

    testWidgets('学習者が2人以上なら選択画面を出し、前回の人を先頭に置く', (tester) async {
      await createTestProfile(db, name: 'あに', colorSeed: 0);
      final b = await createTestProfile(db, name: 'おとうと', colorSeed: 1);

      await pumpApp(tester, prefs: {kLastActiveProfileKey: b.id});

      expect(find.text('だれが学習しますか？'), findsOneWidget);
      expect(find.text('前回'), findsOneWidget);

      // 先頭のカードが前回使った人になっている。
      final firstName = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .firstWhere((s) => s == 'あに' || s == 'おとうと');
      expect(firstName, 'おとうと');
    });

    testWidgets('カードをタップするとその学習者でホームへ進む', (tester) async {
      await createTestProfile(db, name: 'あに', colorSeed: 0);
      await createTestProfile(db, name: 'おとうと', colorSeed: 1);
      final container = await pumpApp(tester);

      await tester.tap(find.text('おとうと'));
      await tester.pumpAndSettle();

      expect(find.byType(RootShell), findsOneWidget);
      expect(container.read(activeProfileProvider)!.name, 'おとうと');
    });
  });

  group('学習者の切り替えで配色と設定が入れ替わる', () {
    testWidgets('配色・文字サイズ・デイリー目標が学習者ごとに切り替わる', (tester) async {
      final a = await createTestProfile(
        db,
        name: 'あに',
        colorSeed: 0,
        paletteId: 'blue',
      );
      final b = await createTestProfile(
        db,
        name: 'おとうと',
        colorSeed: 1,
        paletteId: 'green',
      );
      // 学習設定・表示設定も別々にしておく。
      await db.profileDao.updateProfile(
        a.id,
        const ProfilesCompanion(
          textScale: Value('large'),
          dailyGoal: Value(50),
        ),
      );
      await db.profileDao.updateProfile(
        b.id,
        const ProfilesCompanion(
          textScale: Value('small'),
          dailyGoal: Value(10),
        ),
      );

      final container = await pumpApp(tester);

      // あに を選ぶ
      await tester.tap(find.text('あに'));
      await tester.pumpAndSettle();
      expect(AppColors.accent, bluePalette.accent);
      expect(container.read(activeProfileProvider)!.textScale, 'large');
      expect(container.read(activeProfileProvider)!.dailyGoal, 50);

      // ホーム右上のアバターからゲートへ戻る
      await tester.tap(find.byTooltip('学習者を切り替える'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileGateScreen), findsOneWidget);
      // 未選択の間はアプリの既定配色（ピンク）に戻る
      expect(AppColors.accent, pinkPalette.accent);

      // おとうと を選ぶと配色も設定も入れ替わる
      await tester.tap(find.text('おとうと'));
      await tester.pumpAndSettle();
      expect(AppColors.accent, greenPalette.accent);
      expect(container.read(activeProfileProvider)!.textScale, 'small');
      expect(container.read(activeProfileProvider)!.dailyGoal, 10);
    });

    testWidgets('ホームには現在の学習者の名前が出る', (tester) async {
      await createTestProfile(db, name: 'たろう');
      await pumpApp(tester);

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('たろう さん'), findsOneWidget);
    });
  });
}
