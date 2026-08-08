import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:encello/core/utils/enums.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:encello/data/repositories/wordbook_repository.dart';
import 'package:encello/data/services/export_import_service.dart';
import 'package:encello/domain/usecases/wordbook_csv_codec.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

/// [Docs/06_features/export_import.md] §6 のテスト観点。
void main() {
  late AppDatabase source;
  late AppDatabase target;

  final exportedAt = DateTime(2026, 8, 5, 21, 30);

  setUp(() {
    source = newTestDatabase();
    target = newTestDatabase();
  });

  /// 2人の学習者・単語帳・語の部品・語族・マイ単語・学習記録を持つ DB を作る。
  Future<({Profile taro, Profile jiro, int appleId, int bookId})> seedAll(
    AppDatabase db,
  ) async {
    final taro = await createTestProfile(db, name: 'たろう', colorSeed: 0);
    final jiro = await createTestProfile(db, name: 'じろう', colorSeed: 1);

    final familyId = await db
        .into(db.wordFamilies)
        .insert(WordFamiliesCompanion.insert(baseForm: 'decide'));
    final partId = await db
        .into(db.wordParts)
        .insert(
          WordPartsCompanion.insert(
            form: 'port',
            type: WordPartType.root.value,
            meaning: '運ぶ',
          ),
        );

    final books = WordbookRepository(db);
    final bookId = await books.create(name: '中学英単語', emoji: '🏫', colorSeed: 2);

    final appleId = await db
        .into(db.words)
        .insert(
          WordsCompanion.insert(
            headword: 'apple',
            partOfSpeech: PartOfSpeech.noun.value,
            meaning: 'りんご',
            phonetic: const Value('/ˈæpl/'),
            familyId: Value(familyId),
          ),
        );
    await db
        .into(db.wordExamples)
        .insert(
          WordExamplesCompanion.insert(
            wordId: appleId,
            exampleEn: 'I ate an apple.',
            exampleJa: const Value('りんごを食べました。'),
            sourcePresetId: const Value('jhs_v1'),
            sortOrder: const Value(10),
          ),
        );
    final importId = await db
        .into(db.words)
        .insert(
          WordsCompanion.insert(
            headword: 'import',
            partOfSpeech: PartOfSpeech.verb.value,
            meaning: '輸入する',
          ),
        );
    await db
        .into(db.wordPartLinks)
        .insert(
          WordPartLinksCompanion.insert(wordId: importId, partId: partId),
        );
    await books.addWord(bookId, appleId);
    await books.addWord(bookId, importId);
    await books.setStudyTarget(taro, bookId, selected: true);

    // たろうのマイ単語（じろうには見えない語）。実アプリと同じく
    // その人のマイ単語帳に所属させる（[Docs/06_features/my_words.md] §2）。
    final myWordId = await db
        .into(db.words)
        .insert(
          WordsCompanion.insert(
            headword: 'serendipity',
            partOfSpeech: PartOfSpeech.noun.value,
            meaning: '偶然の幸運',
            ownerProfileId: Value(taro.id),
          ),
        );
    final myBook =
        await (db.select(db.wordbooks)..where(
              (t) =>
                  t.ownerProfileId.equals(taro.id) &
                  t.category.equals(WordbookCategory.myWords.value),
            ))
            .getSingle();
    await books.addWord(myBook.id, myWordId);

    // 学習状態・履歴・日次集計・実績・測定・取り違え。
    await db
        .into(db.wordReviews)
        .insert(
          WordReviewsCompanion.insert(
            profileId: taro.id,
            wordId: appleId,
            dueAt: DateTime(2026, 8, 10),
            repetition: const Value(3),
            intervalDays: const Value(16),
            easeFactor: const Value(2.6),
            lastReviewedAt: Value(DateTime(2026, 8, 4)),
            totalCorrect: const Value(5),
            masteryLevel: const Value(1),
          ),
        );
    await db
        .into(db.partReviews)
        .insert(
          PartReviewsCompanion.insert(
            profileId: taro.id,
            partId: partId,
            dueAt: DateTime(2026, 8, 12),
            lastReviewedAt: Value(DateTime(2026, 8, 3)),
            masteryLevel: const Value(2),
          ),
        );
    await db
        .into(db.studySessions)
        .insert(
          StudySessionsCompanion.insert(
            id: 'session-taro-1',
            profileId: taro.id,
            mode: StudyMode.spell.value,
            startedAt: DateTime(2026, 8, 4, 20),
            finishedAt: Value(DateTime(2026, 8, 4, 20, 10)),
            answeredCount: const Value(2),
            correctCount: const Value(1),
            xpEarned: const Value(30),
          ),
        );
    await db
        .into(db.learningLogs)
        .insert(
          LearningLogsCompanion.insert(
            profileId: taro.id,
            sessionId: 'session-taro-1',
            wordId: Value(appleId),
            mode: StudyMode.spell.value,
            direction: StudyDirection.jaToEn.value,
            isCorrect: true,
            grade: 4,
            elapsedMs: 3000,
            answeredAt: DateTime(2026, 8, 4, 20, 1),
          ),
        );
    await db
        .into(db.dailyStats)
        .insert(
          DailyStatsCompanion.insert(
            profileId: taro.id,
            studyDate: '2026-08-04',
            goalCount: 20,
            answeredCount: const Value(12),
            correctCount: const Value(9),
            xp: const Value(150),
            goalMet: const Value(false),
          ),
        );
    await db
        .into(db.achievements)
        .insert(
          AchievementsCompanion.insert(
            profileId: taro.id,
            code: 'first_session',
            unlockedAt: DateTime(2026, 8, 4, 20, 10),
          ),
        );
    await db
        .into(db.vocabSizeTests)
        .insert(
          VocabSizeTestsCompanion.insert(
            profileId: taro.id,
            takenAt: DateTime(2026, 8, 1, 9),
            estimatedSize: 2180,
            falseAlarmRate: 0.2,
          ),
        );
    await db
        .into(db.resolvedConfusions)
        .insert(
          ResolvedConfusionsCompanion.insert(
            profileId: taro.id,
            wordIdA: appleId < importId ? appleId : importId,
            wordIdB: appleId < importId ? importId : appleId,
            resolvedAt: Value(DateTime(2026, 8, 2)),
          ),
        );

    return (taro: taro, jiro: jiro, appleId: appleId, bookId: bookId);
  }

  Future<int> countOf(AppDatabase db, TableInfo<Table, dynamic> table) async {
    final expr = countAll();
    final row = await (db.selectOnly(table)..addColumns([expr])).getSingle();
    return row.read(expr) ?? 0;
  }

  group('ラウンドトリップ', () {
    test('エクスポート → 空 DB へインポートで件数と値が一致する', () async {
      final seeded = await seedAll(source);
      final payload = await ExportImportService(
        source,
      ).collectBackup(exportedAt: exportedAt);
      final json = encodeBackupJson(payload);

      final service = ExportImportService(target);
      final preview = await service.inspect(json);
      expect(preview.profiles, {'たろう': true, 'じろう': true});
      expect(preview.newWordCount, preview.wordCount);

      await service.apply(preview, mode: ImportMode.merge);

      // 学習者（マイ単語帳も一緒にできる）。
      expect(await countOf(target, target.profiles), 2);
      // 共有の語 + マイ単語。
      expect(
        await countOf(target, target.words),
        await countOf(source, source.words),
      );
      expect(
        await countOf(target, target.wordbookEntries),
        await countOf(source, source.wordbookEntries),
      );
      expect(await countOf(target, target.wordFamilies), 1);
      expect(await countOf(target, target.wordParts), 1);
      expect(await countOf(target, target.wordPartLinks), 1);
      expect(await countOf(target, target.wordReviews), 1);
      expect(await countOf(target, target.partReviews), 1);
      expect(await countOf(target, target.studySessions), 1);
      expect(await countOf(target, target.learningLogs), 1);
      expect(await countOf(target, target.dailyStats), 1);
      expect(await countOf(target, target.achievements), 1);
      expect(await countOf(target, target.vocabSizeTests), 1);
      expect(await countOf(target, target.resolvedConfusions), 1);

      // 値の一致（学習状態・語の中身）。
      final review = await target.select(target.wordReviews).getSingle();
      expect(review.repetition, 3);
      expect(review.intervalDays, 16);
      expect(review.easeFactor, 2.6);
      expect(review.lastReviewedAt, DateTime(2026, 8, 4));

      final apple = await (target.select(
        target.words,
      )..where((t) => t.headword.equals('apple'))).getSingle();
      expect(apple.meaning, 'りんご');
      expect(apple.phonetic, '/ˈæpl/');
      expect(apple.familyId, isNotNull);

      // 例文は `words[].examples` に全件入り、`sourcePresetId` も持ち回る
      // （[Docs/03_data_model.md] §10）。
      final exported = (payload['words'] as List)
          .cast<Map<String, dynamic>>()
          .firstWhere((w) => w['headword'] == 'apple');
      expect(exported['examples'], [
        {
          'en': 'I ate an apple.',
          'ja': 'りんごを食べました。',
          'sourcePresetId': 'jhs_v1',
          'sortOrder': 10,
        },
      ]);
      final restored = await (target.select(
        target.wordExamples,
      )..where((t) => t.wordId.equals(apple.id))).getSingle();
      expect(restored.exampleEn, 'I ate an apple.');
      expect(restored.sourcePresetId, 'jhs_v1');
      expect(restored.sortOrder, 10);

      // 学習対象の単語帳が名前で復元される。
      final taro = await (target.select(
        target.profiles,
      )..where((t) => t.name.equals('たろう'))).getSingle();
      expect(decodeIdList(taro.selectedWordbookIds), isNotEmpty);
      expect(seeded.bookId, isNotNull);
    });

    test('マイ単語が正しい学習者に入る', () async {
      await seedAll(source);
      final service = ExportImportService(target);
      final json = encodeBackupJson(
        await ExportImportService(source).collectBackup(exportedAt: exportedAt),
      );
      await service.apply(await service.inspect(json), mode: ImportMode.merge);

      final taro = await (target.select(
        target.profiles,
      )..where((t) => t.name.equals('たろう'))).getSingle();
      final mine = await (target.select(
        target.words,
      )..where((t) => t.ownerProfileId.equals(taro.id))).get();
      expect(mine.map((w) => w.headword), ['serendipity']);
    });

    test('エクスポートに音声パックのバイナリが含まれない', () async {
      await seedAll(source);
      await source
          .into(source.audioPacks)
          .insert(
            AudioPacksCompanion.insert(
              packId: 'pack_v1',
              name: '音声パック',
              source: AudioPackSource.imported.value,
              lang: SpeechLang.en.value,
            ),
          );

      final json = encodeBackupJson(
        await ExportImportService(source).collectBackup(exportedAt: exportedAt),
      );
      expect(json.contains('audioPacks'), isFalse);
      expect(json.contains('pack_v1'), isFalse);
    });
  });

  group('「追加」での衝突解決', () {
    /// 取り込み先に、同じ語・同じ学習者をあらかじめ作っておく。
    Future<Profile> seedExisting() async {
      final taro = await createTestProfile(target, name: 'たろう');
      await target
          .into(target.words)
          .insert(
            WordsCompanion.insert(
              headword: 'apple',
              partOfSpeech: PartOfSpeech.noun.value,
              meaning: '手元で直した訳',
            ),
          );
      await target
          .into(target.wordParts)
          .insert(
            WordPartsCompanion.insert(
              form: 'port',
              type: WordPartType.root.value,
              meaning: '手元で直した意味',
            ),
          );
      return taro;
    }

    test('既存の単語・語の部品の意味が上書きされない', () async {
      await seedAll(source);
      await seedExisting();
      final service = ExportImportService(target);
      final json = encodeBackupJson(
        await ExportImportService(source).collectBackup(exportedAt: exportedAt),
      );
      await service.apply(await service.inspect(json), mode: ImportMode.merge);

      final apple =
          await (target.select(target.words)..where(
                (t) => t.headword.equals('apple') & t.ownerProfileId.isNull(),
              ))
              .getSingle();
      expect(apple.meaning, '手元で直した訳');

      final part = await target.select(target.wordParts).getSingle();
      expect(part.meaning, '手元で直した意味');
    });

    test('同名の学習者は新規作成されず、既存の設定が上書きされない', () async {
      await seedAll(source);
      final existing = await seedExisting();
      await target.profileDao.updateProfile(
        existing.id,
        const ProfilesCompanion(dailyGoal: Value(50)),
      );

      final service = ExportImportService(target);
      final json = encodeBackupJson(
        await ExportImportService(source).collectBackup(exportedAt: exportedAt),
      );
      final preview = await service.inspect(json);
      expect(preview.profiles['たろう'], isFalse, reason: '既存の学習者は新規ではない');
      expect(preview.profiles['じろう'], isTrue);

      await service.apply(preview, mode: ImportMode.merge);

      final taro = await (target.select(
        target.profiles,
      )..where((t) => t.name.equals('たろう'))).get();
      expect(taro.length, 1);
      expect(taro.single.dailyGoal, 50);
    });

    test('学習状態は lastReviewedAt が新しい方を採る（取り込む側が新しい）', () async {
      await seedAll(source);
      final taro = await seedExisting();
      final apple = await (target.select(
        target.words,
      )..where((t) => t.headword.equals('apple'))).getSingle();
      await target
          .into(target.wordReviews)
          .insert(
            WordReviewsCompanion.insert(
              profileId: taro.id,
              wordId: apple.id,
              dueAt: DateTime(2026, 8, 6),
              // 取り込む側（8/4）より古い。
              lastReviewedAt: Value(DateTime(2026, 8, 1)),
              repetition: const Value(1),
            ),
          );

      final service = ExportImportService(target);
      final json = encodeBackupJson(
        await ExportImportService(source).collectBackup(exportedAt: exportedAt),
      );
      await service.apply(await service.inspect(json), mode: ImportMode.merge);

      final review = await target.select(target.wordReviews).getSingle();
      expect(review.repetition, 3, reason: '取り込む側（新しい方）を採る');
      expect(review.lastReviewedAt, DateTime(2026, 8, 4));
    });

    test('学習状態は lastReviewedAt が新しい方を採る（手元が新しい）', () async {
      await seedAll(source);
      final taro = await seedExisting();
      final apple = await (target.select(
        target.words,
      )..where((t) => t.headword.equals('apple'))).getSingle();
      await target
          .into(target.wordReviews)
          .insert(
            WordReviewsCompanion.insert(
              profileId: taro.id,
              wordId: apple.id,
              dueAt: DateTime(2026, 8, 20),
              // 取り込む側（8/4）より新しい。
              lastReviewedAt: Value(DateTime(2026, 8, 5)),
              repetition: const Value(9),
            ),
          );

      final service = ExportImportService(target);
      final json = encodeBackupJson(
        await ExportImportService(source).collectBackup(exportedAt: exportedAt),
      );
      await service.apply(await service.inspect(json), mode: ImportMode.merge);

      final review = await target.select(target.wordReviews).getSingle();
      expect(review.repetition, 9, reason: '手元（新しい方）を残す');
    });

    test('日次集計は合算し、goalMet は OR になる', () async {
      await seedAll(source);
      final taro = await seedExisting();
      await target
          .into(target.dailyStats)
          .insert(
            DailyStatsCompanion.insert(
              profileId: taro.id,
              studyDate: '2026-08-04',
              goalCount: 20,
              answeredCount: const Value(8),
              correctCount: const Value(6),
              xp: const Value(100),
              goalMet: const Value(true),
            ),
          );

      final service = ExportImportService(target);
      final json = encodeBackupJson(
        await ExportImportService(source).collectBackup(exportedAt: exportedAt),
      );
      await service.apply(await service.inspect(json), mode: ImportMode.merge);

      final stat = await target.select(target.dailyStats).getSingle();
      expect(stat.answeredCount, 8 + 12);
      expect(stat.correctCount, 6 + 9);
      expect(stat.xp, 100 + 150);
      expect(stat.goalMet, isTrue, reason: '片方でも達成していれば達成');
    });

    test('同じセッションを2回取り込んでも履歴が二重にならない', () async {
      await seedAll(source);
      final service = ExportImportService(target);
      final json = encodeBackupJson(
        await ExportImportService(source).collectBackup(exportedAt: exportedAt),
      );
      await service.apply(await service.inspect(json), mode: ImportMode.merge);
      await service.apply(await service.inspect(json), mode: ImportMode.merge);

      expect(await countOf(target, target.studySessions), 1);
      expect(await countOf(target, target.learningLogs), 1);
      expect(await countOf(target, target.vocabSizeTests), 1);
    });
  });

  // CSV は1語1行なので例文は1つだけ（[Docs/03_data_model.md] §10）。
  group('CSV', () {
    test('書き出す例文はその単語帳のもの', () async {
      final seeded = await seedAll(source);
      // 単語帳をプリセット扱いにし、別の単語帳の例文も足しておく。
      await (source.update(source.wordbooks)
            ..where((t) => t.id.equals(seeded.bookId)))
          .write(const WordbooksCompanion(presetId: Value('jhs_v1')));
      await source
          .into(source.wordExamples)
          .insert(
            WordExamplesCompanion.insert(
              wordId: seeded.appleId,
              exampleEn: 'The apple is on sale.',
              exampleJa: const Value('そのりんごは特売中です。'),
              sourcePresetId: const Value('toeic_basic_v1'),
              sortOrder: const Value(60),
            ),
          );

      final csv = await ExportImportService(source).collectCsv(seeded.bookId);

      expect(csv, contains('I ate an apple.'));
      expect(csv, isNot(contains('The apple is on sale.')));
    });

    test('取り込んだ例文は sourcePresetId = null で入る', () async {
      final me = await createTestProfile(target, name: 'たろう');
      final bookId = await WordbookRepository(
        target,
      ).create(name: 'わたしの単語帳', emoji: '📗', colorSeed: 1);
      expect(me.id, isNotNull);

      await ExportImportService(target).importCsv(bookId, const [
        CsvWord(
          headword: 'apple',
          partOfSpeech: PartOfSpeech.noun,
          phonetic: null,
          meaning: 'りんご',
          exampleEn: 'I ate an apple.',
          exampleJa: 'りんごを食べました。',
          level: 1,
        ),
      ]);

      final example = await target.select(target.wordExamples).getSingle();
      expect(example.exampleEn, 'I ate an apple.');
      expect(example.sourcePresetId, isNull);
      expect(example.sortOrder, 0);
    });
  });

  group('検証', () {
    test('formatVersion: 2 は拒否される', () async {
      const json =
          '{"formatVersion": 2, "profiles": [], '
          '"wordbooks": [], "words": []}';
      expect(
        () => ExportImportService(target).inspect(json),
        throwsA(
          isA<BackupFormatException>().having(
            (e) => e.message,
            'message',
            contains('新しいバージョン'),
          ),
        ),
      );
    });

    test('JSON として読めないファイルは拒否される', () async {
      expect(
        () => ExportImportService(target).inspect('これはバックアップではありません'),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('必須キーが無いファイルは拒否される', () async {
      expect(
        () => ExportImportService(target).inspect('{"formatVersion": 1}'),
        throwsA(
          isA<BackupFormatException>().having(
            (e) => e.message,
            'message',
            contains('profiles'),
          ),
        ),
      );
    });

    test('単語の必須項目が欠けていれば1件も取り込まれない', () async {
      const json =
          '{"formatVersion": 1, "profiles": [], "wordbooks": [], "words": ['
          '{"headword": "apple", "partOfSpeech": "noun", "meaning": "りんご"},'
          '{"headword": "banana", "partOfSpeech": "noun"},'
          '{"headword": "", "partOfSpeech": "noun", "meaning": "から"}]}';
      final service = ExportImportService(target);

      await expectLater(
        () => service.inspect(json),
        throwsA(
          isA<BackupFormatException>()
              .having((e) => e.message, 'message', contains('2件'))
              .having((e) => e.details.length, 'details', 2),
        ),
      );
      expect(await countOf(target, target.words), 0);
    });
  });

  group('置換', () {
    test('既存を消してから取り込む', () async {
      await seedAll(source);
      await createTestProfile(target, name: 'けしたいひと');
      await target
          .into(target.words)
          .insert(
            WordsCompanion.insert(
              headword: 'obsolete',
              partOfSpeech: PartOfSpeech.adjective.value,
              meaning: '古い',
            ),
          );

      final service = ExportImportService(target);
      final json = encodeBackupJson(
        await ExportImportService(source).collectBackup(exportedAt: exportedAt),
      );
      await service.apply(
        await service.inspect(json),
        mode: ImportMode.replace,
      );

      final names = (await target.select(target.profiles).get()).map(
        (p) => p.name,
      );
      expect(names, ['たろう', 'じろう']);
      final headwords = (await target.select(target.words).get()).map(
        (w) => w.headword,
      );
      expect(headwords, isNot(contains('obsolete')));
    });
  });
}
