# 03. データモデル（Data Model）

Drift（SQLite）で端末内に保存する。`schemaVersion = 1`。
アプリ設定のうち単純なキー値（テーマ配色・文字サイズ・デイリー目標・TTS 設定など）は `SharedPreferences` に置き、
集計や絞り込みの対象になるものだけを DB に置く（§6）。

## 1. ER 図

```mermaid
erDiagram
  wordbooks ||--o{ wordbook_entries : "含む"
  words ||--o{ wordbook_entries : "属する"
  words ||--o| word_reviews : "学習状態を1つ持つ"
  words ||--o{ learning_logs : "解答履歴"
  study_sessions ||--o{ learning_logs : "セッションの解答"

  wordbooks {
    int id PK
    text name
    text emoji
    int colorSeed
    text category
    text source
    text presetId
    int seedVersion
    int sortOrder
  }
  words {
    int id PK
    text headword
    text partOfSpeech
    text phonetic
    text meaning
    text exampleEn
    text exampleJa
    int level
    text presetId
    bool isEdited
    bool isExcluded
  }
  wordbook_entries {
    int wordbookId PK_FK
    int wordId PK_FK
    int sortOrder
  }
  word_reviews {
    int wordId PK_FK
    int repetition
    real intervalDays
    real easeFactor
    datetime dueAt
    int masteryLevel
  }
  learning_logs {
    int id PK
    text sessionId FK
    int wordId FK
    text mode
    bool isCorrect
    datetime answeredAt
  }
  study_sessions {
    text id PK
    text mode
    datetime startedAt
    int xpEarned
  }
  daily_stats {
    text studyDate PK
    int answeredCount
    bool goalMet
  }
  achievements {
    text code PK
    datetime unlockedAt
  }
```

## 2. テーブル定義

### 2.1 `wordbooks`（単語帳）

| 列 | 型 | 制約 | 説明 |
|---|---|---|---|
| `id` | int | PK, autoIncrement | |
| `name` | text | not null | 表示名（例「中学英単語」） |
| `emoji` | text | not null | 一覧サムネの絵文字（[STYLE_GUIDE §4.4]） |
| `colorSeed` | int | not null | 識別色の割当シード。`AppColors.wordbookColor(colorSeed)` |
| `category` | text | not null | `juniorHigh` / `highSchool` / `eiken` / `toeic` / `custom` |
| `source` | text | not null | `preset` / `user` / `imported` |
| `presetId` | text | nullable, unique | `source = preset` のときアセット側の識別子（例 `jhs_v1`） |
| `seedVersion` | int | not null, default 0 | 投入済みプリセットの版。アセット側が新しいときのみ差分適用 |
| `note` | text | nullable | 説明文 |
| `sortOrder` | int | not null | 一覧の並び |
| `createdAt` / `updatedAt` | datetime | not null | |

### 2.2 `words`（単語）

単語は**単語帳に属さない独立したマスタ**にする。同じ語が複数の単語帳に載っていても実体は1つで、
学習状態も1つになる（[00_overview.md] 対象ユーザー）。

| 列 | 型 | 制約 | 説明 |
|---|---|---|---|
| `id` | int | PK, autoIncrement | |
| `headword` | text | not null, index | 見出し語（例 `bank`）。小文字で正規化して保存 |
| `partOfSpeech` | text | not null | `noun` / `verb` / `adjective` / `adverb` / `preposition` / `conjunction` / `pronoun` / `interjection` / `phrase` |
| `phonetic` | text | nullable | 発音記号（例 `/bæŋk/`） |
| `meaning` | text | not null | 日本語訳。同一品詞の複数語義は `；` で区切って1レコードにまとめる |
| `exampleEn` | text | nullable | 英語例文 |
| `exampleJa` | text | nullable | 例文の和訳 |
| `level` | int | not null, default 1 | 難易度 1〜5 |
| `presetId` | text | nullable, index | プリセット由来ならアセット内の識別子 |
| `isEdited` | bool | not null, default false | プリセット語をユーザーが編集した |
| `isExcluded` | bool | not null, default false | 出題から除外（FR-09） |
| `createdAt` / `updatedAt` | datetime | not null | |

- **一意制約**: `UNIQUE(headword, partOfSpeech)`。`bank`（名詞: 銀行／土手）と `bank`（動詞: 預ける）は別レコード、
  同じ品詞で語義が複数ある場合は `meaning` に併記する。学習者向けの語彙としてこの粒度で足りる。
- **プリセット語の復帰（FR-06）**: 編集前の値を DB に二重に持たず、`presetId` でアセットを引き直して戻す。
  アセットは同梱データなので、いつでも参照できる。

### 2.3 `wordbook_entries`（所属）

| 列 | 型 | 制約 |
|---|---|---|
| `wordbookId` | int | PK, FK → `wordbooks.id`（cascade delete） |
| `wordId` | int | PK, FK → `words.id`（cascade delete） |
| `sortOrder` | int | not null。単語帳内の並び（プリセットの掲載順） |

`wordId` に単独インデックスを張る（「この単語はどの単語帳にあるか」の逆引き用）。

### 2.4 `word_reviews`（学習状態）

| 列 | 型 | 制約 | 説明 |
|---|---|---|---|
| `wordId` | int | PK, FK → `words.id`（cascade delete） | |
| `repetition` | int | not null, default 0 | 連続正解回数（SM-2 の n） |
| `intervalDays` | real | not null, default 0 | 現在の出題間隔（日） |
| `easeFactor` | real | not null, default 2.5 | 容易度係数（SM-2 の EF）。下限 1.3 |
| `dueAt` | datetime | not null, index | 次回出題日時 |
| `lastReviewedAt` | datetime | nullable | |
| `firstLearnedAt` | datetime | nullable | 初回に正解した日時 |
| `lapses` | int | not null, default 0 | 定着後に誤答した回数 |
| `correctStreak` | int | not null, default 0 | 現在の連続正解 |
| `totalCorrect` / `totalIncorrect` | int | not null, default 0 | 通算 |
| `masteryLevel` | int | not null, default 0, index | 0 未学習 / 1 学習中 / 2 定着 / 3 マスター |

- `masteryLevel` は `repetition` と `intervalDays` から**導出できる値だが、列として保存する**。
  1万語の辞書を習熟度で絞り込み・並べ替えする（FR-37 / NFR-02）ためにインデックスが必要で、
  式で毎回計算すると全件スキャンになる。
  導出は `Mastery.from(ReviewState)`（`domain/entities/mastery.dart`）1か所だけが行い、
  学習状態を更新する同一トランザクション内で必ず一緒に書き換える。
- 行は**初めてその単語を解いたときに作る**。未学習語には行が無い（`LEFT JOIN` で未学習を判定する）。

### 2.5 `learning_logs`（解答履歴）

| 列 | 型 | 制約 | 説明 |
|---|---|---|---|
| `id` | int | PK, autoIncrement | |
| `sessionId` | text | not null, FK → `study_sessions.id`, index | |
| `wordId` | int | not null, FK → `words.id`（cascade delete）, index | |
| `mode` | text | not null | `spell` / `listening` / `flashcard` / `choice` |
| `direction` | text | not null | `enToJa` / `jaToEn` |
| `isCorrect` | bool | not null | |
| `grade` | int | not null | SM-2 に渡した grade（0〜5） |
| `answeredText` | text | nullable | スペル系で実際に入力された文字列 |
| `hintUsed` | int | not null, default 0 | 開示したヒント文字数 |
| `replayCount` | int | not null, default 0 | 音声の再生回数（リスニング） |
| `elapsedMs` | int | not null | 出題表示から解答確定までの時間 |
| `answeredAt` | datetime | not null, index | |

### 2.6 `study_sessions`（セッション）

| 列 | 型 | 制約 | 説明 |
|---|---|---|---|
| `id` | text | PK | UUID v4 |
| `mode` | text | not null | 開始時に選んだモード |
| `wordbookIds` | text | not null | 対象単語帳の id を JSON 配列で保持（履歴の再現用。参照整合は取らない） |
| `startedAt` | datetime | not null, index | |
| `finishedAt` | datetime | nullable | null = 中断のまま終わったセッション |
| `plannedCount` | int | not null | 出題予定数 |
| `answeredCount` / `correctCount` | int | not null, default 0 | |
| `xpEarned` | int | not null, default 0 | |

### 2.7 `daily_stats`（日次集計）

| 列 | 型 | 制約 | 説明 |
|---|---|---|---|
| `studyDate` | text | PK | `YYYY-MM-DD`。§4 の日付境界で決める |
| `answeredCount` / `correctCount` | int | not null, default 0 | |
| `xp` | int | not null, default 0 | |
| `studySeconds` | int | not null, default 0 | |
| `goalCount` | int | not null | その日に適用されていたデイリー目標（後から目標を変えても過去の達成判定を動かさない） |
| `goalMet` | bool | not null, default false | `answeredCount >= goalCount` になった時点で true。以後 false に戻さない |

`learning_logs` から毎回集計せず、解答と同一トランザクションで積み上げる。
ホームのストリーク表示（FR-41）が1万件のログ走査を伴わないようにするため。

### 2.8 `achievements`（実績）

| 列 | 型 | 制約 |
|---|---|---|
| `code` | text | PK（例 `streak_7`、`mastered_100`） |
| `unlockedAt` | datetime | not null |

解除条件は `application/achievement_evaluator.dart` に定義し、DB には解除済みだけを残す
（[06_features/gamification.md] §4）。

## 3. インデックス方針

| 対象 | 目的 |
|---|---|
| `words.headword` | 辞書の英語検索・前方一致 |
| `words.presetId` | プリセット差分適用・復帰 |
| `word_reviews.dueAt` | 「今日の復習」の抽出 |
| `word_reviews.masteryLevel` | 習熟度フィルタ・ソート |
| `wordbook_entries.wordId` | 単語→所属単語帳の逆引き |
| `learning_logs.wordId` / `.answeredAt` | 単語詳細の履歴・直近30日の集計 |
| `study_sessions.startedAt` | 履歴一覧 |

日本語訳の検索（FR-35）は `meaning LIKE '%…%'` で中間一致するためインデックスが効かない。
1万語でも全走査が数ミリ秒で終わる規模なので、FTS は導入しない。10万語規模の単語帳を扱うことになった時点で
FTS5 の導入を検討する。

## 4. 日付の境界

学習日は**端末ローカル時刻の 04:00 区切り**とする（FR-46）。
深夜1時の学習を前日の続きとして数え、ストリークが理不尽に切れないようにするため。

```dart
// core/utils/study_date.dart
String studyDateOf(DateTime local) {
  final shifted = local.subtract(const Duration(hours: 4));
  return DateFormat('yyyy-MM-dd').format(shifted);
}
```

`daily_stats.studyDate`・ストリーク計算・「今日の復習」の判定は、すべてこの関数を通す。
`dueAt` の比較だけは実時刻（`DateTime.now()`）で行う（間隔反復は暦日ではなく経過時間で決まるため）。

## 5. マイグレーション

- `schemaVersion` で管理し、`drift_dev` が生成するスキーマスナップショットに対して各版のテストを書く。
- 破壊的変更（列の削除・型変更）は行わず、追加と移行で対応する。
- マイグレーションに失敗したら起動を中断し、エラーとエクスポート手順を表示する。DB を作り直さない。

## 6. `SharedPreferences` に置く設定

| キー | 型 | 既定 | 説明 |
|---|---|---|---|
| `theme.palette` | string | `pink` | テーマ配色 |
| `theme.textScale` | string | `medium` | 文字サイズ 小/中/大 |
| `theme.density` | string | `standard` | 余白 標準/コンパクト |
| `dict.viewMode` | string | `list` | 辞書一覧のリスト/グリッド |
| `dict.gridColumns` | string | `auto` | 列数 auto/2/3/4 |
| `study.selectedWordbookIds` | string(json) | `[]` | 学習対象の単語帳 |
| `study.dailyGoal` | int | `20` | デイリー目標 |
| `study.sessionSize` | int | `20` | 1セッションの問題数 |
| `study.keyboardLayout` | string | `qwerty` | qwerty / abc |
| `study.flashcardMode` | string | `silentAuto` | フラッシュカードの送り方 |
| `study.flashcardSeconds` | int | `3` | 無音自動送りの秒数 |
| `study.choiceDirection` | string | `random` | 4択の出題方向 |
| `tts.enVoice` / `tts.jaVoice` | string | 空 | 選択中の voice 名。空 = 端末既定 |
| `tts.rate` / `tts.pitch` | double | `0.5` / `1.0` | |
| `seed.installedVersion` | int | `0` | プリセットの投入済み版 |

## 7. エクスポート形式

JSON（`formatVersion: 1`）。単語帳・単語・所属・学習状態・履歴・日次集計・実績を含む。

```json
{
  "formatVersion": 1,
  "appVersion": "1.0.0",
  "exportedAt": "2026-08-03T12:34:56+09:00",
  "wordbooks": [ { "presetId": "jhs_v1", "name": "中学英単語", "emoji": "🏫", "category": "juniorHigh", "words": [ ... ] } ],
  "words": [ { "headword": "apple", "partOfSpeech": "noun", "meaning": "りんご", "phonetic": "/ˈæpl/", "exampleEn": "...", "exampleJa": "..." } ],
  "reviews": [ { "headword": "apple", "partOfSpeech": "noun", "repetition": 3, "intervalDays": 16.0, "easeFactor": 2.6, "dueAt": "..." } ],
  "logs": [ ... ],
  "dailyStats": [ ... ],
  "achievements": [ ... ]
}
```

- 単語の参照は数値 id ではなく `headword` + `partOfSpeech` で行う。別端末で id が一致しないため。
- インポートの「追加」は同じ `headword` + `partOfSpeech` があれば学習状態のみを新しい方（`lastReviewedAt` が後）で更新する。
- CSV エクスポート（FR-52）は単語帳単位で
  `headword,partOfSpeech,phonetic,meaning,exampleEn,exampleJa,level` の7列。学習状態は含まない。
  詳細は [06_features/export_import.md]。
