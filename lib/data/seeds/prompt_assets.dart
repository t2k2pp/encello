import 'package:flutter/services.dart' show AssetBundle;

/// AI に単語帳を作ってもらうための定型文アセット（[Docs/06_features/ai_import.md] §4）。
///
/// `assets/prompts/*.txt` を読み、`{{theme}}` などのトークンを差し替えるだけの薄いクラス。
/// 文言そのものは ARB ではなくテキストアセットで持つ（スキーマと同期させるため）。
class PromptAssets {
  final AssetBundle _bundle;

  static const askWordbookPath = 'assets/prompts/ask_wordbook.txt';
  static const convertToWordbookPath = 'assets/prompts/convert_to_wordbook.txt';
  static const askWordbookForImportPath =
      'assets/prompts/ask_wordbook_for_import.txt';
  static const fixWordbookPath = 'assets/prompts/fix_wordbook.txt';

  const PromptAssets(this._bundle);

  /// 壊れていれば（空・読み込み不可）推測で補わず例外にする（[PseudowordAssets] の作法）。
  Future<String> _load(String path) async {
    final raw = await _bundle.loadString(path);
    if (raw.trim().isEmpty) {
      throw FormatException('$path が空です');
    }
    return raw;
  }

  static String _fill(String template, Map<String, String> tokens) {
    var text = template;
    for (final entry in tokens.entries) {
      text = text.replaceAll('{{${entry.key}}}', entry.value);
    }
    return text;
  }

  /// ① 単語帳を作ってもらう（テーマ・語数・レベルを差し込む）。
  Future<String> askWordbook({
    required String theme,
    required int count,
    required String level,
  }) async {
    final raw = await _load(askWordbookPath);
    return _fill(raw, {'theme': theme, 'count': '$count', 'level': level});
  }

  /// ② 直前のやりとりを取込用データに変換してもらう（差し込みトークンなし）。
  Future<String> convertToWordbook() => _load(convertToWordbookPath);

  /// ③ 統合（①＋②を1回で。おすすめの導線）。
  Future<String> askWordbookForImport({
    required String theme,
    required int count,
    required String level,
  }) async {
    final raw = await _load(askWordbookForImportPath);
    return _fill(raw, {'theme': theme, 'count': '$count', 'level': level});
  }

  /// ④ 取り込みに失敗したとき、AI に直してもらう（[Docs/06_features/ai_import.md] §5）。
  Future<String> fixWordbook({
    required String errors,
    required String source,
  }) async {
    final raw = await _load(fixWordbookPath);
    return _fill(raw, {'errors': errors, 'source': source});
  }
}
