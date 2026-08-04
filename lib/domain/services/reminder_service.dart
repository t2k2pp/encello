import 'package:meta/meta.dart';

/// 予約する通知1件（[Docs/06_features/reminders.md] §2）。
@immutable
class ReminderNotice {
  /// 鳴らす時刻（ローカル）。
  final DateTime at;

  /// 本文。プロファイル名と件数を含める（1台を複数人で使うため、
  /// 誰宛かが分からないと機能しない）。
  final String body;

  const ReminderNotice({required this.at, required this.body});
}

/// あるプロファイルの予約内容。
@immutable
class ReminderPlan {
  /// 通知のタイトル。誰宛かは本文の呼びかけで示すため、ここはアプリ名にする。
  final String title;

  /// 予約する通知（**7日分まで**）。空なら予約しない（取り消しだけを行う）。
  final List<ReminderNotice> notices;

  const ReminderPlan({required this.title, required this.notices});

  static const empty = ReminderPlan(title: '', notices: []);
}

/// 学習リマインダーの抽象（[Docs/06_features/reminders.md] §7）。
///
/// 実装は `data/services/notification_service.dart`。テストではフェイクを注入し、
/// 予約された内容（時刻・本文・件数）を検証する。実機の通知に依存したテストを書かない。
abstract class ReminderService {
  /// 通知の権限があるか。
  Future<bool> hasPermission();

  /// 権限を求める。**起動時には呼ばない**。設定でリマインダーを ON に
  /// しようとしたときに初めて呼ぶ（何のための許可かが分かる場面で聞く）。
  Future<bool> requestPermission();

  /// [profileId] の通知を予約し直す。既存は取り消してから入れる。
  Future<void> reschedule(int profileId, ReminderPlan plan);

  /// [profileId] の通知をすべて取り消す。
  Future<void> cancel(int profileId);

  /// 5秒後にテスト通知を1通出す（実際に鳴るかを確かめるため）。
  Future<void> sendTest(int profileId, String title, String body);

  /// 通知タップでアプリが起動したときの `payload`（プロファイル id）。
  /// 通知以外での起動なら null。
  Future<int?> launchProfileId();
}
