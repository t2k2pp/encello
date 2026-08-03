import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// 識別色の選択（36px 色玉。選択中は ink 枠3px＋白チェック。[STYLE_GUIDE §4.2]）。
///
/// 学習者・単語帳など識別色を持つエンティティの編集シートで共通に使う。
class ColorDotPicker extends StatelessWidget {
  /// `AppColors.accentPalette` のインデックス（`colorSeed`）。
  final int selectedSeed;
  final ValueChanged<int> onChanged;

  const ColorDotPicker({
    super.key,
    required this.selectedSeed,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (var i = 0; i < AppColors.accentPalette.length; i++)
          ColorDot(
            color: AppColors.accentPalette[i],
            selected: i == selectedSeed,
            onTap: () => onChanged(i),
          ),
      ],
    );
  }
}

/// 色玉1つ。最小タップ領域 44×44 を確保する（NFR-06）。
class ColorDot extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const ColorDot({
    super.key,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.ink : Colors.transparent,
                  width: 3,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
