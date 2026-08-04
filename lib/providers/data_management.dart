import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/seeds/sample_data.dart';
import '../data/services/cleanup_service.dart';
import '../data/services/reset_progress_service.dart';
import 'providers.dart';

/// サンプルデータの投入・削除（[Docs/06_features/export_import.md] §4）。
final sampleDataServiceProvider = Provider<SampleDataService>(
  (ref) => SampleDataService(ref.watch(databaseProvider)),
);

/// サンプル単語帳が投入済みか（設定 > データの投入ボタンの活性/非活性）。
final sampleDataInstalledProvider = StreamProvider<bool>(
  (ref) => ref.watch(sampleDataServiceProvider).watchInstalled(),
);

/// 未所属の単語・使われていない音声ファイルの整理
/// （[Docs/06_features/export_import.md] §5.1・§5.2）。
final cleanupServiceProvider = Provider<CleanupService>(
  (ref) => CleanupService(ref.watch(databaseProvider)),
);

/// 学習状態のリセット（[Docs/06_features/export_import.md] §5）。
final resetProgressServiceProvider = Provider<ResetProgressService>(
  (ref) => ResetProgressService(ref.watch(databaseProvider)),
);
