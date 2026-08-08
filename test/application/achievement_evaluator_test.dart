import 'package:encello/application/achievement_evaluator.dart';
import 'package:encello/core/utils/enums.dart';
import 'package:encello/domain/entities/achievement_stats.dart';
import 'package:flutter_test/flutter_test.dart';

/// [Docs/06_features/gamification.md] §4・§6 のテスト観点。
void main() {
  Set<String> codesOf(List<AchievementDef> defs) => {
    for (final d in defs) d.code,
  };

  group('進捗の境界', () {
    test('継続7日は6日で未解除、7日で解除', () {
      expect(
        AchievementEvaluator.progressOf(
          'streak_7',
          const AchievementStats(longestStreak: 6),
        ),
        6,
      );
      expect(
        codesOf(
          AchievementEvaluator.satisfied(
            const AchievementStats(longestStreak: 6),
          ),
        ),
        isNot(contains('streak_7')),
      );
      expect(
        codesOf(
          AchievementEvaluator.satisfied(
            const AchievementStats(longestStreak: 7),
          ),
        ),
        contains('streak_7'),
      );
    });

    test('ストリークは最長で判定する（途切れても取り消さない）', () {
      // 現在のストリークが 0 でも、最長が届いていれば条件を満たす。
      expect(
        codesOf(
          AchievementEvaluator.satisfied(
            const AchievementStats(longestStreak: 30),
          ),
        ),
        containsAll(['streak_3', 'streak_7', 'streak_30']),
      );
    });

    test('全問正解は20問以上のセッションでのみ', () {
      expect(
        codesOf(
          AchievementEvaluator.satisfied(
            const AchievementStats(bestPerfectAnswered: 19),
          ),
        ),
        isNot(contains('perfect_20')),
      );
      expect(
        codesOf(
          AchievementEvaluator.satisfied(
            const AchievementStats(bestPerfectAnswered: 20),
          ),
        ),
        contains('perfect_20'),
      );
    });

    test('瞬間反応は平均1.0秒未満のときだけ', () {
      expect(
        AchievementEvaluator.progressOf(
          'speed_1s',
          const AchievementStats(bestSpeedAvgMs: 1000),
        ),
        0,
      );
      expect(
        AchievementEvaluator.progressOf(
          'speed_1s',
          const AchievementStats(bestSpeedAvgMs: 999),
        ),
        1,
      );
      // スピードモードを一度もやっていなければ進捗 0。
      expect(
        AchievementEvaluator.progressOf('speed_1s', const AchievementStats()),
        0,
      );
    });

    test('全モード制覇は8モードすべてを完了したとき', () {
      final seven = StudyMode.values.take(7).toSet();
      expect(
        codesOf(
          AchievementEvaluator.satisfied(
            AchievementStats(completedModes: seven),
          ),
        ),
        isNot(contains('all_modes')),
      );
      expect(
        codesOf(
          AchievementEvaluator.satisfied(
            AchievementStats(completedModes: StudyMode.values.toSet()),
          ),
        ),
        contains('all_modes'),
      );
    });

    test('語彙3000は測定の最大値で判定する', () {
      expect(
        codesOf(
          AchievementEvaluator.satisfied(
            const AchievementStats(bestVocabSize: 2999),
          ),
        ),
        isNot(contains('vocab_3000')),
      );
      expect(
        codesOf(
          AchievementEvaluator.satisfied(
            const AchievementStats(bestVocabSize: 3000),
          ),
        ),
        contains('vocab_3000'),
      );
    });
  });

  group('解除', () {
    test('すでに解除済みの実績は二重に返さない', () {
      const stats = AchievementStats(completedSessions: 1, longestStreak: 3);
      final first = AchievementEvaluator.newlyUnlocked(
        stats,
        unlockedCodes: const {},
      );
      expect(codesOf(first), containsAll(['first_session', 'streak_3']));

      final second = AchievementEvaluator.newlyUnlocked(
        stats,
        unlockedCodes: codesOf(first),
      );
      expect(second, isEmpty);
    });

    test('同時に条件を満たした実績は両方返る', () {
      final unlocked = AchievementEvaluator.newlyUnlocked(
        const AchievementStats(touchedWords: 100, masteredWords: 10),
        unlockedCodes: const {},
      );
      expect(codesOf(unlocked), containsAll(['learned_100', 'mastered_10']));
    });
  });

  group('一覧と次の目標', () {
    test('解除済みを先に、未解除は達成率の高い順に並べる', () {
      final list = AchievementEvaluator.progressList(
        const AchievementStats(completedSessions: 1, touchedWords: 90),
        unlockedAt: {'first_session': DateTime(2026, 8, 1)},
      );
      expect(list.first.def.code, 'first_session');
      expect(list.first.isUnlocked, isTrue);
      // 90/100 まで来ている learned_100 が未解除の先頭に来る。
      expect(list.where((a) => !a.isUnlocked).first.def.code, 'learned_100');
    });

    test('次の目標は最も達成が近い未解除の実績', () {
      final next = AchievementEvaluator.nextTarget(
        const AchievementStats(completedSessions: 1, touchedWords: 90),
        unlockedCodes: const {'first_session'},
      );
      expect(next!.def.code, 'learned_100');
      expect(next.current, 90);
      expect(next.ratio, closeTo(0.9, 1e-9));
    });

    test('すべて解除済みなら次の目標は無い', () {
      final next = AchievementEvaluator.nextTarget(
        const AchievementStats(),
        unlockedCodes: {for (final d in AchievementEvaluator.defs) d.code},
      );
      expect(next, isNull);
    });
  });

  test('実績コードが重複していない（解除済みの行と対応が取れなくなる）', () {
    final codes = AchievementEvaluator.defs.map((d) => d.code).toList();
    expect(codes.toSet().length, codes.length);
  });
}
