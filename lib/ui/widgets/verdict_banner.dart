import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/database/app_database.dart';
import '../../domain/entities/spell_verdict.dart';

/// 「惜しい」のときに入力と正解を並べ、異なる文字だけを強調する
/// （[Docs/06_features/spell_mode.md] §3.3）。
class SpellDiffText extends StatelessWidget {
  final String input;
  final String answer;
  final List<int> diffIndexes;

  const SpellDiffText({
    super.key,
    required this.input,
    required this.answer,
    required this.diffIndexes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _row('あなた', input, const []),
        const SizedBox(height: 2),
        _row('正解', answer, diffIndexes),
      ],
    );
  }

  Widget _row(String label, String value, List<int> highlight) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.caption(color: AppColors.ink2),
          ),
        ),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                for (var i = 0; i < value.length; i++)
                  TextSpan(
                    text: value[i],
                    style: highlight.contains(i)
                        ? AppText.style(
                            size: 18,
                            weight: FontWeight.w800,
                            color: AppColors.nearMissText,
                          )
                        : AppText.style(size: 18, weight: FontWeight.w600),
                  ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// 解答後のフィードバック帯（[Docs/06_features/spell_mode.md] §4）。
///
/// 画面は遷移せず、この帯が下から重なる。**色だけで正誤を伝えない**ため、
/// 必ずアイコンと文言を添える。
class VerdictBanner extends StatelessWidget {
  final SpellVerdict verdict;
  final Word word;

  /// 添える例文。**学習中の単語帳の例文**を選んである
  /// （[Docs/03_data_model.md] §2.4「表示」）。無ければ null。
  final WordExample? example;

  /// 利用者が入力した綴り（「惜しい」の差分表示に使う）。
  final String typed;
  final VoidCallback onNext;

  /// 最後の問題なら「結果を見る」にする。
  final bool isLast;

  const VerdictBanner({
    super.key,
    required this.verdict,
    required this.word,
    required this.example,
    required this.typed,
    required this.onNext,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final (background, icon, label) = switch (verdict) {
      SpellCorrect() => (AppColors.correct, Icons.check, '正解'),
      SpellNearMiss() => (AppColors.nearMissFill, Icons.error_outline, '惜しい'),
      SpellWrong() => (AppColors.wrong, Icons.close, '不正解'),
    };

    return Material(
      color: AppColors.card,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: background,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.style(
                        size: 18,
                        weight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (verdict is SpellNearMiss) ...[
                    SpellDiffText(
                      input: typed,
                      answer: word.headword,
                      diffIndexes: (verdict as SpellNearMiss).diffIndexes,
                    ),
                    const SizedBox(height: 8),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              word.headword,
                              maxLines: 1,
                              style: AppText.style(
                                size: 24,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        if (word.phonetic != null) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              word.phonetic!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.phonetic(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  Text(
                    word.meaning,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(),
                  ),
                  // 例文が無い語では行ごと出さない。
                  if (example != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      example!.exampleEn,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.caption(color: AppColors.ink2),
                    ),
                    // 和訳が無い「出会った文」は英文だけを出す（§2.4）。
                    if (example!.exampleJa != null)
                      Text(
                        example!.exampleJa!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.caption(),
                      ),
                  ],
                  const SizedBox(height: 12),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: onNext,
                    child: Text(isLast ? '結果を見る' : '次へ'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
