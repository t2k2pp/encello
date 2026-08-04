import 'package:encello/data/database/app_database.dart';
import 'package:encello/ui/widgets/shared_text_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_shared_text_source.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_database.dart';

/// 他アプリからの共有テキストの受信（[Docs/06_features/my_words.md] §4.2、§8）。
void main() {
  late AppDatabase db;

  setUp(() {
    db = newTestDatabase();
  });

  Future<FakeSharedTextSource> pumpListener(
    WidgetTester tester, {
    Profile? activeProfile,
    Profile? listenerProfile,
  }) async {
    final source = FakeSharedTextSource();
    await pumpWithProviders(
      tester,
      db: db,
      child: SharedTextListener(
        profile: listenerProfile,
        child: const SizedBox.shrink(),
      ),
      activeProfile: activeProfile,
      wrapInScaffold: true,
      sharedTextSource: source,
    );
    await tester.pumpAndSettle();
    return source;
  }

  testWidgets('1語の共有で登録シートが開き、見出し語に入る', (tester) async {
    final me = await createTestProfile(db, name: 'たろう');
    final source = await pumpListener(
      tester,
      activeProfile: me,
      listenerProfile: me,
    );

    source.emit('apple');
    await tester.pumpAndSettle();

    expect(find.text('単語を追加'), findsOneWidget);
    expect(find.text('apple'), findsOneWidget);
  });

  testWidgets('文の共有で候補チップが出る', (tester) async {
    final me = await createTestProfile(db, name: 'たろう');
    final source = await pumpListener(
      tester,
      activeProfile: me,
      listenerProfile: me,
    );

    source.emit('I have an apple.');
    await tester.pumpAndSettle();

    expect(find.text('単語を追加'), findsOneWidget);
    expect(find.text('文中の語から選ぶ'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'apple'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'have'), findsOneWidget);
    // 見つけた文の欄にそのまま入る。
    expect(find.text('I have an apple.'), findsOneWidget);
    // 推測で見出し語を決めていない。
    expect(find.text('見出し語を入力'), findsOneWidget);
  });

  testWidgets('日本語混じりの共有は見出し語を決めず、文だけ入る', (tester) async {
    final me = await createTestProfile(db, name: 'たろう');
    final source = await pumpListener(
      tester,
      activeProfile: me,
      listenerProfile: me,
    );

    source.emit('これは apple です');
    await tester.pumpAndSettle();

    expect(find.text('単語を追加'), findsOneWidget);
    expect(find.text('見出し語を入力'), findsOneWidget);
    expect(find.text('これは apple です'), findsOneWidget);
    // 日本語混じりでは候補チップも出さない。
    expect(find.text('文中の語から選ぶ'), findsNothing);
  });

  testWidgets('学習者が2人以上なら選択が先頭に出る', (tester) async {
    final taro = await createTestProfile(db, name: 'たろう');
    final jiro = await createTestProfile(db, name: 'じろう');
    // まだ誰も選ばれていない状態（共有からの起動でゲートを通っていない）を再現する。
    final source = await pumpListener(tester, listenerProfile: null);

    source.emit('kiwi');
    await tester.pumpAndSettle();

    expect(find.text('だれのマイ単語にしますか'), findsOneWidget);
    expect(find.text(taro.name), findsOneWidget);
    expect(find.text(jiro.name), findsOneWidget);
    // 選ぶまでは通常の登録フォームを出さない。
    expect(find.text('単語を追加'), findsNothing);

    await tester.tap(find.text(taro.name));
    await tester.pumpAndSettle();

    expect(find.text('単語を追加'), findsOneWidget);
    expect(find.text('kiwi'), findsOneWidget);
  });

  testWidgets('学習者が1人だけなら選択を出さずそのまま開く', (tester) async {
    await createTestProfile(db, name: 'たろう');
    final source = await pumpListener(tester, listenerProfile: null);

    source.emit('mango');
    await tester.pumpAndSettle();

    expect(find.text('だれのマイ単語にしますか'), findsNothing);
    expect(find.text('単語を追加'), findsOneWidget);
    expect(find.text('mango'), findsOneWidget);
  });
}
