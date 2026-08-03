import 'package:drift/drift.dart';

import 'profiles.dart';
import 'word_parts.dart';
import 'words.dart';

/// 学習状態（[Docs/03_data_model.md] §2.5）。
///
/// 行は**初めてその単語を解いたときに作る**。未学習語には行が無い。
///
/// 絞り込みは必ず学習者との複合で行うため、インデックスも複合にする。
@TableIndex(name: 'word_reviews_profile_due', columns: {#profileId, #dueAt})
@TableIndex(
  name: 'word_reviews_profile_mastery',
  columns: {#profileId, #masteryLevel},
)
class WordReviews extends Table {
  IntColumn get profileId =>
      integer().references(Profiles, #id, onDelete: KeyAction.cascade)();
  IntColumn get wordId =>
      integer().references(Words, #id, onDelete: KeyAction.cascade)();

  /// 連続正解回数（SM-2 の n）。
  IntColumn get repetition => integer().withDefault(const Constant(0))();

  /// 現在の出題間隔（日）。
  RealColumn get intervalDays => real().withDefault(const Constant(0))();

  /// 容易度係数。下限 1.3。
  RealColumn get easeFactor => real().withDefault(const Constant(2.5))();

  /// 次回出題日時。
  DateTimeColumn get dueAt => dateTime()();

  DateTimeColumn get lastReviewedAt => dateTime().nullable()();
  DateTimeColumn get firstLearnedAt => dateTime().nullable()();

  IntColumn get lapses => integer().withDefault(const Constant(0))();
  IntColumn get correctStreak => integer().withDefault(const Constant(0))();
  IntColumn get totalCorrect => integer().withDefault(const Constant(0))();
  IntColumn get totalIncorrect => integer().withDefault(const Constant(0))();

  /// 導出値（`Mastery.from`）。絞り込み・並べ替えにインデックスが要るため列に持つ。
  IntColumn get masteryLevel => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {profileId, wordId};
}

/// 語の部品の学習状態（[Docs/03_data_model.md] §2.6）。
///
/// `word_reviews` と同じ形にすることで、同一の `Sm2Scheduler` と `Mastery` を使い回す。
@TableIndex(name: 'part_reviews_profile_due', columns: {#profileId, #dueAt})
class PartReviews extends Table {
  IntColumn get profileId =>
      integer().references(Profiles, #id, onDelete: KeyAction.cascade)();
  IntColumn get partId =>
      integer().references(WordParts, #id, onDelete: KeyAction.cascade)();

  IntColumn get repetition => integer().withDefault(const Constant(0))();
  RealColumn get intervalDays => real().withDefault(const Constant(0))();
  RealColumn get easeFactor => real().withDefault(const Constant(2.5))();
  DateTimeColumn get dueAt => dateTime()();
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();
  DateTimeColumn get firstLearnedAt => dateTime().nullable()();
  IntColumn get lapses => integer().withDefault(const Constant(0))();
  IntColumn get correctStreak => integer().withDefault(const Constant(0))();
  IntColumn get totalCorrect => integer().withDefault(const Constant(0))();
  IntColumn get totalIncorrect => integer().withDefault(const Constant(0))();
  IntColumn get masteryLevel => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {profileId, partId};
}

/// 解消した取り違えの組（[Docs/03_data_model.md] §2.14）。
///
/// **必ず `wordIdA < wordIdB` で正規化して保存する**（組に向きを持たせない）。
class ResolvedConfusions extends Table {
  IntColumn get profileId =>
      integer().references(Profiles, #id, onDelete: KeyAction.cascade)();
  @ReferenceName('resolvedConfusionsAsA')
  IntColumn get wordIdA =>
      integer().references(Words, #id, onDelete: KeyAction.cascade)();

  @ReferenceName('resolvedConfusionsAsB')
  IntColumn get wordIdB =>
      integer().references(Words, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get resolvedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {profileId, wordIdA, wordIdB};
}
