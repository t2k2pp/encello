import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/enums.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

/// アプリ全体のテーマ（Material 3 + デザイントークン）。
class AppTheme {
  const AppTheme._();

  static ThemeData light({UiDensity density = UiDensity.standard}) {
    final base = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.light,
    ).copyWith(surface: AppColors.card, primary: AppColors.accent);

    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      scaffoldBackgroundColor: AppColors.bg,
      extensions: [AppSpacing.forDensity(density)],
      // コンパクト時は Material 部品（ボタン等）の余白も詰める。
      visualDensity: density == UiDensity.compact
          ? VisualDensity.compact
          : VisualDensity.standard,
      textTheme: GoogleFonts.notoSansJpTextTheme().apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.ink,
      ),
      dividerColor: AppColors.line,
      splashColor: AppColors.accentSoft,
    );
  }
}
