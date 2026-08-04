import 'dart:math';

import 'package:encello/domain/usecases/vocab_test_builder.dart';
import 'package:flutter_test/flutter_test.dart';

/// [Docs/06_features/vocab_size_test.md] §3・§4 の出題の作り方。
void main() {
  VocabBandSource band({
    required int id,
    required String name,
    required int wordCount,
    int idBase = 0,
  }) => VocabBandSource(
    wordbookId: id,
    name: name,
    bandSize: 1000,
    words: [
      for (var i = 0; i < wordCount; i++)
        (wordId: idBase + i, headword: '${name}_$i'),
    ],
  );

  final pseudowords = [for (var i = 0; i < 120; i++) 'pseudo$i'];

  test('帯ごとに8問、擬似語が10問入る', () {
    final plan = VocabTestBuilder.build(
      bands: [
        band(id: 1, name: 'a', wordCount: 30, idBase: 100),
        band(id: 2, name: 'b', wordCount: 30, idBase: 200),
      ],
      pseudowords: pseudowords,
      random: Random(1),
    );

    expect(plan.questions.length, 8 * 2 + 10);
    expect(plan.pseudoCount, 10);
    for (final id in [1, 2]) {
      expect(
        plan.questions.where((q) => q.wordbookId == id).length,
        VocabTestBuilder.wordsPerBand,
      );
    }
    // 擬似語には wordId を持たせない（`words` テーブルに入れないため）。
    expect(
      plan.questions.where((q) => q.isPseudo).every((q) => q.wordId == null),
      isTrue,
    );
  });

  test('帯の語が足りなければ、ある分だけ出す（他の帯で埋めない）', () {
    final plan = VocabTestBuilder.build(
      bands: [
        band(id: 1, name: 'a', wordCount: 3, idBase: 100),
        band(id: 2, name: 'b', wordCount: 30, idBase: 200),
      ],
      pseudowords: pseudowords,
      random: Random(2),
    );

    expect(plan.questions.where((q) => q.wordbookId == 1).length, 3);
    expect(plan.questions.where((q) => q.wordbookId == 2).length, 8);
  });

  test('直近の測定で出した語は優先度が下がる', () {
    final recent = {for (var i = 0; i < 10; i++) 100 + i};
    final plan = VocabTestBuilder.build(
      bands: [band(id: 1, name: 'a', wordCount: 30, idBase: 100)],
      pseudowords: pseudowords,
      random: Random(3),
      recentlyAsked: recent,
    );

    final asked = plan.questions
        .where((q) => !q.isPseudo)
        .map((q) => q.wordId!)
        .toSet();
    // 未出題の語が20語あるので、既出の語は1つも選ばれない。
    expect(asked.intersection(recent), isEmpty);
  });

  test('未出題の語が足りなければ、既出の語で埋める', () {
    final recent = {for (var i = 0; i < 30; i++) 100 + i};
    final plan = VocabTestBuilder.build(
      bands: [band(id: 1, name: 'a', wordCount: 30, idBase: 100)],
      pseudowords: pseudowords,
      random: Random(4),
      // 未出題は2語しか無い状態にする。
      recentlyAsked: recent.difference({128, 129}),
    );

    expect(
      plan.questions.where((q) => !q.isPseudo).length,
      VocabTestBuilder.wordsPerBand,
    );
  });

  test('同じシードなら同じ出題になる（決定性）', () {
    List<String> headwordsOf(int seed) => VocabTestBuilder.build(
      bands: [band(id: 1, name: 'a', wordCount: 30, idBase: 100)],
      pseudowords: pseudowords,
      random: Random(seed),
    ).questions.map((q) => q.headword).toList();

    expect(headwordsOf(7), headwordsOf(7));
    expect(headwordsOf(7), isNot(headwordsOf(8)));
  });

  test('実在語と擬似語が混ざった順で出る（擬似語がまとまらない）', () {
    final plan = VocabTestBuilder.build(
      bands: [band(id: 1, name: 'a', wordCount: 30, idBase: 100)],
      pseudowords: pseudowords,
      random: Random(9),
    );
    final firstPseudo = plan.questions.indexWhere((q) => q.isPseudo);
    final lastReal = plan.questions.lastIndexWhere((q) => !q.isPseudo);
    expect(firstPseudo, lessThan(lastReal));
  });
}
