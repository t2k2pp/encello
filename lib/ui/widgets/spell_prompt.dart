import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/enums.dart';
import '../../data/database/app_database.dart';
import 'letter_tiles.dart';

/// 綴りを入力させる出題本体（[Docs/06_features/spell_mode.md] §1・§2.5）。
///
/// スペル / リスニング / 語形変化（SCR-03・SCR-04）と、フラッシュカードの
/// スペル形式の確認テスト（[Docs/06_features/flashcard_mode.md] §4）が同じものを使う。
/// 入力そのものは [EnglishKeyboard]、判定は `SpellJudge` が持ち、ここは描画だけ。
class SpellPrompt extends StatelessWidget {
  final Word word;

  /// 出題文（和訳、または語形変化の差し替え文）。null なら伏せる（リスニング）。
  final String? prompt;

  /// 出題文に添える指示（「名詞形にしなさい」）。無ければ null。
  final String? instruction;

  /// 品詞バッジを出すか。リスニングは音から綴りを起こさせるので出さない。
  final bool showPartOfSpeech;

  /// 出題文の上に差し込む部品（リスニングの再生ボタン）。
  final Widget? header;

  /// 補助操作の行に足すボタン（リスニングの「訳を見る」）。
  final List<Widget> extraActions;

  final String typed;
  final int hintUsed;

  /// 解答前か（補助操作を出すかどうか）。
  final bool answering;

  final bool canHint;
  final VoidCallback onHint;

  /// 「わからない」。押せないときは null。
  final VoidCallback? onGiveUp;

  const SpellPrompt({
    super.key,
    required this.word,
    required this.prompt,
    required this.typed,
    required this.hintUsed,
    required this.answering,
    required this.canHint,
    required this.onHint,
    required this.onGiveUp,
    this.instruction,
    this.showPartOfSpeech = true,
    this.header,
    this.extraActions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        if (showPartOfSpeech)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.chipBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              PartOfSpeech.fromValue(word.partOfSpeech).label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.caption(color: AppColors.ink2),
            ),
          ),
        if (header != null) ...[
          const SizedBox(height: 8),
          header!,
          const SizedBox(height: 8),
        ],
        if (prompt != null) ...[
          const SizedBox(height: 12),
          // 長い和訳でも1行に収める。
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              prompt!,
              textAlign: TextAlign.center,
              style: AppText.prompt(),
            ),
          ),
          if (instruction != null) ...[
            const SizedBox(height: 6),
            Text(
              instruction!,
              textAlign: TextAlign.center,
              style: AppText.body(color: AppColors.ink2),
            ),
          ],
        ],
        const SizedBox(height: 24),
        LetterTiles(
          answer: word.headword,
          typed: typed,
          revealedCount: hintUsed,
        ),
        const SizedBox(height: 20),
        if (answering)
          // ボタンは可変長ラベルの並びなので `Wrap` にする（STYLE_GUIDE §7）。
          // リスニングでは「訳を見る」が加わって3つになり、狭い端末では
          // 1行に収まらない。
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              TextButton.icon(
                onPressed: canHint ? onHint : null,
                icon: const Icon(Icons.lightbulb_outline, size: 18),
                label: Text(hintUsed == 0 ? 'ヒント' : 'ヒント ($hintUsed)'),
              ),
              ...extraActions,
              TextButton(
                onPressed: onGiveUp,
                child: const Text('わからない'),
              ),
            ],
          ),
      ],
    );
  }
}
