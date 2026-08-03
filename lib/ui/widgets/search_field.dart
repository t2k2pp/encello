import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import 'soft_card.dart';

/// 一覧画面の検索バー（[STYLE_GUIDE §3.2]）。
///
/// `SoftCard` の中にボーダーレスの `TextField` を置き、入力があるときだけ
/// × クリアボタンを出す。provider と往復してもカーソルが飛ばないよう、
/// 外から来た値だけを `didUpdateWidget` で同期する。
class SearchField extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final String hintText;

  const SearchField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.hintText,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );

  @override
  void didUpdateWidget(covariant SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // provider 側で値が変わった場合のみ同期。ユーザー入力由来の往復では
    // カーソルを動かさない。
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: Row(
        children: [
          Icon(Icons.search, size: 18, color: AppColors.ink3),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: widget.onChanged,
              controller: _controller,
              style: AppText.body(),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: widget.hintText,
                hintStyle: AppText.body(color: AppColors.ink3),
              ),
            ),
          ),
          if (widget.value.isNotEmpty)
            GestureDetector(
              onTap: () {
                _controller.clear();
                widget.onChanged('');
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(Icons.close, size: 18, color: AppColors.ink3),
              ),
            ),
        ],
      ),
    );
  }
}
