import 'dart:io';

import 'package:encello/domain/usecases/wordbook_json_codec.dart';
import 'package:flutter_test/flutter_test.dart';

/// 実際の AI 出力を模したフィクスチャでの回帰テスト
/// （[Docs/06_features/ai_import.md] §7）。
void main() {
  String fixture(String name) =>
      File('test/fixtures/ai_import/$name').readAsStringSync();

  test('コードフェンス付きの出力がそのまま取り込める', () {
    final result = WordbookJsonCodec.decode(fixture('code_fenced.txt'));
    expect(result.isClean, isTrue, reason: '${result.issues}');
    expect(result.book!.name, 'キャンプ用語');
    expect(result.book!.words, hasLength(3));
  });

  test('前置き・後置きの説明文が付いた出力がそのまま取り込める', () {
    final result = WordbookJsonCodec.decode(fixture('with_preamble.txt'));
    expect(result.isClean, isTrue, reason: '${result.issues}');
    expect(result.book!.name, '空港と飛行機の英単語');
    expect(result.book!.words, hasLength(3));
  });

  test('エラーが混じった出力は正しい語だけを残し、理由を全件出す', () {
    final result = WordbookJsonCodec.decode(fixture('with_errors.txt'));
    expect(result.isPartial, isTrue);
    expect(result.book!.words, hasLength(1));
    expect(result.book!.words.single.headword, 'patient');

    expect(result.issues, hasLength(4));
    expect(
      result.issues.any((i) => i.message.contains('英単語として扱えない文字')),
      isTrue,
    );
    expect(
      result.issues.any((i) => i.message.contains('品詞が不正です: verbs')),
      isTrue,
    );
    expect(
      result.issues.where((i) => i.message.contains('日本語訳')),
      hasLength(2),
      reason: '訳が空の bandage と、exampleJa が無い recover の両方',
    );
  });
}
