import 'dart:convert';
import 'dart:io';

import 'wordbook_validator.dart';

/// プリセット単語帳のソース（`tool/wordbooks/src/<presetId>/`）を検証して
/// `assets/wordbooks/<presetId>.json` を書き出す
/// （[Docs/06_features/wordbooks.md] §3.2）。
///
/// ```
/// dart run tool/build_wordbooks.dart              # 全冊を検証して書き出す
/// dart run tool/build_wordbooks.dart --check      # 検証だけ（書き出さない）
/// dart run tool/build_wordbooks.dart --book jhs_v1 --warnings
/// dart run tool/build_wordbooks.dart --check-all  # 単語帳をまたぐ食い違いだけを検査
/// dart run tool/build_wordbooks.dart --check-pool # プール（§3.4）を検査
/// ```
///
/// 検証で `error` が1件でも出た単語帳は書き出さない。
/// 半分だけ直った状態のアセットを出荷しないため。
///
/// `--check-all` は1冊ずつの検証（`--check`）とは別物で、
/// 全単語帳のソースを読んで `meaning` / `phonetic` / `level` の
/// 単語帳をまたぐ食い違いだけを見る（[Docs/06_features/wordbooks.md] §3.3）。

/// 同梱する単語帳のソース。ディレクトリ走査にしない
/// （`SeedImporter.assetPaths` と同じ理由。列挙漏れは投入されないことで気付ける）。
const _books = <String>[
  'jhs_v1',
  'hs_basic_v1',
  'hs_advanced_v1',
  'eiken_pre2_v1',
  'eiken_2_v1',
  'toeic_basic_v1',
];

const _srcRoot = 'tool/wordbooks/src';
const _poolRoot = 'tool/wordbooks/pool';
const _assetRoot = 'assets/wordbooks';
const _allowedWordsPath = 'tool/wordbooks/allowed_example_words.txt';

/// 警告を全部出さないときに表示する件数。
const _warningPreview = 15;

Future<void> main(List<String> args) async {
  final checkOnly = args.contains('--check');
  final showWarnings = args.contains('--warnings');
  final only = _optionValue(args, '--book');

  // 収録済みの見出し語を出す。新しいチャンクを書くときに、すでにある語を
  // 避けるために使う（重複はビルドで弾かれるが、書く前に分かる方がよい）。
  if (args.contains('--list-headwords')) {
    for (final book in _books) {
      if (only != null && only != book) continue;
      for (final headword in await _listHeadwords(book)) {
        stdout.writeln(headword);
      }
    }
    return;
  }

  // 単語帳をまたぐ検査。1冊ずつでは見えない食い違いだけを見る。
  if (args.contains('--check-all')) {
    if (await _checkAllBooks()) return;
    exitCode = 1;
    return;
  }

  // プールの検査。ビルド対象外だが、`_book.json` に足せばそのまま
  // 単語帳に戻せる形なので、規則を満たしていないと戻したときに落ちる。
  if (args.contains('--check-pool')) {
    if (await _checkPool()) return;
    exitCode = 1;
    return;
  }

  final allowed = await _readAllowedWords();
  var failed = false;

  for (final book in _books) {
    if (only != null && only != book) continue;
    final ok = await _buildBook(
      book,
      allowed: allowed,
      checkOnly: checkOnly,
      showWarnings: showWarnings,
    );
    failed = failed || !ok;
  }

  if (failed) exitCode = 1;
}

String? _optionValue(List<String> args, String name) {
  final i = args.indexOf(name);
  if (i < 0 || i + 1 >= args.length) return null;
  return args[i + 1];
}

Future<Set<String>> _readAllowedWords() async {
  final file = File(_allowedWordsPath);
  if (!file.existsSync()) {
    throw StateError('$_allowedWordsPath がありません');
  }
  final words = <String>{};
  for (final line in await file.readAsLines()) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    for (final w in trimmed.split(RegExp(r'\s+'))) {
      words.addAll(inflections(w.toLowerCase()));
    }
  }
  return words;
}

/// 単語帳のソースにある見出し語を、重複を畳んで並べて返す。
Future<List<String>> _listHeadwords(String book) async {
  final manifest =
      jsonDecode(await File('$_srcRoot/$book/_book.json').readAsString())
          as Map<String, Object?>;
  final headwords = <String>{};
  for (final chunk in (manifest['chunks'] as List).cast<String>()) {
    final file = File('$_srcRoot/$book/$chunk.json');
    if (!file.existsSync()) continue;
    final decoded =
        jsonDecode(await file.readAsString()) as Map<String, Object?>;
    for (final raw in (decoded['words'] as List).cast<Map<String, Object?>>()) {
      headwords.add(raw['headword'] as String);
    }
  }
  final sorted = headwords.toList()..sort();
  return sorted;
}

/// `_book.json` に列挙されたチャンクを読んでソース語を返す。
/// 読めなかったチャンクは [issues] に `error` を積んで飛ばす。
Future<List<SourceWord>> _readBookWords(
  String book,
  List<String> chunkNames,
  List<ValidationIssue> issues,
) async {
  final words = <SourceWord>[];
  for (final chunk in chunkNames) {
    final file = File('$_srcRoot/$book/$chunk.json');
    if (!file.existsSync()) {
      issues.add(ValidationIssue(IssueSeverity.error, chunk, '', 'ファイルがありません'));
      continue;
    }
    Object? decoded;
    try {
      decoded = jsonDecode(await file.readAsString());
    } on FormatException catch (e) {
      issues.add(
        ValidationIssue(IssueSeverity.error, chunk, '', 'JSON が壊れています: $e'),
      );
      continue;
    }
    words.addAll(parseChunk(chunk, decoded, issues));
  }
  return words;
}

/// 全単語帳のソースを読み、単語帳をまたぐ食い違いを検査する（`--check-all`）。
///
/// 1冊ずつの検証（`--check`）はここではやらない。
/// この検査だけが「複数冊を並べないと見えない」もののため。
Future<bool> _checkAllBooks() async {
  stdout.writeln('=== 単語帳をまたぐ検査 ===');

  final issues = <ValidationIssue>[];
  final wordsByBook = <String, List<SourceWord>>{};
  for (final book in _books) {
    final manifestFile = File('$_srcRoot/$book/_book.json');
    if (!manifestFile.existsSync()) {
      stderr.writeln('ERROR [$book] ${manifestFile.path} がありません');
      return false;
    }
    final manifest =
        jsonDecode(await manifestFile.readAsString()) as Map<String, Object?>;
    final chunkNames = (manifest['chunks'] as List).cast<String>();
    final bookIssues = <ValidationIssue>[];
    wordsByBook[book] = await _readBookWords(book, chunkNames, bookIssues);
    // ソースが読めない状態では食い違いを正しく数えられないので、
    // 読み込み時のエラーもそのまま失敗として扱う。
    for (final i in bookIssues.where((i) => i.isError)) {
      issues.add(
        ValidationIssue(i.severity, '$book / ${i.chunk}', i.target, i.message),
      );
    }
  }

  issues.addAll(validateAcrossBooks(wordsByBook));

  final errors = issues.where((i) => i.isError).toList();
  final shared = _sharedWordCount(wordsByBook);
  stdout.writeln(
    '${_books.length}冊 / 延べ ${wordsByBook.values.fold(0, (a, w) => a + w.length)} 語'
    ' / 2冊以上に載る語 $shared',
  );
  for (final e in errors) {
    stderr.writeln(e);
  }
  stdout.writeln('エラー ${errors.length}');
  return errors.isEmpty;
}

/// プール（`tool/wordbooks/pool/`）の語を検査する（`--check-pool`）。
///
/// [Docs/06_features/wordbooks.md] §3.4。ここは出荷しないが、
/// 次の作り直しの流用元になるので、規則から外れたまま置かない。
/// 出荷分（`src`）に同じ `(headword, partOfSpeech)` があるときは値もそろえる。
/// そろっていないと、プールから戻した冊が `--check-all` で落ちる。
Future<bool> _checkPool() async {
  stdout.writeln('=== プールの検査 ===');

  final dir = Directory(_poolRoot);
  if (!dir.existsSync()) {
    stderr.writeln('ERROR $_poolRoot がありません');
    return false;
  }

  // 出荷分の値を引くための索引。
  final shipped = <String, SourceWord>{};
  for (final book in _books) {
    final manifest =
        jsonDecode(await File('$_srcRoot/$book/_book.json').readAsString())
            as Map<String, Object?>;
    final chunkNames = (manifest['chunks'] as List).cast<String>();
    for (final w in await _readBookWords(book, chunkNames, [])) {
      shipped[w.key] = w;
    }
  }

  final allowed = await _readAllowedWords();
  final issues = <ValidationIssue>[];
  var total = 0;
  final paths =
      dir
          .listSync()
          .whereType<File>()
          .map((f) => f.path)
          .where((p) => p.endsWith('.json'))
          .toList()
        ..sort();

  // ファイルごとに検査する。同じ語が2冊分のプールに入っていることは
  // ふつうにあるので（`barrel` は2冊から外れた）、まとめて見ると重複で落ちる。
  for (final path in paths) {
    final name = path.split(RegExp(r'[/\\]')).last.replaceAll('.json', '');
    final decoded = jsonDecode(await File(path).readAsString());
    // プールのファイルはチャンクと同じ形。`note` の語数の検査もそのまま効く。
    final words = parseChunk(name, decoded, issues);
    total += words.length;

    // level の範囲は 1〜5 全部を許す（どの単語帳に戻すか決まっていないため）。
    issues.addAll(
      validateWords(
        words,
        minLevel: 1,
        maxLevel: 5,
        allowedExampleWords: allowed,
      ),
    );

    for (final w in words) {
      final ship = shipped[w.key];
      if (ship == null) continue;
      for (final (label, a, b) in <(String, String, String)>[
        ('meaning', w.meaning, ship.meaning),
        ('phonetic', w.phonetic, ship.phonetic),
        ('level', '${w.level}', '${ship.level}'),
      ]) {
        if (a != b) {
          issues.add(
            ValidationIssue(
              IssueSeverity.error,
              name,
              w.key,
              '出荷分と $label が違います: プール[$a] / src[$b]',
            ),
          );
        }
      }
    }
  }

  final errors = issues.where((i) => i.isError).toList();
  stdout.writeln('${paths.length}ファイル / 延べ $total 語');
  for (final e in errors) {
    stderr.writeln(e);
  }
  stdout.writeln('エラー ${errors.length}');
  return errors.isEmpty;
}

/// 2冊以上に載っている `(headword, partOfSpeech)` の数（検査の母数）。
int _sharedWordCount(Map<String, List<SourceWord>> wordsByBook) {
  final books = <String, Set<String>>{};
  for (final entry in wordsByBook.entries) {
    for (final w in entry.value) {
      books.putIfAbsent(w.key, () => <String>{}).add(entry.key);
    }
  }
  return books.values.where((b) => b.length > 1).length;
}

Future<bool> _buildBook(
  String book, {
  required Set<String> allowed,
  required bool checkOnly,
  required bool showWarnings,
}) async {
  stdout.writeln('=== $book ===');

  final manifestFile = File('$_srcRoot/$book/_book.json');
  if (!manifestFile.existsSync()) {
    stderr.writeln('ERROR ${manifestFile.path} がありません');
    return false;
  }
  final manifest =
      jsonDecode(await manifestFile.readAsString()) as Map<String, Object?>;
  final chunkNames = (manifest['chunks'] as List).cast<String>();
  final levelRange = (manifest['levelRange'] as List).cast<int>();

  final issues = <ValidationIssue>[];
  final words = await _readBookWords(book, chunkNames, issues);

  issues.addAll(
    validateWords(
      words,
      minLevel: levelRange.first,
      maxLevel: levelRange.last,
      allowedExampleWords: allowed,
    ),
  );

  final errors = issues.where((i) => i.isError).toList();
  final warnings = issues.where((i) => !i.isError).toList();

  _printStats(words, chunkNames);

  if (warnings.isNotEmpty) {
    final shown = showWarnings ? warnings : warnings.take(_warningPreview);
    for (final w in shown) {
      stdout.writeln(w);
    }
    if (!showWarnings && warnings.length > _warningPreview) {
      stdout.writeln('... 警告 ${warnings.length} 件（--warnings で全件）');
    }
  }
  for (final e in errors) {
    stderr.writeln(e);
  }
  stdout.writeln('警告 ${warnings.length} / エラー ${errors.length}');

  if (errors.isNotEmpty) {
    stderr.writeln('エラーがあるため書き出しません');
    return false;
  }
  if (checkOnly) return true;

  final asset = buildAsset(manifest, sortWords(words, chunkNames));
  final out = File('$_assetRoot/$book.json');
  await out.writeAsString(encodeAsset(asset));
  stdout.writeln('書き出し: ${out.path}');
  return true;
}

void _printStats(List<SourceWord> words, List<String> chunkNames) {
  final byChunk = <String, int>{for (final c in chunkNames) c: 0};
  final byPos = <String, int>{};
  final byLevel = <int, int>{};
  final headwords = <String>{};
  var noPhonetic = 0;
  var noPhoneticNonPhrase = 0;
  var noExample = 0;

  for (final w in words) {
    byChunk[w.chunk] = (byChunk[w.chunk] ?? 0) + 1;
    byPos[w.partOfSpeech] = (byPos[w.partOfSpeech] ?? 0) + 1;
    byLevel[w.level] = (byLevel[w.level] ?? 0) + 1;
    headwords.add(w.headword);
    if (w.phonetic.isEmpty) {
      noPhonetic++;
      if (w.partOfSpeech != 'phrase') noPhoneticNonPhrase++;
    }
    if (w.exampleEn.isEmpty) noExample++;
  }

  stdout
    ..writeln('延べ ${words.length} 語 / 見出し語 ${headwords.length}')
    ..writeln(
      'チャンク: ${byChunk.entries.map((e) => "${e.key}=${e.value}").join(" ")}',
    )
    ..writeln('品詞: ${_sortedCounts(byPos)}')
    ..writeln('レベル: ${_sortedCounts(byLevel)}')
    ..writeln(
      '発音記号なし $noPhonetic（うち句以外 $noPhoneticNonPhrase） / 例文なし $noExample',
    );

  _printSelectionChecks(words, chunkNames);
}

/// 例文に1つも無いと名詞の羅列になる語（冠詞・限定詞・be 動詞・前置詞・代名詞）。
/// 網羅する必要はない。`Appreciate breadth of knowledge experience.` のような
/// 文を見つけるための目印なので、頻出のものだけで足りる。
const _functionWords = <String>{
  'a',
  'an',
  'the',
  'my',
  'your',
  'his',
  'her',
  'its',
  'our',
  'their',
  'whose',
  'this',
  'that',
  'these',
  'those',
  'which',
  'what',
  'some',
  'any',
  'no',
  'every',
  'each',
  'both',
  'all',
  'many',
  'much',
  'several',
  'few',
  'little',
  'other',
  'another',
  'such',
  'is',
  'are',
  'was',
  'were',
  'am',
  'be',
  'been',
  'being',
  'in',
  'on',
  'at',
  'of',
  'for',
  'to',
  'with',
  'from',
  'by',
  'about',
  'into',
  'over',
  'under',
  'after',
  'before',
  'between',
  'among',
  'through',
  'during',
  'against',
  'without',
  'within',
  'across',
  'toward',
  'towards',
  'upon',
  'beyond',
  'throughout',
  'despite',
  'around',
  'behind',
  'beside',
  'besides',
  'since',
  'until',
  'per',
  'onto',
  'off',
  'out',
  'up',
  'down',
  'near',
  'along',
  'amid',
  'i',
  'you',
  'he',
  'she',
  'it',
  'we',
  'they',
  'me',
  'him',
  'us',
  'them',
  'who',
  'there',
  'here',
};

final _wordPattern = RegExp(r"[a-zA-Z']+");

/// [Docs/06_features/wordbooks.md] §2.1 の「機械検査でしか見つからない壊れ方」。
///
/// **形式検証（§3.3）とは別で、エラーにも警告にもしない。**
/// どれも「やり直すか」の判断を人がするための数で、
/// 不合格のまま出荷を止めると作りかけの単語帳がビルドできなくなる。
void _printSelectionChecks(List<SourceWord> words, List<String> chunkNames) {
  final headwords = words.map((w) => w.headword).toSet();
  final initials = <String, int>{};
  for (final h in headwords) {
    initials[h[0]] = (initials[h[0]] ?? 0) + 1;
  }
  final abc = ['a', 'b', 'c'].fold(0, (sum, c) => sum + (initials[c] ?? 0));
  final abcRatio = abc / headwords.length;

  var examples = 0;
  var bareExamples = 0;
  for (final w in words) {
    if (w.exampleEn.isEmpty) continue;
    examples++;
    final tokens = _wordPattern
        .allMatches(w.exampleEn.toLowerCase())
        .map((m) => m[0]!);
    if (!tokens.any(_functionWords.contains)) bareExamples++;
  }
  final bareRatio = examples == 0 ? 0.0 : bareExamples / examples;

  final parens = words.where((w) => w.meaning.contains('（')).length;

  // チャンクごとの最上位 level の割合。範囲外の語を混ぜていると半分を超える。
  final topLevel = words.map((w) => w.level).reduce((a, b) => a > b ? a : b);
  final overTopLevel = <String>[];
  for (final chunk in chunkNames) {
    final inChunk = words.where((w) => w.chunk == chunk).toList();
    if (inChunk.isEmpty) continue;
    final top = inChunk.where((w) => w.level == topLevel).length;
    if (top * 2 > inChunk.length) {
      overTopLevel.add('$chunk=${(top / inChunk.length * 100).round()}%');
    }
  }

  stdout
    ..writeln('--- 選定の検査（§2.1・エラーにはしない）')
    ..writeln(
      '頭文字 a+b+c ${(abcRatio * 100).round()}%'
      '（半分超で選定やり直し）${abcRatio > 0.5 ? " 不合格" : ""}',
    )
    ..writeln(
      '機能語ゼロの例文 $bareExamples/$examples ${(bareRatio * 100).toStringAsFixed(1)}%'
      '（1割超で例文作り直し）${bareRatio > 0.1 ? " 不合格" : ""}',
    )
    ..writeln('訳の丸括弧 $parens 件（§2.2 (g)）')
    ..writeln(
      'level $topLevel が半分を超えるチャンク: '
      '${overTopLevel.isEmpty ? "なし" : overTopLevel.join(" ")}',
    );
}

String _sortedCounts<K extends Comparable<Object>>(Map<K, int> counts) {
  final keys = counts.keys.toList()..sort();
  return keys.map((k) => '$k=${counts[k]}').join(' ');
}
