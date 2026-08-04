import 'package:encello/domain/usecases/shared_text_parser.dart';
import 'package:flutter_test/flutter_test.dart';

/// 共有テキストの解釈（[Docs/06_features/my_words.md] §4.2、§8）。
/// **推測で見出し語を決めない**ことを固定する。
void main() {
  group('空文字', () {
    test('見出し語・文・候補のすべてが空になる', () {
      final result = SharedTextParser.parse('');
      expect(result.headword, isEmpty);
      expect(result.sentence, isEmpty);
      expect(result.candidateWords, isEmpty);
    });

    test('空白だけの文字列も空扱いになる', () {
      final result = SharedTextParser.parse('   ');
      expect(result.headword, isEmpty);
      expect(result.sentence, isEmpty);
      expect(result.candidateWords, isEmpty);
    });
  });

  group('1語（英字のみ）', () {
    test('見出し語に入る', () {
      final result = SharedTextParser.parse('apple');
      expect(result.headword, 'apple');
      expect(result.sentence, isEmpty);
      expect(result.candidateWords, isEmpty);
    });

    test('大文字は小文字化される', () {
      final result = SharedTextParser.parse('Apple');
      expect(result.headword, 'apple');
    });

    test('前後の空白は取り除かれる', () {
      final result = SharedTextParser.parse('  apple  ');
      expect(result.headword, 'apple');
    });
  });

  group('複数語の文', () {
    test('文が「見つけた文」に入り、語がチップの候補になる', () {
      final result = SharedTextParser.parse('I have an apple.');
      expect(result.headword, isEmpty);
      expect(result.sentence, 'I have an apple.');
      expect(result.candidateWords, ['i', 'have', 'an', 'apple']);
    });

    test('候補は重複を除いて最初の出現順になる', () {
      final result = SharedTextParser.parse('a cat and a dog');
      expect(result.candidateWords, ['a', 'cat', 'and', 'dog']);
    });
  });

  group('英字以外の記号混じり', () {
    test('1語であっても記号が付いていれば推測で見出し語にしない', () {
      final result = SharedTextParser.parse('apple!');
      expect(result.headword, isEmpty);
      expect(result.sentence, 'apple!');
      expect(result.candidateWords, ['apple']);
    });

    test('数字は候補から除かれる', () {
      final result = SharedTextParser.parse('page 123 apple');
      expect(result.headword, isEmpty);
      expect(result.candidateWords, ['page', 'apple']);
    });
  });

  group('日本語を含む', () {
    test('見出し語は空のまま、文だけが入る', () {
      final result = SharedTextParser.parse('これは apple です');
      expect(result.headword, isEmpty);
      expect(result.sentence, 'これは apple です');
      expect(result.candidateWords, isEmpty);
    });

    test('日本語だけの文でも同様', () {
      final result = SharedTextParser.parse('この単語を覚える');
      expect(result.headword, isEmpty);
      expect(result.sentence, 'この単語を覚える');
      expect(result.candidateWords, isEmpty);
    });
  });
}
