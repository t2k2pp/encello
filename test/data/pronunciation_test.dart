import 'package:encello/core/utils/enums.dart';
import 'package:encello/data/services/audio_library.dart';
import 'package:encello/data/services/audio_pronunciation_service.dart';
import 'package:encello/domain/services/pronunciation_service.dart';
import 'package:encello/domain/services/tts_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_tts_service.dart';

void main() {
  const appleId = 1;
  const bananaId = 2;

  /// apple にだけ英語の音声ファイルがある索引。
  AudioLibrary libraryWithApple() => AudioLibrary(
    const {
      (appleId, SpeechLang.en): WordAudioRef(
        path: '/packs/jhs/apple.mp3',
        isAsset: false,
        packName: '中学英単語 音声（米）',
      ),
    },
    1,
  );

  ({
    AudioPronunciationService service,
    FakeTtsService tts,
    FakeAudioFilePlayer player,
  })
  build({
    AudioLibrary? library,
    TtsCapability capability = const TtsCapability(
      enVoices: [TtsVoice(name: 'Test English', locale: 'en-US')],
      jaVoices: [TtsVoice(name: 'Test Japanese', locale: 'ja-JP')],
    ),
    AudioSourcePreference preference = AudioSourcePreference.fileFirst,
  }) {
    final tts = FakeTtsService(capability: capability);
    final player = FakeAudioFilePlayer();
    return (
      service: AudioPronunciationService(
        library: library ?? AudioLibrary.empty,
        tts: tts,
        capability: capability,
        preference: preference,
        filePlayer: player,
      ),
      tts: tts,
      player: player,
    );
  }

  group('音源の解決', () {
    test('音声ファイル優先: ファイルがあればファイル、無ければ合成音声', () {
      final s = build(library: libraryWithApple()).service;
      expect(s.resolve(appleId, SpeechLang.en), AudioSourceKind.audioFile);
      expect(s.resolve(bananaId, SpeechLang.en), AudioSourceKind.tts);
    });

    test('合成音声優先: 音声があれば常に合成音声', () {
      final s = build(
        library: libraryWithApple(),
        preference: AudioSourcePreference.ttsFirst,
      ).service;
      expect(s.resolve(appleId, SpeechLang.en), AudioSourceKind.tts);
    });

    test('音声ファイルのみ: 無い語は鳴らせない（合成音声で代替しない）', () {
      final s = build(
        library: libraryWithApple(),
        preference: AudioSourcePreference.fileOnly,
      ).service;
      expect(s.resolve(appleId, SpeechLang.en), AudioSourceKind.audioFile);
      expect(s.resolve(bananaId, SpeechLang.en), isNull);
    });

    test('合成音声のみ: 音声ファイルがあっても使わない', () {
      final s = build(
        library: libraryWithApple(),
        preference: AudioSourcePreference.ttsOnly,
      ).service;
      expect(s.resolve(appleId, SpeechLang.en), AudioSourceKind.tts);
    });

    test('voice もファイルも無ければ鳴らせない', () {
      final s = build(capability: TtsCapability.none).service;
      expect(s.resolve(appleId, SpeechLang.en), isNull);
      expect(s.resolve(appleId, SpeechLang.ja), isNull);
    });

    test('英語 voice が無くても英語の音声パックがあれば鳴らせる', () {
      final s = build(
        library: libraryWithApple(),
        capability: const TtsCapability(
          enVoices: [],
          jaVoices: [TtsVoice(name: 'ja', locale: 'ja-JP')],
        ),
      ).service;
      expect(s.resolve(appleId, SpeechLang.en), AudioSourceKind.audioFile);
      expect(s.resolve(bananaId, SpeechLang.en), isNull);
    });

    test('音源名はバッジの長押し用に取れる', () {
      final s = build(library: libraryWithApple()).service;
      expect(s.sourceNameOf(appleId, SpeechLang.en), '中学英単語 音声（米）');
      expect(s.sourceNameOf(bananaId, SpeechLang.en), contains('合成音声'));
      expect(s.sourceNameOf(bananaId, SpeechLang.en), contains('Test English'));
    });

    test('音声パックが1つも無ければバッジを出さない', () {
      expect(build().service.hasAnyAudioPack, isFalse);
      expect(build(library: libraryWithApple()).service.hasAnyAudioPack, isTrue);
    });
  });

  group('再生', () {
    test('音声ファイルがある語はファイルを鳴らす', () async {
      final b = build(library: libraryWithApple());
      final result = await b.service.speakWord(
        wordId: appleId,
        headword: 'apple',
        lang: SpeechLang.en,
      );

      expect(result.kind, AudioSourceKind.audioFile);
      expect(result.sourceName, '中学英単語 音声（米）');
      expect(b.player.played, ['/packs/jhs/apple.mp3']);
      expect(b.tts.spoken, isEmpty);
    });

    test('音声ファイルが無い語は見出し語を合成音声で読む', () async {
      final b = build(library: libraryWithApple());
      final result = await b.service.speakWord(
        wordId: bananaId,
        headword: 'banana',
        lang: SpeechLang.en,
      );

      expect(result.kind, AudioSourceKind.tts);
      expect(b.tts.spoken.single.text, 'banana');
      expect(b.tts.spoken.single.lang, SpeechLang.en);
      expect(b.player.played, isEmpty);
    });

    test('鳴らせない語は例外にする（無音で成功したように振る舞わない）', () async {
      final s = build(capability: TtsCapability.none).service;
      await expectLater(
        s.speakWord(wordId: appleId, headword: 'apple', lang: SpeechLang.en),
        throwsA(isA<PronunciationUnavailableException>()),
      );
    });

    test('音声ファイルの再生に失敗しても合成音声へ切り替えない', () async {
      final b = build(library: libraryWithApple());
      b.player.failWith = const PronunciationFailedException('壊れています');

      await expectLater(
        b.service.speakWord(
          wordId: appleId,
          headword: 'apple',
          lang: SpeechLang.en,
        ),
        throwsA(isA<PronunciationFailedException>()),
      );
      // TTS は呼ばれない。「無い」と「壊れている」は違う状態として扱う。
      expect(b.tts.spoken, isEmpty);
    });

    test('例文は常に合成音声で読む', () async {
      final b = build(library: libraryWithApple());
      final result = await b.service.speakText(
        'I ate an apple.',
        SpeechLang.en,
      );

      expect(result.kind, AudioSourceKind.tts);
      expect(b.tts.spoken.single.text, 'I ate an apple.');
      expect(b.player.played, isEmpty);
    });

    test('日本語 voice が無ければ日本語の読み上げは例外', () async {
      final b = build(
        capability: const TtsCapability(
          enVoices: [TtsVoice(name: 'en', locale: 'en-US')],
          jaVoices: [],
        ),
      );
      await expectLater(
        b.service.speakText('りんご', SpeechLang.ja),
        throwsA(isA<PronunciationUnavailableException>()),
      );
    });

    test('stop は音声ファイルと合成音声の両方を止める', () async {
      final b = build(library: libraryWithApple());
      await b.service.stop();
      expect(b.player.stopCount, 1);
      expect(b.tts.stopCount, 1);
    });
  });
}
