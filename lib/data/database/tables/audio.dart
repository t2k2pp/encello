import 'package:drift/drift.dart';

import 'words.dart';

/// 音声パック（[Docs/06_features/pronunciation.md] §3.1）。
///
/// **`profileId` を持たない**。音声は単語の属性であって学習の記録ではないため、
/// `words` と同じく学習者間で共有する。どのパックを使うかの選択と音源の優先順位だけを
/// `profiles`（`audioSource` / `audioPackIds`）に持つ。
@TableIndex(name: 'audio_packs_pack_id', columns: {#packId}, unique: true)
class AudioPacks extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 識別子（例 `jhs_en_us_v1`）。
  TextColumn get packId => text().withLength(min: 1, max: 60)();

  TextColumn get name => text().withLength(min: 1, max: 60)();

  /// 由来（`AudioPackSource`: bundled / imported）。
  TextColumn get source => text()();

  /// 収録言語（`SpeechLang`: en / ja）。
  TextColumn get lang => text()();

  TextColumn get note => text().nullable()();

  /// 収録音声数。
  IntColumn get entryCount => integer().withDefault(const Constant(0))();

  DateTimeColumn get installedAt =>
      dateTime().withDefault(currentDateAndTime)();

  /// 優先順位（同じ語が複数パックにあるとき小さいものを使う）。
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// 単語の音声ファイル（[Docs/06_features/pronunciation.md] §3.1）。
///
/// `(wordId, lang)` のインデックスは音源解決のたびに引く。
@TableIndex(name: 'word_audios_word_lang', columns: {#wordId, #lang})
@TableIndex(
  name: 'word_audios_word_pack_lang',
  columns: {#wordId, #packId, #lang},
  unique: true,
)
class WordAudios extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get wordId =>
      integer().references(Words, #id, onDelete: KeyAction.cascade)();
  IntColumn get packId =>
      integer().references(AudioPacks, #id, onDelete: KeyAction.cascade)();

  /// `SpeechLang`（en / ja）。
  TextColumn get lang => text()();

  /// `source = bundled` はアセットパス、`imported` は保存先の相対パス。
  TextColumn get filePath => text()();
}
