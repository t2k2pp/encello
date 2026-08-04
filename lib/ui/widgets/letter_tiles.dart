import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/usecases/spell_slots.dart';

/// 綴り入力の文字タイル（[Docs/05_design_system.md] §3.2）。
///
/// 表示専用（`TextField` ではない）。入力済みは `ink` の文字＋`accent` の下線、
/// 未入力は `line` の下線。ヒントで開示した文字は `accentSoft` の背景で示す。
/// 文字数が多いときは `Wrap` で折り返す（横スクロールにしない）。
class LetterTiles extends StatelessWidget {
  final String answer;
  final String typed;

  /// ヒントで開示した先頭からの文字数。
  final int revealedCount;

  const LetterTiles({
    super.key,
    required this.answer,
    required this.typed,
    this.revealedCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final slots = SpellSlots.slotsOf(answer, typed);
    var letterIndex = 0;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 8,
      children: [
        for (final slot in slots)
          if (slot.isSymbol)
            _SymbolTile(symbol: slot.character!)
          else
            _LetterTile(
              character: slot.character,
              revealed: letterIndex++ < revealedCount,
            ),
      ],
    );
  }
}

class _LetterTile extends StatelessWidget {
  final String? character;
  final bool revealed;

  const _LetterTile({required this.character, required this.revealed});

  @override
  Widget build(BuildContext context) {
    final filled = character != null;
    return Container(
      width: 28,
      padding: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: revealed ? AppColors.accentSoft : null,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        border: Border(
          bottom: BorderSide(
            color: filled ? AppColors.accent : AppColors.line,
            width: 2,
          ),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        character ?? ' ',
        // 端末の文字拡大に追従させると 28px 幅の枠から溢れるため固定する。
        textScaler: TextScaler.noScaling,
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

/// ハイフン・スペース・アポストロフィなど、最初から見せる記号の枠。
class _SymbolTile extends StatelessWidget {
  final String symbol;

  const _SymbolTile({required this.symbol});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: symbol == ' ' ? 14 : 18,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          symbol,
          textAlign: TextAlign.center,
          textScaler: TextScaler.noScaling,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.ink3,
          ),
        ),
      ),
    );
  }
}
