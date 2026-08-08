import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:encello/application/reminder_scheduler.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:encello/data/repositories/stats_repository.dart';
import 'package:encello/data/repositories/study_repository.dart';
import 'package:encello/data/repositories/wordbook_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_reminder_service.dart';
import '../helpers/study_fixture.dart';
import '../helpers/test_database.dart';

/// [Docs/06_features/reminders.md] §3.1・§8 のテスト観点。
void main() {
  late AppDatabase db;
  late FakeReminderService service;
  late ReminderScheduler scheduler;
  late Profile me;

  // 予約時点（19:00 の通知はこの日ぶんがまだ先）。
  final now = DateTime(2026, 8, 4, 12);

  setUp(() async {
    db = newTestDatabase();
    service = FakeReminderService();
    scheduler = ReminderScheduler(
      service,
      StudyRepository(db),
      StatsRepository(db),
    );
    me = await createTestProfile(db, name: 'たろう');
  });

  /// リマインダーを ON にした学習者を返す。
  Future<Profile> enableReminder({int hour = 19, int minute = 0}) async {
    await (db.update(db.profiles)..where((t) => t.id.equals(me.id))).write(
      ProfilesCompanion(
        reminderEnabled: const Value(true),
        reminderHour: Value(hour),
        reminderMinute: Value(minute),
      ),
    );
    return (db.select(
      db.profiles,
    )..where((t) => t.id.equals(me.id))).getSingle();
  }

  /// 期限が来ている復習を [count] 語ぶん仕込む。
  Future<Profile> seedDueWords(Profile profile, int count) async {
    final seeded = await seedStudyTarget(
      db,
      profile,
      headwords: {for (var i = 0; i < count; i++) 'word$i': 'いみ$i'},
    );
    final words = await db.select(db.words).get();
    for (final word in words) {
      await db
          .into(db.wordReviews)
          .insert(
            WordReviewsCompanion.insert(
              profileId: profile.id,
              wordId: word.id,
              dueAt: now.subtract(const Duration(days: 1)),
              masteryLevel: const Value(1),
            ),
          );
    }
    return seeded.profile;
  }

  test('リマインダーが OFF なら取り消すだけ（予約しない）', () async {
    await scheduler.reschedule(me, now: now);

    expect(service.cancelled, [me.id]);
    expect(service.rescheduled, isEmpty);
  });

  test('通知が許可されていなければ ON でも予約しない', () async {
    final profile = await enableReminder();
    service = FakeReminderService(permitted: false);
    scheduler = ReminderScheduler(
      service,
      StudyRepository(db),
      StatsRepository(db),
    );

    await scheduler.reschedule(profile, now: now);

    // ON に見せかけて鳴らない状態を作らない。
    expect(service.cancelled, [profile.id]);
    expect(service.rescheduled, isEmpty);
  });

  test('ON なら7日分を予約し、本文に名前と件数が入る', () async {
    var profile = await enableReminder();
    profile = await seedDueWords(profile, 3);

    await scheduler.reschedule(profile, now: now);

    final plan = service.rescheduled[profile.id]!;
    expect(plan.notices.length, 7);
    expect(plan.notices.first.at, DateTime(2026, 8, 4, 19));
    expect(plan.notices.first.body, contains('たろう'));
    expect(plan.notices.first.body, contains('3語'));
  });

  test('今日すでに目標を達成していれば今日ぶんを予約しない', () async {
    var profile = await enableReminder();
    profile = await seedDueWords(profile, 2);
    await db
        .into(db.dailyStats)
        .insert(
          DailyStatsCompanion.insert(
            profileId: profile.id,
            studyDate: '2026-08-04',
            goalCount: 20,
            answeredCount: const Value(20),
            goalMet: const Value(true),
          ),
        );

    await scheduler.reschedule(profile, now: now);

    final plan = service.rescheduled[profile.id]!;
    expect(plan.notices.length, 6);
    expect(plan.notices.first.at, DateTime(2026, 8, 5, 19));
  });

  test('解いて期限が延びると、次の予約の件数が減る', () async {
    var profile = await enableReminder();
    profile = await seedDueWords(profile, 3);
    await scheduler.reschedule(profile, now: now);
    expect(service.rescheduled[profile.id]!.notices.first.body, contains('3語'));

    // 1語を解いて期限を先へ送る（セッション後の予約し直しに相当）。
    final first = (await db.select(db.words).get()).first;
    await (db.update(db.wordReviews)..where(
          (t) => t.wordId.equals(first.id) & t.profileId.equals(profile.id),
        ))
        .write(
          WordReviewsCompanion(dueAt: Value(now.add(const Duration(days: 30)))),
        );

    await scheduler.reschedule(profile, now: now);
    expect(service.rescheduled[profile.id]!.notices.first.body, contains('2語'));
  });

  test('テスト通知にはその時点の件数が入る', () async {
    var profile = await enableReminder();
    profile = await seedDueWords(profile, 4);

    await scheduler.sendTest(profile, now: now);

    expect(service.sentTests.single.profileId, profile.id);
    expect(service.sentTests.single.body, contains('4語'));
  });

  test('学習者の削除ではその人の通知を取り消す', () async {
    await scheduler.cancel(me.id);
    expect(service.cancelled, [me.id]);
  });

  test('単語帳を選んでいない学習者は件数 0 で予約する', () async {
    final profile = await enableReminder();

    await scheduler.reschedule(profile, now: now);

    final plan = service.rescheduled[profile.id]!;
    expect(plan.notices.first.body, contains('新しい単語'));
  });

  test('WordbookRepository の選択が空でも例外にならない', () async {
    final profile = await enableReminder();
    expect(decodeIdList(profile.selectedWordbookIds), isEmpty);
    await scheduler.reschedule(profile, now: now);
    expect(service.rescheduled, isNotEmpty);
  });
}
