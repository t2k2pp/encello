import 'package:flutter/material.dart';

import '../utils/enums.dart';

/// 余白のデザイントークン（ThemeExtension）。設定の「余白」（[UiDensity]）に応じて
/// 画面パディングとカード内余白を切り替える（[STYLE_GUIDE §1.4]）。
///
/// 画面外周・カード内側は直値でなく `AppSpacing.of(context)` を参照する。
class AppSpacing extends ThemeExtension<AppSpacing> {
  /// 画面（ListView 等）の外周パディング。
  final EdgeInsets screenPadding;

  /// `SoftCard` の内側パディング。
  final EdgeInsets cardPadding;

  /// リストアイテム間などの標準間隔。
  final double gap;

  const AppSpacing({
    required this.screenPadding,
    required this.cardPadding,
    required this.gap,
  });

  static const standard = AppSpacing(
    screenPadding: EdgeInsets.all(16),
    cardPadding: EdgeInsets.all(14),
    gap: 8,
  );

  static const compact = AppSpacing(
    screenPadding: EdgeInsets.all(10),
    cardPadding: EdgeInsets.all(10),
    gap: 6,
  );

  static AppSpacing forDensity(UiDensity density) => switch (density) {
    UiDensity.standard => standard,
    UiDensity.compact => compact,
  };

  /// テーマから取得する。テーマ未設定（単体テスト等）は標準を使う。
  static AppSpacing of(BuildContext context) =>
      Theme.of(context).extension<AppSpacing>() ?? standard;

  @override
  AppSpacing copyWith({
    EdgeInsets? screenPadding,
    EdgeInsets? cardPadding,
    double? gap,
  }) {
    return AppSpacing(
      screenPadding: screenPadding ?? this.screenPadding,
      cardPadding: cardPadding ?? this.cardPadding,
      gap: gap ?? this.gap,
    );
  }

  @override
  AppSpacing lerp(ThemeExtension<AppSpacing>? other, double t) {
    if (other is! AppSpacing) return this;
    return AppSpacing(
      screenPadding: EdgeInsets.lerp(screenPadding, other.screenPadding, t)!,
      cardPadding: EdgeInsets.lerp(cardPadding, other.cardPadding, t)!,
      gap: gap + (other.gap - gap) * t,
    );
  }
}
