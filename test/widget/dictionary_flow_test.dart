import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:encello/core/utils/enums.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:encello/data/repositories/word_repository.dart';
import 'package:encello/data/repositories/wordbook_repository.dart';
import 'package:encello/ui/screens/dictionary_screen.dart';
import 'package:encello/ui/screens/word_detail_screen.dart';
import 'package:encello/ui/widgets/word_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_database.dart';

/// M2 の完了条件（[Docs/09_roadmap.md]）:
/// 辞書で検索・絞り込み・並べ替えができ、単語を編集できる。
void main() {
  late AppDatabase db;
  late Profile me;
  late int bookId;

  Future<int> addWord({
    required String headword,
    required String meaning,
    String partOfSpeech = 'noun',
  }) async {
    final id = await db
        .into(db.words)
        .insert(
          WordsCompanion.insert(
            headword: headword,
            partOfSpeech: partOfSpeech,
            meaning: meaning,
          ),
        );
    await WordbookRepository(db).addWord(bookId, id);
    return id;
  }

  setUp(() async {
    db = newTestDatabase();
    me = await createTestProfile(db, name: 'たろう');
    bookId = await WordbookRepository(db).create(
      name: '中学英単語',
      emoji: '🏫',
      colorSeed: 1,
    );
  });

  Future<void> pumpDictionary(WidgetTester tester) async {
    await pumpWithProviders(
      tester,
      db: db,
      child: DictionaryScreen(profile: me),
      activeProfile: me,
      wrapInScaffold: true,
      size: const Size(390, 900),
    );
    await tester.pumpAndSettle();
  }

  /// 一覧に出ている見出し語を上から順に取る。
  List<String> headwordsOnScreen(WidgetTester tester) => tester
      .widgetList<WordListTile>(find.byType(WordListTile))
      .map((t) => t.entry.word.headword)
      .toList();

  group('辞書', () {
    testWidgets('単語が1語も無ければ単語帳を選ぶ導線を出す', (tester) async {
      await pumpDictionary(tester);
      expect(find.text('まだ単語がありません'), findsOneWidget);
      expect(find.text('単語帳を選ぶ'), findsOneWidget);
    });

    testWidgets('件数キャプションに総数と学習中の数を出す', (tester) async {
      final apple = await addWord(headword: 'apple', meaning: 'りんご');
      await addWord(headword: 'banana', meaning: 'バナナ');
      await db
          .into(db.wordReviews)
          .insert(
            WordReviewsCompanion.insert(
              profileId: me.id,
              wordId: apple,
              dueAt: DateTime(2026, 8, 4, 4),
              masteryLevel: const Value(1),
            ),
          );

      await pumpDictionary(tester);
      expect(find.text('2語 ・ 学習中 1語'), findsOneWidget);
    });

    testWidgets('英語でも日本語でも検索できる', (tester) async {
      await addWord(headword: 'apple', meaning: 'りんご');
      await addWord(headword: 'banana', meaning: 'バナナ');
      await pumpDictionary(tester);
      expect(headwordsOnScreen(tester), ['apple', 'banana']);

      await tester.enterText(find.byType(TextField), 'りんご');
      // 検索は 250ms のデバウンス後にクエリへ渡る。
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(headwordsOnScreen(tester), ['apple']);

      await tester.enterText(find.byType(TextField), 'banana');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(headwordsOnScreen(tester), ['banana']);
    });

    testWidgets('絞り込みをリセットのアイコンは条件があるときだけ出る', (tester) async {
      await addWord(headword: 'apple', meaning: 'りんご');
      await pumpDictionary(tester);
      expect(find.byTooltip('絞り込みをリセット'), findsNothing);

      await tester.enterText(find.byType(TextField), 'apple');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.byTooltip('絞り込みをリセット'), findsOneWidget);

      await tester.tap(find.byTooltip('絞り込みをリセット'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('絞り込みをリセット'), findsNothing);
    });

    testWidgets('習熟度で絞り込める', (tester) async {
      final apple = await addWord(headword: 'apple', meaning: 'りんご');
      await addWord(headword: 'banana', meaning: 'バナナ');
      await db
          .into(db.wordReviews)
          .insert(
            WordReviewsCompanion.insert(
              profileId: me.id,
              wordId: apple,
              dueAt: DateTime(2026, 8, 4, 4),
              masteryLevel: const Value(1),
            ),
          );

      await pumpDictionary(tester);
      await tester.tap(find.text('習熟度: すべて').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('習熟度: 未学習').last);
      await tester.pumpAndSettle();

      expect(headwordsOnScreen(tester), ['banana']);
    });

    testWidgets('降順に並べ替えられる', (tester) async {
      await addWord(headword: 'apple', meaning: 'りんご');
      await addWord(headword: 'banana', meaning: 'バナナ');
      await addWord(headword: 'cherry', meaning: 'さくらんぼ');

      await pumpDictionary(tester);
      expect(headwordsOnScreen(tester), ['apple', 'banana', 'cherry']);

      await tester.tap(find.text('降順'));
      await tester.pumpAndSettle();
      expect(headwordsOnScreen(tester), ['cherry', 'banana', 'apple']);
    });

    testWidgets('リスト⇄グリッドを切り替えられる', (tester) async {
      await addWord(headword: 'apple', meaning: 'りんご');
      await pumpDictionary(tester);
      expect(find.byType(WordListTile), findsOneWidget);
      expect(find.byType(WordGridTile), findsNothing);

      await tester.tap(find.byTooltip('グリッド表示'));
      await tester.pumpAndSettle();
      expect(find.byType(WordGridTile), findsOneWidget);
      expect(find.byType(WordListTile), findsNothing);
      // 列数の選択はグリッドのときだけ出る。
      expect(find.byTooltip('列数'), findsOneWidget);
    });

    testWidgets('行タップで単語詳細へ進む', (tester) async {
      await addWord(headword: 'apple', meaning: 'りんご');
      await pumpDictionary(tester);

      await tester.tap(find.byType(WordListTile));
      await tester.pumpAndSettle();

      expect(find.byType(WordDetailScreen), findsOneWidget);
      expect(find.text('りんご'), findsWidgets);
    });
  });

  group('単語の編集', () {
    testWidgets('詳細から編集すると一覧にも反映される', (tester) async {
      final id = await addWord(headword: 'apple', meaning: 'りんご');
      await pumpWithProviders(
        tester,
        db: db,
        child: WordDetailScreen(wordId: id, profile: me),
        activeProfile: me,
        size: const Size(390, 900),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('編集'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'りんご'),
        'りんご（訂正）',
      );
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      expect(find.text('りんご（訂正）'), findsWidgets);
      expect((await WordRepository(db).findById(id))!.meaning, 'りんご（訂正）');
    });

    testWidgets('除外すると除外中バッジが付き、辞書には残る', (tester) async {
      final id = await addWord(headword: 'apple', meaning: 'りんご');
      await pumpWithProviders(
        tester,
        db: db,
        child: WordDetailScreen(wordId: id, profile: me),
        activeProfile: me,
        size: const Size(390, 900),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('出題から除外する'));
      await tester.pumpAndSettle();

      expect(find.text('除外中'), findsOneWidget);
      expect(find.text('除外を解除する'), findsOneWidget);
      expect((await WordRepository(db).findById(id))!.isExcluded, isTrue);
    });

    testWidgets('編集済みのプリセット語だけ「編集前に戻す」が出る', (tester) async {
      final id = await db
          .into(db.words)
          .insert(
            WordsCompanion.insert(
              headword: 'apple',
              partOfSpeech: PartOfSpeech.noun.value,
              meaning: 'わたしの訳',
              presetId: const Value('jhs_v1:apple:noun'),
              isEdited: const Value(true),
            ),
          );
      await pumpWithProviders(
        tester,
        db: db,
        child: WordDetailScreen(wordId: id, profile: me),
        activeProfile: me,
        size: const Size(390, 900),
      );
      await tester.pumpAndSettle();
      expect(find.text('編集前に戻す'), findsOneWidget);

      await WordRepository(db).setExcluded(id, excluded: false);
      await tester.pumpAndSettle();
      // 編集済みでない語では出さない。
      final plain = await addWord(headword: 'banana', meaning: 'バナナ');
      await pumpWithProviders(
        tester,
        db: db,
        child: WordDetailScreen(wordId: plain, profile: me),
        activeProfile: me,
        size: const Size(390, 900),
      );
      await tester.pumpAndSettle();
      expect(find.text('編集前に戻す'), findsNothing);
    });

    testWidgets('例文が無い語では例文カードを出さない', (tester) async {
      final id = await addWord(headword: 'apple', meaning: 'りんご');
      await pumpWithProviders(
        tester,
        db: db,
        child: WordDetailScreen(wordId: id, profile: me),
        activeProfile: me,
        size: const Size(390, 900),
      );
      await tester.pumpAndSettle();
      expect(find.text('例文'), findsNothing);
      // 未学習の語では 0 の羅列を並べない。
      expect(find.text('まだ学習していません。'), findsOneWidget);
    });
  });
}
