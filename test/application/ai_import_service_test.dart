import 'package:encello/application/ai_import_service.dart';
import 'package:encello/core/utils/enums.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:encello/domain/usecases/wordbook_json_codec.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

/// [Docs/06_features/ai_import.md] §3.4・§7 のテスト観点。
void main() {
  late AppDatabase db;
  late AiImportService service;

  setUp(() {
    db = newTestDatabase();
    service = AiImportService(db);
  });

  ParsedWord word({
    required String headword,
    PartOfSpeech partOfSpeech = PartOfSpeech.noun,
    String meaning = 'いみ',
    int level = 1,
  }) {
    return ParsedWord(
      headword: headword,
      partOfSpeech: partOfSpeech,
      phonetic: null,
      meaning: meaning,
      exampleEn: null,
      exampleJa: null,
      level: level,
    );
  }

  ParsedWordbook book({
    String name = 'テスト単語帳',
    String emoji = '📗',
    List<ParsedWord>? words,
  }) {
    return ParsedWordbook(
      name: name,
      emoji: emoji,
      note: null,
      words: words ?? [word(headword: 'apple'), word(headword: 'banana')],
    );
  }

  group('新しく単語帳を作る', () {
    test('単語帳・単語・所属がすべて作られる', () async {
      final result = await service.import(book());

      expect(result.totalCount, 2);
      expect(result.newWordCount, 2);

      final wb = await db.select(db.wordbooks).getSingle();
      expect(wb.id, result.wordbookId);
      expect(wb.name, 'テスト単語帳');
      expect(wb.source, WordbookSource.imported.value);
      expect(wb.category, WordbookCategory.custom.value);

      final words = await db.select(db.words).get();
      expect(words.map((w) => w.headword), containsAll(['apple', 'banana']));
      expect(words.every((w) => w.ownerProfileId == null), isTrue);
      expect(
        words.every((w) => w.presetId == null),
        isTrue,
        reason: 'AI 取り込み語は「元に戻す」の対象にしない',
      );

      final entries = await db.select(db.wordbookEntries).get();
      expect(entries, hasLength(2));
    });
  });

  group('既存の共有語との一致', () {
    test('既存語と一致したら words は増えず所属だけ増える', () async {
      final existingId = await createSharedWord(
        db,
        headword: 'apple',
        partOfSpeech: 'noun',
        meaning: '既存の訳',
      );

      final result = await service.import(book());

      expect(result.totalCount, 2);
      expect(result.newWordCount, 1, reason: 'apple は既存語なので新規は banana だけ');

      final words = await db.select(db.words).get();
      expect(words, hasLength(2), reason: 'apple の行が増えていない');

      final entries = await (db.select(
        db.wordbookEntries,
      )..where((t) => t.wordId.equals(existingId))).get();
      expect(entries, hasLength(1), reason: '既存語は所属だけが増える');
    });

    test('既存語の訳は上書きされない', () async {
      await createSharedWord(
        db,
        headword: 'apple',
        partOfSpeech: 'noun',
        meaning: '既存の訳',
      );

      await service.import(
        book(
          words: [word(headword: 'apple', meaning: '新しい訳のつもり')],
        ),
      );

      final saved = await (db.select(
        db.words,
      )..where((t) => t.headword.equals('apple'))).getSingle();
      expect(saved.meaning, '既存の訳');
    });

    test('品詞が違えば別の語として新規作成される', () async {
      await createSharedWord(
        db,
        headword: 'run',
        partOfSpeech: 'verb',
        meaning: '走る',
      );

      final result = await service.import(
        book(
          words: [word(headword: 'run', partOfSpeech: PartOfSpeech.noun)],
        ),
      );

      expect(result.newWordCount, 1);
      final words = await (db.select(
        db.words,
      )..where((t) => t.headword.equals('run'))).get();
      expect(words, hasLength(2));
    });
  });

  group('プレビュー', () {
    test('新しく増える語数と既存バッジを正しく数える', () async {
      await createSharedWord(
        db,
        headword: 'apple',
        partOfSpeech: 'noun',
        meaning: '既存の訳',
      );

      final preview = await service.preview(book());

      expect(preview.totalCount, 2);
      expect(preview.newCount, 1);
      expect(preview.existingCount, 1);

      final appleRow = preview.words.firstWhere((w) => w.headword == 'apple');
      expect(appleRow.isExisting, isTrue);
      expect(appleRow.meaning, '既存の訳', reason: '既存語の訳を出す（上書きしない）');

      final bananaRow = preview.words.firstWhere((w) => w.headword == 'banana');
      expect(bananaRow.isExisting, isFalse);

      // プレビューは DB を書き換えない。
      expect(await db.select(db.words).get(), hasLength(1));
      expect(await db.select(db.wordbooks).get(), isEmpty);
    });

    test('先頭20語だけを返す', () async {
      final words = List.generate(30, (i) => word(headword: 'word$i'));
      final preview = await service.preview(book(words: words));
      expect(preview.totalCount, 30);
      expect(preview.words, hasLength(20));
    });
  });

  group('既存の単語帳に足す（分割取り込み）', () {
    test('同じ単語帳に2回に分けて取り込める', () async {
      final first = await service.import(
        book(
          words: [
            word(headword: 'apple'),
            word(headword: 'banana'),
          ],
        ),
      );

      final second = await service.import(
        book(
          words: [
            word(headword: 'cherry'),
            word(headword: 'banana'),
          ],
        ),
        targetWordbookId: first.wordbookId,
      );

      expect(second.newWordCount, 1, reason: 'banana は1回目ですでに作られている');

      final wordbooks = await db.select(db.wordbooks).get();
      expect(wordbooks, hasLength(1), reason: '単語帳は増えず、同じ1冊に足される');

      final entries = await (db.select(
        db.wordbookEntries,
      )..where((t) => t.wordbookId.equals(first.wordbookId))).get();
      expect(
        entries.map((e) => e.wordId).toSet(),
        hasLength(3),
        reason: 'apple・banana・cherry の3語が所属する（banana の重複所属は増えない）',
      );
    });
  });

  group('トランザクション', () {
    test('途中で失敗したら1件も残らない', () async {
      // 存在しない単語帳 id を指定し、所属の書き込みで外部キー違反を起こして
      // 途中失敗を再現する。
      const invalidWordbookId = 9999;

      await expectLater(
        service.import(
          book(
            words: [
              word(headword: 'apple'),
              word(headword: 'banana'),
            ],
          ),
          targetWordbookId: invalidWordbookId,
        ),
        throwsA(anything),
      );

      expect(
        await db.select(db.words).get(),
        isEmpty,
        reason: 'ロールバックにより単語も残らない',
      );
      expect(await db.select(db.wordbookEntries).get(), isEmpty);
      expect(await db.select(db.wordbooks).get(), isEmpty);
    });
  });
}
