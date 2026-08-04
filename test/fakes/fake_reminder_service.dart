import 'package:encello/domain/services/reminder_service.dart';

/// 実機の通知プラグインに触れないフェイク（[Docs/07_testing_strategy.md] §4）。
///
/// `SessionResultScreen` がセッション終了後に呼ぶ `reminderSchedulerProvider` は、
/// 本物の実装（`NotificationService`）だと flutter_local_notifications /
/// flutter_timezone のプラットフォームチャネルに依存し、ウィジェットテストでは
/// 解決せず `pumpAndSettle` がタイムアウトする。テストでは常にこちらへ差し替える。
class FakeReminderService implements ReminderService {
  FakeReminderService({
    this.permitted = true,
    this.grantOnRequest = true,
    this.launchedProfileId,
  });

  /// すでに通知が許可されているか。許可を求めて通れば true になる。
  bool permitted;

  /// 権限を求めたときに許可されるか。
  final bool grantOnRequest;

  /// 通知タップで起動したときのプロファイル id。
  final int? launchedProfileId;

  /// [reschedule] で最後に渡された内容（profileId → plan）。
  final Map<int, ReminderPlan> rescheduled = {};

  /// [cancel] された profileId（呼ばれた順）。
  final List<int> cancelled = [];

  /// [sendTest] の呼び出し内容。
  final sentTests = <({int profileId, String title, String body})>[];

  @override
  Future<bool> hasPermission() async => permitted;

  @override
  Future<bool> requestPermission() async {
    requestCount++;
    if (grantOnRequest) permitted = true;
    return permitted;
  }

  /// 権限を求めた回数（起動時に求めていないことの確認に使う）。
  int requestCount = 0;

  @override
  Future<void> reschedule(int profileId, ReminderPlan plan) async {
    rescheduled[profileId] = plan;
  }

  @override
  Future<void> cancel(int profileId) async {
    rescheduled.remove(profileId);
    cancelled.add(profileId);
  }

  @override
  Future<void> sendTest(int profileId, String title, String body) async {
    sentTests.add((profileId: profileId, title: title, body: body));
  }

  @override
  Future<int?> launchProfileId() async => launchedProfileId;
}
