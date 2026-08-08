import 'package:drift/drift.dart';

import 'profiles.dart';
import 'word_parts.dart';
import 'words.dart';

/// 学習セッション（[Docs/03_data_model.md] §2.8）。
@TableIndex(
  name: 'study_sessions_profile_started',
  columns: {#profileId, #startedAt},
)
class StudySessions extends Table {
  /// UUID v4。
  TextColumn get id => text()();

  IntColumn get profileId =>
      integer().references(Profiles, #id, onDelete: KeyAction.cascade)();

  /// 学習モード（`StudyMode`）。
  TextColumn get mode => text()();

  /// 対象単語帳の id を JSON 配列で持つ（履歴の再現用）。
  TextColumn get wordbookIds => text().withDefault(const Constant('[]'))();

  DateTimeColumn get startedAt => dateTime()();

  /// null = 中断のまま終わった。
  DateTimeColumn get finishedAt => dateTime().nullable()();

  IntColumn get plannedCount => integer().withDefault(const Constant(0))();
  IntColumn get answeredCount => integer().withDefault(const Constant(0))();
  IntColumn get correctCount => integer().withDefault(const Constant(0))();
  IntColumn get xpEarned => integer().withDefault(const Constant(0))();

  /// スピードモードでのみ。時間内正解のみの平均反応時間（ミリ秒）。
  IntColumn get avgReactionMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// 解答履歴（[Docs/03_data_model.md] §2.7）。
///
/// `wordId` と `partId` は**どちらか一方だけが非 null**になる。両方 null、または
/// 両方非 null の行は作らない（リポジトリで保証する）。
@TableIndex(
  name: 'learning_logs_profile_answered',
  columns: {#profileId, #answeredAt},
)
@TableIndex(name: 'learning_logs_session_id', columns: {#sessionId})
@TableIndex(name: 'learning_logs_word_id', columns: {#wordId})
class LearningLogs extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get profileId =>
      integer().references(Profiles, #id, onDelete: KeyAction.cascade)();
  TextColumn get sessionId =>
      text().references(StudySessions, #id, onDelete: KeyAction.cascade)();

  /// 語のつくりモードでは null。
  IntColumn get wordId => integer().nullable().references(
    Words,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// 語のつくりモードでのみ非 null。
  IntColumn get partId => integer().nullable().references(
    WordParts,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// 学習モード（`StudyMode`）。
  TextColumn get mode => text()();

  /// 出題方向（`StudyDirection`）。
  TextColumn get direction => text()();

  BoolColumn get isCorrect => boolean()();

  /// SM-2 に渡した grade（0〜5）。`-1` = 学習状態を更新しなかった（時間切れ等）。
  IntColumn get grade => integer()();

  /// 入力した文字列／選んだ選択肢。取り違え検出に使う。
  TextColumn get answeredText => text().nullable()();

  /// 開示したヒント文字数。
  IntColumn get hintUsed => integer().withDefault(const Constant(0))();

  /// 音声の再生回数。
  IntColumn get replayCount => integer().withDefault(const Constant(0))();

  /// 出題表示から解答確定までの時間（ミリ秒）。
  IntColumn get elapsedMs => integer()();

  DateTimeColumn get answeredAt => dateTime()();
}

/// 日次集計（[Docs/03_data_model.md] §2.9）。
///
/// `learning_logs` から毎回集計せず、解答と同一トランザクションで積み上げる。
class DailyStats extends Table {
  IntColumn get profileId =>
      integer().references(Profiles, #id, onDelete: KeyAction.cascade)();

  /// `YYYY-MM-DD`。学習日の境界（04:00）で決める（`studyDateOf`）。
  TextColumn get studyDate => text()();

  IntColumn get answeredCount => integer().withDefault(const Constant(0))();
  IntColumn get correctCount => integer().withDefault(const Constant(0))();
  IntColumn get xp => integer().withDefault(const Constant(0))();
  IntColumn get studySeconds => integer().withDefault(const Constant(0))();

  /// その日に適用されていた目標（後から変えても過去を動かさない）。
  IntColumn get goalCount => integer()();

  /// 達成した時点で true。以後 false に戻さない。
  BoolColumn get goalMet => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {profileId, studyDate};
}

/// 実績（[Docs/03_data_model.md] §2.15）。
/// 解除条件は `application/achievement_evaluator.dart` に定義し、DB には解除済みだけを残す。
class Achievements extends Table {
  IntColumn get profileId =>
      integer().references(Profiles, #id, onDelete: KeyAction.cascade)();

  /// 実績コード（例 `streak_7`、`mastered_100`）。
  TextColumn get code => text()();

  DateTimeColumn get unlockedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {profileId, code};
}

/// 語彙力測定の履歴（[Docs/03_data_model.md] §2.10）。
@TableIndex(
  name: 'vocab_size_tests_profile_taken',
  columns: {#profileId, #takenAt},
)
class VocabSizeTests extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get profileId =>
      integer().references(Profiles, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get takenAt => dateTime()();

  /// 推定語彙数。
  IntColumn get estimatedSize => integer()();

  /// 擬似語に「わかる」と答えた率。
  RealColumn get falseAlarmRate => real()();

  /// 帯ごとの補正済み正答率と出題数を JSON で。
  TextColumn get bandResults => text().withDefault(const Constant('[]'))();

  /// 出題した実在語の id（次回の重複回避用）を JSON で。
  TextColumn get askedWordIds => text().withDefault(const Constant('[]'))();
}
