import 'package:flutter/material.dart';

import '../../core/theme/app_text.dart';

/// 空状態（絵文字48 ＋ メッセージ ＋ 補足 ＋ 任意のアクション。[STYLE_GUIDE §3.7]）。
///
/// 「未登録」と「絞り込みゼロ件」は必ず分岐させ、それぞれにアクションを添える。
class EmptyState extends StatelessWidget {
  final String emoji;
  final String message;
  final String? subMessage;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    this.emoji = '🔍',
    required this.message,
    this.subMessage,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppText.sectionTitle(),
            ),
            if (subMessage != null) ...[
              const SizedBox(height: 6),
              Text(
                subMessage!,
                textAlign: TextAlign.center,
                style: AppText.caption(),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
