import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

/// 円形の進捗（`CustomPainter`）。ホームの今日の進捗と、結果画面の正解率に使う
/// （[Docs/05_design_system.md] §3.2）。外部のグラフパッケージは使わない。
class ProgressRing extends StatelessWidget {
  /// 0.0〜1.0。
  final double value;
  final double size;
  final double strokeWidth;
  final Color? color;

  /// リングの中に置く表示（件数など）。
  final Widget? child;

  const ProgressRing({
    super.key,
    required this.value,
    this.size = 96,
    this.strokeWidth = 10,
    this.color,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          value: value.clamp(0.0, 1.0),
          strokeWidth: strokeWidth,
          color: color ?? AppColors.accent,
          track: AppColors.masteryTrack,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(strokeWidth + 4),
            child: FittedBox(fit: BoxFit.scaleDown, child: child),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final double strokeWidth;
  final Color color;
  final Color track;

  const _RingPainter({
    required this.value,
    required this.strokeWidth,
    required this.color,
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

    if (value <= 0) return;
    final progress = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * value, false, progress);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color;
}

/// 正解率などをリングの中に出すためのラベル。
class RingLabel extends StatelessWidget {
  final String value;
  final String caption;

  const RingLabel({super.key, required this.value, required this.caption});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          maxLines: 1,
          style: AppText.style(size: 22, weight: FontWeight.w800),
        ),
        Text(caption, maxLines: 1, style: AppText.caption()),
      ],
    );
  }
}
