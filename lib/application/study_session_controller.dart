import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import '../core/utils/enums.dart';
import '../data/database/app_database.dart';
import '../data/repositories/wordbook_repository.dart' show decodeIdList;
import '../domain/entities/spell_verdict.dart';
import '../domain/usecases/family_quiz_builder.dart';
import '../domain/usecases/grade_resolver.dart';
import '../domain/usecases/spell_judge.dart';
import '../domain/usecases/spell_slots.dart';
import '../domain/usecases/study_queue_builder.dart';
import '../providers/providers.dart';
import 'answer_submission_service.dart';

/// 学習セッションの進行段階（[Docs/04_screens_and_flows.md] §5）。
enum StudyPhase { presenting, feedback, finished }

/// 学習セッションの状態。
///
/// **Stream に載せない**。出題キューはセッション開始時に一度だけ作り、ここが
/// メモリ上で進行を持つ。DB 更新のたびに再ビルドされて問題順が変わる事故を
/// 構造的に防ぐ（[Docs/02_architecture.md] §2）。
@immutable
class StudySessionState {
  final String sessionId;
  final StudyMode mode;
  final Profile profile;

  /// 出題キュー。誤答した語は末尾へ1回だけ戻すため、進行中に伸びることがある。
  final List<QueuedItem> queue;
  final Map<int, Word> words;

  /// いま何問目か（0 始まり）。
  final int index;

  /// 入力済みの英字（記号は含まない）。
  final String typed;

  /// ヒントで開示した文字数。
  final int hintUsed;

  /// 音声を聞き直した回数（リスニングのみ）。
  final int replayCount;

  /// 「訳を見る」を押したか（リスニングのみ）。押した回は grade の上限を 3 にする。
  final bool meaningRevealed;

  /// 「わからない」を押したか。
  final bool gaveUp;

  final StudyPhase phase;

  /// 直前の解答の判定。`feedback` の間だけ非 null。
  final SpellVerdict? verdict;

  /// 判定を確定した時点の入力（フィードバック帯の差分表示に使う）。
  final String submittedText;

  /// DB へ書き込み中。ここが終わるまで「次へ」を押させない。
  final bool busy;

  final int answeredCount;
  final int correctCount;
  final int xpEarned;

  /// セッション内の連続正解数（XP のボーナス判定に使う）。
  final int correctStreak;

  /// この問題が画面に出た時刻（`elapsedMs` の起点）。
  final DateTime presentedAt;

  /// 誤答で末尾へ戻した語。戻すのは1回までにして、セッションが終わらなくなるのを防ぐ。
  final Set<int> requeued;

  /// 出題文の差し替え（語形変化: `decide（動詞：決める）` → 名詞形にしなさい）。
  /// 空なら語の和訳をそのまま出す。
  final Map<int, ({String prompt, String instruction})> promptOverrides;

  const StudySessionState({
    required this.sessionId,
    required this.mode,
    required this.profile,
    required this.queue,
    required this.words,
    required this.index,
    required this.typed,
    required this.hintUsed,
    required this.replayCount,
    required this.meaningRevealed,
    required this.gaveUp,
    required this.phase,
    required this.verdict,
    required this.submittedText,
    required this.busy,
    required this.answeredCount,
    required this.correctCount,
    required this.xpEarned,
    required this.correctStreak,
    required this.presentedAt,
    required this.requeued,
    this.promptOverrides = const {},
  });

  /// いま出題している語。`finished` では null。
  Word? get currentWord =>
      index < queue.length ? words[queue[index].wordId] : null;

  int get totalCount => queue.length;

  /// 「答え合わせ」を押せるか。1文字も入っていなければ押せない。
  bool get canSubmit =>
      phase == StudyPhase.presenting && typed.isNotEmpty && !busy;

  /// これ以上ヒントを出せるか。
  bool get canHint {
    final word = currentWord;
    if (word == null || phase != StudyPhase.presenting) return false;
    return typed.length < SpellSlots.letterCount(word.headword);
  }

  /// この問題が最後か。
  bool get isLastQuestion => index >= queue.length - 1;

  StudySessionState copyWith({
    List<QueuedItem>? queue,
    Map<int, Word>? words,
    int? index,
    String? typed,
    int? hintUsed,
    int? replayCount,
    bool? meaningRevealed,
    bool? gaveUp,
    StudyPhase? phase,
    SpellVerdict? verdict,
    bool clearVerdict = false,
    String? submittedText,
    bool? busy,
    int? answeredCount,
    int? correctCount,
    int? xpEarned,
    int? correctStreak,
    DateTime? presentedAt,
    Set<int>? requeued,
  }) {
    return StudySessionState(
      sessionId: sessionId,
      mode: mode,
      profile: profile,
      queue: queue ?? this.queue,
      words: words ?? this.words,
      index: index ?? this.index,
      typed: typed ?? this.typed,
      hintUsed: hintUsed ?? this.hintUsed,
      replayCount: replayCount ?? this.replayCount,
      meaningRevealed: meaningRevealed ?? this.meaningRevealed,
      gaveUp: gaveUp ?? this.gaveUp,
      phase: phase ?? this.phase,
      verdict: clearVerdict ? null : (verdict ?? this.verdict),
      submittedText: submittedText ?? this.submittedText,
      busy: busy ?? this.busy,
      answeredCount: answeredCount ?? this.answeredCount,
      correctCount: correctCount ?? this.correctCount,
      xpEarned: xpEarned ?? this.xpEarned,
      correctStreak: correctStreak ?? this.correctStreak,
      presentedAt: presentedAt ?? this.presentedAt,
      requeued: requeued ?? this.requeued,
      promptOverrides: promptOverrides,
    );
  }
}

/// セッションを開始できなかった理由。空のセッションを始めないための値。
class StudyStartFailure implements Exception {
  final String message;

  const StudyStartFailure(this.message);

  @override
  String toString() => message;
}

/// 学習セッションの進行（[Docs/04_screens_and_flows.md] §5）。
class StudySessionController extends Notifier<StudySessionState?> {
  @override
  StudySessionState? build() => null;

  /// セッションを開始する。対象語が0件なら [StudyStartFailure] を投げ、
  /// 空のセッションを作らない。
  Future<void> start({
    required Profile profile,
    required StudyMode mode,
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
      // 同じセッションの再現とテストの決定性のため、乱数はセッションIDから作る。
      shuffleSeed: sessionId.hashCode,
    );
    if (queue.isEmpty) {
      throw StudyStartFailure(switch (policy) {
        QueuePolicy.newOnly => 'まだ学習していない語がありません。',
        QueuePolicy.weakOnly => '苦手として抽出できる語がありません。',
        QueuePolicy.reviewFirst => '選んだ単語帳に出題できる語がありません。',
      });
    }

    final words = await study.loadWords(queue.map((q) => q.wordId));
    await study.startSession(
      sessionId: sessionId,
      profile: profile,
      mode: mode.value,
      wordbookIds: decodeIdList(profile.selectedWordbookIds),
      plannedCount: queue.length,
      startedAt: now,
    );

    state = StudySessionState(
      sessionId: sessionId,
      mode: mode,
      profile: profile,
      queue: queue,
      words: words,
      index: 0,
      typed: '',
      hintUsed: 0,
      replayCount: 0,
      meaningRevealed: false,
      gaveUp: false,
      phase: StudyPhase.presenting,
      verdict: null,
      submittedText: '',
      busy: false,
      answeredCount: 0,
      correctCount: 0,
      xpEarned: 0,
      correctStreak: 0,
      presentedAt: now,
      requeued: const {},
    );
  }

  /// 語形変化クイズを開始する（[Docs/06_features/word_families.md] §4）。
  ///
  /// スペルモードの出題形式の1つとして扱い、入力・判定・記録は同じ実装を使う。
  /// 更新するのは**答えた語**の学習状態だけで、提示した語は変えない。
  Future<void> startFamily({
    required Profile profile,
    required List<FamilyQuestion> questions,
    required int limit,
  }) async {
    if (questions.isEmpty) {
      throw const StudyStartFailure('語形変化の問題を作れる語族がありません。');
    }
    final study = ref.read(studyRepositoryProvider);
    final now = ref.read(clockProvider)();
    final sessionId = const Uuid().v4();

    final picked = ([...questions]..shuffle(Random(sessionId.hashCode)))
        .take(limit)
        .toList();
    final words = await study.loadWords(picked.map((q) => q.answer.wordId));
    await study.startSession(
      sessionId: sessionId,
      profile: profile,
      mode: StudyMode.family.value,
      wordbookIds: decodeIdList(profile.selectedWordbookIds),
      plannedCount: picked.length,
      startedAt: now,
    );

    state = StudySessionState(
      sessionId: sessionId,
      mode: StudyMode.family,
      profile: profile,
      queue: [
        for (final q in picked)
          QueuedItem(wordId: q.answer.wordId, source: QueueSource.due),
      ],
      words: words,
      index: 0,
      typed: '',
      hintUsed: 0,
      replayCount: 0,
      meaningRevealed: false,
      gaveUp: false,
      phase: StudyPhase.presenting,
      verdict: null,
      submittedText: '',
      busy: false,
      answeredCount: 0,
      correctCount: 0,
      xpEarned: 0,
      correctStreak: 0,
      presentedAt: now,
      requeued: const {},
      promptOverrides: {
        for (final q in picked)
          q.answer.wordId: (
            prompt:
                '${q.prompt.headword}（${q.prompt.partOfSpeech.label}：${q.prompt.meaning}）',
            instruction: '${q.answer.partOfSpeech.label}形にしなさい',
          ),
      },
    );
  }

  void typeLetter(String letter) {
    final s = state;
    final word = s?.currentWord;
    if (s == null || word == null || s.phase != StudyPhase.presenting) return;
    if (s.typed.length >= SpellSlots.letterCount(word.headword)) return;
    state = s.copyWith(typed: s.typed + letter);
  }

  void backspace() {
    final s = state;
    if (s == null || s.phase != StudyPhase.presenting || s.typed.isEmpty) {
      return;
    }
    // ヒントで開示した文字も消せる。開示済みの数は減らさない（記録は残す）。
    state = s.copyWith(typed: s.typed.substring(0, s.typed.length - 1));
  }

  /// 未入力の先頭1文字を開示する（FR-18）。
  void hint() {
    final s = state;
    final word = s?.currentWord;
    if (s == null || word == null || !s.canHint) return;
    state = s.copyWith(
      typed: SpellSlots.reveal(word.headword, s.typed),
      hintUsed: s.hintUsed + 1,
    );
  }

  /// 音声を聞き直した（リスニング）。回数を記録に残す。
  void countReplay() {
    final s = state;
    if (s == null || s.phase != StudyPhase.presenting) return;
    state = s.copyWith(replayCount: s.replayCount + 1);
  }

  /// 「訳を見る」（リスニング）。音だけでは思い出せなかったため、
  /// この回の grade は 3 を超えない（[Docs/06_features/listening_mode.md] §2）。
  void revealMeaning() {
    final s = state;
    if (s == null || s.phase != StudyPhase.presenting) return;
    state = s.copyWith(meaningRevealed: true);
  }

  /// 「わからない」。即座に grade 0 で確定し、正解を表示する。
  Future<void> giveUp() async {
    final s = state;
    if (s == null || s.phase != StudyPhase.presenting || s.busy) return;
    state = s.copyWith(gaveUp: true);
    await submit();
  }

  /// 「答え合わせ」。判定し、1トランザクションで記録してフィードバックへ移る。
  Future<void> submit() async {
    final s = state;
    final word = s?.currentWord;
    if (s == null || word == null) return;
    if (s.phase != StudyPhase.presenting || s.busy) return;
    if (s.typed.isEmpty && !s.gaveUp) return;

    state = s.copyWith(busy: true);
    final now = ref.read(clockProvider)();
    final composed = SpellSlots.compose(word.headword, s.typed);
    final verdict = s.gaveUp
        ? const SpellWrong()
        : SpellJudge.judge(composed, word.headword);
    final grade = GradeResolver.forSpell(
      mode: s.mode,
      verdict: verdict,
      elapsedMs: now.difference(s.presentedAt).inMilliseconds,
      hintUsed: s.hintUsed,
      gaveUp: s.gaveUp,
      meaningRevealed: s.meaningRevealed,
    );
    final isCorrect = verdict.isCorrect && !s.gaveUp;
    final nextStreak = isCorrect ? s.correctStreak + 1 : 0;

    try {
      final outcome = await ref
          .read(answerSubmissionServiceProvider)
          .submit(
            profile: s.profile,
            sessionId: s.sessionId,
            record: AnswerRecord(
              wordId: word.id,
              mode: s.mode,
              // リスニングは音（英語）が問い、それ以外は和訳が問い。
              direction: s.mode == StudyMode.listening
                  ? StudyDirection.enToJa
                  : StudyDirection.jaToEn,
              isCorrect: isCorrect,
              isNearMiss: verdict is SpellNearMiss,
              grade: grade,
              answeredText: composed,
              hintUsed: s.hintUsed,
              replayCount: s.replayCount,
              elapsedMs: now.difference(s.presentedAt).inMilliseconds,
            ),
            answeredAt: now,
            sessionCorrectStreak: nextStreak,
          );

      // 誤答した語はキューの末尾へ1回だけ戻す（FR-31）。
      final requeue =
          !isCorrect && !s.requeued.contains(word.id);
      state = s.copyWith(
        busy: false,
        phase: StudyPhase.feedback,
        verdict: verdict,
        submittedText: composed,
        answeredCount: s.answeredCount + 1,
        correctCount: s.correctCount + (isCorrect ? 1 : 0),
        xpEarned: s.xpEarned + outcome.xpEarned,
        correctStreak: nextStreak,
        queue: requeue
            ? [
                ...s.queue,
                QueuedItem(wordId: word.id, source: s.queue[s.index].source),
              ]
            : s.queue,
        requeued: requeue ? {...s.requeued, word.id} : s.requeued,
      );
    } catch (e) {
      // 書き込みに失敗したら判定前へ戻す。黙って進めない。
      state = s.copyWith(busy: false, gaveUp: false);
      rethrow;
    }
  }

  /// 「次へ」。残りがあれば次の問題、無ければ終了へ。
  void next() {
    final s = state;
    if (s == null || s.phase != StudyPhase.feedback || s.busy) return;
    final nextIndex = s.index + 1;
    if (nextIndex >= s.queue.length) {
      state = s.copyWith(phase: StudyPhase.finished, clearVerdict: true);
      return;
    }
    state = s.copyWith(
      index: nextIndex,
      typed: '',
      hintUsed: 0,
      replayCount: 0,
      meaningRevealed: false,
      gaveUp: false,
      phase: StudyPhase.presenting,
      clearVerdict: true,
      submittedText: '',
      presentedAt: ref.read(clockProvider)(),
    );
  }

  /// セッションを閉じる（結果画面から戻る・中断）。
  void clear() => state = null;
}
