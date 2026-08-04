import 'dart:io' show Platform;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/services/reminder_service.dart';

/// 学習リマインダーの実装（[Docs/06_features/reminders.md]）。
///
/// `zonedSchedule` を **`AndroidScheduleMode.inexactAllowWhileIdle`** で使う。
/// 1日1回の学習リマインダーに秒単位の正確さは要らないため、
/// `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM` を要求しない（Android 14 以降の
/// 追加の権限確認とストア審査の説明を避ける。数分のずれと引き換えにする）。
class NotificationService implements ReminderService {
  final FlutterLocalNotificationsPlugin _plugin;

  /// 通知チャンネル（Android）。
  static const channelId = 'study_reminder';
  static const channelName = '学習リマインダー';
  static const channelDescription = '毎日きまった時刻に、その日の復習をお知らせします。';

  /// 1プロファイルあたりに確保する通知 id の幅。7日分を個別に予約するため、
  /// プロファイルごとに連番のブロックを割り当てる（[Docs/06_features/reminders.md] §3）。
  static const idsPerProfile = 10;

  /// 通知 id の起点。
  static const idBase = 1000;

  /// 何日先まで予約するか。これ以降は次回起動時に作り直す
  /// （古い件数の通知を延々と出し続けない）。
  static const scheduleDays = 7;

  bool _initialized = false;

  NotificationService([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  /// 通知プラグインとタイムゾーンを初期化する。**起動をブロックしない**
  /// （[Docs/02_architecture.md] §4）。何度呼んでも1回だけ実行する。
  Future<void> ensureInitialized() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    // 端末のタイムゾーン名（IANA）を OS から取る。UTC オフセットから推測すると
    // 夏時間のある地域で1年のうち半分ずれる。
    final zone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone.identifier));

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // 権限は起動時に求めない。設定で ON にしようとしたときに初めて求める
        // （[Docs/06_features/reminders.md] §4）。
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _initialized = true;
  }

  @override
  Future<bool> hasPermission() async {
    await ensureInitialized();
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.areNotificationsEnabled() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final options = await ios?.checkPermissions();
    return options?.isEnabled ?? false;
  }

  @override
  Future<bool> requestPermission() async {
    await ensureInitialized();
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await ios?.requestPermissions(alert: true, badge: true, sound: true) ??
        false;
  }

  @override
  Future<void> reschedule(int profileId, ReminderPlan plan) async {
    await ensureInitialized();
    await cancel(profileId);
    // 予約は7日分まで。8日目以降は次回起動時に、そのときの件数で作り直す。
    final notices = plan.notices.take(scheduleDays).toList();
    for (var i = 0; i < notices.length; i++) {
      final notice = notices[i];
      await _plugin.zonedSchedule(
        id: _idOf(profileId, i),
        title: plan.title,
        body: notice.body,
        scheduledDate: tz.TZDateTime.from(notice.at, tz.local),
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        // 通知のプロファイルへ切り替えてからホームを開くために id を持たせる。
        payload: '$profileId',
      );
    }
  }

  @override
  Future<void> cancel(int profileId) async {
    await ensureInitialized();
    for (var i = 0; i < idsPerProfile; i++) {
      await _plugin.cancel(id: _idOf(profileId, i));
    }
  }

  @override
  Future<void> sendTest(int profileId, String title, String body) async {
    await ensureInitialized();
    // 実際に鳴るかを確かめられるよう5秒後に出す。予約枠とは別の id を使い、
    // 本来のリマインダーを潰さない。
    await _plugin.zonedSchedule(
      id: _idOf(profileId, idsPerProfile - 1),
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: '$profileId',
    );
  }

  @override
  Future<int?> launchProfileId() async {
    await ensureInitialized();
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details == null || !details.didNotificationLaunchApp) return null;
    final payload = details.notificationResponse?.payload;
    if (payload == null) return null;
    return int.tryParse(payload);
  }

  /// プロファイルごとに連番のブロックを割り当てる。
  /// 最後の1つ（[idsPerProfile] - 1）はテスト通知に使う。
  static int _idOf(int profileId, int index) =>
      idBase + profileId * idsPerProfile + index;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
    iOS: DarwinNotificationDetails(),
  );
}
