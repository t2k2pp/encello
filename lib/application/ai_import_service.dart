import 'package:drift/drift.dart';
import 'package:meta/meta.dart';

import '../core/utils/enums.dart';
import '../data/database/app_database.dart';
import '../data/repositories/word_repository.dart';
import '../domain/usecases/wordbook_json_codec.dart';

/// プレビューに出す語1件（[Docs/06_features/ai_import.md] §3.2）。
@immutable
class AiImportPreviewWord {
  final String headword;
  final PartOfSpeech partOfSpeech;

  /// 既存の共有語と一致した場合はその語の訳（上書きしないため。§2.3）。
  final String meaning;

  /// 既存の共有語と一致した（「すでにある語」バッジの対象）。
  final bool isExisting;

  const AiImportPreviewWord({
    required this.headword,
    required this.partOfSpeech,
    required this.meaning,
    required this.isExisting,
  });
}

/// 取り込み前のプレビュー（[Docs/06_features/ai_import.md] §3.2）。
@immutable
class AiImportPreview {
  final String name;
  final String emoji;
  final String? note;

  /// 取り込む語の総数。
  final int totalCount;

  /// 新しく作られる語数（既存の共有語と一致した語を除く）。
  final int newCount;

  /// 先頭20語。
  final List<AiImportPreviewWord> words;

  const AiImportPreview({
    required this.name,
    required this.emoji,
    required this.note,
    required this.totalCount,
    required this.newCount,
    required this.words,
  });

  /// 既存の共有語と一致して新規作成しない語数。
  int get existingCount => totalCount - newCount;
}

/// 取り込み結果（完了後の SnackBar 用）。
@immutable
class AiImportResult {
  final int wordbookId;
  final int totalCount;
  final int newWordCount;

  const AiImportResult({
    required this.wordbookId,
    required this.totalCount,
    required this.newWordCount,
  });
}

/// AI に作ってもらった単語帳の取り込み（[Docs/06_features/ai_import.md]）。
///
/// 既存の共有語（`ownerProfileId = null`）と `(headword, partOfSpeech)` が一致したら
/// **行を増やさず所属だけを足す**。既存語の訳は上書きしない（§2.3）。
/// 新規作成する語は共有の語にし、`presetId` は付けない（AI 取り込み語は
/// 「元に戻す」の対象にしない）。
class AiImportService {
  final AppDatabase _db;

  AiImportService(this._db);

  /// 取り込み前のプレビュー。DB は読むだけで書かない。
  Future<AiImportPreview> preview(ParsedWordbook book) async {
    var newCount = 0;
    final previewWords = <AiImportPreviewWord>[];
    for (final w in book.words) {
      final existing = await _findSharedWord(w.headword, w.partOfSpeech);
      final isExisting = existing != null;
      if (!isExisting) newCount++;
      if (previewWords.length < 20) {
        previewWords.add(
          AiImportPreviewWord(
            headword: w.headword,
            partOfSpeech: w.partOfSpeech,
            meaning: existing?.meaning ?? w.meaning,
            isExisting: isExisting,
          ),
        );
      }
    }
    return AiImportPreview(
      name: book.name,
      emoji: book.emoji,
      note: book.note,
      totalCount: book.words.length,
      newCount: newCount,
      words: previewWords,
    );
  }

  /// 取り込みを実行する。単語帳→単語→所属を1トランザクションで書き、途中で失敗したら
  /// 1件も残さない（[Docs/06_features/ai_import.md] §3.4）。
  ///
  /// [targetWordbookId] を渡すと「既存の単語帳に足す」（同じ単語帳へ複数回に分けて
  /// 取り込める。§4.1）。未指定なら新しい単語帳を作る。
  Future<AiImportResult> import(
    ParsedWordbook book, {
    int? targetWordbookId,
  }) {
    return _db.transaction(() async {
      final wordbookId = targetWordbookId ?? await _createWordbook(book);

      final maxOrder = _db.wordbookEntries.sortOrder.max();
      final orderRow =
          await (_db.selectOnly(_db.wordbookEntries)
                ..addColumns([maxOrder])
                ..where(_db.wordbookEntries.wordbookId.equals(wordbookId)))
              .getSingle();
      var nextOrder = (orderRow.read(maxOrder) ?? -1) + 1;

      var newWordCount = 0;
      for (final w in book.words) {
        final existing = await _findSharedWord(w.headword, w.partOfSpeech);
        int wordId;
        if (existing != null) {
          wordId = existing.id;
        } else {
          wordId = await _db
              .into(_db.words)
              .insert(
                WordsCompanion.insert(
                  headword: w.headword,
                  partOfSpeech: w.partOfSpeech.value,
                  meaning: w.meaning,
                  phonetic: Value(w.phonetic),
                  level: Value(w.level),
                ),
              );
          // 取り込み先はユーザー単語帳なので、例文は `sourcePresetId = null` で入れる
          // （[Docs/03_data_model.md] §2.4）。既存語の例文は上書きしない。
          await WordRepository(_db).setUserExample(
            wordId,
            exampleEn: w.exampleEn,
            exampleJa: w.exampleJa,
          );
          newWordCount++;
        }
        await _db
            .into(_db.wordbookEntries)
            .insertOnConflictUpdate(
              WordbookEntriesCompanion.insert(
                wordbookId: wordbookId,
                wordId: wordId,
                sortOrder: Value(nextOrder),
              ),
            );
        nextOrder++;
      }

      return AiImportResult(
        wordbookId: wordbookId,
        totalCount: book.words.length,
        newWordCount: newWordCount,
      );
    });
  }

  Future<int> _createWordbook(ParsedWordbook book) async {
    final maxOrder = _db.wordbooks.sortOrder.max();
    final row = await (_db.selectOnly(
      _db.wordbooks,
    )..addColumns([maxOrder])).getSingle();
    return _db
        .into(_db.wordbooks)
        .insert(
          WordbooksCompanion.insert(
            name: book.name,
            emoji: book.emoji,
            colorSeed: book.name.hashCode,
            category: WordbookCategory.custom.value,
            source: WordbookSource.imported.value,
            note: Value(book.note),
            sortOrder: Value((row.read(maxOrder) ?? 0) + 1),
          ),
        );
  }

  /// 共有の語（`ownerProfileId = null`）を `(headword, partOfSpeech)` で探す。
  /// マイ単語（`ownerProfileId` あり）は対象にしない
  /// （[Docs/06_features/ai_import.md] §2.3 は「共有語」に限定している）。
  Future<Word?> _findSharedWord(String headword, PartOfSpeech pos) =>
      (_db.select(_db.words)..where(
            (t) =>
                t.headword.equals(headword) &
                t.partOfSpeech.equals(pos.value) &
                t.ownerProfileId.isNull(),
          ))
          .getSingleOrNull();
}
