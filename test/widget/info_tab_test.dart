import 'package:encello/core/app_info.dart';
import 'package:encello/core/utils/app_version.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:encello/ui/screens/privacy_policy_screen.dart';
import 'package:encello/ui/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_database.dart';

/// 設定 > 情報（[Docs/10_oss_licenses.md] §6）。
///
/// ストア提出の必須項目（プライバシーポリシーの掲示・OSS ライセンス表示）が
/// アプリから実際に開けることを見る。
void main() {
  late AppDatabase db;
  late Profile me;

  setUp(() async {
    db = newTestDatabase();
    me = await createTestProfile(db, name: 'たろう');
  });

  /// 設定の「情報」タブを開く。
  Future<void> pumpInfoTab(WidgetTester tester) async {
    await pumpWithProviders(
      tester,
      db: db,
      child: SettingsScreen(profile: me),
      activeProfile: me,
      wrapInScaffold: true,
    );
    await tester.pumpAndSettle();
    final tab = find.widgetWithText(Tab, '情報');
    await tester.ensureVisible(tab);
    await tester.pumpAndSettle();
    await tester.tap(tab);
    await tester.pumpAndSettle();
  }

  testWidgets('アプリ名・バージョン・問い合わせ先が出る', (tester) async {
    await pumpInfoTab(tester);
    expect(find.text(AppInfo.name), findsOneWidget);
    expect(find.text('バージョン $kAppVersion'), findsOneWidget);
    expect(find.text('お問い合わせ: ${AppInfo.supportEmail}'), findsOneWidget);
  });

  testWidgets('プライバシーポリシーを開ける', (tester) async {
    await pumpInfoTab(tester);
    await tester.tap(find.text('プライバシーポリシー'));
    await tester.pumpAndSettle();

    expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
    // 端末内で完結するという要になる主張が本文に出ていること。
    expect(find.textContaining('本アプリはインターネット通信を行いません'), findsOneWidget);

    // 問い合わせ先は末尾にあるので、`ListView` を最後まで送ってから見る。
    await tester.scrollUntilVisible(
      find.textContaining(AppInfo.supportEmail),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.textContaining(AppInfo.supportEmail), findsOneWidget);
  });

  testWidgets('オープンソースライセンスを開ける', (tester) async {
    await pumpInfoTab(tester);
    await tester.tap(find.text('オープンソースライセンス'));
    await tester.pumpAndSettle();

    expect(find.byType(LicensePage), findsOneWidget);
  });
}
