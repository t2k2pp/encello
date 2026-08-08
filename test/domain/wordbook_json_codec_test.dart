import 'dart:convert';

import 'package:encello/domain/usecases/wordbook_json_codec.dart';
import 'package:flutter_test/flutter_test.dart';

/// [Docs/06_features/ai_import.md] §7 のテスト観点。
void main() {
  String validJson({
    String version = '1',
    String name = '看護実習の英単語',
    String? emoji = '🩺',
    String? note = '実習で出てくる基本語',
    List<Map<String, Object?>>? words,
  }) {
    final wordList =
        words ??
        [
          {
            'headword': 'patient',
            'partOfSpeech': 'noun',
            'phonetic': '/ˈpeɪʃənt/',
            'meaning': '患者',
            'exampleEn': 'The patient is resting in the next room.',
            'exampleJa': 'その患者は隣の部屋で休んでいます。',
            'level': 2,
          },
          {
            'headword': 'take care of',
            'partOfSpeech': 'phrase',
            'meaning': '〜の世話をする',
            'level': 2,
          },
        ];
    final map = {
      'encelloWordbook': version,
      'name': name,
      'emoji': ?emoji,
      'note': ?note,
      'words': wordList,
    };
    return jsonEncode(map);
  }

  group('正常系', () {
    test('スキーマ通りの内容がそのまま取り込める', () {
      final result = WordbookJsonCodec.decode(validJson());
      expect(result.isClean, isTrue);
      expect(result.issues, isEmpty);
      final book = result.book!;
      expect(book.name, '看護実習の英単語');
      expect(book.emoji, '🩺');
      expect(book.note, '実習で出てくる基本語');
      expect(book.words, hasLength(2));
      expect(book.words[0].headword, 'patient');
      expect(book.words[0].exampleJa, 'その患者は隣の部屋で休んでいます。');
      expect(book.words[1].headword, 'take care of');
      expect(book.words[1].phonetic, isNull);
    });

    test('見出し語は小文字で保存される', () {
      final result = WordbookJsonCodec.decode(
        validJson(
          words: [
            {'headword': 'Apple', 'partOfSpeech': 'noun', 'meaning': 'りんご'},
          ],
        ),
      );
      expect(result.book!.words.single.headword, 'apple');
    });

    test('emoji・note を省略すると既定値になる', () {
      final result = WordbookJsonCodec.decode(
        validJson(emoji: null, note: null),
      );
      expect(result.book!.emoji, '📗');
      expect(result.book!.note, isNull);
    });
  });

  group('前処理', () {
    test('コードフェンスを除去して取り込める', () {
      final wrapped = '```json\n${validJson()}\n```';
      final result = WordbookJsonCodec.decode(wrapped);
      expect(result.isClean, isTrue);
    });

    test('前置き・後置きの説明文を無視する', () {
      final wrapped = 'はい、単語帳を作りました。\n\n${validJson()}\n\n他にご質問があればどうぞ。';
      final result = WordbookJsonCodec.decode(wrapped);
      expect(result.isClean, isTrue);
    });

    test('先頭・末尾の空白と BOM を除去する', () {
      final wrapped = '﻿  \n${validJson()}\n  ';
      final result = WordbookJsonCodec.decode(wrapped);
      expect(result.isClean, isTrue);
    });

    test('全角引用符で壊れた JSON は修復されずエラーになる（推測修復の回帰）', () {
      // 全角引用符・全角コロンを使った壊れたデータ。半角化して救わない。
      const broken = '{＂encelloWordbook＂：＂1＂，＂name＂：＂テスト＂，＂words＂：[]}';
      final result = WordbookJsonCodec.decode(broken);
      expect(result.book, isNull);
      expect(result.issues, isNotEmpty);
      expect(
        result.issues.every(
          (i) => !i.message.contains('全角') && !i.message.contains('半角'),
        ),
        isTrue,
        reason: '推測で直した形跡（全角/半角への言及）があってはいけない',
      );
    });
  });

  group('境界値', () {
    test('単語帳の名前は40文字まで有効', () {
      final result = WordbookJsonCodec.decode(validJson(name: 'あ' * 40));
      expect(result.isClean, isTrue);
    });

    test('単語帳の名前は41文字で無効', () {
      final result = WordbookJsonCodec.decode(validJson(name: 'あ' * 41));
      expect(result.book, isNull);
      expect(result.issues.single.message, contains('40文字以内'));
    });

    test('語数は200件まで有効', () {
      final words = List.generate(
        200,
        (i) => {
          'headword': _alphaHeadword(i),
          'partOfSpeech': 'noun',
          'meaning': '意味$i',
        },
      );
      final result = WordbookJsonCodec.decode(validJson(words: words));
      expect(result.isClean, isTrue, reason: '${result.issues}');
      expect(result.book!.words, hasLength(200));
    });

    test('語数は201件で無効（50語ずつに分ける案内）', () {
      final words = List.generate(
        201,
        (i) => {
          'headword': _alphaHeadword(i),
          'partOfSpeech': 'noun',
          'meaning': '意味$i',
        },
      );
      final result = WordbookJsonCodec.decode(validJson(words: words));
      expect(result.book, isNull);
      expect(result.issues.single.message, contains('50語ずつ'));
    });

    test('level は1〜5が有効、0と6は無効', () {
      Map<String, Object?> wordWithLevel(int level) => {
        'headword': 'apple',
        'partOfSpeech': 'noun',
        'meaning': 'りんご',
        'level': level,
      };

      for (final level in [1, 5]) {
        final result = WordbookJsonCodec.decode(
          validJson(words: [wordWithLevel(level)]),
        );
        expect(result.isClean, isTrue, reason: 'level=$level は有効');
      }
      for (final level in [0, 6]) {
        final result = WordbookJsonCodec.decode(
          validJson(words: [wordWithLevel(level)]),
        );
        expect(result.book, isNull, reason: 'level=$level は無効');
        expect(result.issues.any((i) => i.message.contains('1〜5')), isTrue);
      }
    });

    test('level を省略すると1になる', () {
      final result = WordbookJsonCodec.decode(
        validJson(
          words: [
            {'headword': 'apple', 'partOfSpeech': 'noun', 'meaning': 'りんご'},
          ],
        ),
      );
      expect(result.book!.words.single.level, 1);
    });

    test('見出し語は60文字まで有効、61文字は無効', () {
      final ok = WordbookJsonCodec.decode(
        validJson(
          words: [
            {'headword': 'a' * 60, 'partOfSpeech': 'noun', 'meaning': 'いみ'},
          ],
        ),
      );
      expect(ok.isClean, isTrue);

      final ng = WordbookJsonCodec.decode(
        validJson(
          words: [
            {'headword': 'a' * 61, 'partOfSpeech': 'noun', 'meaning': 'いみ'},
          ],
        ),
      );
      expect(ng.book, isNull);
      expect(ng.issues.any((i) => i.message.contains('60文字以内')), isTrue);
    });
  });

  group('フィールドごとの検証', () {
    test('英単語として扱えない文字は弾かれる', () {
      final result = WordbookJsonCodec.decode(
        validJson(
          words: [
            {'headword': 'Patient!', 'partOfSpeech': 'noun', 'meaning': '患者'},
          ],
        ),
      );
      expect(result.book, isNull);
      final issue = result.issues.firstWhere((i) => i.index == 1);
      expect(issue.headword, 'Patient!');
      expect(issue.message, contains('英単語として扱えない文字'));
    });

    test('品詞が不正な語は理由付きで弾かれる', () {
      final result = WordbookJsonCodec.decode(
        validJson(
          words: [
            {'headword': 'run', 'partOfSpeech': 'verbs', 'meaning': '走る'},
          ],
        ),
      );
      expect(result.issues.any((i) => i.message.contains('verbs')), isTrue);
    });

    test('日本語訳が無い語は弾かれる', () {
      final result = WordbookJsonCodec.decode(
        validJson(
          words: [
            {'headword': 'run', 'partOfSpeech': 'verb', 'meaning': ''},
          ],
        ),
      );
      expect(result.issues.any((i) => i.message.contains('日本語訳')), isTrue);
    });

    test('exampleEn だけがある語は exampleJa 必須エラーになる', () {
      final result = WordbookJsonCodec.decode(
        validJson(
          words: [
            {
              'headword': 'run',
              'partOfSpeech': 'verb',
              'meaning': '走る',
              'exampleEn': 'I run every morning.',
            },
          ],
        ),
      );
      expect(result.book, isNull);
      expect(result.issues.any((i) => i.message.contains('日本語訳')), isTrue);
    });

    test('exampleEn と exampleJa が両方あれば有効', () {
      final result = WordbookJsonCodec.decode(
        validJson(
          words: [
            {
              'headword': 'run',
              'partOfSpeech': 'verb',
              'meaning': '走る',
              'exampleEn': 'I run every morning.',
              'exampleJa': '私は毎朝走ります。',
            },
          ],
        ),
      );
      expect(result.isClean, isTrue);
    });
  });

  group('版の不一致', () {
    test('encelloWordbook が "1" 以外なら更新案内になる', () {
      final result = WordbookJsonCodec.decode(validJson(version: '2'));
      expect(result.book, isNull);
      expect(result.issues.single.message, '新しい形式です。アプリを更新してください');
    });
  });

  group('ファイル内重複', () {
    test('(headword, partOfSpeech) の重複は最初の出現の位置を示す', () {
      final result = WordbookJsonCodec.decode(
        validJson(
          words: [
            {'headword': 'apple', 'partOfSpeech': 'noun', 'meaning': 'りんご1'},
            {'headword': 'run', 'partOfSpeech': 'verb', 'meaning': '走る'},
            {'headword': 'apple', 'partOfSpeech': 'noun', 'meaning': 'りんご2'},
          ],
        ),
      );
      expect(result.isPartial, isTrue);
      final dup = result.issues.single;
      expect(dup.index, 3);
      expect(dup.headword, 'apple');
      expect(dup.message, '1語目と重複しています');
      // 重複した3語目は弾かれ、最初の apple と run だけが残る。
      expect(result.book!.words.map((w) => w.headword), ['apple', 'run']);
    });

    test('品詞が違えば同じ見出し語でも重複にならない', () {
      final result = WordbookJsonCodec.decode(
        validJson(
          words: [
            {'headword': 'run', 'partOfSpeech': 'verb', 'meaning': '走る'},
            {'headword': 'run', 'partOfSpeech': 'noun', 'meaning': '一走り'},
          ],
        ),
      );
      expect(result.isClean, isTrue);
      expect(result.book!.words, hasLength(2));
    });
  });

  group('エラーの全件列挙', () {
    test('複数の不正行がすべて出る（最初の1件で打ち切らない）', () {
      final result = WordbookJsonCodec.decode(
        validJson(
          words: [
            {'headword': 'Patient!', 'partOfSpeech': 'noun', 'meaning': '患者'},
            {'headword': 'run', 'partOfSpeech': 'verb', 'meaning': ''},
            {'headword': 'walk', 'partOfSpeech': 'verbs', 'meaning': '歩く'},
            {'headword': 'apple', 'partOfSpeech': 'noun', 'meaning': 'りんご'},
          ],
        ),
      );
      expect(result.isPartial, isTrue);
      expect(result.issues, hasLength(3));
      expect(result.issues[0].index, 1);
      expect(result.issues[1].index, 2);
      expect(result.issues[2].index, 3);
      // 有効だった4語目（apple）だけが残る。
      expect(result.book!.words.single.headword, 'apple');
    });
  });

  group('致命的な失敗', () {
    test('単語の一覧が無ければ致命的な失敗になる', () {
      final json = jsonEncode({'encelloWordbook': '1', 'name': 'テスト'});
      final result = WordbookJsonCodec.decode(json);
      expect(result.book, isNull);
      expect(result.issues, isNotEmpty);
    });

    test('単語が1件もなければ致命的な失敗になる', () {
      final result = WordbookJsonCodec.decode(validJson(words: []));
      expect(result.book, isNull);
      expect(result.issues.single.message, contains('1件もありません'));
    });

    test('壊れた内容として読み取れない入力はエラーになる', () {
      final result = WordbookJsonCodec.decode('これは単語帳ではありません');
      expect(result.book, isNull);
      expect(result.issues, isNotEmpty);
    });

    test('すべての語が不正なら取り込める語がないと案内する', () {
      final result = WordbookJsonCodec.decode(
        validJson(
          words: [
            {'headword': 'Patient!', 'partOfSpeech': 'noun', 'meaning': '患者'},
          ],
        ),
      );
      expect(result.book, isNull);
      expect(result.issues.any((i) => i.message.contains('取り込める語')), isTrue);
    });
  });

  group('describeIssues', () {
    test('全件を1行ずつの複数行テキストにする', () {
      final result = WordbookJsonCodec.decode(
        validJson(
          words: [
            {'headword': 'Patient!', 'partOfSpeech': 'noun', 'meaning': '患者'},
            {'headword': 'run', 'partOfSpeech': 'verb', 'meaning': ''},
            {'headword': 'apple', 'partOfSpeech': 'noun', 'meaning': 'りんご'},
          ],
        ),
      );
      final text = WordbookJsonCodec.describeIssues(result.issues);
      expect(text.split('\n'), hasLength(2));
      expect(text, contains('1語目'));
      expect(text, contains('2語目'));
    });
  });
}

/// 見出し語の検証（英字のみ）を満たす一意な語を大量に作るための補助。
/// `word0`, `word1`... のように数字を混ぜると headword の検証に落ちるため、
/// アルファベットの連番（`wordaa`, `wordab`, ...）にする。
String _alphaHeadword(int index) {
  var n = index;
  final letters = StringBuffer();
  do {
    letters.write(String.fromCharCode(97 + (n % 26)));
    n = n ~/ 26;
  } while (n > 0);
  return 'word${letters.toString()}';
}
