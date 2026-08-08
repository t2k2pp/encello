import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

/// 棒グラフの1本。
class BarDatum {
  /// 横軸のラベル（`YYYY-MM-DD`）。目盛りには日だけを出す。
  final String label;
  final double value;

  /// 目標を達成した日か（バーの色を変える）。
  final bool highlighted;

  const BarDatum({
    required this.label,
    required this.value,
    this.highlighted = false,
  });
}

/// 直近30日の学習量（`CustomPainter`。[Docs/06_features/stats.md] §4）。
///
/// 学習していない日も**バー0で描く**（日付を詰めない）。空白があること自体が
/// 情報になる。目標線を破線で重ねる。
class BarChart extends StatelessWidget {
  final List<BarDatum> data;

  /// 破線で重ねる目標値。null なら描かない。
  final double? goalLine;
  final double height;

  const BarChart({
    super.key,
    required this.data,
    this.goalLine,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height,
          child: CustomPaint(
            painter: _BarPainter(
              data: data,
              goalLine: goalLine,
              barColor: AppColors.accent,
              mutedColor: AppColors.chipBg,
              lineColor: AppColors.ink3,
            ),
          ),
        ),
        const SizedBox(height: 4),
        _AxisLabels(data: data),
      ],
    );
  }
}

/// 折れ線グラフ（正解率・反応時間）。**値が無い日は点を打たず線を切る**
/// （[Docs/06_features/stats.md] §5・§6）。
class LineChart extends StatelessWidget {
  /// 各点の値。null = その日はデータが無い。
  final List<double?> values;

  /// 横軸のラベル（`YYYY-MM-DD`）。
  final List<String> labels;

  /// 縦軸の上限。正解率のように**固定したい**ときに渡す（データで伸縮させない）。
  final double? maxValue;

  /// 破線で重ねる基準値（制限時間など）。
  final double? guideLine;
  final double height;

  const LineChart({
    super.key,
    required this.values,
    required this.labels,
    this.maxValue,
    this.guideLine,
    this.height = 140,
  }) : assert(values.length == labels.length, '値とラベルの数が合っていません');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height,
          child: CustomPaint(
            painter: _LinePainter(
              values: values,
              maxValue: maxValue,
              guideLine: guideLine,
              lineColor: AppColors.accent,
              gridColor: AppColors.line,
              guideColor: AppColors.ink3,
            ),
          ),
        ),
        const SizedBox(height: 4),
        _AxisLabels(
          data: [
            for (var i = 0; i < labels.length; i++)
              BarDatum(label: labels[i], value: 0),
          ],
        ),
      ],
    );
  }
}

/// 横軸のラベル（左端・中央・右端の3つだけ）。30日分すべては入らない。
class _AxisLabels extends StatelessWidget {
  final List<BarDatum> data;

  const _AxisLabels({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    String short(String date) {
      final parts = date.split('-');
      return parts.length == 3
          ? '${int.parse(parts[1])}/${int.parse(parts[2])}'
          : date;
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            short(data.first.label),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.caption(),
          ),
        ),
        Expanded(
          child: Text(
            short(data[data.length ~/ 2].label),
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: AppText.caption(),
          ),
        ),
        Expanded(
          child: Text(
            short(data.last.label),
            maxLines: 1,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: AppText.caption(),
          ),
        ),
      ],
    );
  }
}

class _BarPainter extends CustomPainter {
  final List<BarDatum> data;
  final double? goalLine;
  final Color barColor;
  final Color mutedColor;
  final Color lineColor;

  const _BarPainter({
    required this.data,
    required this.goalLine,
    required this.barColor,
    required this.mutedColor,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxValue = [
      for (final d in data) d.value,
      ?goalLine,
      1.0,
    ].reduce((a, b) => a > b ? a : b);

    final slot = size.width / data.length;
    final barWidth = (slot * 0.7).clamp(1.0, 14.0);
    for (var i = 0; i < data.length; i++) {
      final d = data[i];
      final h = size.height * (d.value / maxValue);
      final left = slot * i + (slot - barWidth) / 2;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, size.height - h, barWidth, h),
        const Radius.circular(2),
      );
      canvas.drawRect(
        // 0 の日は下端に細い線を残し、「その日が無かった」ように見せない。
        Rect.fromLTWH(left, size.height - 1, barWidth, 1),
        Paint()..color = mutedColor,
      );
      if (d.value <= 0) continue;
      canvas.drawRRect(
        rect,
        Paint()..color = d.highlighted ? barColor : mutedColor,
      );
    }

    final goal = goalLine;
    if (goal == null || goal <= 0) return;
    _drawDashedLine(
      canvas,
      y: size.height - size.height * (goal / maxValue),
      width: size.width,
      color: lineColor,
    );
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.data.length != data.length || old.goalLine != goalLine;
}

class _LinePainter extends CustomPainter {
  final List<double?> values;
  final double? maxValue;
  final double? guideLine;
  final Color lineColor;
  final Color gridColor;
  final Color guideColor;

  const _LinePainter({
    required this.values,
    required this.maxValue,
    required this.guideLine,
    required this.lineColor,
    required this.gridColor,
    required this.guideColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final top =
        maxValue ??
        [
          for (final v in values) ?v,
          ?guideLine,
          1.0,
        ].reduce((a, b) => a > b ? a : b);

    // 上下の基準線。
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      grid,
    );
    canvas.drawLine(Offset.zero, Offset(size.width, 0), grid);

    final slot = values.length == 1
        ? size.width
        : size.width / (values.length - 1);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = lineColor;

    Offset? previous;
    for (var i = 0; i < values.length; i++) {
      final v = values[i];
      if (v == null) {
        // 値が無い日は点を打たず、線をつながない。
        previous = null;
        continue;
      }
      final point = Offset(
        slot * i,
        size.height - size.height * (v / top).clamp(0.0, 1.0),
      );
      if (previous != null) canvas.drawLine(previous, point, paint);
      canvas.drawCircle(point, 2.5, Paint()..color = lineColor);
      previous = point;
    }

    final guide = guideLine;
    if (guide == null || guide <= 0) return;
    _drawDashedLine(
      canvas,
      y: size.height - size.height * (guide / top).clamp(0.0, 1.0),
      width: size.width,
      color: guideColor,
    );
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.values.length != values.length ||
      old.maxValue != maxValue ||
      old.guideLine != guideLine;
}

/// 目標線・基準線の破線。
void _drawDashedLine(
  Canvas canvas, {
  required double y,
  required double width,
  required Color color,
}) {
  final paint = Paint()
    ..color = color
    ..strokeWidth = 1;
  const dash = 4.0;
  const gap = 4.0;
  var x = 0.0;
  while (x < width) {
    canvas.drawLine(Offset(x, y), Offset((x + dash).clamp(0, width), y), paint);
    x += dash + gap;
  }
}
