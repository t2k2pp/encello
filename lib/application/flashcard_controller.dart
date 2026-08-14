import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import '../core/utils/enums.dart';
import '../data/database/app_database.dart';
import '../data/repositories/wordbook_repository.dart' show decodeIdList;
import '../domain/entities/spell_verdict.dart';
import '../domain/usecases/choice_distractors.dart';
import '../domain/usecases/grade_resolver.dart';
import '../domain/usecases/spell_judge.dart';
import '../domain/usecases/spell_slots.dart';
import '../domain/usecases/study_queue_builder.dart';
import '../providers/providers.dart';
import 'answer_submission_service.dart';
import 'choice_session_controller.dart'
    show ChoiceQuestion, ChoiceQuestionBuilder;
import 'study_session_controller.dart' show StudyStartFailure;

/// フラッシュカードの進行段階（[Docs/06_features/flashcard_mode.md] §2）。
enum FlashcardPhase {
  showing,
  paused,

  /// ラウンドの流し見を終え、そのラウンドの語を確認テストで問うている。
  testing,

  finished,

  /// 読み上げに失敗して送りを止めた。無音のまま流し続けない。
  halted,
}

/// 確認テストの1問（[Docs/06_features/flashcard_mode.md] §4）。
///
/// 4択とスペルで問いの形が違うので sealed で分ける。どちらも**そのラウンドで
/// 見せた語**しか持たない。
sealed class FlashcardTestQuestion {
  int get wordId;

  const FlashcardTestQuestion();
}

/// 4択の1問。選択肢の組み立ては4択モードと同じ [ChoiceQuestionBuilder] を使う。
final class FlashcardChoiceQuestion extends FlashcardTestQuestion {
  final ChoiceQuestion question;

  const FlashcardChoiceQuestion(this.question);

  @override
  int get wordId => question.wordId!;
}

/// スペルの1問。判定・入力はスペルモードと同じ実装を使う（方向は `jaToEn` 固定）。
final class FlashcardSpellQuestion extends FlashcardTestQuestion {
  final Word word;

  const FlashcardSpellQuestion(this.word);

  @override
  int get wordId => word.id;
}

@immutable
class FlashcardState {
  final String sessionId;
  final Profile profile;
  final FlashcardMode mode;

  /// 確認テストの形式。`none` ならラウンドの切れ目でも止まらず流し続ける。
  final FlashcardTestFormat testFormat;

  /// 確認テストまでに流し見する枚数（ラウンドの長さ）。
  final int roundSize;

  final List<QueuedItem> queue;
  final Map<int, Word> words;

  /// 4択の選択肢を組むための候補プール。セッション開始時に一度だけ読む
  /// （ラウンドの切れ目で DB を待たせないため）。
  final List<ChoiceCandidate> choicePool;

  final int index;
  final FlashcardPhase phase;

  /// いま解いている確認テストの問題。`testing` 以外では空。
  final List<FlashcardTestQuestion> testQueue;
  final int testIndex;

  /// テストの解答を確定したか（フィードバックを出しているか）。
  final bool testAnswered;

  /// 4択で選んだ選択肢の位置。未解答なら null。
  final int? selectedIndex;

  /// スペルで入力済みの英字と、ヒントで開示した文字数。
  final String typed;
  final int hintUsed;

  /// スペルの判定。フィードバック中だけ非 null。
  final SpellVerdict? verdict;

  /// 判定を確定した時点の入力（差分表示に使う）。
  final String submittedText;

  /// テスト内の連続正解数（XP のボーナス判定に使う）。
  final int correctStreak;

  /// 送りを止めた理由（[FlashcardPhase.halted] のときだけ）。
  final String? haltReason;

  /// いまのカード／テストの1問が出た時刻（`elapsedMs` の起点）。
  final DateTime presentedAt;
  final bool busy;

  const FlashcardState({
    required this.sessionId,
    required this.profile,
    required this.mode,
    required this.testFormat,
    required this.roundSize,
    required this.queue,
    required this.words,
    required this.choicePool,
    required this.index,
    required this.phase,
    required this.testQueue,
    required this.testIndex,
    required this.testAnswered,
    required this.selectedIndex,
    required this.typed,
    required this.hintUsed,
    required this.verdict,
    required this.submittedText,
    required this.correctStreak,
    required this.haltReason,
    required this.presentedAt,
    required this.busy,
  });

  Word? get currentWord =>
      index < queue.length ? words[queue[index].wordId] : null;

  int get totalCount => queue.length;

  bool get isLast => index >= queue.length - 1;

  /// いまのラウンドの先頭カードの位置。
  int get roundStart => (index ~/ roundSize) * roundSize;

  /// いまのラウンドの末尾カードの位置。最後のラウンドは半端な枚数になる。
  int get roundEnd => min(roundStart + roundSize - 1, queue.length - 1);

  /// いまのカードがラウンドの最後か。
  bool get isRoundEnd => index >= roundEnd;

  /// 何ラウンド目か（1 始まり）。
  int get roundNumber => index ~/ roundSize + 1;

  /// 全部で何ラウンドか。
  int get roundTotal => (queue.length + roundSize - 1) ~/ roundSize;

  /// いま解いているテストの問題。
  FlashcardTestQuestion? get currentQuestion =>
      testIndex < testQueue.length ? testQueue[testIndex] : null;

  /// テストの最後の問題か。
  bool get isLastQuestion => testIndex >= testQueue.length - 1;

  /// 「答え合わせ」を押せるか（スペル）。1文字も入っていなければ押せない。
  bool get canSubmit => phase == FlashcardPhase.testing && !testAnswered &&
      typed.isNotEmpty && !busy;

  /// これ以上ヒントを出せるか（スペル）。
  bool get canHint {
    final question = currentQuestion;
    if (question is! FlashcardSpellQuestion) return false;
    if (testAnswered || busy) return false;
    return typed.length < SpellSlots.letterCount(question.word.headword);
  }

  /// 上段に出す言語。**上段＝先に意識させたい言語**という一貫した意味を持たせる
  /// （[Docs/06_features/flashcard_mode.md] §1）。
  SpeechLang get topLang =>
      mode == FlashcardMode.speakEn ? SpeechLang.en : SpeechLang.ja;

  /// 確認テスト（4択）の出題方向。上下の配置と揃える（§4）。
  /// 英語が上段なら「英語を見て意味を選ぶ」、日本語が上段なら「意味を見て英語を選ぶ」。
  StudyDirection get testDirection => topLang == SpeechLang.en
      ? StudyDirection.enToJa
      : StudyDirection.jaToEn;

  /// 読み上げる言語。無音モードでは null。
  SpeechLang? get speakLang => switch (mode) {
    FlashcardMode.silentAuto => null,
    FlashcardMode.speakEn => SpeechLang.en,
    FlashcardMode.speakJa => SpeechLang.ja,
  };

  FlashcardState copyWith({
    int? index,
    FlashcardPhase? phase,
    List<FlashcardTestQuestion>? testQueue,
    int? testIndex,
    bool? testAnswered,
    int? selectedIndex,
    bool clearSelection = false,
    String? typed,
    int? hintUsed,
    SpellVerdict? verdict,
    bool clearVerdict = false,
    String? submittedText,
    int? correctStreak,
    String? haltReason,
    DateTime? presentedAt,
    bool? busy,
  }) {
    return FlashcardState(
      sessionId: sessionId,
      profile: profile,
      mode: mode,
      testFormat: testFormat,
      roundSize: roundSize,
      queue: queue,
      words: words,
      choicePool: choicePool,
      index: index ?? this.index,
      phase: phase ?? this.phase,
      testQueue: testQueue ?? this.testQueue,
      testIndex: testIndex ?? this.testIndex,
      testAnswered: testAnswered ?? this.testAnswered,
      selectedIndex: clearSelection
          ? null
          : (selectedIndex ?? this.selectedIndex),
      typed: typed ?? this.typed,
      hintUsed: hintUsed ?? this.hintUsed,
      verdict: clearVerdict ? null : (verdict ?? this.verdict),
      submittedText: submittedText ?? this.submittedText,
      correctStreak: correctStreak ?? this.correctStreak,
      haltReason: haltReason ?? this.haltReason,
      presentedAt: presentedAt ?? this.presentedAt,
      busy: busy ?? this.busy,
    );
  }
}

/// フラッシュカードの進行（[Docs/06_features/flashcard_mode.md]）。
///
/// 「N枚の流し見 → その N語の確認テスト」を繰り返す。送りの契機は無音モードだけが
/// タイマーで、読み上げモードは**再生の完了**。固定秒で代用しない（語の長さで
/// 再生時間が変わり、長い語が途中で切れる）。実際の再生は画面側が
/// [PronunciationService] を通じて行い、ここは進行だけを持つ。
///
/// **自己評価（覚えた / あやしい）は持たない。** 覚えたかどうかの判定は確認テストが
/// 担う。主観の自己評価と客観のテスト結果が二重にあると、どちらの成績なのかが
/// ぼやける。加えて、押す前にカードが送られてしまう以上、自己評価は取りこぼしが
/// 起きて成績として信用できない。流し見の最中は何も記録しない。
class FlashcardController extends Notifier<FlashcardState?> {
  @override
  FlashcardState? build() => null;

  Future<void> start({
    required Profile profile,
    required FlashcardMode mode,
    required FlashcardTestFormat testFormat,
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
    // 4択の誤答選択肢は「選んでいる単語帳の語」から選ぶ。ラウンドの切れ目で
    // DB を待たせないよう、ここで一度だけ読む。
    final pool = testFormat == FlashcardTestFormat.choice
        ? await ref.read(modeRepositoryProvider).loadChoiceCandidates(profile)
        : const <ChoiceCandidate>[];
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
      testFormat: testFormat,
      // 0 以下のラウンドは成立しない。設定 UI が出す値は 5 / 10 / 20。
      roundSize: profile.flashcardRoundSize.clamp(1, queue.length),
      queue: queue,
      words: words,
      choicePool: pool,
      index: 0,
      phase: FlashcardPhase.showing,
      testQueue: const [],
      testIndex: 0,
      testAnswered: false,
      selectedIndex: null,
      typed: '',
      hintUsed: 0,
      verdict: null,
      submittedText: '',
      correctStreak: 0,
      haltReason: null,
      presentedAt: now,
      busy: false,
    );
  }

  /// 次のカードへ。ラウンドの最後まで送ったら確認テストに入る。
  void advance() {
    final s = state;
    if (s == null || s.phase == FlashcardPhase.finished) return;

    if (s.isRoundEnd) {
      final questions = _buildTest(s);
      if (questions.isNotEmpty) {
        state = s.copyWith(
          phase: FlashcardPhase.testing,
          testQueue: questions,
          testIndex: 0,
          testAnswered: false,
          clearSelection: true,
          typed: '',
          hintUsed: 0,
          clearVerdict: true,
          submittedText: '',
          presentedAt: ref.read(clockProvider)(),
        );
        return;
      }
      // テストなし、または選択肢が4つ揃わずに1問も作れなかったラウンド。
      // ダミーで埋めずに、そのまま次のラウンドへ送る（§4）。
      _openNextRound(s);
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
    if (s == null || s.phase == FlashcardPhase.testing) return;
    // ラウンドをまたぐ移動はしない。テストの対象が「そのラウンドで見せた語」で
    // なくなってしまう。
    final next = (s.index + delta).clamp(s.roundStart, s.roundEnd);
    state = s.copyWith(
      index: next,
      phase: FlashcardPhase.paused,
      presentedAt: ref.read(clockProvider)(),
    );
  }

  void togglePause() {
    final s = state;
    if (s == null || s.phase == FlashcardPhase.testing) return;
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

  /// 4択の選択肢を選ぶ。タップした瞬間に確定し、取り消せない。
  Future<void> answerChoice(int optionIndex) async {
    final s = state;
    final question = s?.currentQuestion;
    if (s == null || question is! FlashcardChoiceQuestion) return;
    if (s.phase != FlashcardPhase.testing || s.testAnswered || s.busy) return;

    final isCorrect = optionIndex == question.question.answerIndex;
    await _submit(
      s,
      wordId: question.wordId,
      direction: question.question.direction,
      xpMode: StudyMode.choice,
      isCorrect: isCorrect,
      grade: GradeResolver.forChoice(isCorrect: isCorrect),
      answeredText: question.question.options[optionIndex],
      after: (next) => next.copyWith(
        testAnswered: true,
        selectedIndex: optionIndex,
      ),
    );
  }

  void typeLetter(String letter) {
    final s = state;
    final question = s?.currentQuestion;
    if (s == null || question is! FlashcardSpellQuestion) return;
    if (s.phase != FlashcardPhase.testing || s.testAnswered) return;
    if (s.typed.length >= SpellSlots.letterCount(question.word.headword)) {
      return;
    }
    state = s.copyWith(typed: s.typed + letter);
  }

  void backspace() {
    final s = state;
    if (s == null || s.phase != FlashcardPhase.testing) return;
    if (s.testAnswered || s.typed.isEmpty) return;
    // ヒントで開示した文字も消せる。開示済みの数は減らさない（記録は残す）。
    state = s.copyWith(typed: s.typed.substring(0, s.typed.length - 1));
  }

  /// 未入力の先頭1文字を開示する（スペルモードと同じ扱い）。
  void hint() {
    final s = state;
    final question = s?.currentQuestion;
    if (s == null || question is! FlashcardSpellQuestion || !s.canHint) return;
    state = s.copyWith(
      typed: SpellSlots.reveal(question.word.headword, s.typed),
      hintUsed: s.hintUsed + 1,
    );
  }

  /// 「わからない」。即座に grade 0 で確定し、正解を表示する。
  Future<void> giveUp() => submitSpell(gaveUp: true);

  /// スペルの「答え合わせ」。判定はスペルモードと同じ [SpellJudge] を使う。
  Future<void> submitSpell({bool gaveUp = false}) async {
    final s = state;
    final question = s?.currentQuestion;
    if (s == null || question is! FlashcardSpellQuestion) return;
    if (s.phase != FlashcardPhase.testing || s.testAnswered || s.busy) return;
    if (s.typed.isEmpty && !gaveUp) return;

    final headword = question.word.headword;
    final composed = SpellSlots.compose(headword, s.typed);
    final verdict = gaveUp
        ? const SpellWrong()
        : SpellJudge.judge(composed, headword);
    final elapsed = ref
        .read(clockProvider)()
        .difference(s.presentedAt)
        .inMilliseconds;
    final grade = GradeResolver.forSpell(
      mode: StudyMode.flashcard,
      verdict: verdict,
      elapsedMs: elapsed,
      hintUsed: s.hintUsed,
      gaveUp: gaveUp,
    );
    final isCorrect = verdict.isCorrect && !gaveUp;

    await _submit(
      s,
      wordId: question.wordId,
      direction: StudyDirection.jaToEn,
      xpMode: StudyMode.spell,
      isCorrect: isCorrect,
      isNearMiss: verdict is SpellNearMiss,
      grade: grade,
      answeredText: composed,
      hintUsed: s.hintUsed,
      after: (next) => next.copyWith(
        testAnswered: true,
        verdict: verdict,
        submittedText: composed,
      ),
    );
  }

  /// テストの「次へ」。残りがあれば次の問題、無ければ次のラウンドへ。
  void next() {
    final s = state;
    if (s == null || s.phase != FlashcardPhase.testing) return;
    if (!s.testAnswered || s.busy) return;

    if (s.isLastQuestion) {
      _openNextRound(s);
      return;
    }
    state = s.copyWith(
      testIndex: s.testIndex + 1,
      testAnswered: false,
      clearSelection: true,
      typed: '',
      hintUsed: 0,
      clearVerdict: true,
      submittedText: '',
      presentedAt: ref.read(clockProvider)(),
    );
  }

  void clear() => state = null;

  /// 次のラウンドの先頭カードへ。残りが無ければ終了。
  void _openNextRound(FlashcardState s) {
    final nextIndex = s.roundEnd + 1;
    if (nextIndex >= s.queue.length) {
      state = s.copyWith(phase: FlashcardPhase.finished, testQueue: const []);
      return;
    }
    state = s.copyWith(
      index: nextIndex,
      phase: FlashcardPhase.showing,
      testQueue: const [],
      testIndex: 0,
      testAnswered: false,
      clearSelection: true,
      typed: '',
      hintUsed: 0,
      clearVerdict: true,
      submittedText: '',
      presentedAt: ref.read(clockProvider)(),
    );
  }

  /// いまのラウンドで見せた語だけからテストを組む。`none` なら空を返す。
  List<FlashcardTestQuestion> _buildTest(FlashcardState s) {
    final ids = [
      for (var i = s.roundStart; i <= s.roundEnd; i++) s.queue[i],
    ];
    return switch (s.testFormat) {
      FlashcardTestFormat.none => const [],
      FlashcardTestFormat.spell => [
        for (final item in ids)
          if (s.words[item.wordId] != null)
            FlashcardSpellQuestion(s.words[item.wordId]!),
      ],
      FlashcardTestFormat.choice => [
        // 選択肢が4つ揃わない語は飛ばす（ダミー文字列で埋めない。FR-29）。
        for (final q in ChoiceQuestionBuilder.build(
          queue: ids,
          byId: {for (final c in s.choicePool) c.wordId: c},
          pool: s.choicePool,
          preference: s.testDirection == StudyDirection.enToJa
              ? ChoiceDirection.enToJa
              : ChoiceDirection.jaToEn,
          // ラウンドごとに決まる種にする（同じセッションを再現できる）。
          random: Random(s.sessionId.hashCode + s.roundStart),
        ))
          FlashcardChoiceQuestion(q),
      ],
    };
  }

  /// テストの解答を1トランザクションで確定する。
  ///
  /// 記録するのは**テストの解答だけ**。流し見のカードは `learning_logs` にも
  /// `word_reviews` にも `daily_stats` にも入らない（§6）。
  Future<void> _submit(
    FlashcardState s, {
    required int wordId,
    required StudyDirection direction,
    required StudyMode xpMode,
    required bool isCorrect,
    required int grade,
    required String answeredText,
    required FlashcardState Function(FlashcardState) after,
    bool isNearMiss = false,
    int hintUsed = 0,
  }) async {
    state = s.copyWith(busy: true);
    final now = ref.read(clockProvider)();
    final nextStreak = isCorrect ? s.correctStreak + 1 : 0;
    try {
      await ref
          .read(answerSubmissionServiceProvider)
          .submit(
            profile: s.profile,
            sessionId: s.sessionId,
            record: AnswerRecord(
              wordId: wordId,
              // 統計上はフラッシュカードの成績として扱う。XP だけテストの形式の
              // 係数を使う（§7）。
              mode: StudyMode.flashcard,
              xpMode: xpMode,
              direction: direction,
              isCorrect: isCorrect,
              isNearMiss: isNearMiss,
              grade: grade,
              answeredText: answeredText,
              hintUsed: hintUsed,
              // 流し見の表示時間ではなく、テスト1問の解答時間。
              elapsedMs: now.difference(s.presentedAt).inMilliseconds,
            ),
            answeredAt: now,
            sessionCorrectStreak: nextStreak,
          );
    } catch (e) {
      // 書き込みに失敗したら判定前へ戻す。黙って進めない。
      state = s.copyWith(busy: false);
      rethrow;
    }
    state = after(s.copyWith(busy: false, correctStreak: nextStreak));
  }
}
