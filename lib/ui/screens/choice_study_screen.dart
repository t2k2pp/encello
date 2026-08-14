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

  /// 問題を出す前のカウントダウン（スピードのみ）。
  Timer? _countdownTimer;

  /// カウントダウンの残り。null なら数えていない（＝問題が見えている）。
  int? _countdown;

  int? _armedIndex;

  /// セッションの最初だけ長めに数える。いきなり1問目が出ると身構える間が無い。
  static const _firstCountdown = 3;

  /// 問題と問題のあいだの合図。ここも3秒数えると50問で2分半が待ち時間になり、
  /// 「見た瞬間に意味が出てくる速さ」を鍛えるという目的が壊れる（§2.1）。
  static const _betweenCountdown = 1;

  @override
  void dispose() {
    _limit?.dispose();
    _flashTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  /// スピードは、カウントダウンを挟んでから問題を出す。
  ///
  /// 数え終わるまで問題は隠す。見せたまま数えると、そのぶんが考える時間になり、
  /// 反応時間が測れなくなる（§2.1）。
  void _armQuestion(ChoiceSessionState session) {
    if (session.mode != StudyMode.speed) return;
    if (_armedIndex == session.index) return;
    _armedIndex = session.index;

    _countdownTimer?.cancel();
    _tickCountdown(
      session,
      session.index == 0 ? _firstCountdown : _betweenCountdown,
    );
  }

  /// 残り [remaining] 秒から1秒ずつ数える。0 になったら問題を見せて計測を始める。
  void _tickCountdown(ChoiceSessionState session, int remaining) {
    setState(() => _countdown = remaining);
    _countdownTimer = Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      final current = ref.read(choiceSessionProvider);
      if (current == null ||
          current.phase != StudyPhase.presenting ||
          current.index != session.index) {
        return;
      }
      if (remaining > 1) {
        _tickCountdown(session, remaining - 1);
        return;
      }
      setState(() => _countdown = null);
      // 問題が見えた瞬間を反応時間の起点にする。
      ref.read(choiceSessionProvider.notifier).markPresented();
      _armLimit(session);
    });
  }

  /// 制限時間を計り始める。時間切れも `Judging` を通す（記録は残す）。
  void _armLimit(ChoiceSessionState session) {
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
        if (mounted) _armQuestion(session);
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
                  // 残り時間はバーと数字の両方で出す。バーだけだと、あとどれだけ
                  // 猶予があるのかが読み取れず、時間切れが不意打ちになる（§2.1）。
                  if (session.mode == StudyMode.speed &&
                      _limit != null &&
                      _countdown == null)
                    _RemainingTime(limit: _limit!),
                  Expanded(
                    child: _countdown != null
                        // 数え終わるまで問題は見せない。見せたまま数えると、
                        // そのぶんが考える時間になり反応時間が測れない。
                        ? _Countdown(value: _countdown!)
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: ChoiceQuestionView(
                              question: question,
                              selectedIndex: session.selectedIndex,
                              answered: answered,
                              onSelect: answered || session.busy
                                  ? null
                                  : _answer,
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

/// 問題を出す前のカウントダウン（スピードのみ）。
///
/// 数字だけを大きく置き、問題は隠す。**次が来ることが分かってから始まる**という
/// 一点のためにあるので、余計な文言は添えない
/// （[Docs/06_features/speed_mode.md] §2.1）。
class _Countdown extends StatelessWidget {
  final int value;

  const _Countdown({required this.value});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('つぎの問題', style: AppText.caption()),
          const SizedBox(height: 8),
          Text(
            '$value',
            // 数字そのものが合図なので、端末の文字拡大では動かさない。
            textScaler: TextScaler.noScaling,
            style: AppText.style(
              size: 72,
              weight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

/// 制限時間の残り（バー＋秒数）。
///
/// 秒数は切り上げで出す。「1」が見えているあいだは1秒未満でも残っている、
/// という読み方で揃える（0 を見せてから時間切れになると、数字が嘘になる）。
class _RemainingTime extends StatelessWidget {
  final AnimationController limit;

  const _RemainingTime({required this.limit});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: limit,
      builder: (context, _) {
        final left = limit.duration! * (1 - limit.value);
        final seconds = (left.inMilliseconds / 1000).ceil();
        // 残り1秒を切ったら色を変える。点滅はさせない（急かしすぎる）。
        final urgent = seconds <= 1;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 2),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'あと $seconds 秒',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption(
                    color: urgent ? AppColors.wrong : AppColors.ink2,
                  ),
                ),
              ),
            ),
            LinearProgressIndicator(
              value: 1 - limit.value,
              minHeight: 4,
              backgroundColor: AppColors.line,
              color: urgent ? AppColors.wrong : AppColors.accent,
            ),
          ],
        );
      },
    );
  }
}
