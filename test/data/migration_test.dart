import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

/// v1 → v2 → v3 の移行（[Docs/03_data_model.md] §2.4・§9）。
///
/// `drift_schemas/` はまだ無いため、古い版に相当する DB を手で組んで確かめる。
/// いまの schema で作った DB から、その版より後に入った列や表を落とし、
/// `user_version` を戻せば古い版に相当する。
void main() {
  late Database raw;

  /// いまの schema で空の DB を作る。返した [Database] のまま `AppDatabase` を
  /// 開けば `onUpgrade` が走る。
  Future<Database> openCurrent() async {
    final raw = sqlite3.openInMemory();
    final seed = AppDatabase(
      NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
    );
    // 1文投げて schema を作らせる（drift は初回のクエリで onCreate を走らせる）。
    await seed.select(seed.words).get();
    await seed.close();
    return raw;
  }

  /// v2 相当。フラッシュカードの確認テストの2列がまだ無い。
  Future<Database> openV2() async {
    final raw = await openCurrent();
    raw.execute('ALTER TABLE profiles DROP COLUMN flashcard_test_format');
    raw.execute('ALTER TABLE profiles DROP COLUMN flashcard_round_size');
    raw.execute('PRAGMA user_version = 2');
    return raw;
  }

  /// v1 相当。v2 の状態からさらに `word_examples` を落とし、`words` に単数の
  /// 例文2列を戻す。
  Future<Database> openV1() async {
    final raw = await openV2();
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

  // v2 → v3: フラッシュカードの確認テストの2列を足す
  // （[Docs/06_features/flashcard_mode.md] §3）。
  group('v2 → v3', () {
    late Database v2;

    setUp(() async {
      v2 = await openV2();
      addTearDown(v2.close);
    });

    test('確認テストの設定が既定（4択・10枚）で入る', () async {
      // 列が無かった頃の学習者を1件作っておく。
      v2.execute(
        "INSERT INTO profiles (name, emoji, color_seed) VALUES ('たろう', '🙂', 0)",
      );

      final db = AppDatabase(
        NativeDatabase.opened(v2, closeUnderlyingOnClose: false),
      );
      addTearDown(db.close);
      final profile = await db.select(db.profiles).getSingle();

      expect(profile.name, 'たろう');
      // 流し見だけでは覚えたか分からないので、既定は確認テストありにする。
      expect(profile.flashcardTestFormat, 'choice');
      expect(profile.flashcardRoundSize, 10);
    });
  });
}
