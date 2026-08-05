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
/// ```
///
/// 検証で `error` が1件でも出た単語帳は書き出さない。
/// 半分だけ直った状態のアセットを出荷しないため。

/// 同梱する単語帳のソース。ディレクトリ走査にしない
/// （`SeedImporter.assetPaths` と同じ理由。列挙漏れは投入されないことで気付ける）。
const _books = <String>['jhs_v1'];

const _srcRoot = 'tool/wordbooks/src';
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
  final words = <SourceWord>[];
  for (final chunk in chunkNames) {
    final file = File('$_srcRoot/$book/$chunk.json');
    if (!file.existsSync()) {
      issues.add(
        ValidationIssue(IssueSeverity.error, chunk, '', 'ファイルがありません'),
      );
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
    ..writeln('チャンク: ${byChunk.entries.map((e) => "${e.key}=${e.value}").join(" ")}')
    ..writeln('品詞: ${_sortedCounts(byPos)}')
    ..writeln('レベル: ${_sortedCounts(byLevel)}')
    ..writeln(
      '発音記号なし $noPhonetic（うち句以外 $noPhoneticNonPhrase） / 例文なし $noExample',
    );
}

String _sortedCounts<K extends Comparable<Object>>(Map<K, int> counts) {
  final keys = counts.keys.toList()..sort();
  return keys.map((k) => '$k=${counts[k]}').join(' ');
}
