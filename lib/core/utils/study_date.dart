/// 学習日の境界（[Docs/03_data_model.md] §6）。
///
/// 学習日は**端末ローカル時刻の 04:00 区切り**とする。深夜1時の学習を前日の続きとして
/// 数え、ストリークが理不尽に切れないようにするため。
///
/// `daily_stats.studyDate`・ストリーク計算・「今日の復習」の判定は、すべてここを通す。
/// `dueAt` の比較だけは実時刻で行う（間隔反復は暦日ではなく経過時間で決まるため）。
library;

import 'package:intl/intl.dart';

/// 学習日の切り替わり時刻（時）。
const studyDayStartHour = 4;

final _studyDateFormat = DateFormat('yyyy-MM-dd');

/// ローカル時刻 [local] が属する学習日（`YYYY-MM-DD`）。
String studyDateOf(DateTime local) =>
    _studyDateFormat.format(local.subtract(const Duration(hours: studyDayStartHour)));

/// ローカル時刻 [local] が属する学習日の起点（その日の 04:00）。
///
/// SM-2 の `dueAt` は解答時刻ではなくこの起点に間隔を足す
/// （[Docs/06_features/srs_scheduler.md] §4）。
DateTime studyDayStart(DateTime local) {
  final shifted = local.subtract(const Duration(hours: studyDayStartHour));
  return DateTime(shifted.year, shifted.month, shifted.day, studyDayStartHour);
}

/// 学習日 [studyDate]（`YYYY-MM-DD`）の起点（その日の 04:00）。
DateTime studyDayStartOfDate(String studyDate) {
  final d = _studyDateFormat.parseStrict(studyDate);
  return DateTime(d.year, d.month, d.day, studyDayStartHour);
}
