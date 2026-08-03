import 'package:meta/meta.dart';

/// ある学習者のある単語（または語の部品）の間隔反復パラメータ。
///
/// Drift にも Flutter にも依存しない純粋な値オブジェクト。リポジトリが
/// `WordReview` / `PartReview`（Drift 生成クラス）との相互変換を担う
/// （[Docs/02_architecture.md] §1.3）。
@immutable
class ReviewState {
  /// 連続正解回数（SM-2 の n）
  final int repetition;

  /// 現在の出題間隔（日）
  final double intervalDays;

  /// 容易度係数（SM-2 の EF）。下限 1.3
  final double easeFactor;

  /// 次回出題日時。null = まだ一度も解いていない
  final DateTime? dueAt;

  /// 一度定着した語を落とした回数
  final int lapses;

  final int correctStreak;
  final int totalCorrect;
  final int totalIncorrect;

  /// 最初に grade >= 3 になった時刻
  final DateTime? firstLearnedAt;
  final DateTime? lastReviewedAt;

  const ReviewState({
    required this.repetition,
    required this.intervalDays,
    required this.easeFactor,
    required this.dueAt,
    required this.lapses,
    required this.correctStreak,
    required this.totalCorrect,
    required this.totalIncorrect,
    required this.firstLearnedAt,
    required this.lastReviewedAt,
  });

  /// 未学習（`word_reviews` に行が無い状態）に対応する初期値。
  static const initial = ReviewState(
    repetition: 0,
    intervalDays: 0,
    easeFactor: 2.5,
    dueAt: null,
    lapses: 0,
    correctStreak: 0,
    totalCorrect: 0,
    totalIncorrect: 0,
    firstLearnedAt: null,
    lastReviewedAt: null,
  );

  /// 通算の解答数。
  int get totalAnswered => totalCorrect + totalIncorrect;

  /// 通算の正解率（0.0〜1.0）。まだ解いていなければ null。
  double? get accuracy =>
      totalAnswered == 0 ? null : totalCorrect / totalAnswered;

  ReviewState copyWith({
    int? repetition,
    double? intervalDays,
    double? easeFactor,
    DateTime? dueAt,
    int? lapses,
    int? correctStreak,
    int? totalCorrect,
    int? totalIncorrect,
    DateTime? firstLearnedAt,
    DateTime? lastReviewedAt,
  }) {
    return ReviewState(
      repetition: repetition ?? this.repetition,
      intervalDays: intervalDays ?? this.intervalDays,
      easeFactor: easeFactor ?? this.easeFactor,
      dueAt: dueAt ?? this.dueAt,
      lapses: lapses ?? this.lapses,
      correctStreak: correctStreak ?? this.correctStreak,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      totalIncorrect: totalIncorrect ?? this.totalIncorrect,
      firstLearnedAt: firstLearnedAt ?? this.firstLearnedAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ReviewState &&
      other.repetition == repetition &&
      other.intervalDays == intervalDays &&
      other.easeFactor == easeFactor &&
      other.dueAt == dueAt &&
      other.lapses == lapses &&
      other.correctStreak == correctStreak &&
      other.totalCorrect == totalCorrect &&
      other.totalIncorrect == totalIncorrect &&
      other.firstLearnedAt == firstLearnedAt &&
      other.lastReviewedAt == lastReviewedAt;

  @override
  int get hashCode => Object.hash(
    repetition,
    intervalDays,
    easeFactor,
    dueAt,
    lapses,
    correctStreak,
    totalCorrect,
    totalIncorrect,
    firstLearnedAt,
    lastReviewedAt,
  );
}
