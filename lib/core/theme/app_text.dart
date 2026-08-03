import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// タイポグラフィのヘルパー。Noto Sans JP に統一する（[Docs/05_design_system.md] §2）。
///
/// **英単語の表示にもラテン用の別書体を使わない**。書体を混ぜるとカードごとに行高が
/// 変わり、フラッシュカードの自動送りで文字位置が跳ねるため。
///
/// 色の既定値はテーマ配色（[AppColors]）に追従するため、null で受けて中で解決する。
class AppText {
  const AppText._();

  static TextStyle style({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.notoSansJp(
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.ink,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle title({Color? color}) => style(
    size: 22,
    weight: FontWeight.w800,
    color: color ?? AppColors.ink,
    letterSpacing: -0.5,
  );

  static TextStyle sectionTitle({Color? color}) =>
      style(size: 16, weight: FontWeight.w700, color: color ?? AppColors.ink);

  static TextStyle body({Color? color}) =>
      style(size: 14, weight: FontWeight.w500, color: color ?? AppColors.ink);

  static TextStyle caption({Color? color}) =>
      style(size: 12, weight: FontWeight.w500, color: color ?? AppColors.ink3);

  // --- encello 固有（[Docs/05_design_system.md] §2）---

  /// 学習画面・単語詳細の英単語。長い語のため `FittedBox(scaleDown)` で包んで使う。
  static TextStyle headword({Color? color}) => style(
    size: 34,
    weight: FontWeight.w700,
    color: color ?? AppColors.ink,
    letterSpacing: 0.5,
  );

  /// 発音記号。
  static TextStyle phonetic({Color? color}) =>
      style(size: 14, weight: FontWeight.w400, color: color ?? AppColors.ink2);

  /// スペルモードの和訳提示。`FittedBox(scaleDown)` で包んで使う。
  static TextStyle prompt({Color? color}) =>
      style(size: 24, weight: FontWeight.w700, color: color ?? AppColors.ink);
}
