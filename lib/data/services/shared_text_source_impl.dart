import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../domain/services/shared_text_source.dart';

/// `receive_sharing_intent` を使った共有テキストの受信
/// （[Docs/06_features/my_words.md] §4.2、[Docs/08_platform_setup.md] §2.3・§3.2）。
///
/// **テキスト（`text/plain` / `public.plain-text`）だけ**を扱う。画像・動画・URL は
/// このアプリの対象外のため無視する。
class ReceiveSharingIntentTextSource implements SharedTextSource {
  const ReceiveSharingIntentTextSource();

  @override
  Future<List<String>> initialTexts() async {
    final media = await ReceiveSharingIntent.instance.getInitialMedia();
    return [
      for (final m in media)
        if (m.type == SharedMediaType.text) m.path,
    ];
  }

  @override
  Stream<String> textStream() {
    return ReceiveSharingIntent.instance.getMediaStream().expand(
      (files) => [
        for (final f in files)
          if (f.type == SharedMediaType.text) f.path,
      ],
    );
  }

  @override
  void reset() {
    ReceiveSharingIntent.instance.reset();
  }
}
