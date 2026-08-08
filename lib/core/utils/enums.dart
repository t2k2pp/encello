/// アプリ全体で使う列挙の集中管理。DB には文字列で保存し、未知値はバリデーションで
/// 弾く（黙って既定値へ倒さない。[Docs/03_data_model.md]）。
library;

/// 文字サイズ（設定 > 表示）。端末の文字拡大設定に**乗算**して適用する。
enum TextSizeOption {
  small('small', '小', 0.9),
  medium('medium', '中', 1.0),
  large('large', '大', 1.15);

  final String value;
  final String label;

  /// テキストスケール係数（1.0 = 端末設定そのまま）。
  final double scale;
  const TextSizeOption(this.value, this.label, this.scale);

  static TextSizeOption fromValue(String v) => TextSizeOption.values.firstWhere(
    (e) => e.value == v,
    orElse: () => throw FormatException('未知のTextSizeOption: $v'),
  );
}

/// 余白の密度（設定 > 表示）。
enum UiDensity {
  standard('standard', '標準'),
  compact('compact', 'コンパクト');

  final String value;
  final String label;
  const UiDensity(this.value, this.label);

  static UiDensity fromValue(String v) => UiDensity.values.firstWhere(
    (e) => e.value == v,
    orElse: () => throw FormatException('未知のUiDensity: $v'),
  );
}

/// 一覧の表示形式（辞書・単語帳の中身・マイ単語）。
enum ListViewMode {
  list('list'),
  grid('grid');

  final String value;
  const ListViewMode(this.value);

  static ListViewMode fromValue(String v) => ListViewMode.values.firstWhere(
    (e) => e.value == v,
    orElse: () => throw FormatException('未知のListViewMode: $v'),
  );
}

/// アプリ内英字キーボードの配列（[Docs/06_features/spell_mode.md] §2）。
enum KeyboardLayout {
  qwerty('qwerty', 'QWERTY'),
  abc('abc', 'ABC順');

  final String value;
  final String label;
  const KeyboardLayout(this.value, this.label);

  static KeyboardLayout fromValue(String v) => KeyboardLayout.values.firstWhere(
    (e) => e.value == v,
    orElse: () => throw FormatException('未知のKeyboardLayout: $v'),
  );
}

/// フラッシュカードの送り方（FR-24）。
enum FlashcardMode {
  silentAuto('silentAuto', '無音・固定秒で送る'),
  speakEn('speakEn', '英語を読み上げて送る'),
  speakJa('speakJa', '日本語を読み上げて送る');

  final String value;
  final String label;
  const FlashcardMode(this.value, this.label);

  static FlashcardMode fromValue(String v) => FlashcardMode.values.firstWhere(
    (e) => e.value == v,
    orElse: () => throw FormatException('未知のFlashcardMode: $v'),
  );
}

/// 4択クイズの出題方向（FR-27）。
enum ChoiceDirection {
  enToJa('enToJa', '英語→日本語'),
  jaToEn('jaToEn', '日本語→英語'),
  random('random', 'ランダム');

  final String value;
  final String label;
  const ChoiceDirection(this.value, this.label);

  static ChoiceDirection fromValue(String v) =>
      ChoiceDirection.values.firstWhere(
        (e) => e.value == v,
        orElse: () => throw FormatException('未知のChoiceDirection: $v'),
      );
}

/// 音源の優先順位（FR-99、[Docs/06_features/pronunciation.md] §2）。
enum AudioSourcePreference {
  fileFirst('fileFirst', '音声ファイル優先'),
  ttsFirst('ttsFirst', '合成音声優先'),
  fileOnly('fileOnly', '音声ファイルのみ'),
  ttsOnly('ttsOnly', '合成音声のみ');

  final String value;
  final String label;
  const AudioSourcePreference(this.value, this.label);

  static AudioSourcePreference fromValue(String v) =>
      AudioSourcePreference.values.firstWhere(
        (e) => e.value == v,
        orElse: () => throw FormatException('未知のAudioSourcePreference: $v'),
      );
}

/// 学習モード（[Docs/00_overview.md] 用語）。`learning_logs.mode` に保存する。
enum StudyMode {
  spell('spell', 'スペル', '✏️'),
  listening('listening', 'リスニング', '🎧'),
  flashcard('flashcard', 'フラッシュカード', '🃏'),
  choice('choice', '4択', '🎯'),
  speed('speed', 'スピード', '⚡'),
  parts('parts', '語のつくり', '🧩'),
  family('family', '語形変化', '🔤'),
  confusion('confusion', '取り違え', '🔀');

  final String value;
  final String label;
  final String emoji;
  const StudyMode(this.value, this.label, this.emoji);

  static StudyMode fromValue(String v) => StudyMode.values.firstWhere(
    (e) => e.value == v,
    orElse: () => throw FormatException('未知のStudyMode: $v'),
  );
}

/// 出題方向（`learning_logs.direction`）。
enum StudyDirection {
  enToJa('enToJa'),
  jaToEn('jaToEn');

  final String value;
  const StudyDirection(this.value);

  static StudyDirection fromValue(String v) => StudyDirection.values.firstWhere(
    (e) => e.value == v,
    orElse: () => throw FormatException('未知のStudyDirection: $v'),
  );
}

/// 品詞（`words.partOfSpeech`）。
enum PartOfSpeech {
  noun('noun', '名詞'),
  verb('verb', '動詞'),
  adjective('adjective', '形容詞'),
  adverb('adverb', '副詞'),
  preposition('preposition', '前置詞'),
  conjunction('conjunction', '接続詞'),
  pronoun('pronoun', '代名詞'),
  interjection('interjection', '間投詞'),
  phrase('phrase', '熟語'),
  unknown('unknown', '未分類');

  final String value;
  final String label;
  const PartOfSpeech(this.value, this.label);

  static PartOfSpeech fromValue(String v) => PartOfSpeech.values.firstWhere(
    (e) => e.value == v,
    orElse: () => throw FormatException('未知のPartOfSpeech: $v'),
  );
}

/// 単語帳の区分（`wordbooks.category`）。
enum WordbookCategory {
  juniorHigh('juniorHigh', '中学'),
  highSchool('highSchool', '高校'),
  eiken('eiken', '英検'),
  toeic('toeic', 'TOEIC'),
  myWords('myWords', 'マイ単語'),
  custom('custom', 'その他');

  final String value;
  final String label;
  const WordbookCategory(this.value, this.label);

  static WordbookCategory fromValue(String v) =>
      WordbookCategory.values.firstWhere(
        (e) => e.value == v,
        orElse: () => throw FormatException('未知のWordbookCategory: $v'),
      );
}

/// 単語帳の由来（`wordbooks.source`）。
enum WordbookSource {
  preset('preset'),
  user('user'),
  imported('imported');

  final String value;
  const WordbookSource(this.value);

  static WordbookSource fromValue(String v) => WordbookSource.values.firstWhere(
    (e) => e.value == v,
    orElse: () => throw FormatException('未知のWordbookSource: $v'),
  );
}

/// 語の部品の種別（`word_parts.type`）。
enum WordPartType {
  prefix('prefix', '接頭辞'),
  root('root', '語根'),
  suffix('suffix', '接尾辞');

  final String value;
  final String label;
  const WordPartType(this.value, this.label);

  static WordPartType fromValue(String v) => WordPartType.values.firstWhere(
    (e) => e.value == v,
    orElse: () => throw FormatException('未知のWordPartType: $v'),
  );
}

/// 読み上げる言語（`word_audios.lang` / `audio_packs.lang`）。
enum SpeechLang {
  en('en', 'en-US'),
  ja('ja', 'ja-JP');

  final String value;

  /// TTS へ渡す既定のロケール。
  final String defaultLocale;
  const SpeechLang(this.value, this.defaultLocale);

  static SpeechLang fromValue(String v) => SpeechLang.values.firstWhere(
    (e) => e.value == v,
    orElse: () => throw FormatException('未知のSpeechLang: $v'),
  );
}

/// 音声パックの由来（`audio_packs.source`）。
enum AudioPackSource {
  bundled('bundled'),
  imported('imported');

  final String value;
  const AudioPackSource(this.value);

  static AudioPackSource fromValue(String v) =>
      AudioPackSource.values.firstWhere(
        (e) => e.value == v,
        orElse: () => throw FormatException('未知のAudioPackSource: $v'),
      );
}
