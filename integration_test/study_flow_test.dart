import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:encello/app.dart';
import 'package:encello/application/shared_text_receiver.dart';
import 'package:encello/core/utils/enums.dart';
import 'package:encello/data/database/app_database.dart';
import 'package:encello/data/seeds/seed_importer.dart';
import 'package:encello/providers/audio.dart';
import 'package:encello/providers/providers.dart';
import 'package:encello/providers/stats.dart';
import 'package:encello/ui/screens/home_screen.dart';
import 'package:encello/ui/screens/session_result_screen.dart';
import 'package:encello/ui/screens/wordbook_detail_screen.dart';
import 'package:encello/ui/widgets/soft_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/fakes/fake_pronunciation_service.dart';
import '../test/fakes/fake_reminder_service.dart';
import '../test/fakes/fake_shared_text_source.dart';
import '../test/fakes/fake_tts_service.dart';

/// M9 統合テスト（[Docs/07_testing_strategy.md] §5）。
///
/// 起動 → 学習者作成 → 単語帳選択 → スペル5問 → 結果 → 2人目へ切り替え →
/// 再起動までを**1本**通す。画面は実際に叩き、プロバイダを直接動かして画面を
/// 飛ばすことはしない（飛ばすと通したことにならない）。
///
/// 実機に依存する口（`PronunciationService` と `ReminderService`）はフェイクに
/// 差し替えて塞ぐ。プリセット単語帳は**実アセット**を `rootBundle` から読み、
/// 本番と同じ [SeedImporter] で投入する。
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// 学習に使う5語。
  ///
  /// モード選択シートで選べる問題数は 10 / 20 / 50 / 全部 で、5問は選べない。
  /// 出題は「選んだ単語帳の出題できる語」から作られるので、**5語だけの単語帳**を
  /// 学習対象にして5問のセッションにする。プリセットは1冊で数百語あるため使えない。
  ///
  /// 見出し語はプリセットに無いものを選ぶ（取り込みが既存の共有語に吸収されると
  /// 和訳が既存のものになり、出題中の語を和訳から特定できなくなる）。
  /// 和訳は互いに重ならない語にする（画面の和訳から出題中の語を特定するため）。
  const studyWords = <String, String>{
    'pebble': '小石',
    'walnut': 'くるみ',
    'apricot': 'あんず',
    'pancake': 'ホットケーキ',
    'seaweed': '海そう',
  };
  const bookName = '統合テスト用';

  /// 貼り付け取込（SCR-24）に流し込む単語帳（EncelloWordbook v1）。
  final importText = const JsonEncoder.withIndent('  ').convert({
    'encelloWordbook': '1',
    'name': bookName,
    'emoji': '🧪',
    'words': [
      for (final e in studyWords.entries)
        {
          'headword': e.key,
          'partOfSpeech': 'noun',
          'meaning': e.value,
          'level': 2,
        },
    ],
  });

  /// 固定時刻。学習日の境界・SM-2 の期限・ストリークは時刻に依存するため、
  /// 実時刻に依存したテストを書かない（[Docs/07_testing_strategy.md] §3.5）。
  final now = DateTime(2026, 8, 9, 10);
  final studyDate = '2026-08-09';

  /// DB ファイルの置き場。再起動は**同じファイルを閉じて開き直す**ことで表す。
  late Directory workDir;
  late File dbFile;
  late FakeReminderService reminders;
  late FakePronunciationService pronunciation;

  /// 起動中のアプリが握っている DB。[shutdown] で閉じる。
  AppDatabase? db;

  setUp(() {
    workDir = Directory.systemTemp.createTempSync('encello_integration');
    dbFile = File('${workDir.path}/encello.sqlite');
    reminders = FakeReminderService();
    pronunciation = FakePronunciationService();
    // SharedPreferences の実装を待って無言で止まらないよう必ずモック初期化する
    // （[Docs/07_testing_strategy.md] §4）。以後は作り直さないので、値は
    // 「再起動」をまたいで残る（端末に残る設定と同じ扱いになる）。
    SharedPreferences.setMockInitialValues({});
    // 同梱フォントだけを使い、起動をネットワーク状態に依存させない（NFR-04）。
    GoogleFonts.config.allowRuntimeFetching = false;
    // 一時ディレクトリは必ず消す（[Docs/07_testing_strategy.md] §4）。
    // DB を閉じる前に消さないよう、片付けは最初に登録する（逆順で走る）。
    addTearDown(() {
      if (workDir.existsSync()) workDir.deleteSync(recursive: true);
    });
    addTearDown(() async => db?.close());
  });

  /// アプリを起動する（`main.dart` の [BootstrapGate] と同じ順序で初期化する）。
  ///
  /// 戻り値はプリセット投入の結果。2回目の起動で `applied` が false になることで、
  /// 投入済みの版が端末に残っていることを確かめられる。
  Future<SeedImportResult> boot(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final prefs = await SharedPreferences.getInstance();
    final opened = AppDatabase(NativeDatabase(dbFile));
    db = opened;
    final seeded = await SeedImporter(opened, rootBundle).importIfNeeded(
      installedVersion: prefs.getInt(kSeedInstalledVersionKey) ?? 0,
    );
    if (seeded.applied) {
      await prefs.setInt(kSeedInstalledVersionKey, seeded.installedVersion);
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
          databaseProvider.overrideWithValue(opened),
          clockProvider.overrideWithValue(() => now),
          // 実機の音を鳴らさない。本物の `AudioPronunciationService` は音声パックを
          // 使っていなくても `audioplayers` の `AudioPlayer` を作るため、入口の
          // `PronunciationService` ごと差し替える。
          pronunciationProvider.overrideWith(
            (ref, profile) async => pronunciation,
          ),
          // 読み上げ設定の反映（`setRate` 等）もプラグインを叩かせない。
          ttsServiceProvider.overrideWithValue(FakeTtsService()),
          // 実機の通知を予約しない。
          reminderServiceProvider.overrideWithValue(reminders),
          // 通知タップで起動したのではない（[BootstrapGate] と同じ位置の override）。
          launchProfileIdProvider.overrideWithValue(null),
          // 他アプリからの共有は受け取らない（実機の共有シートに依存させない）。
          sharedTextSourceProvider.overrideWithValue(FakeSharedTextSource()),
          // 音声パックの置き場。path_provider のチャネルを使わずに済ませる。
          documentsPathProvider.overrideWith((ref) async => workDir.path),
        ],
        child: const EncelloApp(),
      ),
    );
    await tester.pumpAndSettle();
    return seeded;
  }

  /// アプリを終了する。ウィジェットを外して `ProviderScope` を捨ててから DB を
  /// 閉じる（依存の逆順。[Docs/07_testing_strategy.md] §4）。
  Future<void> shutdown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await db!.close();
    db = null;
  }

  /// 画面上の英字キーボードで綴りを打つ（OS の IME は使わない）。
  Future<void> type(WidgetTester tester, String text) async {
    for (final ch in text.split('')) {
      await tester.tap(find.widgetWithText(GestureDetector, ch).first);
      await tester.pump();
    }
  }

  /// いま出題されている語を、画面に出ている和訳から特定する。
  String currentHeadword() {
    final shown = studyWords.entries
        .where((e) => find.text(e.value).evaluate().isNotEmpty)
        .toList();
    expect(shown, hasLength(1), reason: '出題中の語を画面から特定できませんでした');
    return shown.single.key;
  }

  /// 1問に答えてフィードバックを閉じ、答えた語の見出し語を返す。
  ///
  /// 誤答は「わからない」で作る（打ち間違いに頼らず、必ず不正解で確定する）。
  Future<String> answerOne(
    WidgetTester tester, {
    required bool correct,
  }) async {
    final headword = currentHeadword();
    if (correct) {
      await type(tester, headword);
      await tester.tap(find.text('答え合わせ'));
    } else {
      await tester.tap(find.text('わからない'));
    }
    await tester.pumpAndSettle();
    expect(find.text(correct ? '正解' : '不正解'), findsOneWidget);

    final isLast = find.text('結果を見る').evaluate().isNotEmpty;
    await tester.tap(find.text(isLast ? '結果を見る' : '次へ'));
    await tester.pumpAndSettle();
    return headword;
  }

  /// シェルのタブを切り替える。
  Future<void> openTab(WidgetTester tester, IconData icon) async {
    await tester.tap(find.byIcon(icon));
    await tester.pumpAndSettle();
  }

  /// 積んだ画面から戻る。
  ///
  /// `WidgetTester.pageBack` は英語の「Back」ツールチップしか見ないため、
  /// 日本語ロケールで動くこのアプリでは見つけられない。戻るボタンの型で探す。
  Future<void> goBack(WidgetTester tester) async {
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
  }

  /// 画面を上へスクロールして [finder] を出す。
  ///
  /// `scrollUntilVisible` は使わない。スクロール対象を `find.byType(Scrollable)` で
  /// 探すが、シェルの `IndexedStack` は選ばれていないタブも組み立てたままにするため
  /// 複数見つかって決められない。掴む位置も領域の中央になり、貼り付け欄のような
  /// 複数行 `TextField` がある画面ではそちらがドラッグを吸ってしまう。
  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 10 && finder.evaluate().isEmpty; i++) {
      await tester.dragFrom(const Offset(100, 700), const Offset(0, -280));
      await tester.pumpAndSettle();
    }
    expect(finder, findsWidgets, reason: 'スクロールしても見つかりませんでした');
  }

  /// 単語帳管理で [name] の学習対象スイッチを入れる。
  Future<void> toggleStudyTarget(WidgetTester tester, String name) async {
    await scrollTo(tester, find.text(name));
    final row = find.ancestor(
      of: find.text(name),
      matching: find.byType(SoftCard),
    );
    await tester.tap(find.descendant(of: row, matching: find.byType(Switch)));
    await tester.pumpAndSettle();
  }

  /// モード選択シートから学習を始める（モードの既定はスペル）。
  Future<void> startSpellSession(WidgetTester tester) async {
    await tester.tap(find.text('学習をはじめる'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('はじめる'));
    await tester.pumpAndSettle();
  }

  /// [name] の学習者を DB から引く。
  Future<Profile> profileNamed(String name) async {
    final all = await db!.select(db!.profiles).get();
    return all.singleWhere((p) => p.name == name);
  }

  Future<Word> wordOf(int id) =>
      (db!.select(db!.words)..where((t) => t.id.equals(id)))
          .getSingle();

  /// [profile] の学習状態を「見出し語 → 行」で引く。
  Future<Map<String, WordReview>> reviewsOf(Profile profile) async {
    final rows = (await db!.select(db!.wordReviews).get())
        .where((r) => r.profileId == profile.id)
        .toList();
    return {
      for (final row in rows) (await wordOf(row.wordId)).headword: row,
    };
  }

  testWidgets('学習1周を通し、学習者ごとに分かれた状態が再起動後も残る', (tester) async {
    // ---- 1. 起動 → プリセットが投入される --------------------------------
    final firstBoot = await boot(tester);
    expect(firstBoot.applied, isTrue);
    expect(firstBoot.wordbookCount, SeedImporter.assetPaths.length);

    final books = await db!.select(db!.wordbooks).get();
    expect(books, hasLength(SeedImporter.assetPaths.length));
    expect(await db!.select(db!.words).get(), isNotEmpty);
    // 学習者がまだ1人もいないので、プロファイルゲートは登録を促す。
    expect(find.text('encello へようこそ'), findsOneWidget);

    // ---- 2. 学習者を作る → プロファイルゲートを通る ------------------------
    await tester.tap(find.text('学習者を登録する'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'たろう');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    expect(find.text('たろう さん'), findsOneWidget);

    // ---- 3. 単語帳を1冊選ぶ ----------------------------------------------
    // 5問のセッションにするため、5語だけの単語帳を貼り付け取込（SCR-24）で作る。
    await openTab(tester, Icons.settings_outlined);
    await tester.tap(find.text('データ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('貼り付けて取り込む'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, importText);
    await tester.pump();
    await tester.tap(find.text('確認する'));
    await tester.pumpAndSettle();
    await scrollTo(tester, find.text('${studyWords.length}語を取り込む'));
    await tester.tap(find.text('${studyWords.length}語を取り込む'));
    await tester.pumpAndSettle();
    expect(find.byType(WordbookDetailScreen), findsOneWidget);
    await goBack(tester);

    // 単語帳管理からその1冊を学習対象にする。プリセットも同じ画面に並んでいる。
    await tester.tap(find.text('マスタ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('単語帳管理'));
    await tester.pumpAndSettle();
    expect(find.text('中学英単語'), findsOneWidget);
    await toggleStudyTarget(tester, bookName);
    await goBack(tester);
    await openTab(tester, Icons.home_outlined);

    // ---- 4. スペルモードで5問のセッションを開始する -------------------------
    await startSpellSession(tester);
    expect(find.text('1 / ${studyWords.length}'), findsOneWidget);

    // ---- 5. 3問正解・2問誤答して結果画面まで進む --------------------------
    // 誤答した語はセッション中に1回だけ末尾へ戻る（FR-31）。5問のうち2問を誤答
    // すると、結果画面に着くまでの解答は 5 + 2 = 7 問になる。
    final asked = <String>[];
    for (var i = 0; i < studyWords.length + 2; i++) {
      asked.add(await answerOne(tester, correct: i < 3));
    }
    expect(asked.take(5).toSet(), studyWords.keys.toSet());
    expect(asked[5], asked[3]);
    expect(asked[6], asked[4]);

    expect(find.byType(SessionResultScreen), findsOneWidget);
    expect(find.text('3 / 7 問正解'), findsOneWidget);

    // ---- 6. word_reviews / daily_stats / study_sessions ------------------
    final taro = await profileNamed('たろう');
    final taroReviews = await reviewsOf(taro);
    expect(taroReviews, hasLength(studyWords.length));
    for (final headword in asked.take(3)) {
      expect(taroReviews[headword]!.totalCorrect, 1);
      expect(taroReviews[headword]!.totalIncorrect, 0);
      // 正解した語は次の期限が先に延びる（SM-2）。
      expect(taroReviews[headword]!.dueAt.isAfter(now), isTrue);
    }
    for (final headword in asked.skip(3).take(2)) {
      expect(taroReviews[headword]!.totalCorrect, 0);
      // 末尾へ戻された分も含めて2回とも誤答している。
      expect(taroReviews[headword]!.totalIncorrect, 2);
    }

    final daily = (await db!.select(db!.dailyStats).get())
        .where((s) => s.profileId == taro.id)
        .toList();
    expect(daily, hasLength(1));
    expect(daily.single.studyDate, studyDate);
    expect(daily.single.answeredCount, 7);
    expect(daily.single.correctCount, 3);
    expect(daily.single.goalCount, taro.dailyGoal);

    final sessions = await db!.select(db!.studySessions).get();
    expect(sessions, hasLength(1));
    expect(sessions.single.profileId, taro.id);
    expect(sessions.single.mode, StudyMode.spell.value);
    expect(sessions.single.plannedCount, studyWords.length);
    expect(sessions.single.answeredCount, 7);
    expect(sessions.single.correctCount, 3);
    expect(sessions.single.finishedAt, isNotNull);

    final logs = await db!.select(db!.learningLogs).get();
    expect(logs, hasLength(7));
    expect(logs.where((l) => l.isCorrect), hasLength(3));

    await tester.tap(find.text('終わる'));
    await tester.pumpAndSettle();

    // ---- 7. 2人目の学習者を作って切り替え、同じ単語が未学習として出る -------
    await openTab(tester, Icons.settings_outlined);
    await tester.tap(find.text('マスタ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('学習者管理'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('学習者を追加'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'はなこ');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    expect(find.text('はなこ'), findsOneWidget);
    await goBack(tester);

    await openTab(tester, Icons.home_outlined);
    await tester.tap(find.byTooltip('学習者を切り替える'));
    await tester.pumpAndSettle();
    expect(find.text('だれが学習しますか？'), findsOneWidget);
    await tester.tap(find.text('はなこ'));
    await tester.pumpAndSettle();
    expect(find.text('はなこ さん'), findsOneWidget);

    // 学習対象は学習者ごとに持つので、2人目は自分で選び直す。
    await tester.tap(find.text('自分で単語帳を選ぶ'));
    await tester.pumpAndSettle();
    await toggleStudyTarget(tester, bookName);
    await goBack(tester);

    await startSpellSession(tester);
    // たろうが解いた5語と同じ語が、はなこには未学習の5問として出る。
    expect(find.text('1 / ${studyWords.length}'), findsOneWidget);
    expect(studyWords.keys, contains(currentHeadword()));
    final hanako = await profileNamed('はなこ');
    expect(await reviewsOf(hanako), isEmpty);
    final studied = <int>{
      for (final row in await db!.select(db!.wordReviews).get())
        row.wordId,
    };
    final imported = (await db!.select(db!.wordbooks).get())
        .singleWhere((b) => b.name == bookName);
    final entries = await db!.select(db!.wordbookEntries).get();
    expect(
      entries
          .where((e) => e.wordbookId == imported.id)
          .map((e) => e.wordId)
          .toSet(),
      studied,
    );

    // 1問だけ解いて中断する。たろうの記録は動かない（NFR-11）。
    final hanakoWord = currentHeadword();
    await type(tester, hanakoWord);
    await tester.tap(find.text('答え合わせ'));
    await tester.pumpAndSettle();
    expect(find.text('正解'), findsOneWidget);
    await tester.tap(find.byTooltip('学習を中断する'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('中断する'));
    await tester.pumpAndSettle();

    expect(await reviewsOf(hanako), hasLength(1));
    expect((await reviewsOf(hanako))[hanakoWord]!.totalCorrect, 1);
    expect(await reviewsOf(taro), hasLength(studyWords.length));

    // ---- 8. 再起動しても両者の学習状態が残っている（NFR-03）----------------
    await shutdown(tester);
    final secondBoot = await boot(tester);
    // 投入済みの版が端末に残っているので、プリセットは入れ直さない。
    expect(secondBoot.applied, isFalse);

    // ゲートには2人が並び、それぞれの今日の進捗が残っている。
    expect(find.text('だれが学習しますか？'), findsOneWidget);
    expect(find.text('今日 7 / ${taro.dailyGoal} 問'), findsOneWidget);
    expect(find.text('今日 1 / ${hanako.dailyGoal} 問'), findsOneWidget);

    final taroAfter = await reviewsOf(taro);
    expect(taroAfter, hasLength(studyWords.length));
    for (final headword in asked.take(3)) {
      expect(taroAfter[headword]!.totalCorrect, 1);
    }
    for (final headword in asked.skip(3).take(2)) {
      expect(taroAfter[headword]!.totalIncorrect, 2);
    }
    expect(await reviewsOf(hanako), hasLength(1));

    // 学習対象の単語帳も残っている。
    await tester.tap(find.text('たろう'));
    await tester.pumpAndSettle();
    expect(find.text('たろう さん'), findsOneWidget);
    final onHome = find.descendant(
      of: find.byType(HomeScreen),
      matching: find.text(bookName),
    );
    await scrollTo(tester, onHome);
    expect(onHome, findsOneWidget);

    await shutdown(tester);
  }, timeout: const Timeout(Duration(minutes: 5)));
}
