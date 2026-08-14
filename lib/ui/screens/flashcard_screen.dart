import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../application/flashcard_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/enums.dart';
import '../../domain/services/pronunciation_service.dart';
import '../../providers/audio.dart';
import '../../providers/providers.dart';
import '../widgets/choice_question_view.dart';
import '../widgets/english_keyboard.dart';
import '../widgets/soft_card.dart';
import '../widgets/spell_prompt.dart';
import '../widgets/verdict_banner.dart';
import 'session_result_screen.dart';

/// SCR-05 フラッシュカード（[Docs/04_screens_and_flows.md] §4.4、
/// [Docs/06_features/flashcard_mode.md]）。
///
/// 「N枚の流し見 → その N語の確認テスト」を繰り返す。カードは表裏を持たず、
/// 上下を同時に表示する。めくる操作を挟むと「次々に流して浴びる」という目的が
/// 損なわれる。**流し見の側に自己評価ボタンは置かない**。覚えたかどうかは
/// 確認テストが判定する（[flashcard_mode.md] §3）。
class FlashcardScreen extends ConsumerStatefulWidget {
  const FlashcardScreen({super.key});

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen> {
  Timer? _silentTimer;

  /// いま送りの処理を仕掛けたカード。同じカードで二重に仕掛けない。
  int? _scheduledIndex;

  /// 画面を離れるときに音を止めるための読み上げサービス。
  ///
  /// `dispose()` から `ref` を読むと riverpod 3 が例外を投げる（`BuildContext` が
  /// すでに無効なため）。解決済みのサービスを [build] のたびにここへ控えておき、
  /// 後片付けでは `ref` に触れない（[Docs/07_testing_strategy.md] §4）。
  PronunciationService? _pronunciation;

  @override
  void initState() {
    super.initState();
    // 自動送り中に画面を消灯させない（NFR-10）。
    unawaited(WakelockPlus.enable());
  }

  @override
  void dispose() {
    _silentTimer?.cancel();
    // 画面を離れたら必ず解除し、鳴っている音も止める。
    unawaited(WakelockPlus.disable());
    unawaited(_pronunciation?.stop() ?? Future<void>.value());
    super.dispose();
  }

  /// 現在のカードの送りを仕掛ける。無音モードはタイマー、読み上げモードは再生の完了。
  void _schedule(FlashcardState session) {
    if (_scheduledIndex == session.index) return;
    _scheduledIndex = session.index;
    _silentTimer?.cancel();

    final lang = session.speakLang;
    if (lang == null) {
      _silentTimer = Timer(
        Duration(seconds: session.profile.flashcardSeconds),
        () {
          if (mounted && _isRunning()) {
            ref.read(flashcardProvider.notifier).advance();
          }
        },
      );
      return;
    }
    unawaited(_speakThenAdvance(session, lang));
  }

  bool _isRunning() =>
      ref.read(flashcardProvider)?.phase == FlashcardPhase.showing;

  /// 読み上げの**完了**を送りの契機にする。固定秒のタイマーで代用しない。
  Future<void> _speakThenAdvance(
    FlashcardState session,
    SpeechLang lang,
  ) async {
    final service = ref.read(pronunciationProvider(session.profile)).value;
    final word = session.currentWord;
    if (service == null || word == null) return;
    try {
      await service.speakWord(
        wordId: word.id,
        headword: lang == SpeechLang.en ? word.headword : word.meaning,
        lang: lang,
      );
    } catch (e) {
      // 無音のまま自動送りを続けない。別の音源へ切り替えもしない。
      if (mounted) ref.read(flashcardProvider.notifier).halt('$e');
      return;
    }
    if (mounted && _isRunning()) {
      ref.read(flashcardProvider.notifier).advance();
    }
  }

  void _close() {
    ref.read(flashcardProvider.notifier).clear();
    Navigator.of(context).pop();
  }

  void _finish(FlashcardState session) {
    ref.read(flashcardProvider.notifier).clear();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => SessionResultScreen(sessionId: session.sessionId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(flashcardProvider);
    if (session == null) return const Scaffold(body: SizedBox.shrink());
    _pronunciation = ref.watch(pronunciationProvider(session.profile)).value;

    if (session.phase == FlashcardPhase.finished) {
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

    if (session.phase == FlashcardPhase.halted) {
      _silentTimer?.cancel();
      return _HaltedView(reason: session.haltReason ?? '', onClose: _close);
    }

    if (session.phase == FlashcardPhase.showing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _schedule(session);
      });
    } else {
      _silentTimer?.cancel();
      _scheduledIndex = null;
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: session.phase == FlashcardPhase.testing
                ? _RoundTest(session: session, onFinish: () => _finish(session))
                : _CardView(session: session, onFinish: () => _finish(session)),
          ),
        ),
      ),
    );
  }
}

/// 流し見のカード（上下を同時に表示する）。
class _CardView extends ConsumerWidget {
  final FlashcardState session;
  final VoidCallback onFinish;

  const _CardView({required this.session, required this.onFinish});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(flashcardProvider.notifier);
    final word = session.currentWord!;
    final top = session.topLang == SpeechLang.en ? word.headword : word.meaning;
    final bottom = session.topLang == SpeechLang.en
        ? word.meaning
        : word.headword;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: '学習を終える',
                onPressed: onFinish,
              ),
              Expanded(
                child: Text(
                  '${session.index + 1} / ${session.totalCount}'
                  '（${session.roundNumber}/${session.roundTotal} ラウンド）',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption(),
                ),
              ),
              IconButton(
                icon: Icon(
                  session.phase == FlashcardPhase.paused
                      ? Icons.play_arrow
                      : Icons.pause,
                ),
                tooltip: session.phase == FlashcardPhase.paused
                    ? '再開する'
                    : '一時停止する',
                onPressed: notifier.togglePause,
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SoftCard(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          top,
                          textAlign: TextAlign.center,
                          style: AppText.style(
                            size: 28,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Divider(color: AppColors.line),
                      const SizedBox(height: 12),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          bottom,
                          textAlign: TextAlign.center,
                          style: AppText.style(
                            size: 22,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (word.phonetic != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          word.phonetic!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.phonetic(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // 移動はラウンドの中だけ。またぐと確認テストの対象が
        // 「そのラウンドで見せた語」でなくなる。
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                tooltip: '前のカード',
                onPressed: session.index == session.roundStart
                    ? null
                    : () => notifier.moveBy(-1),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                tooltip: session.isRoundEnd ? '確認テストへ' : '次のカード',
                onPressed: session.isRoundEnd
                    ? notifier.advance
                    : () => notifier.moveBy(1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ラウンドの確認テスト（4択 / スペル）。
///
/// 描画は4択画面・スペル画面と同じ [ChoiceQuestionView] / [SpellPrompt] /
/// [EnglishKeyboard] / [VerdictBanner] を使う。テストの体裁を別に作らない。
class _RoundTest extends ConsumerStatefulWidget {
  final FlashcardState session;
  final VoidCallback onFinish;

  const _RoundTest({required this.session, required this.onFinish});

  @override
  ConsumerState<_RoundTest> createState() => _RoundTestState();
}

class _RoundTestState extends ConsumerState<_RoundTest> {
  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('解答を保存できませんでした: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final notifier = ref.read(flashcardProvider.notifier);
    final question = session.currentQuestion!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: '学習を終える',
                onPressed: widget.onFinish,
              ),
              Expanded(
                child: Text(
                  '確認テスト '
                  '${session.testIndex + 1} / ${session.testQueue.length}'
                  '（${session.roundNumber}/${session.roundTotal} ラウンド）',
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
        switch (question) {
          FlashcardChoiceQuestion() => Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ChoiceQuestionView(
                question: question.question,
                selectedIndex: session.selectedIndex,
                answered: session.testAnswered,
                onSelect: session.testAnswered || session.busy
                    ? null
                    : (i) => _guard(() => notifier.answerChoice(i)),
              ),
            ),
          ),
          FlashcardSpellQuestion() => Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: SpellPrompt(
                word: question.word,
                prompt: question.word.meaning,
                typed: session.typed,
                hintUsed: session.hintUsed,
                answering: !session.testAnswered,
                canHint: session.canHint,
                onHint: notifier.hint,
                onGiveUp: session.busy
                    ? null
                    : () => _guard(notifier.giveUp),
              ),
            ),
          ),
        },
        if (session.testAnswered && question is FlashcardSpellQuestion)
          VerdictBanner(
            verdict: session.verdict!,
            word: question.word,
            // 流し見の途中に例文を挟まない（確認テストは短く終える）。
            example: null,
            typed: session.submittedText,
            isLast: session.isLastQuestion && session.isLast,
            onNext: notifier.next,
          )
        else if (session.testAnswered)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: notifier.next,
              child: Text(
                session.isLastQuestion && session.isLast ? '結果を見る' : '次へ',
              ),
            ),
          )
        else if (question is FlashcardSpellQuestion)
          EnglishKeyboard(
            layout: KeyboardLayout.fromValue(session.profile.keyboardLayout),
            onKey: notifier.typeLetter,
            onBackspace: notifier.backspace,
            onSubmit: session.canSubmit
                ? () => _guard(notifier.submitSpell)
                : null,
          ),
      ],
    );
  }
}

/// 読み上げに失敗して送りを止めた状態。理由を示してセッションを終える。
class _HaltedView extends StatelessWidget {
  final String reason;
  final VoidCallback onClose;

  const _HaltedView({required this.reason, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔇', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text('読み上げできなかったので止めました', style: AppText.sectionTitle()),
              const SizedBox(height: 6),
              Text(
                reason,
                textAlign: TextAlign.center,
                style: AppText.caption(),
              ),
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: onClose,
                child: const Text('終わる'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
