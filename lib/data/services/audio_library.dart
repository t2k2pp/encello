import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

import '../../core/utils/enums.dart';
import '../database/app_database.dart';
import '../repositories/wordbook_repository.dart' show decodeIdList;

/// 展開済み音声パックの置き場（アプリ文書ディレクトリの下）。
const kAudioPackDirName = 'audio_packs';

/// ある語・ある言語で使う音声ファイル1件。
@immutable
class WordAudioRef {
  /// 再生に渡すパス。`bundled` はアセットパス、`imported` は絶対パス。
  final String path;
  final bool isAsset;

  /// バッジの長押しで見せる音源名。
  final String packName;

  const WordAudioRef({
    required this.path,
    required this.isAsset,
    required this.packName,
  });
}

/// 「どの語をどのファイルで鳴らすか」の索引（[Docs/06_features/pronunciation.md] §3）。
///
/// 再生のたびに DB を引かずに済むよう、学習者が使うパックだけを優先順に畳んで持つ。
/// パックの ON/OFF や優先順位を変えたら作り直す。
class AudioLibrary {
  final Map<(int, SpeechLang), WordAudioRef> _index;

  /// この学習者が使っているパックの数。0 なら音源バッジを出さない。
  final int enabledPackCount;

  const AudioLibrary(this._index, this.enabledPackCount);

  static const empty = AudioLibrary({}, 0);

  WordAudioRef? lookup(int wordId, SpeechLang lang) => _index[(wordId, lang)];

  bool get isEmpty => _index.isEmpty;

  /// [profile] が使うパックだけを、`profiles.audioPackIds` の**並び順**で畳む。
  /// 先に来たパックが勝つ（同じ語が複数のパックにあれば優先順位の高い方を使う）。
  ///
  /// [documentsPath] は展開済みパックの親ディレクトリ。
  static Future<AudioLibrary> load(
    AppDatabase db,
    Profile profile, {
    required String documentsPath,
  }) async {
    final enabledIds = decodeIdList(profile.audioPackIds);
    if (enabledIds.isEmpty) return empty;

    final packs = await (db.select(
      db.audioPacks,
    )..where((t) => t.id.isIn(enabledIds))).get();
    final packById = {for (final pack in packs) pack.id: pack};

    final index = <(int, SpeechLang), WordAudioRef>{};
    // 優先順位の低い方から入れると上書きで壊れるため、高い順に入れて既存を残す。
    for (final packId in enabledIds) {
      final pack = packById[packId];
      if (pack == null) continue;
      final isAsset =
          AudioPackSource.fromValue(pack.source) == AudioPackSource.bundled;
      final audios = await (db.select(
        db.wordAudios,
      )..where((t) => t.packId.equals(packId))).get();

      for (final audio in audios) {
        final key = (audio.wordId, SpeechLang.fromValue(audio.lang));
        if (index.containsKey(key)) continue;
        index[key] = WordAudioRef(
          path: isAsset
              ? audio.filePath
              : p.join(documentsPath, kAudioPackDirName, audio.filePath),
          isAsset: isAsset,
          packName: pack.name,
        );
      }
    }
    return AudioLibrary(index, packs.length);
  }
}
