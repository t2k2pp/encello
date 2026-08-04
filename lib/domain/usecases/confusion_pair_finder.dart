import 'package:meta/meta.dart';

import '../../core/utils/enums.dart';
import 'spell_judge.dart';

/// 取り違えの検出に使う解答ログ1件（DB から読んだ値をそのまま渡す）。
@immutable
class AnsweredLog {
  final int wordId;
  final StudyMode mode;
  final StudyDirection direction;
  final bool isCorrect;

  /// 入力した文字列／選んだ選択肢。
  final String? answeredText;
  final DateTime answeredAt;

  const AnsweredLog({
    required this.wordId,
    required this.mode,
    required this.direction,
    required this.isCorrect,
    required this.answeredText,
    required this.answeredAt,
  });
}

/// 逆引きに使う語（見出し語と訳）。
@immutable
class ConfusionWord {
  final int wordId;
  final String headword;
  final String meaning;

  /// 除外された語・下書きは組にしない。
  final bool isStudiable;

  const ConfusionWord({
    required this.wordId,
    required this.headword,
    required this.meaning,
    this.isStudiable = true,
  });
}

/// 取り違えている2語の組。**向きを持たない**（`wordIdA < wordIdB` で正規化する）。
@immutable
class ConfusionPair {
  final int wordIdA;
  final int wordIdB;

  /// この組での誤答回数（両方向を合算した数）。
  final int count;

  const ConfusionPair({
    required this.wordIdA,
    required this.wordIdB,
    required this.count,
  });

  ({int a, int b}) get ids => (a: wordIdA, b: wordIdB);

  @override
  bool operator ==(Object other) =>
      other is ConfusionPair &&
      other.wordIdA == wordIdA &&
      other.wordIdB == wordIdB &&
      other.count == count;

  @override
  int get hashCode => Object.hash(wordIdA, wordIdB, count);

  @override
  String toString() => 'ConfusionPair($wordIdA,$wordIdB × $count)';
}

/// その学習者が実際に取り違えている組を、解答履歴から割り出す
/// （[Docs/06_features/confusion_drill.md] §2）。純粋関数。
///
/// 既製の「紛らわしい語リスト」ではなく**自分の誤り**を使う。追加のデータは要らない。
abstract final class ConfusionPairFinder {
  /// 組が成立する最小の誤答回数。1回はたまたま。
  static const minCount = 2;

  /// 何日前までの誤答を見るか。昔の混同を蒸し返さない。
  static const withinDays = 90;

  static List<ConfusionPair> find({
    required List<AnsweredLog> logs,
    required List<ConfusionWord> words,
    required DateTime now,

    /// 解消済みの組（`resolved_confusions`）。出題対象から外す。
    Set<({int a, int b})> resolved = const {},
  }) {
    final byId = {for (final w in words) w.wordId: w};
    // 逆引き表。同じ訳・同じ綴りが複数あれば一意に決められないので候補から外す。
    final byMeaning = _uniqueIndex(words, (w) => w.meaning);
    final byHeadword = _uniqueIndex(
      words,
      (w) => SpellJudge.normalize(w.headword),
    );

    final counts = <({int a, int b}), int>{};
    final threshold = now.subtract(const Duration(days: withinDays));

    for (final log in logs) {
      if (log.isCorrect) continue;
      if (log.answeredAt.isBefore(threshold)) continue;
      final answered = log.answeredText;
      if (answered == null || answered.isEmpty) continue;

      final target = byId[log.wordId];
      if (target == null || !target.isStudiable) continue;

      final confusedWith = switch (log.mode) {
        // 4択: 選んだ選択肢の文字列を、出題方向に応じて語へ逆引きする。
        StudyMode.choice || StudyMode.speed =>
          log.direction == StudyDirection.enToJa
              ? byMeaning[answered]
              : byHeadword[SpellJudge.normalize(answered)],
        // 綴り系: 打った文字列が**別の実在語**だったときだけ組にする。
        // 実在しない綴りは単なる打ち間違いで、語の取り違えではない。
        StudyMode.spell ||
        StudyMode.listening ||
        StudyMode.family => byHeadword[SpellJudge.normalize(answered)],
        _ => null,
      };
      if (confusedWith == null) continue;
      if (confusedWith.wordId == target.wordId) continue;
      if (!confusedWith.isStudiable) continue;

      final key = _normalizePair(target.wordId, confusedWith.wordId);
      if (resolved.contains(key)) continue;
      counts[key] = (counts[key] ?? 0) + 1;
    }

    final pairs = [
      for (final entry in counts.entries)
        if (entry.value >= minCount)
          ConfusionPair(
            wordIdA: entry.key.a,
            wordIdB: entry.key.b,
            count: entry.value,
          ),
    ]..sort((x, y) => y.count.compareTo(x.count));
    return pairs;
  }

  /// `(A,B)` と `(B,A)` を同じ組として扱うための正規化。
  static ({int a, int b}) _normalizePair(int x, int y) =>
      x < y ? (a: x, b: y) : (a: y, b: x);

  /// 値が一意に決まるものだけを引ける索引にする。
  static Map<String, ConfusionWord> _uniqueIndex(
    List<ConfusionWord> words,
    String Function(ConfusionWord) key,
  ) {
    final counts = <String, int>{};
    for (final w in words) {
      counts[key(w)] = (counts[key(w)] ?? 0) + 1;
    }
    return {
      for (final w in words)
        if (counts[key(w)] == 1) key(w): w,
    };
  }

  /// 組の正規化（呼び出し側が DB へ書くときに使う）。
  static ({int a, int b}) normalize(int x, int y) => _normalizePair(x, y);
}
