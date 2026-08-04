import 'dart:convert';
import 'dart:io';

import 'package:encello/data/seeds/pseudoword_assets.dart';
import 'package:encello/data/seeds/seed_importer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_asset_bundle.dart';

/// 擬似語アセットの検証（[Docs/06_features/vocab_size_test.md] §4・§9）。
///
/// アセットの実ファイルを読むため `rootBundle` は使わず、ファイルから読み込んで
/// フェイクバンドルに載せる（ウィジェットバインディングに依存させない）。
void main() {
  late List<String> pseudowords;

  setUpAll(() async {
    final raw = File(PseudowordAssets.assetPath).readAsStringSync();
    pseudowords = await PseudowordAssets(
      FakeAssetBundle({PseudowordAssets.assetPath: raw}),
    ).load();
  });

  test('120語が重複なく読める', () {
    expect(pseudowords.length, 120);
    expect(pseudowords.toSet().length, 120);
  });

  test('すべて小文字の英字（綴りとして自然に見えるもの）', () {
    for (final word in pseudowords) {
      expect(
        RegExp(r'^[a-z]{4,}$').hasMatch(word),
        isTrue,
        reason: '英字4文字以上の小文字であること: $word',
      );
    }
  });

  test('同梱単語帳の見出し語が1つも含まれない', () {
    final headwords = <String>{};
    for (final path in SeedImporter.assetPaths) {
      final json = jsonDecode(File(path).readAsStringSync());
      for (final word in (json as Map<String, dynamic>)['words'] as List) {
        headwords.add(
          (word as Map<String, dynamic>)['headword'].toString().toLowerCase(),
        );
      }
    }
    expect(headwords, isNotEmpty, reason: '同梱単語帳が読めていない');
    expect(
      pseudowords.toSet().intersection(headwords),
      isEmpty,
      reason: '実在語（同梱単語帳の見出し語）が擬似語に混ざっている',
    );
  });

  test('壊れたアセットは推測で補わず例外にする', () async {
    final bundle = FakeAssetBundle({
      PseudowordAssets.assetPath: '{"words": "not-a-list"}',
    });
    expect(
      () => PseudowordAssets(bundle).load(),
      throwsA(isA<FormatException>()),
    );
  });
}
