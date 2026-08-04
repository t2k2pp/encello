import 'package:encello/domain/entities/spell_verdict.dart';
import 'package:encello/domain/usecases/spell_judge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('正規化', () {
    test('大小差・前後の空白は正解になる', () {
      expect(SpellJudge.judge('  Apple ', 'apple'), const SpellCorrect());
    });

    test('連続する空白は1つにまとめる', () {
      expect(SpellJudge.judge('a  lot   of', 'a lot of'), const SpellCorrect());
    });

    test('Unicode のアポストロフィは ASCII と同じに扱う', () {
      expect(SpellJudge.judge('don’t', "don't"), const SpellCorrect());
      expect(SpellJudge.judge("don't", 'don’t'), const SpellCorrect());
    });

    test('アクセント記号は別の綴りとして扱う', () {
      expect(SpellJudge.judge('cafe', 'café'), isNot(const SpellCorrect()));
    });
  });

  group('惜しい（NearMiss）', () {
    test('置換1文字で成立する', () {
      final verdict = SpellJudge.judge('applr', 'apple');
      expect(verdict, isA<SpellNearMiss>());
      expect((verdict as SpellNearMiss).diffIndexes, [4]);
    });

    test('1文字足りない（削除）で成立し、抜けた位置を指す', () {
      final verdict = SpellJudge.judge('aple', 'apple');
      expect(verdict, isA<SpellNearMiss>());
      expect((verdict as SpellNearMiss).diffIndexes, [2]);
    });

    test('1文字多い（挿入）で成立し、食い違いが始まる位置を指す', () {
      final verdict = SpellJudge.judge('appple', 'apple');
      expect(verdict, isA<SpellNearMiss>());
      // 余分な p に押し出された 'l'（正解の3文字目）から食い違う。
      expect((verdict as SpellNearMiss).diffIndexes, [3]);
    });

    test('入力の末尾に余分な文字があるときは指す位置が無い', () {
      final verdict = SpellJudge.judge('apples', 'apple');
      expect(verdict, isA<SpellNearMiss>());
      expect((verdict as SpellNearMiss).diffIndexes, isEmpty);
    });

    test('末尾に余分な1文字があっても成立する', () {
      expect(SpellJudge.judge('apples', 'apple'), isA<SpellNearMiss>());
    });

    test('正解が4文字未満なら惜しいにしない', () {
      // cat と car は別の語であり、惜しくない。
      expect(SpellJudge.judge('car', 'cat'), const SpellWrong());
    });

    test('正解がちょうど4文字なら成立する', () {
      expect(SpellJudge.judge('bock', 'book'), isA<SpellNearMiss>());
    });

    test('2文字違えば不正解', () {
      expect(SpellJudge.judge('applr', 'apply'), isA<SpellNearMiss>());
      expect(SpellJudge.judge('aprlr', 'apple'), const SpellWrong());
    });

    test('長さが2以上違えば不正解', () {
      expect(SpellJudge.judge('ap', 'apple'), const SpellWrong());
    });

    test('惜しいは正解として数えない', () {
      expect(SpellJudge.judge('aple', 'apple').isCorrect, isFalse);
    });
  });

  group('不正解', () {
    test('空入力は不正解', () {
      expect(SpellJudge.judge('', 'apple'), const SpellWrong());
    });

    test('まったく違う語は不正解', () {
      expect(SpellJudge.judge('banana', 'apple'), const SpellWrong());
    });
  });
}
