import 'review_state.dart';

/// 習熟度（[Docs/06_features/srs_scheduler.md] §5）。
///
/// `word_reviews.masteryLevel` / `part_reviews.masteryLevel` は導出値だが、
/// 絞り込み・並べ替えにインデックスが要るため列として持つ。
/// **導出は [Mastery.from] だけが行い**、学習状態を書き換える同一トランザクション内で
/// 必ず一緒に書き換える（[Docs/03_data_model.md] §2.5）。
enum Mastery {
  unlearned(0, '未学習'),
  learning(1, '学習中'),
  settled(2, '定着'),
  mastered(3, 'マスター');

  /// DB に保存する値。
  final int level;
  final String label;
  const Mastery(this.level, this.label);

  static Mastery fromLevel(int level) => Mastery.values.firstWhere(
    (e) => e.level == level,
    orElse: () => throw FormatException('未知のmasteryLevel: $level'),
  );

  /// 学習状態から習熟度を導出する。
  ///
  /// `word_reviews` に行が無い語（= まだ一度も解いていない）は [unlearned]。
  /// 行がある語は必ず [learning] 以上になる。
  static Mastery from(ReviewState s) {
    if (s.intervalDays >= 90 && s.correctStreak >= 3) return Mastery.mastered;
    if (s.intervalDays >= 21) return Mastery.settled;
    return Mastery.learning;
  }
}
