import 'package:meta/meta.dart';

import '../domain/entities/achievement_stats.dart';

/// 実績の定義（[Docs/06_features/gamification.md] §4）。
///
/// 条件そのものはコードに置き、`achievements` テーブルには**解除済みだけ**を残す。
/// 実績を足しても既存の行には影響しない。
@immutable
class AchievementDef {
  /// `achievements.code`。一度決めたら変えない（解除済みの行と対応が取れなくなる）。
  final String code;
  final String name;
  final String emoji;

  /// 未解除でも見せる条件の説明（[Docs/06_features/gamification.md] §4）。
  final String description;

  /// 解除に要る進捗の値。1 = 一度でも満たせば解除。
  final int target;

  /// 進捗の単位（「7 / 30日」の「日」）。
  final String unit;

  const AchievementDef({
    required this.code,
    required this.name,
    required this.emoji,
    required this.description,
    required this.target,
    required this.unit,
  });
}

/// 実績1件の表示用データ（SCR-14）。
@immutable
class AchievementProgress {
  final AchievementDef def;

  /// 現在の進捗（[AchievementDef.target] に対する値）。
  final int current;

  /// 解除済みならその日時。
  final DateTime? unlockedAt;

  const AchievementProgress({
    required this.def,
    required this.current,
    required this.unlockedAt,
  });

  bool get isUnlocked => unlockedAt != null;

  /// 0.0〜1.0。
  double get ratio =>
      def.target <= 0 ? 1 : (current / def.target).clamp(0.0, 1.0);
}

/// 未解除の実績条件を判定する（[Docs/06_features/gamification.md] §4）。
///
/// セッション終了時と、実績一覧を開いたときに走らせる。判定は純粋関数で、
/// 解除済みの記録は呼び出し側（`AchievementService`）が DB に残す。
abstract final class AchievementEvaluator {
  /// 全モード制覇に要るモード数。
  static const allModesCount = 8;

  /// 実績の定義。表示順もこの並びにする。
  static const defs = <AchievementDef>[
    AchievementDef(
      code: 'first_session',
      name: 'はじめの一歩',
      emoji: '🌱',
      description: '初めてセッションを完了する',
      target: 1,
      unit: '回',
    ),
    AchievementDef(
      code: 'streak_3',
      name: '継続 3日',
      emoji: '🔥',
      description: '目標達成を3日続ける',
      target: 3,
      unit: '日',
    ),
    AchievementDef(
      code: 'streak_7',
      name: '継続 7日',
      emoji: '🔥',
      description: '目標達成を7日続ける',
      target: 7,
      unit: '日',
    ),
    AchievementDef(
      code: 'streak_30',
      name: '継続 30日',
      emoji: '🔥',
      description: '目標達成を30日続ける',
      target: 30,
      unit: '日',
    ),
    AchievementDef(
      code: 'streak_100',
      name: '継続 100日',
      emoji: '🔥',
      description: '目標達成を100日続ける',
      target: 100,
      unit: '日',
    ),
    AchievementDef(
      code: 'learned_100',
      name: '100語に触れた',
      emoji: '📖',
      description: '100語を一度でも学習する',
      target: 100,
      unit: '語',
    ),
    AchievementDef(
      code: 'learned_500',
      name: '500語に触れた',
      emoji: '📖',
      description: '500語を一度でも学習する',
      target: 500,
      unit: '語',
    ),
    AchievementDef(
      code: 'learned_1000',
      name: '1000語に触れた',
      emoji: '📖',
      description: '1000語を一度でも学習する',
      target: 1000,
      unit: '語',
    ),
    AchievementDef(
      code: 'mastered_10',
      name: '10語マスター',
      emoji: '🏅',
      description: '10語をマスターにする',
      target: 10,
      unit: '語',
    ),
    AchievementDef(
      code: 'mastered_100',
      name: '100語マスター',
      emoji: '🏅',
      description: '100語をマスターにする',
      target: 100,
      unit: '語',
    ),
    AchievementDef(
      code: 'mastered_500',
      name: '500語マスター',
      emoji: '🏅',
      description: '500語をマスターにする',
      target: 500,
      unit: '語',
    ),
    AchievementDef(
      code: 'perfect_20',
      name: '全問正解',
      emoji: '💯',
      description: '20問以上のセッションを正解率100%で終える',
      target: 20,
      unit: '問',
    ),
    AchievementDef(
      code: 'spell_500',
      name: '綴り職人',
      emoji: '✏️',
      description: 'スペルモードで通算500問正解する',
      target: 500,
      unit: '問',
    ),
    AchievementDef(
      code: 'night_owl',
      name: '夜更かし',
      emoji: '🦉',
      description: '0時から4時のあいだに学習する',
      target: 1,
      unit: '回',
    ),
    AchievementDef(
      code: 'early_bird',
      name: '早起き',
      emoji: '🐦',
      description: '4時から7時のあいだに学習する',
      target: 1,
      unit: '回',
    ),
    AchievementDef(
      code: 'all_modes',
      name: '全モード制覇',
      emoji: '🎪',
      description: '8つのモードすべてでセッションを完了する',
      target: allModesCount,
      unit: 'モード',
    ),
    AchievementDef(
      code: 'parts_50',
      name: '語源使い',
      emoji: '🧩',
      description: '語の部品を50個マスターする',
      target: 50,
      unit: '個',
    ),
    AchievementDef(
      code: 'family_100',
      name: '語形自在',
      emoji: '🔤',
      description: '語形変化クイズに100問正解する',
      target: 100,
      unit: '問',
    ),
    AchievementDef(
      code: 'confusion_10',
      name: '見分けの達人',
      emoji: '🔀',
      description: '取り違えの組を10件解消する',
      target: 10,
      unit: '組',
    ),
    AchievementDef(
      code: 'speed_1s',
      name: '瞬間反応',
      emoji: '⚡',
      description: 'スピードモードで平均1.0秒を切る',
      target: 1,
      unit: '回',
    ),
    AchievementDef(
      code: 'vocab_3000',
      name: '語彙3000',
      emoji: '🗻',
      description: '語彙力測定で推定3,000語に到達する',
      target: 3000,
      unit: '語',
    ),
  ];

  static AchievementDef defOf(String code) => defs.firstWhere(
    (d) => d.code == code,
    orElse: () => throw FormatException('未知の実績コード: $code'),
  );

  /// 実績1件の現在の進捗。未解除の実績も条件と進捗を見せるため、
  /// 解除済みかどうかに関わらず計算する。
  static int progressOf(String code, AchievementStats s) => switch (code) {
    'first_session' => s.completedSessions,
    'streak_3' || 'streak_7' || 'streak_30' || 'streak_100' => s.longestStreak,
    'learned_100' || 'learned_500' || 'learned_1000' => s.touchedWords,
    'mastered_10' || 'mastered_100' || 'mastered_500' => s.masteredWords,
    'perfect_20' => s.bestPerfectAnswered,
    'spell_500' => s.spellCorrect,
    'night_owl' => s.nightAnswers,
    'early_bird' => s.morningAnswers,
    'all_modes' => s.completedModes.length,
    'parts_50' => s.masteredParts,
    'family_100' => s.familyCorrect,
    'confusion_10' => s.resolvedConfusions,
    // 1.0秒未満を切ったことがあるか（速いほど良い指標なので進捗は 0/1 で持つ）。
    'speed_1s' => (s.bestSpeedAvgMs ?? _speedGoalMs) < _speedGoalMs ? 1 : 0,
    'vocab_3000' => s.bestVocabSize,
    _ => throw FormatException('未知の実績コード: $code'),
  };

  /// 条件を満たしている実績（解除済みかどうかは見ない）。
  static List<AchievementDef> satisfied(AchievementStats stats) => [
    for (final d in defs)
      if (progressOf(d.code, stats) >= d.target) d,
  ];

  /// [unlockedCodes] にまだ入っていない、条件を満たした実績。
  /// セッション終了時にここへ来たものを結果画面のカードに出す。
  static List<AchievementDef> newlyUnlocked(
    AchievementStats stats, {
    required Set<String> unlockedCodes,
  }) => [
    for (final d in satisfied(stats))
      if (!unlockedCodes.contains(d.code)) d,
  ];

  /// 一覧（SCR-14）に出す全実績の進捗。解除済みを先に、未解除は達成率の高い順。
  static List<AchievementProgress> progressList(
    AchievementStats stats, {
    required Map<String, DateTime> unlockedAt,
  }) {
    final list = [
      for (final d in defs)
        AchievementProgress(
          def: d,
          current: progressOf(d.code, stats),
          unlockedAt: unlockedAt[d.code],
        ),
    ];
    list.sort((a, b) {
      if (a.isUnlocked != b.isUnlocked) return a.isUnlocked ? -1 : 1;
      if (a.isUnlocked) return a.unlockedAt!.compareTo(b.unlockedAt!);
      return b.ratio.compareTo(a.ratio);
    });
    return list;
  }

  /// ホームの「未達の実績カード」に出す1件（最も達成が近い未解除の実績）。
  static AchievementProgress? nextTarget(
    AchievementStats stats, {
    required Set<String> unlockedCodes,
  }) {
    final pending = [
      for (final d in defs)
        if (!unlockedCodes.contains(d.code))
          AchievementProgress(
            def: d,
            current: progressOf(d.code, stats),
            unlockedAt: null,
          ),
    ]..sort((a, b) => b.ratio.compareTo(a.ratio));
    return pending.isEmpty ? null : pending.first;
  }

  /// 「瞬間反応」の基準（平均1.0秒）。
  static const _speedGoalMs = 1000;
}
