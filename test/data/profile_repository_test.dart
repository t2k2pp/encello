import 'package:drift/drift.dart';
import 'package:encello/core/utils/enums.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:encello/data/repositories/profile_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late ProfileRepository repo;

  setUp(() {
    db = newTestDatabase();
    repo = ProfileRepository(db);
  });

  group('作成', () {
    test('学習者を作るとマイ単語帳が1冊できる', () async {
      final profile = await repo.create(
        name: 'たろう',
        emoji: '🦊',
        colorSeed: 1,
        paletteId: 'blue',
      );

      final books = await db.select(db.wordbooks).get();
      expect(books, hasLength(1));
      expect(books.single.category, WordbookCategory.myWords.value);
      expect(books.single.ownerProfileId, profile.id);
    });

    test('既定値が設計どおり入る', () async {
      final p = await repo.create(
        name: 'はなこ',
        emoji: '🐰',
        colorSeed: 2,
        paletteId: 'pink',
      );
      expect(p.dailyGoal, 20);
      expect(p.sessionSize, 20);
      expect(p.keyboardLayout, KeyboardLayout.qwerty.value);
      expect(p.audioSource, AudioSourcePreference.fileFirst.value);
      expect(p.selectedWordbookIds, '[]');
      expect(p.reminderEnabled, isFalse);
    });
  });

  group('削除', () {
    test('最後の1人は削除できない', () async {
      final only = await repo.create(
        name: 'ひとり',
        emoji: '🙂',
        colorSeed: 0,
        paletteId: 'pink',
      );
      await expectLater(repo.delete(only.id), throwsStateError);
      expect(await repo.count(), 1);
    });

    test('2人いれば削除でき、その人の記録とマイ単語だけが消える', () async {
      final a = await repo.create(
        name: 'あに',
        emoji: '🐯',
        colorSeed: 0,
        paletteId: 'pink',
      );
      final b = await repo.create(
        name: 'おとうと',
        emoji: '🐤',
        colorSeed: 1,
        paletteId: 'blue',
      );

      final shared = await createSharedWord(db, headword: 'apple');
      await db
          .into(db.words)
          .insert(
            WordsCompanion.insert(
              headword: 'mine',
              partOfSpeech: 'noun',
              meaning: 'わたしの語',
              ownerProfileId: Value(a.id),
            ),
          );
      for (final profileId in [a.id, b.id]) {
        await db
            .into(db.wordReviews)
            .insert(
              WordReviewsCompanion.insert(
                profileId: profileId,
                wordId: shared,
                dueAt: DateTime(2026, 8, 4, 4),
              ),
            );
      }

      await repo.delete(a.id);

      // 共有の語は残る。あにのマイ単語だけが消える。
      final words = await db.select(db.words).get();
      expect(words.map((w) => w.headword), ['apple']);

      // 学習状態はおとうとの分だけ残る。
      final reviews = await db.select(db.wordReviews).get();
      expect(reviews.map((r) => r.profileId), [b.id]);

      // マイ単語帳も一緒に消える。
      final books = await db.select(db.wordbooks).get();
      expect(books.map((w) => w.ownerProfileId), [b.id]);
    });

    test('削除確認に出す件数を数えられる', () async {
      final a = await repo.create(
        name: 'あに',
        emoji: '🐯',
        colorSeed: 0,
        paletteId: 'pink',
      );
      await repo.create(
        name: 'おとうと',
        emoji: '🐤',
        colorSeed: 1,
        paletteId: 'blue',
      );

      final word = await createSharedWord(db, headword: 'apple');
      await db
          .into(db.wordReviews)
          .insert(
            WordReviewsCompanion.insert(
              profileId: a.id,
              wordId: word,
              dueAt: DateTime(2026, 8, 4, 4),
            ),
          );
      await db
          .into(db.words)
          .insert(
            WordsCompanion.insert(
              headword: 'mine',
              partOfSpeech: 'noun',
              meaning: 'わたしの語',
              ownerProfileId: Value(a.id),
            ),
          );

      final impact = await repo.deletionImpact(a.id);
      expect(impact.reviews, 1);
      expect(impact.logs, 0);
      expect(impact.myWords, 1);
      expect(impact.totalRecords, 1);
    });
  });

  group('学習者の分離（NFR-11）', () {
    test('同じ単語に2人分の学習状態が独立して存在できる', () async {
      final a = await repo.create(
        name: 'A',
        emoji: '🐯',
        colorSeed: 0,
        paletteId: 'pink',
      );
      final b = await repo.create(
        name: 'B',
        emoji: '🐤',
        colorSeed: 1,
        paletteId: 'blue',
      );
      final word = await createSharedWord(db, headword: 'apple');

      await db
          .into(db.wordReviews)
          .insert(
            WordReviewsCompanion.insert(
              profileId: a.id,
              wordId: word,
              dueAt: DateTime(2026, 8, 4, 4),
              masteryLevel: const Value(3),
            ),
          );
      await db
          .into(db.wordReviews)
          .insert(
            WordReviewsCompanion.insert(
              profileId: b.id,
              wordId: word,
              dueAt: DateTime(2026, 8, 10, 4),
              masteryLevel: const Value(1),
            ),
          );

      final rows = await db.select(db.wordReviews).get();
      expect(rows, hasLength(2));
      expect(
        rows.firstWhere((r) => r.profileId == a.id).masteryLevel,
        3,
      );
      expect(
        rows.firstWhere((r) => r.profileId == b.id).masteryLevel,
        1,
      );
    });

    test('設定の変更が他の学習者に影響しない', () async {
      final a = await repo.create(
        name: 'A',
        emoji: '🐯',
        colorSeed: 0,
        paletteId: 'pink',
      );
      final b = await repo.create(
        name: 'B',
        emoji: '🐤',
        colorSeed: 1,
        paletteId: 'blue',
      );

      await repo.updateSettings(
        a.id,
        const ProfilesCompanion(
          palette: Value('green'),
          dailyGoal: Value(50),
          textScale: Value('large'),
        ),
      );

      expect((await repo.findById(a.id))!.palette, 'green');
      expect((await repo.findById(a.id))!.dailyGoal, 50);
      expect((await repo.findById(b.id))!.palette, 'blue');
      expect((await repo.findById(b.id))!.dailyGoal, 20);
      expect((await repo.findById(b.id))!.textScale, 'medium');
    });
  });

  group('要約（一覧・ゲートに出す値）', () {
    test('学習中の語数・今日の進捗・ストリークを学習者ごとに返す', () async {
      final a = await repo.create(
        name: 'A',
        emoji: '🐯',
        colorSeed: 0,
        paletteId: 'pink',
      );
      final b = await repo.create(
        name: 'B',
        emoji: '🐤',
        colorSeed: 1,
        paletteId: 'blue',
      );
      final word = await createSharedWord(db, headword: 'apple');

      await db
          .into(db.wordReviews)
          .insert(
            WordReviewsCompanion.insert(
              profileId: a.id,
              wordId: word,
              dueAt: DateTime(2026, 8, 4, 4),
              masteryLevel: const Value(2),
            ),
          );
      await db
          .into(db.dailyStats)
          .insert(
            DailyStatsCompanion.insert(
              profileId: a.id,
              studyDate: '2026-08-03',
              goalCount: 20,
              answeredCount: const Value(20),
              goalMet: const Value(true),
            ),
          );
      await db
          .into(db.dailyStats)
          .insert(
            DailyStatsCompanion.insert(
              profileId: a.id,
              studyDate: '2026-08-04',
              goalCount: 20,
              answeredCount: const Value(5),
            ),
          );

      final overviews = await repo.overviews(
        await repo.getAll(),
        // 2026-08-04 の日中（学習日 2026-08-04）
        now: DateTime(2026, 8, 4, 10),
      );

      final oa = overviews.firstWhere((o) => o.profile.id == a.id);
      expect(oa.summary.learningWords, 1);
      expect(oa.summary.todayAnswered, 5);
      expect(oa.summary.todayGoal, 20);
      // 今日はまだ未達だが、昨日達成しているので 1 日。
      expect(oa.streak.current, 1);

      final ob = overviews.firstWhere((o) => o.profile.id == b.id);
      expect(ob.summary.learningWords, 0);
      expect(ob.summary.todayAnswered, 0);
      expect(ob.streak.current, 0);
    });
  });
}
