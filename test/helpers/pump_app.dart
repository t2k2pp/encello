import 'package:encello/core/theme/app_colors.dart';
import 'package:encello/core/theme/app_theme.dart';
import 'package:encello/core/utils/enums.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:encello/data/services/export_import_service.dart';
import 'package:encello/application/shared_text_receiver.dart';
import 'package:encello/data/seeds/prompt_assets.dart';
import 'package:encello/data/seeds/pseudoword_assets.dart';
import 'package:encello/domain/services/shared_text_source.dart';
import 'package:encello/domain/services/tts_service.dart';
import 'package:encello/providers/audio.dart';
import 'package:encello/providers/providers.dart';
import 'package:encello/providers/stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import '../fakes/fake_file_exchange_service.dart';
import '../fakes/fake_reminder_service.dart';
import '../fakes/fake_shared_text_source.dart';
import '../fakes/fake_tts_service.dart';

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

  /// 端末の読み上げ。既定は英日どちらも使えるフェイク（実機の音を鳴らさない）。
  TtsCapability? ttsCapability,

  /// 学習リマインダー。既定は許可済みのフェイク（実機の通知を予約しない）。
  /// 予約内容を検証したいテストは、自分でフェイクを作って渡す。
  FakeReminderService? reminder,

  /// [child] 自身が `Scaffold` を持たない画面（シェルのタブ）では true にする。
  bool wrapInScaffold = false,

  /// 通知タップで起動したときの学習者 id（`launchProfileIdProvider`）。
  int? launchProfileId,

  /// 擬似語アセット。渡すと `pseudowordAssetsProvider` を差し替える
  /// （riverpod 3 は `Override` 型を公開していないため、override のリストを
  /// 引数で受け取れない。差し替えたい provider ごとに引数を足す）。
  PseudowordAssets? pseudowords,

  /// AI 単語帳取り込みの定型文アセット。渡すと `promptAssetsProvider` を差し替える。
  PromptAssets? promptAssets,

  /// ファイルの書き出し・読み込み。既定でフェイクにし、実機のダイアログを出さない。
  FakeFileExchangeService? fileExchange,

  /// 他アプリからの共有テキスト。既定でフェイク（何も共有しない）にし、実機の
  /// 共有シートに依存させない（[Docs/06_features/my_words.md] §4.2）。
  SharedTextSource? sharedTextSource,
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
      // 実機の TTS を呼ばない（[Docs/07_testing_strategy.md] §5）。
      ttsServiceProvider.overrideWithValue(
        FakeTtsService(capability: ttsCapability),
      ),
      // 本物の NotificationService はプラットフォームチャネルに依存し、
      // ウィジェットテストでは解決せず pumpAndSettle が止まる
      // （[Docs/07_testing_strategy.md] §4）。
      reminderServiceProvider.overrideWithValue(
        reminder ?? FakeReminderService(),
      ),
      // path_provider を使わずに済ませる（ウィジェットテストでは解決しない）。
      documentsPathProvider.overrideWith((ref) async {
        final dir = Directory.systemTemp.createTempSync('encello_docs');
        addTearDown(() {
          if (dir.existsSync()) dir.deleteSync(recursive: true);
        });
        return dir.path;
      }),
      if (clock != null) clockProvider.overrideWithValue(clock),
      if (launchProfileId != null)
        launchProfileIdProvider.overrideWithValue(launchProfileId),
      if (pseudowords != null)
        pseudowordAssetsProvider.overrideWithValue(pseudowords),
      if (promptAssets != null)
        promptAssetsProvider.overrideWithValue(promptAssets),
      fileExchangeServiceProvider.overrideWithValue(
        fileExchange ?? FakeFileExchangeService(),
      ),
      sharedTextSourceProvider.overrideWithValue(
        sharedTextSource ?? FakeSharedTextSource(),
      ),
      // JSON への変換は別 isolate を起こさずその場で行う
      // （ウィジェットテストでは isolate を起こさない。§4）。
      backupEncoderProvider.overrideWithValue(
        (payload) async => encodeBackupJson(payload),
      ),
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
