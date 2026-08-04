import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:encello/core/utils/enums.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:encello/data/services/reset_progress_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

/// 学習状態のリセット（[Docs/06_features/export_import.md] §5、§6）。
void main() {
  late AppDatabase db;
  late ResetProgressService service;

  setUp(() {
    db = newTestDatabase();
    service = ResetProgressService(db);
  });

  /// [profileId] に、リセット対象8テーブルすべてに1行ずつ記録を作る。
  /// 併せて単語・単語帳・マイ単語（リセットで残るべきもの）も1件ずつ作る。
  Future<int> seedFullProgress(AppDatabase db, int profileId) async {
    final wordId = await db
        .into(db.words)
        .insert(
          WordsCompanion.insert(
            headword: 'apple_$profileId',
            partOfSpeech: PartOfSpeech.noun.value,
            meaning: 'りんご',
          ),
        );
    final partId = await db
        .into(db.wordParts)
        .insert(
          WordPartsCompanion.insert(
            form: 'port_$profileId',
            type: WordPartType.root.value,
            meaning: '運ぶ',
          ),
        );
    final wordId2 = await db
        .into(db.words)
        .insert(
          WordsCompanion.insert(
            headword: 'banana_$profileId',
            partOfSpeech: PartOfSpeech.noun.value,
            meaning: 'バナナ',
          ),
        );

    await db
        .into(db.wordReviews)
        .insert(
          WordReviewsCompanion.insert(
            profileId: profileId,
            wordId: wordId,
            dueAt: DateTime(2026, 8, 5),
          ),
        );
    await db
        .into(db.partReviews)
        .insert(
          PartReviewsCompanion.insert(
            profileId: profileId,
            partId: partId,
            dueAt: DateTime(2026, 8, 5),
          ),
        );

    final sessionId = 'session_$profileId';
    await db
        .into(db.studySessions)
        .insert(
          StudySessionsCompanion.insert(
            id: sessionId,
            profileId: profileId,
            mode: StudyMode.spell.value,
            startedAt: DateTime(2026, 8, 5, 10),
          ),
        );
    await db
        .into(db.learningLogs)
        .insert(
          LearningLogsCompanion.insert(
            profileId: profileId,
            sessionId: sessionId,
            wordId: Value(wordId),
            mode: StudyMode.spell.value,
            direction: StudyDirection.jaToEn.value,
            isCorrect: true,
            grade: 4,
            elapsedMs: 1000,
            answeredAt: DateTime(2026, 8, 5, 10, 1),
          ),
        );
    await db
        .into(db.dailyStats)
        .insert(
          DailyStatsCompanion.insert(
            profileId: profileId,
            studyDate: '2026-08-05',
            goalCount: 20,
          ),
        );
    await db
        .into(db.achievements)
        .insert(
          AchievementsCompanion.insert(
            profileId: profileId,
            code: 'streak_7',
            unlockedAt: DateTime(2026, 8, 5),
          ),
        );
    await db
        .into(db.vocabSizeTests)
        .insert(
          VocabSizeTestsCompanion.insert(
            profileId: profileId,
            takenAt: DateTime(2026, 8, 5),
            estimatedSize: 1000,
            falseAlarmRate: 0.1,
          ),
        );
    await db
        .into(db.resolvedConfusions)
        .insert(
          ResolvedConfusionsCompanion.insert(
            profileId: profileId,
            wordIdA: wordId < wordId2 ? wordId : wordId2,
            wordIdB: wordId < wordId2 ? wordId2 : wordId,
          ),
        );

    return wordId;
  }

  test('inspect が各テーブルの件数を正しく数える', () async {
    final taro = await createTestProfile(db, name: 'たろう');
    await seedFullProgress(db, taro.id);

    final counts = await service.inspect(taro.id);
    expect(counts.wordReviews, 1);
    expect(counts.partReviews, 1);
    expect(counts.learningLogs, 1);
    expect(counts.studySessions, 1);
    expect(counts.dailyStats, 1);
    expect(counts.achievements, 1);
    expect(counts.vocabSizeTests, 1);
    expect(counts.resolvedConfusions, 1);
  });

  test('リセットで対象8テーブルが空になる', () async {
    final taro = await createTestProfile(db, name: 'たろう');
    await seedFullProgress(db, taro.id);

    await service.reset(taro.id);

    final counts = await service.inspect(taro.id);
    expect(counts.total, 0);
  });

  test('words・wordbooks・マイ単語の件数は変わらない', () async {
    final taro = await createTestProfile(db, name: 'たろう');
    await seedFullProgress(db, taro.id);

    final wordCountBefore = (await db.select(db.words).get()).length;
    final wordbookCountBefore = (await db.select(db.wordbooks).get()).length;

    await service.reset(taro.id);

    final wordCountAfter = (await db.select(db.words).get()).length;
    final wordbookCountAfter = (await db.select(db.wordbooks).get()).length;
    expect(wordCountAfter, wordCountBefore);
    expect(wordbookCountAfter, wordbookCountBefore);
  });

  test('他の学習者の記録が消えない', () async {
    final taro = await createTestProfile(db, name: 'たろう');
    final jiro = await createTestProfile(db, name: 'じろう');
    await seedFullProgress(db, taro.id);
    await seedFullProgress(db, jiro.id);

    await service.reset(taro.id);

    final taroCounts = await service.inspect(taro.id);
    final jiroCounts = await service.inspect(jiro.id);
    expect(taroCounts.total, 0);
    expect(jiroCounts.total, greaterThan(0));
    expect(jiroCounts.wordReviews, 1);
    expect(jiroCounts.partReviews, 1);
    expect(jiroCounts.learningLogs, 1);
    expect(jiroCounts.studySessions, 1);
    expect(jiroCounts.dailyStats, 1);
    expect(jiroCounts.achievements, 1);
    expect(jiroCounts.vocabSizeTests, 1);
    expect(jiroCounts.resolvedConfusions, 1);
  });
}
