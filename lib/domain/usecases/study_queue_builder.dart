import 'dart:math';

import 'package:meta/meta.dart';

import '../entities/review_state.dart';

/// 出題方針（[Docs/06_features/srs_scheduler.md] §6.2）。
enum QueuePolicy {
  /// 期限到来の復習を優先し、不足分を新規語で埋める。
  reviewFirst('reviewFirst', '復習優先'),

  /// 未学習の語だけを掲載順に取る。
  newOnly('newOnly', '新規のみ'),

  /// 解答10回以上かつ正解率60%未満の語を、正解率の低い順に取る。
  weakOnly('weakOnly', '苦手のみ');

  final String value;
  final String label;
  const QueuePolicy(this.value, this.label);

  static QueuePolicy fromValue(String v) => QueuePolicy.values.firstWhere(
    (e) => e.value == v,
    orElse: () => throw FormatException('未知のQueuePolicy: $v'),
  );
}

/// キューに入った語が、どういう理由で選ばれたか。
enum QueueSource {
  /// 期限が来ている復習。
  due,

  /// まだ一度も解いていない語。
  newWord,

  /// 復習も新規も尽きたため、期限前の語を前借りした。
  borrowed,

  /// 苦手として選ばれた語。
  weak,
}

/// 出題キューの候補1件。DB から読んだ値をそのまま渡す。
@immutable
class StudyCandidate {
  final int wordId;

  /// 学習状態。null = 未学習（`word_reviews` に行が無い）。
  final ReviewState? review;

  /// 単語帳の掲載順（新規語をこの順で取る）。
  final int sortOrder;

  const StudyCandidate({
    required this.wordId,
    required this.review,
    required this.sortOrder,
  });

  bool get isNew => review == null;

  int get totalAnswered => review?.totalAnswered ?? 0;

  double? get accuracy => review?.accuracy;
}

/// キューに並んだ1問。
@immutable
class QueuedItem {
  final int wordId;
  final QueueSource source;

  const QueuedItem({required this.wordId, required this.source});

  @override
  bool operator ==(Object other) =>
      other is QueuedItem &&
      other.wordId == wordId &&
      other.source == source;

  @override
  int get hashCode => Object.hash(wordId, source);

  @override
  String toString() => 'QueuedItem($wordId, ${source.name})';
}

/// 出題キューの生成（[Docs/06_features/srs_scheduler.md] §6）。純粋関数。
///
/// DB から読んだ候補と設定を受け取り、出題順を返す。
abstract final class StudyQueueBuilder {
  /// 苦手と見なす条件（[Docs/06_features/dictionary.md] §1.2 と同じ定義）。
  static const weakMinAnswered = 10;
  static const weakMaxAccuracy = 0.6;

  /// [limit] 問ぶんのキューを作る。候補が足りなければその数だけ返す。
  ///
  /// [shuffleSeed] はセッションIDから作る。同じセッションの再現とテストの決定性を
  /// 確保するため、乱数は必ずシード付きにする（§6.3）。
  static List<QueuedItem> build({
    required List<StudyCandidate> candidates,
    required QueuePolicy policy,
    required int limit,
    required DateTime now,
    required int shuffleSeed,
  }) {
    if (limit <= 0) return const [];

    // 同じ単語が複数の単語帳に属していても1度しか入れない。
    final unique = <int, StudyCandidate>{};
    for (final c in candidates) {
      unique.putIfAbsent(c.wordId, () => c);
    }
    final pool = unique.values.toList();

    final picked = switch (policy) {
      QueuePolicy.reviewFirst => _reviewFirst(pool, limit, now),
      QueuePolicy.newOnly => _newOnly(pool, limit),
      QueuePolicy.weakOnly => _weakOnly(pool, limit),
    };

    return _shuffle(picked, shuffleSeed);
  }

  static List<QueuedItem> _reviewFirst(
    List<StudyCandidate> pool,
    int limit,
    DateTime now,
  ) {
    final result = <QueuedItem>[];

    // ① 期限到来の復習を dueAt の昇順で。
    final due = pool
        .where((c) => c.review?.dueAt != null && !c.review!.dueAt!.isAfter(now))
        .toList()
      ..sort((a, b) => a.review!.dueAt!.compareTo(b.review!.dueAt!));
    for (final c in due) {
      if (result.length >= limit) return result;
      result.add(QueuedItem(wordId: c.wordId, source: QueueSource.due));
    }

    // ② 不足分を未学習語で（単語帳の掲載順）。
    final fresh = pool.where((c) => c.isNew).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    for (final c in fresh) {
      if (result.length >= limit) return result;
      result.add(QueuedItem(wordId: c.wordId, source: QueueSource.newWord));
    }

    // ③ まだ不足なら dueAt が近い順に前借りする。
    final taken = result.map((e) => e.wordId).toSet();
    final upcoming = pool
        .where((c) => !taken.contains(c.wordId) && c.review?.dueAt != null)
        .toList()
      ..sort((a, b) => a.review!.dueAt!.compareTo(b.review!.dueAt!));
    for (final c in upcoming) {
      if (result.length >= limit) return result;
      result.add(QueuedItem(wordId: c.wordId, source: QueueSource.borrowed));
    }
    return result;
  }

  static List<QueuedItem> _newOnly(List<StudyCandidate> pool, int limit) {
    final fresh = pool.where((c) => c.isNew).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return [
      for (final c in fresh.take(limit))
        QueuedItem(wordId: c.wordId, source: QueueSource.newWord),
    ];
  }

  static List<QueuedItem> _weakOnly(List<StudyCandidate> pool, int limit) {
    final weak = pool.where((c) {
      final accuracy = c.accuracy;
      return accuracy != null &&
          c.totalAnswered >= weakMinAnswered &&
          accuracy < weakMaxAccuracy;
    }).toList()..sort((a, b) => a.accuracy!.compareTo(b.accuracy!));
    return [
      for (final c in weak.take(limit))
        QueuedItem(wordId: c.wordId, source: QueueSource.weak),
    ];
  }

  /// Fisher–Yates。乱数はシード付きにして、同じシードなら同じ順序にする。
  static List<QueuedItem> _shuffle(List<QueuedItem> items, int seed) {
    final random = Random(seed);
    final list = [...items];
    for (var i = list.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final tmp = list[i];
      list[i] = list[j];
      list[j] = tmp;
    }
    return list;
  }
}
