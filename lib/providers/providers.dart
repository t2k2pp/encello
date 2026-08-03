import 'package:flutter_riverpod/flutter_riverpod.dart';
// StateProvider は Riverpod 3 で legacy 扱い（rootTabIndexProvider で使用）。
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/app_colors.dart';
import '../data/database/app_database.dart';
import '../data/repositories/profile_repository.dart';

/// 前回使った学習者（[Docs/03_data_model.md] §8）。
/// 学習者ごとの設定は `profiles` の列に持つため、prefs には端末レベルの値だけを置く。
const kLastActiveProfileKey = 'profile.lastActiveId';

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
