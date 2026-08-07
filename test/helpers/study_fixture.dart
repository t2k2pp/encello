import 'package:drift/drift.dart';
import 'package:encello/core/utils/enums.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:encello/data/repositories/wordbook_repository.dart';

/// 学習セッションを開始できる状態（単語帳＋語＋学習対象の選択）を作る。
///
/// [headwords] は `見出し語:訳` の組。省略すると `apple` 1語だけを入れる。
Future<({int wordbookId, Profile profile})> seedStudyTarget(
  AppDatabase db,
  Profile profile, {
  Map<String, String> headwords = const {'apple': 'りんご'},
  String? phonetic,
  String? exampleEn,
  String? exampleJa,
}) async {
  final repo = WordbookRepository(db);
  final wordbookId = await repo.create(
    name: 'テスト単語帳',
    emoji: '📗',
    colorSeed: 1,
  );
  for (final entry in headwords.entries) {
    final id = await db
        .into(db.words)
        .insert(
          WordsCompanion.insert(
            headword: entry.key,
            partOfSpeech: PartOfSpeech.noun.value,
            meaning: entry.value,
            phonetic: Value(phonetic),
          ),
        );
    // 例文は `word_examples` に持つ（[Docs/03_data_model.md] §2.4）。
    if (exampleEn != null) {
      await db
          .into(db.wordExamples)
          .insert(
            WordExamplesCompanion.insert(
              wordId: id,
              exampleEn: exampleEn,
              exampleJa: exampleJa ?? '',
            ),
          );
    }
    await repo.addWord(wordbookId, id);
  }
  await repo.setStudyTarget(profile, wordbookId, selected: true);
  final updated =
      await (db.select(db.profiles)..where((t) => t.id.equals(profile.id)))
          .getSingle();
  return (wordbookId: wordbookId, profile: updated);
}
