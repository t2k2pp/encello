import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// `wakelock_plus` の画面消灯抑止（`toggle`）を黙って受け止めるフェイク。
///
/// フラッシュカードは自動送り中に画面を消灯させないため `WakelockPlus.enable()` を
/// 呼ぶ（NFR-10）。実装が無いままだと pigeon のチャネルが応答せず、投げっぱなしの
/// Future が `PlatformException` で落ちる（[Docs/07_testing_strategy.md] §4）。
void installFakeWakelock() {
  // pigeon の生成コードは戻り値を `[result]` の形で読む。`toggle` は void なので
  // `[null]` を返す。コーデックは標準のもの（生成側も `StandardMessageCodec`）。
  final reply = const StandardMessageCodec().encodeMessage(<Object?>[null]);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMessageHandler(_toggleChannel, (_) async => reply);
  addTearDown(() => messenger.setMockMessageHandler(_toggleChannel, null));
}

const _toggleChannel =
    'dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.toggle';
