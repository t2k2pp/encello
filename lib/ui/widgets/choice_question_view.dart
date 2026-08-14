import 'package:flutter/material.dart';

import '../../application/choice_session_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import 'soft_card.dart';

/// 選択式の1問の描画（[Docs/06_features/quiz_mode.md] §3・§4）。
///
/// 4択・スピード・語のつくり・取り違え（SCR-06 / 19 / 20 / 21）と、
/// フラッシュカードの確認テスト（[Docs/06_features/flashcard_mode.md] §4）が
/// 同じものを使う。問題の組み立てと記録は呼び出し側が持ち、ここは描画だけを持つ。
class ChoiceQuestionView extends StatelessWidget {
  final ChoiceQuestion question;

  /// 選んだ選択肢の位置。未解答なら null。
  final int? selectedIndex;

  /// 解答が確定しているか（正誤の色とアイコンを出す）。
  final bool answered;

  /// 選択肢のタップ。null なら選べない。
  final ValueChanged<int>? onSelect;

  const ChoiceQuestionView({
    super.key,
    required this.question,
    required this.selectedIndex,
    required this.answered,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        if (question.hint != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.chipBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              question.hint!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppText.caption(color: AppColors.ink2),
            ),
          ),
        const SizedBox(height: 12),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            question.prompt,
            textAlign: TextAlign.center,
            style: AppText.prompt(),
          ),
        ),
        const SizedBox(height: 20),
        for (var i = 0; i < question.options.length; i++) ...[
          _Option(
            label: question.options[i],
            state: _stateOf(i),
            onTap: onSelect == null ? null : () => onSelect!(i),
          ),
          const SizedBox(height: 8),
        ],
        if (answered && question.explanation.isNotEmpty) ...[
          const SizedBox(height: 4),
          SoftCard(
            color: AppColors.chipBg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final line in question.explanation)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      line,
                      style: AppText.caption(color: AppColors.ink2),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  _OptionState _stateOf(int index) {
    if (!answered) return _OptionState.idle;
    if (index == question.answerIndex) return _OptionState.correct;
    if (index == selectedIndex) return _OptionState.wrong;
    return _OptionState.idle;
  }
}

enum _OptionState { idle, correct, wrong }

/// 選択肢1つ。高さは内容に応じて伸びる（固定しない）。
/// **色だけで正誤を伝えない**ため、必ずアイコンを添える。
class _Option extends StatelessWidget {
  final String label;
  final _OptionState state;
  final VoidCallback? onTap;

  const _Option({required this.label, required this.state, this.onTap});

  @override
  Widget build(BuildContext context) {
    final (border, icon, iconColor) = switch (state) {
      _OptionState.idle => (AppColors.line, null, null),
      _OptionState.correct => (
        AppColors.correct,
        Icons.check,
        AppColors.correctText,
      ),
      _OptionState.wrong => (AppColors.wrong, Icons.close, AppColors.wrong),
    };

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: border,
          width: state == _OptionState.idle ? 1 : 2,
        ),
      ),
      child: SoftCard(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppText.body(),
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(icon, size: 20, color: iconColor),
            ],
          ],
        ),
      ),
    );
  }
}
