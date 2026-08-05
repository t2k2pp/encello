/// プリセット単語帳の分割ソースを検証して1本のアセットに結合するロジック
/// （[Docs/06_features/wordbooks.md] §3.2）。
///
/// dart:io に触れないので、CLI（`tool/build_wordbooks.dart`）からも
/// テスト（`test/data/preset_wordbook_asset_test.dart`）からも同じものを使う。
library;

import 'dart:convert';

/// 指摘の重さ。`error` が1件でもあればアセットを書き出さない。
enum IssueSeverity { error, warning }

/// 検証の指摘1件。
class ValidationIssue {
  final IssueSeverity severity;

  /// 由来のチャンク名（`01_function_words`）。アセットの検証では `asset`。
  final String chunk;

  /// 対象の語（`answer:verb`）。語に紐付かない指摘では空。
  final String target;
  final String message;

  const ValidationIssue(
    this.severity,
    this.chunk,
    this.target,
    this.message,
  );

  bool get isError => severity == IssueSeverity.error;

  @override
  String toString() {
    final mark = isError ? 'ERROR' : 'WARN ';
    final where = target.isEmpty ? chunk : '$chunk / $target';
    return '$mark [$where] $message';
  }
}

/// ソース1語（チャンクファイルの `words[]` の1要素）。
///
/// `phonetic` / `exampleEn` / `exampleJa` は**空文字を「値なし」**として扱う
/// （[Docs/06_features/wordbooks.md] §3）。
class SourceWord {
  final String headword;
  final String partOfSpeech;
  final String phonetic;
  final String meaning;
  final String exampleEn;
  final String exampleJa;
  final int level;
  final String chunk;

  const SourceWord({
    required this.headword,
    required this.partOfSpeech,
    required this.phonetic,
    required this.meaning,
    required this.exampleEn,
    required this.exampleJa,
    required this.level,
    required this.chunk,
  });

  String get key => '$headword:$partOfSpeech';
}

/// ビルドの結果。`asset` は `error` が無いときだけ入る。
class BuildResult {
  final Map<String, Object?>? asset;
  final List<ValidationIssue> issues;
  final List<SourceWord> words;

  const BuildResult({
    required this.asset,
    required this.issues,
    required this.words,
  });

  Iterable<ValidationIssue> get errors => issues.where((i) => i.isError);
  Iterable<ValidationIssue> get warnings => issues.where((i) => !i.isError);
}

/// `PartOfSpeech` の値（`lib/core/utils/enums.dart`）。
/// `unknown` はプリセットには置かない（品詞が分からない語を同梱しない）。
const kPartsOfSpeech = <String>{
  'noun',
  'verb',
  'adjective',
  'adverb',
  'preposition',
  'conjunction',
  'pronoun',
  'interjection',
  'phrase',
};

/// 見出し語に許す文字。小文字・半角スペース1つ・ハイフン・アポストロフィ
/// （[Docs/06_features/wordbooks.md] §2）。
final _headwordPattern = RegExp(r"^[a-z]+(?:[ '\-][a-z]+)*$");

/// 発音記号は IPA をスラッシュで囲む（`/ˈæpəl/`）。
final _phoneticPattern = RegExp(r'^/[^/]+/$');

/// 日本語（ひらがな・カタカナ・漢字・全角記号）を含むか。
final _japanesePattern = RegExp(r'[぀-ヿ㐀-鿿＀-ﾟ]');

/// 例文の語の切り出し。アポストロフィは語の一部として残す（`don't`）。
final _wordTokenPattern = RegExp(r"[A-Za-z][A-Za-z']*");

/// 例文の語数の上限（`>` で警告 / `_maxExampleWords` 超で不合格）。
const _softExampleWords = 10;
const _maxExampleWords = 12;

/// 訳の語義の上限（[Docs/06_features/wordbooks.md] §2）。
const _maxSenses = 3;

/// チャンクファイルの JSON からソース語を読む。
///
/// 形が違う要素は落として `error` を積む（1語の壊れで全体を止めない。
/// ただし `error` があるとアセットは書き出さないので、結局は直すことになる）。
List<SourceWord> parseChunk(
  String chunkName,
  Object? decoded,
  List<ValidationIssue> issues,
) {
  void err(String target, String message) =>
      issues.add(ValidationIssue(IssueSeverity.error, chunkName, target, message));

  if (decoded is! Map<String, Object?>) {
    err('', 'チャンクがオブジェクトではありません');
    return const [];
  }
  if (decoded['chunk'] != chunkName) {
    err('', 'chunk がファイル名と一致しません: ${decoded['chunk']}');
  }
  final rawWords = decoded['words'];
  if (rawWords is! List) {
    err('', 'words が配列ではありません');
    return const [];
  }

  final words = <SourceWord>[];
  for (var i = 0; i < rawWords.length; i++) {
    final raw = rawWords[i];
    if (raw is! Map<String, Object?>) {
      err('#$i', '語がオブジェクトではありません');
      continue;
    }
    final headword = raw['headword'];
    final partOfSpeech = raw['partOfSpeech'];
    final meaning = raw['meaning'];
    final level = raw['level'];
    final target = '$headword:$partOfSpeech';

    if (headword is! String || headword.isEmpty) {
      err('#$i', 'headword がありません');
      continue;
    }
    if (partOfSpeech is! String || partOfSpeech.isEmpty) {
      err(headword, 'partOfSpeech がありません');
      continue;
    }
    if (meaning is! String) {
      err(target, 'meaning が文字列ではありません');
      continue;
    }
    if (level is! int) {
      err(target, 'level が整数ではありません: $level');
      continue;
    }
    String optional(String key) {
      final v = raw[key];
      if (v == null) return '';
      if (v is! String) {
        err(target, '$key が文字列ではありません: $v');
        return '';
      }
      return v.trim();
    }

    final known = {
      'headword',
      'partOfSpeech',
      'phonetic',
      'meaning',
      'exampleEn',
      'exampleJa',
      'level',
    };
    for (final key in raw.keys) {
      if (!known.contains(key)) {
        err(target, '知らない項目があります: $key');
      }
    }

    words.add(
      SourceWord(
        headword: headword.trim(),
        partOfSpeech: partOfSpeech.trim(),
        phonetic: optional('phonetic'),
        meaning: meaning.trim(),
        exampleEn: optional('exampleEn'),
        exampleJa: optional('exampleJa'),
        level: level,
        chunk: chunkName,
      ),
    );
  }
  return words;
}

/// 語の集合を検証する。ビルド時とアセットの回帰テストで同じものを使う。
///
/// [allowedExampleWords] は例文に出てよい語（機能語・固有名詞など）。
/// 例文の語彙が単語帳の外に出ていないかは**警告**に留める
/// （見出し語の活用形まで機械で完全には判定できないため）。
List<ValidationIssue> validateWords(
  List<SourceWord> words, {
  required int minLevel,
  required int maxLevel,
  required Set<String> allowedExampleWords,
}) {
  final issues = <ValidationIssue>[];
  void add(IssueSeverity s, SourceWord w, String message) =>
      issues.add(ValidationIssue(s, w.chunk, w.key, message));
  void err(SourceWord w, String m) => add(IssueSeverity.error, w, m);
  void warn(SourceWord w, String m) => add(IssueSeverity.warning, w, m);

  final seen = <String, SourceWord>{};
  final seenExamples = <String, SourceWord>{};

  // 例文の語彙チェックに使う「この単語帳で読める語」。
  final vocabulary = <String>{...allowedExampleWords};
  for (final w in words) {
    for (final part in w.headword.split(' ')) {
      vocabulary.addAll(inflections(part));
    }
  }

  for (final w in words) {
    // 見出し語
    if (!_headwordPattern.hasMatch(w.headword)) {
      err(w, '見出し語に使えない文字があります（小文字・スペース1つ・- \' のみ）');
    }

    // 品詞
    if (!kPartsOfSpeech.contains(w.partOfSpeech)) {
      err(w, '品詞が不正です: ${w.partOfSpeech}');
    }
    final isPhrase = w.partOfSpeech == 'phrase';
    if (w.headword.contains(' ') && !isPhrase) {
      err(w, '複数語の見出し語は品詞を phrase にします');
    }

    // 重複
    final duplicated = seen[w.key];
    if (duplicated != null) {
      err(w, '${duplicated.chunk} と重複しています');
    } else {
      seen[w.key] = w;
    }

    // 訳
    if (w.meaning.isEmpty) {
      err(w, '訳がありません');
    } else {
      if (!_japanesePattern.hasMatch(w.meaning)) {
        err(w, '訳に日本語がありません: ${w.meaning}');
      }
      if (w.meaning.contains(';')) {
        err(w, '語義の区切りは全角の ； を使います');
      }
      final senses = w.meaning.split('；');
      if (senses.length > _maxSenses) {
        err(w, '語義が $_maxSenses を超えています（${senses.length}）');
      }
      if (senses.any((s) => s.trim().isEmpty)) {
        err(w, '空の語義があります');
      }
    }

    // 発音記号
    if (w.phonetic.isNotEmpty) {
      if (!_phoneticPattern.hasMatch(w.phonetic)) {
        err(w, '発音記号は / で囲みます: ${w.phonetic}');
      }
      if (isPhrase) {
        err(w, '句には発音記号を付けません');
      }
    } else if (!isPhrase) {
      warn(w, '発音記号がありません');
    }

    // 例文
    if (w.exampleEn.isEmpty != w.exampleJa.isEmpty) {
      err(w, '例文と和訳は対で用意します');
    } else if (w.exampleEn.isNotEmpty) {
      final duplicatedExample = seenExamples[w.exampleEn];
      if (duplicatedExample != null) {
        err(w, '例文が ${duplicatedExample.key} と同じです');
      } else {
        seenExamples[w.exampleEn] = w;
      }

      if (!RegExp(r'[.!?]$').hasMatch(w.exampleEn)) {
        err(w, '例文が . ! ? で終わっていません');
      }
      if (_japanesePattern.hasMatch(w.exampleEn)) {
        err(w, '例文に日本語が混ざっています');
      }
      if (!_japanesePattern.hasMatch(w.exampleJa)) {
        err(w, '例文和訳に日本語がありません');
      }
      if (!RegExp(r'[。！？]$').hasMatch(w.exampleJa)) {
        err(w, '例文和訳が 。！？ で終わっていません');
      }

      final tokens = _wordTokenPattern
          .allMatches(w.exampleEn)
          .map((m) => m.group(0)!.toLowerCase())
          .toList();
      if (tokens.length > _maxExampleWords) {
        err(w, '例文が長すぎます（${tokens.length}語）');
      } else if (tokens.length > _softExampleWords) {
        warn(w, '例文が ${tokens.length}語です（目安は $_softExampleWords語以内）');
      }

      final headTokens = w.headword.split(' ');
      final headForms = inflections(headTokens.first);
      if (!tokens.any(headForms.contains)) {
        warn(w, '例文に見出し語が見当たりません');
      }

      final outside = tokens
          .map(_stripPossessive)
          .where((t) => !vocabulary.contains(t))
          .toSet();
      if (outside.isNotEmpty) {
        warn(w, '例文に単語帳の外の語があります: ${outside.join(" ")}');
      }
    }

    // レベル
    if (w.level < minLevel || w.level > maxLevel) {
      err(w, 'level は $minLevel〜$maxLevel です: ${w.level}');
    }
  }
  return issues;
}

String _stripPossessive(String token) =>
    token.endsWith("'s") ? token.substring(0, token.length - 2) : token;

/// 見出し語から、例文に出てくる形（活用・派生）を機械的に広げる。
///
/// 例文の語彙チェック（警告）にだけ使う。ここで拾えない不規則形は
/// `allowed_example_words.txt` に置く。
Set<String> inflections(String base) {
  final forms = <String>{base};
  if (base.length < 2) return forms;

  final last = base[base.length - 1];
  final stem = base.substring(0, base.length - 1);
  const vowels = 'aeiou';

  // 三人称単数・複数
  if ('sxz'.contains(last) ||
      base.endsWith('ch') ||
      base.endsWith('sh') ||
      base.endsWith('o')) {
    forms.add('${base}es');
  }
  forms.add('${base}s');
  if (last == 'y' && !vowels.contains(base[base.length - 2])) {
    forms
      ..add('${stem}ies')
      ..add('${stem}ied')
      ..add('${stem}ier')
      ..add('${stem}iest')
      ..add('${stem}ily');
  }

  // 過去・過去分詞・現在分詞
  if (last == 'e') {
    forms
      ..add('${base}d')
      ..add('${stem}ing')
      ..add('${base}r')
      ..add('${base}st');
  } else {
    forms
      ..add('${base}ed')
      ..add('${base}ing')
      ..add('${base}er')
      ..add('${base}est');
  }
  // 短母音+子音の重ね（stop → stopped / big → bigger）
  if (base.length >= 3 &&
      !vowels.contains(last) &&
      last != 'y' &&
      last != 'w' &&
      vowels.contains(base[base.length - 2]) &&
      !vowels.contains(base[base.length - 3])) {
    forms
      ..add('$base${last}ed')
      ..add('$base${last}ing')
      ..add('$base${last}er')
      ..add('$base${last}est');
  }

  // 副詞形・名詞形の軽い派生
  forms.add('${base}ly');
  if (last == 'y' && !vowels.contains(base[base.length - 2])) {
    forms.add('${stem}iness');
  }
  return forms;
}

/// 検証を通ったソースからアセットの JSON を組み立てる。
///
/// `words[].presetId` は**ここで生成する**（`<presetId>:<headword>:<partOfSpeech>`）。
/// 手書きさせると綴り違いが混ざり、「元に戻す」がアセットを引けなくなる。
Map<String, Object?> buildAsset(
  Map<String, Object?> manifest,
  List<SourceWord> words,
) {
  final presetId = manifest['presetId'] as String;
  return <String, Object?>{
    'presetId': presetId,
    'name': manifest['name'],
    'emoji': manifest['emoji'],
    'category': manifest['category'],
    'colorSeed': manifest['colorSeed'],
    'seedVersion': manifest['seedVersion'],
    'bandSize': manifest['bandSize'],
    'sortOrder': manifest['sortOrder'],
    'note': manifest['note'],
    'words': [
      for (final w in words)
        <String, Object?>{
          'presetId': '$presetId:${w.headword}:${w.partOfSpeech}',
          'headword': w.headword,
          'partOfSpeech': w.partOfSpeech,
          'phonetic': w.phonetic,
          'meaning': w.meaning,
          'exampleEn': w.exampleEn,
          'exampleJa': w.exampleJa,
          'level': w.level,
        },
    ],
  };
}

/// アセットの JSON をソース語に戻す（出荷したアセットを回帰テストで検証するため）。
List<SourceWord> readAssetWords(Map<String, Object?> asset) {
  final words = asset['words'];
  if (words is! List) throw const FormatException('words が配列ではありません');
  return [
    for (final raw in words.cast<Map<String, Object?>>())
      SourceWord(
        headword: raw['headword'] as String,
        partOfSpeech: raw['partOfSpeech'] as String,
        phonetic: (raw['phonetic'] as String?) ?? '',
        meaning: raw['meaning'] as String,
        exampleEn: (raw['exampleEn'] as String?) ?? '',
        exampleJa: (raw['exampleJa'] as String?) ?? '',
        level: raw['level'] as int,
        chunk: 'asset',
      ),
  ];
}

/// 語を単語帳のソート順（チャンク順 → 見出し語 → 品詞）に並べる。
///
/// チャンクは分野でまとまっているので、その順を保つと辞書一覧が分野順に読める。
/// チャンクの中を見出し語順にするのは、差分と重複を目で追えるようにするため。
List<SourceWord> sortWords(List<SourceWord> words, List<String> chunkOrder) {
  final rank = {for (var i = 0; i < chunkOrder.length; i++) chunkOrder[i]: i};
  final sorted = [...words];
  sorted.sort((a, b) {
    final c = (rank[a.chunk] ?? 999).compareTo(rank[b.chunk] ?? 999);
    if (c != 0) return c;
    final h = a.headword.compareTo(b.headword);
    if (h != 0) return h;
    return a.partOfSpeech.compareTo(b.partOfSpeech);
  });
  return sorted;
}

/// アセットを人が読める整形で書き出す（差分が読めるように2スペース）。
String encodeAsset(Map<String, Object?> asset) =>
    '${const JsonEncoder.withIndent('  ').convert(asset)}\n';
