import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// 学習者の絵文字＋識別色の丸（[Docs/05_design_system.md] §3.2）。
///
/// ホーム右上（36px）とプロファイルゲート（72px）で使う。名前を添えるかは
/// 呼び出し側で選ぶ。
class ProfileAvatar extends StatelessWidget {
  final String emoji;

  /// 識別色の割当シード（`profiles.colorSeed`）。
  final int colorSeed;
  final double size;

  /// 現在の学習者であることを示す枠を描くか。
  final bool selected;

  const ProfileAvatar({
    super.key,
    required this.emoji,
    required this.colorSeed,
    this.size = 36,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.seedColor(colorSeed);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        // 識別色そのままでは絵文字が沈むため、淡く敷いて枠に識別色を使う。
        color: color.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? color : color.withValues(alpha: 0.35),
          width: selected ? 3 : 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: EdgeInsets.all(size * 0.14),
          // 絵文字は端末の文字拡大に追従させない。丸の中で位置が跳ねるため。
          child: Text(
            emoji,
            textScaler: TextScaler.noScaling,
            style: TextStyle(fontSize: size * 0.52),
          ),
        ),
      ),
    );
  }
}
