import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:encello/application/study_launcher.dart';
import 'package:encello/core/utils/enums.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:encello/data/repositories/word_repository.dart';
import 'package:encello/data/repositories/wordbook_repository.dart';
import 'package:encello/data/seeds/pseudoword_assets.dart';
import 'package:encello/domain/usecases/family_quiz_builder.dart';
import 'package:encello/domain/usecases/study_queue_builder.dart';
import 'package:encello/providers/providers.dart';
import 'package:encello/ui/dialogs/start_study_sheet.dart';
import 'package:encello/ui/screens/achievements_screen.dart';
import 'package:encello/ui/screens/audio_packs_screen.dart';
import 'package:encello/ui/screens/choice_study_screen.dart';
import 'package:encello/ui/screens/csv_import_screen.dart';
import 'package:encello/ui/screens/dictionary_screen.dart';
import 'package:encello/ui/screens/flashcard_screen.dart';
import 'package:encello/ui/screens/home_screen.dart';
import 'package:encello/ui/screens/my_words_screen.dart';
import 'package:encello/ui/screens/paste_import_screen.dart';
import 'package:encello/ui/screens/privacy_policy_screen.dart';
import 'package:encello/ui/screens/profile_gate_screen.dart';
import 'package:encello/ui/screens/profiles_screen.dart';
import 'package:encello/ui/screens/prompt_guide_screen.dart';
import 'package:encello/ui/screens/root_shell.dart';
import 'package:encello/ui/screens/session_history_screen.dart';
import 'package:encello/ui/screens/session_result_screen.dart';
import 'package:encello/ui/screens/settings_screen.dart';
import 'package:encello/ui/screens/spell_study_screen.dart';
import 'package:encello/ui/screens/stats_screen.dart';
import 'package:encello/ui/screens/vocab_test_screen.dart';
import 'package:encello/ui/screens/word_detail_screen.dart';
import 'package:encello/ui/screens/word_part_detail_screen.dart';
import 'package:encello/ui/screens/wordbook_detail_screen.dart';
import 'package:encello/ui/screens/wordbooks_screen.dart';
import 'package:encello/ui/screens/write_meaning_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_wakelock.dart';
import '../helpers/fake_asset_bundle.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_database.dart';

/// オーバーフロー・マトリクス（[Docs/07_testing_strategy.md] §3.1、NFR-05）。
///
/// **幅 320 / 390 / 768 dp × textScaler 1.0 / 1.3 / 1.6** の9通りを主要画面に回し、
/// `tester.takeException()` が null であることを確認する。
/// 長い値（20文字の学習者名・単語帳名、`internationalization`、長い和訳）を使う。
void main() {
  const widths = <double>[320, 390, 768];
  const scales = <double>[1.0, 1.3, 1.6];

  /// 20文字の学習者名（`profiles.name` の上限）。
  const longName = 'あいうえおかきくけこさしすせそたちつてと';
  const longName2 = 'なにぬねのはひふへほまみむめもやゆよわ';
  const longBookName = 'とてもながいなまえのたんごちょうです';
  const longHeadword = 'internationalization';
  const longMeaning = '〜を国際化する；〜に国際的な性格を与える；国際管理下に置く';

  late AppDatabase db;

  setUp(() {
    db = newTestDatabase();
  });

  /// 単語帳と長い単語を用意し、単語帳 id と単語 id を返す。
  Future<({int wordbookId, int wordId})> seedWords(Profile profile) async {
    final repo = WordbookRepository(db);
    final wordbookId = await repo.create(
      name: longBookName,
      emoji: '📗',
      colorSeed: 2,
      note: 'とてもながい説明文がここに入ります。折り返しが効いていることを確かめます。',
    );
    final wordId = await db
        .into(db.words)
        .insert(
          WordsCompanion.insert(
            headword: longHeadword,
            partOfSpeech: PartOfSpeech.verb.value,
            meaning: longMeaning,
            phonetic: const Value('/ˌɪntərˌnæʃənələˈzeɪʃən/'),
            presetId: const Value('jhs_v1:internationalization:verb'),
            isEdited: const Value(true),
            isExcluded: const Value(true),
          ),
        );
    await db
        .into(db.wordExamples)
        .insert(
          WordExamplesCompanion.insert(
            wordId: wordId,
            exampleEn:
                'The internationalization of the company took several years.',
            exampleJa: const Value('その会社の国際化には数年かかりました。'),
            sourcePresetId: const Value('jhs_v1'),
            sortOrder: const Value(10),
          ),
        );
    await repo.addWord(wordbookId, wordId);
    await db
        .into(db.wordReviews)
        .insert(
          WordReviewsCompanion.insert(
            profileId: profile.id,
            wordId: wordId,
            dueAt: DateTime(2026, 8, 4, 4),
            masteryLevel: const Value(2),
            totalCorrect: const Value(12),
            totalIncorrect: const Value(3),
            correctStreak: const Value(4),
          ),
        );
    await repo.setStudyTarget(profile, wordbookId, selected: true);
    return (wordbookId: wordbookId, wordId: wordId);
  }

  /// 固定時刻。取り違えの検出は「90日以内の誤答」を見るため、実時刻に依存させない
  /// （[Docs/07_testing_strategy.md] §3.5）。
  DateTime fixedNow() => DateTime(2026, 8, 4, 20);

  /// 主要画面を1つ描画して、レイアウト例外が出ないことを確認する。
  Future<void> checkMatrix(
    WidgetTester tester,
    String label,
    Widget Function(Profile? profile) build, {
    bool withActiveProfile = true,
    bool wrapInScaffold = false,
    DateTime Function()? clock,
  }) async {
    for (final width in widths) {
      for (final scale in scales) {
        final profiles = await db.select(db.profiles).get();
        final first = profiles.isEmpty ? null : profiles.first;
        await pumpWithProviders(
          tester,
          db: db,
          child: build(first),
          activeProfile: withActiveProfile ? first : null,
          textScale: scale,
          size: Size(width, 900),
          wrapInScaffold: wrapInScaffold,
          clock: clock,
        );
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '$label が 幅$width × textScaler$scale で溢れた',
        );
      }
    }
  }

  /// 学習セッションを伴う画面を1つ描画して、レイアウト例外が出ないことを確認する。
  ///
  /// 学習画面はタイマー（自動送り・制限時間）とアニメーションを持つ。進め方は
  /// 画面ごとに違うので [drive] に任せ、最後は空のツリーへ差し替えて確実に破棄する
  /// （[Docs/07_testing_strategy.md] §4）。
  Future<void> checkSessionMatrix(
    WidgetTester tester,
    String label, {
    required Widget screen,
    required Future<void> Function(ProviderContainer container, Profile profile)
    start,
    required Future<void> Function(ProviderContainer container) drive,
  }) async {
    for (final width in widths) {
      for (final scale in scales) {
        final profile = (await db.select(db.profiles).get()).first;
        final container = await pumpWithProviders(
          tester,
          db: db,
          child: screen,
          activeProfile: profile,
          textScale: scale,
          size: Size(width, 900),
          clock: fixedNow,
        );
        await start(container, profile);
        await drive(container);
        expect(
          tester.takeException(),
          isNull,
          reason: '$label が 幅$width × textScaler$scale で溢れた',
        );
        await tester.pumpWidget(const SizedBox.shrink());
      }
    }
  }

  /// 学習に使う単語帳を作り、学習対象に選ぶ。
  ///
  /// 見出し語も和訳も長いものだけを入れる（短い語で埋めると、どの語が出題されても
  /// 溢れないという保証にならない）。
  Future<({int wordbookId, List<int> wordIds})> seedStudyDeck(
    Profile profile, {
    int fillerCount = 24,
  }) async {
    final repo = WordbookRepository(db);
    final wordbookId = await repo.create(
      name: longBookName,
      emoji: '📗',
      colorSeed: 2,
    );
    final ids = <int>[
      await db
          .into(db.words)
          .insert(
            WordsCompanion.insert(
              headword: longHeadword,
              partOfSpeech: PartOfSpeech.verb.value,
              meaning: longMeaning,
              phonetic: const Value('/ˌɪntərˌnæʃənələˈzeɪʃən/'),
            ),
          ),
    ];
    await db
        .into(db.wordExamples)
        .insert(
          WordExamplesCompanion.insert(
            wordId: ids.first,
            exampleEn:
                'The internationalization of the company took several years.',
            exampleJa: const Value('その会社の国際化には数年かかりました。'),
          ),
        );
    for (var i = 0; i < fillerCount; i++) {
      ids.add(
        await db
            .into(db.words)
            .insert(
              WordsCompanion.insert(
                headword: '$longHeadword${String.fromCharCode(97 + i)}',
                partOfSpeech: PartOfSpeech.noun.value,
                // 逆引きに使うため、和訳は語ごとに違うものにする。
                meaning: '$longMeaning（$i）',
              ),
            ),
      );
    }
    for (final id in ids) {
      await repo.addWord(wordbookId, id);
    }
    await repo.setStudyTarget(profile, wordbookId, selected: true);
    return (wordbookId: wordbookId, wordIds: ids);
  }

  /// 渡した語を学習済みにする（スピードの解禁条件と習熟度バッジのため）。
  Future<void> markLearned(Profile profile, Iterable<int> wordIds) async {
    for (final id in wordIds) {
      await db
          .into(db.wordReviews)
          .insert(
            WordReviewsCompanion.insert(
              profileId: profile.id,
              wordId: id,
              dueAt: DateTime(2026, 8, 4, 4),
              masteryLevel: const Value(2),
              totalCorrect: const Value(12),
              totalIncorrect: const Value(3),
              correctStreak: const Value(4),
            ),
          );
    }
  }

  /// [wordId] と [confusedWith] を取り違えた履歴を2回ぶん作る（組の成立条件）。
  Future<void> seedConfusion(
    Profile profile, {
    required int wordId,
    required int confusedWith,
  }) async {
    final other = await (db.select(
      db.words,
    )..where((t) => t.id.equals(confusedWith))).getSingle();
    await db
        .into(db.studySessions)
        .insert(
          StudySessionsCompanion.insert(
            id: 'past-session',
            profileId: profile.id,
            mode: StudyMode.choice.value,
            startedAt: DateTime(2026, 8, 1),
          ),
        );
    for (var i = 0; i < 2; i++) {
      await db
          .into(db.learningLogs)
          .insert(
            LearningLogsCompanion.insert(
              profileId: profile.id,
              sessionId: 'past-session',
              wordId: Value(wordId),
              mode: StudyMode.choice.value,
              direction: StudyDirection.enToJa.value,
              isCorrect: false,
              grade: 1,
              answeredText: Value(other.meaning),
              elapsedMs: 3000,
              answeredAt: DateTime(2026, 8, 2),
            ),
          );
    }
  }

  /// 語の部品を作って単語に紐付ける。[wordIds] は12語以上を渡す。
  ///
  /// 出題に使えるのは**紐付いた語が3語以上ある部品**で、誤答選択肢は同じ種別から
  /// 選ぶ（[Docs/06_features/word_parts.md] §5.3）。そのため語根を4つ用意し、
  /// それぞれに3語ずつ紐付ける。先頭の語には接頭辞・接尾辞も付けて、
  /// 単語詳細の「語のつくり」カードに部品が4つ並ぶ状態を作る。
  /// 戻り値は語の部品の詳細で使う語根の id。
  Future<int> seedWordParts(List<int> wordIds) async {
    Future<int> addPart(
      String form,
      String type,
      String meaning,
      String origin,
    ) => db
        .into(db.wordParts)
        .insert(
          WordPartsCompanion.insert(
            form: form,
            type: type,
            meaning: meaning,
            origin: Value(origin),
            note: const Value('同じつづりでも別の意味になる語があるので、語全体で確かめてください。'),
          ),
        );
    Future<void> link(int wordId, int partId, int position) => db
        .into(db.wordPartLinks)
        .insert(
          WordPartLinksCompanion.insert(
            wordId: wordId,
            partId: partId,
            position: Value(position),
          ),
        );

    final roots = [
      await addPart('nat', 'root', '生まれる；生まれ', 'ラテン語 nasci（生まれる）'),
      await addPart('port', 'root', '運ぶ；港', 'ラテン語 portare（運ぶ）'),
      await addPart('spect', 'root', '見る；ながめる', 'ラテン語 spectare（見る）'),
      await addPart('dict', 'root', '言う；告げる', 'ラテン語 dicere（言う）'),
    ];
    // 語根ごとに3語。先頭の語は1つ目の語根に紐付ける。
    for (var i = 0; i < roots.length * 3; i++) {
      await link(wordIds[i], roots[i ~/ 3], 1);
    }
    // 先頭の語だけ、接頭辞と接尾辞も添えて部品を4つにする。
    await link(
      wordIds.first,
      await addPart('inter-', 'prefix', '〜のあいだで；相互に', 'ラテン語 inter（〜のあいだに）'),
      0,
    );
    await link(
      wordIds.first,
      await addPart('-al', 'suffix', '〜に関する（形容詞をつくる）', 'ラテン語 -alis'),
      2,
    );
    await link(
      wordIds.first,
      await addPart('-ization', 'suffix', '〜にすること（名詞をつくる）', 'ギリシャ語 -izein ＋ -ation'),
      3,
    );
    return roots.first;
  }

  /// 語形変化クイズが成立する語族を作る（求める品詞の語がちょうど1つ）。
  /// 提示語は既習にしておく（知らない語からは変形を作れない）。
  Future<void> seedQuizFamily(Profile profile, int wordbookId) async {
    final familyId = await db
        .into(db.wordFamilies)
        .insert(const WordFamiliesCompanion(baseForm: Value('national')));
    final prompt = await db
        .into(db.words)
        .insert(
          WordsCompanion.insert(
            headword: 'national',
            partOfSpeech: PartOfSpeech.adjective.value,
            meaning: '国家の；国民の；全国的な',
            familyId: Value(familyId),
          ),
        );
    final answer = await db
        .into(db.words)
        .insert(
          WordsCompanion.insert(
            headword: 'nationalization',
            partOfSpeech: PartOfSpeech.noun.value,
            meaning: '国有化；国営化；国民化',
            familyId: Value(familyId),
          ),
        );
    final repo = WordbookRepository(db);
    await repo.addWord(wordbookId, prompt);
    await repo.addWord(wordbookId, answer);
    await markLearned(profile, [prompt]);
  }

  group('学習者まわりの画面', () {
    testWidgets('プロファイルゲート（学習者2人）', (tester) async {
      await createTestProfile(db, name: longName, colorSeed: 0);
      await createTestProfile(db, name: longName2, colorSeed: 1);
      await checkMatrix(
        tester,
        'プロファイルゲート',
        (_) => const ProfileGateScreen(),
        withActiveProfile: false,
      );
    });

    testWidgets('プロファイルゲート（初回起動・学習者0人）', (tester) async {
      await checkMatrix(
        tester,
        'プロファイルゲート（初回）',
        (_) => const ProfileGateScreen(),
        withActiveProfile: false,
      );
    });

    testWidgets('学習者管理', (tester) async {
      await createTestProfile(db, name: longName, colorSeed: 0);
      await createTestProfile(db, name: longName2, colorSeed: 1);
      await checkMatrix(tester, '学習者管理', (_) => const ProfilesScreen());
    });
  });

  group('シェルとタブ', () {
    testWidgets('ホーム（単語帳未選択）', (tester) async {
      await createTestProfile(db, name: longName);
      await checkMatrix(
        tester,
        'ホーム（未選択）',
        (profile) => HomeScreen(profile: profile!),
        wrapInScaffold: true,
      );
    });

    testWidgets('ホーム（単語帳を選択済み）', (tester) async {
      final profile = await createTestProfile(db, name: longName);
      await seedWords(profile);
      await checkMatrix(
        tester,
        'ホーム（選択済み）',
        (p) => HomeScreen(profile: p!),
        wrapInScaffold: true,
      );
    });

    testWidgets('辞書（単語なし）', (tester) async {
      await createTestProfile(db, name: longName);
      await checkMatrix(
        tester,
        '辞書（空）',
        (profile) => DictionaryScreen(profile: profile!),
        wrapInScaffold: true,
      );
    });

    testWidgets('辞書（長い語あり）', (tester) async {
      final profile = await createTestProfile(db, name: longName);
      await seedWords(profile);
      await checkMatrix(
        tester,
        '辞書',
        (p) => DictionaryScreen(profile: p!),
        wrapInScaffold: true,
      );
    });

    // 列数は「自動（最小タイル幅200基準）」と「最大の4列」で分岐が変わる
    // （[Docs/06_features/dictionary.md] §1.4）。両方を見る。
    for (final columns in const ['auto', '4']) {
      testWidgets('辞書（グリッド表示・列数$columns）', (tester) async {
        final profile = await createTestProfile(db, name: longName);
        final deck = await seedStudyDeck(profile, fillerCount: 11);
        await markLearned(profile, deck.wordIds.take(4));
        await (db.update(
          db.profiles,
        )..where((t) => t.id.equals(profile.id))).write(
          ProfilesCompanion(
            dictViewMode: Value(ListViewMode.grid.value),
            dictGridColumns: Value(columns),
          ),
        );
        await checkMatrix(
          tester,
          '辞書（グリッド・$columns）',
          (p) => DictionaryScreen(profile: p!),
          wrapInScaffold: true,
        );
      });
    }

    testWidgets('統計', (tester) async {
      await createTestProfile(db, name: longName);
      await checkMatrix(
        tester,
        '統計',
        (p) => StatsScreen(profile: p!),
        wrapInScaffold: true,
      );
    });

    testWidgets('統計（測定・学習の記録あり）', (tester) async {
      final profile = await createTestProfile(db, name: longName);
      await seedWords(profile);
      await db
          .into(db.dailyStats)
          .insert(
            DailyStatsCompanion.insert(
              profileId: profile.id,
              studyDate: '2026-08-04',
              goalCount: 20,
              answeredCount: const Value(24),
              correctCount: const Value(18),
              xp: const Value(320),
              goalMet: const Value(true),
            ),
          );
      await db
          .into(db.vocabSizeTests)
          .insert(
            VocabSizeTestsCompanion.insert(
              profileId: profile.id,
              takenAt: DateTime(2026, 8, 1),
              estimatedSize: 2180,
              falseAlarmRate: 0.2,
              bandResults: Value(
                '[{"wordbookId":1,"name":"$longBookName",'
                '"bandSize":1600,"asked":8,"known":6,"corrected":0.55}]',
              ),
            ),
          );
      await checkMatrix(
        tester,
        '統計（記録あり）',
        (p) => StatsScreen(profile: p!),
        wrapInScaffold: true,
      );
    });

    testWidgets('実績一覧', (tester) async {
      final profile = await createTestProfile(db, name: longName);
      await db
          .into(db.achievements)
          .insert(
            AchievementsCompanion.insert(
              profileId: profile.id,
              code: 'first_session',
              unlockedAt: DateTime(2026, 8, 1),
            ),
          );
      await checkMatrix(tester, '実績一覧', (p) => AchievementsScreen(profile: p!));
    });

    testWidgets('学習履歴', (tester) async {
      final profile = await createTestProfile(db, name: longName);
      await db
          .into(db.studySessions)
          .insert(
            StudySessionsCompanion.insert(
              id: 'session-1',
              profileId: profile.id,
              mode: StudyMode.spell.value,
              startedAt: DateTime(2026, 8, 4, 20),
              finishedAt: Value(DateTime(2026, 8, 4, 20, 12)),
              answeredCount: const Value(20),
              correctCount: const Value(16),
              xpEarned: const Value(180),
            ),
          );
      await checkMatrix(
        tester,
        '学習履歴',
        (p) => SessionHistoryScreen(profile: p!),
      );
    });

    testWidgets('語彙力測定', (tester) async {
      final profile = await createTestProfile(db, name: longName);
      await seedWords(profile);
      await checkMatrix(tester, '語彙力測定', (p) => VocabTestScreen(profile: p!));
    });

    testWidgets('語彙力測定の結果', (tester) async {
      await createTestProfile(db, name: longName);
      // 帯として使えるのは `bandSize` を持つ単語帳だけ。長い名前の1冊を置く。
      final bandId = await db
          .into(db.wordbooks)
          .insert(
            WordbooksCompanion.insert(
              name: longBookName,
              emoji: '🏫',
              colorSeed: 1,
              category: WordbookCategory.juniorHigh.value,
              source: WordbookSource.preset.value,
              presetId: const Value('jhs_v1'),
              bandSize: const Value(1600),
              sortOrder: const Value(10),
            ),
          );
      for (var i = 0; i < 12; i++) {
        final wordId = await db
            .into(db.words)
            .insert(
              WordsCompanion.insert(
                headword: '$longHeadword${String.fromCharCode(97 + i)}',
                partOfSpeech: PartOfSpeech.noun.value,
                meaning: '$longMeaning（$i）',
              ),
            );
        await WordbookRepository(db).addWord(bandId, wordId);
      }

      for (final width in widths) {
        for (final scale in scales) {
          final current = (await db.select(db.profiles).get()).first;
          await pumpWithProviders(
            tester,
            db: db,
            child: VocabTestScreen(profile: current),
            activeProfile: current,
            textScale: scale,
            size: Size(width, 900),
            clock: fixedNow,
            // `CachingAssetBundle` は読み込んだ Future を持ち続けるので、
            // 描画のたびに作り直す（[Docs/07_testing_strategy.md] §4）。
            pseudowords: PseudowordAssets(
              FakeAssetBundle({
                PseudowordAssets.assetPath: jsonEncode({
                  'formatVersion': 1,
                  'words': [for (var i = 0; i < 10; i++) 'zzpseudo$i'],
                }),
              }),
            ),
          );
          await tester.pumpAndSettle();

          // 帯8問＋擬似語10問。すべて「わからない」で答えると、推奨単語帳の
          // カードが出る状態の結果画面になる。
          for (var i = 0; i < 18; i++) {
            final button = find.widgetWithText(OutlinedButton, 'わからない');
            if (button.evaluate().isEmpty) break;
            await tester.tap(button);
            await tester.pumpAndSettle();
          }

          expect(find.text('あなたの語彙力'), findsOneWidget);
          expect(
            tester.takeException(),
            isNull,
            reason: '語彙力測定の結果 が 幅$width × textScaler$scale で溢れた',
          );
        }
      }
    });

    testWidgets('CSV 取り込み', (tester) async {
      final profile = await createTestProfile(db, name: longName);
      final seeded = await seedWords(profile);
      final book = await (db.select(
        db.wordbooks,
      )..where((t) => t.id.equals(seeded.wordbookId))).getSingle();
      await checkMatrix(
        tester,
        'CSV 取り込み',
        (_) => CsvImportScreen(wordbook: book),
      );
    });

    testWidgets('シェル（4タブ）', (tester) async {
      await createTestProfile(db, name: longName);
      await checkMatrix(
        tester,
        'シェル',
        (profile) => RootShell(profile: profile!),
      );
    });
  });

  group('単語帳と単語', () {
    testWidgets('単語帳管理', (tester) async {
      final profile = await createTestProfile(db, name: longName);
      await seedWords(profile);
      await checkMatrix(tester, '単語帳管理', (p) => WordbooksScreen(profile: p!));
    });

    testWidgets('単語帳の中身', (tester) async {
      final profile = await createTestProfile(db, name: longName);
      final seeded = await seedWords(profile);
      await checkMatrix(
        tester,
        '単語帳の中身',
        (p) => WordbookDetailScreen(wordbookId: seeded.wordbookId, profile: p!),
      );
    });

    testWidgets('音声パック管理', (tester) async {
      final profile = await createTestProfile(db, name: longName);
      await seedWords(profile);
      await db
          .into(db.audioPacks)
          .insert(
            AudioPacksCompanion.insert(
              packId: 'jhs_en_us_v1',
              name: 'とてもながいなまえのおんせいぱっくです',
              source: AudioPackSource.imported.value,
              lang: SpeechLang.en.value,
              entryCount: const Value(1540),
            ),
          );
      await checkMatrix(
        tester,
        '音声パック管理',
        (p) => AudioPacksScreen(profile: p!),
      );
    });

    testWidgets('単語詳細', (tester) async {
      final profile = await createTestProfile(db, name: longName);
      final seeded = await seedWords(profile);
      await checkMatrix(
        tester,
        '単語詳細',
        (p) => WordDetailScreen(wordId: seeded.wordId, profile: p!),
      );
    });

    testWidgets('単語詳細（語のつくり・語族・取り違えのカードあり）', (tester) async {
      final profile = await createTestProfile(db, name: longName);
      final deck = await seedStudyDeck(profile, fillerCount: 11);
      final target = deck.wordIds.first;
      await markLearned(profile, [target]);
      await seedWordParts(deck.wordIds);
      // 語族に8語（自分＋7語）。品詞と訳をすべて長いものにする。
      final familyId = await db
          .into(db.wordFamilies)
          .insert(const WordFamiliesCompanion(baseForm: Value('nation')));
      await (db.update(db.words)..where((t) => t.id.equals(target))).write(
        WordsCompanion(
          familyId: Value(familyId),
          confusionNote: const Value('-ization は「〜にすること」、-ality は「〜であること」と覚えます。'),
        ),
      );
      for (final member in const [
        (headword: 'nation', pos: PartOfSpeech.noun, meaning: '国家；国民；民族'),
        (
          headword: 'national',
          pos: PartOfSpeech.adjective,
          meaning: '国家の；国民の；全国的な',
        ),
        (
          headword: 'nationally',
          pos: PartOfSpeech.adverb,
          meaning: '全国的に；国家として',
        ),
        (headword: 'nationality', pos: PartOfSpeech.noun, meaning: '国籍；国民性'),
        (headword: 'nationalize', pos: PartOfSpeech.verb, meaning: '〜を国有化する'),
        (
          headword: 'international',
          pos: PartOfSpeech.adjective,
          meaning: '国際的な；国家間の',
        ),
        (
          headword: 'internationally',
          pos: PartOfSpeech.adverb,
          meaning: '国際的に；国際間で',
        ),
      ]) {
        await db
            .into(db.words)
            .insert(
              WordsCompanion.insert(
                headword: member.headword,
                partOfSpeech: member.pos.value,
                meaning: member.meaning,
                familyId: Value(familyId),
              ),
            );
      }
      await seedConfusion(
        profile,
        wordId: target,
        confusedWith: deck.wordIds[1],
      );
      await checkMatrix(
        tester,
        '単語詳細（各カードあり）',
        (p) => WordDetailScreen(wordId: target, profile: p!),
        clock: fixedNow,
      );
    });

    testWidgets('語の部品の詳細', (tester) async {
      final profile = await createTestProfile(db, name: longName);
      final deck = await seedStudyDeck(profile, fillerCount: 11);
      await markLearned(profile, deck.wordIds.take(2));
      final partId = await seedWordParts(deck.wordIds);
      final part = await (db.select(
        db.wordParts,
      )..where((t) => t.id.equals(partId))).getSingle();
      await checkMatrix(
        tester,
        '語の部品の詳細',
        (p) => WordPartDetailScreen(part: part, profile: p!),
      );
    });

    testWidgets('マイ単語', (tester) async {
      final profile = await createTestProfile(db, name: longName);
      final words = WordRepository(db);
      await words.createOwned(
        ownerProfileId: profile.id,
        headword: longHeadword,
        partOfSpeech: PartOfSpeech.verb,
        meaning: longMeaning,
      );
      // 下書きも1件（下書きバッジ・下書きフィルタ・「訳を書く」ボタンを溢れさせる）。
      await words.createOwned(
        ownerProfileId: profile.id,
        headword: 'draftword',
        partOfSpeech: PartOfSpeech.noun,
      );
      await checkMatrix(tester, 'マイ単語', (p) => MyWordsScreen(profile: p!));
    });

    testWidgets('訳を書く', (tester) async {
      final profile = await createTestProfile(db, name: longName);
      final words = WordRepository(db);
      await words.createOwned(
        ownerProfileId: profile.id,
        headword: longHeadword,
        partOfSpeech: PartOfSpeech.verb,
        exampleEn:
            'The internationalization of the company took several years.',
      );
      await checkMatrix(tester, '訳を書く', (p) => WriteMeaningScreen(profile: p!));
    });
  });

  group('学習モードの画面', () {
    setUp(() {
      // フラッシュカードは自動送り中に画面を消灯させない（NFR-10）。
      installFakeWakelock();
    });

    /// 綴りを1文字だけ打って誤答で確定させる。画面キーボードのタップに頼らず、
    /// 「出題 → フィードバック帯」の両方を必ず通す。
    Future<void> submitWrong(
      WidgetTester tester,
      ProviderContainer container,
    ) async {
      final notifier = container.read(studySessionProvider.notifier);
      notifier.typeLetter('x');
      await notifier.submit();
      await tester.pumpAndSettle();
    }

    /// 選択式の1問に誤答して、解説つきのフィードバックまで出す。
    Future<void> answerChoiceWrong(
      WidgetTester tester,
      ProviderContainer container,
    ) async {
      final session = container.read(choiceSessionProvider)!;
      final question = session.current!;
      final wrong =
          (question.answerIndex + 1) % question.options.length;
      await container.read(choiceSessionProvider.notifier).answer(wrong);
      await tester.pumpAndSettle();
    }

    testWidgets('スペル学習', (tester) async {
      final profile = await createTestProfile(db, name: longName);
      await seedStudyDeck(profile, fillerCount: 0);
      await checkSessionMatrix(
        tester,
        'スペル学習',
        screen: const SpellStudyScreen(),
        start: (container, p) => container
            .read(studySessionProvider.notifier)
            .start(
              profile: p,
              mode: StudyMode.spell,
              policy: QueuePolicy.reviewFirst,
              limit: 1,
            ),
        drive: (container) async {
          await tester.pumpAndSettle();
          // ヒントで文字を開示した状態のタイルも見る。
          container.read(studySessionProvider.notifier).hint();
          await tester.pumpAndSettle();
          // 「惜しい」の差分表示つきフィードバック帯。
          final notifier = container.read(studySessionProvider.notifier);
          for (final ch in longHeadword.substring(1).split('')) {
            notifier.typeLetter(ch);
          }
          await notifier.submit();
          await tester.pumpAndSettle();
        },
      );
    });

    testWidgets('リスニング・スペル', (tester) async {
      final profile = await createTestProfile(db, name: longName);
      await seedStudyDeck(profile, fillerCount: 0);
      await checkSessionMatrix(
        tester,
        'リスニング',
        screen: const SpellStudyScreen(),
        start: (container, p) => container
            .read(studySessionProvider.notifier)
            .start(
              profile: p,
              mode: StudyMode.listening,
              policy: QueuePolicy.reviewFirst,
              limit: 1,
            ),
        drive: (container) async {
          await tester.pumpAndSettle();
          // 訳を伏せた状態と、開いた状態の両方を見る。
          container.read(studySessionProvider.notifier).revealMeaning();
          await tester.pumpAndSettle();
          await submitWrong(tester, container);
        },
      );
    });

    testWidgets('語形変化クイズ', (tester) async {
      final profile = await createTestProfile(db, name: longName);
      final deck = await seedStudyDeck(profile, fillerCount: 0);
      await seedQuizFamily(profile, deck.wordbookId);
      await checkSessionMatrix(
        tester,
        '語形変化',
        screen: const SpellStudyScreen(),
        start: (container, p) async {
          final members = await container
              .read(modeRepositoryProvider)
              .loadFamilyMembers(p.id);
          await container
              .read(studySessionProvider.notifier)
              .startFamily(
                profile: p,
                questions: FamilyQuizBuilder.build(members),
                limit: 1,
              );
        },
        drive: (container) async {
          await tester.pumpAndSettle();
          await submitWrong(tester, container);
        },
      );
    });

    testWidgets('結果画面', (tester) async {
      final profile = await createTestProfile(db, name: longName);
      await seedStudyDeck(profile, fillerCount: 0);
      await checkSessionMatrix(
        tester,
        '結果画面',
        screen: const SpellStudyScreen(),
        start: (container, p) => container
            .read(studySessionProvider.notifier)
            .start(
              profile: p,
              mode: StudyMode.spell,
              policy: QueuePolicy.reviewFirst,
              limit: 1,
            ),
        drive: (container) async {
          await tester.pumpAndSettle();
          // 誤答した語は末尾へ戻る。2回誤答して「間違えた語」カードつきの結果へ。
          for (var i = 0; i < 2; i++) {
            await submitWrong(tester, container);
            container.read(studySessionProvider.notifier).next();
            await tester.pumpAndSettle();
          }
          expect(find.byType(SessionResultScreen), findsOneWidget);
        },
      );
    });

    for (final mode in FlashcardMode.values) {
      testWidgets('フラッシュカード（${mode.label}）', (tester) async {
        final profile = await createTestProfile(db, name: longName);
        await seedStudyDeck(profile, fillerCount: 4);
        await checkSessionMatrix(
          tester,
          'フラッシュカード（${mode.label}）',
          screen: const FlashcardScreen(),
          start: (container, p) => container
              .read(flashcardProvider.notifier)
              .start(
                profile: p,
                mode: mode,
                policy: QueuePolicy.reviewFirst,
                limit: 5,
              ),
          // 自動送りを持つので `pumpAndSettle` は使わない
          // （[Docs/07_testing_strategy.md] §4）。
          drive: (container) async {
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 100));
          },
        );
      });
    }

    testWidgets('4択クイズ', (tester) async {
      final profile = await createTestProfile(db, name: longName);
      await seedStudyDeck(profile, fillerCount: 5);
      await checkSessionMatrix(
        tester,
        '4択クイズ',
        screen: const ChoiceStudyScreen(),
        start: (container, p) => container
            .read(studyLauncherProvider)
            .start(
              profile: p,
              mode: StudyMode.choice,
              policy: QueuePolicy.reviewFirst,
              limit: 3,
            ),
        drive: (container) async {
          await tester.pumpAndSettle();
          await answerChoiceWrong(tester, container);
        },
      );
    });

    testWidgets('スピードモード', (tester) async {
      final profile = await createTestProfile(db, name: longName);
      final deck = await seedStudyDeck(profile, fillerCount: 24);
      await markLearned(profile, deck.wordIds.take(kSpeedMinWords));
      await checkSessionMatrix(
        tester,
        'スピードモード',
        screen: const ChoiceStudyScreen(),
        start: (container, p) => container
            .read(studyLauncherProvider)
            .start(
              profile: p,
              mode: StudyMode.speed,
              policy: QueuePolicy.reviewFirst,
              limit: kSpeedQuestionCount,
            ),
        // 制限時間のバーが動き続けるので `pumpAndSettle` は使わない（§4）。
        drive: (container) async {
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
          final session = container.read(choiceSessionProvider)!;
          await container
              .read(choiceSessionProvider.notifier)
              .answer(session.current!.answerIndex);
          await tester.pump(const Duration(milliseconds: 100));
        },
      );
    });

    testWidgets('語のつくり', (tester) async {
      final profile = await createTestProfile(db, name: longName);
      final deck = await seedStudyDeck(profile, fillerCount: 11);
      await seedWordParts(deck.wordIds);
      await checkSessionMatrix(
        tester,
        '語のつくり',
        screen: const ChoiceStudyScreen(),
        start: (container, p) => container
            .read(studyLauncherProvider)
            .start(
              profile: p,
              mode: StudyMode.parts,
              policy: QueuePolicy.reviewFirst,
              limit: 3,
            ),
        drive: (container) async {
          await tester.pumpAndSettle();
          await answerChoiceWrong(tester, container);
        },
      );
    });

    testWidgets('取り違えドリル', (tester) async {
      final profile = await createTestProfile(db, name: longName);
      final deck = await seedStudyDeck(profile, fillerCount: 5);
      await seedConfusion(
        profile,
        wordId: deck.wordIds[0],
        confusedWith: deck.wordIds[1],
      );
      await checkSessionMatrix(
        tester,
        '取り違えドリル',
        screen: const ChoiceStudyScreen(),
        start: (container, p) => container
            .read(studyLauncherProvider)
            .start(
              profile: p,
              mode: StudyMode.confusion,
              policy: QueuePolicy.reviewFirst,
              limit: 10,
            ),
        drive: (container) async {
          await tester.pumpAndSettle();
          await answerChoiceWrong(tester, container);
        },
      );
    });

    testWidgets('モード選択シート（全モードが選べる状態）', (tester) async {
      final profile = await createTestProfile(db, name: longName);
      final deck = await seedStudyDeck(profile, fillerCount: 24);
      await markLearned(profile, deck.wordIds.take(kSpeedMinWords));
      await seedConfusion(
        profile,
        wordId: deck.wordIds[0],
        confusedWith: deck.wordIds[1],
      );
      await seedWordParts(deck.wordIds);
      await seedQuizFamily(profile, deck.wordbookId);

      for (final width in widths) {
        for (final scale in scales) {
          final current = (await db.select(db.profiles).get()).first;
          await pumpWithProviders(
            tester,
            db: db,
            child: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: FilledButton(
                    onPressed: () =>
                        showStartStudySheet(context, profile: current),
                    child: const Text('学習をはじめる'),
                  ),
                ),
              ),
            ),
            activeProfile: current,
            textScale: scale,
            size: Size(width, 900),
            clock: fixedNow,
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text('学習をはじめる'));
          await tester.pumpAndSettle();

          // 送り方の行が増えるフラッシュカードでも溢れないことを見る。
          await tester.tap(find.byType(DropdownButtonFormField<StudyMode>));
          await tester.pumpAndSettle();
          await tester.tap(
            find.text('${StudyMode.flashcard.emoji} ${StudyMode.flashcard.label}').last,
          );
          await tester.pumpAndSettle();

          expect(
            tester.takeException(),
            isNull,
            reason: 'モード選択シート が 幅$width × textScaler$scale で溢れた',
          );
          await tester.pumpWidget(const SizedBox.shrink());
        }
      }
    });
  });

  group('AI 単語帳取り込み', () {
    testWidgets('貼り付け取込', (tester) async {
      final profile = await createTestProfile(db, name: longName);
      await seedWords(profile);
      await checkMatrix(
        tester,
        '貼り付け取込',
        (p) => PasteImportScreen(profile: p!),
      );
    });

    testWidgets('AI への頼み方', (tester) async {
      await createTestProfile(db, name: longName);
      await checkMatrix(
        tester,
        'AI への頼み方',
        (p) => PromptGuideScreen(profile: p!),
      );
    });
  });

  group('設定の各タブが溢れない', () {
    for (final tabIndex in [0, 1, 2, 3, 4]) {
      testWidgets('設定タブ $tabIndex', (tester) async {
        await createTestProfile(db, name: longName);
        for (final width in widths) {
          for (final scale in scales) {
            final profile = (await db.select(db.profiles).get()).first;
            await pumpWithProviders(
              tester,
              db: db,
              child: SettingsScreen(profile: profile),
              activeProfile: profile,
              textScale: scale,
              size: Size(width, 900),
              wrapInScaffold: true,
            );
            await tester.pumpAndSettle();
            if (tabIndex > 0) {
              // isScrollable な TabBar は狭い幅だと末尾のタブが画面外に出るため、
              // タップ前にスクロールして表示範囲へ入れる。
              final tab = find.byType(Tab).at(tabIndex);
              await tester.ensureVisible(tab);
              await tester.pumpAndSettle();
              await tester.tap(tab);
              await tester.pumpAndSettle();
            }
            expect(
              tester.takeException(),
              isNull,
              reason: '設定タブ$tabIndex が 幅$width × textScaler$scale で溢れた',
            );
          }
        }
      });
    }

    testWidgets('プライバシーポリシー', (tester) async {
      await createTestProfile(db, name: longName);
      await checkMatrix(
        tester,
        'プライバシーポリシー',
        (_) => const PrivacyPolicyScreen(),
      );
    });
  });
}
