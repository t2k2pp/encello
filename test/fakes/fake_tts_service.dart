import 'dart:async';

import 'package:encello/core/utils/enums.dart';
import 'package:encello/data/services/audio_library.dart';
import 'package:encello/data/services/audio_pronunciation_service.dart';
import 'package:encello/domain/services/tts_service.dart';

/// 実機の読み上げを起こさないフェイク（[Docs/07_testing_strategy.md] §5）。
class FakeTtsService implements TtsService {
  FakeTtsService({TtsCapability? capability})
    : capability_ = capability ?? _bothLanguages;

  static const _bothLanguages = TtsCapability(
    enVoices: [TtsVoice(name: 'Test English', locale: 'en-US')],
    jaVoices: [TtsVoice(name: 'Test Japanese', locale: 'ja-JP')],
  );

  TtsCapability capability_;

  /// 読み上げた内容（呼ばれた順）。
  final spoken = <({String text, SpeechLang lang})>[];
  int stopCount = 0;
  double? rate;
  double? pitch;
  final setVoices = <SpeechLang, String>{};

  /// 次の [speak] で投げる例外。再生失敗の経路を試すために使う。
  Object? failWith;

  /// 手動で完了させたいときに使う。null なら即完了する。
  Completer<void>? pending;

  @override
  Future<TtsCapability> capability() async => capability_;

  @override
  Future<void> speak(String text, SpeechLang lang) async {
    if (failWith != null) throw failWith!;
    if (!capability_.has(lang)) {
      throw TtsUnavailableException('voice がありません: $lang');
    }
    // 前の再生を止めてから始める。
    stopCount++;
    spoken.add((text: text, lang: lang));
    final gate = pending;
    if (gate != null) await gate.future;
  }

  @override
  Future<void> stop() async => stopCount++;

  @override
  Future<void> setRate(double value) async => rate = value;

  @override
  Future<void> setPitch(double value) async => pitch = value;

  @override
  Future<void> setVoice(SpeechLang lang, String voiceName) async {
    if (voiceName.isEmpty) return;
    final exists = capability_.voicesFor(lang).any((v) => v.name == voiceName);
    if (!exists) {
      throw TtsUnavailableException('選択中の音声が見つかりません: $voiceName');
    }
    setVoices[lang] = voiceName;
  }
}

/// 実ファイルを鳴らさないフェイク。
class FakeAudioFilePlayer implements AudioFilePlayer {
  final played = <String>[];
  int stopCount = 0;

  /// 次の [play] で投げる例外。
  Object? failWith;

  @override
  Future<void> play(WordAudioRef ref) async {
    if (failWith != null) throw failWith!;
    played.add(ref.path);
  }

  @override
  Future<void> stop() async => stopCount++;
}
