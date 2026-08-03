import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// アプリ専用のデータ保存先（DB・音声パックの展開先）。
///
/// OS がバックアップ・削除の対象を決められる正規の場所を使い、外部ストレージには置かない
/// （[Docs/08_platform_setup.md] §2.4）。
Future<Directory> appDataDirectory() => getApplicationDocumentsDirectory();
