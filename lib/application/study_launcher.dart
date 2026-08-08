import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/enums.dart';
import '../data/database/app_database.dart';
import '../domain/usecases/choice_distractors.dart';
import '../domain/usecases/parts_question_builder.dart';
import '../domain/usecases/study_queue_builder.dart';
import '../providers/providers.dart';
import 'choice_session_controller.dart';
import 'study_session_controller.dart' show StudyStartFailure;

/// 選択式モード（4択・スピード・取り違え）のセッションを組み立てて開始する。
///
/// 出題の作り方はモードごとに違うが、進行と記録は [ChoiceSessionController] が共通に持つ。
class StudyLauncher {
  final Ref _ref;

  const StudyLauncher(this._ref);

  Future<void> start({
    required Profile profile,
    required StudyMode mode,
    required QueuePolicy policy,
    required int limit,
  }) async {
    final questions = switch (mode) {
      StudyMode.choice => await _buildChoice(profile, policy, limit),
      StudyMode.speed => await _buildSpeed(profile, limit),
      StudyMode.confusion => await _buildConfusion(profile, limit),
      StudyMode.parts => await _buildParts(profile, limit),
      _ => throw StateError('選択式で扱わないモード: $mode'),
    };
    await _ref
        .read(choiceSessionProvider.notifier)
        .startWith(profile: profile, mode: mode, questions: questions);
  }

  Future<List<ChoiceQuestion>> _buildChoice(
    Profile profile,
    QueuePolicy policy,
    int limit,
  ) async {
    final pool = await _ref
        .read(modeRepositoryProvider)
        .loadChoiceCandidates(profile);
    if (pool.length < ChoiceDistractors.optionCount) {
      // 4つ揃わない単語帳ではこのモードを出さない（ダミーで埋めない。FR-29）。
      throw const StudyStartFailure('4択にするには、学習対象の語が4語以上必要です。');
    }

    final candidates = await _ref
        .read(studyRepositoryProvider)
        .loadCandidates(profile);
    final seed = DateTime.now().microsecondsSinceEpoch;
    final queue = StudyQueueBuilder.build(
      candidates: candidates,
      policy: policy,
      limit: limit,
      now: _ref.read(clockProvider)(),
      shuffleSeed: seed,
    );
    final questions = ChoiceQuestionBuilder.build(
      queue: queue,
      byId: {for (final c in pool) c.wordId: c},
      pool: pool,
      preference: ChoiceDirection.fromValue(profile.choiceDirection),
      random: Random(seed),
    );
    if (questions.isEmpty) {
      throw const StudyStartFailure('選んだ単語帳に出題できる語がありません。');
    }
    return questions;
  }

  /// スピードは**すでに学習した語だけ**を対象にする。未学習の語を制限時間つきで
  /// 出しても、考える時間が無いだけで何も身に付かない。
  Future<List<ChoiceQuestion>> _buildSpeed(Profile profile, int limit) async {
    final repo = _ref.read(modeRepositoryProvider);
    final learned = await repo.loadChoiceCandidates(profile, learnedOnly: true);
    if (learned.length < kSpeedMinWords) {
      throw const StudyStartFailure('スピードは学習済みの語が$kSpeedMinWords語以上必要です。');
    }
    // 誤答選択肢は学習済みに限らず全候補から選んでよい。
    final pool = await repo.loadChoiceCandidates(profile);
    final seed = DateTime.now().microsecondsSinceEpoch;
    final random = Random(seed);
    final order = [...learned]..shuffle(random);

    return ChoiceQuestionBuilder.build(
      queue: [
        for (final c in order.take(kSpeedQuestionCount))
          QueuedItem(wordId: c.wordId, source: QueueSource.due),
      ],
      byId: {for (final c in pool) c.wordId: c},
      pool: pool,
      preference: ChoiceDirection.fromValue(profile.choiceDirection),
      random: random,
    );
  }

  /// 語のつくり（[Docs/06_features/word_parts.md] §5）。
  ///
  /// 出題対象は**紐付いた単語が3語以上ある部品**だけ。1語しか繋がっていない部品を
  /// 覚えても応用が利かない。3問に1問は推測問題を混ぜるが、条件を満たす語が無ければ
  /// 無理に作らない。
  Future<List<ChoiceQuestion>> _buildParts(Profile profile, int limit) async {
    final repo = _ref.read(modeRepositoryProvider);
    final parts = await repo.loadPartCandidates(profile.id);
    if (parts.length < PartsQuestionBuilder.optionCount) {
      throw const StudyStartFailure('語のつくりを出すには、単語に紐付いた部品がもう少し必要です。');
    }
    final guesses = await repo.loadGuessCandidates(profile);
    final built = PartsQuestionBuilder.build(
      parts: parts,
      guesses: guesses,
      limit: limit,
      random: Random(DateTime.now().microsecondsSinceEpoch),
    );
    if (built.isEmpty) {
      throw const StudyStartFailure('語のつくりの問題を作れませんでした。');
    }
    return [
      for (final q in built)
        ChoiceQuestion(
          prompt: q.prompt,
          hint: q.hint,
          options: q.options,
          answerIndex: q.answerIndex,
          direction: StudyDirection.enToJa,
          explanation: q.explanation,
          partId: q.partId,
          // 推測問題は正解しても学習状態を作らない。
          wordId: q.isGuess ? q.guessWordId : null,
          guessOnly: q.isGuess,
        ),
    ];
  }

  Future<List<ChoiceQuestion>> _buildConfusion(
    Profile profile,
    int limit,
  ) async {
    final repo = _ref.read(modeRepositoryProvider);
    final now = _ref.read(clockProvider)();
    final pairs = await repo.findConfusionPairs(profile.id, now: now);
    if (pairs.isEmpty) {
      throw const StudyStartFailure('いまのところ、取り違えている組は見つかっていません。');
    }
    final words = await repo.loadConfusionWords(profile.id);
    final byId = {for (final w in words) w.wordId: w};
    final ids = {
      for (final p in pairs) ...[p.wordIdA, p.wordIdB],
    };
    final details = await repo.loadConfusionDetails(ids);

    final questions = ConfusionQuestionBuilder.build(
      pairs: pairs,
      byId: byId,
      partOfSpeechLabels: details.labels,
      confusionNotes: details.notes,
      random: Random(DateTime.now().microsecondsSinceEpoch),
    );
    return questions.take(limit).toList();
  }
}

/// スピードモードに要る学習済み語数の下限（[Docs/06_features/speed_mode.md] §3）。
const kSpeedMinWords = 20;

/// スピードモードの出題数（§2）。
const kSpeedQuestionCount = 50;

final studyLauncherProvider = Provider<StudyLauncher>(
  (ref) => StudyLauncher(ref),
);
