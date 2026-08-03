import 'package:flutter/material.dart';

/// 広い画面（iPad / 横向き）でコンテンツが間延びしないよう、最大幅を制限して
/// 中央寄せする共通ラッパ（[STYLE_GUIDE §2]）。
///
/// **学習画面（SCR-03〜SCR-06）では使わない**。最大幅640に絞るとキーボードが中央に
/// 浮いて押しにくくなるため、学習画面は最大幅720とし、キーボードは画面幅いっぱいに
/// 置く（[Docs/05_design_system.md] §4）。
class CenteredContent extends StatelessWidget {
  final Widget child;

  /// コンテンツの最大幅。既定は一覧・設定・統計で読みやすい 640。
  final double maxWidth;

  const CenteredContent({super.key, required this.child, this.maxWidth = 640});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
