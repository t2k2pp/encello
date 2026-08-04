import 'dart:math';

import 'package:meta/meta.dart';

/// 帯（級帯）に使える1冊と、その帯から出題できる語
/// （[Docs/06_features/vocab_size_test.md] §3）。
@immutable
class VocabBandSource {
  final int wordbookId;
  final String name;

  /// 帯の語数（目安）。`wordbooks.bandSize`。
  final int bandSize;

  /// 出題候補（`(wordId, headword)`）。単語帳の収録語から作る。
  final List<({int wordId, String headword})> words;

  const VocabBandSource({
    required this.wordbookId,
    required this.name,
    required this.bandSize,
    required this.words,
  });
}

/// 測定で出す1問。
@immutable
class VocabQuestion {
  /// 出題する語（実在語・擬似語のどちらも）。
  final String headword;

  /// 実在語の `words.id`。擬似語では null。
  final int? wordId;

  /// この語が属する帯の単語帳 id。擬似語では null。
  final int? wordbookId;

  const VocabQuestion({
    required this.headword,
    this.wordId,
    this.wordbookId,
  });

  /// 擬似語か（結果画面まで伏せる）。
  bool get isPseudo => wordId == null;
}

/// 測定1回分の出題。
@immutable
class VocabTestPlan {
  /// 出題順（実在語と擬似語が混ざっている）。
  final List<VocabQuestion> questions;

  /// 帯の定義（解答の集計と結果表示に使う。易しい順）。
  final List<VocabBandSource> bands;

  const VocabTestPlan({required this.questions, required this.bands});

  int get pseudoCount => questions.where((q) => q.isPseudo).length;
}

/// 測定の出題を組み立てる（[Docs/06_features/vocab_size_test.md] §2・§3）。純粋関数。
///
/// 帯ごとに [wordsPerBand] 問、擬似語を [pseudoCount] 問。
/// 帯に十分な語が無ければ、その帯はある分だけ出す（他の帯から埋め合わせない。
/// 帯ごとの到達率が別の帯の語で汚れるため）。
abstract final class VocabTestBuilder {
  /// 帯ごとの出題数。
  static const wordsPerBand = 8;

  /// 擬似語の出題数。
  static const pseudoCount = 10;

  /// 測定を成立させるのに要る実在語の下限。これを下回るときは測定を始めない。
  static const minRealWords = 8;

  static VocabTestPlan build({
    required List<VocabBandSource> bands,
    required List<String> pseudowords,
    required Random random,

    /// 直近の測定で出した語の id。**優先度を下げる**（同じ語ばかり出さない）。
    Set<int> recentlyAsked = const {},
    int wordsPerBand = VocabTestBuilder.wordsPerBand,
    int pseudoCount = VocabTestBuilder.pseudoCount,
  }) {
    final questions = <VocabQuestion>[];

    for (final band in bands) {
      for (final w in _pick(band.words, wordsPerBand, recentlyAsked, random)) {
        questions.add(
          VocabQuestion(
            headword: w.headword,
            wordId: w.wordId,
            wordbookId: band.wordbookId,
          ),
        );
      }
    }

    final pseudo = [...pseudowords]..shuffle(random);
    for (final p in pseudo.take(pseudoCount)) {
      questions.add(VocabQuestion(headword: p));
    }

    questions.shuffle(random);
    return VocabTestPlan(questions: questions, bands: bands);
  }

  /// 直近の測定で出していない語を先に取り、足りない分だけ既出から補う。
  static List<({int wordId, String headword})> _pick(
    List<({int wordId, String headword})> pool,
    int count,
    Set<int> recentlyAsked,
    Random random,
  ) {
    final fresh = [
      for (final w in pool)
        if (!recentlyAsked.contains(w.wordId)) w,
    ]..shuffle(random);
    if (fresh.length >= count) return fresh.take(count).toList();

    final repeat = [
      for (final w in pool)
        if (recentlyAsked.contains(w.wordId)) w,
    ]..shuffle(random);
    return [...fresh, ...repeat.take(count - fresh.length)];
  }
}
