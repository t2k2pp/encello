import 'dart:math';

import 'package:meta/meta.dart';

import '../../core/utils/enums.dart';

/// 4択の候補1件（単語の表示に必要な最小限）。
@immutable
class ChoiceCandidate {
  final int wordId;
  final String headword;
  final String meaning;
  final PartOfSpeech partOfSpeech;

  /// 同じ単語帳から優先して選ぶための識別子。所属していなければ空。
  final Set<int> wordbookIds;

  const ChoiceCandidate({
    required this.wordId,
    required this.headword,
    required this.meaning,
    required this.partOfSpeech,
    this.wordbookIds = const {},
  });

  /// その出題方向で選択肢に出す文字列。
  String labelFor(StudyDirection direction) =>
      direction == StudyDirection.enToJa ? meaning : headword;
}

/// 4択の誤答選択肢を選ぶ（[Docs/06_features/quiz_mode.md] §2）。純粋関数。
abstract final class ChoiceDistractors {
  /// 1問に必要な選択肢の数。
  static const optionCount = 4;

  /// [correct] に対する誤答を3つ選ぶ。揃わなければ**空を返す**
  /// （ダミー文字列を作って埋めない。FR-29）。
  ///
  /// 優先順は ① 同じ単語帳・同じ品詞 ② 同じ単語帳 ③ 全候補。
  /// 品詞を揃えるのは、選択肢を見ただけで答えが割れないようにするため。
  static List<ChoiceCandidate> pick({
    required ChoiceCandidate correct,
    required List<ChoiceCandidate> pool,
    required StudyDirection direction,
    required Random random,
  }) {
    final label = correct.labelFor(direction);
    final usable = [
      for (final c in pool)
        if (c.wordId != correct.wordId &&
            // 訳文が正解と完全一致する語は除く（同義語で正解が2つになるのを防ぐ）。
            c.labelFor(direction) != label)
          c,
    ];
    // 同じ表示文字列の候補どうしも1つに畳む。
    final unique = <String, ChoiceCandidate>{};
    for (final c in usable) {
      unique.putIfAbsent(c.labelFor(direction), () => c);
    }
    final pruned = unique.values.toList();
    if (pruned.length < optionCount - 1) return const [];

    final sameBook = pruned
        .where(
          (c) => c.wordbookIds.intersection(correct.wordbookIds).isNotEmpty,
        )
        .toList();
    final tiers = <List<ChoiceCandidate>>[
      [
        for (final c in sameBook)
          if (c.partOfSpeech == correct.partOfSpeech) c,
      ],
      sameBook,
      pruned,
    ];

    final picked = <ChoiceCandidate>[];
    final taken = <int>{};

    // 日本語→英語では、正解と先頭文字が同じ語を1つ以上入れたい
    // （見た目だけで消せないようにする）。
    if (direction == StudyDirection.jaToEn && correct.headword.isNotEmpty) {
      final initial = correct.headword[0];
      final lookalike = [
        for (final tier in tiers)
          for (final c in tier)
            if (c.headword.startsWith(initial)) c,
      ];
      if (lookalike.isNotEmpty) {
        final chosen = lookalike[random.nextInt(lookalike.length)];
        picked.add(chosen);
        taken.add(chosen.wordId);
      }
    }

    for (final tier in tiers) {
      if (picked.length >= optionCount - 1) break;
      final shuffled = [...tier]..shuffle(random);
      for (final c in shuffled) {
        if (picked.length >= optionCount - 1) break;
        if (taken.add(c.wordId)) picked.add(c);
      }
    }

    return picked.length == optionCount - 1 ? picked : const [];
  }

  /// 正解と誤答を並べ、正解の位置を決める。
  ///
  /// [avoidIndex] には直前の問題で正解だった位置を渡す。位置の癖で当てられるのを防ぐため、
  /// 同じ位置に正解を置かない（§3）。
  static List<ChoiceCandidate> arrange({
    required ChoiceCandidate correct,
    required List<ChoiceCandidate> distractors,
    required Random random,
    int? avoidIndex,
  }) {
    final options = [...distractors]..shuffle(random);
    var index = random.nextInt(optionCount);
    if (avoidIndex != null && index == avoidIndex) {
      index = (index + 1 + random.nextInt(optionCount - 1)) % optionCount;
    }
    options.insert(index, correct);
    return options;
  }
}
