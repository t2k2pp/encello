import 'dart:math';

import 'package:meta/meta.dart';

import '../../core/utils/enums.dart';
import '../entities/mastery.dart';

/// 語の部品1つ（出題に要る最小限）。
@immutable
class PartCandidate {
  final int partId;
  final String form;
  final WordPartType type;
  final String meaning;

  /// 紐付いた単語の数。**3語以上の部品だけ**を出題する
  /// （1語しか繋がっていない部品を覚えても応用が利かない）。
  final int linkedWordCount;

  /// この部品を含む単語の見出し語（正解後に3語まで示す）。
  final List<String> sampleWords;

  /// 現在の学習者の習熟度（推測問題の対象判定に使う）。
  final Mastery mastery;

  const PartCandidate({
    required this.partId,
    required this.form,
    required this.type,
    required this.meaning,
    required this.linkedWordCount,
    this.sampleWords = const [],
    this.mastery = Mastery.unlearned,
  });
}

/// 推測問題の候補（部品がすべて既習で、語そのものは未学習の語）。
@immutable
class GuessCandidate {
  final int wordId;
  final String headword;

  /// 正解の意味。
  final String meaning;

  /// 部品の分解ヒント（`de-（離れて）+ port（運ぶ）`）。
  final String breakdown;

  const GuessCandidate({
    required this.wordId,
    required this.headword,
    required this.meaning,
    required this.breakdown,
  });
}

/// 語のつくりモードの1問（画面が扱う形へ変換する前の中間表現）。
@immutable
class PartsQuestion {
  final String prompt;
  final String? hint;
  final List<String> options;
  final int answerIndex;
  final List<String> explanation;

  /// 学習状態を更新する部品。推測問題では null。
  final int? partId;

  /// 推測問題の対象語。正解しても `word_reviews` は作らない。
  final int? guessWordId;

  const PartsQuestion({
    required this.prompt,
    required this.options,
    required this.answerIndex,
    this.hint,
    this.explanation = const [],
    this.partId,
    this.guessWordId,
  });

  bool get isGuess => guessWordId != null;
}

/// 語のつくりモードの出題（[Docs/06_features/word_parts.md] §5・§6）。純粋関数。
abstract final class PartsQuestionBuilder {
  /// 出題対象になる、紐付いた単語数の下限。
  static const minLinkedWords = 3;

  static const optionCount = 4;

  /// 何問に1問、推測問題を混ぜるか。
  static const guessEvery = 3;

  static List<PartsQuestion> build({
    required List<PartCandidate> parts,
    required List<GuessCandidate> guesses,
    required int limit,
    required Random random,
  }) {
    final usable = [
      for (final p in parts)
        if (p.linkedWordCount >= minLinkedWords) p,
    ];
    if (usable.isEmpty) return const [];

    final ordered = [...usable]..shuffle(random);
    final remainingGuesses = [...guesses]..shuffle(random);

    final questions = <PartsQuestion>[];
    var partCursor = 0;
    for (var i = 0; i < limit; i++) {
      // 3問に1問は推測問題。候補が無ければ**無理に作らない**。
      final wantGuess = (i + 1) % guessEvery == 0;
      if (wantGuess && remainingGuesses.isNotEmpty) {
        final guess = remainingGuesses.removeLast();
        final question = _buildGuess(guess, guesses, random);
        if (question != null) {
          questions.add(question);
          continue;
        }
      }
      if (partCursor >= ordered.length) partCursor = 0;
      final part = ordered[partCursor++];
      final question = _buildPart(part, usable, random);
      if (question != null) questions.add(question);
    }
    return questions;
  }

  /// 部品→意味 / 意味→部品 をランダムに出す。
  /// 誤答は**同じ種別**から選ぶ（接頭辞の問題に語根を混ぜると種別だけで割れる）。
  static PartsQuestion? _buildPart(
    PartCandidate correct,
    List<PartCandidate> pool,
    Random random,
  ) {
    final sameType = [
      for (final p in pool)
        if (p.type == correct.type &&
            p.partId != correct.partId &&
            p.meaning != correct.meaning &&
            p.form != correct.form)
          p,
    ];
    if (sameType.length < optionCount - 1) return null;

    final distractors = ([...sameType]..shuffle(random)).take(optionCount - 1);
    final formToMeaning = random.nextBool();
    final options = [
      correct,
      ...distractors,
    ].map((p) => formToMeaning ? p.meaning : p.form).toList()..shuffle(random);
    final answer = formToMeaning ? correct.meaning : correct.form;

    return PartsQuestion(
      prompt: formToMeaning
          ? correct.form
          : '「${correct.meaning}」を表す${correct.type.label}は？',
      hint: formToMeaning ? correct.type.label : null,
      options: options,
      answerIndex: options.indexOf(answer),
      partId: correct.partId,
      explanation: [
        '${correct.form}（${correct.type.label}）: ${correct.meaning}',
        // 部品と実際の語を必ず結び付ける。
        if (correct.sampleWords.isNotEmpty)
          '例: ${correct.sampleWords.take(3).join(' / ')}',
      ],
    );
  }

  /// 部品の意味だけをヒントに、未学習語の意味を推測させる。
  static PartsQuestion? _buildGuess(
    GuessCandidate correct,
    List<GuessCandidate> pool,
    Random random,
  ) {
    final others = [
      for (final g in pool)
        if (g.wordId != correct.wordId && g.meaning != correct.meaning) g,
    ];
    if (others.length < optionCount - 1) return null;

    final options = [
      correct,
      ...([...others]..shuffle(random)).take(optionCount - 1),
    ].map((g) => g.meaning).toList()..shuffle(random);

    return PartsQuestion(
      prompt: '${correct.headword} の意味は？',
      hint: correct.breakdown,
      options: options,
      answerIndex: options.indexOf(correct.meaning),
      guessWordId: correct.wordId,
      explanation: ['${correct.headword}: ${correct.meaning}'],
    );
  }
}
