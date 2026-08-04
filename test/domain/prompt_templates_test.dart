import 'dart:io';

import 'package:encello/data/seeds/prompt_assets.dart';
import 'package:encello/domain/usecases/wordbook_json_codec.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_asset_bundle.dart';

/// プロンプトとスキーマの同期テスト（[Docs/06_features/ai_import.md] §4.3）。
///
/// アセットの実ファイルを読むため `rootBundle` は使わず、ファイルから読み込んで
/// フェイクバンドルに載せる（[pseudowords_test.dart] と同じ作法）。
/// `CachingAssetBundle` はテストごとに作り直す（使い回すと2件目以降でハングする）。
void main() {
  final askWordbook = File(PromptAssets.askWordbookPath).readAsStringSync();
  final convertToWordbook = File(
    PromptAssets.convertToWordbookPath,
  ).readAsStringSync();
  final askWordbookForImport = File(
    PromptAssets.askWordbookForImportPath,
  ).readAsStringSync();
  final fixWordbook = File(PromptAssets.fixWordbookPath).readAsStringSync();

  const requiredFields = [
    'encelloWordbook',
    'name',
    'words',
    'headword',
    'partOfSpeech',
    'meaning',
  ];

  final schemaTemplates = {
    '① ask_wordbook': askWordbook,
    '② convert_to_wordbook': convertToWordbook,
    '③ ask_wordbook_for_import': askWordbookForImport,
  };

  final themeTemplates = {
    '① ask_wordbook': askWordbook,
    '③ ask_wordbook_for_import': askWordbookForImport,
  };

  group('①②③にスキーマの必須フィールド名がすべて含まれる', () {
    for (final entry in schemaTemplates.entries) {
      test(entry.key, () {
        for (final field in requiredFields) {
          expect(
            entry.value.contains(field),
            isTrue,
            reason: '${entry.key} に "$field" が含まれていません',
          );
        }
      });
    }
  });

  group('①③はテーマ・語数・レベルのトークンを持つ', () {
    for (final entry in themeTemplates.entries) {
      test(entry.key, () {
        expect(entry.value.contains('{{theme}}'), isTrue);
        expect(entry.value.contains('{{count}}'), isTrue);
        expect(entry.value.contains('{{level}}'), isTrue);
      });
    }
  });

  test('④ fix_wordbook は {{errors}} と {{source}} のトークンを持つ', () {
    expect(fixWordbook.contains('{{errors}}'), isTrue);
    expect(fixWordbook.contains('{{source}}'), isTrue);
  });

  group('①③の【出力例】がそのまま取り込める', () {
    test('① ask_wordbook', () {
      final example = askWordbook.split('【出力例】').last;
      final result = WordbookJsonCodec.decode(example);
      expect(result.isClean, isTrue, reason: '${result.issues}');
    });

    test('③ ask_wordbook_for_import', () {
      final example = askWordbookForImport.split('【出力例】').last;
      final result = WordbookJsonCodec.decode(example);
      expect(result.isClean, isTrue, reason: '${result.issues}');
    });
  });

  group('PromptAssets のトークン差し替え', () {
    test('① テーマ・語数・レベルが差し込まれる', () async {
      final assets = PromptAssets(
        FakeAssetBundle({PromptAssets.askWordbookPath: askWordbook}),
      );
      final prompt = await assets.askWordbook(
        theme: '恐竜の名前',
        count: 15,
        level: '小学生',
      );
      expect(prompt.contains('恐竜の名前'), isTrue);
      expect(prompt.contains('15語'), isTrue);
      expect(prompt.contains('小学生'), isTrue);
      expect(prompt.contains('{{theme}}'), isFalse);
      expect(prompt.contains('{{count}}'), isFalse);
      expect(prompt.contains('{{level}}'), isFalse);
    });

    test('② はそのまま返る（差し込みトークンなし）', () async {
      final assets = PromptAssets(
        FakeAssetBundle({
          PromptAssets.convertToWordbookPath: convertToWordbook,
        }),
      );
      final prompt = await assets.convertToWordbook();
      expect(prompt, convertToWordbook);
    });

    test('③ テーマ・語数・レベルが差し込まれる', () async {
      final assets = PromptAssets(
        FakeAssetBundle({
          PromptAssets.askWordbookForImportPath: askWordbookForImport,
        }),
      );
      final prompt = await assets.askWordbookForImport(
        theme: '空港と飛行機',
        count: 30,
        level: '高校生',
      );
      expect(prompt.contains('空港と飛行機'), isTrue);
      expect(prompt.contains('30語'), isTrue);
      expect(prompt.contains('高校生'), isTrue);
    });

    test('④ エラー一覧と元テキストが差し込まれる', () async {
      final assets = PromptAssets(
        FakeAssetBundle({PromptAssets.fixWordbookPath: fixWordbook}),
      );
      final prompt = await assets.fixWordbook(
        errors: '3語目「Patient!」: 英単語として扱えない文字が含まれます',
        source: '{"encelloWordbook":"1"}',
      );
      expect(prompt.contains('3語目「Patient!」'), isTrue);
      expect(prompt.contains('{"encelloWordbook":"1"}'), isTrue);
    });

    test('壊れたアセット（空ファイル）は推測で補わず例外にする', () async {
      final assets = PromptAssets(
        FakeAssetBundle({PromptAssets.askWordbookPath: ''}),
      );
      expect(
        () => assets.askWordbook(theme: 'x', count: 1, level: 'y'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
