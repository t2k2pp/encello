import 'package:encello/domain/entities/review_state.dart';
import 'package:encello/domain/usecases/study_queue_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 8, 4, 10);

  StudyCandidate fresh(int id, {int sortOrder = 0}) =>
      StudyCandidate(wordId: id, review: null, sortOrder: sortOrder);

  StudyCandidate ownedFresh(int id, {required DateTime createdAt}) =>
      StudyCandidate(
        wordId: id,
        review: null,
        sortOrder: 0,
        isOwned: true,
        createdAt: createdAt,
      );

  StudyCandidate reviewed(
    int id, {
    required DateTime dueAt,
    int sortOrder = 0,
    int totalCorrect = 0,
    int totalIncorrect = 0,
  }) {
    return StudyCandidate(
      wordId: id,
      sortOrder: sortOrder,
      review: ReviewState.initial.copyWith(
        dueAt: dueAt,
        repetition: 1,
        intervalDays: 1,
        totalCorrect: totalCorrect,
        totalIncorrect: totalIncorrect,
      ),
    );
  }

  List<QueuedItem> build(
    List<StudyCandidate> candidates, {
    QueuePolicy policy = QueuePolicy.reviewFirst,
    int limit = 20,
    int seed = 1,
  }) {
    return StudyQueueBuilder.build(
      candidates: candidates,
      policy: policy,
      limit: limit,
      now: now,
      shuffleSeed: seed,
    );
  }

  group('復習優先', () {
    test('期限到来の復習を先に取る', () {
      final queue = build([
        fresh(1),
        reviewed(2, dueAt: DateTime(2026, 8, 3)),
        reviewed(3, dueAt: DateTime(2026, 8, 10)),
      ], limit: 1);
      expect(queue.single.wordId, 2);
      expect(queue.single.source, QueueSource.due);
    });

    test('復習が足りなければ未学習語で埋める', () {
      final queue = build([
        reviewed(1, dueAt: DateTime(2026, 8, 3)),
        fresh(2, sortOrder: 1),
        fresh(3, sortOrder: 0),
      ], limit: 3);
      expect(queue.map((e) => e.wordId).toSet(), {1, 2, 3});
      expect(queue.firstWhere((e) => e.wordId == 1).source, QueueSource.due);
      expect(
        queue.firstWhere((e) => e.wordId == 2).source,
        QueueSource.newWord,
      );
    });

    test('未学習語は掲載順に取る', () {
      final queue = build([
        fresh(1, sortOrder: 5),
        fresh(2, sortOrder: 1),
        fresh(3, sortOrder: 3),
      ], limit: 2);
      expect(queue.map((e) => e.wordId).toSet(), {2, 3});
    });

    test('復習も新規も尽きたら期限前の語を前借りする', () {
      final queue = build([
        reviewed(1, dueAt: DateTime(2026, 8, 3)),
        reviewed(2, dueAt: DateTime(2026, 8, 20)),
        reviewed(3, dueAt: DateTime(2026, 8, 10)),
      ], limit: 3);
      expect(queue.map((e) => e.wordId).toSet(), {1, 2, 3});
      expect(
        queue.firstWhere((e) => e.wordId == 3).source,
        QueueSource.borrowed,
      );
      expect(
        queue.firstWhere((e) => e.wordId == 2).source,
        QueueSource.borrowed,
      );
    });

    test('前借りは期限が近い順に取る', () {
      final queue = build([
        reviewed(1, dueAt: DateTime(2026, 8, 20)),
        reviewed(2, dueAt: DateTime(2026, 8, 10)),
      ], limit: 1);
      expect(queue.single.wordId, 2);
      expect(queue.single.source, QueueSource.borrowed);
    });

    test('候補が0件なら空を返す', () {
      expect(build(const []), isEmpty);
    });

    test('同じ単語が2つの単語帳にあってもキューに1度しか入らない', () {
      final queue = build([
        fresh(1, sortOrder: 0),
        fresh(1, sortOrder: 9),
        fresh(2, sortOrder: 1),
      ], limit: 10);
      expect(queue.map((e) => e.wordId).toList()..sort(), [1, 2]);
    });

    test('期限ちょうどの語は期限到来として扱う', () {
      final queue = build([reviewed(1, dueAt: now)], limit: 1);
      expect(queue.single.source, QueueSource.due);
    });
  });

  group('新規のみ', () {
    test('未学習語だけを取る', () {
      final queue = build([
        reviewed(1, dueAt: DateTime(2026, 8, 3)),
        fresh(2),
      ], policy: QueuePolicy.newOnly);
      expect(queue.single.wordId, 2);
    });

    test('未学習語が無ければ空', () {
      final queue = build([
        reviewed(1, dueAt: DateTime(2026, 8, 3)),
      ], policy: QueuePolicy.newOnly);
      expect(queue, isEmpty);
    });
  });

  group('マイ単語の新規出題順（[Docs/06_features/my_words.md] §6）', () {
    // build() は最後に結果をシード付きシャッフルするため、最終順序では検証できない。
    // 代わりに limit を選択数より少なくし、「どの語が選ばれるか」（toSet）で
    // 内部の並べ替えを検証する（他の既存テストと同じ手法）。
    final pool = [
      // マイ単語は登録が新しい順（sortOrder は無視される）。
      ownedFresh(20, createdAt: DateTime(2026, 8, 1)),
      ownedFresh(21, createdAt: DateTime(2026, 8, 3)),
      ownedFresh(22, createdAt: DateTime(2026, 8, 2)),
      // 共有語は掲載順（sortOrder）のまま。
      fresh(10, sortOrder: 5),
      fresh(11, sortOrder: 1),
      fresh(12, sortOrder: 3),
    ];

    test('マイ単語の中では登録が新しい順に選ばれる', () {
      final queue = build(pool, policy: QueuePolicy.newOnly, limit: 1);
      expect(queue.map((e) => e.wordId).toSet(), {21});
    });

    test('マイ単語がすべて選ばれたあとは共有語が掲載順に選ばれる', () {
      final queue = build(pool, policy: QueuePolicy.newOnly, limit: 4);
      // マイ単語3語（20, 21, 22）＋ 掲載順が最小の共有語（11）。
      expect(queue.map((e) => e.wordId).toSet(), {20, 21, 22, 11});
    });

    test('復習優先の新規語補充でもマイ単語は登録が新しい順になる', () {
      final queue = build(
        [
          reviewed(1, dueAt: DateTime(2026, 8, 3)),
          ownedFresh(20, createdAt: DateTime(2026, 8, 1)),
          ownedFresh(21, createdAt: DateTime(2026, 8, 5)),
          fresh(10, sortOrder: 0),
        ],
        policy: QueuePolicy.reviewFirst,
        limit: 2,
      );
      // 期限到来の 1 に加え、新規語補充では最も新しいマイ単語 21 が選ばれる。
      expect(queue.map((e) => e.wordId).toSet(), {1, 21});
    });
  });

  group('苦手のみ', () {
    test('解答10回以上かつ正解率60%未満だけを、正解率の低い順に取る', () {
      final queue = build(
        [
          // 10回・正解5回（50%）
          reviewed(
            1,
            dueAt: DateTime(2026, 8, 3),
            totalCorrect: 5,
            totalIncorrect: 5,
          ),
          // 10回・正解7回（70%）→ 対象外
          reviewed(
            2,
            dueAt: DateTime(2026, 8, 3),
            totalCorrect: 7,
            totalIncorrect: 3,
          ),
          // 9回・正解1回（11%）だが回数が足りない → 対象外
          reviewed(
            3,
            dueAt: DateTime(2026, 8, 3),
            totalCorrect: 1,
            totalIncorrect: 8,
          ),
          // 10回・正解2回（20%）
          reviewed(
            4,
            dueAt: DateTime(2026, 8, 3),
            totalCorrect: 2,
            totalIncorrect: 8,
          ),
          fresh(5),
        ],
        policy: QueuePolicy.weakOnly,
        limit: 1,
      );
      // 正解率が最も低い 4 が先に取られる。
      expect(queue.single.wordId, 4);
    });
  });

  group('決定性', () {
    final pool = [for (var i = 1; i <= 20; i++) fresh(i, sortOrder: i)];

    test('同じシードなら同じ順序', () {
      expect(
        build(pool, seed: 42).map((e) => e.wordId),
        build(pool, seed: 42).map((e) => e.wordId),
      );
    });

    test('違うシードなら違う順序', () {
      expect(
        build(pool, seed: 1).map((e) => e.wordId).toList(),
        isNot(build(pool, seed: 2).map((e) => e.wordId).toList()),
      );
    });

    test('シャッフルしても件数と中身は変わらない', () {
      final queue = build(pool, seed: 7, limit: 20);
      expect(queue, hasLength(20));
      expect(queue.map((e) => e.wordId).toList()..sort(), [
        for (var i = 1; i <= 20; i++) i,
      ]);
    });
  });

  test('問題数が0以下なら空', () {
    expect(build([fresh(1)], limit: 0), isEmpty);
  });
}
