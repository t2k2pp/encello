import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/mastery.dart';
import 'mastery_badge.dart';

/// 辞書一覧のサムネ（[Docs/05_design_system.md] §3.2）。
///
/// 見出し語の先頭1文字（大文字）＋ 単語帳色の背景 ＋ 習熟度リング（外周2.5px）。
/// 絵文字ではなく文字を使うのは、語ごとに絵文字を用意できないため。
class WordThumb extends StatelessWidget {
  final String headword;

  /// 所属単語帳の識別色シード。どの単語帳にも属さない語は null。
  final int? colorSeed;
  final Mastery mastery;
  final double size;

  const WordThumb({
    super.key,
    required this.headword,
    required this.colorSeed,
    required this.mastery,
    this.size = 54,
  });

  @override
  Widget build(BuildContext context) {
    final base = colorSeed == null
        ? AppColors.chipBg
        : AppColors.seedColor(colorSeed!).withValues(alpha: 0.18);
    final initial = headword.isEmpty ? '?' : headword[0].toUpperCase();
    const ring = 2.5;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MasteryRingPainter(
          color: masteryColor(mastery),
          // 未学習は line 色のリングになるため、背景と溶けないよう太さは変えない。
          strokeWidth: ring,
        ),
        child: Padding(
          padding: const EdgeInsets.all(ring + 1.5),
          child: Container(
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(size * 0.24),
              border: Border.all(color: const Color(0x0A000000)),
            ),
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(4),
                // 端末の文字拡大に追従させると 54px の枠から溢れるため固定する。
                child: Text(
                  initial,
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    fontSize: size * 0.44,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MasteryRingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _MasteryRingPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color;
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(size.width * 0.28)),
      paint,
    );
  }

  @override
  bool shouldRepaint(_MasteryRingPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
