# プリセット単語帳の作り方（作業手順）

設計は [Docs/06_features/wordbooks.md] §2〜§3。ここは**チャンクを1本書くときの手順書**。

## 置き場所

```
tool/wordbooks/
  allowed_example_words.txt      例文に出てよい語（見出し語に入れないと決めたものだけ）
  src/<presetId>/
    _book.json                   単語帳のメタと、収録するチャンクの列挙
    NN_<slug>.json               チャンク1本（分野ごと）
assets/wordbooks/<presetId>.json ビルドの出力。手で編集しない
```

出力アセットは `dart run tool/build_wordbooks.dart` が作る。
**`assets/wordbooks/*.json` を直接編集しない**（次のビルドで消える）。

## チャンク1本を書く手順

1. すでに入っている見出し語を見る。

   ```
   dart run tool/build_wordbooks.dart --book jhs_v1 --list-headwords
   ```

2. `tool/wordbooks/src/<presetId>/NN_<slug>.json` を書く。

   ```json
   {
     "chunk": "05_school",
     "note": "学校と勉強",
     "words": [
       {
         "headword": "teacher",
         "partOfSpeech": "noun",
         "phonetic": "/ˈtiːtʃər/",
         "meaning": "先生；教師",
         "exampleEn": "Our new teacher is very kind.",
         "exampleJa": "私たちの新しい先生はとても親切です。",
         "level": 1
       }
     ]
   }
   ```

   - `chunk` はファイル名（拡張子なし）と一致させる。
   - **`presetId` は書かない**。ビルドが `<presetId>:<headword>:<partOfSpeech>` を付ける。
   - ここに挙げた7項目以外は書かない（知らない項目はエラーになる）。

3. `_book.json` の `chunks` の末尾にチャンク名を足す。

4. 検証する。**エラーが0になるまで直す**。

   ```
   dart run tool/build_wordbooks.dart --check --book jhs_v1 --warnings
   ```

## 収録する語の範囲（最優先）

`jhs_v1` は**中学校で学ぶ語彙**の単語帳。検定教科書と高校入試で実際に出る語だけを入れる。
**指定の語数に届かないことより、範囲外の語が混ざることの方が悪い。**
届かなければ、埋めずにその旨を報告する。

| | 例 |
|---|---|
| 入れる | `arrive` `decide` `improve` `international` `environment` |
| 入れない | `obtain` `maintain` `occur` `donate` `wander` `crawl` `settle`（高校以降の語） |

- `level` の 3 は「中3〜高校入試の発展」であって「高校の語」ではない。
  **level 3 がそのチャンクの半分を超えたら、範囲外の語を入れている疑いがある。**
- 迷ったら入れない。「中学生がこの語を教科書で見るか」で判断する。

## 書くときの規則

| 項目 | 規則 |
|---|---|
| `headword` | 小文字。語間は半角スペース1つ。使える文字は `a-z` とスペース・`-`・`'` |
| `partOfSpeech` | `noun` `verb` `adjective` `adverb` `preposition` `conjunction` `pronoun` `interjection` `phrase`。**1レコード1品詞**。同綴異品詞は別レコードにする |
| 複数語の見出し語 | 品詞は `phrase`、`phonetic` は空文字 |
| `meaning` | その品詞で最も使われる語義から最大3つ。区切りは**全角の `；`**。半角 `;` は不可 |
| `phonetic` | IPA を `/` で囲む。米音を既定にする。**確信が持てない語は空文字**（推測で書かない） |
| `exampleEn` | 10語以内。見出し語をその文で使う。`. ! ?` で終える。その語のレベルで読める語彙だけで書く |
| `exampleJa` | 直訳ではない自然な日本語。`。！？` で終える。例文があるなら必ず対で用意する |
| `level` | 1〜3（1=中1相当 / 2=中2相当 / 3=中3〜発展） |

- 例文と発音記号は空を許す。**全語に無理やり付けない**。ただし例文と和訳は必ず対にする。
- 例文は語ごとに違う文にする（同じ文の使い回しはエラー）。
- 語数を埋めるために、その分野に無い語や品質の怪しい訳を入れない。

## 警告の扱い

エラーは0にする。警告は種類によって扱いが違う。

| 警告 | 扱い |
|---|---|
| 例文に単語帳の外の語があります | 後のチャンクでその語が入れば消える。中学レベルを超える語なら例文を書き直す |
| 例文に見出し語が見当たりません | 不規則活用（`spend` → `spent`）なら残してよい。それ以外は書き直す |
| 例文が N 語です | 10語を少し超える程度は残してよい。13語以上はエラー |
| 発音記号がありません | 意図して空にしたなら残す |
