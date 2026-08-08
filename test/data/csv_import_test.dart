import 'dart:convert';
import 'dart:typed_data';

import 'package:charset/charset.dart';
import 'package:encello/core/utils/enums.dart';
import 'package:encello/data/services/text_charset.dart';
import 'package:encello/domain/usecases/wordbook_csv_codec.dart';
import 'package:flutter_test/flutter_test.dart';

/// CSV の取り込み（[Docs/06_features/wordbooks.md] §5）。
void main() {
  const header =
      'headword,partOfSpeech,phonetic,meaning,exampleEn,exampleJa,level';

  group('読み取り', () {
    test('ヘッダ行ありを読める', () {
      final result = WordbookCsvCodec.decode(
        '$header\napple,noun,/ˈæpl/,りんご,I ate an apple.,りんごを食べた。,1',
        hasHeader: true,
      );
      expect(result.issues, isEmpty);
      final word = result.words.single;
      expect(word.headword, 'apple');
      expect(word.partOfSpeech, PartOfSpeech.noun);
      expect(word.phonetic, '/ˈæpl/');
      expect(word.meaning, 'りんご');
      expect(word.exampleEn, 'I ate an apple.');
      expect(word.level, 1);
    });

    test('ヘッダ行なしとして読むと1行目も語になる', () {
      final result = WordbookCsvCodec.decode(
        'apple,noun,,りんご,,,2',
        hasHeader: false,
      );
      expect(result.words.single.level, 2);
    });

    test('ヘッダ行を「なし」と指定すると見出し行が弾かれる（自動判定しない）', () {
      final result = WordbookCsvCodec.decode(header, hasHeader: false);
      expect(result.words, isEmpty);
      // `headword` は品詞が不正な行として弾かれる。
      expect(result.issues.single.line, 1);
    });

    test('見出し語は小文字に正規化される', () {
      final result = WordbookCsvCodec.decode(
        'Apple,noun,,りんご,,,1',
        hasHeader: false,
      );
      expect(result.words.single.headword, 'apple');
    });

    test('CRLF でも読める', () {
      final result = WordbookCsvCodec.decode(
        'apple,noun,,りんご,,,1\r\nbanana,noun,,バナナ,,,1',
        hasHeader: false,
      );
      expect(result.words.length, 2);
    });
  });

  group('弾く行と理由', () {
    test('見出し語が空', () {
      final result = WordbookCsvCodec.decode(
        ',noun,,りんご,,,1',
        hasHeader: false,
      );
      expect(result.issues.single.display, contains('見出し語がありません'));
    });

    test('英字以外が含まれる', () {
      final result = WordbookCsvCodec.decode(
        'りんご,noun,,りんご,,,1',
        hasHeader: false,
      );
      expect(result.issues.single.display, contains('英単語として扱えない文字'));
    });

    test('品詞が不正', () {
      final result = WordbookCsvCodec.decode(
        'apple,nouns,,りんご,,,1',
        hasHeader: false,
      );
      expect(result.issues.single.display, contains('品詞が不正です: nouns'));
    });

    test('訳が空', () {
      final result = WordbookCsvCodec.decode(
        'apple,noun,,,,,1',
        hasHeader: false,
      );
      expect(result.issues.single.display, contains('日本語訳がありません'));
    });

    test('レベルが範囲外', () {
      final result = WordbookCsvCodec.decode(
        'apple,noun,,りんご,,,6',
        hasHeader: false,
      );
      expect(result.issues.single.display, contains('レベルは1〜5'));
    });

    test('ファイル内で重複', () {
      final result = WordbookCsvCodec.decode(
        'apple,noun,,りんご,,,1\napple,noun,,林檎,,,1',
        hasHeader: false,
      );
      expect(result.words.length, 1);
      expect(result.issues.single.display, contains('1行目と重複しています'));
    });

    test('弾いた行があっても、通った行は取り込める', () {
      final result = WordbookCsvCodec.decode(
        'apple,noun,,りんご,,,1\n'
        'りんご,noun,,りんご,,,1\n'
        'banana,noun,,バナナ,,,1',
        hasHeader: false,
      );
      expect(result.words.map((w) => w.headword), ['apple', 'banana']);
      expect(result.issues.single.line, 2, reason: '行番号は詰めない');
    });
  });

  group('書き出し', () {
    test('7列のヘッダ付きで書き出し、読み戻せる', () {
      final csv = WordbookCsvCodec.encode([
        const CsvWord(
          headword: 'apple',
          partOfSpeech: PartOfSpeech.noun,
          phonetic: '/ˈæpl/',
          meaning: 'りんご；りんごの木',
          exampleEn: 'I ate an apple.',
          exampleJa: 'りんごを食べた。',
          level: 2,
        ),
      ]);
      expect(csv.split('\n').first, header);

      final back = WordbookCsvCodec.decode(csv, hasHeader: true);
      expect(back.issues, isEmpty);
      expect(back.words.single.meaning, 'りんご；りんごの木');
      expect(back.words.single.level, 2);
    });
  });

  group('文字コード', () {
    test('UTF-8 を読める（BOM 付きも）', () {
      const text = 'apple,noun,,りんご,,,1';
      expect(
        decodeTextFile(Uint8List.fromList(utf8.encode(text)))!.charset,
        TextCharset.utf8,
      );
      final withBom = Uint8List.fromList([
        0xEF,
        0xBB,
        0xBF,
        ...utf8.encode(text),
      ]);
      final decoded = decodeTextFile(withBom)!;
      expect(decoded.charset, TextCharset.utf8);
      expect(decoded.text.startsWith('apple'), isTrue, reason: 'BOM を落とす');
    });

    test('Shift_JIS を読める', () {
      final bytes = Uint8List.fromList(
        const ShiftJISEncoder().convert('apple,noun,,りんご,,,1'),
      );
      final decoded = decodeTextFile(bytes)!;
      expect(decoded.charset, TextCharset.shiftJis);
      expect(decoded.text, 'apple,noun,,りんご,,,1');
      expect(
        WordbookCsvCodec.decode(
          decoded.text,
          hasHeader: false,
        ).words.single.meaning,
        'りんご',
      );
    });

    test('どちらでも読めないバイト列は取り込まない', () {
      // Shift_JIS としても成立しないバイト列。
      final bytes = Uint8List.fromList([0xFF, 0xFE, 0xFD, 0xFC]);
      final decoded = decodeTextFile(bytes);
      // 読めた場合でも文字化けした内容をそのまま単語にしないこと（見出し語で弾かれる）。
      if (decoded != null) {
        final result = WordbookCsvCodec.decode(decoded.text, hasHeader: false);
        expect(result.words, isEmpty);
      }
    });
  });
}
