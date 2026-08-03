# 発音の再生と音声パック（Pronunciation & Audio Packs）

対応要件: FR-98〜FR-104
実装: `domain/services/pronunciation_service.dart`（抽象）,
`data/services/audio_pronunciation_service.dart`, `data/services/audio_pack_importer.dart`

## 1. 音源は2つある

| 音源 | 中身 | 長所 | 短所 |
|---|---|---|---|
| 音声ファイル | 実際の発音を録音した音声（音声パック） | 発音・アクセント・リズムが正確。学習の見本になる | 語ごとにファイルが要る。容量を食う |
| 音声合成（TTS） | 端末の TTS エンジン | どの語でも鳴る。容量ゼロ | 語によって不自然になる。端末差が大きい |

**音声ファイルがある語はそれを使い、無い語は音声合成で読む。**
両方ある語をどちらで鳴らすかは設定で選ぶ。

これは失敗を隠すための切り替えではなく、**音源の優先順位という設計**にする。
そのため、いま何で鳴っているかを必ず画面に示す（§5）。

## 2. 音源の解決

`PronunciationService` が音源を決める。

```dart
enum AudioSourceKind { audioFile, tts }

/// 解決結果。null = この語はこの言語で鳴らせない
AudioSourceKind? resolve(int wordId, SpeechLang lang);
```

`profiles.audioSource` の設定で順番が変わる。

| 設定 | 解決の順番 | ファイルも TTS も無いとき |
|---|---|---|
| `fileFirst`（既定） | 音声ファイル → TTS | 鳴らせない（ボタン非表示） |
| `ttsFirst` | TTS → 音声ファイル | 鳴らせない |
| `fileOnly` | 音声ファイルのみ | 鳴らせない。**TTS で代替しない** |
| `ttsOnly` | TTS のみ | 鳴らせない。音声ファイルがあっても使わない |

- `fileOnly` は「合成音声の発音を信用しない」人向け。
  この設定では音声ファイルの無い語の読み上げボタンを**非表示**にする。
  TTS でこっそり鳴らして「音声ファイルがある」ように見せない。
- `ttsOnly` は容量を空けるためではなく（ファイルは消えない）、
  端末の TTS の方が聞き取りやすいと判断した人のための選択肢。

### 2.1 例文の読み上げ

例文には音声ファイルを持たせない。**例文は常に TTS で読む**。
語の音声パックと同じ規模で例文を録音するのは現実的でないため。

読み上げボタンの音源バッジ（§5）で、語は 🎙 / 例文は 🔉 と表示が分かれる。

### 2.2 再生に失敗したときは切り替えない

**音源の解決は「有無」で行い、「失敗」では行わない。**

音声ファイルが存在するのに再生に失敗した（ファイルが壊れている、コーデックが読めない）場合、
TTS に切り替えずに失敗として扱う。SnackBar で
「音声ファイルを再生できませんでした: apple.mp3」と示し、フラッシュカードの自動送りは止める。

無言で別の音源に差し替えると、壊れたパックを入れたまま気付けない。
「無い」と「壊れている」は違う状態として扱う。

## 3. 音声パック

### 3.1 データ

`audio_packs`

| 列 | 型 | 説明 |
|---|---|---|
| `id` | int | PK |
| `packId` | text | 識別子。UNIQUE（例 `jhs_en_us_v1`） |
| `name` | text | 表示名（例「中学英単語 音声（米）」） |
| `source` | text | `bundled`（同梱）/ `imported`（取り込み） |
| `lang` | text | `en` / `ja` |
| `note` | text? | 説明・出典 |
| `entryCount` | int | 収録音声数 |
| `installedAt` | datetime | |
| `sortOrder` | int | 優先順位（同じ語が複数パックにあるとき上のものを使う） |

`word_audios`

| 列 | 型 | 説明 |
|---|---|---|
| `id` | int | PK |
| `wordId` | int | FK → `words.id`（cascade delete） |
| `packId` | int | FK → `audio_packs.id`（cascade delete） |
| `lang` | text | `en` / `ja` |
| `filePath` | text | `source = bundled` はアセットパス、`imported` は保存先の相対パス |

`UNIQUE(wordId, packId, lang)`。`(wordId, lang)` にインデックス（音源解決のたびに引くため）。

同じ語が複数のパックにある場合、`audio_packs.sortOrder` が小さいものを使う。
どのパックが使われたかは音源バッジの長押しで確認できる。

### 3.2 音声パックは学習者で共有する

`audio_packs` / `word_audios` に `profileId` を持たせない。
音声は単語の属性であって学習の記録ではないため、`words` と同じく全員で共有する。
ただし**どのパックを使うかの選択**（`profiles.audioPackIds`）と
音源の優先順位（`profiles.audioSource`）は学習者ごとに持つ。

### 3.3 保存先

| source | 場所 |
|---|---|
| `bundled` | `assets/audio/<packId>/` |
| `imported` | アプリ文書ディレクトリの `audio_packs/<packId>/` |

DB にはパスだけを持ち、音声そのものを入れない。
起動時に孤児ファイル（DB に対応する `word_audios` が無いファイル）を自動削除しない。
設定 > データの「使われていない音声ファイルを整理」で手動実行する。

## 4. 音声パックの取り込み

ZIP ファイルを `file_selector` で選ばせ、`archive` で展開する。

### 4.1 形式

```
jhs_en_us_v1.zip
├── manifest.json
└── audio/
    ├── apple_noun.mp3
    ├── run_verb.mp3
    └── ...
```

```json
{
  "packId": "jhs_en_us_v1",
  "name": "中学英単語 音声（米）",
  "lang": "en",
  "note": "自作の録音",
  "entries": [
    { "headword": "apple", "partOfSpeech": "noun", "file": "audio/apple_noun.mp3" },
    { "headword": "run", "file": "audio/run.mp3" }
  ]
}
```

- `partOfSpeech` は省略できる。省略時は**その見出し語の全品詞**に同じ音声を紐付ける。
  発音が品詞で変わる語（`record` 名詞/動詞）だけ品詞を書けばよい。
- 対応形式は **mp3 / m4a / wav / ogg**。それ以外の拡張子のエントリは取り込まない。

### 4.2 検証

取り込み前に全体を検証し、**致命的な問題があれば1件も取り込まない**。

| 検証 | 失敗時の表示 |
|---|---|
| ZIP として展開できる | 「ファイルを展開できません」 |
| `manifest.json` がある・解析できる | 「manifest.json が見つかりません」 |
| `packId` が既存と重複しない | 「同じ音声パックがすでに入っています。置き換えますか」（置換を選べる） |
| `entries` の `file` が ZIP 内に実在する | 「N件の音声ファイルが見つかりません」＋先頭10件 |
| 拡張子が対応形式 | 「対応していない形式です: xxx.flac」 |

`(headword, partOfSpeech)` に一致する単語が DB に無いエントリは**取り込まずに件数を報告する**
（「1,600件中 1,540件を取り込みました。60件は該当する単語がありませんでした」）。
音声のためだけに単語を作らない。

### 4.3 進捗と中断

数千ファイルの展開は時間がかかる。進捗ダイアログ（件数と割合）を出し、中断できるようにする。
中断したら展開済みのファイルを消し、DB にも書かない。半分だけ入ったパックを残さない。

## 5. 音源の表示

読み上げボタンの右下に小さなバッジを重ねる。

| バッジ | 意味 |
|---|---|
| 🎙 | 音声ファイルで鳴る |
| 🔉 | 音声合成で鳴る |
| （バッジ無し・ボタン非表示） | 鳴らせない |

- 学習画面（正解後のフィードバック帯）、単語詳細、辞書一覧の再生ボタンに付ける。
- 長押しでツールチップに音源名を出す（「中学英単語 音声（米）」/「合成音声: Google 日本語」）。
- 音声パックが1つも入っていない場合はバッジを出さない（全部 🔉 になり、情報にならないため）。

## 6. 抽象インターフェース

```dart
enum SpeechLang { en, ja }

class SpokenResult {
  final AudioSourceKind kind;
  final String sourceName; // パック名 または voice 名
}

abstract class PronunciationService {
  /// 鳴らせるか。null = 鳴らせない（ボタンを出さない）
  AudioSourceKind? resolve(int wordId, SpeechLang lang);

  /// 単語を鳴らす。完了 or 中断まで待つ。
  /// 鳴らせない場合は PronunciationUnavailableException。
  /// 再生に失敗した場合は PronunciationFailedException（別音源へ切り替えない）。
  Future<SpokenResult> speakWord(int wordId, SpeechLang lang);

  /// 例文などの任意テキスト。常に TTS。
  Future<SpokenResult> speakText(String text, SpeechLang lang);

  Future<void> stop();
}
```

- フラッシュカードの自動送り（[flashcard_mode.md] §2）は `speakWord` の完了を契機にする。
  音声ファイルでも TTS でも、**完了で解決する Future** であることが前提になる。
  `audioplayers` の `onPlayerComplete` と `flutter_tts` の `setCompletionHandler` を、
  それぞれ `Completer` に橋渡しして同じ形にする。
- 実装は `AudioPronunciationService` 1つ。内部で `AudioPlayer` と `TtsService` を持ち、
  §2 の順番で解決して呼び分ける。UI は音源を意識しない。
- `stop()` は両方を止める。

## 7. 設定（設定 > 学習）

音声カードを次の構成にする。

```
音声                                              (sectionTitle)
  単語の読み上げに使う音源を選べます。
  例文は常に合成音声で読み上げます。

  音源       [ 音声ファイル優先 | 合成音声優先 | 音声ファイルのみ | 合成音声のみ ]
                                                  ← SegmentedButton

  音声パック                                        3件 >   ← SCR-23 へ
    中学英単語 音声（米）      1,540語   [ ON ]
    日本語訳 音声              1,600語   [ ON ]

  ── 合成音声 ────────────────────────────
  英語の音声   [ Google US English ▾ ]
  日本語の音声 [ Google 日本語 ▾ ]
  速さ         ──────●───────
  高さ         ─────●────────
  [ 試聴 ]
```

- 音声パックが1つも入っていないとき、「音源」の SegmentedButton を出さない
  （選ぶ意味がない）。代わりに「音声パックを追加すると、録音された発音で学習できます」の1行を出す。
- 合成音声のセクションは、端末に voice が1つも無ければカードごと出さない（[tts.md] §4）。
- 音声パックも合成音声も無い場合、音声カード全体を出さず
  「この端末では音声を再生できません」の1行に置き換える。

## 8. 音声パック管理（SCR-23）

[STYLE_GUIDE §4.1] のマスタ管理画面の型。

- 行 = 🎙 サムネ ｜ 名前＋caption「英語 ・ 1,540語 ・ 12.4MB」｜ 使用の `Switch` ｜ 削除。
- 行を長押し（またはドラッグ）で優先順位を並べ替えられる。
- FAB = 「音声パックを取り込む」（ZIP を選ぶ）。
- 同梱パック（`source = bundled`）は削除できない。使用の ON/OFF だけできる。
- 削除は `confirmDestructive`。展開済みファイルも消えることと、解放される容量を明記する。

## 9. v1 で同梱する音声パック

v1 では**音声パックを同梱しない**。仕組みだけを実装し、取り込みで追加できる状態にする。

- 数千語の録音は、単語データの整備とは別に大きな作業になる。
- 品質の揃わない録音を混ぜるより、無い方がよい（合成音声で一貫して鳴る）。
- 同梱すると APK / IPA が数十MB 増え、初回ダウンロードの障壁になる。

同梱パックの追加は [09_roadmap.md] の v2 候補として残す。
それまでは、利用者が自分で用意した音声を取り込める。

## 10. テスト観点

- `fileFirst` で、音声ファイルのある語は `audioFile`、無い語は `tts` に解決される。
- `fileOnly` で、音声ファイルの無い語が `null`（ボタン非表示）に解決される。
- `ttsOnly` で、音声ファイルのある語も `tts` に解決される。
- 同じ語が2つのパックにあるとき、`sortOrder` の小さいパックが選ばれる。
- 音声ファイルの再生失敗で **TTS に切り替わらず**、例外になる。
- 再生失敗でフラッシュカードの自動送りが止まる。
- `speakWord` の完了 Future が、音声ファイル・TTS のどちらでも再生完了で解決する。
- `stop()` で `AudioPlayer` と `TtsService` の両方が止まる。
- ZIP 取り込み: manifest 欠落・ファイル欠落・非対応拡張子がそれぞれ正しい理由で弾かれる。
- `partOfSpeech` 省略のエントリが、その見出し語の全品詞に紐付く。
- 該当語の無いエントリが取り込まれず、件数が報告される。
- 取り込み中断で、展開済みファイルと DB の行が両方とも残らない。
- 音声パック削除で `word_audios` の行と実ファイルが消え、`words` は残る。
- 音声パックが0件のとき、設定に「音源」の SegmentedButton が現れない。
