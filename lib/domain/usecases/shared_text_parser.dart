import 'package:meta/meta.dart';

/// 共有テキストの解釈結果（[Docs/06_features/my_words.md] §4.2）。
@immutable
class SharedTextParseResult {
  /// クイック登録シートの見出し語欄へ入れる値。空 = 見出し語を決めなかった。
  final String headword;

  /// 「見つけた文」欄へ入れる値。空 = 文を入れない。
  final String sentence;

  /// 文中の語のチップ（複数語の文のときだけ非空）。
  final List<String> candidateWords;

  const SharedTextParseResult({
    required this.headword,
    required this.sentence,
    required this.candidateWords,
  });

  static const empty = SharedTextParseResult(
    headword: '',
    sentence: '',
    candidateWords: [],
  );
}

/// 他アプリから共有されたテキストを解釈する純粋関数
/// （[Docs/06_features/my_words.md] §4.2）。
///
/// **推測で見出し語を決めない。** 複数語の文からどれが単語なのかは呼び出し側（利用者）に
/// 選ばせる。日本語が混ざっている場合は単語として扱えないため、見出し語は空のまま
/// 「見つけた文」にだけ残す。
abstract final class SharedTextParser {
  /// 英字だけで構成された語を拾う（記号・数字・日本語は含めない）。
  static final _wordPattern = RegExp('[A-Za-z]+');

  /// 全体が英字だけの1語か（前後の空白を除く）。
  static final _singleWordPattern = RegExp(r'^[A-Za-z]+$');

  /// ひらがな・カタカナ・漢字を含むか。
  static final _japanesePattern = RegExp('[぀-ゟ゠-ヿ一-鿿]');

  static SharedTextParseResult parse(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return SharedTextParseResult.empty;

    if (_japanesePattern.hasMatch(text)) {
      // 日本語を含む: 見出し語は空のまま、文だけを入れる。
      return SharedTextParseResult(
        headword: '',
        sentence: text,
        candidateWords: const [],
      );
    }

    if (_singleWordPattern.hasMatch(text)) {
      // 1語（英字のみ）: 見出し語に入れる。
      return SharedTextParseResult(
        headword: text.toLowerCase(),
        sentence: '',
        candidateWords: const [],
      );
    }

    // 複数語の文（英字以外の記号・数字が混ざる場合もここに来る）。
    // 文中の語をチップで並べて選ばせる。推測でどれか1つに決めない。
    final words = <String>[];
    final seen = <String>{};
    for (final m in _wordPattern.allMatches(text)) {
      final w = m.group(0)!.toLowerCase();
      if (seen.add(w)) words.add(w);
    }
    return SharedTextParseResult(
      headword: '',
      sentence: text,
      candidateWords: words,
    );
  }
}
