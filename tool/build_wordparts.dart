import 'dart:convert';
import 'dart:io';

import 'wordbook_validator.dart' show kPartsOfSpeech;

/// 語の部品と派生語ファミリーのソース（`tool/wordparts/src/`）を検証して
/// `assets/word_parts.json` を書き出す
/// （[Docs/06_features/word_parts.md] §9、[Docs/06_features/word_families.md] §8）。
///
/// ```
/// dart run tool/build_wordparts.dart          # 検証して書き出す
/// dart run tool/build_wordparts.dart --check  # 検証だけ
/// ```
///
/// 単語帳のソース（`tool/wordbooks/src/`）を読み、**そこに無い見出し語への
/// 紐付けをエラーにする**。投入時に引けない紐付けを出荷しないため。

const _srcRoot = 'tool/wordparts/src';
const _bookRoot = 'tool/wordbooks/src';
const _outPath = 'assets/word_parts.json';

/// 部品のソース。ディレクトリ走査にしない（列挙漏れに気付けるようにする）。
const _partFiles = <String>['prefixes.json', 'roots.json', 'suffixes.json'];
const _linkFiles = <String>['links_1.json', 'links_2.json', 'links_3.json', 'links_4.json'];
const _familyFile = 'families.json';

/// 部品の種別。`WordPartType`（`lib/core/utils/enums.dart`）と同じ値。
const _types = <String>{'prefix', 'root', 'suffix'};

/// [Docs/06_features/word_parts.md] §5.3。紐付いた語がこれ未満の部品は出題されない。
const _minLinksForQuiz = 3;

final _japanese = RegExp(r'[぀-ヿ㐀-鿿＀-ﾟ]');
final _formPattern = RegExp(r'^-?[a-z]+-?$');

class _Issue {
  final String where;
  final String message;
  const _Issue(this.where, this.message);
  @override
  String toString() => 'ERROR [$where] $message';
}

Future<void> main(List<String> args) async {
  final checkOnly = args.contains('--check');
  final issues = <_Issue>[];

  final headwords = await _readHeadwords(issues);
  final parts = await _readParts(issues);
  final links = await _readLinks(issues, parts, headwords);
  final families = await _readFamilies(issues, headwords);

  _printStats(parts, links, families, headwords);

  for (final i in issues) {
    stderr.writeln(i);
  }
  stdout.writeln('エラー ${issues.length}');
  if (issues.isNotEmpty) {
    stderr.writeln('エラーがあるため書き出しません');
    exitCode = 1;
    return;
  }
  if (checkOnly) return;

  final seedVersion = await _readSeedVersion();
  final asset = <String, Object?>{
    'seedVersion': seedVersion,
    'parts': parts,
    'links': links,
    'families': families,
  };
  await File(_outPath).writeAsString('${jsonEncode(asset)}\n');
  stdout.writeln('書き出し: $_outPath（seedVersion $seedVersion）');
}

/// 単語帳のソースにある `(headword, partOfSpeech)` を集める。
///
/// 紐付けは見出し語単位なので品詞は問わないが、品詞が不正なものは
/// 単語帳側の検証で落ちるのでここでは見ない。
Future<Map<String, Set<String>>> _readHeadwords(List<_Issue> issues) async {
  final result = <String, Set<String>>{};
  final root = Directory(_bookRoot);
  if (!root.existsSync()) {
    issues.add(const _Issue(_bookRoot, 'ディレクトリがありません'));
    return result;
  }
  for (final dir in root.listSync().whereType<Directory>()) {
    final manifest =
        jsonDecode(await File('${dir.path}/_book.json').readAsString())
            as Map<String, Object?>;
    for (final chunk in (manifest['chunks'] as List).cast<String>()) {
      final decoded =
          jsonDecode(await File('${dir.path}/$chunk.json').readAsString())
              as Map<String, Object?>;
      for (final w in (decoded['words'] as List).cast<Map<String, Object?>>()) {
        final headword = w['headword'] as String;
        final pos = w['partOfSpeech'] as String;
        if (!kPartsOfSpeech.contains(pos)) continue;
        result.putIfAbsent(headword, () => <String>{}).add(pos);
      }
    }
  }
  return result;
}

Future<List<Map<String, Object?>>> _readParts(List<_Issue> issues) async {
  final parts = <Map<String, Object?>>[];
  final seen = <String>{};

  for (final name in _partFiles) {
    final file = File('$_srcRoot/$name');
    if (!file.existsSync()) {
      issues.add(_Issue(name, 'ファイルがありません'));
      continue;
    }
    final decoded =
        jsonDecode(await file.readAsString()) as Map<String, Object?>;
    final type = decoded['type'] as String?;
    if (type == null || !_types.contains(type)) {
      issues.add(_Issue(name, 'type が不正です: $type'));
      continue;
    }
    for (final raw in (decoded['parts'] as List).cast<Map<String, Object?>>()) {
      final form = raw['form'] as String?;
      if (form == null || !_formPattern.hasMatch(form)) {
        issues.add(_Issue(name, 'form に使えない文字があります: $form'));
        continue;
      }
      // ハイフンの位置が種別を表す（§2.1）。ずれていると一覧の見た目が壊れる。
      final expected = switch (type) {
        'prefix' => form.endsWith('-') && !form.startsWith('-'),
        'suffix' => form.startsWith('-') && !form.endsWith('-'),
        _ => !form.startsWith('-') && !form.endsWith('-'),
      };
      if (!expected) {
        issues.add(_Issue('$name / $form', '$type のハイフンの位置が違います'));
      }
      if (!seen.add(form)) {
        issues.add(_Issue('$name / $form', 'form が重複しています'));
      }
      final meaning = raw['meaning'] as String?;
      if (meaning == null || meaning.isEmpty) {
        issues.add(_Issue('$name / $form', 'meaning がありません'));
      } else {
        if (!_japanese.hasMatch(meaning)) {
          issues.add(_Issue('$name / $form', 'meaning に日本語がありません'));
        }
        if (meaning.contains('（')) {
          issues.add(_Issue('$name / $form', 'meaning に丸括弧があります'));
        }
      }
      final level = raw['level'];
      if (level is! int || level < 1 || level > 5) {
        issues.add(_Issue('$name / $form', 'level が 1〜5 ではありません: $level'));
      }
      for (final key in ['origin', 'note']) {
        final v = raw[key];
        if (v != null && v is! String) {
          issues.add(_Issue('$name / $form', '$key が文字列ではありません'));
        }
      }
      parts.add({
        'form': form,
        'type': type,
        'meaning': meaning ?? '',
        'origin': raw['origin'],
        'note': raw['note'],
        'level': level is int ? level : 1,
      });
    }
  }
  return parts;
}

Future<List<Map<String, Object?>>> _readLinks(
  List<_Issue> issues,
  List<Map<String, Object?>> parts,
  Map<String, Set<String>> headwords,
) async {
  final forms = {for (final p in parts) p['form'] as String};
  final links = <Map<String, Object?>>[];
  final seen = <String>{};

  for (final name in _linkFiles) {
    final file = File('$_srcRoot/$name');
    if (!file.existsSync()) {
      issues.add(_Issue(name, 'ファイルがありません'));
      continue;
    }
    final decoded =
        jsonDecode(await file.readAsString()) as Map<String, Object?>;
    for (final raw in (decoded['links'] as List).cast<Map<String, Object?>>()) {
      final headword = raw['headword'] as String?;
      if (headword == null || headword.isEmpty) {
        issues.add(_Issue(name, 'headword がありません'));
        continue;
      }
      // 単語帳に無い語へ紐付けても投入時に引けない。
      if (!headwords.containsKey(headword)) {
        issues.add(_Issue('$name / $headword', '単語帳にこの見出し語がありません'));
        continue;
      }
      if (!seen.add(headword)) {
        issues.add(_Issue('$name / $headword', 'headword が重複しています'));
        continue;
      }
      final list = raw['parts'];
      if (list is! List || list.isEmpty) {
        issues.add(_Issue('$name / $headword', 'parts がありません'));
        continue;
      }
      final formsInLink = list.cast<String>();
      final dup = <String>{};
      for (final f in formsInLink) {
        if (!forms.contains(f)) {
          issues.add(_Issue('$name / $headword', '知らない部品です: $f'));
        }
        if (!dup.add(f)) {
          issues.add(_Issue('$name / $headword', '同じ部品が2回あります: $f'));
        }
      }
      final note = raw['partsNote'];
      if (note != null) {
        if (note is! String || note.isEmpty) {
          issues.add(_Issue('$name / $headword', 'partsNote が文字列ではありません'));
        } else {
          if (!_japanese.hasMatch(note)) {
            issues.add(_Issue('$name / $headword', 'partsNote に日本語がありません'));
          }
          if (note.contains('（')) {
            issues.add(_Issue('$name / $headword', 'partsNote に丸括弧があります'));
          }
        }
      }
      links.add({
        'headword': headword,
        'parts': formsInLink,
        'partsNote': note,
      });
    }
  }
  return links;
}

Future<List<Map<String, Object?>>> _readFamilies(
  List<_Issue> issues,
  Map<String, Set<String>> headwords,
) async {
  final file = File('$_srcRoot/$_familyFile');
  if (!file.existsSync()) {
    issues.add(_Issue(_familyFile, 'ファイルがありません'));
    return const [];
  }
  final decoded = jsonDecode(await file.readAsString()) as Map<String, Object?>;
  final families = <Map<String, Object?>>[];
  final seenBase = <String>{};
  // 1語は1つの語族にしか属せない（`words.familyId` が1つしか持てない）。
  final owner = <String, String>{};

  for (final raw
      in (decoded['families'] as List).cast<Map<String, Object?>>()) {
    final base = raw['baseForm'] as String?;
    if (base == null || base.isEmpty) {
      issues.add(_Issue(_familyFile, 'baseForm がありません'));
      continue;
    }
    if (!seenBase.add(base)) {
      issues.add(_Issue('$_familyFile / $base', 'baseForm が重複しています'));
      continue;
    }
    final members = raw['members'];
    if (members is! List || members.length < 2) {
      // 1語の語族はカードも出題も成立しない（word_families.md §3・§4.2）。
      issues.add(_Issue('$_familyFile / $base', 'members が2語未満です'));
      continue;
    }
    final list = members.cast<String>();
    if (!list.contains(base)) {
      issues.add(_Issue('$_familyFile / $base', 'baseForm が members に入っていません'));
    }
    final dup = <String>{};
    for (final m in list) {
      if (!headwords.containsKey(m)) {
        issues.add(_Issue('$_familyFile / $base', '単語帳にこの見出し語がありません: $m'));
        continue;
      }
      if (!dup.add(m)) {
        issues.add(_Issue('$_familyFile / $base', 'members に同じ語が2回あります: $m'));
        continue;
      }
      final other = owner[m];
      if (other != null) {
        issues.add(_Issue('$_familyFile / $base', '$m は $other の語族にも入っています'));
        continue;
      }
      owner[m] = base;
    }
    families.add({'baseForm': base, 'note': raw['note'], 'members': list});
  }
  return families;
}

/// 単語帳の `seedVersion` に合わせる。
///
/// 投入ゲートはアセットの最大 `seedVersion` だけを見るため、
/// 部品だけ版がずれていると端末に届かない
/// （[Docs/06_features/wordbooks.md] §3.1）。
Future<int> _readSeedVersion() async {
  final versions = <int>{};
  for (final dir in Directory(_bookRoot).listSync().whereType<Directory>()) {
    final manifest =
        jsonDecode(await File('${dir.path}/_book.json').readAsString())
            as Map<String, Object?>;
    versions.add(manifest['seedVersion'] as int);
  }
  if (versions.length != 1) {
    throw StateError('単語帳の seedVersion がそろっていません: $versions');
  }
  return versions.single;
}

void _printStats(
  List<Map<String, Object?>> parts,
  List<Map<String, Object?>> links,
  List<Map<String, Object?>> families,
  Map<String, Set<String>> headwords,
) {
  final byType = <String, int>{};
  for (final p in parts) {
    byType[p['type'] as String] = (byType[p['type'] as String] ?? 0) + 1;
  }
  final linkCount = <String, int>{};
  var linkRows = 0;
  for (final l in links) {
    for (final f in (l['parts'] as List).cast<String>()) {
      linkCount[f] = (linkCount[f] ?? 0) + 1;
      linkRows++;
    }
  }
  final quizzable = linkCount.values.where((n) => n >= _minLinksForQuiz).length;
  final unlinked = parts
      .map((p) => p['form'] as String)
      .where((f) => !linkCount.containsKey(f))
      .toList();
  final familyMembers = families.fold(
    0,
    (sum, f) => sum + (f['members'] as List).length,
  );
  final withNote = links.where((l) => l['partsNote'] != null).length;

  stdout
    ..writeln('=== 語の部品 ===')
    ..writeln(
      '部品 ${parts.length}（${byType.entries.map((e) => "${e.key}=${e.value}").join(" ")}）',
    )
    ..writeln('紐付け ${links.length}語 / 部品との組 $linkRows 組')
    ..writeln('partsNote あり $withNote 語')
    ..writeln(
      '$_minLinksForQuiz語以上に紐付いた部品 $quizzable（語のつくりモードで出題されるのはこれだけ・§5.3）',
    )
    ..writeln(
      '紐付けが無い部品 ${unlinked.length}'
      '${unlinked.isEmpty ? "" : ": ${unlinked.join(" ")}"}',
    )
    ..writeln('語族 ${families.length} / 延べ $familyMembers 語')
    ..writeln('単語帳の見出し語 ${headwords.length}');
}
