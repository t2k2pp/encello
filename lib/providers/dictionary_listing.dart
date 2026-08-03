import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/app_database.dart';
import '../data/repositories/word_repository.dart';
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
