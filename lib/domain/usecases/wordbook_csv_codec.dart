import 'package:csv/csv.dart';
import 'package:meta/meta.dart';

import '../../core/utils/enums.dart';

/// CSV の列（[Docs/06_features/wordbooks.md] §5）。順序も含めて仕様。
const kCsvColumns = <String>[
  'headword',
  'partOfSpeech',
  'phonetic',
  'meaning',
  'exampleEn',
  'exampleJa',
  'level',
];

/// 取り込む1語（検証を通ったもの）。
@immutable
class CsvWord {
  final String headword;
  final PartOfSpeech partOfSpeech;
  final String? phonetic;
  final String meaning;
  final String? exampleEn;
  final String? exampleJa;
  final int level;

  const CsvWord({
    required this.headword,
    required this.partOfSpeech,
    required this.phonetic,
    required this.meaning,
    required this.exampleEn,
    required this.exampleJa,
    required this.level,
  });
}

/// 弾いた行1件（[Docs/06_features/wordbooks.md] §5）。
@immutable
class CsvIssue {
  /// 何行目か（ファイルの行番号。1始まり）。
  final int line;
  final String message;

  const CsvIssue({required this.line, required this.message});

  String get display => '$line行目: $message';
}

/// CSV の読み取り結果。弾いた行があっても、通った行だけを取り込めるようにする
/// （[Docs/06_features/wordbooks.md] §5）。
@immutable
class CsvDecodeResult {
  final List<CsvWord> words;
  final List<CsvIssue> issues;

  const CsvDecodeResult({required this.words, required this.issues});
}

/// 単語帳の CSV 入出力（[Docs/06_features/wordbooks.md] §5）。純粋関数。
///
/// **推測で補完しない。** 弾いた行は取り込まず、理由を行番号付きで返す。
/// ヘッダ行の有無も自動判定せず、呼び出し側（画面のチェックボックス）が渡す。
abstract final class WordbookCsvCodec {
  /// 見出し語に許す文字（英字・スペース・ハイフン・アポストロフィ）。
  static final RegExp _headwordPattern = RegExp(r"^[A-Za-z '\-]+$");

  /// 値を数値へ自動変換しない（`level` は自分で検証する）。
  /// 空行も飛ばさない（行番号がずれると「N行目」の理由が合わなくなる）。
  static final _csv = Csv(
    lineDelimiter: '\n',
    dynamicTyping: false,
    skipEmptyLines: false,
  );

  /// 単語帳の語を CSV にする。学習状態は含めない。
  static String encode(Iterable<CsvWord> words) {
    final rows = <List<String>>[
      kCsvColumns,
      for (final w in words)
        [
          w.headword,
          w.partOfSpeech.value,
          w.phonetic ?? '',
          w.meaning,
          w.exampleEn ?? '',
          w.exampleJa ?? '',
          '${w.level}',
        ],
    ];
    return _csv.encode(rows);
  }

  /// CSV を読む。[hasHeader] は画面のチェックボックスの値をそのまま渡す。
  static CsvDecodeResult decode(String csv, {required bool hasHeader}) {
    // 改行コードの違い（CRLF）だけは読み取りの前に揃える。内容の推測ではない。
    final normalized = csv.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final rows = _csv.decode(normalized);

    final words = <CsvWord>[];
    final issues = <CsvIssue>[];
    // 同一ファイル内の重複判定（`(headword, partOfSpeech)` → 何行目か）。
    final seen = <String, int>{};

    for (var i = 0; i < rows.length; i++) {
      final line = i + 1;
      if (hasHeader && i == 0) continue;
      final row = rows[i];
      if (row.isEmpty || row.every((c) => '$c'.trim().isEmpty)) continue;

      String cell(int index) =>
          index < row.length ? '${row[index]}'.trim() : '';

      final headword = cell(0).toLowerCase();
      if (headword.isEmpty) {
        issues.add(CsvIssue(line: line, message: '見出し語がありません'));
        continue;
      }
      if (!_headwordPattern.hasMatch(headword)) {
        issues.add(CsvIssue(line: line, message: '英単語として扱えない文字が含まれます'));
        continue;
      }

      final posValue = cell(1);
      PartOfSpeech partOfSpeech;
      try {
        partOfSpeech = PartOfSpeech.fromValue(posValue);
      } on FormatException {
        issues.add(CsvIssue(line: line, message: '品詞が不正です: $posValue'));
        continue;
      }

      final meaning = cell(3);
      if (meaning.isEmpty) {
        issues.add(CsvIssue(line: line, message: '日本語訳がありません'));
        continue;
      }

      final levelText = cell(6);
      final level = levelText.isEmpty ? 1 : int.tryParse(levelText);
      if (level == null || level < 1 || level > 5) {
        issues.add(CsvIssue(line: line, message: 'レベルは1〜5で指定してください'));
        continue;
      }

      final key = '$headword:${partOfSpeech.value}';
      final duplicatedAt = seen[key];
      if (duplicatedAt != null) {
        issues.add(CsvIssue(line: line, message: '$duplicatedAt行目と重複しています'));
        continue;
      }
      seen[key] = line;

      words.add(
        CsvWord(
          headword: headword,
          partOfSpeech: partOfSpeech,
          phonetic: _nullIfBlank(cell(2)),
          meaning: meaning,
          exampleEn: _nullIfBlank(cell(4)),
          exampleJa: _nullIfBlank(cell(5)),
          level: level,
        ),
      );
    }

    return CsvDecodeResult(words: words, issues: issues);
  }

  static String? _nullIfBlank(String value) =>
      value.trim().isEmpty ? null : value.trim();
}
