import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:encello/data/database/app_database.dart';
import 'package:encello/providers/providers.dart';
import 'package:encello/ui/screens/profile_gate_screen.dart';
import 'package:encello/ui/widgets/reminder_settings_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_reminder_service.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_database.dart';

/// 学習リマインダーの UI（[Docs/06_features/reminders.md] §4〜§6・§8）。
void main() {
  late AppDatabase db;
  late Profile me;

  DateTime now() => DateTime(2026, 8, 4, 12);

  setUp(() async {
    db = newTestDatabase();
    me = await createTestProfile(db, name: 'たろう');
  });

  Future<Profile> reload(int id) =>
      (db.select(db.profiles)..where((t) => t.id.equals(id))).getSingle();

  group('設定のトグル', () {
    testWidgets('権限が拒否されたらトグルは ON にならず、理由を1行出す', (tester) async {
      final reminder = FakeReminderService(
        permitted: false,
        grantOnRequest: false,
      );
      await pumpWithProviders(
        tester,
        db: db,
        child: ReminderSettingsCard(profile: me),
        activeProfile: me,
        reminder: reminder,
        clock: now,
        wrapInScaffold: true,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(find.textContaining('通知が許可されていません'), findsOneWidget);
      // ON に見せかけて鳴らない状態を作らない。
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
      expect((await reload(me.id)).reminderEnabled, isFalse);
      expect(reminder.rescheduled, isEmpty);
    });

    testWidgets('許可されればトグルが ON になり、予約が作られる', (tester) async {
      final reminder = FakeReminderService(permitted: false);
      await pumpWithProviders(
        tester,
        db: db,
        child: ReminderSettingsCard(profile: me),
        activeProfile: me,
        reminder: reminder,
        clock: now,
        wrapInScaffold: true,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect((await reload(me.id)).reminderEnabled, isTrue);
      expect(reminder.rescheduled[me.id]!.notices, isNotEmpty);
      // ON のときだけ時刻とテスト通知を出す。
      expect(find.text('19:00'), findsOneWidget);
      expect(find.text('テスト通知を送る'), findsOneWidget);
    });

    testWidgets('OFF に戻すと予約が取り消される', (tester) async {
      await (db.update(db.profiles)..where((t) => t.id.equals(me.id))).write(
        const ProfilesCompanion(reminderEnabled: Value(true)),
      );
      final profile = await reload(me.id);
      final reminder = FakeReminderService();

      await pumpWithProviders(
        tester,
        db: db,
        child: ReminderSettingsCard(profile: profile),
        activeProfile: profile,
        reminder: reminder,
        clock: now,
        wrapInScaffold: true,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect((await reload(me.id)).reminderEnabled, isFalse);
      expect(reminder.cancelled, contains(me.id));
    });
  });

  group('通知のタップ', () {
    testWidgets('payload の学習者に切り替えてからホームを開く', (tester) async {
      final other = await createTestProfile(db, name: 'はなこ', colorSeed: 1);

      final container = await pumpWithProviders(
        tester,
        db: db,
        child: const ProfileGateScreen(),
        launchProfileId: other.id,
        clock: now,
      );
      // 切り替え後はゲートが読み込み中の表示（回り続けるインジケータ）になるため、
      // pumpAndSettle ではなくフレームを明示的に進める
      // （[Docs/07_testing_strategy.md] §4）。
      await tester.pump();
      await tester.pump();

      // 別の人のプロファイルが開いたままだと記録が混ざる。
      expect(container.read(activeProfileProvider)?.id, other.id);
    });

    testWidgets('payload の学習者が削除済みなら切り替えずに選ばせる', (tester) async {
      await createTestProfile(db, name: 'はなこ', colorSeed: 1);

      final container = await pumpWithProviders(
        tester,
        db: db,
        // 存在しない id（削除済みの人からの通知）。
        launchProfileId: 999,
        child: const ProfileGateScreen(),
        clock: now,
      );
      await tester.pumpAndSettle();

      expect(container.read(activeProfileProvider), isNull);
      expect(find.text('だれが学習しますか？'), findsOneWidget);
    });
  });
}
