import 'package:meta/meta.dart';

import '../../core/utils/enums.dart';

/// 実績の判定に要る集計値（[Docs/06_features/gamification.md] §4）。
///
/// 「触れた語数」「マスター語数」は**選択中の単語帳に限定しない**。学習対象を
/// 切り替えるたびに実績の進捗が上下すると、達成の意味が失われるため、その人が
/// 触れた全単語を対象に数える（§5）。値はすべて**現在の学習者**のもの。
@immutable
class AchievementStats {
  /// 完了した（`finishedAt` が入っている）セッション数。
  final int completedSessions;

  /// 最長のストリーク（達成後に途切れても実績は取り消さない）。
  final int longestStreak;

  /// 学習状態のある語数（`word_reviews` の行数）。
  final int touchedWords;

  /// マスター（`masteryLevel = 3`）の語数。
  final int masteredWords;

  /// 正解率100%で終えたセッションの最大解答数（`perfect_20` の判定に使う）。
  final int bestPerfectAnswered;

  /// spell モードの通算正解数。
  final int spellCorrect;

  /// 語形変化クイズの通算正解数。
  final int familyCorrect;

  /// 学習日の 00:00〜04:00 に解いた回数。
  final int nightAnswers;

  /// 学習日の 04:00〜07:00 に解いた回数。
  final int morningAnswers;

  /// セッションを完了したことのあるモード。
  final Set<StudyMode> completedModes;

  /// マスターした語の部品の数。
  final int masteredParts;

  /// 解消した取り違えの組の数。
  final int resolvedConfusions;

  /// スピードモードの最速の平均反応時間（ミリ秒）。実施が無ければ null。
  final int? bestSpeedAvgMs;

  /// 語彙力測定の推定語彙数の最大値。
  final int bestVocabSize;

  const AchievementStats({
    this.completedSessions = 0,
    this.longestStreak = 0,
    this.touchedWords = 0,
    this.masteredWords = 0,
    this.bestPerfectAnswered = 0,
    this.spellCorrect = 0,
    this.familyCorrect = 0,
    this.nightAnswers = 0,
    this.morningAnswers = 0,
    this.completedModes = const {},
    this.masteredParts = 0,
    this.resolvedConfusions = 0,
    this.bestSpeedAvgMs,
    this.bestVocabSize = 0,
  });
}
