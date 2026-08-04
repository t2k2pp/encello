import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../../core/utils/app_data_dir.dart';
import '../../domain/services/file_exchange_service.dart';

/// ファイルの書き出し・読み込み・共有（[Docs/06_features/export_import.md] §1）。
///
/// **保存の作法をプラットフォームで分ける。**
/// `file_selector` の保存ダイアログ（`getSaveLocation`）はデスクトップだけの機能で、
/// Android / iOS の実装は持っていない。そこで
///
/// - デスクトップ: 保存ダイアログで場所を選ばせてそこへ書く
/// - Android / iOS: アプリのデータ領域へ書いてから**共有シート**に渡し、
///   保存先はシート側で選んでもらう
///
/// と明示的に分岐する。呼び出し側から見た戻り値（書き出したパス）は同じ。
/// 例外を握って別の方法へ落とす、という書き方はしない。
class FileExchangeServiceImpl implements FileExchangeService {
  const FileExchangeServiceImpl();

  /// 保存ダイアログを持つプラットフォームか。
  static bool get _hasSaveDialog =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  @override
  Future<String?> save({
    required String suggestedName,
    required String contents,
  }) async {
    if (_hasSaveDialog) {
      final location = await getSaveLocation(suggestedName: suggestedName);
      if (location == null) return null;
      final file = File(location.path);
      await file.writeAsString(contents, encoding: utf8);
      return file.path;
    }

    final dir = await appDataDirectory();
    final file = File(p.join(dir.path, suggestedName));
    await file.writeAsString(contents, encoding: utf8);
    await share(path: file.path, subject: suggestedName);
    return file.path;
  }

  @override
  Future<PickedFile?> pick({required List<String> extensions}) async {
    final file = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(label: extensions.join(' / '), extensions: extensions),
      ],
    );
    if (file == null) return null;
    return PickedFile(name: file.name, bytes: await file.readAsBytes());
  }

  @override
  Future<void> share({required String path, required String subject}) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(path)], subject: subject),
    );
  }
}
