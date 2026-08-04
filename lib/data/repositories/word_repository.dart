import 'package:drift/drift.dart';
import 'package:meta/meta.dart';

import '../../core/utils/enums.dart';
import '../../domain/entities/mastery.dart';
import '../database/app_database.dart';
import 'wordbook_repository.dart';

/// 辞書の並べ替え項目（[Docs/06_features/dictionary.md] §1.3）。
enum DictionarySort {
  headword('headword', '見出し語'),
  mastery('mastery', '習熟度'),
  lastReviewed('lastReviewed', '最終学習日');

  final String value;
  final String label;
  const DictionarySort(this.value, this.label);
}

/// 辞書の習熟度フィルタ（[Docs/06_features/dictionary.md] §1.2）。
enum MasteryFilter {
  all('all', 'すべて'),
  unlearned('unlearned', '未学習'),
  learning('learning', '学習中'),
  settled('settled', '定着'),
  mastered('mastered', 'マスター'),
  weak('weak', '苦手'),
  draft('draft', '下書きのみ');

  final String value;
  final String label;
  const MasteryFilter(this.value, this.label);
}

/// 辞書の単語帳フィルタ。[wordbookId] が非 null なら その1冊に絞る。
@immutable
class WordbookFilter {
  final String kind;
  final int? wordbookId;

  const WordbookFilter._(this.kind, [this.wordbookId]);

  static const all = WordbookFilter._('all');

  /// 現在の学習者が学習対象にしている単語帳。
  static const studyTarget = WordbookFilter._('studyTarget');

  /// 自分のマイ単語（`words.ownerProfileId` が自分）。
  static const myWords = WordbookFilter._('myWords');

  const WordbookFilter.book(int id) : this._('book', id);

  @override
  bool operator ==(Object other) =>
      other is WordbookFilter &&
      other.kind == kind &&
      other.wordbookId == wordbookId;

  @override
  int get hashCode => Object.hash(kind, wordbookId);
}

/// 辞書一覧の問い合わせ条件。
@immutable
class DictionaryQuery {
  final int profileId;

  /// 学習対象の単語帳 id（`WordbookFilter.studyTarget` のときに使う）。
  final List<int> selectedWordbookIds;
  final String search;
  final bool searchExamples;
  final WordbookFilter wordbook;
  final MasteryFilter mastery;
  final DictionarySort sort;
  final bool ascending;

  const DictionaryQuery({
    required this.profileId,
    this.selectedWordbookIds = const [],
    this.search = '',
    this.searchExamples = false,
    this.wordbook = WordbookFilter.all,
    this.mastery = MasteryFilter.all,
    this.sort = DictionarySort.headword,
    this.ascending = true,
  });

  /// 検索・フィルタが初期状態か（ヘッダーの条件リセットの表示判定。[STYLE_GUIDE §3.5]）。
  bool get isPristine =>
      search.isEmpty &&
      wordbook == WordbookFilter.all &&
      mastery == MasteryFilter.all &&
      sort == DictionarySort.headword &&
      ascending;

  @override
  bool operator ==(Object other) =>
      other is DictionaryQuery &&
      other.profileId == profileId &&
      other.search == search &&
      other.searchExamples == searchExamples &&
      other.wordbook == wordbook &&
      other.mastery == mastery &&
      other.sort == sort &&
      other.ascending == ascending &&
      _sameIds(other.selectedWordbookIds, selectedWordbookIds);

  @override
  int get hashCode => Object.hash(
    profileId,
    search,
    searchExamples,
    wordbook,
    mastery,
    sort,
    ascending,
    Object.hashAll(selectedWordbookIds),
  );

  static bool _sameIds(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  DictionaryQuery copyWith({
    List<int>? selectedWordbookIds,
    String? search,
    bool? searchExamples,
    WordbookFilter? wordbook,
    MasteryFilter? mastery,
    DictionarySort? sort,
    bool? ascending,
  }) {
    return DictionaryQuery(
      profileId: profileId,
      selectedWordbookIds: selectedWordbookIds ?? this.selectedWordbookIds,
      search: search ?? this.search,
      searchExamples: searchExamples ?? this.searchExamples,
      wordbook: wordbook ?? this.wordbook,
      mastery: mastery ?? this.mastery,
      sort: sort ?? this.sort,
      ascending: ascending ?? this.ascending,
    );
  }
}

/// 辞書一覧の1行。単語＋現在の学習者の学習状態＋表示用の単語帳色。
@immutable
class DictionaryEntry {
  final Word word;

  /// 学習状態が無ければ [Mastery.unlearned]。
  final Mastery mastery;
  final DateTime? lastReviewedAt;
  final int totalCorrect;
  final int totalIncorrect;

  /// サムネの背景に使う単語帳の識別色シード。どの単語帳にも属さない語は null。
  final int? wordbookColorSeed;

  const DictionaryEntry({
    required this.word,
    required this.mastery,
    required this.lastReviewedAt,
    required this.totalCorrect,
    required this.totalIncorrect,
    required this.wordbookColorSeed,
  });

  PartOfSpeech get partOfSpeech => PartOfSpeech.fromValue(word.partOfSpeech);

  int get totalAnswered => totalCorrect + totalIncorrect;
}

/// 辞書の件数キャプション用（[Docs/06_features/dictionary.md] §1.5）。
@immutable
class DictionaryCounts {
  final int total;
  final int learning;

  const DictionaryCounts({required this.total, required this.learning});
}

/// 単語の読み書きと辞書の問い合わせ（[Docs/03_data_model.md] §2.3）。
///
/// 絞り込みと並べ替えは **SQL 側で行う**。全件を Dart へ読んでからフィルタしない
/// （NFR-02）。
class WordRepository {
  final AppDatabase _db;

  WordRepository(this._db);

  // --- 辞書 ---

  Stream<List<DictionaryEntry>> watchDictionary(DictionaryQuery q) {
    final sql = _buildSelect(q);
    return _db
        .customSelect(sql.text, variables: sql.variables, readsFrom: _readsFrom)
        .watch()
        .map((rows) => rows.map(_toEntry).toList());
  }

  Stream<DictionaryCounts> watchCounts(DictionaryQuery q) {
    final where = _buildWhere(q);
    final sql =
        '''
SELECT COUNT(*) AS total,
       COALESCE(SUM(CASE WHEN r.mastery_level >= 1 THEN 1 ELSE 0 END), 0) AS learning
FROM words w
LEFT JOIN word_reviews r ON r.word_id = w.id AND r.profile_id = ?
WHERE ${where.text}
''';
    return _db
        .customSelect(
          sql,
          variables: [Variable<int>(q.profileId), ...where.variables],
          readsFrom: _readsFrom,
        )
        .watch()
        .map((rows) {
          final row = rows.single;
          return DictionaryCounts(
            total: row.read<int>('total'),
            learning: row.read<int>('learning'),
          );
        });
  }

  Set<ResultSetImplementation<dynamic, dynamic>> get _readsFrom => {
    _db.words,
    _db.wordReviews,
    _db.wordbookEntries,
    _db.wordbooks,
  };

  DictionaryEntry _toEntry(QueryRow row) {
    final level = row.read<int?>('mastery_level');
    return DictionaryEntry(
      word: _db.words.map(row.data),
      mastery: level == null ? Mastery.unlearned : Mastery.fromLevel(level),
      lastReviewedAt: row.read<DateTime?>('last_reviewed_at'),
      totalCorrect: row.read<int?>('total_correct') ?? 0,
      totalIncorrect: row.read<int?>('total_incorrect') ?? 0,
      wordbookColorSeed: row.read<int?>('wordbook_color_seed'),
    );
  }

  _Sql _buildSelect(DictionaryQuery q) {
    final where = _buildWhere(q);
    final order = _buildOrder(q);
    final sql =
        '''
SELECT w.*,
       r.mastery_level AS mastery_level,
       r.last_reviewed_at AS last_reviewed_at,
       r.total_correct AS total_correct,
       r.total_incorrect AS total_incorrect,
       (SELECT wb.color_seed
          FROM wordbook_entries we
          JOIN wordbooks wb ON wb.id = we.wordbook_id
         WHERE we.word_id = w.id
         ORDER BY wb.sort_order, wb.id
         LIMIT 1) AS wordbook_color_seed
FROM words w
LEFT JOIN word_reviews r ON r.word_id = w.id AND r.profile_id = ?
WHERE ${where.text}
ORDER BY ${order.text}
''';
    return _Sql(sql, [
      Variable<int>(q.profileId),
      ...where.variables,
      ...order.variables,
    ]);
  }

  _Sql _buildWhere(DictionaryQuery q) {
    final clauses = <String>[];
    final vars = <Variable<Object>>[];

    // 可視範囲: 共有の語＋自分のマイ単語（[Docs/03_data_model.md] §5）。
    clauses.add('(w.owner_profile_id IS NULL OR w.owner_profile_id = ?)');
    vars.add(Variable<int>(q.profileId));

    final search = q.search.trim().toLowerCase();
    if (search.isNotEmpty) {
      final contains = '%${_escapeLike(search)}%';
      final targets = <String>[
        "w.headword LIKE ? ESCAPE '\\'",
        "w.meaning LIKE ? ESCAPE '\\'",
      ];
      vars
        ..add(Variable<String>(contains))
        ..add(Variable<String>(contains));
      if (q.searchExamples) {
        targets
          ..add("w.example_en LIKE ? ESCAPE '\\'")
          ..add("w.example_ja LIKE ? ESCAPE '\\'");
        vars
          ..add(Variable<String>(contains))
          ..add(Variable<String>(contains));
      }
      clauses.add('(${targets.join(' OR ')})');
    }

    switch (q.wordbook.kind) {
      case 'studyTarget':
        if (q.selectedWordbookIds.isEmpty) {
          // 学習対象が1冊も無い＝該当なし。全件に化けさせない。
          clauses.add('1 = 0');
        } else {
          clauses.add(
            'EXISTS (SELECT 1 FROM wordbook_entries we WHERE we.word_id = w.id '
            'AND we.wordbook_id IN (${_placeholders(q.selectedWordbookIds.length)}))',
          );
          vars.addAll(q.selectedWordbookIds.map(Variable<int>.new));
        }
      case 'myWords':
        clauses.add('w.owner_profile_id = ?');
        vars.add(Variable<int>(q.profileId));
      case 'book':
        clauses.add(
          'EXISTS (SELECT 1 FROM wordbook_entries we '
          'WHERE we.word_id = w.id AND we.wordbook_id = ?)',
        );
        vars.add(Variable<int>(q.wordbook.wordbookId!));
      case 'all':
        break;
      default:
        throw StateError('未知の単語帳フィルタ: ${q.wordbook.kind}');
    }

    switch (q.mastery) {
      case MasteryFilter.all:
        break;
      case MasteryFilter.unlearned:
        clauses.add('r.word_id IS NULL');
      case MasteryFilter.learning:
        clauses.add('r.mastery_level = ${Mastery.learning.level}');
      case MasteryFilter.settled:
        clauses.add('r.mastery_level = ${Mastery.settled.level}');
      case MasteryFilter.mastered:
        clauses.add('r.mastery_level = ${Mastery.mastered.level}');
      case MasteryFilter.weak:
        // 苦手 = 解答10回以上かつ正解率60%未満（[srs_scheduler.md] §6.2 と同じ定義）。
        clauses.add(
          '(r.total_correct + r.total_incorrect) >= 10 '
          'AND r.total_correct * 1.0 / (r.total_correct + r.total_incorrect) < 0.6',
        );
      case MasteryFilter.draft:
        clauses.add('w.is_draft = 1');
    }

    return _Sql(clauses.join(' AND '), vars);
  }

  _Sql _buildOrder(DictionaryQuery q) {
    final dir = q.ascending ? 'ASC' : 'DESC';
    final vars = <Variable<Object>>[];
    final terms = <String>[];

    final search = q.search.trim().toLowerCase();
    if (search.isNotEmpty) {
      // 前方一致の結果を中間一致より上に並べる（[Docs/06_features/dictionary.md] §1.1）。
      terms.add("CASE WHEN w.headword LIKE ? ESCAPE '\\' THEN 0 ELSE 1 END");
      vars.add(Variable<String>('${_escapeLike(search)}%'));
    }

    switch (q.sort) {
      case DictionarySort.headword:
        terms.add('w.headword $dir');
      case DictionarySort.mastery:
        terms
          ..add('COALESCE(r.mastery_level, 0) $dir')
          ..add('w.headword ASC');
      case DictionarySort.lastReviewed:
        // 未学習は末尾に置く（[Docs/06_features/dictionary.md] §1.3）。
        terms
          ..add('CASE WHEN r.last_reviewed_at IS NULL THEN 1 ELSE 0 END ASC')
          ..add('r.last_reviewed_at $dir')
          ..add('w.headword ASC');
    }
    // 同点の並びを毎回同じにする。
    terms.add('w.id ASC');
    return _Sql(terms.join(', '), vars);
  }

  static String _placeholders(int count) =>
      List.filled(count, '?').join(', ');

  /// LIKE のワイルドカード（`%` `_`）と、エスケープ文字そのものを無効化する。
  static String _escapeLike(String input) => input
      .replaceAll('\\', '\\\\')
      .replaceAll('%', '\\%')
      .replaceAll('_', '\\_');

  // --- 単語の読み書き ---

  Future<Word?> findById(int id) =>
      (_db.select(_db.words)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<Word?> watchById(int id) =>
      (_db.select(_db.words)..where((t) => t.id.equals(id))).watchSingleOrNull();

  /// 現在の学習者から見える範囲で `(headword, partOfSpeech)` の語を探す。
  /// 共有の語を優先し、無ければ自分のマイ単語を返す。
  Future<Word?> findByHeadword(
    String headword,
    PartOfSpeech partOfSpeech, {
    required int profileId,
  }) async {
    final normalized = headword.trim().toLowerCase();
    final shared =
        await (_db.select(_db.words)..where(
              (t) =>
                  t.headword.equals(normalized) &
                  t.partOfSpeech.equals(partOfSpeech.value) &
                  t.ownerProfileId.isNull(),
            ))
            .getSingleOrNull();
    if (shared != null) return shared;
    return (_db.select(_db.words)..where(
          (t) =>
              t.headword.equals(normalized) &
              t.partOfSpeech.equals(partOfSpeech.value) &
              t.ownerProfileId.equals(profileId),
        ))
        .getSingleOrNull();
  }

  /// 共有の語を作る。`(headword, partOfSpeech)` が既存と衝突する場合は例外にする
  /// （呼び出し側が先に [findByHeadword] で確認し、既存語を単語帳へ所属させる）。
  Future<int> createShared({
    required String headword,
    required PartOfSpeech partOfSpeech,
    required String meaning,
    String? phonetic,
    String? exampleEn,
    String? exampleJa,
    int level = 1,
  }) {
    return _db
        .into(_db.words)
        .insert(
          WordsCompanion.insert(
            headword: headword.trim().toLowerCase(),
            partOfSpeech: partOfSpeech.value,
            meaning: meaning,
            phonetic: Value(_nullIfBlank(phonetic)),
            exampleEn: Value(_nullIfBlank(exampleEn)),
            exampleJa: Value(_nullIfBlank(exampleJa)),
            level: Value(level),
          ),
        );
  }

  /// 語を編集する。プリセット由来の語なら `isEdited = true` を立てる（FR-05）。
  ///
  /// `(headword, partOfSpeech)` を他の語と衝突する値へ変えようとした場合は保存せず
  /// [StateError] を投げる（[Docs/06_features/dictionary.md] §2.2）。
  Future<void> updateWord(
    Word word, {
    required String headword,
    required PartOfSpeech partOfSpeech,
    required String meaning,
    String? phonetic,
    String? exampleEn,
    String? exampleJa,
    required int level,
  }) async {
    final normalized = headword.trim().toLowerCase();
    final conflict =
        await (_db.select(_db.words)..where(
              (t) =>
                  t.headword.equals(normalized) &
                  t.partOfSpeech.equals(partOfSpeech.value) &
                  t.id.equals(word.id).not() &
                  (word.ownerProfileId == null
                      ? t.ownerProfileId.isNull()
                      : t.ownerProfileId.equals(word.ownerProfileId!)),
            ))
            .getSingleOrNull();
    if (conflict != null) {
      throw StateError('同じ見出し語と品詞の単語がすでにあります。');
    }

    await (_db.update(_db.words)..where((t) => t.id.equals(word.id))).write(
      WordsCompanion(
        headword: Value(normalized),
        partOfSpeech: Value(partOfSpeech.value),
        meaning: Value(meaning),
        phonetic: Value(_nullIfBlank(phonetic)),
        exampleEn: Value(_nullIfBlank(exampleEn)),
        exampleJa: Value(_nullIfBlank(exampleJa)),
        level: Value(level),
        // 訳が入ったら下書きではなくなる（[Docs/06_features/my_words.md] §3）。
        // 下書きは**マイ単語だけ**の状態。共有の語は訳が空でも下書きにしない
        // （[Docs/03_data_model.md] §2.3）。
        isDraft: Value(
          word.ownerProfileId != null && meaning.trim().isEmpty,
        ),
        isEdited: Value(word.presetId != null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// マイ単語を作る（[Docs/06_features/my_words.md] §2〜§3）。
  ///
  /// `meaning` が空なら `isDraft = true` で保存する（見出し語だけで登録できる）。
  /// 保存先は [ownerProfileId] のマイ単語帳（`wordbooks.category = myWords`）へ
  /// 自動で所属させる。`(headword, partOfSpeech, ownerProfileId)` が既存と衝突する
  /// 場合は例外になる（[createShared] と同じ作法。呼び出し側が事前に
  /// [findByHeadword] で確認する）。
  Future<int> createOwned({
    required int ownerProfileId,
    required String headword,
    required PartOfSpeech partOfSpeech,
    String meaning = '',
    String? phonetic,
    String? exampleEn,
    String? exampleJa,
    int level = 1,
  }) async {
    final wordbooks = WordbookRepository(_db);
    return _db.transaction(() async {
      final myWordsBook = await wordbooks.myWordsBookOf(ownerProfileId);
      final wordId = await _db
          .into(_db.words)
          .insert(
            WordsCompanion.insert(
              headword: headword.trim().toLowerCase(),
              partOfSpeech: partOfSpeech.value,
              meaning: meaning,
              phonetic: Value(_nullIfBlank(phonetic)),
              exampleEn: Value(_nullIfBlank(exampleEn)),
              exampleJa: Value(_nullIfBlank(exampleJa)),
              level: Value(level),
              ownerProfileId: Value(ownerProfileId),
              isDraft: Value(meaning.trim().isEmpty),
            ),
          );
      await wordbooks.addWord(myWordsBook.id, wordId);
      return wordId;
    });
  }

  /// 自分の下書きの語（「訳を書く」モードが1語ずつ埋めていく対象）。
  ///
  /// 登録が新しい順に並べる。出会った直後の語ほど記憶が残っていて訳を書きやすい
  /// （[Docs/06_features/my_words.md] §5）。
  Future<List<Word>> draftWords(int profileId) =>
      (_db.select(_db.words)
            ..where(
              (t) =>
                  t.ownerProfileId.equals(profileId) & t.isDraft.equals(true),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  /// 自分の下書き（[Docs/06_features/my_words.md] §3）の語数。
  /// ホームの下書きカードとマイ単語画面の「訳を書く」ボタンが見る。
  Stream<int> watchDraftCount(int profileId) {
    final count = _db.words.id.count();
    final query = _db.selectOnly(_db.words)
      ..addColumns([count])
      ..where(
        _db.words.ownerProfileId.equals(profileId) &
            _db.words.isDraft.equals(true),
      );
    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }

  /// プリセット語を編集前の値へ戻す（FR-06）。`isEdited = false` にする。
  Future<void> restorePreset(
    int wordId, {
    required String meaning,
    String? phonetic,
    String? exampleEn,
    String? exampleJa,
    required int level,
    required String headword,
    required PartOfSpeech partOfSpeech,
  }) async {
    await (_db.update(_db.words)..where((t) => t.id.equals(wordId))).write(
      WordsCompanion(
        headword: Value(headword),
        partOfSpeech: Value(partOfSpeech.value),
        meaning: Value(meaning),
        phonetic: Value(phonetic),
        exampleEn: Value(exampleEn),
        exampleJa: Value(exampleJa),
        level: Value(level),
        isDraft: const Value(false),
        isEdited: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// 語を削除する。所属・学習状態・履歴も cascade で一緒に消える。
  Future<void> delete(int wordId) async {
    final deleted =
        await (_db.delete(_db.words)..where((t) => t.id.equals(wordId))).go();
    if (deleted == 0) throw StateError('削除対象の単語が見つかりません（id=$wordId）');
  }

  /// 出題から除外する / 除外を解除する（FR-09）。辞書には残り、学習状態も保持する。
  Future<void> setExcluded(int wordId, {required bool excluded}) async {
    await (_db.update(_db.words)..where((t) => t.id.equals(wordId))).write(
      WordsCompanion(
        isExcluded: Value(excluded),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// ある語の、現在の学習者の学習状態。まだ解いていなければ null。
  Stream<WordReview?> watchReview(int wordId, int profileId) {
    return (_db.select(_db.wordReviews)..where(
          (t) => t.wordId.equals(wordId) & t.profileId.equals(profileId),
        ))
        .watchSingleOrNull();
  }

  /// [profile] が選んでいる単語帳にある「出題できる語」の数
  /// （[Docs/06_features/srs_scheduler.md] §6.1）。
  Future<int> countStudyable(Profile profile) async {
    final wordbookIds = decodeIdList(profile.selectedWordbookIds);
    if (wordbookIds.isEmpty) return 0;
    final rows = await _db
        .customSelect(
          'SELECT COUNT(DISTINCT w.id) AS c FROM words w '
          'JOIN wordbook_entries we ON we.word_id = w.id '
          'WHERE we.wordbook_id IN (${_placeholders(wordbookIds.length)}) '
          'AND (w.owner_profile_id IS NULL OR w.owner_profile_id = ?) '
          'AND w.is_excluded = 0 AND w.is_draft = 0',
          variables: [
            ...wordbookIds.map(Variable<int>.new),
            Variable<int>(profile.id),
          ],
          readsFrom: {_db.words, _db.wordbookEntries},
        )
        .getSingle();
    return rows.read<int>('c');
  }

  static String? _nullIfBlank(String? v) {
    if (v == null) return null;
    final trimmed = v.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

/// SQL の断片と、そこに対応する変数。
class _Sql {
  final String text;
  final List<Variable<Object>> variables;

  const _Sql(this.text, this.variables);
}
