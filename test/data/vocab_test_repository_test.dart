import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:encello/data/database/app_database.dart';
import 'package:encello/data/repositories/vocab_test_repository.dart';
import 'package:encello/domain/usecases/vocab_size_estimator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

/// [Docs/06_features/vocab_size_test.md] §3・§7 のデータ側。
void main() {
  late AppDatabase db;
  late VocabTestRepository repo;
  late Profile me;
  late Profile other;

  setUp(() async {
    db = newTestDatabase();
    repo = VocabTestRepository(db);
    me = await createTestProfile(db, name: 'わたし', colorSeed: 0);
    other = await createTestProfile(db, name: 'ほかのひと', colorSeed: 1);
  });

  /// 帯に使う単語帳を1冊作り、id を返す。
  Future<int> createBand({
    required String name,
    required int sortOrder,
    int? bandSize = 1000,
  }) {
    return db
        .into(db.wordbooks)
        .insert(
          WordbooksCompanion.insert(
            name: name,
            emoji: '📗',
            colorSeed: 1,
            category: 'juniorHigh',
            source: 'preset',
            presetId: Value('$name-preset'),
            bandSize: Value(bandSize),
            sortOrder: Value(sortOrder),
          ),
        );
  }

  Future<int> addWord(
    int wordbookId, {
    required String headword,
    bool excluded = false,
    bool draft = false,
    int? ownerProfileId,
  }) async {
    final wordId = await db
        .into(db.words)
        .insert(
          WordsCompanion.insert(
            headword: headword,
            partOfSpeech: 'noun',
            meaning: draft ? '' : 'いみ',
            isExcluded: Value(excluded),
            isDraft: Value(draft),
            ownerProfileId: Value(ownerProfileId),
          ),
        );
    await db
        .into(db.wordbookEntries)
        .insert(
          WordbookEntriesCompanion.insert(
            wordbookId: wordbookId,
            wordId: wordId,
          ),
        );
    return wordId;
  }

  group('帯の読み出し', () {
    test('bandSize を持つ単語帳だけが、易しい順（sortOrder 昇順）で返る', () async {
      final hard = await createBand(name: '英検2級', sortOrder: 50);
      final easy = await createBand(name: '中学英単語', sortOrder: 10);
      final notBand = await createBand(
        name: 'ユーザー単語帳',
        sortOrder: 20,
        bandSize: null,
      );
      await addWord(hard, headword: 'reluctant');
      await addWord(easy, headword: 'apple');
      await addWord(notBand, headword: 'banana');

      final bands = await repo.loadBands();
      expect(bands.map((b) => b.name), ['中学英単語', '英検2級']);
      expect(bands.first.bandSize, 1000);
    });

    test('除外・下書き・他人のマイ単語は帯の語に入らない', () async {
      final band = await createBand(name: '中学英単語', sortOrder: 10);
      await addWord(band, headword: 'apple');
      await addWord(band, headword: 'excluded', excluded: true);
      await addWord(band, headword: 'draft', draft: true);
      await addWord(band, headword: 'mine', ownerProfileId: me.id);

      final bands = await repo.loadBands();
      expect(bands.single.words.map((w) => w.headword), ['apple']);
    });

    test('語が1語も無い単語帳は帯にしない', () async {
      await createBand(name: '空の単語帳', sortOrder: 10);
      expect(await repo.loadBands(), isEmpty);
    });
  });

  group('記録', () {
    VocabSizeEstimate estimateOf(int known) => VocabSizeEstimator.estimate(
      bands: [
        VocabBandAnswers(
          wordbookId: 1,
          name: '中学英単語',
          bandSize: 1000,
          asked: 10,
          known: known,
        ),
      ],
      pseudoAsked: 10,
      pseudoKnown: 0,
    );

    test('保存した測定が latest / history / askedWordIds で戻る', () async {
      await repo.save(
        profileId: me.id,
        takenAt: DateTime(2026, 8, 1, 10),
        estimate: estimateOf(5),
        askedWordIds: const [11, 22],
      );
      await repo.save(
        profileId: me.id,
        takenAt: DateTime(2026, 8, 4, 10),
        estimate: estimateOf(8),
        askedWordIds: const [33],
      );

      final latest = await repo.latest(me.id);
      expect(latest!.estimatedSize, 800);
      expect(latest.falseAlarmRate, 0);

      final history = await repo.history(me.id);
      expect(history.map((t) => t.estimatedSize), [800, 500]);

      // 直近1回ぶんだけを「出したことがある語」として扱う。
      expect(await repo.recentlyAskedWordIds(me.id), {33});
      expect(await repo.recentlyAskedWordIds(me.id, count: 2), {11, 22, 33});

      final bands = VocabTestRepository.decodeBands(latest.bandResults);
      expect(bands.single.name, '中学英単語');
      expect(bands.single.estimatedWords, 800);
    });

    test('測定しても word_reviews は1行も増減しない', () async {
      final before = await db.select(db.wordReviews).get();
      await repo.save(
        profileId: me.id,
        takenAt: DateTime(2026, 8, 4, 10),
        estimate: estimateOf(9),
        askedWordIds: const [1, 2, 3],
      );
      final after = await db.select(db.wordReviews).get();
      expect(after.length, before.length);
      expect(after, isEmpty);
    });

    test('学習者ごとに独立している', () async {
      await repo.save(
        profileId: me.id,
        takenAt: DateTime(2026, 8, 4, 10),
        estimate: estimateOf(9),
        askedWordIds: const [1],
      );

      expect(await repo.latest(other.id), isNull);
      expect(await repo.history(other.id), isEmpty);
      expect(await repo.recentlyAskedWordIds(other.id), isEmpty);
    });
  });
}
