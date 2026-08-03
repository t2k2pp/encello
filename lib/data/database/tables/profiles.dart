import 'package:drift/drift.dart';

/// 学習者（[Docs/06_features/profiles.md] §2）。
///
/// 1台の端末を複数人で使う前提。単語そのものは全員で共有し、学習の記録だけを
/// 人ごとに分ける。**学習設定と表示設定は SharedPreferences ではなくこの表の列に持つ**
/// （学習者を切り替えたら設定も一緒に切り替わる必要があるため）。
///
/// 行が1件も無い状態は許さない。最初の学習者は初回起動時に作らせる。
class Profiles extends Table {
  IntColumn get id => integer().autoIncrement()();

  // --- 識別 ---
  TextColumn get name => text().withLength(min: 1, max: 20)();
  TextColumn get emoji => text().withDefault(const Constant('🙂'))();

  /// 識別色の割当シード（`AppColors.seedColor(colorSeed)`）。
  IntColumn get colorSeed => integer()();

  // --- 表示設定 ---

  /// テーマ配色 id（`AppPalette.id`）。人ごとに変えられる。
  TextColumn get palette => text().withDefault(const Constant('pink'))();
  TextColumn get textScale => text().withDefault(const Constant('medium'))();
  TextColumn get density => text().withDefault(const Constant('standard'))();
  TextColumn get dictViewMode => text().withDefault(const Constant('list'))();

  /// 辞書グリッドの列数。`auto` または `2` / `3` / `4`。
  TextColumn get dictGridColumns => text().withDefault(const Constant('auto'))();

  /// 辞書の検索対象に例文を含めるか。
  BoolColumn get searchExamples =>
      boolean().withDefault(const Constant(false))();

  // --- 学習設定 ---
  IntColumn get dailyGoal => integer().withDefault(const Constant(20))();
  IntColumn get sessionSize => integer().withDefault(const Constant(20))();
  TextColumn get keyboardLayout =>
      text().withDefault(const Constant('qwerty'))();
  BoolColumn get autoNextOnCorrect =>
      boolean().withDefault(const Constant(false))();
  TextColumn get flashcardMode =>
      text().withDefault(const Constant('silentAuto'))();
  IntColumn get flashcardSeconds => integer().withDefault(const Constant(3))();
  TextColumn get choiceDirection =>
      text().withDefault(const Constant('random'))();

  /// スピードモードの制限時間（ミリ秒）。
  IntColumn get speedLimitMs => integer().withDefault(const Constant(3000))();

  /// 学習対象の単語帳 id（JSON 配列）。
  TextColumn get selectedWordbookIds =>
      text().withDefault(const Constant('[]'))();

  // --- 音声設定 ---

  /// 音源の優先順位（`AudioSourcePreference`）。
  TextColumn get audioSource =>
      text().withDefault(const Constant('fileFirst'))();

  /// 使用する音声パック id（JSON 配列。優先順）。
  TextColumn get audioPackIds => text().withDefault(const Constant('[]'))();
  TextColumn get ttsEnVoice => text().withDefault(const Constant(''))();
  TextColumn get ttsJaVoice => text().withDefault(const Constant(''))();
  RealColumn get ttsRate => real().withDefault(const Constant(0.5))();
  RealColumn get ttsPitch => real().withDefault(const Constant(1.0))();

  // --- 学習リマインダー ---
  BoolColumn get reminderEnabled =>
      boolean().withDefault(const Constant(false))();
  IntColumn get reminderHour => integer().withDefault(const Constant(19))();
  IntColumn get reminderMinute => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
