import 'dart:async';

import 'package:encello/domain/services/shared_text_source.dart';

/// 実機の共有シートに依存しないフェイク（[Docs/07_testing_strategy.md] §4）。
///
/// [emit] でストリームへテキストを流し、`SharedTextListener` の反応を検証できる。
class FakeSharedTextSource implements SharedTextSource {
  FakeSharedTextSource({this.initial = const []});

  final List<String> initial;
  final _controller = StreamController<String>.broadcast();

  void emit(String text) => _controller.add(text);

  @override
  Future<List<String>> initialTexts() async => initial;

  @override
  Stream<String> textStream() => _controller.stream;

  @override
  void reset() {}
}
