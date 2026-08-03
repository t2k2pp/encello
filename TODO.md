# Encello - 実装 ToDo リスト

## Phase 1: 設計書作成とリポジトリ基盤整備
- [x] 設計ドキュメントの作成 (`docs/00_overview.md` ～ `docs/05_design_system.md`)
- [x] 開発規約 `CLAUDE.md` の作成
- [x] ToDoリスト `TODO.md` の作成
- [x] 初期設計コミットの記録 (`git commit`)

## Phase 2: Flutter プロジェクト初期化 & パッケージ依存関係の設定
- [ ] Flutter プロジェクトの生成 (`flutter create --org com.encello encello`)
- [ ] `pubspec.yaml` の依存関係追加 (`flutter_riverpod`, `drift`, `sqlite3`, `flutter_tts`, `google_fonts` 等)
- [ ] 基本ディレクトリ構造 (`lib/core`, `lib/data`, `lib/domain`, `lib/presentation`) の準備

## Phase 3: データ層 (Drift/SQLite & Models) の実装
- [ ] Drift テーブル定義 (`words`, `word_reviews`, `learning_logs`, `stories`, `story_clozes`, `user_settings`) の作成
- [ ] コード自動生成 (`build_runner` による Drift DB生成)
- [ ] リポジトリ層 (Repository Implementation) と初期シードデータ (プリセット単語・ストーリー) の実装
- [ ] 忘却曲線復習計算アルゴリズム (`SpacedRepetitionCalculator`) のドメイン実装 & ユニットテスト

## Phase 4: プレゼンテーション層 (UI & Providers) の実装
- [ ] テーマ・デザインシステム基盤 (`lib/core/theme`) の構築
- [ ] ダッシュボード画面 (`SCR-01`) と Riverpod Providers の実装
- [ ] スペル学習モード画面 (`SCR-03`) と類似度判定ロジックの実装
- [ ] フラッシュカード学習モード画面 (`SCR-04`) の実装
- [ ] ストーリー穴埋め学習モード画面 (`SCR-05`) の実装
- [ ] 単語一覧・辞書画面 (`SCR-06`) および詳細・検索機能の実装
- [ ] 統計画面 (`SCR-07`) および設定画面 (`SCR-08`) の実装

## Phase 5: データインポート/エクスポート & 仕上げ
- [ ] CSV/JSON バックアップ・エクスポート/インポート機能の実装
- [ ] 音声読み上げ (`flutter_tts`) 動作確認 & エラーハンドリング
- [ ] 最終動作テスト & ドキュメント更新

## Phase 6: リモートリポジトリ同期
- [ ] ユーザーから提示されたリモートリポジトリURLの追加 (`git remote add origin <URL>`)
- [ ] リモートリポジトリへの Push (`git push -u origin main`)
