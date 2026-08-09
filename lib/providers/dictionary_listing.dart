import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/app_database.dart';
import '../data/repositories/word_repository.dart';
import '../domain/entities/mastery.dart';
import '../domain/usecases/family_quiz_builder.dart';
import 'providers.dart';

/// 辞書・単語帳の中身の一覧（[Docs/06_features/dictionary.md] §1）。
///
/// 絞り込みと並べ替えは SQL 側で行うため、条件をそのまま provider の引数にする。
final dictionaryEntriesProvider =
    StreamProvider.family<List<DictionaryEntry>, DictionaryQuery>(
      (ref, query) => ref.watch(wordRepositoryProvider).watchDictionary(query),
    );

/// 件数キャプション（「1,842語 ・ 学習中 312語」）。一覧の行を数えず COUNT で取る。
final dictionaryCountsProvider =
    StreamProvider.family<DictionaryCounts, DictionaryQuery>(
      (ref, query) => ref.watch(wordRepositoryProvider).watchCounts(query),
    );

/// 単語詳細で見る1語（編集・除外の結果が即座に反映されるようストリームで取る）。
final wordByIdProvider = StreamProvider.family<Word?, int>(
  (ref, id) => ref.watch(wordRepositoryProvider).watchById(id),
);

/// 単語詳細が並べる例文（全件、表示順）。0件なら空
/// （[Docs/03_data_model.md] §2.4「表示」）。
final wordExamplesProvider = StreamProvider.family<List<WordExample>, int>(
  (ref, wordId) => ref.watch(wordRepositoryProvider).watchExamples(wordId),
);

/// `word_examples.sourcePresetId` → 単語帳（例文の出どころを名前で出すため）。
final wordbooksByPresetIdProvider = StreamProvider<Map<String, Wordbook>>(
  (ref) => ref.watch(wordbookRepositoryProvider).watchByPresetId(),
);

/// ある語の、ある学習者の学習状態。行が無ければ null（未学習）。
final wordReviewProvider =
    StreamProvider.family<WordReview?, ({int wordId, int profileId})>(
      (ref, key) => ref
          .watch(wordRepositoryProvider)
          .watchReview(key.wordId, key.profileId),
    );

/// ある語が属している単語帳（詳細のチップ）。
final wordbooksOfWordProvider =
    StreamProvider.family<List<Wordbook>, ({int wordId, int profileId})>(
      (ref, key) => ref
          .watch(wordbookRepositoryProvider)
          .watchWordbooksOf(key.wordId, key.profileId),
    );

/// ある語の「語のつくり」（部品を並び順で）。紐付けが無ければ空。
final wordPartsProvider = FutureProvider.family<List<WordPart>, int>(
  (ref, wordId) => ref.watch(modeRepositoryProvider).partsOf(wordId),
);

/// ある語の分解表示（`im-（中へ）+ port（運ぶ）`）。
final wordBreakdownProvider = FutureProvider.family<String?, int>((
  ref,
  wordId,
) async {
  final map = await ref.watch(modeRepositoryProvider).breakdownsOf([wordId]);
  return map[wordId];
});

/// その部品を含む単語と、現在の学習者の習熟度。
final wordsOfPartProvider =
    FutureProvider.family<
      List<({Word word, Mastery mastery})>,
      ({int partId, int profileId})
    >((ref, key) async {
      final repo = ref.watch(modeRepositoryProvider);
      final words = await repo.wordsOfPart(key.partId, key.profileId);
      final mastery = await repo.masteryOf(key.profileId);
      return [
        for (final w in words)
          (word: w, mastery: mastery[w.id] ?? Mastery.unlearned),
      ];
    });

/// ある語と取り違えている相手の語（[Docs/06_features/confusion_drill.md] §4）。
/// 組が1つも無ければ空。
final confusionPartnersProvider =
    FutureProvider.family<
      List<({Word word, int count})>,
      ({int wordId, int profileId})
    >(
      (ref, key) => ref
          .watch(modeRepositoryProvider)
          .confusionPartnersOf(
            key.wordId,
            profileId: key.profileId,
            now: ref.watch(clockProvider)(),
          ),
    );

/// ある語が属する語族の全語。語族に属さない語では空。
final wordFamilyProvider =
    FutureProvider.family<List<FamilyMember>, ({int wordId, int profileId})>((
      ref,
      key,
    ) async {
      final word = await ref.watch(wordRepositoryProvider).findById(key.wordId);
      final familyId = word?.familyId;
      if (familyId == null) return const [];
      return ref
          .watch(modeRepositoryProvider)
          .loadFamilyMembers(key.profileId, familyId: familyId);
    });
