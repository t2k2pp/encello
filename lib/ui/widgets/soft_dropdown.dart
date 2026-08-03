import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// 一覧画面のフィルタ・ソートに使うプルダウンの共通装飾（[STYLE_GUIDE §3.3]）。
///
/// 絞り込みは**必ずプルダウン**で作る（ボタン・チップの列にしない）。
InputDecoration softDropdownDecoration(String hint) => InputDecoration(
  isDense: true,
  filled: true,
  fillColor: AppColors.card,
  hintText: hint,
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
  ),
);

/// ラベルを1行で省略するプルダウン。
class SoftDropdown<T> extends StatelessWidget {
  final T value;
  final String hint;
  final List<({T value, String label})> items;
  final ValueChanged<T> onChanged;

  const SoftDropdown({
    super.key,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: softDropdownDecoration(hint),
      items: [
        for (final item in items)
          DropdownMenuItem<T>(
            value: item.value,
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

/// 昇順/降順のトグル（[STYLE_GUIDE §3.4]）。項目プルダウンと分離して、
/// 開いたメニューが画面を覆わないようにする。
class SortDirectionToggle extends StatelessWidget {
  final bool ascending;
  final ValueChanged<bool> onChanged;

  const SortDirectionToggle({
    super.key,
    required this.ascending,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(visualDensity: VisualDensity.compact),
      segments: const [
        ButtonSegment(
          value: true,
          icon: Icon(Icons.arrow_upward, size: 16),
          label: Text('昇順'),
        ),
        ButtonSegment(
          value: false,
          icon: Icon(Icons.arrow_downward, size: 16),
          label: Text('降順'),
        ),
      ],
      selected: {ascending},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}
