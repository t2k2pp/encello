import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/shared_text_receiver.dart';
import '../../data/database/app_database.dart';
import '../../domain/usecases/shared_text_parser.dart';
import '../../providers/providers.dart';
import '../dialogs/quick_add_word_sheet.dart';

/// 他アプリからの共有テキストを受け取り、クイック登録シートを開く
/// （[Docs/06_features/my_words.md] §4.2）。
///
/// アプリのルート（`app.dart`）に一度だけ差し込む。[profile] には現在の学習者
/// （未選択なら null）を渡す。共有からの起動ではプロファイルゲートを通っていないため、
/// [profile] が null かつ学習者が2人以上のときは、シートの先頭で
/// 「だれのマイ単語にしますか」を選ばせる。
class SharedTextListener extends ConsumerWidget {
  final Profile? profile;
  final Widget child;

  const SharedTextListener({
    super.key,
    required this.profile,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<String>>(sharedTextEventsProvider, (previous, next) {
      next.whenData((text) => _handle(context, ref, text));
    });
    return child;
  }

  Future<void> _handle(BuildContext context, WidgetRef ref, String raw) async {
    final parsed = SharedTextParser.parse(raw);
    // 空文字・記号だけ等、拾える情報が無ければ何も開かない。
    if (parsed.headword.isEmpty &&
        parsed.sentence.isEmpty &&
        parsed.candidateWords.isEmpty) {
      return;
    }

    final active = profile;
    if (active != null) {
      await showQuickAddWordSheet(
        context,
        profile: active,
        initialHeadword: parsed.headword,
        initialSentence: parsed.sentence,
        candidateWords: parsed.candidateWords,
      );
      return;
    }

    final profiles = await ref.read(profileRepositoryProvider).getAll();
    if (profiles.isEmpty || !context.mounted) return;

    if (profiles.length == 1) {
      await showQuickAddWordSheet(
        context,
        profile: profiles.single,
        initialHeadword: parsed.headword,
        initialSentence: parsed.sentence,
        candidateWords: parsed.candidateWords,
      );
      return;
    }

    await showQuickAddWordSheet(
      context,
      profileChoices: profiles,
      initialHeadword: parsed.headword,
      initialSentence: parsed.sentence,
      candidateWords: parsed.candidateWords,
    );
  }
}
