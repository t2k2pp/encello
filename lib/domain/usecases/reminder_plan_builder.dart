import '../services/reminder_service.dart';

/// リマインダーの予約内容を組み立てる（[Docs/06_features/reminders.md] §2・§3）。純粋関数。
///
/// 通知本文には件数が入るため、内容は**予約時点の見込み**になる。
/// アプリを開いたとき・セッションを終えたとき・設定を変えたときに作り直して、
/// 実際とのずれを最小にする。
abstract final class ReminderPlanBuilder {
  /// 何日先まで予約するか。
  static const scheduleDays = 7;

  /// 「続いています」の呼びかけを添えるストリークの下限。
  static const streakMentionDays = 3;

  /// 通知のタイトル。
  static const title = 'encello';

  /// [now] 以降の直近 [scheduleDays] 日ぶんの通知を作る。
  ///
  /// - 今日ぶんは、指定時刻を過ぎている場合と、**すでに目標を達成している**場合は
  ///   作らない（達成した人に「やれ」と言わない）。
  /// - [dueCountAt] には、その通知時刻の時点で期限が来ている復習の語数を渡す。
  static ReminderPlan build({
    required String profileName,
    required int hour,
    required int minute,
    required DateTime now,
    required bool goalMetToday,
    required int streakDays,
    required int Function(DateTime at) dueCountAt,
  }) {
    final notices = <ReminderNotice>[];
    for (var offset = 0; offset < scheduleDays; offset++) {
      final day = DateTime(now.year, now.month, now.day + offset);
      final at = DateTime(day.year, day.month, day.day, hour, minute);
      if (!at.isAfter(now)) continue;
      if (offset == 0 && goalMetToday) continue;
      notices.add(
        ReminderNotice(
          at: at,
          body: bodyOf(
            profileName: profileName,
            dueCount: dueCountAt(at),
            // ストリークの呼びかけは今日ぶんにだけ添える。翌日以降は、その日の
            // 達成状況で変わるため断定できない。
            streakDays: offset == 0 ? streakDays : 0,
          ),
        ),
      );
    }
    return ReminderPlan(title: title, notices: notices);
  }

  /// 通知の本文（[Docs/06_features/reminders.md] §2）。
  ///
  /// **プロファイル名を入れる**（1台を複数人で使うため、誰宛かが分からないと
  /// 機能しない）。「ストリークが切れます」のような脅す文言は使わない。
  static String bodyOf({
    required String profileName,
    required int dueCount,
    required int streakDays,
  }) {
    if (streakDays >= streakMentionDays && dueCount > 0) {
      return '$profileNameさん、$streakDays日続いています。今日の復習は$dueCount語です';
    }
    if (dueCount > 0) {
      return '$profileNameさん、今日の復習が$dueCount語あります';
    }
    if (streakDays >= streakMentionDays) {
      return '$profileNameさん、$streakDays日続いています。今日はまだ学習していません';
    }
    return '$profileNameさん、今日はまだ学習していません。新しい単語はいかがですか';
  }
}
