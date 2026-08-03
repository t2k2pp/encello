import 'package:encello/data/database/app_database.dart';
import 'package:encello/ui/screens/dictionary_screen.dart';
import 'package:encello/ui/screens/home_screen.dart';
import 'package:encello/ui/screens/profile_gate_screen.dart';
import 'package:encello/ui/screens/profiles_screen.dart';
import 'package:encello/ui/screens/root_shell.dart';
import 'package:encello/ui/screens/settings_screen.dart';
import 'package:encello/ui/screens/stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_database.dart';

/// オーバーフロー・マトリクス（[Docs/07_testing_strategy.md] §3.1、NFR-05）。
///
/// **幅 320 / 390 / 768 dp × textScaler 1.0 / 1.3 / 1.6** の9通りを主要画面に回し、
/// `tester.takeException()` が null であることを確認する。
/// 学習者名には上限いっぱいの20文字を使う。
void main() {
  const widths = <double>[320, 390, 768];
  const scales = <double>[1.0, 1.3, 1.6];

  /// 20文字の学習者名（`profiles.name` の上限）。
  const longName = 'あいうえおかきくけこさしすせそたちつてと';
  const longName2 = 'なにぬねのはひふへほまみむめもやゆよわ';

  late AppDatabase db;

  setUp(() {
    db = newTestDatabase();
  });

  /// 主要画面を1つ描画して、レイアウト例外が出ないことを確認する。
  Future<void> checkMatrix(
    WidgetTester tester,
    String label,
    Widget Function(Profile? profile) build, {
    bool withActiveProfile = true,
    bool wrapInScaffold = false,
  }) async {
    for (final width in widths) {
      for (final scale in scales) {
        final profiles = await db.select(db.profiles).get();
        final first = profiles.isEmpty ? null : profiles.first;
        await pumpWithProviders(
          tester,
          db: db,
          child: build(first),
          activeProfile: withActiveProfile ? first : null,
          textScale: scale,
          size: Size(width, 900),
          wrapInScaffold: wrapInScaffold,
        );
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '$label が 幅$width × textScaler$scale で溢れた',
        );
      }
    }
  }

  group('主要画面が 幅×文字拡大 のマトリクスで溢れない', () {
    testWidgets('プロファイルゲート（学習者2人）', (tester) async {
      await createTestProfile(db, name: longName, colorSeed: 0);
      await createTestProfile(db, name: longName2, colorSeed: 1);
      await checkMatrix(
        tester,
        'プロファイルゲート',
        (_) => const ProfileGateScreen(),
        withActiveProfile: false,
      );
    });

    testWidgets('プロファイルゲート（初回起動・学習者0人）', (tester) async {
      await checkMatrix(
        tester,
        'プロファイルゲート（初回）',
        (_) => const ProfileGateScreen(),
        withActiveProfile: false,
      );
    });

    testWidgets('ホーム', (tester) async {
      await createTestProfile(db, name: longName);
      await checkMatrix(
        tester,
        'ホーム',
        (profile) => HomeScreen(profile: profile!),
        wrapInScaffold: true,
      );
    });

    testWidgets('辞書', (tester) async {
      await createTestProfile(db, name: longName);
      await checkMatrix(
        tester,
        '辞書',
        (_) => const DictionaryScreen(),
        wrapInScaffold: true,
      );
    });

    testWidgets('統計', (tester) async {
      await createTestProfile(db, name: longName);
      await checkMatrix(
        tester,
        '統計',
        (_) => const StatsScreen(),
        wrapInScaffold: true,
      );
    });

    testWidgets('シェル（4タブ）', (tester) async {
      await createTestProfile(db, name: longName);
      await checkMatrix(
        tester,
        'シェル',
        (profile) => RootShell(profile: profile!),
      );
    });

    testWidgets('学習者管理', (tester) async {
      await createTestProfile(db, name: longName, colorSeed: 0);
      await createTestProfile(db, name: longName2, colorSeed: 1);
      await checkMatrix(tester, '学習者管理', (_) => const ProfilesScreen());
    });
  });

  group('設定の各タブが溢れない', () {
    for (final tabIndex in [0, 1, 2]) {
      testWidgets('設定タブ $tabIndex', (tester) async {
        await createTestProfile(db, name: longName);
        for (final width in widths) {
          for (final scale in scales) {
            final profile = (await db.select(db.profiles).get()).first;
            await pumpWithProviders(
              tester,
              db: db,
              child: SettingsScreen(profile: profile),
              activeProfile: profile,
              textScale: scale,
              size: Size(width, 900),
              wrapInScaffold: true,
            );
            await tester.pumpAndSettle();
            if (tabIndex > 0) {
              await tester.tap(find.byType(Tab).at(tabIndex));
              await tester.pumpAndSettle();
            }
            expect(
              tester.takeException(),
              isNull,
              reason: '設定タブ$tabIndex が 幅$width × textScaler$scale で溢れた',
            );
          }
        }
      });
    }
  });
}
