import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

/// 絵文字をボトムシートで選び、選択された絵文字（String）を返す（[STYLE_GUIDE §4.4]）。
Future<String?> pickEmoji(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    builder: (ctx) => SizedBox(
      height: 320,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) => Navigator.pop(ctx, emoji.emoji),
        config: const Config(height: 320, checkPlatformCompatibility: true),
      ),
    ),
  );
}
