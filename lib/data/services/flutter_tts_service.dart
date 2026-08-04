import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

import '../../core/utils/enums.dart';
import '../../domain/services/tts_service.dart';

/// `flutter_tts` による読み上げ（[Docs/06_features/tts.md]）。
///
/// `setCompletionHandler` / `setErrorHandler` を [Completer] に橋渡しして、
/// `speak()` を「完了まで待つ Future」にする。フラッシュカードの送りがこの完了を
/// 契機にするため、awaitable であることが前提になる。
class FlutterTtsService implements TtsService {
  final FlutterTts _tts;

  /// いま再生中の1件。次の [speak] はこれを止めてから始める。
  Completer<void>? _speaking;

  bool _handlersInstalled = false;

  FlutterTtsService([FlutterTts? tts]) : _tts = tts ?? FlutterTts();

  void _installHandlers() {
    if (_handlersInstalled) return;
    _handlersInstalled = true;
    _tts.setCompletionHandler(() => _finish());
    _tts.setCancelHandler(() => _finish());
    _tts.setErrorHandler(
      (dynamic message) =>
          _finish(TtsUnavailableException('読み上げに失敗しました: $message')),
    );
  }

  void _finish([Object? error]) {
    final completer = _speaking;
    _speaking = null;
    if (completer == null || completer.isCompleted) return;
    if (error == null) {
      completer.complete();
    } else {
      completer.completeError(error);
    }
  }

  @override
  Future<TtsCapability> capability() async {
    final raw = await _tts.getVoices;
    final voices = <TtsVoice>[];
    if (raw is List) {
      for (final entry in raw) {
        if (entry is! Map) continue;
        final name = entry['name'];
        final locale = entry['locale'];
        if (name is String && locale is String) {
          voices.add(TtsVoice(name: name, locale: locale));
        }
      }
    }
    return TtsCapability(
      enVoices: [
        for (final v in voices)
          if (v.locale.toLowerCase().startsWith('en')) v,
      ],
      jaVoices: [
        for (final v in voices)
          if (v.locale.toLowerCase().startsWith('ja')) v,
      ],
    );
  }

  @override
  Future<void> speak(String text, SpeechLang lang) async {
    _installHandlers();
    await stop();
    await _tts.setLanguage(lang.defaultLocale);
    // 完了まで待てるようにする（既定の awaitSpeakCompletion は false）。
    await _tts.awaitSpeakCompletion(true);

    final completer = Completer<void>();
    _speaking = completer;
    final result = await _tts.speak(text);
    // 1 = 開始できた。それ以外は音声が無い等で始まっていない。
    if (result != 1) {
      _finish(
        TtsUnavailableException('この端末では ${lang.defaultLocale} を読み上げできません'),
      );
    }
    return completer.future;
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
    _finish();
  }

  @override
  Future<void> setRate(double rate) => _tts.setSpeechRate(rate);

  @override
  Future<void> setPitch(double pitch) => _tts.setPitch(pitch);

  @override
  Future<void> setVoice(SpeechLang lang, String voiceName) async {
    if (voiceName.isEmpty) return;
    final capability = await this.capability();
    final voice = capability
        .voicesFor(lang)
        .where((v) => v.name == voiceName)
        .firstOrNull;
    if (voice == null) {
      // 保存済みの voice が端末から消えた場合。**勝手に別の voice へ切り替えない**
      // （[Docs/06_features/tts.md] §3）。設定画面が選び直させる。
      throw TtsUnavailableException('選択中の音声が見つかりません: $voiceName');
    }
    await _tts.setVoice({'name': voice.name, 'locale': voice.locale});
  }
}
