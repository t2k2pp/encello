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
import '../widgets/choice_question_view.dart';
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
                      child: ChoiceQuestionView(
                        question: question,
                        selectedIndex: session.selectedIndex,
                        answered: answered,
                        onSelect: answered || session.busy ? null : _answer,
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

}
