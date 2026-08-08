import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

/// ドーナツの1区分。
class DonutSegment {
  final String label;
  final int value;
  final Color color;

  const DonutSegment({
    required this.label,
    required this.value,
    required this.color,
  });
}

/// 習熟度の内訳（`CustomPainter`。[Docs/05_design_system.md] §3.1）。
///
/// 外部のグラフパッケージは使わない。凡例は色ドット＋名称＋語数＋割合で、
/// **色だけに頼らない**。
class DonutChart extends StatelessWidget {
  final List<DonutSegment> segments;

  /// 中央に置く表示（「1,204 / 3,800」など）。
  final Widget? center;
  final double size;
  final double strokeWidth;

  const DonutChart({
    super.key,
    required this.segments,
    this.center,
    this.size = 160,
    this.strokeWidth = 22,
  });

  int get total => segments.fold(0, (sum, s) => sum + s.value);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(
          segments: segments,
          strokeWidth: strokeWidth,
          track: AppColors.masteryTrack,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(strokeWidth + 6),
            child: FittedBox(fit: BoxFit.scaleDown, child: center),
          ),
        ),
      ),
    );
  }
}

/// ドーナツの凡例（色ドット＋名称＋件数＋割合）。
class DonutLegend extends StatelessWidget {
  final List<DonutSegment> segments;

  /// 件数の単位（「語」「語族」）。
  final String unit;

  const DonutLegend({super.key, required this.segments, this.unit = '語'});

  @override
  Widget build(BuildContext context) {
    final total = segments.fold(0, (sum, s) => sum + s.value);
    return Column(
      children: [
        for (final s in segments)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: s.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(),
                  ),
                ),
                Text(
                  '${s.value}$unit',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 44,
                  child: Text(
                    total == 0 ? '—' : '${(s.value * 100 / total).round()}%',
                    maxLines: 1,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption(),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<DonutSegment> segments;
  final double strokeWidth;
  final Color track;

  const _DonutPainter({
    required this.segments,
    required this.strokeWidth,
    required this.track,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = track;
    canvas.drawArc(rect, 0, math.pi * 2, false, base);

    final total = segments.fold(0, (sum, s) => sum + s.value);
    if (total == 0) return;

    var start = -math.pi / 2;
    for (final s in segments) {
      if (s.value <= 0) continue;
      final sweep = math.pi * 2 * s.value / total;
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..color = s.color,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.segments.length != segments.length ||
      old.strokeWidth != strokeWidth ||
      Iterable<int>.generate(segments.length).any(
        (i) =>
            old.segments[i].value != segments[i].value ||
            old.segments[i].color != segments[i].color,
      );
}
