import 'dart:typed_data';

import 'package:meta/meta.dart';

/// 読み込んだファイル1件。
@immutable
class PickedFile {
  final String name;
  final Uint8List bytes;

  const PickedFile({required this.name, required this.bytes});
}

/// ファイルの書き出し・読み込み・共有の抽象
/// （[Docs/06_features/export_import.md] §1）。
///
/// 実装は `data/services/file_exchange_service_impl.dart`（`file_selector` と
/// `share_plus`）。テストではフェイクを注入し、実機のダイアログに依存させない。
abstract class FileExchangeService {
  /// 保存先を選ばせて書き出し、保存したパスを返す。キャンセルなら null。
  Future<String?> save({
    required String suggestedName,
    required String contents,
  });

  /// 読み込むファイルを選ばせる。キャンセルなら null。
  /// [extensions] は拡張子（`json` / `csv`）。
  Future<PickedFile?> pick({required List<String> extensions});

  /// 書き出したファイルを他アプリへ共有する。
  Future<void> share({required String path, required String subject});
}
