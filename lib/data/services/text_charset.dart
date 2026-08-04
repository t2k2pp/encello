import 'dart:convert';
import 'dart:typed_data';

import 'package:charset/charset.dart';

/// 取り込んだファイルの文字コード（[Docs/06_features/wordbooks.md] §5）。
enum TextCharset {
  utf8('UTF-8'),
  shiftJis('Shift_JIS');

  final String label;
  const TextCharset(this.label);
}

/// 判別できた文字コードと、その読み取り結果。
class DecodedText {
  final TextCharset charset;
  final String text;

  const DecodedText({required this.charset, required this.text});
}

/// バイト列を UTF-8 → Shift_JIS の順で厳密に読む。
///
/// **どちらでも読めなければ null を返す**（推測で文字化けしたまま取り込まない。
/// 呼び出し側は「文字コードを判別できません。UTF-8 で保存し直してください」と示す）。
DecodedText? decodeTextFile(Uint8List bytes) {
  final body = _stripBom(bytes);
  try {
    return DecodedText(
      charset: TextCharset.utf8,
      // allowMalformed を付けない。壊れたバイトを � で埋めて「読めたこと」にしない。
      text: utf8.decode(body),
    );
  } on FormatException {
    // UTF-8 として読めなかった場合だけ Shift_JIS を試す。
  }
  try {
    return DecodedText(
      charset: TextCharset.shiftJis,
      text: const ShiftJISDecoder().convert(body),
    );
  } on Exception {
    return null;
  }
}

/// UTF-8 の BOM を落とす（残すと1列目の見出しが一致しない）。
List<int> _stripBom(Uint8List bytes) {
  if (bytes.length >= 3 &&
      bytes[0] == 0xEF &&
      bytes[1] == 0xBB &&
      bytes[2] == 0xBF) {
    return bytes.sublist(3);
  }
  return bytes;
}
