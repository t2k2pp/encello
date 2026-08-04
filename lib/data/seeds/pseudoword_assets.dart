import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle;

/// 擬似語アセットの読み込み（[Docs/06_features/vocab_size_test.md] §4）。
///
/// 擬似語には訳も例文も持たせない。`words` テーブルには入れず、アセットのまま扱う
/// （測定は学習ではないので、語として登録すると学習状態と混ざる）。
class PseudowordAssets {
  final AssetBundle _bundle;

  static const assetPath = 'assets/pseudowords.json';

  const PseudowordAssets(this._bundle);

  /// 同梱の擬似語をすべて読む。壊れていれば推測で補わず例外にする。
  Future<List<String>> load() async {
    final raw = await _bundle.loadString(assetPath);
    final json = jsonDecode(raw);
    if (json is! Map<String, dynamic>) {
      throw FormatException('$assetPath がオブジェクトではありません');
    }
    final words = json['words'];
    if (words is! List) {
      throw FormatException('$assetPath の words が配列ではありません');
    }
    return [
      for (final w in words)
        if (w is String && w.isNotEmpty)
          w
        else
          throw FormatException('擬似語が文字列で入っていません: $w'),
    ];
  }
}
