import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/wordbook_validator.dart';

/// 出荷するプリセットアセットが品質基準を満たしていることを確かめる
/// （[Docs/06_features/wordbooks.md] §3.3）。
///
/// ビルドツールと同じ検証ロジックをアセット側にも当てる。
/// ビルドを通さずに `assets/wordbooks/*.json` を直接触った場合にも気付けるようにするため。
/// 出荷する6冊。`SeedImporter.assetPaths` と同じ並び（易→難）。
const _books = <String>[
  'jhs_v1',
  'hs_basic_v1',
  'hs_advanced_v1',
  'eiken_pre2_v1',
  'eiken_2_v1',
  'toeic_basic_v1',
];

void main() {
  final allowed = _readAllowedWords();

  for (final book in _books) {
    group(book, () {
      final asset =
          jsonDecode(File('assets/wordbooks/$book.json').readAsStringSync())
              as Map<String, Object?>;
      final manifest =
          jsonDecode(
                File('tool/wordbooks/src/$book/_book.json').readAsStringSync(),
              )
              as Map<String, Object?>;
      final words = readAssetWords(asset);

      test('検証エラーが無い', () {
        final levelRange = (manifest['levelRange'] as List).cast<int>();
        final issues = validateWords(
          words,
          minLevel: levelRange.first,
          maxLevel: levelRange.last,
          allowedExampleWords: allowed,
        );
        final errors = issues.where((i) => i.isError).toList();
        expect(errors, isEmpty, reason: errors.join('\n'));
      });

      test('ソースのメタと一致している', () {
        for (final key in const [
          'presetId',
          'name',
          'emoji',
          'category',
          'colorSeed',
          'seedVersion',
          'bandSize',
          'sortOrder',
          'note',
        ]) {
          expect(asset[key], manifest[key], reason: key);
        }
      });

      test('presetId が <presetId>:<headword>:<partOfSpeech> で一意', () {
        final ids = <String>{};
        for (final raw
            in (asset['words'] as List).cast<Map<String, Object?>>()) {
          final expected = '$book:${raw['headword']}:${raw['partOfSpeech']}';
          expect(raw['presetId'], expected);
          expect(ids.add(expected), isTrue, reason: '重複: $expected');
        }
      });

      test('例文と和訳が対になっている', () {
        for (final w in words) {
          expect(
            w.exampleEn.isEmpty,
            w.exampleJa.isEmpty,
            reason: '${w.key}: 例文と和訳が対になっていない',
          );
        }
      });

      test('発音記号が欠けているのは句だけ', () {
        final missing = words
            .where((w) => w.phonetic.isEmpty && w.partOfSpeech != 'phrase')
            .map((w) => w.key)
            .toList();
        expect(missing, isEmpty, reason: '発音記号なし: ${missing.join(", ")}');
      });
    });
  }

  // ここから下は6冊を横断する検査なので、1冊ずつの group の外に置く。
  test('単語帳をまたいで meaning / phonetic / level が食い違っていない', () {
    final wordsByBook = <String, List<SourceWord>>{
      for (final book in _books)
        book: readAssetWords(
          jsonDecode(File('assets/wordbooks/$book.json').readAsStringSync())
              as Map<String, Object?>,
        ),
    };
    final errors = validateAcrossBooks(
      wordsByBook,
    ).where((i) => i.isError).toList();
    expect(errors, isEmpty, reason: errors.join('\n'));
  });
}

Set<String> _readAllowedWords() {
  final words = <String>{};
  for (final line in File(
    'tool/wordbooks/allowed_example_words.txt',
  ).readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    for (final w in trimmed.split(RegExp(r'\s+'))) {
      words.addAll(inflections(w.toLowerCase()));
    }
  }
  return words;
}
