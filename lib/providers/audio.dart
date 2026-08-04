import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/app_data_dir.dart';
import '../core/utils/enums.dart';
import '../data/database/app_database.dart';
import '../data/services/audio_library.dart';
import '../data/services/audio_pronunciation_service.dart';
import '../data/repositories/wordbook_repository.dart' show decodeIdList;
import '../data/services/flutter_tts_service.dart';
import '../domain/services/pronunciation_service.dart';
import '../domain/services/tts_service.dart';
import 'providers.dart';

/// 端末の読み上げ。テストではフェイクへ差し替える。
final ttsServiceProvider = Provider<TtsService>((ref) => FlutterTtsService());

/// この端末で使える voice（[Docs/06_features/tts.md] §2）。
///
/// **起動をブロックしない。** 取得できるまでの間、読み上げボタンとリスニングモードは
/// 表示しない（押しても鳴らないボタンを先に出さない）。
final ttsCapabilityProvider = FutureProvider<TtsCapability>(
  (ref) => ref.watch(ttsServiceProvider).capability(),
);

/// 端末に入っている音声パック（全学習者で共有する）。
final audioPacksProvider = StreamProvider<List<AudioPack>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.audioPacks)
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
      .watch();
});

/// 展開済み音声パックの置き場。テストでは一時ディレクトリへ差し替える。
final documentsPathProvider = FutureProvider<String>(
  (ref) async => (await appDataDirectory()).path,
);

/// 学習者が使う音声パックの索引。ON/OFF や優先順位を変えたら作り直す。
final audioLibraryProvider = FutureProvider.family<AudioLibrary, Profile>((
  ref,
  profile,
) async {
  // 使うパックが1つも無ければ、置き場を調べる必要すら無い。
  if (decodeIdList(profile.audioPackIds).isEmpty) return AudioLibrary.empty;
  return AudioLibrary.load(
    ref.watch(databaseProvider),
    profile,
    documentsPath: await ref.watch(documentsPathProvider.future),
  );
});

/// 読み上げの入口。UI と学習セッションはここだけを見る。
///
/// voice の列挙と音声パックの読み込みが終わるまで `null`（= まだボタンを出さない）。
final pronunciationProvider = FutureProvider.family<PronunciationService, Profile>((
  ref,
  profile,
) async {
  final capability = await ref.watch(ttsCapabilityProvider.future);
  final library = await ref.watch(audioLibraryProvider(profile).future);
  final tts = ref.watch(ttsServiceProvider);

  // 学習者ごとの読み上げ設定を反映する。voice が端末から消えていた場合は
  // 勝手に別の voice へ切り替えず、設定画面が警告を出す（[tts.md] §3）。
  await tts.setRate(profile.ttsRate);
  await tts.setPitch(profile.ttsPitch);
  for (final (lang, name) in [
    (SpeechLang.en, profile.ttsEnVoice),
    (SpeechLang.ja, profile.ttsJaVoice),
  ]) {
    if (name.isEmpty) continue;
    try {
      await tts.setVoice(lang, name);
    } on TtsUnavailableException {
      // 設定画面の警告に任せ、ここでは既定の voice のまま進める。
    }
  }

  return AudioPronunciationService(
    library: library,
    tts: tts,
    capability: capability,
    preference: AudioSourcePreference.fromValue(profile.audioSource),
  );
});

/// 学習者の設定に「端末に無い voice」が残っていないか。
/// 残っていれば設定画面が「選択中の音声が見つかりません」を出す。
final missingVoicesProvider = Provider.family<List<SpeechLang>, Profile>((
  ref,
  profile,
) {
  final capability = ref.watch(ttsCapabilityProvider).value;
  if (capability == null) return const [];
  return [
    for (final (lang, name) in [
      (SpeechLang.en, profile.ttsEnVoice),
      (SpeechLang.ja, profile.ttsJaVoice),
    ])
      if (name.isNotEmpty &&
          !capability.voicesFor(lang).any((v) => v.name == name))
        lang,
  ];
});

/// いま選べる学習モード（[STYLE_GUIDE §0-4]）。
///
/// 条件を満たさないモードは**選択肢ごと出さない**。無効化してグレーにしない。
/// リスニングは、学習対象の語のどれかを英語で鳴らせるときだけ選べる
/// （[Docs/06_features/listening_mode.md] §4）。
final availableModesProvider = FutureProvider.family<List<StudyMode>, Profile>((
  ref,
  profile,
) async {
  final candidates = await ref
      .watch(studyRepositoryProvider)
      .loadCandidates(profile);
  if (candidates.isEmpty) return const [];

  final modes = <StudyMode>[StudyMode.spell];
  final service = await ref.watch(pronunciationProvider(profile).future);
  final canSpeakEn = candidates.any(
    (c) => service.resolve(c.wordId, SpeechLang.en) != null,
  );
  if (canSpeakEn) modes.add(StudyMode.listening);
  // フラッシュカードは無音の送り方があるので、音が無くても選べる。
  modes.add(StudyMode.flashcard);
  return modes;
});
