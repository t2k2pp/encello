// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_dao.dart';

// ignore_for_file: type=lint
mixin _$ProfileDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $WordFamiliesTable get wordFamilies => attachedDatabase.wordFamilies;
  $WordsTable get words => attachedDatabase.words;
  $WordReviewsTable get wordReviews => attachedDatabase.wordReviews;
  $StudySessionsTable get studySessions => attachedDatabase.studySessions;
  $WordPartsTable get wordParts => attachedDatabase.wordParts;
  $LearningLogsTable get learningLogs => attachedDatabase.learningLogs;
  $DailyStatsTable get dailyStats => attachedDatabase.dailyStats;
  ProfileDaoManager get managers => ProfileDaoManager(this);
}

class ProfileDaoManager {
  final _$ProfileDaoMixin _db;
  ProfileDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$WordFamiliesTableTableManager get wordFamilies =>
      $$WordFamiliesTableTableManager(_db.attachedDatabase, _db.wordFamilies);
  $$WordsTableTableManager get words =>
      $$WordsTableTableManager(_db.attachedDatabase, _db.words);
  $$WordReviewsTableTableManager get wordReviews =>
      $$WordReviewsTableTableManager(_db.attachedDatabase, _db.wordReviews);
  $$StudySessionsTableTableManager get studySessions =>
      $$StudySessionsTableTableManager(_db.attachedDatabase, _db.studySessions);
  $$WordPartsTableTableManager get wordParts =>
      $$WordPartsTableTableManager(_db.attachedDatabase, _db.wordParts);
  $$LearningLogsTableTableManager get learningLogs =>
      $$LearningLogsTableTableManager(_db.attachedDatabase, _db.learningLogs);
  $$DailyStatsTableTableManager get dailyStats =>
      $$DailyStatsTableTableManager(_db.attachedDatabase, _db.dailyStats);
}
