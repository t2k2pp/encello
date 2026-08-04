import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/study_session_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/enums.dart';
import '../../data/database/app_database.dart';
import '../../domain/entities/spell_verdict.dart';
import '../../providers/providers.dart';
import '../dialogs/confirm_dialog.dart';
import '../widgets/english_keyboard.dart';
import '../widgets/letter_tiles.dart';
import '../widgets/verdict_banner.dart';
import 'session_result_screen.dart';

/// SCR-03 スペル学習（[Docs/04_screens_and_flows.md] §4.3）。
///
/// **この画面に `EditableText`（= `TextField`）を1つも置かない。**
/// 入力は [EnglishKeyboard] と `StudySessionController.typed` だけで完結する
/// （[Docs/06_features/spell_mode.md] §2.1）。
///
/// 学習画面は `CenteredContent` を使わず、最大幅 720 とする。キーボードが中央に
/// 浮くと押しにくいため（[Docs/05_design_system.md] §4）。
class SpellStudyScreen extends ConsumerStatefulWidget {
  const SpellStudyScreen({super.key});

  @override
  ConsumerState<SpellStudyScreen> createState() => _SpellStudyScreenState();
}

class _SpellStudyScreenState extends ConsumerState<SpellStudyScreen> {
  Timer? _autoNext;

  @override
  void dispose() {
    _autoNext?.cancel();
    super.dispose();
  }

  /// 正解のときだけ、設定「正解したら自動で次へ」に従って 1.2 秒後に進む。
  /// 「惜しい」「不正解」は設定に関わらず必ずタップで進む（見る時間が要る）。
  void _scheduleAutoNext(StudySessionState session) {
    _autoNext?.cancel();
    if (!session.profile.autoNextOnCorrect) return;
    if (session.verdict is! SpellCorrect) return;
    _autoNext = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) ref.read(studySessionProvider.notifier).next();
    });
  }

  Future<void> _confirmAbort(StudySessionState session) async {
    // すでに解答した分は保存済みなので破棄されない。
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
    ref.read(studySessionProvider.notifier).clear();
    Navigator.of(context).pop();
  }

  Future<void> _submit() async {
    try {
      await ref.read(studySessionProvider.notifier).submit();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('解答を保存できませんでした: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(studySessionProvider);
    if (session == null) {
      // 結果画面へ移ったあとに一瞬だけ通る。
      return const Scaffold(body: SizedBox.shrink());
    }

    if (session.phase == StudyPhase.finished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => SessionResultScreen(sessionId: session.sessionId),
          ),
        );
      });
      // 差し替えは次のフレームで起きる。ここに回り続けるインジケータを置かない
      // （1フレームしか見えないうえ、ウィジェットテストが収束しなくなる）。
      return const Scaffold(body: SizedBox.shrink());
    }

    if (session.phase == StudyPhase.feedback) _scheduleAutoNext(session);

    final word = session.currentWord!;
    return PopScope(
      // ✕ と同じ確認を、端末の戻る操作でも通す。
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
                  _ProgressBar(
                    session: session,
                    onAbort: () => _confirmAbort(session),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: _Question(session: session, word: word),
                    ),
                  ),
                  if (session.phase == StudyPhase.feedback)
                    VerdictBanner(
                      verdict: session.verdict!,
                      word: word,
                      typed: session.submittedText,
                      isLast: session.isLastQuestion,
                      onNext: () {
                        _autoNext?.cancel();
                        ref.read(studySessionProvider.notifier).next();
                      },
                    )
                  else
                    EnglishKeyboard(
                      layout: KeyboardLayout.fromValue(
                        session.profile.keyboardLayout,
                      ),
                      onKey: ref.read(studySessionProvider.notifier).typeLetter,
                      onBackspace:
                          ref.read(studySessionProvider.notifier).backspace,
                      onSubmit: session.canSubmit ? _submit : null,
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

/// 上部の進捗（✕ / ドット / 「4/10」）。
class _ProgressBar extends StatelessWidget {
  final StudySessionState session;
  final VoidCallback onAbort;

  const _ProgressBar({required this.session, required this.onAbort});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: '学習を中断する',
            onPressed: onAbort,
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: session.totalCount == 0
                    ? 0
                    : session.index / session.totalCount,
                minHeight: 6,
                backgroundColor: AppColors.line,
                color: AppColors.accent,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${session.index + 1} / ${session.totalCount}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.caption(),
          ),
        ],
      ),
    );
  }
}

/// 出題（品詞バッジ・和訳・文字タイル・補助操作）。
class _Question extends ConsumerWidget {
  final StudySessionState session;
  final Word word;

  const _Question({required this.session, required this.word});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(studySessionProvider.notifier);
    final answering = session.phase == StudyPhase.presenting;

    return Column(
      children: [
        const SizedBox(height: 8),
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
        const SizedBox(height: 12),
        // 長い和訳でも1行に収める。
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            word.meaning,
            textAlign: TextAlign.center,
            style: AppText.prompt(),
          ),
        ),
        const SizedBox(height: 24),
        LetterTiles(
          answer: word.headword,
          typed: session.typed,
          revealedCount: session.hintUsed,
        ),
        const SizedBox(height: 20),
        if (answering)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: session.canHint ? notifier.hint : null,
                icon: const Icon(Icons.lightbulb_outline, size: 18),
                label: Text(
                  session.hintUsed == 0 ? 'ヒント' : 'ヒント (${session.hintUsed})',
                ),
              ),
              TextButton(
                onPressed: session.busy ? null : notifier.giveUp,
                child: const Text('わからない'),
              ),
            ],
          ),
      ],
    );
  }
}
