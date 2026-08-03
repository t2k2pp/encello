import 'package:encello/core/theme/app_colors.dart';
import 'package:encello/core/theme/app_theme.dart';
import 'package:encello/core/utils/enums.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:encello/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ウィジェットテスト用の [ProviderScope] を用意して [child] を描画する。
///
/// [SharedPreferences] は必ずモック初期化してから読む（実装を待って無言で止まるのを
/// 防ぐ。[Docs/07_testing_strategy.md] §4）。DB はメモリ上のものへ差し替える。
Future<ProviderContainer> pumpWithProviders(
  WidgetTester tester, {
  required AppDatabase db,
  required Widget child,
  Profile? activeProfile,
  double textScale = 1.0,
  Size size = const Size(390, 844),
  Map<String, Object> prefs = const {},
  DateTime Function()? clock,

  /// [child] 自身が `Scaffold` を持たない画面（シェルのタブ）では true にする。
  bool wrapInScaffold = false,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sharedPrefs = await SharedPreferences.getInstance();

  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      sharedPrefsProvider.overrideWithValue(sharedPrefs),
      if (clock != null) clockProvider.overrideWithValue(clock),
    ],
  );
  // 依存の逆順に片付ける（DB を閉じる前にコンテナを破棄する）。
  addTearDown(container.dispose);

  if (activeProfile != null) {
    container.read(activeProfileProvider.notifier).select(activeProfile);
  } else {
    AppColors.setActive(paletteById(null));
  }

  final density = activeProfile == null
      ? UiDensity.standard
      : UiDensity.fromValue(activeProfile.density);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light(density: density),
        locale: const Locale('ja'),
        // 端末の文字拡大だけを差し替える。MediaQueryData を丸ごと作り直すと
        // 画面サイズが 0 になり、実機と違う条件でレイアウトしてしまう。
        builder: (context, inner) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: inner!,
        ),
        // 画面部品（InkWell・Tooltip）は Material の子であることを前提にする。
        // 実機ではシェルの Scaffold がそれを与えるので、テストでも同じ形にする。
        home: wrapInScaffold ? Scaffold(body: child) : child,
      ),
    ),
  );
  return container;
}
