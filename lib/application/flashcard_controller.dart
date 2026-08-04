import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import '../core/utils/enums.dart';
import '../data/database/app_database.dart';
import '../data/repositories/wordbook_repository.dart' show decodeIdList;
import '../domain/usecases/study_queue_builder.dart';
import '../providers/providers.dart';
import 'answer_submission_service.dart';
import 'study_session_controller.dart' show StudyStartFailure;

/// フラッシュカードの進行段階（[Docs/06_features/flashcard_mode.md] §2）。
enum FlashcardPhase {
  showing,
  paused,
  finished,

  /// 読み上げに失敗して送りを止めた。無音のまま流し続けない。
  halted,
}

/// カードの自己評価（FR-26）。押さなければ学習状態を変えない。
enum FlashcardRating {
  remembered('覚えた', 4),
  shaky('あやしい', 2);

  final String label;
  final int grade;
  const FlashcardRating(this.label, this.grade);
}

@immutable
class FlashcardState {
  final String sessionId;
  final Profile profile;
  final FlashcardMode mode;
  final List<QueuedItem> queue;
  final Map<int, Word> words;
  final int index;
  final FlashcardPhase phase;

  /// 自己評価した枚数と内訳（結果画面で「表示 40枚 / 評価 12枚」を出す）。
  final int evaluatedCount;
  final int rememberedCount;
  final int shakyCount;

  /// 送りを止めた理由（[FlashcardPhase.halted] のときだけ）。
  final String? haltReason;

  final DateTime presentedAt;
  final bool busy;

  const FlashcardState({
    required this.sessionId,
    required this.profile,
    required this.mode,
    required this.queue,
    required this.words,
    required this.index,
    required this.phase,
    required this.evaluatedCount,
    required this.rememberedCount,
    required this.shakyCount,
    required this.haltReason,
    required this.presentedAt,
    required this.busy,
  });

  Word? get currentWord =>
      index < queue.length ? words[queue[index].wordId] : null;

  int get totalCount => queue.length;

  bool get isLast => index >= queue.length - 1;

  /// 上段に出す言語。**上段＝先に意識させたい言語**という一貫した意味を持たせる
  /// （[Docs/06_features/flashcard_mode.md] §1）。
  SpeechLang get topLang =>
      mode == FlashcardMode.speakEn ? SpeechLang.en : SpeechLang.ja;

  /// 読み上げる言語。無音モードでは null。
  SpeechLang? get speakLang => switch (mode) {
    FlashcardMode.silentAuto => null,
    FlashcardMode.speakEn => SpeechLang.en,
    FlashcardMode.speakJa => SpeechLang.ja,
  };

  FlashcardState copyWith({
    int? index,
    FlashcardPhase? phase,
    int? evaluatedCount,
    int? rememberedCount,
    int? shakyCount,
    String? haltReason,
    DateTime? presentedAt,
    bool? busy,
  }) {
    return FlashcardState(
      sessionId: sessionId,
      profile: profile,
      mode: mode,
      queue: queue,
      words: words,
      index: index ?? this.index,
      phase: phase ?? this.phase,
      evaluatedCount: evaluatedCount ?? this.evaluatedCount,
      rememberedCount: rememberedCount ?? this.rememberedCount,
      shakyCount: shakyCount ?? this.shakyCount,
      haltReason: haltReason ?? this.haltReason,
      presentedAt: presentedAt ?? this.presentedAt,
      busy: busy ?? this.busy,
    );
  }
}

/// フラッシュカードの進行（[Docs/06_features/flashcard_mode.md]）。
///
/// 送りの契機は無音モードだけがタイマーで、読み上げモードは**再生の完了**。
/// 固定秒で代用しない（語の長さで再生時間が変わり、長い語が途中で切れる）。
/// 実際の再生は画面側が [PronunciationService] を通じて行い、ここは進行だけを持つ。
class FlashcardController extends Notifier<FlashcardState?> {
  @override
  FlashcardState? build() => null;

  Future<void> start({
    required Profile profile,
    required FlashcardMode mode,
    required QueuePolicy policy,
    required int limit,
  }) async {
    final study = ref.read(studyRepositoryProvider);
    final now = ref.read(clockProvider)();

    final candidates = await study.loadCandidates(profile);
    if (candidates.isEmpty) {
      throw const StudyStartFailure('選んだ単語帳に出題できる語がありません。');
    }
    final sessionId = const Uuid().v4();
    final queue = StudyQueueBuilder.build(
      candidates: candidates,
      policy: policy,
      limit: limit,
      now: now,
      shuffleSeed: sessionId.hashCode,
    );
    if (queue.isEmpty) {
      throw const StudyStartFailure('出題できる語がありません。');
    }

    final words = await study.loadWords(queue.map((q) => q.wordId));
    await study.startSession(
      sessionId: sessionId,
      profile: profile,
      mode: StudyMode.flashcard.value,
      wordbookIds: decodeIdList(profile.selectedWordbookIds),
      plannedCount: queue.length,
      startedAt: now,
    );

    state = FlashcardState(
      sessionId: sessionId,
      profile: profile,
      mode: mode,
      queue: queue,
      words: words,
      index: 0,
      phase: FlashcardPhase.showing,
      evaluatedCount: 0,
      rememberedCount: 0,
      shakyCount: 0,
      haltReason: null,
      presentedAt: now,
      busy: false,
    );
  }

  /// 次のカードへ。残りが無ければ終了。
  void advance() {
    final s = state;
    if (s == null || s.phase == FlashcardPhase.finished) return;
    if (s.isLast) {
      state = s.copyWith(phase: FlashcardPhase.finished);
      return;
    }
    state = s.copyWith(
      index: s.index + 1,
      phase: FlashcardPhase.showing,
      presentedAt: ref.read(clockProvider)(),
    );
  }

  /// 手動で移動する。ユーザーが操作した以上、勝手に流し始めない。
  void moveBy(int delta) {
    final s = state;
    if (s == null) return;
    final next = (s.index + delta).clamp(0, s.queue.length - 1);
    state = s.copyWith(
      index: next,
      phase: FlashcardPhase.paused,
      presentedAt: ref.read(clockProvider)(),
    );
  }

  void togglePause() {
    final s = state;
    if (s == null) return;
    state = s.copyWith(
      phase: s.phase == FlashcardPhase.paused
          ? FlashcardPhase.showing
          : FlashcardPhase.paused,
    );
  }

  /// 読み上げに失敗した。送りを止めて理由を残す。
  void halt(String reason) {
    final s = state;
    if (s == null) return;
    state = s.copyWith(phase: FlashcardPhase.halted, haltReason: reason);
  }

  /// 自己評価。押したときだけ記録し、押さずに流したカードは何も書かない（FR-26）。
  Future<void> rate(FlashcardRating rating) async {
    final s = state;
    final word = s?.currentWord;
    if (s == null || word == null || s.busy) return;

    state = s.copyWith(busy: true);
    final now = ref.read(clockProvider)();
    try {
      await ref
          .read(answerSubmissionServiceProvider)
          .submit(
            profile: s.profile,
            sessionId: s.sessionId,
            record: AnswerRecord(
              wordId: word.id,
              mode: StudyMode.flashcard,
              direction: s.topLang == SpeechLang.en
                  ? StudyDirection.enToJa
                  : StudyDirection.jaToEn,
              isCorrect: rating == FlashcardRating.remembered,
              grade: rating.grade,
              elapsedMs: now.difference(s.presentedAt).inMilliseconds,
            ),
            answeredAt: now,
            sessionCorrectStreak: 0,
          );
    } catch (e) {
      state = s.copyWith(busy: false);
      rethrow;
    }

    final rated = state!.copyWith(
      busy: false,
      evaluatedCount: s.evaluatedCount + 1,
      rememberedCount:
          s.rememberedCount + (rating == FlashcardRating.remembered ? 1 : 0),
      shakyCount: s.shakyCount + (rating == FlashcardRating.shaky ? 1 : 0),
    );
    state = rated;
    // 評価したら即座に次のカードへ送る。
    advance();
  }

  void clear() => state = null;
}
