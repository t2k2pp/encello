import 'package:drift/drift.dart';
import 'package:meta/meta.dart';

import '../data/database/app_database.dart';
import '../data/repositories/study_repository.dart';

/// セッションの成績（結果画面が見る値）。
@immutable
class SessionSummary {
  final StudySession session;

  /// 間違えた語（惜しいを含む）。出題順。
  final List<Word> missedWords;

  const SessionSummary({required this.session, required this.missedWords});

  int get answeredCount => session.answeredCount;

  int get correctCount => session.correctCount;

  /// 正解率（0.0〜1.0）。1問も解いていなければ null。
  double? get accuracy =>
      answeredCount == 0 ? null : correctCount / answeredCount;

  Duration get elapsed =>
      (session.finishedAt ?? session.startedAt).difference(session.startedAt);
}

/// セッションの確定（[Docs/02_architecture.md] §1.1）。
///
/// 中断で終わったセッションは `finishedAt` を null のままにする。
/// 実績の解除判定とリマインダーの予約し直しは、それぞれの機能が入った時点でここに足す。
class SessionFinalizer {
  final AppDatabase _db;
  final StudyRepository _study;

  SessionFinalizer(this._db) : _study = StudyRepository(_db);

  /// セッションを終了として確定し、結果画面に出す成績を返す。
  Future<SessionSummary> finish({
    required String sessionId,
    required DateTime finishedAt,

    /// スピードモードでのみ。時間内正解だけの平均反応時間（ミリ秒）。
    int? avgReactionMs,
  }) async {
    await (_db.update(_db.studySessions)..where((t) => t.id.equals(sessionId)))
        .write(
          StudySessionsCompanion(
            finishedAt: Value(finishedAt),
            avgReactionMs: Value(avgReactionMs),
          ),
        );
    return summarize(sessionId);
  }

  /// 途中で中断したセッション。すでに解答した分は保存済みなので破棄しない。
  /// `finishedAt` を入れないことで「中断のまま終わった」と分かるようにする。
  Future<void> abort(String sessionId) async {
    // 1問も解いていない中断は記録として意味が無いため行ごと消す。
    final session = await _study.findSession(sessionId);
    if (session == null) return;
    if (session.answeredCount == 0) {
      await (_db.delete(_db.studySessions)
            ..where((t) => t.id.equals(sessionId)))
          .go();
    }
  }

  Future<SessionSummary> summarize(String sessionId) async {
    final session = await _study.findSession(sessionId);
    if (session == null) {
      throw StateError('セッションが見つかりません（id=$sessionId）');
    }
    final logs = await _study.logsOf(sessionId);

    // 同じ語を2回出題した場合（誤答の再出題）、最後の解答で判断する。
    final lastByWord = <int, LearningLog>{};
    for (final log in logs) {
      final wordId = log.wordId;
      if (wordId != null) lastByWord[wordId] = log;
    }
    final missedIds = [
      for (final entry in lastByWord.entries)
        if (!entry.value.isCorrect) entry.key,
    ];
    final words = await _study.loadWords(missedIds);

    return SessionSummary(
      session: session,
      missedWords: [
        for (final id in missedIds)
          if (words[id] != null) words[id]!,
      ],
    );
  }
}
