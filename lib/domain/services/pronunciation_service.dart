import 'package:meta/meta.dart';

import '../../core/utils/enums.dart';

/// 何で鳴らすか（[Docs/06_features/pronunciation.md] §2）。
enum AudioSourceKind {
  /// 録音された音声ファイル（音声パック）。
  audioFile('🎙'),

  /// 端末の音声合成。
  tts('🔉');

  /// 読み上げボタンに重ねる音源バッジ（§5）。
  final String badge;
  const AudioSourceKind(this.badge);
}

/// 鳴らし終えたときの結果。
@immutable
class SpokenResult {
  final AudioSourceKind kind;

  /// パック名 または voice 名（音源バッジの長押しで見せる）。
  final String sourceName;

  const SpokenResult({required this.kind, required this.sourceName});
}

/// その語をその言語で鳴らせない。ボタンを出さないための状態であり、
/// 呼ばれた時点で例外にする（無音で成功したように振る舞わない）。
class PronunciationUnavailableException implements Exception {
  final String message;

  const PronunciationUnavailableException(this.message);

  @override
  String toString() => message;
}

/// 音源はあるのに再生に失敗した。**別の音源へ切り替えない**
/// （[Docs/06_features/pronunciation.md] §2.2。「無い」と「壊れている」は違う）。
class PronunciationFailedException implements Exception {
  final String message;

  const PronunciationFailedException(this.message);

  @override
  String toString() => message;
}

/// 単語・テキストの読み上げ（[Docs/06_features/pronunciation.md] §6）。
///
/// UI と学習セッションはここだけを呼び、音声ファイルか合成音声かを意識しない。
abstract class PronunciationService {
  /// 鳴らせるか。null = 音声ファイルも合成音声も無い（ボタンを出さない）。
  AudioSourceKind? resolve(int wordId, SpeechLang lang);

  /// 音源の名前（バッジの長押しで見せる）。鳴らせないときは null。
  String? sourceNameOf(int wordId, SpeechLang lang);

  /// 音声パックが1つでも使われているか。1つも無いときは全部が合成音声になり、
  /// バッジが情報にならないため出さない（§5）。
  bool get hasAnyAudioPack;

  /// 単語を鳴らす。完了 or 中断まで待つ。
  ///
  /// [headword] は呼び出し側が渡す。合成音声には**見出し語をそのまま**渡すため
  /// （発音記号は表示専用。[Docs/06_features/tts.md] §5）で、かつ再生のたびに
  /// DB を引き直さないため。呼び出し側は必ず語を手に持っている。
  Future<SpokenResult> speakWord({
    required int wordId,
    required String headword,
    required SpeechLang lang,
  });

  /// 例文などの任意テキスト。常に合成音声で読む（§2.1）。
  Future<SpokenResult> speakText(String text, SpeechLang lang);

  Future<void> stop();
}
