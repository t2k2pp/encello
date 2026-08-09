import 'package:encello/core/utils/enums.dart';
import 'package:encello/domain/services/pronunciation_service.dart';

/// 実機の音を鳴らさないフェイク（[Docs/07_testing_strategy.md] §5）。
///
/// 本物（`AudioPronunciationService`）は音声パックを使っていなくても
/// `audioplayers` の `AudioPlayer` を必ず作るため、プラグインが無いテスト環境では
/// `MissingPluginException` になる。`pronunciationProvider` ごとこちらへ差し替える。
class FakePronunciationService implements PronunciationService {
  FakePronunciationService({
    this.kind = AudioSourceKind.tts,
    this.hasAnyAudioPack = false,
    this.sourceName = 'テスト音声',
  });

  /// 鳴らせる音源。null にすると「鳴らせない」（読み上げボタンを出さない状態）。
  final AudioSourceKind? kind;

  @override
  final bool hasAnyAudioPack;

  final String sourceName;

  /// 鳴らした内容（呼ばれた順）。
  final spoken = <({String text, SpeechLang lang})>[];

  int stopCount = 0;

  @override
  AudioSourceKind? resolve(int wordId, SpeechLang lang) => kind;

  @override
  String? sourceNameOf(int wordId, SpeechLang lang) =>
      kind == null ? null : sourceName;

  @override
  Future<SpokenResult> speakWord({
    required int wordId,
    required String headword,
    required SpeechLang lang,
  }) => speakText(headword, lang);

  @override
  Future<SpokenResult> speakText(String text, SpeechLang lang) async {
    final source = kind;
    if (source == null) {
      throw const PronunciationUnavailableException('鳴らせる音源がありません');
    }
    spoken.add((text: text, lang: lang));
    return SpokenResult(kind: source, sourceName: sourceName);
  }

  @override
  Future<void> stop() async => stopCount++;
}
