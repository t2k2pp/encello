import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

import '../../core/utils/enums.dart';
import '../database/app_database.dart';
import 'audio_library.dart';

/// 音声パックの取り込みが成功したときの結果。
@immutable
class AudioPackImportResult {
  final String packId;
  final String name;

  /// DB の単語と結び付いた音声の数。
  final int importedCount;

  /// 該当する単語が無くて取り込まなかった数。音声のためだけに単語を作らない。
  final int unmatchedCount;

  const AudioPackImportResult({
    required this.packId,
    required this.name,
    required this.importedCount,
    required this.unmatchedCount,
  });
}

/// 取り込みを中止した理由。**致命的な問題があれば1件も取り込まない**
/// （[Docs/06_features/pronunciation.md] §4.2）。
class AudioPackImportException implements Exception {
  final String message;

  /// 補足（見つからなかったファイル名など、先頭10件）。
  final List<String> details;

  const AudioPackImportException(this.message, [this.details = const []]);

  @override
  String toString() => message;
}

/// 音声パック（ZIP）の取り込み（[Docs/06_features/pronunciation.md] §4）。
///
/// 展開とDB書き込みのどちらかが失敗したら、**両方を巻き戻す**。
/// 半分だけ入ったパックを残さない。
class AudioPackImporter {
  final AppDatabase _db;

  /// 展開先の親（アプリ文書ディレクトリ）。
  final Directory _documentsDir;

  const AudioPackImporter(this._db, this._documentsDir);

  /// 対応する音声形式。これ以外の拡張子は取り込まない。
  static const supportedExtensions = {'.mp3', '.m4a', '.wav', '.ogg'};

  Future<AudioPackImportResult> importZip(
    File zipFile, {
    /// 同じ `packId` がすでにある場合に置き換えるか。false なら例外にする。
    bool replaceExisting = false,
  }) async {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(await zipFile.readAsBytes());
    } catch (e) {
      throw AudioPackImportException('ファイルを展開できません: $e');
    }

    final manifest = _readManifest(archive);
    final existing =
        await (_db.select(_db.audioPacks)
              ..where((t) => t.packId.equals(manifest.packId)))
            .getSingleOrNull();
    if (existing != null && !replaceExisting) {
      throw AudioPackImportException('同じ音声パックがすでに入っています: ${manifest.name}');
    }

    _validateFiles(archive, manifest);

    final destination = Directory(
      p.join(_documentsDir.path, kAudioPackDirName, manifest.packId),
    );
    // 置換のときは古い展開物を先に消す（混ざったまま残さない）。
    if (destination.existsSync()) destination.deleteSync(recursive: true);

    try {
      final resolved = await _resolveEntries(manifest);
      if (resolved.matched.isEmpty) {
        throw AudioPackImportException(
          'このパックの音声に対応する単語が1つもありません。'
          '先に単語帳を取り込んでから、もう一度お試しください。',
        );
      }
      _extract(archive, manifest, destination);

      await _db.transaction(() async {
        if (existing != null) {
          // word_audios は cascade で消える。
          await (_db.delete(_db.audioPacks)
                ..where((t) => t.id.equals(existing.id)))
              .go();
        }
        final sortOrder = await _nextSortOrder();
        final packRowId = await _db
            .into(_db.audioPacks)
            .insert(
              AudioPacksCompanion.insert(
                packId: manifest.packId,
                name: manifest.name,
                source: AudioPackSource.imported.value,
                lang: manifest.lang.value,
                note: Value(manifest.note),
                entryCount: Value(resolved.matched.length),
                sortOrder: Value(sortOrder),
              ),
            );
        for (final entry in resolved.matched) {
          await _db
              .into(_db.wordAudios)
              .insert(
                WordAudiosCompanion.insert(
                  wordId: entry.wordId,
                  packId: packRowId,
                  lang: manifest.lang.value,
                  // 展開先からの相対パスで持つ（端末が変わっても解決できる）。
                  filePath: p.join(manifest.packId, entry.file),
                ),
              );
        }
      });

      return AudioPackImportResult(
        packId: manifest.packId,
        name: manifest.name,
        importedCount: resolved.matched.length,
        unmatchedCount: resolved.unmatchedCount,
      );
    } catch (e) {
      // 展開済みファイルと DB の行を両方巻き戻す。
      if (destination.existsSync()) destination.deleteSync(recursive: true);
      rethrow;
    }
  }

  _Manifest _readManifest(Archive archive) {
    final file = archive.files
        .where((f) => f.isFile && p.basename(f.name) == 'manifest.json')
        .firstOrNull;
    if (file == null) {
      throw const AudioPackImportException('manifest.json が見つかりません');
    }
    final Object? json;
    try {
      json = jsonDecode(utf8.decode(file.content as List<int>));
    } catch (e) {
      throw AudioPackImportException('manifest.json を読み取れません: $e');
    }
    if (json is! Map<String, dynamic>) {
      throw const AudioPackImportException('manifest.json の形式が違います');
    }
    return _Manifest.fromJson(json);
  }

  /// エントリのファイルが ZIP 内に実在し、対応形式かを確認する。
  void _validateFiles(Archive archive, _Manifest manifest) {
    final names = {
      for (final f in archive.files)
        if (f.isFile) f.name,
    };
    final missing = <String>[];
    final unsupported = <String>[];
    for (final entry in manifest.entries) {
      if (!names.contains(entry.file)) {
        missing.add(entry.file);
        continue;
      }
      if (!supportedExtensions.contains(
        p.extension(entry.file).toLowerCase(),
      )) {
        unsupported.add(entry.file);
      }
    }
    if (unsupported.isNotEmpty) {
      throw AudioPackImportException(
        '対応していない形式が含まれています',
        unsupported.take(10).toList(),
      );
    }
    if (missing.isNotEmpty) {
      throw AudioPackImportException(
        '${missing.length}件の音声ファイルが見つかりません',
        missing.take(10).toList(),
      );
    }
  }

  /// エントリを DB の単語へ結び付ける。
  ///
  /// `partOfSpeech` を省いたエントリは、その見出し語の**全品詞**に同じ音声を紐付ける
  /// （発音が品詞で変わる語だけ品詞を書けばよい）。
  Future<({List<_ResolvedEntry> matched, int unmatchedCount})> _resolveEntries(
    _Manifest manifest,
  ) async {
    final matched = <_ResolvedEntry>[];
    var unmatched = 0;
    for (final entry in manifest.entries) {
      final query = _db.select(_db.words)
        ..where((t) => t.headword.equals(entry.headword.toLowerCase()));
      if (entry.partOfSpeech != null) {
        query.where((t) => t.partOfSpeech.equals(entry.partOfSpeech!.value));
      }
      final words = await query.get();
      if (words.isEmpty) {
        unmatched++;
        continue;
      }
      for (final word in words) {
        matched.add(_ResolvedEntry(wordId: word.id, file: entry.file));
      }
    }
    return (matched: matched, unmatchedCount: unmatched);
  }

  void _extract(Archive archive, _Manifest manifest, Directory destination) {
    final wanted = {for (final e in manifest.entries) e.file};
    destination.createSync(recursive: true);
    for (final file in archive.files) {
      if (!file.isFile || !wanted.contains(file.name)) continue;
      // ZIP 内の相対パスに `..` が混ざっていても展開先の外へ出さない。
      final normalized = p.normalize(file.name);
      if (normalized.startsWith('..') || p.isAbsolute(normalized)) {
        throw AudioPackImportException('不正なパスが含まれています: ${file.name}');
      }
      final out = File(p.join(destination.path, normalized))
        ..createSync(recursive: true);
      out.writeAsBytesSync(file.content as List<int>);
    }
  }

  Future<int> _nextSortOrder() async {
    final maxOrder = _db.audioPacks.sortOrder.max();
    final row = await (_db.selectOnly(_db.audioPacks)
          ..addColumns([maxOrder]))
        .getSingle();
    return (row.read(maxOrder) ?? -1) + 1;
  }
}

class _Manifest {
  final String packId;
  final String name;
  final SpeechLang lang;
  final String? note;
  final List<_ManifestEntry> entries;

  const _Manifest({
    required this.packId,
    required this.name,
    required this.lang,
    required this.note,
    required this.entries,
  });

  factory _Manifest.fromJson(Map<String, dynamic> json) {
    final packId = json['packId'];
    final name = json['name'];
    final lang = json['lang'];
    if (packId is! String || packId.isEmpty) {
      throw const AudioPackImportException('manifest.json に packId がありません');
    }
    if (name is! String || name.isEmpty) {
      throw const AudioPackImportException('manifest.json に name がありません');
    }
    if (lang is! String) {
      throw const AudioPackImportException('manifest.json に lang がありません');
    }
    final entries = json['entries'];
    if (entries is! List || entries.isEmpty) {
      throw const AudioPackImportException('manifest.json に entries がありません');
    }
    return _Manifest(
      packId: packId,
      name: name,
      lang: SpeechLang.values.firstWhere(
        (e) => e.value == lang,
        orElse: () => throw AudioPackImportException('lang が不正です: $lang'),
      ),
      note: json['note'] as String?,
      entries: [
        for (final e in entries)
          _ManifestEntry.fromJson(e as Map<String, dynamic>),
      ],
    );
  }
}

class _ManifestEntry {
  final String headword;
  final PartOfSpeech? partOfSpeech;
  final String file;

  const _ManifestEntry({
    required this.headword,
    required this.partOfSpeech,
    required this.file,
  });

  factory _ManifestEntry.fromJson(Map<String, dynamic> json) {
    final headword = json['headword'];
    final file = json['file'];
    if (headword is! String || headword.isEmpty) {
      throw const AudioPackImportException('entries に headword がありません');
    }
    if (file is! String || file.isEmpty) {
      throw AudioPackImportException('entries に file がありません: $headword');
    }
    final pos = json['partOfSpeech'];
    return _ManifestEntry(
      headword: headword,
      partOfSpeech: pos == null
          ? null
          : PartOfSpeech.values.firstWhere(
              (e) => e.value == pos,
              orElse: () =>
                  throw AudioPackImportException('品詞が不正です: $pos'),
            ),
      file: file,
    );
  }
}

class _ResolvedEntry {
  final int wordId;
  final String file;

  const _ResolvedEntry({required this.wordId, required this.file});
}
