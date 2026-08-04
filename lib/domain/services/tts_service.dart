import 'package:meta/meta.dart';

import '../../core/utils/enums.dart';

/// 端末が持つ読み上げ音声1つ（[Docs/06_features/tts.md] §1）。
@immutable
class TtsVoice {
  /// 端末が返す voice 名。
  final String name;

  /// `en-US` / `en-GB` / `ja-JP` など。
  final String locale;

  const TtsVoice({required this.name, required this.locale});

  @override
  bool operator ==(Object other) =>
      other is TtsVoice && other.name == name && other.locale == locale;

  @override
  int get hashCode => Object.hash(name, locale);

  @override
  String toString() => '$name ($locale)';
}

/// この端末で読み上げに使えるもの。
@immutable
class TtsCapability {
  final List<TtsVoice> enVoices;
  final List<TtsVoice> jaVoices;

  const TtsCapability({required this.enVoices, required this.jaVoices});

  static const none = TtsCapability(enVoices: [], jaVoices: []);

  bool get hasEn => enVoices.isNotEmpty;

  bool get hasJa => jaVoices.isNotEmpty;

  bool get hasAny => hasEn || hasJa;

  List<TtsVoice> voicesFor(SpeechLang lang) =>
      lang == SpeechLang.en ? enVoices : jaVoices;

  bool has(SpeechLang lang) => voicesFor(lang).isNotEmpty;
}

/// 読み上げができない状態。**黙って無音で成功したように振る舞わない**
/// （[Docs/00_overview.md] 設計上の原則）。
class TtsUnavailableException implements Exception {
  final String message;

  const TtsUnavailableException(this.message);

  @override
  String toString() => message;
}

/// 端末の読み上げ（[Docs/06_features/tts.md] §1）。
///
/// UI からは [PronunciationService] だけを呼び、ここを直接呼ばない
/// （音声ファイルか合成音声かの判断はそちらが持つ）。
abstract class TtsService {
  /// 利用できる voice の一覧。起動をブロックせず、ホーム表示後に非同期で取る。
  Future<TtsCapability> capability();

  /// 読み上げ完了まで待つ。voice が無い言語では [TtsUnavailableException] を投げる。
  /// 再生中に別の [speak] が来たら、前の再生を止めてから始める。
  Future<void> speak(String text, SpeechLang lang);

  Future<void> stop();

  Future<void> setRate(double rate);

  Future<void> setPitch(double pitch);

  /// 使う voice を指定する。空文字なら端末既定に任せる。
  Future<void> setVoice(SpeechLang lang, String voiceName);
}
