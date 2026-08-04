import 'package:drift/drift.dart' show BooleanExpressionOperators;
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
// StateProvider は Riverpod 3 で legacy 扱い（rootTabIndexProvider で使用）。
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../application/ai_import_service.dart';
import '../data/services/export_import_service.dart';
import '../data/services/file_exchange_service_impl.dart';
import '../domain/services/file_exchange_service.dart';
import '../application/answer_submission_service.dart';
import '../application/choice_session_controller.dart';
import '../application/flashcard_controller.dart';
import '../application/session_finalizer.dart';
import '../application/study_session_controller.dart';
import '../core/theme/app_colors.dart';
import '../data/database/app_database.dart';
import '../data/repositories/mode_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/study_repository.dart';
import '../data/repositories/word_repository.dart';
import '../data/repositories/wordbook_repository.dart';
import '../data/seeds/prompt_assets.dart';
import '../data/seeds/seed_importer.dart';

/// 端末レベルの設定キー（[Docs/03_data_model.md] §8）。
/// 学習者ごとの設定は `profiles` の列に持つため、prefs にはこれだけを置く。
const kLastActiveProfileKey = 'profile.lastActiveId';
const kSeedInstalledVersionKey = 'seed.installedVersion';

/// 起動時に読み込んだ SharedPreferences。[BootstrapGate] で override する。
final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('BootstrapGate で override すること'),
);

/// DB（アプリ全体で単一）。テストでは override する。
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(null);
  ref.onDispose(db.close);
  return db;
});

/// 現在時刻。時刻に依存するロジックをテストで固定できるよう Provider 越しに取る
/// （[Docs/07_testing_strategy.md] §3.5）。
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(databaseProvider)),
);

final wordRepositoryProvider = Provider<WordRepository>(
  (ref) => WordRepository(ref.watch(databaseProvider)),
);

final wordbookRepositoryProvider = Provider<WordbookRepository>(
  (ref) => WordbookRepository(ref.watch(databaseProvider)),
);

final studyRepositoryProvider = Provider<StudyRepository>(
  (ref) => StudyRepository(ref.watch(databaseProvider)),
);

/// 1問の解答を1トランザクションで確定する（[Docs/02_architecture.md] §1.1）。
final answerSubmissionServiceProvider = Provider<AnswerSubmissionService>(
  (ref) => AnswerSubmissionService(ref.watch(databaseProvider)),
);

final sessionFinalizerProvider = Provider<SessionFinalizer>(
  (ref) => SessionFinalizer(ref.watch(databaseProvider)),
);

/// 進行中の学習セッション。null = セッション外。
final studySessionProvider =
    NotifierProvider<StudySessionController, StudySessionState?>(
      StudySessionController.new,
    );

final modeRepositoryProvider = Provider<ModeRepository>(
  (ref) => ModeRepository(ref.watch(databaseProvider)),
);

/// 進行中の選択式セッション（4択・スピード・語のつくり・取り違え）。
final choiceSessionProvider =
    NotifierProvider<ChoiceSessionController, ChoiceSessionState?>(
      ChoiceSessionController.new,
    );

/// 進行中のフラッシュカード。null = セッション外。
final flashcardProvider =
    NotifierProvider<FlashcardController, FlashcardState?>(
      FlashcardController.new,
    );

/// 「今日の復習 N語」（[Docs/06_features/srs_scheduler.md] §7）。
final dueCountProvider = StreamProvider.family<int, Profile>(
  (ref, profile) => ref
      .watch(studyRepositoryProvider)
      .watchDueCount(profile, ref.watch(clockProvider)),
);

/// 現在の学習者が選んでいる単語帳にある「出題できる語」の数。
/// 0 のときは学習を始められないため、シェルの FAB を出さない。
final studyableWordCountProvider = FutureProvider.family<int, Profile>(
  (ref, profile) => ref.watch(wordRepositoryProvider).countStudyable(profile),
);

/// 自分のマイ単語の下書き数（[Docs/06_features/my_words.md] §3）。
/// ホームの下書きカードとマイ単語画面（SCR-17）の「訳を書く」ボタンが見る。
final myWordsDraftCountProvider = StreamProvider.family<int, int>(
  (ref, profileId) =>
      ref.watch(wordRepositoryProvider).watchDraftCount(profileId),
);

/// ある学習日の集計。行が無ければ null（その日はまだ解いていない）。
final dailyStatsProvider =
    StreamProvider.family<DailyStat?, ({Profile profile, String studyDate})>((
      ref,
      key,
    ) {
      final db = ref.watch(databaseProvider);
      return (db.select(db.dailyStats)..where(
            (t) =>
                t.profileId.equals(key.profile.id) &
                t.studyDate.equals(key.studyDate),
          ))
          .watchSingleOrNull();
    });

/// プリセット投入（起動ゲート）と、プリセット語の「元に戻す」で使う。
final seedImporterProvider = Provider<SeedImporter>(
  (ref) => SeedImporter(ref.watch(databaseProvider), rootBundle),
);

/// AI に単語帳を作ってもらうための定型文（[Docs/06_features/ai_import.md] §4）。
final promptAssetsProvider = Provider<PromptAssets>(
  (ref) => PromptAssets(rootBundle),
);

/// AI に作ってもらった単語帳の取り込み（[Docs/06_features/ai_import.md]）。
final aiImportServiceProvider = Provider<AiImportService>(
  (ref) => AiImportService(ref.watch(databaseProvider)),
);

/// バックアップの書き出しと取り込み（[Docs/06_features/export_import.md]）。
final exportImportServiceProvider = Provider<ExportImportService>(
  (ref) => ExportImportService(ref.watch(databaseProvider)),
);

/// ファイルの書き出し・読み込み・共有。テストではフェイクへ差し替える。
final fileExchangeServiceProvider = Provider<FileExchangeService>(
  (ref) => const FileExchangeServiceImpl(),
);

/// バックアップを JSON 文字列にする。**別 isolate で回す**
/// （語数が多くても UI を止めない。[Docs/06_features/export_import.md] §1）。
/// ウィジェットテストでは isolate を起こさない実装に差し替える
/// （[Docs/07_testing_strategy.md] §4）。
final backupEncoderProvider = Provider<Future<String> Function(BackupPayload)>(
  (ref) => (payload) => compute(encodeBackupJson, payload),
);

/// 現在の学習者から見える単語帳（共有＋自分のマイ単語帳）。
final wordbooksProvider =
    StreamProvider.family<List<WordbookWithCount>, int>(
      (ref, profileId) =>
          ref.watch(wordbookRepositoryProvider).watchVisible(profileId),
    );

/// 登録されている学習者の一覧（プロファイルゲート・学習者管理が見る）。
final profilesProvider = StreamProvider<List<Profile>>(
  (ref) => ref.watch(profileRepositoryProvider).watchAll(),
);

/// 学習者ごとの表示データ（学習中の語数・今日の進捗・ストリーク）。
/// プロファイルゲート（SCR-00）と学習者管理（SCR-22）が見る。
final profileOverviewsProvider = FutureProvider<List<ProfileOverview>>((
  ref,
) async {
  final profiles = await ref.watch(profilesProvider.future);
  return ref
      .watch(profileRepositoryProvider)
      .overviews(profiles, now: ref.watch(clockProvider)());
});

/// 通知タップで起動したときの学習者 id（[BootstrapGate] で override する）。
///
/// **その通知のプロファイルに切り替えてから**ホームを開く。別の人のプロファイルが
/// 開いたままだと、そのまま学習して記録が混ざる（[Docs/06_features/reminders.md] §6）。
/// 通知以外での起動、または該当プロファイルが削除済みなら null 扱いになる。
final launchProfileIdProvider = Provider<int?>((ref) => null);

/// 前回使った学習者の id（無ければ null）。ゲートで先頭に置く。
final lastActiveProfileIdProvider = Provider<int?>(
  (ref) => ref.watch(sharedPrefsProvider).getInt(kLastActiveProfileKey),
);

/// 現在の学習者。null = まだ選ばれていない（プロファイルゲートを出す）。
///
/// リポジトリ内部で「現在の学習者」を参照すると、テストや一括処理で意図しない
/// 学習者のデータを触る事故が起きるため、UI から明示的に `profileId` を渡す
/// （[Docs/02_architecture.md] §1.2）。ここはその値の置き場でしかない。
///
/// 学習者が選ばれている前提の画面には、この値をルート（`app.dart`）から
/// **コンストラクタで明示的に渡す**。「現在の学習者は非 null」を provider で
/// 表そうとすると、切り替えの瞬間に null を読んで落ちる経路ができるため。
class ActiveProfileNotifier extends Notifier<Profile?> {
  @override
  Profile? build() => null;

  /// 学習者を選ぶ。配色をグローバルへ反映し、次回起動用に id を覚える。
  /// 実際の再描画はルートが `'<profileId>:<paletteId>'` をキーにサブツリーを
  /// 作り直して行う（`app.dart`）。
  void select(Profile profile) {
    AppColors.setActive(paletteById(profile.palette));
    ref.read(sharedPrefsProvider).setInt(kLastActiveProfileKey, profile.id);
    state = profile;
  }

  /// 設定変更・編集のあとに DB から読み直す。
  Future<void> reload() async {
    final current = state;
    if (current == null) return;
    final fresh = await ref.read(profileRepositoryProvider).findById(current.id);
    if (fresh == null) {
      // 現在の学習者が消えた（他画面からの削除）。ゲートへ戻して選び直させる。
      clear();
      return;
    }
    AppColors.setActive(paletteById(fresh.palette));
    state = fresh;
  }

  /// 選択を解除してプロファイルゲートへ戻す。
  void clear() {
    AppColors.setActive(paletteById(null));
    state = null;
  }
}

final activeProfileProvider =
    NotifierProvider<ActiveProfileNotifier, Profile?>(ActiveProfileNotifier.new);

/// ルートのタブ位置（ホーム/辞書/統計/設定）。学習者・配色の切替でサブツリーを
/// 作り直しても現在タブを保つため、ローカル state ではなく provider に持つ。
final rootTabIndexProvider = StateProvider<int>((ref) => 0);
