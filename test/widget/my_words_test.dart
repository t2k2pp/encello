import 'package:encello/core/utils/enums.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:encello/data/repositories/word_repository.dart';
import 'package:encello/data/repositories/wordbook_repository.dart';
import 'package:encello/ui/dialogs/quick_add_word_sheet.dart';
import 'package:encello/ui/screens/home_screen.dart';
import 'package:encello/ui/screens/my_words_screen.dart';
import 'package:encello/ui/widgets/word_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';
import '../helpers/study_fixture.dart';
import '../helpers/test_database.dart';

/// M7-A の完了条件（[Docs/06_features/my_words.md] §8）。
void main() {
  late AppDatabase db;
  late Profile me;

  setUp(() async {
    db = newTestDatabase();
    me = await createTestProfile(db, name: 'たろう');
  });

  /// クイック登録シートの見出し語をアプリ内キーボードで打つ
  /// （[Docs/06_features/spell_mode.md] §2 と同じ手法）。
  Future<void> typeHeadword(WidgetTester tester, String text) async {
    for (final ch in text.split('')) {
      await tester.tap(find.widgetWithText(GestureDetector, ch).first);
      await tester.pump();
    }
  }

  Future<void> pumpQuickAdd(WidgetTester tester, {Profile? profile}) async {
    final p = profile ?? me;
    await pumpWithProviders(
      tester,
      db: db,
      child: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => showQuickAddWordSheet(context, profile: p),
              child: const Text('open'),
            ),
          ),
        ),
      ),
      activeProfile: p,
      size: const Size(390, 900),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  group('クイック登録', () {
    testWidgets('見出し語だけで保存すると下書きになる', (tester) async {
      await pumpQuickAdd(tester);
      await typeHeadword(tester, 'puppy');
      await tester.tap(find.text('保存').last);
      await tester.pumpAndSettle();

      final words = await db.select(db.words).get();
      final word = words.firstWhere((w) => w.headword == 'puppy');
      expect(word.isDraft, isTrue);
      expect(word.ownerProfileId, me.id);
    });

    testWidgets('訳を入れると下書きにならない', (tester) async {
      await pumpQuickAdd(tester);
      await typeHeadword(tester, 'kitten');
      // 1つ目の TextField が訳（見出し語は EnglishKeyboard で入力するため無い）。
      await tester.enterText(find.byType(TextField).at(0), 'こねこ');
      await tester.tap(find.text('保存').last);
      await tester.pumpAndSettle();

      final words = await db.select(db.words).get();
      final word = words.firstWhere((w) => w.headword == 'kitten');
      expect(word.isDraft, isFalse);
      expect(word.meaning, 'こねこ');
    });

    testWidgets(
      'EditableText が見出し語用に出ていない（訳・例文の数と一致する）',
      (tester) async {
        await pumpQuickAdd(tester);
        // 訳・見つけた文の TextField の分だけ EditableText がある（見出し語用は無い）。
        expect(find.byType(EditableText), findsNWidgets(2));
        await typeHeadword(tester, 'apple');
        expect(find.byType(EditableText), findsNWidgets(2));
      },
    );

    testWidgets('既存の共有語と同じ見出し語＋品詞のとき、既存を示す分岐に入る', (tester) async {
      final bookId = await WordbookRepository(db).create(
        name: 'テスト単語帳',
        emoji: '📗',
        colorSeed: 1,
      );
      final wordId = await WordRepository(db).createShared(
        headword: 'shared',
        partOfSpeech: PartOfSpeech.noun,
        meaning: '共有の語',
      );
      await WordbookRepository(db).addWord(bookId, wordId);

      await pumpQuickAdd(tester);
      await typeHeadword(tester, 'shared');
      await tester.pumpAndSettle();

      expect(find.textContaining('テスト単語帳'), findsOneWidget);
      expect(find.text('マイ単語として登録する'), findsOneWidget);
      expect(find.text('既存の語を学習対象にする'), findsOneWidget);
      // 分岐に入っている間は通常の保存ボタンを出さない（推測でどちらかに倒さない）。
      expect(find.text('保存してもう1語'), findsNothing);
    });

    testWidgets('「保存してもう1語」でシートが閉じず、入力がクリアされる', (tester) async {
      await pumpQuickAdd(tester);
      await typeHeadword(tester, 'first');
      expect(find.text('first'), findsOneWidget);

      await tester.tap(find.text('保存してもう1語'));
      await tester.pumpAndSettle();

      // シートは開いたまま（背後の「open」ボタンは覆われて押せない状態が続く）。
      expect(find.text('保存してもう1語'), findsOneWidget);
      // 見出し語の表示はクリアされている。
      expect(find.text('見出し語を入力'), findsOneWidget);
      expect(find.text('first'), findsNothing);

      final words = await db.select(db.words).get();
      expect(words.where((w) => w.headword == 'first'), hasLength(1));
    });
  });

  group('SCR-17 マイ単語画面', () {
    testWidgets('自分のマイ単語だけを出す', (tester) async {
      final words = WordRepository(db);
      await words.createOwned(
        ownerProfileId: me.id,
        headword: 'mine',
        partOfSpeech: PartOfSpeech.noun,
        meaning: 'わたしの語',
      );
      final other = await createTestProfile(db, name: 'ほかのひと', colorSeed: 1);
      await words.createOwned(
        ownerProfileId: other.id,
        headword: 'theirs',
        partOfSpeech: PartOfSpeech.noun,
        meaning: 'ほかのひとの語',
      );
      await words.createShared(
        headword: 'shared',
        partOfSpeech: PartOfSpeech.noun,
        meaning: '共有の語',
      );

      await pumpWithProviders(
        tester,
        db: db,
        child: MyWordsScreen(profile: me),
        activeProfile: me,
        wrapInScaffold: true,
        size: const Size(390, 900),
      );
      await tester.pumpAndSettle();

      final headwords = tester
          .widgetList<WordListTile>(find.byType(WordListTile))
          .map((t) => t.entry.word.headword)
          .toList();
      expect(headwords, ['mine']);
    });
  });

  group('ホームの下書きカード', () {
    Future<void> pumpHome(WidgetTester tester, Profile profile) async {
      await pumpWithProviders(
        tester,
        db: db,
        child: HomeScreen(profile: profile),
        activeProfile: profile,
        wrapInScaffold: true,
        size: const Size(390, 900),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('下書きが2語では出ない', (tester) async {
      final seeded = await seedStudyTarget(db, me);
      final words = WordRepository(db);
      for (final h in ['one', 'two']) {
        await words.createOwned(
          ownerProfileId: me.id,
          headword: h,
          partOfSpeech: PartOfSpeech.noun,
        );
      }
      await pumpHome(tester, seeded.profile);
      expect(find.text('マイ単語の下書き'), findsNothing);
    });

    testWidgets('下書きが3語で出る', (tester) async {
      final seeded = await seedStudyTarget(db, me);
      final words = WordRepository(db);
      for (final h in ['one', 'two', 'three']) {
        await words.createOwned(
          ownerProfileId: me.id,
          headword: h,
          partOfSpeech: PartOfSpeech.noun,
        );
      }
      await pumpHome(tester, seeded.profile);
      expect(find.text('マイ単語の下書き'), findsOneWidget);
    });
  });
}
