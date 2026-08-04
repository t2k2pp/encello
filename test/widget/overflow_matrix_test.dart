import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:encello/core/utils/enums.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:encello/data/repositories/word_repository.dart';
import 'package:encello/data/repositories/wordbook_repository.dart';
import 'package:encello/ui/screens/achievements_screen.dart';
import 'package:encello/ui/screens/audio_packs_screen.dart';
import 'package:encello/ui/screens/dictionary_screen.dart';
import 'package:encello/ui/screens/home_screen.dart';
import 'package:encello/ui/screens/my_words_screen.dart';
import 'package:encello/ui/screens/paste_import_screen.dart';
import 'package:encello/ui/screens/profile_gate_screen.dart';
import 'package:encello/ui/screens/profiles_screen.dart';
import 'package:encello/ui/screens/prompt_guide_screen.dart';
import 'package:encello/ui/screens/root_shell.dart';
import 'package:encello/ui/screens/session_history_screen.dart';
import 'package:encello/ui/screens/settings_screen.dart';
import 'package:encello/ui/screens/stats_screen.dart';
import 'package:encello/ui/screens/vocab_test_screen.dart';
import 'package:encello/ui/screens/word_detail_screen.dart';
import 'package:encello/ui/screens/wordbook_detail_screen.dart';
import 'package:encello/ui/screens/wordbooks_screen.dart';
import 'package:encello/ui/screens/write_meaning_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
            exampleEn: const Value(
              'The internationalization of the company took several years.',
            ),
            exampleJa: const Value('その会社の国際化には数年かかりました。'),
            presetId: const Value('jhs_v1:internationalization:verb'),
            isEdited: const Value(true),
            isExcluded: const Value(true),
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

  /// 主要画面を1つ描画して、レイアウト例外が出ないことを確認する。
  Future<void> checkMatrix(
    WidgetTester tester,
    String label,
    Widget Function(Profile? profile) build, {
    bool withActiveProfile = true,
    bool wrapInScaffold = false,
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
      await checkMatrix(
        tester,
        '単語帳管理',
        (p) => WordbooksScreen(profile: p!),
      );
    });

    testWidgets('単語帳の中身', (tester) async {
      final profile = await createTestProfile(db, name: longName);
      final seeded = await seedWords(profile);
      await checkMatrix(
        tester,
        '単語帳の中身',
        (p) => WordbookDetailScreen(
          wordbookId: seeded.wordbookId,
          profile: p!,
        ),
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
      await checkMatrix(
        tester,
        'マイ単語',
        (p) => MyWordsScreen(profile: p!),
      );
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
      await checkMatrix(
        tester,
        '訳を書く',
        (p) => WriteMeaningScreen(profile: p!),
      );
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
  });
}
