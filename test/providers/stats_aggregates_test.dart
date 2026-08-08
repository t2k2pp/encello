import 'package:encello/data/database/app_database.dart';
import 'package:encello/data/repositories/stats_repository.dart';
import 'package:encello/providers/reaction_time_stats.dart';
import 'package:encello/providers/stats_aggregates.dart';
import 'package:flutter_test/flutter_test.dart';

/// [Docs/06_features/stats.md] §4〜§6・§11 の集計。
void main() {
  DailyStat stat(
    String date, {
    int answered = 10,
    int correct = 8,
    int goal = 20,
    bool met = false,
  }) => DailyStat(
    profileId: 1,
    studyDate: date,
    answeredCount: answered,
    correctCount: correct,
    xp: 0,
    studySeconds: 0,
    goalCount: goal,
    goalMet: met,
  );

  group('学習量の系列', () {
    test('欠損日が 0 埋めされ、ちょうど30日分になる', () {
      final series = StatsAggregates.dailySeries(
        [stat('2026-08-04'), stat('2026-07-20')],
        today: '2026-08-04',
        currentGoal: 20,
      );

      expect(series.length, 30);
      expect(series.first.studyDate, '2026-07-06');
      expect(series.last.studyDate, '2026-08-04');
      // 記録の無い日も日付を詰めずに 0 で並べる。
      expect(
        series.firstWhere((p) => p.studyDate == '2026-08-03').answeredCount,
        0,
      );
      expect(
        series.firstWhere((p) => p.studyDate == '2026-07-20').answeredCount,
        10,
      );
    });

    test('記録が無い日の目標は現在の設定値を使う', () {
      final series = StatsAggregates.dailySeries(
        [stat('2026-08-04', goal: 50)],
        today: '2026-08-04',
        currentGoal: 20,
      );
      expect(series.last.goalCount, 50);
      expect(series.first.goalCount, 20);
    });

    test('解答 0 の日は正解率が null（0% の点を打たない）', () {
      final series = StatsAggregates.dailySeries(
        [stat('2026-08-04', answered: 10, correct: 5)],
        today: '2026-08-04',
        currentGoal: 20,
      );
      expect(series.last.accuracy, closeTo(0.5, 1e-9));
      expect(series.first.accuracy, isNull);
    });

    test('30日より前の記録は系列に入らない', () {
      final series = StatsAggregates.dailySeries(
        [stat('2026-06-01', answered: 99)],
        today: '2026-08-04',
        currentGoal: 20,
      );
      expect(series.every((p) => p.answeredCount == 0), isTrue);
    });
  });

  group('直近の成績', () {
    final stats = [
      stat('2026-08-04', answered: 10, correct: 5),
      stat('2026-08-03', answered: 10, correct: 10),
      // 8日前（対象外）。
      stat('2026-07-28', answered: 100, correct: 0),
    ];

    test('直近7日だけを見る', () {
      expect(StatsAggregates.recentAnswered(stats, today: '2026-08-04'), 20);
      expect(
        StatsAggregates.recentAccuracy(stats, today: '2026-08-04'),
        closeTo(0.75, 1e-9),
      );
    });

    test('解答が1問も無ければ正解率は null', () {
      expect(
        StatsAggregates.recentAccuracy(const [], today: '2026-08-04'),
        isNull,
      );
      expect(StatsAggregates.recentAnswered(const [], today: '2026-08-04'), 0);
    });
  });

  group('反応時間', () {
    SpeedAnswer answer(DateTime at, int ms, {bool correct = true}) =>
        SpeedAnswer(answeredAt: at, elapsedMs: ms, isCorrect: correct);

    test('平均は時間内に正解した問題だけで取る', () {
      final series = ReactionTimeStats.dailySeries([
        answer(DateTime(2026, 8, 4, 20), 1000),
        answer(DateTime(2026, 8, 4, 20), 2000),
        // 時間切れ・誤答は平均に混ぜない（制限時間を変えると比べられなくなる）。
        answer(DateTime(2026, 8, 4, 20), 3000, correct: false),
      ], today: '2026-08-04');
      expect(series.last.averageMs, 1500);
      expect(series.last.sampleCount, 2);
    });

    test('実施していない日は null で線を切る', () {
      final series = ReactionTimeStats.dailySeries([
        answer(DateTime(2026, 8, 4, 20), 1200),
      ], today: '2026-08-04');
      expect(series.length, 30);
      expect(series.last.averageMs, 1200);
      expect(series[series.length - 2].averageMs, isNull);
    });

    test('学習日は 04:00 区切りで数える', () {
      // 8/5 の 03:59 は学習日 8/4。
      final series = ReactionTimeStats.dailySeries([
        answer(DateTime(2026, 8, 5, 3, 59), 900),
      ], today: '2026-08-04');
      expect(series.last.studyDate, '2026-08-04');
      expect(series.last.averageMs, 900);
    });

    test('全期間の平均も時間内正解だけで取る', () {
      expect(
        ReactionTimeStats.average([
          answer(DateTime(2026, 8, 4, 20), 800),
          answer(DateTime(2026, 8, 4, 20), 1200),
          answer(DateTime(2026, 8, 4, 20), 5000, correct: false),
        ]),
        1000,
      );
      expect(ReactionTimeStats.average(const []), isNull);
    });
  });
}
