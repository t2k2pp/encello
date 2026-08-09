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
import '../widgets/soft_card.dart';
import 'session_result_screen.dart';

/// SCR-05 フラッシュカード（[Docs/04_screens_and_flows.md] §4.4、
/// [Docs/06_features/flashcard_mode.md]）。
///
/// カードは表裏を持たず、上下を同時に表示する。めくる操作を挟むと
/// 「次々に流して浴びる」という目的が損なわれる。
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

    final word = session.currentWord!;
    final top = session.topLang == SpeechLang.en ? word.headword : word.meaning;
    final bottom = session.topLang == SpeechLang.en
        ? word.meaning
        : word.headword;

    return Scaffold(
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
                        tooltip: '学習を終える',
                        onPressed: () {
                          ref.read(flashcardProvider.notifier).clear();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) => SessionResultScreen(
                                sessionId: session.sessionId,
                              ),
                            ),
                          );
                        },
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
                      IconButton(
                        icon: Icon(
                          session.phase == FlashcardPhase.paused
                              ? Icons.play_arrow
                              : Icons.pause,
                        ),
                        tooltip: session.phase == FlashcardPhase.paused
                            ? '再開する'
                            : '一時停止する',
                        onPressed: ref
                            .read(flashcardProvider.notifier)
                            .togglePause,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      tooltip: '前のカード',
                      onPressed: session.index == 0
                          ? null
                          : () =>
                                ref.read(flashcardProvider.notifier).moveBy(-1),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      tooltip: '次のカード',
                      onPressed: session.isLast
                          ? null
                          : () =>
                                ref.read(flashcardProvider.notifier).moveBy(1),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: session.busy
                              ? null
                              : () => _rate(FlashcardRating.shaky),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: const Text('あやしい'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          onPressed: session.busy
                              ? null
                              : () => _rate(FlashcardRating.remembered),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: const Text('覚えた'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _rate(FlashcardRating rating) async {
    _silentTimer?.cancel();
    try {
      await ref.read(flashcardProvider.notifier).rate(rating);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('記録できませんでした: $e')));
    }
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
