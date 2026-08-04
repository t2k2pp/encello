/// 他アプリからの共有テキストの受信元（[Docs/06_features/my_words.md] §4.2）。
///
/// 実装は `data/services/shared_text_source_impl.dart`（`receive_sharing_intent`）。
/// テストではフェイクを注入し、実機の共有シートに依存させない
/// （[Docs/07_testing_strategy.md] §4）。
abstract class SharedTextSource {
  /// 起動時にすでに保留されていた共有テキスト（無ければ空リスト）。
  Future<List<String>> initialTexts();

  /// 起動後に届く共有テキストのストリーム。
  Stream<String> textStream();

  /// 消費済みとして片付ける（同じ内容を再取得しない）。
  void reset();
}
