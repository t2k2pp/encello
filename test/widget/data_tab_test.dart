import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:encello/core/utils/enums.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:encello/data/repositories/wordbook_repository.dart';
import 'package:encello/data/services/export_import_service.dart';
import 'package:encello/ui/widgets/data_exchange_cards.dart';
import 'package:encello/ui/widgets/reset_progress_card.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_file_exchange_service.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_database.dart';

/// 設定 > データの入出力（[Docs/06_features/export_import.md] §6）。
void main() {
  late AppDatabase db;
  late Profile me;

  DateTime now() => DateTime(2026, 8, 5, 21, 30);

  setUp(() async {
    db = newTestDatabase();
    me = await createTestProfile(db, name: 'たろう');
  });

  /// 取り込み用の最小のバックアップ（学習者1人と単語1語）。
  String backupJson({String profileName = 'はなこ'}) => encodeBackupJson({
    'formatVersion': 1,
    'appVersion': '1.0.0',
    'exportedAt': '2026-08-01T21:30:00.000',
    'profiles': [
      {'name': profileName, 'colorSeed': 1},
    ],
    'wordbooks': const [],
    'words': [
      {'headword': 'apple', 'partOfSpeech': 'noun', 'meaning': 'りんご'},
    ],
  });

  Future<FakeFileExchangeService> pumpBackupCard(
    WidgetTester tester, {
    FakeFileExchangeService? fake,
  }) async {
    final exchange = fake ?? FakeFileExchangeService();
    await pumpWithProviders(
      tester,
      db: db,
      child: const BackupCard(),
      activeProfile: me,
      clock: now,
      wrapInScaffold: true,
      fileExchange: exchange,
    );
    await tester.pumpAndSettle();
    return exchange;
  }

  group('書き出し', () {
    testWidgets('日付入りのファイル名で JSON を書き出す', (tester) async {
      final exchange = await pumpBackupCard(tester);

      await tester.tap(find.text('書き出す'));
      await tester.pumpAndSettle();

      expect(exchange.saved.single.name, 'encello_backup_20260805_2130.json');
      expect(exchange.saved.single.contents, contains('"formatVersion": 1'));
      // 音声パックは含めない（[Docs/06_features/export_import.md] §1）。
      expect(exchange.saved.single.contents, isNot(contains('audioPacks')));
    });
  });

  group('取り込み', () {
    testWidgets('プレビューを出し、「追加で取り込む」で取り込む', (tester) async {
      final exchange = await pumpBackupCard(
        tester,
        fake: FakeFileExchangeService(
          picked: FakeFileExchangeService.fileOf('backup.json', backupJson()),
        ),
      );
      expect(exchange.saved, isEmpty);

      await tester.tap(find.text('復元する'));
      await tester.pumpAndSettle();

      expect(find.text('バックアップの内容'), findsOneWidget);
      expect(find.textContaining('はなこ（新規）'), findsOneWidget);

      await tester.tap(find.text('追加で取り込む'));
      await tester.pumpAndSettle();

      final names = (await db.select(db.profiles).get()).map((p) => p.name);
      expect(names, containsAll(['たろう', 'はなこ']));
    });

    testWidgets('置き換えは二段確認で、途中でやめれば何も消えない', (tester) async {
      await pumpBackupCard(
        tester,
        fake: FakeFileExchangeService(
          picked: FakeFileExchangeService.fileOf('backup.json', backupJson()),
        ),
      );

      await tester.tap(find.text('復元する'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('置き換える'));
      await tester.pumpAndSettle();

      // 1段目。
      expect(find.text('すべて置き換えますか'), findsOneWidget);
      await tester.tap(find.text('次へ'));
      await tester.pumpAndSettle();

      // 2段目。ここでやめる。
      expect(find.text('本当に置き換えますか'), findsOneWidget);
      await tester.tap(find.text('キャンセル'));
      await tester.pumpAndSettle();

      final names = (await db.select(db.profiles).get()).map((p) => p.name);
      expect(names, ['たろう'], reason: '確認を取り下げたら何も取り込まない');
    });

    testWidgets('二段目まで確認すると置き換わる', (tester) async {
      await pumpBackupCard(
        tester,
        fake: FakeFileExchangeService(
          picked: FakeFileExchangeService.fileOf('backup.json', backupJson()),
        ),
      );

      await tester.tap(find.text('復元する'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('置き換える'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('次へ'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('本当に置き換える'));
      await tester.pumpAndSettle();

      final names = (await db.select(db.profiles).get()).map((p) => p.name);
      expect(names, ['はなこ'], reason: '既存は消えてから取り込まれる');
    });

    testWidgets('形式が新しいファイルは理由を出して1件も取り込まない', (tester) async {
      await pumpBackupCard(
        tester,
        fake: FakeFileExchangeService(
          picked: FakeFileExchangeService.fileOf(
            'backup.json',
            '{"formatVersion": 2, "profiles": [], "wordbooks": [], "words": []}',
          ),
        ),
      );

      await tester.tap(find.text('復元する'));
      await tester.pumpAndSettle();

      expect(find.text('取り込めませんでした'), findsOneWidget);
      expect(find.textContaining('新しいバージョン'), findsOneWidget);
      expect((await db.select(db.profiles).get()).length, 1);
    });
  });

  group('CSV', () {
    testWidgets('単語帳を選んで書き出せる', (tester) async {
      // プリセット単語帳と同じく、マイ単語帳より前の並び順にする
      // （カードの初期選択は先頭の単語帳になる）。
      final books = WordbookRepository(db);
      final bookId = await db
          .into(db.wordbooks)
          .insert(
            WordbooksCompanion.insert(
              name: 'テスト単語帳',
              emoji: '📗',
              colorSeed: 1,
              category: WordbookCategory.custom.value,
              source: WordbookSource.user.value,
              sortOrder: const Value(10),
            ),
          );
      final wordId = await db
          .into(db.words)
          .insert(
            WordsCompanion.insert(
              headword: 'apple',
              partOfSpeech: PartOfSpeech.noun.value,
              meaning: 'りんご',
            ),
          );
      await books.addWord(bookId, wordId);

      final exchange = FakeFileExchangeService();
      await pumpWithProviders(
        tester,
        db: db,
        child: CsvCard(profile: me),
        activeProfile: me,
        clock: now,
        wrapInScaffold: true,
        fileExchange: exchange,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('書き出す'));
      await tester.pumpAndSettle();

      expect(exchange.saved.single.name, endsWith('_20260805.csv'));
      expect(exchange.saved.single.contents, contains('apple,noun'));
      // 学習状態は CSV に含めない。
      expect(exchange.saved.single.contents, isNot(contains('masteryLevel')));
    });
  });

  group('学習状態のリセット', () {
    Future<void> seedProgress(Profile profile) async {
      final wordId = await db
          .into(db.words)
          .insert(
            WordsCompanion.insert(
              headword: 'apple',
              partOfSpeech: PartOfSpeech.noun.value,
              meaning: 'りんご',
            ),
          );
      await db
          .into(db.wordReviews)
          .insert(
            WordReviewsCompanion.insert(
              profileId: profile.id,
              wordId: wordId,
              dueAt: now(),
            ),
          );
    }

    testWidgets('二段確認で、途中でやめれば何も消えない', (tester) async {
      await seedProgress(me);
      await pumpWithProviders(
        tester,
        db: db,
        child: ResetProgressCard(profile: me),
        activeProfile: me,
        clock: now,
        wrapInScaffold: true,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('学習状態をリセットする'));
      await tester.pumpAndSettle();

      // 1段目。件数の列挙とタイトルに学習者名が入る。
      expect(find.text('${me.name}さんの学習状態をリセット'), findsOneWidget);
      expect(find.textContaining('単語の学習状態 1件'), findsOneWidget);
      await tester.tap(find.text('次へ'));
      await tester.pumpAndSettle();

      // 2段目。ここでやめる。
      expect(find.text('本当にリセットしますか'), findsOneWidget);
      await tester.tap(find.text('キャンセル'));
      await tester.pumpAndSettle();

      final reviews = await db.select(db.wordReviews).get();
      expect(reviews, hasLength(1), reason: '確認を取り下げたら何も消えない');
    });

    testWidgets('1段目のキャンセルでも何も消えない', (tester) async {
      await seedProgress(me);
      await pumpWithProviders(
        tester,
        db: db,
        child: ResetProgressCard(profile: me),
        activeProfile: me,
        clock: now,
        wrapInScaffold: true,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('学習状態をリセットする'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('キャンセル'));
      await tester.pumpAndSettle();

      final reviews = await db.select(db.wordReviews).get();
      expect(reviews, hasLength(1));
    });

    testWidgets('二段目まで確認するとリセットされる', (tester) async {
      await seedProgress(me);
      await pumpWithProviders(
        tester,
        db: db,
        child: ResetProgressCard(profile: me),
        activeProfile: me,
        clock: now,
        wrapInScaffold: true,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('学習状態をリセットする'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('次へ'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('本当にリセットする'));
      await tester.pumpAndSettle();

      final reviews = await db.select(db.wordReviews).get();
      expect(reviews, isEmpty);
      final words = await db.select(db.words).get();
      expect(words, hasLength(1), reason: '単語は残る');
    });
  });
}
