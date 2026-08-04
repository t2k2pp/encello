import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:encello/core/utils/enums.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:encello/data/services/audio_pack_importer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late Directory documents;
  late AudioPackImporter importer;

  setUp(() {
    db = newTestDatabase();
    documents = Directory.systemTemp.createTempSync('encello_audio_test');
    // ファイル I/O を伴うテストは必ず後片付けする（[Docs/07_testing_strategy.md] §4）。
    addTearDown(() {
      if (documents.existsSync()) documents.deleteSync(recursive: true);
    });
    importer = AudioPackImporter(db, documents);
  });

  /// テスト用の ZIP を組み立ててファイルに書く。
  File makeZip({
    Map<String, Object?>? manifest,
    List<String> audioFiles = const ['audio/apple.mp3'],
    bool includeManifest = true,
  }) {
    final archive = Archive();
    if (includeManifest) {
      final bytes = utf8.encode(
        jsonEncode(
          manifest ??
              {
                'packId': 'jhs_en_us_v1',
                'name': '中学英単語 音声（米）',
                'lang': 'en',
                'note': 'テスト用',
                'entries': [
                  {'headword': 'apple', 'file': 'audio/apple.mp3'},
                ],
              },
        ),
      );
      archive.addFile(ArchiveFile('manifest.json', bytes.length, bytes));
    }
    for (final name in audioFiles) {
      final bytes = utf8.encode('dummy audio');
      archive.addFile(ArchiveFile(name, bytes.length, bytes));
    }
    final file = File(p.join(documents.path, 'pack.zip'))
      ..writeAsBytesSync(ZipEncoder().encode(archive));
    return file;
  }

  Future<int> addWord(String headword, {String pos = 'noun'}) =>
      createSharedWord(db, headword: headword, partOfSpeech: pos);

  group('取り込み', () {
    test('音声が単語に紐付き、ファイルが展開される', () async {
      final wordId = await addWord('apple');

      final result = await importer.importZip(makeZip());

      expect(result.packId, 'jhs_en_us_v1');
      expect(result.importedCount, 1);
      expect(result.unmatchedCount, 0);

      final pack = await db.select(db.audioPacks).getSingle();
      expect(pack.name, '中学英単語 音声（米）');
      expect(pack.source, AudioPackSource.imported.value);
      expect(pack.entryCount, 1);

      final audio = await db.select(db.wordAudios).getSingle();
      expect(audio.wordId, wordId);
      expect(audio.lang, SpeechLang.en.value);
      // 展開先からの相対パスで持つ。
      expect(audio.filePath, p.join('jhs_en_us_v1', 'audio/apple.mp3'));

      expect(
        File(
          p.join(documents.path, 'audio_packs', 'jhs_en_us_v1', 'audio', 'apple.mp3'),
        ).existsSync(),
        isTrue,
      );
    });

    test('品詞を省いたエントリは同じ見出し語の全品詞に紐付く', () async {
      await addWord('run', pos: 'noun');
      await addWord('run', pos: 'verb');

      final result = await importer.importZip(
        makeZip(
          manifest: {
            'packId': 'pack1',
            'name': 'パック',
            'lang': 'en',
            'entries': [
              {'headword': 'run', 'file': 'audio/run.mp3'},
            ],
          },
          audioFiles: ['audio/run.mp3'],
        ),
      );

      expect(result.importedCount, 2);
      expect(await db.select(db.wordAudios).get(), hasLength(2));
    });

    test('品詞を書いたエントリはその品詞にだけ紐付く', () async {
      await addWord('record', pos: 'noun');
      await addWord('record', pos: 'verb');

      await importer.importZip(
        makeZip(
          manifest: {
            'packId': 'pack1',
            'name': 'パック',
            'lang': 'en',
            'entries': [
              {
                'headword': 'record',
                'partOfSpeech': 'verb',
                'file': 'audio/record.mp3',
              },
            ],
          },
          audioFiles: ['audio/record.mp3'],
        ),
      );

      final audio = await db.select(db.wordAudios).getSingle();
      final word = await (db.select(db.words)
            ..where((t) => t.id.equals(audio.wordId)))
          .getSingle();
      expect(word.partOfSpeech, 'verb');
    });

    test('該当する単語が無いエントリは件数を報告して取り込まない', () async {
      await addWord('apple');

      final result = await importer.importZip(
        makeZip(
          manifest: {
            'packId': 'pack1',
            'name': 'パック',
            'lang': 'en',
            'entries': [
              {'headword': 'apple', 'file': 'audio/apple.mp3'},
              {'headword': 'unknown', 'file': 'audio/unknown.mp3'},
            ],
          },
          audioFiles: ['audio/apple.mp3', 'audio/unknown.mp3'],
        ),
      );

      expect(result.importedCount, 1);
      expect(result.unmatchedCount, 1);
      // 音声のためだけに単語を作らない。
      expect(await db.select(db.words).get(), hasLength(1));
    });
  });

  group('検証（致命的なら1件も取り込まない）', () {
    test('manifest.json が無ければ取り込まない', () async {
      await addWord('apple');
      await expectLater(
        importer.importZip(makeZip(includeManifest: false)),
        throwsA(isA<AudioPackImportException>()),
      );
      expect(await db.select(db.audioPacks).get(), isEmpty);
    });

    test('音声ファイルが欠けていれば取り込まない', () async {
      await addWord('apple');
      await expectLater(
        importer.importZip(makeZip(audioFiles: const [])),
        throwsA(
          isA<AudioPackImportException>().having(
            (e) => e.message,
            'message',
            contains('見つかりません'),
          ),
        ),
      );
      expect(await db.select(db.wordAudios).get(), isEmpty);
      expect(
        Directory(p.join(documents.path, 'audio_packs')).existsSync(),
        isFalse,
      );
    });

    test('対応していない形式があれば取り込まない', () async {
      await addWord('apple');
      await expectLater(
        importer.importZip(
          makeZip(
            manifest: {
              'packId': 'pack1',
              'name': 'パック',
              'lang': 'en',
              'entries': [
                {'headword': 'apple', 'file': 'audio/apple.flac'},
              ],
            },
            audioFiles: ['audio/apple.flac'],
          ),
        ),
        throwsA(
          isA<AudioPackImportException>().having(
            (e) => e.message,
            'message',
            contains('対応していない形式'),
          ),
        ),
      );
      expect(await db.select(db.audioPacks).get(), isEmpty);
    });

    test('1件も単語に紐付かなければ取り込まない', () async {
      await expectLater(
        importer.importZip(makeZip()),
        throwsA(isA<AudioPackImportException>()),
      );
      expect(await db.select(db.audioPacks).get(), isEmpty);
      expect(
        Directory(
          p.join(documents.path, 'audio_packs', 'jhs_en_us_v1'),
        ).existsSync(),
        isFalse,
      );
    });

    test('同じパックが入っていれば、置換を選ばない限り取り込まない', () async {
      await addWord('apple');
      await importer.importZip(makeZip());

      await expectLater(
        importer.importZip(makeZip()),
        throwsA(
          isA<AudioPackImportException>().having(
            (e) => e.message,
            'message',
            contains('すでに入っています'),
          ),
        ),
      );
      expect(await db.select(db.audioPacks).get(), hasLength(1));
    });

    test('置換を選べば古いパックと音声を入れ替える', () async {
      await addWord('apple');
      await importer.importZip(makeZip());
      final first = await db.select(db.audioPacks).getSingle();

      await importer.importZip(makeZip(), replaceExisting: true);

      final packs = await db.select(db.audioPacks).get();
      expect(packs, hasLength(1));
      expect(packs.single.id, isNot(first.id));
      expect(await db.select(db.wordAudios).get(), hasLength(1));
    });

    test('展開先の外へ出るパスは取り込まない', () async {
      await addWord('apple');
      await expectLater(
        importer.importZip(
          makeZip(
            manifest: {
              'packId': 'pack1',
              'name': 'パック',
              'lang': 'en',
              'entries': [
                {'headword': 'apple', 'file': '../evil.mp3'},
              ],
            },
            audioFiles: ['../evil.mp3'],
          ),
        ),
        throwsA(isA<AudioPackImportException>()),
      );
      expect(await db.select(db.audioPacks).get(), isEmpty);
    });
  });
}
