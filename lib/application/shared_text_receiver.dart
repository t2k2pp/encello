import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/services/shared_text_source_impl.dart';
import '../domain/services/shared_text_source.dart';

/// 共有テキストの受信元。テストではフェイクへ差し替える
/// （[Docs/06_features/my_words.md] §4.2、[Docs/07_testing_strategy.md] §4）。
final sharedTextSourceProvider = Provider<SharedTextSource>(
  (ref) => const ReceiveSharingIntentTextSource(),
);

/// 起動時にすでに保留されていたテキストと、以後届くテキストを1本のストリームにまとめる。
///
/// `receive_sharing_intent` の起動時共有（[SharedTextSource.initialTexts]）は
/// 最初の購読時に1回だけ読む。
Stream<String> _events(SharedTextSource source) async* {
  for (final text in await source.initialTexts()) {
    yield text;
  }
  yield* source.textStream();
}

/// UI（[SharedTextListener]）が購読する共有テキストのイベント列
/// （[Docs/06_features/my_words.md] §4.2）。
final sharedTextEventsProvider = StreamProvider<String>(
  (ref) => _events(ref.watch(sharedTextSourceProvider)),
);
