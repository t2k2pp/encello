import 'dart:io';

import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

import '../database/app_database.dart';
import 'audio_library.dart' show kAudioPackDirName;

/// 未所属の単語の下調べ（削除前の確認に使う。
/// [Docs/06_features/export_import.md] §5.1）。
@immutable
class OrphanWordsInspection {
  /// どの単語帳にも属さない語の数。
  final int wordCount;

  /// そのうち学習状態（`word_reviews`）が付いている語の数。
  final int withProgressCount;

  /// そのうち誰かのマイ単語（`ownerProfileId` が非 null）の数。
  ///
  /// この整理は端末全体を対象にするため、**他の学習者のマイ単語も消える**。
  /// 確認の文面でそれを伝えるために数える。
  final int myWordCount;

  const OrphanWordsInspection({
    required this.wordCount,
    required this.withProgressCount,
    required this.myWordCount,
  });
}

/// 使われていない音声ファイルの下調べ（[Docs/06_features/export_import.md] §5.2）。
@immutable
class OrphanAudioFilesInspection {
  final int fileCount;

  /// 解放されるバイト数。
  final int freedBytes;

  const OrphanAudioFilesInspection({
    required this.fileCount,
    required this.freedBytes,
  });
}

/// 未所属の単語・使われていない音声ファイルの整理（手動トリガーのみ。
/// [Docs/06_features/export_import.md] §5.1・§5.2、[Docs/06_features/pronunciation.md] §3.3）。
///
/// **起動時に自動で走らせない。** どちらも設定 > データからの手動実行専用。
class CleanupService {
  final AppDatabase _db;

  const CleanupService(this._db);

  // -------------------------------------------------------- 未所属の単語

  Future<OrphanWordsInspection> inspectOrphanWords() async {
    final ids = await _orphanWordIds();
    if (ids.isEmpty) {
      return const OrphanWordsInspection(
        wordCount: 0,
        withProgressCount: 0,
        myWordCount: 0,
      );
    }
    final withProgress = await _countWordsWithProgress(ids);
    final owned =
        await (_db.select(_db.words)
              ..where((t) => t.id.isIn(ids) & t.ownerProfileId.isNotNull()))
            .get();
    return OrphanWordsInspection(
      wordCount: ids.length,
      withProgressCount: withProgress,
      myWordCount: owned.length,
    );
  }

  /// どの単語帳にも属さない語を削除する。学習状態・履歴も cascade で一緒に消える。
  Future<int> deleteOrphanWords() async {
    final ids = await _orphanWordIds();
    if (ids.isEmpty) return 0;
    return (_db.delete(_db.words)..where((t) => t.id.isIn(ids))).go();
  }

  Future<List<int>> _orphanWordIds() async {
    final rows = await _db
        .customSelect(
          'SELECT w.id AS id FROM words w '
          'WHERE NOT EXISTS ('
          '  SELECT 1 FROM wordbook_entries we WHERE we.word_id = w.id'
          ')',
          readsFrom: {_db.words, _db.wordbookEntries},
        )
        .get();
    return [for (final r in rows) r.read<int>('id')];
  }

  Future<int> _countWordsWithProgress(List<int> wordIds) async {
    if (wordIds.isEmpty) return 0;
    final placeholders = List.filled(wordIds.length, '?').join(', ');
    final row = await _db
        .customSelect(
          'SELECT COUNT(DISTINCT word_id) AS c FROM word_reviews '
          'WHERE word_id IN ($placeholders)',
          variables: wordIds.map(Variable<int>.new).toList(),
          readsFrom: {_db.wordReviews},
        )
        .getSingle();
    return row.read<int>('c');
  }

  // ------------------------------------------------- 使われていない音声ファイル

  /// [documentsPath] は展開済み音声パックの親ディレクトリ（`documentsPathProvider`）。
  Future<OrphanAudioFilesInspection> inspectUnusedAudioFiles(
    String documentsPath,
  ) async {
    final files = await _findOrphanAudioFiles(documentsPath);
    var freed = 0;
    for (final f in files) {
      freed += await f.length();
    }
    return OrphanAudioFilesInspection(
      fileCount: files.length,
      freedBytes: freed,
    );
  }

  Future<OrphanAudioFilesInspection> deleteUnusedAudioFiles(
    String documentsPath,
  ) async {
    final files = await _findOrphanAudioFiles(documentsPath);
    var freed = 0;
    for (final f in files) {
      freed += await f.length();
      await f.delete();
    }
    return OrphanAudioFilesInspection(
      fileCount: files.length,
      freedBytes: freed,
    );
  }

  /// `audio_packs/` 配下のファイルのうち、`word_audios` に対応する行が無いもの。
  Future<List<File>> _findOrphanAudioFiles(String documentsPath) async {
    final dir = Directory(p.join(documentsPath, kAudioPackDirName));
    if (!dir.existsSync()) return const [];

    final known = <String>{
      for (final row in await _db.select(_db.wordAudios).get())
        p.normalize(row.filePath),
    };

    final result = <File>[];
    for (final entity in dir.listSync(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      final relative = p.normalize(p.relative(entity.path, from: dir.path));
      if (!known.contains(relative)) result.add(entity);
    }
    return result;
  }
}
