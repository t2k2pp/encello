import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// 破壊的操作（削除・全置換など）の前に出す共通確認ダイアログ（[STYLE_GUIDE §4.3]）。
/// 画面ごとに独自実装せず、文言と見た目を一貫させる。
///
/// 確定で `true`、キャンセル/閉じるで `false` を返す。
Future<bool> confirmDestructive(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = '削除',
  String cancelLabel = 'キャンセル',
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(child: Text(message)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(foregroundColor: AppColors.accentDeep),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// 参照されているデータを消そうとしたときの「削除できません」ダイアログ
/// （閉じるのみ。[STYLE_GUIDE §4.3]）。確定後に失敗させないため、
/// 確認より**前**に判定してこれを出す。
Future<void> showCannotDelete(
  BuildContext context, {
  required String title,
  required String message,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(child: Text(message)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('閉じる'),
        ),
      ],
    ),
  );
}
