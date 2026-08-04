import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/study_date.dart';

/// カレンダーの1日の状態。
enum StreakDayState {
  /// 目標を達成した日。
  met,

  /// 学習したが未達の日。
  studied,

  /// 学習していない日。
  none,
}

/// 月カレンダー（[Docs/06_features/stats.md] §7）。
///
/// 達成日 `accent` / 学習したが未達 `accentSoft` / 未学習は無地。
/// 3段階を凡例で示し、色だけに頼らない。日付は学習日（04:00 区切り）で数える。
class StreakCalendar extends StatelessWidget {
  /// 表示する月（日は無視する）。
  final DateTime month;

  /// 学習日（`YYYY-MM-DD`）→ 状態。
  final Map<String, StreakDayState> states;

  /// 今日の学習日（枠を付ける）。
  final String today;

  final VoidCallback? onPrevMonth;
  final VoidCallback? onNextMonth;

  const StreakCalendar({
    super.key,
    required this.month,
    required this.states,
    required this.today,
    this.onPrevMonth,
    this.onNextMonth,
  });

  static const _weekdayLabels = ['日', '月', '火', '水', '木', '金', '土'];

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // 日曜始まり。weekday は月曜=1〜日曜=7。
    final leading = first.weekday % 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onPrevMonth,
              tooltip: '前の月',
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(
                '${month.year}年${month.month}月',
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: AppText.body(),
              ),
            ),
            IconButton(
              onPressed: onNextMonth,
              tooltip: '次の月',
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        Row(
          children: [
            for (final label in _weekdayLabels)
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: AppText.caption(),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          children: [
            for (var i = 0; i < leading; i++) const SizedBox.shrink(),
            for (var day = 1; day <= daysInMonth; day++)
              _DayCell(
                day: day,
                state:
                    states[formatStudyDate(
                      DateTime(month.year, month.month, day),
                    )] ??
                    StreakDayState.none,
                isToday:
                    formatStudyDate(DateTime(month.year, month.month, day)) ==
                    today,
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            _LegendItem(color: AppColors.accent, label: '目標を達成'),
            _LegendItem(color: AppColors.accentSoft, label: '学習したが未達'),
            _LegendItem(color: AppColors.card, label: '学習していない'),
          ],
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final StreakDayState state;
  final bool isToday;

  const _DayCell({
    required this.day,
    required this.state,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final fill = switch (state) {
      StreakDayState.met => AppColors.accent,
      StreakDayState.studied => AppColors.accentSoft,
      StreakDayState.none => AppColors.card,
    };
    return Container(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isToday ? AppColors.ink : AppColors.line,
          width: isToday ? 2 : 1,
        ),
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          '$day',
          maxLines: 1,
          style: AppText.caption(
            color: state == StreakDayState.met ? Colors.white : AppColors.ink2,
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: AppColors.line),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, maxLines: 1, style: AppText.caption()),
      ],
    );
  }
}
