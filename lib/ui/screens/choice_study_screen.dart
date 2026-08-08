import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/choice_session_controller.dart';
import '../../application/study_session_controller.dart' show StudyPhase;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/enums.dart';
import '../../providers/providers.dart';
import '../dialogs/confirm_dialog.dart';
import '../widgets/soft_card.dart';
import 'session_result_screen.dart';

/// SCR-06 4択クイズ / SCR-19 スピード / SCR-20 語のつくり / SCR-21 取り違えドリル。
///
/// 4つのモードは描画も進行も同じ形なので1つの画面で扱う。差分は
/// **制限時間の有無**（スピード）と**選択肢の数**（取り違えは2択）だけ。
class ChoiceStudyScreen extends ConsumerStatefulWidget {
  const ChoiceStudyScreen({super.key});

  @override
  ConsumerState<ChoiceStudyScreen> createState() => _ChoiceStudyScreenState();
}

class _ChoiceStudyScreenState extends ConsumerState<ChoiceStudyScreen>
    with SingleTickerProviderStateMixin {
  /// 制限時間のバーを動かすコントローラ（スピードのみ）。
  AnimationController? _limit;

  /// 正誤のフラッシュ後に自動で進むタイマー（スピードのみ）。
  Timer? _flashTimer;

  int? _armedIndex;

  @override
  void dispose() {
    _limit?.dispose();
    _flashTimer?.cancel();
    super.dispose();
  }

  /// スピードは制限時間つき。時間切れも `Judging` を通す（記録は残す）。
  void _armLimit(ChoiceSessionState session) {
    if (session.mode != StudyMode.speed) return;
    if (_armedIndex == session.index) return;
    _armedIndex = session.index;

    _limit?.dispose();
    final controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: session.profile.speedLimitMs),
    );
    _limit = controller;
    controller.forward().whenComplete(() {
      if (!mounted) return;
      final current = ref.read(choiceSessionProvider);
      if (current == null) return;
      if (current.phase != StudyPhase.presenting) return;
      if (current.index != session.index) return;
      unawaited(_answer(null, timedOut: true));
    });
  }

  Future<void> _answer(int? index, {bool timedOut = false}) async {
    _limit?.stop();
    try {
      await ref
          .read(choiceSessionProvider.notifier)
          .answer(index, timedOut: timedOut);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('解答を保存できませんでした: $e')));
      return;
    }
    // スピードは0.4秒の色フラッシュだけで次へ進む。1問ずつ止まると
    // 流暢性の訓練にならない（[Docs/06_features/speed_mode.md] §2）。
    if (mounted && ref.read(choiceSessionProvider)?.mode == StudyMode.speed) {
      _flashTimer?.cancel();
      _flashTimer = Timer(const Duration(milliseconds: 400), () {
        if (mounted) ref.read(choiceSessionProvider.notifier).next();
      });
    }
  }

  Future<void> _confirmAbort(ChoiceSessionState session) async {
    final ok = await confirmDestructive(
      context,
      title: '学習を中断しますか',
      message: session.answeredCount == 0
          ? 'まだ1問も解いていません。中断してホームへ戻ります。'
          : 'ここまでの${session.answeredCount}問は記録に残ります。中断してホームへ戻ります。',
      confirmLabel: '中断する',
      cancelLabel: '続ける',
    );
    if (!ok || !mounted) return;
    await ref.read(sessionFinalizerProvider).abort(session.sessionId);
    if (!mounted) return;
    ref.read(choiceSessionProvider.notifier).clear();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(choiceSessionProvider);
    if (session == null) return const Scaffold(body: SizedBox.shrink());

    if (session.phase == StudyPhase.finished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => SessionResultScreen(sessionId: session.sessionId),
          ),
        );
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    if (session.phase == StudyPhase.presenting) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _armLimit(session);
      });
    }

    final question = session.current!;
    final answered = session.phase == StudyPhase.feedback;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmAbort(session);
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: '学習を中断する',
                          onPressed: () => _confirmAbort(session),
                        ),
                        Expanded(
                          child: Text(
                            '${session.index + 1} / ${session.totalCount}',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.caption(),
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  // 残り時間は細いバーだけ。数字のカウントダウンは出さず、
                  // 点滅・色変化もさせない（急かしすぎない）。
                  if (session.mode == StudyMode.speed && _limit != null)
                    AnimatedBuilder(
                      animation: _limit!,
                      builder: (context, _) => LinearProgressIndicator(
                        value: 1 - _limit!.value,
                        minHeight: 4,
                        backgroundColor: AppColors.line,
                        color: AppColors.accent,
                      ),
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          if (question.hint != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
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
                              state: _stateOf(session, question, i),
                              onTap: answered || session.busy
                                  ? null
                                  : () => _answer(i),
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
                                        style: AppText.caption(
                                          color: AppColors.ink2,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  // スピードはフィードバック帯を挟まず自動で進む。
                  if (answered && session.mode != StudyMode.speed)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: ref
                            .read(choiceSessionProvider.notifier)
                            .next,
                        child: Text(session.isLast ? '結果を見る' : '次へ'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _OptionState _stateOf(
    ChoiceSessionState session,
    ChoiceQuestion question,
    int index,
  ) {
    if (session.phase != StudyPhase.feedback) return _OptionState.idle;
    if (index == question.answerIndex) return _OptionState.correct;
    if (index == session.selectedIndex) return _OptionState.wrong;
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
