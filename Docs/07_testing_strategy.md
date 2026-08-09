# 07. テスト戦略（Testing Strategy）

## 1. 層ごとの方針

| 層 | 対象 | 手段 |
|---|---|---|
| Domain | SM-2、出題キュー、綴り判定、grade 決定、誤答選択肢、XP、ストリーク、習熟度導出、日付境界、語彙数推定、取り違え検出、語形変化の出題条件 | ユニットテスト。**分岐と境界値を網羅する** |
| Data | Drift の DAO、マイグレーション、プリセット投入、音声パック取り込み、エクスポート/インポート | `NativeDatabase.memory()` を使うユニットテスト＋ `drift_dev` のスキーマテスト |
| Application | 1問確定のトランザクション、セッション確定、実績判定、リマインダー予約、共有テキストの受け取り | フェイクを注入したユニットテスト |
| Presentation | 各画面のレイアウト、オーバーフロー、状態分岐 | ウィジェットテスト |
| 全体 | 学習1周（開始→解答→結果）、学習者の分離 | `integration_test` |

`domain/` は Flutter にも Drift にも依存しないため、`flutter test` で高速に回る。
ここを厚くして、UI テストは「壊れやすい所」に絞る。

## 2. ディレクトリ

```
test/
├── domain/          # sm2_scheduler / study_queue_builder / spell_judge / grade_resolver
│                    #   / choice_distractors / xp_calculator / streak_calculator
│                    #   / mastery / study_date / vocab_size_estimator / vocab_test_builder
│                    #   / reminder_plan_builder / confusion_pair_finder / family_quiz_builder
├── data/            # dao / migration / seed_importer / audio_pack_importer / export_import
│                    #   / vocab_test_repository / pseudowords（アセットの検証）
├── application/     # answer_submission / session_finalizer / achievement_evaluator
│                    #   / reminder_scheduler / shared_text_receiver
├── providers/       # stats_aggregates / reaction_time_stats（境界の純粋関数）
├── widget/          # 画面ごと + overflow_matrix_test.dart
├── fakes/           # fake_pronunciation_service / fake_tts_service
│                    #   / fake_reminder_service / fake_clock
└── helpers/         # テスト用 DB 生成、学習者・単語ファクトリ
integration_test/
└── study_flow_test.dart
```

## 3. 必ず書くテスト

各機能設計書の「テスト観点」節が正本。ここでは横断的なものを挙げる。

### 3.1 オーバーフロー・マトリクス

`test/widget/overflow_matrix_test.dart` で
**幅 320 / 390 / 768 dp × textScaler 1.0 / 1.3 / 1.6** の9通りを主要画面に対して回し、
`tester.takeException()` が null であることを確認する（NFR-05）。

対象画面: プロファイルゲート / ホーム / スペル学習 / リスニング / フラッシュカード / 4択 /
スピード / 語のつくり / 取り違え / 結果 / 語彙力測定と結果 / 辞書（リスト・グリッド）/
単語詳細（語のつくり・語族・取り違えの各カードあり）/ 語の部品の詳細 / マイ単語 / 統計 /
実績一覧 / 学習履歴 / 設定（5タブすべて）/ 単語帳管理 / 学習者管理 / 音声パック管理。

長い値を使う: 見出し語 `internationalization`、和訳
`〜を国際化する；〜に国際的な性格を与える；国際管理下に置く`、単語帳名・学習者名・音声パック名は20文字、
語族に8語、語のつくりの部品を4つ。

### 3.2 OS キーボードが出ないことの回帰テスト

スペル・リスニング画面のウィジェットテストで、
`expect(find.byType(EditableText), findsNothing)` を確認する（[06_features/spell_mode.md] §2.1）。
将来 `TextField` を持ち込む変更が入ったら必ず落ちる。

### 3.3 マイグレーション

`drift_dev schema dump` で各版のスナップショットを `drift_schemas/` に置き、
`schemaVersion` を上げるたびに旧版→新版のマイグレーションテストを追加する（NFR-09）。

### 3.4 決定性

出題順のシャッフルはシード付き乱数を使う（[06_features/srs_scheduler.md] §6.3）。
テストでは固定シードを渡し、順序を厳密に検証する。

### 3.5 時刻

`DateTime.now()` を直接呼ばない。`Clock` を Provider で注入し、テストでは `FakeClock` を使う。
04:00 境界・ストリーク・`dueAt` は時刻に依存するため、実時刻に依存したテストを書かない。

### 3.6 学習者の分離

学習に関わるすべてのリポジトリメソッドについて、
**プロファイルAの操作がプロファイルBのデータを変えない**ことを検証する（NFR-11）。

`test/helpers/` に「2人の学習者と同じ単語集合を用意する」ファクトリを置き、
`word_reviews` / `daily_stats` / `achievements` / `part_reviews` / `resolved_confusions` /
`vocab_size_tests` の各テストで使い回す。

`profileId` を必須引数にしているため、渡し忘れはコンパイルエラーになる。
テストで見るのは「渡した値が実際に効いているか」。

## 4. ウィジェットテストがハングしないための規則

ウィジェットテストは失敗せずに「無言で数百秒止まる」ことがある。原因は限られているので、
最初から避ける形で書く。

| 原因 | 回避 |
|---|---|
| `SharedPreferences` の実装を待つ | `SharedPreferences.setMockInitialValues({})` を `setUp` で必ず呼ぶ |
| Drift の `Stream` を `.first` で待つ | `.first` を使わず `expectLater(stream, emits(...))` にする。ストリームが一度も流れないと `.first` は永遠に待つ |
| `tearDown` の順序 | DB を閉じる前に `ProviderContainer.dispose()` を呼ぶ（依存の逆順に片付ける） |
| `dart:io` の非同期処理 | ファイル I/O を伴うテストは `IOOverrides` か一時ディレクトリを使い、`addTearDown` で確実に消す |
| `unawaited` の漏れ | 起動処理の非同期を投げっぱなしにしない。`await tester.pumpAndSettle()` で回収できる形にする |
| `compute`（別 isolate） | ウィジェットテストでは isolate を起こさない。エクスポートの JSON 生成は Provider 越しに差し替える |
| 通知プラグイン | `reminderServiceProvider` を `FakeReminderService` に差し替える（`pumpWithProviders` の既定）。本物は `flutter_local_notifications` / `flutter_timezone` のチャネルに依存し、テストでは解決しない |
| 共有シートの受信 | `sharedTextSourceProvider` を `FakeSharedTextSource` に差し替える（`pumpWithProviders` の既定）。本物は `receive_sharing_intent` のプラットフォームチャネルに依存し、テストでは解決しない。`emit(text)` でストリームへ流して `SharedTextListener` の反応を検証する |
| `CachingAssetBundle` の使い回し | フェイクのアセットバンドルは**テストごとに作り直す**。読み込んだ Future をキャッシュするため、2件目以降で解決しない Future を待ち続ける |
| 読み込み中の表示が残る画面 | プロファイルゲートのように切り替え後もインジケータが回る画面では `pumpAndSettle` を使わず `pump()` でフレームを進める |

加えて、アニメーションを持つ画面（フィードバック帯・フラッシュカードの自動送り）では
`pumpAndSettle()` が終わらないことがある。**繰り返すアニメーションを持つ画面では
`pump(Duration)` を明示的に進める**。

## 5. 統合テスト

`integration_test/study_flow_test.dart` で次を1本通す。

1. 起動 → プリセットが投入される
2. 学習者を作る → プロファイルゲートを通る
3. 単語帳を1冊選ぶ
4. スペルモードで5問のセッションを開始する
5. 3問正解・2問誤答して結果画面まで進む
6. `word_reviews` / `daily_stats` / `study_sessions` に期待どおり書かれている
7. 2人目の学習者を作って切り替え、同じ単語が未学習として出る
8. アプリを再起動しても両者の学習状態が残っている（NFR-03）

`PronunciationService` と `ReminderService` はフェイクに差し替える。
実機の音声・通知に依存させない。

### 5.1 実行

実機・エミュレータは使わず flutter_tester で回す。

```
flutter test -d flutter-tester integration_test/study_flow_test.dart
```

`integration_test/` 配下のテストは既定で端末を要求するため、`-d flutter-tester` を必ず付ける。

### 5.2 通し方の決めごと

- **画面は実際に叩く**。プロバイダを直接動かして画面を飛ばさない（飛ばすと通したことに
  ならない）。出題中の語は、画面に出ている和訳から特定する。
- **再起動**は、一時ディレクトリに置いた**同じ DB ファイルを閉じて開き直す**ことで表す
  （メモリ DB では再起動を表現できない）。`SharedPreferences` のモックは起動のたびに
  作り直さないので、投入済みプリセットの版は再起動をまたいで残る。2回目の起動で
  再投入が起きないことまで確かめる。
- **プリセット投入は実アセット**（`assets/wordbooks/`）を `rootBundle` から読み、本番と
  同じ `SeedImporter` で入れる。検証は「6冊入った」「語が0件でない」まで。
- **学習対象は5語だけの単語帳**にする。モード選択シートで選べる問題数は 10 / 20 / 50 /
  全部 で5問を直接は選べず、プリセットは1冊で数百語あるため、貼り付け取込（SCR-24）で
  作った5語の単語帳を学習対象にして5問のセッションにする。
- 5問のうち2問を誤答すると、その2語は末尾へ1回だけ戻る（FR-31）。結果画面に着くまでの
  解答は7問になり、`study_sessions` は `plannedCount = 5` / `answeredCount = 7` /
  `correctCount = 3`、誤答した2語の `word_reviews.totalIncorrect` は 2 になる。
- 時刻は固定した `clockProvider` を使う（§3.5）。学習日・`dueAt`・ストリークを
  実時刻に依存させないため。
- `PronunciationService` は `pronunciationProvider` ごと `FakePronunciationService` へ
  差し替える。本物（`AudioPronunciationService`）は音声パックを使っていなくても
  `audioplayers` の `AudioPlayer` を作るため、プラグインの無い環境では
  `MissingPluginException` になる。
- 戻る操作に `WidgetTester.pageBack` は使わない。英語の「Back」ツールチップしか見ず、
  日本語ロケールで動くこのアプリでは見つけられない。`find.byType(BackButton)` で探す。
- 縦スクロールは `scrollUntilVisible` を使わない。スクロール対象を
  `find.byType(Scrollable)` で探すが、シェルの `IndexedStack` は選ばれていないタブも
  組み立てたままにするため複数見つかって決められない。掴む位置を画面下寄りに固定して
  ドラッグする（複数行 `TextField` にドラッグを吸われるのも避けられる）。

## 6. 手動確認が要るもの

自動テストで担保できないものは、リリース前チェックリストに残す。

- 実機の IME が学習画面で一度も出ないこと（Android / iOS 各1台）。
- 端末の TTS 音声が実際に鳴ること。速度・ピッチの変更が反映されること。
- 音声パックの音声が実際に鳴り、音源バッジが 🎙 になること。パックを外すと 🔉 に変わること。
- iOS でサイレントスイッチが ON でも音が鳴ること（[08_platform_setup.md] §3.1）。
- Android で音声データ未ダウンロードの端末での表示（[06_features/tts.md] §4）。
- 学習リマインダーが指定時刻に実機で届き、タップでその学習者に切り替わること。
- 他アプリ（ブラウザ・電子書籍）からの共有でクイック登録シートが開くこと。
- フラッシュカードの自動送り中に画面が消灯しないこと（NFR-10）。
- 出題の切り替わりが体感で引っかからないこと（NFR-01）。
- スピードモードの50問が引っかからずに流れること。
