import 'package:encello/domain/usecases/reminder_plan_builder.dart';
import 'package:flutter_test/flutter_test.dart';

/// [Docs/06_features/reminders.md] §8 のテスト観点。
void main() {
  // 予約時点。19:00 の通知はこの日ぶんがまだ先。
  final now = DateTime(2026, 8, 4, 12);

  group('予約の作り方', () {
    test('7日分・7件で、8日目が含まれない', () {
      final plan = ReminderPlanBuilder.build(
        profileName: 'たろう',
        hour: 19,
        minute: 0,
        now: now,
        goalMetToday: false,
        streakDays: 0,
        dueCountAt: (_) => 5,
      );

      expect(plan.notices.length, 7);
      expect(plan.notices.first.at, DateTime(2026, 8, 4, 19));
      expect(plan.notices.last.at, DateTime(2026, 8, 10, 19));
      expect(
        plan.notices.any((n) => n.at.isAfter(DateTime(2026, 8, 10, 19))),
        isFalse,
      );
    });

    test('今日の時刻を過ぎていれば、今日ぶんは作らない', () {
      final plan = ReminderPlanBuilder.build(
        profileName: 'たろう',
        hour: 7,
        minute: 0,
        now: now,
        goalMetToday: false,
        streakDays: 0,
        dueCountAt: (_) => 5,
      );

      expect(plan.notices.first.at, DateTime(2026, 8, 5, 7));
      expect(plan.notices.length, 6);
    });

    test('今日すでに目標を達成していれば、今日ぶんを作らない', () {
      final plan = ReminderPlanBuilder.build(
        profileName: 'たろう',
        hour: 19,
        minute: 0,
        now: now,
        goalMetToday: true,
        streakDays: 5,
        dueCountAt: (_) => 5,
      );

      expect(plan.notices.first.at, DateTime(2026, 8, 5, 19));
      expect(plan.notices.length, 6);
    });

    test('その通知時刻の見込み件数を使う', () {
      final plan = ReminderPlanBuilder.build(
        profileName: 'たろう',
        hour: 19,
        minute: 0,
        now: now,
        goalMetToday: false,
        streakDays: 0,
        // 日が進むほど期限が来る語が増える。
        dueCountAt: (at) => at.difference(now).inDays + 1,
      );

      expect(plan.notices.first.body, contains('1語'));
      expect(plan.notices[1].body, contains('2語'));
    });
  });

  group('本文', () {
    test('プロファイル名と復習件数が入る', () {
      final body = ReminderPlanBuilder.bodyOf(
        profileName: 'たろう',
        dueCount: 23,
        streakDays: 0,
      );
      expect(body, contains('たろう'));
      expect(body, contains('23語'));
    });

    test('ストリークが3日以上なら日数を添える', () {
      final body = ReminderPlanBuilder.bodyOf(
        profileName: 'たろう',
        dueCount: 23,
        streakDays: 7,
      );
      expect(body, contains('7日続いています'));
      expect(body, contains('23語'));
    });

    test('ストリークが2日なら日数を出さない', () {
      final body = ReminderPlanBuilder.bodyOf(
        profileName: 'たろう',
        dueCount: 23,
        streakDays: 2,
      );
      expect(body, isNot(contains('続いています')));
    });

    test('復習が無いときは新しい単語を誘う', () {
      final body = ReminderPlanBuilder.bodyOf(
        profileName: 'はなこ',
        dueCount: 0,
        streakDays: 0,
      );
      expect(body, contains('はなこ'));
      expect(body, contains('新しい単語'));
    });

    test('脅す文言を使わない', () {
      for (final streak in [0, 3]) {
        for (final due in [0, 23]) {
          final body = ReminderPlanBuilder.bodyOf(
            profileName: 'たろう',
            dueCount: due,
            streakDays: streak,
          );
          expect(body, isNot(contains('切れ')));
          expect(body, isNot(contains('失')));
        }
      }
    });

    test('ストリークの呼びかけは今日ぶんにだけ添える', () {
      final plan = ReminderPlanBuilder.build(
        profileName: 'たろう',
        hour: 19,
        minute: 0,
        now: now,
        goalMetToday: false,
        streakDays: 7,
        dueCountAt: (_) => 5,
      );

      expect(plan.notices.first.body, contains('7日続いています'));
      // 翌日以降は、その日の達成状況で変わるため断定しない。
      expect(plan.notices[1].body, isNot(contains('続いています')));
    });
  });
}
