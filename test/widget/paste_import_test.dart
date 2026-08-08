import 'dart:io';

import 'package:encello/data/database/app_database.dart';
import 'package:encello/data/seeds/prompt_assets.dart';
import 'package:encello/ui/screens/paste_import_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_asset_bundle.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_database.dart';

/// SCR-24 貼り付け取込（[Docs/06_features/ai_import.md] §1.1・§3・§5、
/// [Docs/04_screens_and_flows.md] §4.16）。
void main() {
  late AppDatabase db;
  late Profile me;
  late PromptAssets promptAssets;
  final clipboardWrites = <String>[];

  setUp(() async {
    db = newTestDatabase();
    me = await createTestProfile(db, name: 'たろう');
    promptAssets = PromptAssets(
      FakeAssetBundle({
        PromptAssets.fixWordbookPath: File(
          PromptAssets.fixWordbookPath,
        ).readAsStringSync(),
      }),
    );
    clipboardWrites.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            final args = call.arguments as Map<Object?, Object?>;
            clipboardWrites.add(args['text'] as String);
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await pumpWithProviders(
      tester,
      db: db,
      child: PasteImportScreen(profile: me),
      activeProfile: me,
      promptAssets: promptAssets,
      size: const Size(390, 900),
    );
    await tester.pumpAndSettle();
  }

  /// テキストを貼り付けて「確認する」を押す。ボタンの活性状態はテキストの
  /// 有無に連動するため、`enterText` の通知が反映されるよう間に `pump` を挟む。
  Future<void> enterAndConfirm(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField).first, text);
    await tester.pump();
    await tester.tap(find.text('確認する'));
    await tester.pumpAndSettle();
  }

  const brokenText = 'これは単語帳ではありません';

  testWidgets('確認に失敗しても貼り付けたテキストは消えない', (tester) async {
    await pumpScreen(tester);
    await enterAndConfirm(tester, brokenText);

    expect(find.text(brokenText), findsOneWidget);
    // 致命的な失敗のときに出る「直してもらう」導線まで出ていることも確認する
    // （エラー画面へ正しく遷移したことの裏付け）。
    expect(find.text('AI に直してもらう文をコピー'), findsOneWidget);
  });

  testWidgets('エラー一覧が全件出る（最初の1件で打ち切らない）', (tester) async {
    await pumpScreen(tester);
    const withTwoErrors =
        '{"encelloWordbook":"1","name":"テスト","words":['
        '{"headword":"Patient!","partOfSpeech":"noun","meaning":"患者"},'
        '{"headword":"run","partOfSpeech":"verb","meaning":""}'
        ']}';
    await enterAndConfirm(tester, withTwoErrors);

    expect(find.textContaining('英単語として扱えない文字'), findsOneWidget);
    expect(find.textContaining('日本語訳がありません'), findsOneWidget);
  });

  testWidgets('直してもらう文にエラー一覧と元テキストが両方入る', (tester) async {
    await pumpScreen(tester);
    await enterAndConfirm(tester, brokenText);

    await tester.tap(find.text('AI に直してもらう文をコピー'));
    await tester.pumpAndSettle();

    expect(clipboardWrites, hasLength(1));
    final copied = clipboardWrites.single;
    expect(copied.contains(brokenText), isTrue, reason: '元のテキストが入っていること');
    expect(copied.contains('読み取れませんでした'), isTrue, reason: 'エラーの理由が入っていること');
  });

  testWidgets('画面に「JSON」「インポート」「パース」の文字が出ていない', (tester) async {
    await pumpScreen(tester);
    for (final banned in ['JSON', 'インポート', 'パース']) {
      expect(
        find.textContaining(banned),
        findsNothing,
        reason: '初期状態に "$banned" が出ている',
      );
    }

    await enterAndConfirm(tester, brokenText);
    for (final banned in ['JSON', 'インポート', 'パース']) {
      expect(
        find.textContaining(banned),
        findsNothing,
        reason: 'エラー表示に "$banned" が出ている',
      );
    }
  });
}
