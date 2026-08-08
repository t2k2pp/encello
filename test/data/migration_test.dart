import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

/// v1 → v2 の移行（[Docs/03_data_model.md] §2.4・§9）。
///
/// `drift_schemas/` はまだ無いため、v1 相当の DB を手で組んで確かめる。
/// いまの schema で作った DB から `word_examples` を落とし、`words` に単数の
/// 例文2列を戻し、`user_version` を 1 にすれば v1 相当になる。
void main() {
  late Database raw;

  /// v1 相当の DB を1つ用意する。返した [Database] のまま `AppDatabase` を開けば
  /// `onUpgrade` が走る。
  Future<Database> openV1() async {
    final raw = sqlite3.openInMemory();
    final seed = AppDatabase(
      NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
    );
    // 1文投げて schema を作らせる（drift は初回のクエリで onCreate を走らせる）。
    await seed.select(seed.words).get();
    await seed.close();

    raw.execute('DROP TABLE word_examples');
    raw.execute('ALTER TABLE words ADD COLUMN example_en TEXT');
    raw.execute('ALTER TABLE words ADD COLUMN example_ja TEXT');
    raw.execute('PRAGMA user_version = 1');
    return raw;
  }

  void insertWordbook(String presetId, int sortOrder) {
    raw.execute(
      '''
      INSERT INTO wordbooks
        (name, emoji, color_seed, category, source, preset_id, sort_order)
      VALUES (?, '📘', 0, 'juniorHigh', 'preset', ?, ?)
      ''',
      [presetId, presetId, sortOrder],
    );
  }

  int insertV1Word({
    required String headword,
    String? presetId,
    String? exampleEn,
    String? exampleJa,
  }) {
    raw.execute(
      '''
      INSERT INTO words
        (headword, part_of_speech, meaning, preset_id, example_en, example_ja)
      VALUES (?, 'noun', 'いみ', ?, ?, ?)
      ''',
      [headword, presetId, exampleEn, exampleJa],
    );
    return raw.lastInsertRowId;
  }

  Future<List<WordExample>> migrateAndReadExamples() async {
    final db = AppDatabase(
      NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
    );
    addTearDown(db.close);
    return (db.select(
      db.wordExamples,
    )..orderBy([(t) => OrderingTerm(expression: t.wordId)])).get();
  }

  setUp(() async {
    raw = await openV1();
    addTearDown(raw.close);
  });

  test('プリセット由来の例文の sortOrder は単語帳の sortOrder になる', () async {
    insertWordbook('jhs_v1', 10);
    insertWordbook('toeic_basic_v1', 60);
    final appleId = insertV1Word(
      headword: 'apple',
      presetId: 'jhs_v1:apple:noun',
      exampleEn: 'I ate an apple.',
      exampleJa: 'りんごを食べました。',
    );
    final contractId = insertV1Word(
      headword: 'contract',
      presetId: 'toeic_basic_v1:contract:noun',
      exampleEn: 'Please check the contract.',
      exampleJa: '契約書を確認してください。',
    );

    final examples = await migrateAndReadExamples();

    expect(examples, hasLength(2));
    final apple = examples.firstWhere((e) => e.wordId == appleId);
    expect(apple.sourcePresetId, 'jhs_v1');
    expect(apple.sortOrder, 10);
    final contract = examples.firstWhere((e) => e.wordId == contractId);
    expect(contract.sourcePresetId, 'toeic_basic_v1');
    expect(contract.sortOrder, 60);
  });

  test('対応する単語帳が無いプリセット由来の例文は sortOrder 0 になる', () async {
    final id = insertV1Word(
      headword: 'zebra',
      presetId: 'unknown_v1:zebra:noun',
      exampleEn: 'The zebra is running.',
      exampleJa: 'そのシマウマは走っています。',
    );

    final examples = await migrateAndReadExamples();

    expect(examples.single.wordId, id);
    expect(examples.single.sourcePresetId, 'unknown_v1');
    expect(examples.single.sortOrder, 0);
  });

  test('ユーザーの文は sortOrder 0 で移り、和訳が無ければ null になる', () async {
    insertWordbook('jhs_v1', 10);
    final id = insertV1Word(
      headword: 'sunset',
      exampleEn: 'The sunset was beautiful.',
      // v1 は和訳を空文字で持てた。移行後は「無い」を null で表す（§2.4）。
      exampleJa: '',
    );

    final examples = await migrateAndReadExamples();

    expect(examples.single.wordId, id);
    expect(examples.single.sourcePresetId, isNull);
    expect(examples.single.exampleJa, isNull);
    expect(examples.single.sortOrder, 0);
  });

  test('和訳が欠けたプリセット由来の例文は行を作らない', () async {
    insertWordbook('jhs_v1', 10);
    insertV1Word(
      headword: 'apple',
      presetId: 'jhs_v1:apple:noun',
      exampleEn: 'I ate an apple.',
    );
    // 例文そのものが無い語も行を作らない。
    insertV1Word(headword: 'pear', presetId: 'jhs_v1:pear:noun');

    expect(await migrateAndReadExamples(), isEmpty);
  });
}
