import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text.dart';
import 'data/database/app_database.dart';
import 'data/seeds/seed_importer.dart';
import 'providers/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // フォントは assets/google_fonts/ に同梱した Noto Sans JP を使う。
  // ランタイムのネットワーク取得を明示的に禁止し、起動がネットワーク状態に
  // 依存しないようにする（NFR-04）。
  GoogleFonts.config.allowRuntimeFetching = false;

  // 同梱フォントのライセンス（OFL）を登録する。
  // 表示は 設定 > 情報 > オープンソースライセンス。
  LicenseRegistry.addLicense(() async* {
    final ofl = await rootBundle.loadString('assets/google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(const ['google_fonts'], ofl);
  });

  // ビルドエラー時に黒画面/グレー画面ではなく、読めるエラー表示を出す。
  ErrorWidget.builder = (details) => Material(
    color: AppColors.bg,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          '画面の表示でエラーが発生しました。\n${details.exception}',
          textAlign: TextAlign.center,
          style: AppText.body(),
        ),
      ),
    ),
  );

  // runApp の前で非同期初期化を await しない。プラグイン初期化が停滞した場合に
  // 最初のフレームが出ず、ネイティブスプラッシュのまま固まるため（NFR-08）。
  runApp(const BootstrapGate());
}

/// 起動時の非同期初期化の結果。[ProviderScope] の override にまとめて渡す。
class _BootstrapData {
  final SharedPreferences prefs;
  final AppDatabase db;

  const _BootstrapData(this.prefs, this.db);
}

/// 起動ゲート（[Docs/02_architecture.md] §4）。
///
/// 即座に Flutter のフレームを描画してネイティブスプラッシュを引き継ぎ、その後に
/// 非同期初期化を行って本体アプリへ切り替える。停滞は10秒で打ち切り、エラーと
/// 再試行ボタンを出す（黙って待ち続けない。NFR-08）。
class BootstrapGate extends StatefulWidget {
  const BootstrapGate({super.key});

  @override
  State<BootstrapGate> createState() => _BootstrapGateState();
}

class _BootstrapGateState extends State<BootstrapGate> {
  _BootstrapData? _data;
  Object? _error;

  /// 初期化の停滞判定。SharedPreferences の読込は通常ミリ秒オーダーで終わるため、
  /// これを超えたらプラットフォーム側の異常とみなしエラー表示に切り替える。
  static const _initTimeout = Duration(seconds: 10);

  /// 初期化の Future。再試行時も同一 Future を待ち直すことで、処理がまだ進行中の
  /// タイムアウトから二重に走らせない。
  Future<_BootstrapData>? _loading;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final data = await (_loading ??= _load()).timeout(_initTimeout);
      if (mounted) setState(() => _data = data);
    } catch (e) {
      // タイムアウト（処理がまだ進行中）は同一 Future を待ち直す。
      // 実際に失敗した Future は捨て、再試行で作り直す。
      if (e is! TimeoutException) _loading = null;
      if (mounted) setState(() => _error = e);
    }
  }

  /// DB は再試行で作り直さない（同じファイルを二重に開かないため）。
  AppDatabase? _db;

  Future<_BootstrapData> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final db = _db ??= AppDatabase(null);
    // プリセット単語帳の投入。アセットの seedVersion が DB の値より新しいときだけ
    // 差分を適用する（[Docs/06_features/wordbooks.md] §3.1）。
    final result = await SeedImporter(db, rootBundle).importIfNeeded(
      installedVersion: prefs.getInt(kSeedInstalledVersionKey) ?? 0,
    );
    if (result.applied) {
      await prefs.setInt(kSeedInstalledVersionKey, result.installedVersion);
    }
    return _BootstrapData(prefs, db);
  }

  void _retry() {
    setState(() {
      _error = null;
      _data = null;
    });
    _init();
  }

  @override
  void dispose() {
    _db?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    if (data != null) {
      return ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(data.prefs),
          databaseProvider.overrideWithValue(data.db),
        ],
        child: const EncelloApp(),
      );
    }
    // 初期化中/失敗時の画面。本体テーマに依存しない最小構成で必ず描画できる。
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: _error == null
              ? CircularProgressIndicator(color: AppColors.accent)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _error is TimeoutException
                            ? '起動処理に時間がかかっています。\nしばらく待ってから再試行してください。'
                            : '起動時の初期化に失敗しました。\n$_error',
                        textAlign: TextAlign.center,
                        style: AppText.body(),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                        ),
                        onPressed: _retry,
                        child: const Text('再試行'),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
