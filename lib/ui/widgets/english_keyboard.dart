import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/enums.dart';

/// アプリ内英字キーボード（[Docs/06_features/spell_mode.md] §2）。
///
/// **OS のキーボードを一切使わない。** `TextField` に `autocorrect: false` を
/// 指定しても Android の一部 IME は変換候補バーを出し、`app` まで打った時点で
/// `apple` が候補に出てしまう。OS の入力欄を使わないことが、これを確実に防ぐ唯一の方法。
///
/// フォーカスもテキスト選択もカーソルも無い。文字は常に末尾に追加され、⌫ で末尾から消える。
/// 物理キーボード（iPad の外付け等）からの a–z / Backspace / Enter も同じ入口へ流す。
class EnglishKeyboard extends StatefulWidget {
  final KeyboardLayout layout;
  final ValueChanged<String> onKey;
  final VoidCallback onBackspace;

  /// 「答え合わせ」。null のときは無効化する（未入力のとき）。
  final VoidCallback? onSubmit;
  final String submitLabel;

  const EnglishKeyboard({
    super.key,
    required this.layout,
    required this.onKey,
    required this.onBackspace,
    required this.onSubmit,
    this.submitLabel = '答え合わせ',
  });

  /// 配列ごとの段構成。ハイフン・アポストロフィ・スペースのキーは置かない
  /// （記号はアプリ側が最初から表示する）。
  static const rows = <KeyboardLayout, List<String>>{
    KeyboardLayout.qwerty: ['qwertyuiop', 'asdfghjkl', 'zxcvbnm'],
    KeyboardLayout.abc: ['abcdefghij', 'klmnopqrs', 'tuvwxyz'],
  };

  @override
  State<EnglishKeyboard> createState() => _EnglishKeyboardState();
}

class _EnglishKeyboardState extends State<EnglishKeyboard> {
  final _focusNode = FocusNode();
  Timer? _backspaceRepeat;

  @override
  void initState() {
    super.initState();
    // 物理キーボードからの入力を拾うため、自分でフォーカスを持つ。
    // 画面上のキーボードは表示したままにする。
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _backspaceRepeat?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handlePhysicalKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      widget.onBackspace();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      widget.onSubmit?.call();
      return KeyEventResult.handled;
    }
    final character = event.character?.toLowerCase();
    if (character != null &&
        character.length == 1 &&
        RegExp('[a-z]').hasMatch(character)) {
      widget.onKey(character);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _startBackspaceRepeat() {
    widget.onBackspace();
    // 長押しで連続削除。0文字になったら呼び出し側が何もしないだけなので、
    // ここでは指を離すまで刻み続ける。
    _backspaceRepeat = Timer.periodic(
      const Duration(milliseconds: 60),
      (_) => widget.onBackspace(),
    );
  }

  void _stopBackspaceRepeat() {
    _backspaceRepeat?.cancel();
    _backspaceRepeat = null;
  }

  @override
  Widget build(BuildContext context) {
    final rows = EnglishKeyboard.rows[widget.layout]!;
    final media = MediaQuery.of(context);
    // 高さは画面高の 30〜36%。文字拡大では伸ばさない（キー高さの下限で担保する）。
    final keyboardHeight = (media.size.height * 0.33).clamp(
      media.size.height * 0.30,
      media.size.height * 0.36,
    );

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handlePhysicalKey,
      child: Container(
        color: AppColors.bg,
        padding: const EdgeInsets.fromLTRB(4, 6, 4, 8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // キー幅は幅から10列で等分する。下限を設けないことで 320dp でも収まる。
            final keyWidth = (constraints.maxWidth - 8) / 10;
            // 3段ぶんの高さ。最小タップ領域 44dp を下回らせない（NFR-06）。
            final keyHeight = ((keyboardHeight - 60) / 3).clamp(44.0, 64.0);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < rows.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (final ch in rows[i].split(''))
                          _Key(
                            label: ch,
                            width: keyWidth - 4,
                            height: keyHeight,
                            onTap: () => widget.onKey(ch),
                          ),
                        // ⌫ は最下段の右端に置く。
                        if (i == rows.length - 1)
                          _Key(
                            label: '⌫',
                            width: keyWidth * 1.5 - 4,
                            height: keyHeight,
                            semanticLabel: '1文字消す',
                            onTap: widget.onBackspace,
                            onLongPressStart: _startBackspaceRepeat,
                            onLongPressEnd: _stopBackspaceRepeat,
                          ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: widget.onSubmit,
                    child: Text(widget.submitLabel),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// キー1つ。押下で 80ms の `scale 0.94` ＋ 触覚フィードバック。
class _Key extends StatefulWidget {
  final String label;
  final double width;
  final double height;
  final VoidCallback onTap;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;
  final String? semanticLabel;

  const _Key({
    required this.label,
    required this.width,
    required this.height,
    required this.onTap,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.semanticLabel,
  });

  @override
  State<_Key> createState() => _KeyState();
}

class _KeyState extends State<_Key> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    // 端末の文字拡大に追従させると10列が破綻するため、キーラベルだけは
    // textScaler を 1.0 に固定する（[Docs/05_design_system.md] §3.3）。
    // 代わりにキー高さを下限44dpで確保している。
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      button: true,
      label: widget.semanticLabel ?? widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          _setPressed(true);
          HapticFeedback.selectionClick();
        },
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        onLongPressStart: widget.onLongPressStart == null
            ? null
            : (_) => widget.onLongPressStart!(),
        onLongPressEnd: widget.onLongPressEnd == null
            ? null
            : (_) => widget.onLongPressEnd!(),
        child: AnimatedScale(
          scale: _pressed ? 0.94 : 1.0,
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 80),
          curve: Curves.easeOut,
          child: Container(
            width: widget.width,
            height: widget.height,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _pressed ? AppColors.accentSoft : AppColors.card,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              widget.label,
              textScaler: TextScaler.noScaling,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
