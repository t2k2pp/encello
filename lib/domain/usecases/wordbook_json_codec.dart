/// AI が作った単語帳（EncelloWordbook v1）の取り込み検証（[Docs/06_features/ai_import.md] §2）。
///
/// **フォールバック禁止**: 壊れた入力を推測で直さない。全角引用符の半角化のような
/// 構文の推測修復は行わない。パースや検証に失敗したら、理由を全件列挙して呼び出し側
/// （UI）が「AI に直してもらう文」へ誘導できるようにするだけ。
library;

import 'dart:convert';

import 'package:characters/characters.dart';
import 'package:meta/meta.dart';

import '../../core/utils/enums.dart';

/// 取り込む単語帳（検証を通った語だけを含む）。
@immutable
class ParsedWordbook {
  final String name;
  final String emoji;
  final String? note;

  /// 検証を通った語だけ。弾いた語は含まない（[Docs/06_features/ai_import.md] §3.3）。
  final List<ParsedWord> words;

  const ParsedWordbook({
    required this.name,
    required this.emoji,
    required this.note,
    required this.words,
  });
}

/// 取り込む語1件。
@immutable
class ParsedWord {
  final String headword;
  final PartOfSpeech partOfSpeech;
  final String? phonetic;
  final String meaning;
  final String? exampleEn;
  final String? exampleJa;
  final int level;

  const ParsedWord({
    required this.headword,
    required this.partOfSpeech,
    required this.phonetic,
    required this.meaning,
    required this.exampleEn,
    required this.exampleJa,
    required this.level,
  });
}

/// 検証で見つかった問題1件（[Docs/06_features/ai_import.md] §3.1）。
///
/// [index] は何語目か（1始まり）。単語帳全体に関わる問題（版違い・名前なし等）は null。
/// [headword] は分かっているときだけ入れる（型が不正で読み取れない場合は null）。
@immutable
class ImportIssue {
  final int? index;
  final String? headword;
  final String message;

  const ImportIssue({this.index, this.headword, required this.message});

  /// 画面にそのまま出せる1行（例: `3語目「Patient!」: 英単語として扱えない文字が含まれます`）。
  String get display {
    final i = index;
    if (i == null) return message;
    final h = headword;
    if (h == null || h.isEmpty) return '$i語目: $message';
    return '$i語目「$h」: $message';
  }
}

/// [WordbookJsonCodec.decode] の結果。
///
/// - 完全に成功: [book] が全語入りで [issues] は空。
/// - 部分的に成功: [book] に検証を通った語だけが入り、[issues] に弾いた語の理由が入る
///   （呼び出し側は「正しい語だけ取り込む」か「やめる」を選ばせる。§3.3）。
/// - 致命的に失敗（版違い・名前なし等、単語帳そのものが作れない）: [book] は null。
@immutable
class WordbookDecodeResult {
  final ParsedWordbook? book;
  final List<ImportIssue> issues;

  const WordbookDecodeResult({required this.book, required this.issues});

  /// 弾いた語も無く、そのまま取り込める。
  bool get isClean => book != null && issues.isEmpty;

  /// 一部の語を弾いたが、残りは取り込める（部分取り込みを選ばせる）。
  bool get isPartial => book != null && issues.isNotEmpty;
}

/// EncelloWordbook v1 の前処理・検証・デコード（[Docs/06_features/ai_import.md] §2）。
abstract final class WordbookJsonCodec {
  static const _supportedVersion = '1';
  static const _maxWords = 200;

  /// 英字・スペース・ハイフン・アポストロフィのみ（[Docs/06_features/ai_import.md] §2.1）。
  static final RegExp _headwordPattern = RegExp(r"^[A-Za-z '\-]+$");

  /// 前処理（[Docs/06_features/ai_import.md] §2.2 の1〜3のみ。4の推測修復はしない）。
  ///
  /// 1. 先頭・末尾の空白と BOM を除去
  /// 2. コードフェンス（```json 〜 ```）を除去
  /// 3. 最初の `{` から対応する最後の `}` までを抽出（前置き・後置きの説明文を無視）
  static String preprocess(String raw) {
    var text = raw.trim();
    if (text.isNotEmpty && text.codeUnitAt(0) == 0xFEFF) {
      text = text.substring(1);
    }
    text = text.replaceAll(RegExp(r'```(?:json)?', caseSensitive: false), '');
    text = text.trim();

    final start = text.indexOf('{');
    if (start == -1) return text;
    final end = _matchingBraceIndex(text, start);
    if (end == -1) return text.substring(start);
    return text.substring(start, end + 1);
  }

  /// 対応する `}` の位置を返す（文字列リテラル内の `{` `}` は数えない）。
  /// 対応が取れなければ -1。
  static int _matchingBraceIndex(String text, int openIndex) {
    var depth = 0;
    var inString = false;
    var escaped = false;
    for (var i = openIndex; i < text.length; i++) {
      final ch = text[i];
      if (inString) {
        if (escaped) {
          escaped = false;
        } else if (ch == '\\') {
          escaped = true;
        } else if (ch == '"') {
          inString = false;
        }
        continue;
      }
      if (ch == '"') {
        inString = true;
      } else if (ch == '{') {
        depth++;
      } else if (ch == '}') {
        depth--;
        if (depth == 0) return i;
      }
    }
    return -1;
  }

  /// 前処理してから検証する。エラーは全件を [WordbookDecodeResult.issues] に集める
  /// （最初の1件で打ち切らない）。
  static WordbookDecodeResult decode(String raw) {
    final preprocessed = preprocess(raw);
    dynamic json;
    try {
      json = jsonDecode(preprocessed);
    } on FormatException {
      return _structuralFailure();
    }
    if (json is! Map<String, dynamic>) {
      return _structuralFailure();
    }
    return _validate(json);
  }

  static WordbookDecodeResult _structuralFailure() =>
      const WordbookDecodeResult(
        book: null,
        issues: [ImportIssue(message: '貼り付けた内容を読み取れませんでした。コピーした範囲を確認してください。')],
      );

  static WordbookDecodeResult _validate(Map<String, dynamic> json) {
    final version = json['encelloWordbook'];
    if (version != _supportedVersion) {
      return const WordbookDecodeResult(
        book: null,
        issues: [ImportIssue(message: '新しい形式です。アプリを更新してください')],
      );
    }

    final bookIssues = <ImportIssue>[];

    final nameRaw = json['name'];
    String? name;
    if (nameRaw is! String || nameRaw.trim().isEmpty) {
      bookIssues.add(const ImportIssue(message: '単語帳の名前がありません'));
    } else if (nameRaw.length > 40) {
      bookIssues.add(const ImportIssue(message: '単語帳の名前が長すぎます（40文字以内にしてください）'));
    } else {
      name = nameRaw;
    }

    var emoji = '📗';
    final emojiRaw = json['emoji'];
    if (emojiRaw != null) {
      if (emojiRaw is! String) {
        bookIssues.add(const ImportIssue(message: '絵文字の形式が正しくありません'));
      } else if (emojiRaw.isNotEmpty) {
        if (emojiRaw.characters.length != 1) {
          bookIssues.add(const ImportIssue(message: '絵文字は1文字で指定してください'));
        } else {
          emoji = emojiRaw;
        }
      }
    }

    String? note;
    final noteRaw = json['note'];
    if (noteRaw != null) {
      if (noteRaw is! String) {
        bookIssues.add(const ImportIssue(message: '説明の形式が正しくありません'));
      } else if (noteRaw.length > 200) {
        bookIssues.add(const ImportIssue(message: '説明が長すぎます（200文字以内にしてください）'));
      } else {
        final trimmed = noteRaw.trim();
        note = trimmed.isEmpty ? null : trimmed;
      }
    }

    final wordsRaw = json['words'];
    final wordIssues = <ImportIssue>[];
    final validWords = <ParsedWord>[];

    if (wordsRaw is! List) {
      bookIssues.add(const ImportIssue(message: '単語の一覧がありません'));
    } else if (wordsRaw.isEmpty) {
      bookIssues.add(const ImportIssue(message: '単語が1件もありません'));
    } else if (wordsRaw.length > _maxWords) {
      bookIssues.add(
        const ImportIssue(message: '一度に取り込める語数を超えています。50語ずつに分けて作ってもらってください'),
      );
    } else {
      final seen = <String, int>{};
      for (var i = 0; i < wordsRaw.length; i++) {
        final idx = i + 1;
        final rawWord = wordsRaw[i];
        if (rawWord is! Map<String, dynamic>) {
          wordIssues.add(
            ImportIssue(index: idx, message: '単語のデータとして読み取れませんでした'),
          );
          continue;
        }
        final result = _validateWord(rawWord, idx, seen);
        wordIssues.addAll(result.issues);
        if (result.word != null) {
          final key = _dupKey(result.word!.headword, result.word!.partOfSpeech);
          seen[key] = idx;
          validWords.add(result.word!);
        }
      }
      if (validWords.isEmpty) {
        wordIssues.add(const ImportIssue(message: '取り込める語が1つもありませんでした'));
      }
    }

    final issues = [...bookIssues, ...wordIssues];
    final book = (bookIssues.isEmpty && validWords.isNotEmpty)
        ? ParsedWordbook(
            name: name!,
            emoji: emoji,
            note: note,
            words: validWords,
          )
        : null;
    return WordbookDecodeResult(book: book, issues: issues);
  }

  static String _dupKey(String headword, PartOfSpeech pos) =>
      '$headword ${pos.value}';

  static ({ParsedWord? word, List<ImportIssue> issues}) _validateWord(
    Map<String, dynamic> raw,
    int idx,
    Map<String, int> seen,
  ) {
    final issues = <ImportIssue>[];

    String? headword;
    String? headwordDisplay;
    final headwordRaw = raw['headword'];
    if (headwordRaw is! String || headwordRaw.trim().isEmpty) {
      issues.add(ImportIssue(index: idx, message: '英単語がありません'));
    } else {
      final h = headwordRaw.trim();
      headwordDisplay = h;
      if (h.length > 60) {
        issues.add(
          ImportIssue(
            index: idx,
            headword: h,
            message: '英単語が長すぎます（60文字以内にしてください）',
          ),
        );
      } else if (!_headwordPattern.hasMatch(h)) {
        issues.add(
          ImportIssue(index: idx, headword: h, message: '英単語として扱えない文字が含まれます'),
        );
      } else {
        headword = h.toLowerCase();
      }
    }

    PartOfSpeech? pos;
    final posRaw = raw['partOfSpeech'];
    if (posRaw is! String || posRaw.isEmpty) {
      issues.add(
        ImportIssue(index: idx, headword: headwordDisplay, message: '品詞がありません'),
      );
    } else {
      try {
        pos = PartOfSpeech.fromValue(posRaw);
      } on FormatException {
        issues.add(
          ImportIssue(
            index: idx,
            headword: headwordDisplay,
            message: '品詞が不正です: $posRaw',
          ),
        );
      }
    }

    String? phonetic;
    final phoneticRaw = raw['phonetic'];
    if (phoneticRaw != null) {
      if (phoneticRaw is! String) {
        issues.add(
          ImportIssue(
            index: idx,
            headword: headwordDisplay,
            message: '発音記号の形式が正しくありません',
          ),
        );
      } else {
        final trimmed = phoneticRaw.trim();
        phonetic = trimmed.isEmpty ? null : trimmed;
      }
    }

    String? meaning;
    final meaningRaw = raw['meaning'];
    if (meaningRaw is! String || meaningRaw.trim().isEmpty) {
      issues.add(
        ImportIssue(
          index: idx,
          headword: headwordDisplay,
          message: '日本語訳がありません',
        ),
      );
    } else if (meaningRaw.length > 200) {
      issues.add(
        ImportIssue(
          index: idx,
          headword: headwordDisplay,
          message: '日本語訳が長すぎます（200文字以内にしてください）',
        ),
      );
    } else {
      meaning = meaningRaw.trim();
    }

    String? exampleEn;
    final exampleEnRaw = raw['exampleEn'];
    if (exampleEnRaw != null) {
      if (exampleEnRaw is! String) {
        issues.add(
          ImportIssue(
            index: idx,
            headword: headwordDisplay,
            message: '例文の形式が正しくありません',
          ),
        );
      } else {
        final trimmed = exampleEnRaw.trim();
        if (trimmed.length > 200) {
          issues.add(
            ImportIssue(
              index: idx,
              headword: headwordDisplay,
              message: '例文が長すぎます（200文字以内にしてください）',
            ),
          );
        } else {
          exampleEn = trimmed.isEmpty ? null : trimmed;
        }
      }
    }

    String? exampleJa;
    final exampleJaRaw = raw['exampleJa'];
    if (exampleJaRaw != null) {
      if (exampleJaRaw is! String) {
        issues.add(
          ImportIssue(
            index: idx,
            headword: headwordDisplay,
            message: '例文の和訳の形式が正しくありません',
          ),
        );
      } else {
        final trimmed = exampleJaRaw.trim();
        if (trimmed.length > 200) {
          issues.add(
            ImportIssue(
              index: idx,
              headword: headwordDisplay,
              message: '例文の和訳が長すぎます（200文字以内にしてください）',
            ),
          );
        } else {
          exampleJa = trimmed.isEmpty ? null : trimmed;
        }
      }
    }

    if (exampleEn != null && exampleJa == null) {
      issues.add(
        ImportIssue(
          index: idx,
          headword: headwordDisplay,
          message: '日本語訳がありません',
        ),
      );
    }

    int? level;
    final levelRaw = raw['level'];
    if (levelRaw == null) {
      level = 1;
    } else if (levelRaw is! int || levelRaw < 1 || levelRaw > 5) {
      issues.add(
        ImportIssue(
          index: idx,
          headword: headwordDisplay,
          message: 'レベルは1〜5で指定してください',
        ),
      );
    } else {
      level = levelRaw;
    }

    if (headword != null && pos != null) {
      final key = _dupKey(headword, pos);
      final firstIndex = seen[key];
      if (firstIndex != null) {
        issues.add(
          ImportIssue(
            index: idx,
            headword: headword,
            message: '$firstIndex語目と重複しています',
          ),
        );
      }
    }

    if (issues.isNotEmpty ||
        headword == null ||
        pos == null ||
        meaning == null ||
        level == null) {
      return (word: null, issues: issues);
    }

    return (
      word: ParsedWord(
        headword: headword,
        partOfSpeech: pos,
        phonetic: phonetic,
        meaning: meaning,
        exampleEn: exampleEn,
        exampleJa: exampleJa,
        level: level,
      ),
      issues: issues,
    );
  }

  /// [ImportIssue] の一覧を「直してもらう文」（`fix_wordbook.txt` の `{{errors}}`）や
  /// 画面のエラー一覧に使う複数行テキストにする。
  static String describeIssues(List<ImportIssue> issues) =>
      issues.map((e) => e.display).join('\n');
}
