# Encello - アーキテクチャ設計書 (Architecture & Tech Stack)

## 1. 技術スタック (Technology Stack)

| カテゴリ | 選定技術 | バージョン/備考 |
|---|---|---|
| **コアフレームワーク** | Flutter (Dart) | Flutter 3.29+ / Dart 3.7+ |
| **状態管理 / DI** | `flutter_riverpod` | ^3.0 (Riverpod Generator推奨) |
| **データベース / 永続化** | `drift` + `sqlite3` | SQLiteを用いた非同期型ローカルDB |
| **音声読み上げ** | `flutter_tts` | オフライン音声合成 API |
| **UI & フォント** | `google_fonts` | Inter / Outfit / Noto Sans JP |
| **パス・ファイル操作** | `path_provider`, `path` | 端末内ファイルストレージ |
| **入出力 / 共有** | `share_plus`, `file_selector` | CSV/JSON エクスポート・インポート |

---

## 2. アーキテクチャ パターン

`pricello` に準拠した **クリーンアーキテクチャ + Feature-First (機能別構成)** パターンを採用します。

```
lib/
├── app.dart                    # MaterialApp 設定・ルーティング・テーマ定義
├── main.dart                   # アプリ起動エントリーポイント
├── core/                       # 全体で共有するユーティリティ・定数・テーマ
│   ├── constants/              # アプリ定数・UI定数
│   ├── theme/                  # アプリテーマ (Light / Dark)
│   ├── utils/                  # レーベンシュタイン距離, 日付フォーマット等
│   └── widgets/                # 共通ボタン, ダイアログ, カード等
├── data/                       # データベース定義 & ローカルデータソース
│   ├── database/               # Drift データベース・テーブル定義
│   │   ├── connection/         # Native (SQLite) 接続設定
│   │   ├── tables/             # Words, LearningLogs, Stories 等のテーブル定義
│   │   └── app_database.dart   # Drift Database クラス
│   ├── repositories/           # Repository 実装
│   └── seeds/                  # 初期プリセット単語・ストーリーデータ
├── domain/                     # ビジネスロジック & エンティティ
│   ├── models/                 # ドメインモデル
│   ├── repositories/           # Repository インターフェース
│   └── services/               # 間隔反復アルゴリズム (SM-2 Calculator) 等
└── presentation/               # UI レイヤー (画面 & Riverpod Providers)
    ├── dashboard/              # ダッシュボード画面 & Provider
    ├── dictionary/             # 単語一覧・検索・編集画面
    ├── learning/               # 学習モード (Spell, Flashcard, Story Cloze)
    ├── stats/                  # 統計・グラフ画面
    └── settings/               # 設定画面
```

---

## 3. レイヤー間の依存関係規約

1. **Presentation レイヤー**:
   - UI Widget と Riverpod Provider から構成される。
   - Data レイヤーの Drift 生成クラスを直接操作せず、Domain レイヤーのモデル/Repository インターフェースを介してデータにアクセスする。
2. **Domain レイヤー**:
   - 純粋な Dart コードで記述し、Flutter UI や Drift に直接依存しない。
   - `SpacedRepetitionCalculator` 等のコアロジックは単体テスト（Unit Test）が100%通過するように設計する。
3. **Data レイヤー**:
   - Drift テーブル定義、DAO、Repository の具体実装を担当。
   - 非同期 IO はすべて `Future` または `Stream` で処理。

---

## 4. エラーハンドリング & 状態管理方針

- **AsyncValue の徹底活用**: Riverpod の `AsyncValue` (`AsyncData`, `AsyncError`, `AsyncLoading`) を利用し、データ取得中のローディング状態やエラー状態を統一的に画面へ反映する。
- **例外のキャッチと通知**: スワロー（例外を無視して放置すること）や不適切な空返しは禁止。ログ記録とユーザーへの分かりやすいエラー通知を徹底する。
