import 'package:meta/meta.dart';

import '../../core/utils/enums.dart';
import '../entities/mastery.dart';

/// 語族の1語（出題条件の判定に必要な最小限）。
@immutable
class FamilyMember {
  final int wordId;
  final int familyId;
  final String headword;
  final String meaning;
  final PartOfSpeech partOfSpeech;
  final Mastery mastery;

  /// 除外・下書きの語は出題にも答えにも使わない。
  final bool isStudiable;

  const FamilyMember({
    required this.wordId,
    required this.familyId,
    required this.headword,
    required this.meaning,
    required this.partOfSpeech,
    required this.mastery,
    this.isStudiable = true,
  });
}

/// 語形変化クイズの1問。
@immutable
class FamilyQuestion {
  /// 提示する語（既習）。
  final FamilyMember prompt;

  /// 答えさせる語。
  final FamilyMember answer;

  const FamilyQuestion({required this.prompt, required this.answer});

  /// 「名詞形にしなさい」の求める品詞。
  PartOfSpeech get targetPartOfSpeech => answer.partOfSpeech;

  @override
  bool operator ==(Object other) =>
      other is FamilyQuestion &&
      other.prompt.wordId == prompt.wordId &&
      other.answer.wordId == answer.wordId;

  @override
  int get hashCode => Object.hash(prompt.wordId, answer.wordId);
}

/// 語形変化クイズの出題を組み立てる（[Docs/06_features/word_families.md] §4.2）。純粋関数。
///
/// **答えが一意に定まらない語族は出題しない。** 求める品詞の語が2つある語族
/// （`decision` と `decisiveness`）はどちらも正解になってしまい、
/// 片方を不正解にするのは誤りだから。
abstract final class FamilyQuizBuilder {
  static List<FamilyQuestion> build(List<FamilyMember> members) {
    final byFamily = <int, List<FamilyMember>>{};
    for (final m in members) {
      if (!m.isStudiable) continue;
      byFamily.putIfAbsent(m.familyId, () => []).add(m);
    }

    final questions = <FamilyQuestion>[];
    for (final family in byFamily.values) {
      // 語族に2語以上ないと変形の問題が作れない。
      if (family.length < 2) continue;

      // 求める品詞の語が語族にちょうど1つのものだけを答えにできる。
      final byPos = <PartOfSpeech, List<FamilyMember>>{};
      for (final m in family) {
        byPos.putIfAbsent(m.partOfSpeech, () => []).add(m);
      }

      for (final entry in byPos.entries) {
        if (entry.value.length != 1) continue;
        final answer = entry.value.single;
        for (final prompt in family) {
          if (prompt.wordId == answer.wordId) continue;
          // 知らない語から変形は作れない。
          if (prompt.mastery == Mastery.unlearned) continue;
          // 提示語と答えが同じ品詞では「変形」にならない。
          if (prompt.partOfSpeech == answer.partOfSpeech) continue;
          questions.add(FamilyQuestion(prompt: prompt, answer: answer));
        }
      }
    }
    return questions;
  }
}
