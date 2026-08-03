# encello 設計ドキュメント

英単語学習アプリ **encello（エンチェロ）** の設計書。
利用者向けの説明はリポジトリ直下の `README.md`、開発に関する設計はすべてここに置く。

## 読む順番

| # | ファイル | 内容 |
|---|---|---|
| 00 | [00_overview.md](00_overview.md) | 何を作るか。スコープ・用語・原則 |
| 01 | [01_requirements.md](01_requirements.md) | 機能要件（FR）・非機能要件（NFR） |
| 02 | [02_architecture.md](02_architecture.md) | レイヤー・パッケージ・起動シーケンス |
| 03 | [03_data_model.md](03_data_model.md) | Drift スキーマ・ER 図・エクスポート形式 |
| 04 | [04_screens_and_flows.md](04_screens_and_flows.md) | 画面一覧・遷移・レイアウト |
| 05 | [05_design_system.md](05_design_system.md) | 配色・タイポグラフィ・共通部品 |
| 06 | [06_features/](06_features/) | 機能ごとの詳細（下表） |
| 07 | [07_testing_strategy.md](07_testing_strategy.md) | テストの層と必ず書くもの |
| 08 | [08_platform_setup.md](08_platform_setup.md) | Android / iOS の設定 |
| 09 | [09_roadmap.md](09_roadmap.md) | 実装順（M1〜M9）と v2 候補 |

## 機能設計（06_features/）

| ファイル | 内容 |
|---|---|
| [profiles.md](06_features/profiles.md) | 学習者（1台を複数人で使う）。何を共有し何を分けるか |
| [srs_scheduler.md](06_features/srs_scheduler.md) | SM-2・grade の決め方・出題キュー・習熟度 |
| [spell_mode.md](06_features/spell_mode.md) | スペルモードとアプリ内キーボード・綴り判定 |
| [listening_mode.md](06_features/listening_mode.md) | 発音を聞いて綴る |
| [flashcard_mode.md](06_features/flashcard_mode.md) | 3種の自動送り |
| [quiz_mode.md](06_features/quiz_mode.md) | 4択と誤答選択肢の選び方 |
| [speed_mode.md](06_features/speed_mode.md) | 制限時間つきの流暢性訓練。反応時間を測る |
| [word_parts.md](06_features/word_parts.md) | 接頭辞・語根・接尾辞。未知語を推測する力 |
| [word_families.md](06_features/word_families.md) | 派生語ファミリーと語形変化クイズ |
| [confusion_drill.md](06_features/confusion_drill.md) | 解答履歴から取り違えの組を割り出して練習する |
| [vocab_size_test.md](06_features/vocab_size_test.md) | 語彙力測定・レベル判定・単語帳の推奨 |
| [dictionary.md](06_features/dictionary.md) | 辞書の検索・一覧・単語詳細 |
| [wordbooks.md](06_features/wordbooks.md) | 単語帳・プリセットデータ・CSV 取り込み |
| [my_words.md](06_features/my_words.md) | 出会った語の登録・下書き・共有シート受信 |
| [pronunciation.md](06_features/pronunciation.md) | 音声ファイルと合成音声の使い分け・音声パック |
| [tts.md](06_features/tts.md) | 合成音声の詳細と、使えないときの扱い |
| [gamification.md](06_features/gamification.md) | 目標・ストリーク・XP・実績 |
| [reminders.md](06_features/reminders.md) | 学習リマインダー（ローカル通知） |
| [stats.md](06_features/stats.md) | 統計画面と集計の置き場所 |
| [export_import.md](06_features/export_import.md) | バックアップ・サンプルデータ・リセット |

## 上位の規約

UI/UX の共通規約は姉妹アプリ共通の [../../Docs/STYLE_GUIDE.md] が正本。
本ドキュメントと矛盾した場合は STYLE_GUIDE が優先する。
STYLE_GUIDE から意図的に外している箇所は [05_design_system.md] §3.3・§4 に明記している。
