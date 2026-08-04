import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:encello/core/utils/enums.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:encello/data/services/audio_library.dart' show kAudioPackDirName;
import 'package:encello/data/services/cleanup_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../helpers/test_database.dart';

/// 未所属の単語・使われていない音声ファイルの整理
/// （[Docs/06_features/export_import.md] §5.1・§5.2、[Docs/06_features/pronunciation.md] §3.3）。
void main() {
  late AppDatabase db;
  late CleanupService service;

  setUp(() {
    db = newTestDatabase();
    service = CleanupService(db);
  });

  group('未所属の単語', () {
    test('どの単語帳にも属さない語だけが対象になる', () async {
      final orphanId = await createSharedWord(db, headword: 'orphan');
      final linkedId = await createSharedWord(db, headword: 'linked');
      final bookId = await db
          .into(db.wordbooks)
          .insert(
            WordbooksCompanion.insert(
              name: '単語帳',
              emoji: '📗',
              colorSeed: 0,
              category: WordbookCategory.custom.value,
              source: WordbookSource.user.value,
            ),
          );
      await db
          .into(db.wordbookEntries)
          .insert(
            WordbookEntriesCompanion.insert(
              wordbookId: bookId,
              wordId: linkedId,
            ),
          );

      final inspection = await service.inspectOrphanWords();
      expect(inspection.wordCount, 1);
      expect(inspection.withProgressCount, 0);

      final deleted = await service.deleteOrphanWords();
      expect(deleted, 1);

      final remaining = await db.select(db.words).get();
      expect(remaining.map((w) => w.id), [linkedId]);
      expect(remaining.map((w) => w.id), isNot(contains(orphanId)));
    });

    test('学習状態が付いている語の件数を数える', () async {
      final profile = await createTestProfile(db, name: 'たろう');
      final orphanId = await createSharedWord(db, headword: 'orphan');
      await db
          .into(db.wordReviews)
          .insert(
            WordReviewsCompanion.insert(
              profileId: profile.id,
              wordId: orphanId,
              dueAt: DateTime(2026, 8, 5),
            ),
          );

      final inspection = await service.inspectOrphanWords();
      expect(inspection.wordCount, 1);
      expect(inspection.withProgressCount, 1);
    });
  });

  test('未所属の語に他の学習者のマイ単語が含まれていれば数える', () async {
    final other = await createTestProfile(db, name: 'ほかのひと', colorSeed: 1);
    await db
        .into(db.words)
        .insert(
          WordsCompanion.insert(
            headword: 'orphanmine',
            partOfSpeech: PartOfSpeech.noun.value,
            meaning: 'どこにも属さないマイ単語',
            ownerProfileId: Value(other.id),
          ),
        );

    final inspection = await service.inspectOrphanWords();

    // 端末全体が対象なので、ほかの学習者のマイ単語も対象に入る。
    expect(inspection.wordCount, greaterThanOrEqualTo(1));
    expect(inspection.myWordCount, 1);
  });

  group('使われていない音声ファイル', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('encello_cleanup_test');
    });

    tearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    Future<void> writeFile(String relativePath, List<int> bytes) async {
      final file = File(p.join(tempDir.path, kAudioPackDirName, relativePath));
      file.createSync(recursive: true);
      await file.writeAsBytes(bytes);
    }

    test('word_audios にあるファイルは消えず、無いファイルだけ消える', () async {
      final wordId = await createSharedWord(db, headword: 'apple');
      final packId = await db
          .into(db.audioPacks)
          .insert(
            AudioPacksCompanion.insert(
              packId: 'pack_v1',
              name: 'テストパック',
              source: AudioPackSource.imported.value,
              lang: SpeechLang.en.value,
            ),
          );
      await db
          .into(db.wordAudios)
          .insert(
            WordAudiosCompanion.insert(
              wordId: wordId,
              packId: packId,
              lang: SpeechLang.en.value,
              filePath: p.join('pack_v1', 'apple.mp3'),
            ),
          );

      await writeFile(p.join('pack_v1', 'apple.mp3'), List.filled(100, 1));
      await writeFile(p.join('pack_v1', 'orphan.mp3'), List.filled(250, 2));

      final inspection = await service.inspectUnusedAudioFiles(tempDir.path);
      expect(inspection.fileCount, 1);
      expect(inspection.freedBytes, 250);

      final result = await service.deleteUnusedAudioFiles(tempDir.path);
      expect(result.fileCount, 1);
      expect(result.freedBytes, 250);

      expect(
        File(p.join(tempDir.path, kAudioPackDirName, 'pack_v1', 'apple.mp3'))
            .existsSync(),
        isTrue,
      );
      expect(
        File(p.join(tempDir.path, kAudioPackDirName, 'pack_v1', 'orphan.mp3'))
            .existsSync(),
        isFalse,
      );
    });

    test('音声パックのディレクトリが無ければ0件として扱う', () async {
      final inspection = await service.inspectUnusedAudioFiles(tempDir.path);
      expect(inspection.fileCount, 0);
      expect(inspection.freedBytes, 0);
    });
  });
}
