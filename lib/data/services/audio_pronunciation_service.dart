import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import '../../core/utils/enums.dart';
import '../../domain/services/pronunciation_service.dart';
import '../../domain/services/tts_service.dart';
import 'audio_library.dart';

/// 音声ファイルの再生（差し替え可能にして、テストでは実再生を起こさない）。
abstract class AudioFilePlayer {
  /// 再生完了まで待つ。失敗したら例外にする。
  Future<void> play(WordAudioRef ref);

  Future<void> stop();
}

/// `audioplayers` による再生。`onPlayerComplete` を [Completer] へ橋渡しして、
/// TTS と同じ「完了まで待つ Future」にする（[Docs/06_features/pronunciation.md] §6）。
class AudioPlayersFilePlayer implements AudioFilePlayer {
  final AudioPlayer _player;
  StreamSubscription<void>? _completeSub;
  Completer<void>? _playing;

  AudioPlayersFilePlayer([AudioPlayer? player])
    : _player = player ?? AudioPlayer();

  @override
  Future<void> play(WordAudioRef ref) async {
    await stop();
    final completer = Completer<void>();
    _playing = completer;
    _completeSub = _player.onPlayerComplete.listen((_) {
      if (!completer.isCompleted) completer.complete();
    });
    try {
      await _player.play(
        ref.isAsset ? AssetSource(ref.path) : DeviceFileSource(ref.path),
      );
    } catch (e) {
      _playing = null;
      await _completeSub?.cancel();
      throw PronunciationFailedException('音声ファイルを再生できませんでした: $e');
    }
    await completer.future;
    await _completeSub?.cancel();
    _playing = null;
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await _completeSub?.cancel();
    _completeSub = null;
    final completer = _playing;
    _playing = null;
    if (completer != null && !completer.isCompleted) completer.complete();
  }
}

/// 音声ファイルと合成音声を束ねる唯一の実装（[Docs/06_features/pronunciation.md] §6）。
///
/// 音源の解決は「有無」で行い、「失敗」では行わない。音声ファイルがあるのに再生に
/// 失敗したら、TTS へ切り替えずに失敗として扱う（§2.2）。
class AudioPronunciationService implements PronunciationService {
  final AudioLibrary library;
  final TtsService tts;
  final TtsCapability capability;
  final AudioSourcePreference preference;
  final AudioFilePlayer _filePlayer;

  AudioPronunciationService({
    required this.library,
    required this.tts,
    required this.capability,
    required this.preference,
    AudioFilePlayer? filePlayer,
  }) : _filePlayer = filePlayer ?? AudioPlayersFilePlayer();

  @override
  bool get hasAnyAudioPack => library.enabledPackCount > 0;

  @override
  AudioSourceKind? resolve(int wordId, SpeechLang lang) {
    final hasFile = library.lookup(wordId, lang) != null;
    final hasTts = capability.has(lang);
    return switch (preference) {
      AudioSourcePreference.fileFirst =>
        hasFile
            ? AudioSourceKind.audioFile
            : (hasTts ? AudioSourceKind.tts : null),
      AudioSourcePreference.ttsFirst =>
        hasTts
            ? AudioSourceKind.tts
            : (hasFile ? AudioSourceKind.audioFile : null),
      // TTS でこっそり鳴らして「音声ファイルがある」ように見せない。
      AudioSourcePreference.fileOnly =>
        hasFile ? AudioSourceKind.audioFile : null,
      // 音声ファイルがあっても使わない。
      AudioSourcePreference.ttsOnly => hasTts ? AudioSourceKind.tts : null,
    };
  }

  @override
  String? sourceNameOf(int wordId, SpeechLang lang) {
    return switch (resolve(wordId, lang)) {
      AudioSourceKind.audioFile => library.lookup(wordId, lang)!.packName,
      AudioSourceKind.tts => _voiceNameOf(lang),
      null => null,
    };
  }

  String _voiceNameOf(SpeechLang lang) {
    final voices = capability.voicesFor(lang);
    return voices.isEmpty ? '合成音声' : '合成音声: ${voices.first.name}';
  }

  @override
  Future<SpokenResult> speakWord({
    required int wordId,
    required String headword,
    required SpeechLang lang,
  }) async {
    final kind = resolve(wordId, lang);
    if (kind == null) {
      throw PronunciationUnavailableException('この語は読み上げできません: $headword');
    }
    if (kind == AudioSourceKind.audioFile) {
      final ref = library.lookup(wordId, lang)!;
      await _filePlayer.play(ref);
      return SpokenResult(
        kind: AudioSourceKind.audioFile,
        sourceName: ref.packName,
      );
    }
    await _speakWithTts(headword, lang);
    return SpokenResult(
      kind: AudioSourceKind.tts,
      sourceName: _voiceNameOf(lang),
    );
  }

  @override
  Future<SpokenResult> speakText(String text, SpeechLang lang) async {
    if (!capability.has(lang)) {
      throw PronunciationUnavailableException('この端末では読み上げできません');
    }
    await _speakWithTts(text, lang);
    return SpokenResult(
      kind: AudioSourceKind.tts,
      sourceName: _voiceNameOf(lang),
    );
  }

  Future<void> _speakWithTts(String text, SpeechLang lang) async {
    try {
      await tts.speak(text, lang);
    } on TtsUnavailableException catch (e) {
      throw PronunciationFailedException(e.message);
    }
  }

  @override
  Future<void> stop() async {
    await _filePlayer.stop();
    await tts.stop();
  }
}
