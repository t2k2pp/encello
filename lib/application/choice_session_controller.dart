import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import '../core/utils/enums.dart';
import '../data/database/app_database.dart';
import '../data/repositories/wordbook_repository.dart' show decodeIdList;
import '../domain/usecases/choice_distractors.dart';
import '../domain/usecases/confusion_pair_finder.dart';
import '../domain/usecases/grade_resolver.dart';
import '../domain/usecases/study_queue_builder.dart';
import '../providers/providers.dart';
import 'answer_submission_service.dart';
import 'study_session_controller.dart' show StudyPhase, StudyStartFailure;

/// 選択式の1問。4択（choice / speed）・語のつくり（parts）・取り違え（confusion）で
/// 同じ形を使う。
@immutable
class ChoiceQuestion {
  /// 問題文（英単語 / 和訳 / 部品 / 部品の意味）。
  final String prompt;

  /// 問題文の下に添える補足（品詞・部品の分解ヒントなど）。無ければ null。
  final String? hint;

  /// 選択肢の表示文字列。
  final List<String> options;

  /// 正解の位置。
  final int answerIndex;

  /// 解答後に見せる説明（取り違えの両語の訳、部品を含む単語など）。
  final List<String> explanation;

  /// 学習状態を更新する対象。語のつくりでは [partId]、それ以外は [wordId]。
  final int? wordId;
  final int? partId;

  /// 取り違えで不正解のとき一緒に下げる相手の語。
  final int? partnerWordId;

  /// 出題方向（記録に残す）。
  final StudyDirection direction;

  /// 正解しても学習状態を作らない問題（語のつくりの推測問題）。
  final bool guessOnly;

  const ChoiceQuestion({
    required this.prompt,
    required this.options,
    required this.answerIndex,
    required this.direction,
    this.hint,
    this.explanation = const [],
    this.wordId,
    this.partId,
    this.partnerWordId,
    this.guessOnly = false,
  });

  String get answerLabel => options[answerIndex];
}

/// 選択式セッションの状態。
@immutable
class ChoiceSessionState {
  final String sessionId;
  final StudyMode mode;
  final Profile profile;
  final List<ChoiceQuestion> questions;
  final int index;
  final StudyPhase phase;

  /// 選んだ選択肢の位置。未解答なら null。
  final int? selectedIndex;

  final bool busy;
  final int answeredCount;
  final int correctCount;
  final int correctStreak;

  /// 時間切れの数（スピードのみ）。
  final int timedOutCount;

  /// 推測問題の正解数（語のつくりのみ）。
  final int guessedCount;
  final int guessTotal;

  /// 時間内に正解した問題の反応時間（スピードの平均に使う）。
  final List<int> reactionMs;

  final DateTime presentedAt;

  /// 直前の問題で正解だった位置（位置の癖で当てられないようにする）。
  final int? previousAnswerIndex;

  const ChoiceSessionState({
    required this.sessionId,
    required this.mode,
    required this.profile,
    required this.questions,
    required this.index,
    required this.phase,
    required this.selectedIndex,
    required this.busy,
    required this.answeredCount,
    required this.correctCount,
    required this.correctStreak,
    required this.timedOutCount,
    required this.guessedCount,
    required this.guessTotal,
    required this.reactionMs,
    required this.presentedAt,
    required this.previousAnswerIndex,
  });

  ChoiceQuestion? get current =>
      index < questions.length ? questions[index] : null;

  int get totalCount => questions.length;

  bool get isLast => index >= questions.length - 1;

  /// 時間内に正解した問題だけの平均反応時間（ミリ秒）。
  ///
  /// 時間切れ（＝制限時間）を混ぜると、制限時間を変えたときに平均が動いて
  /// 回どうしで比べられなくなる（[Docs/06_features/speed_mode.md] §5）。
  int? get averageReactionMs => reactionMs.isEmpty
      ? null
      : (reactionMs.reduce((a, b) => a + b) / reactionMs.length).round();

  ChoiceSessionState copyWith({
    int? index,
    StudyPhase? phase,
    int? selectedIndex,
    bool clearSelection = false,
    bool? busy,
    int? answeredCount,
    int? correctCount,
    int? correctStreak,
    int? timedOutCount,
    int? guessedCount,
    List<int>? reactionMs,
    DateTime? presentedAt,
    int? previousAnswerIndex,
  }) {
    return ChoiceSessionState(
      sessionId: sessionId,
      mode: mode,
      profile: profile,
      questions: questions,
      index: index ?? this.index,
      phase: phase ?? this.phase,
      selectedIndex: clearSelection
          ? null
          : (selectedIndex ?? this.selectedIndex),
      busy: busy ?? this.busy,
      answeredCount: answeredCount ?? this.answeredCount,
      correctCount: correctCount ?? this.correctCount,
      correctStreak: correctStreak ?? this.correctStreak,
      timedOutCount: timedOutCount ?? this.timedOutCount,
      guessedCount: guessedCount ?? this.guessedCount,
      guessTotal: guessTotal,
      reactionMs: reactionMs ?? this.reactionMs,
      presentedAt: presentedAt ?? this.presentedAt,
      previousAnswerIndex: previousAnswerIndex ?? this.previousAnswerIndex,
    );
  }
}

/// 選択式セッションの進行（4択・スピード・語のつくり・取り違え）。
///
/// 出題の組み立てはモードごとに違うが、進行と記録は同じなのでここに集約する。
class ChoiceSessionController extends Notifier<ChoiceSessionState?> {
  @override
  ChoiceSessionState? build() => null;

  /// 組み立て済みの問題でセッションを開始する。
  Future<void> startWith({
    required Profile profile,
    required StudyMode mode,
    required List<ChoiceQuestion> questions,
  }) async {
    if (questions.isEmpty) {
      throw const StudyStartFailure('出題できる問題がありません。');
    }
    final sessionId = const Uuid().v4();
    final now = ref.read(clockProvider)();
    await ref
        .read(studyRepositoryProvider)
        .startSession(
          sessionId: sessionId,
          profile: profile,
          mode: mode.value,
          wordbookIds: decodeIdList(profile.selectedWordbookIds),
          plannedCount: questions.length,
          startedAt: now,
        );

    state = ChoiceSessionState(
      sessionId: sessionId,
      mode: mode,
      profile: profile,
      questions: questions,
      index: 0,
      phase: StudyPhase.presenting,
      selectedIndex: null,
      busy: false,
      answeredCount: 0,
      correctCount: 0,
      correctStreak: 0,
      timedOutCount: 0,
      guessedCount: 0,
      guessTotal: questions.where((q) => q.guessOnly).length,
      reactionMs: const [],
      presentedAt: now,
      previousAnswerIndex: null,
    );
  }

  /// 選択肢を選ぶ。タップした瞬間に確定し、取り消せない。
  /// [timedOut] はスピードの制限時間切れ。
  Future<void> answer(int? optionIndex, {bool timedOut = false}) async {
    final s = state;
    final question = s?.current;
    if (s == null || question == null) return;
    if (s.phase != StudyPhase.presenting || s.busy) return;

    state = s.copyWith(busy: true, selectedIndex: optionIndex);
    final now = ref.read(clockProvider)();
    final elapsed = now.difference(s.presentedAt).inMilliseconds;
    final isCorrect = !timedOut && optionIndex == question.answerIndex;

    final grade = switch (s.mode) {
      StudyMode.speed => GradeResolver.forSpeed(
        timedOut: timedOut,
        isCorrect: isCorrect,
      ),
      // 推測問題は正解しても学習状態を作らない。**推測できたことと覚えたことは別**
      // （[Docs/06_features/word_parts.md] §6）。
      _ when question.guessOnly => GradeResolver.noUpdate,
      _ => GradeResolver.forChoice(isCorrect: isCorrect),
    };
    final nextStreak = isCorrect ? s.correctStreak + 1 : 0;

    try {
      await ref
          .read(answerSubmissionServiceProvider)
          .submit(
            profile: s.profile,
            sessionId: s.sessionId,
            record: AnswerRecord(
              wordId: question.wordId,
              partId: question.partId,
              // 取り違えの誤答は相手の語も下げる。
              alsoLowerWordId: isCorrect ? null : question.partnerWordId,
              mode: s.mode,
              direction: question.direction,
              isCorrect: isCorrect,
              grade: grade,
              answeredText: optionIndex == null
                  ? null
                  : question.options[optionIndex],
              elapsedMs: timedOut ? elapsed : elapsed,
            ),
            answeredAt: now,
            sessionCorrectStreak: nextStreak,
          );
    } catch (e) {
      state = s.copyWith(busy: false, clearSelection: true);
      rethrow;
    }

    // 取り違えは、5回連続正解で組を解消済みにし、誤答で復活させる（§6）。
    final partner = question.partnerWordId;
    if (s.mode == StudyMode.confusion &&
        partner != null &&
        question.wordId != null) {
      await ref
          .read(modeRepositoryProvider)
          .updateConfusionResolution(
            profileId: s.profile.id,
            wordIdA: question.wordId!,
            wordIdB: partner,
            isCorrect: isCorrect,
            now: now,
          );
    }

    state = s.copyWith(
      busy: false,
      phase: StudyPhase.feedback,
      selectedIndex: optionIndex,
      answeredCount: s.answeredCount + 1,
      correctCount: s.correctCount + (isCorrect ? 1 : 0),
      correctStreak: nextStreak,
      timedOutCount: s.timedOutCount + (timedOut ? 1 : 0),
      guessedCount:
          s.guessedCount + (question.guessOnly && isCorrect ? 1 : 0),
      // 平均は時間内に正解した問題だけで取る。
      reactionMs: isCorrect ? [...s.reactionMs, elapsed] : s.reactionMs,
      previousAnswerIndex: question.answerIndex,
    );
  }

  void next() {
    final s = state;
    if (s == null || s.phase != StudyPhase.feedback || s.busy) return;
    final nextIndex = s.index + 1;
    if (nextIndex >= s.questions.length) {
      state = s.copyWith(phase: StudyPhase.finished, clearSelection: true);
      return;
    }
    state = s.copyWith(
      index: nextIndex,
      phase: StudyPhase.presenting,
      clearSelection: true,
      presentedAt: ref.read(clockProvider)(),
    );
  }

  void clear() => state = null;
}

/// 4択・スピードの問題を組み立てる（[Docs/06_features/quiz_mode.md]）。
abstract final class ChoiceQuestionBuilder {
  /// [queue] の順に問題を作る。選択肢が4つ揃わない語は**飛ばす**
  /// （ダミー文字列で埋めない）。
  static List<ChoiceQuestion> build({
    required List<QueuedItem> queue,
    required Map<int, ChoiceCandidate> byId,
    required List<ChoiceCandidate> pool,
    required ChoiceDirection preference,
    required Random random,
  }) {
    final questions = <ChoiceQuestion>[];
    int? previousAnswerIndex;

    for (final item in queue) {
      final correct = byId[item.wordId];
      if (correct == null) continue;

      final direction = switch (preference) {
        ChoiceDirection.enToJa => StudyDirection.enToJa,
        ChoiceDirection.jaToEn => StudyDirection.jaToEn,
        ChoiceDirection.random => random.nextBool()
            ? StudyDirection.enToJa
            : StudyDirection.jaToEn,
      };

      final distractors = ChoiceDistractors.pick(
        correct: correct,
        pool: pool,
        direction: direction,
        random: random,
      );
      if (distractors.isEmpty) continue;

      final arranged = ChoiceDistractors.arrange(
        correct: correct,
        distractors: distractors,
        random: random,
        avoidIndex: previousAnswerIndex,
      );
      final answerIndex = arranged.indexWhere(
        (c) => c.wordId == correct.wordId,
      );
      previousAnswerIndex = answerIndex;

      questions.add(
        ChoiceQuestion(
          prompt: direction == StudyDirection.enToJa
              ? correct.headword
              : correct.meaning,
          hint: direction == StudyDirection.enToJa
              ? correct.partOfSpeech.label
              : null,
          options: [
            for (final c in arranged) c.labelFor(direction),
          ],
          answerIndex: answerIndex,
          direction: direction,
          wordId: correct.wordId,
        ),
      );
    }
    return questions;
  }
}

/// 取り違えドリルの問題を組み立てる（[Docs/06_features/confusion_drill.md] §3）。
abstract final class ConfusionQuestionBuilder {
  /// 2語を必ず**並べて**出す。片方だけを問うと、比べて区別する練習にならない。
  /// 出題は両方向を交互にし、`affect` を問う回と `effect` を問う回を対にする。
  static List<ChoiceQuestion> build({
    required List<ConfusionPair> pairs,
    required Map<int, ConfusionWord> byId,
    required Map<int, String> partOfSpeechLabels,
    required Map<int, String?> confusionNotes,
    required Random random,
  }) {
    final questions = <ChoiceQuestion>[];
    for (final pair in pairs) {
      final a = byId[pair.wordIdA];
      final b = byId[pair.wordIdB];
      if (a == null || b == null) continue;

      for (final target in [a, b]) {
        final other = target.wordId == a.wordId ? b : a;
        final options = random.nextBool()
            ? [a.headword, b.headword]
            : [b.headword, a.headword];
        questions.add(
          ChoiceQuestion(
            prompt: target.meaning,
            hint: partOfSpeechLabels[target.wordId],
            options: options,
            answerIndex: options.indexOf(target.headword),
            direction: StudyDirection.jaToEn,
            wordId: target.wordId,
            partnerWordId: other.wordId,
            explanation: [
              for (final w in [a, b])
                '${w.headword}（${partOfSpeechLabels[w.wordId] ?? ''}：${w.meaning}）',
              // note があれば添える。無ければ出さない（機械生成しない）。
              if (confusionNotes[target.wordId] != null)
                confusionNotes[target.wordId]!,
            ],
          ),
        );
      }
    }
    return questions;
  }
}
