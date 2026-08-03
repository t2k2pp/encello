# スペルモードとアプリ内キーボード（Spell Mode）

対応要件: FR-15〜FR-20
実装: `ui/screens/spell_study_screen.dart`, `ui/widgets/english_keyboard.dart`,
`ui/widgets/letter_tiles.dart`, `domain/usecases/spell_judge.dart`

## 1. 出題

| 提示するもの | 提示しないもの |
|---|---|
| 日本語訳 | 英単語そのもの |
| 品詞バッジ | 発音記号（正解後に出す） |
| 文字数（`_` の数） | 例文（正解後に出す） |

- 文字数は最初から見せる。綴り学習では語長が手がかりの一部であり、
  伏せても「入力欄の幅」から推測できてしまうため隠す意味がない。
- ハイフンやスペースを含む語（`well-known`, `a lot of`）は、その記号を**最初から表示**し、
  ユーザーが入力するのは英字だけにする。記号の位置を当てさせても綴りの学習にならない。

## 2. アプリ内キーボード

### 2.1 OS のキーボードを使わない理由

`TextField` に `autocorrect: false` / `enableSuggestions: false` / `keyboardType: visiblePassword` を
指定しても、Android の一部 IME は変換候補バーを表示する。
`apple` の `app` まで入力した時点で候補に `apple` が出れば、この画面の目的は失われる。
OS の入力欄をまったく使わないことが、これを確実に防ぐ唯一の方法になる。

### 2.2 構造

`TextField` を使わず、次の3つで構成する。

```
StudySessionController
  └─ typed: String            ← 入力中の文字列（状態は Notifier が持つ）
       ├─ LetterTiles         ← 表示（読み取り専用）
       └─ EnglishKeyboard     ← 入力（onKey / onBackspace / onSubmit）
```

- フォーカスもテキスト選択もカーソルも無い。文字は常に末尾に追加され、⌫ で末尾から消える。
- 途中の文字を直す操作は用意しない。⌫ で戻して打ち直す。
  カーソル移動を入れるとキーボードが複雑になり、綴りを通しで打つ練習という目的から外れる。

### 2.3 配列

| 配列 | 段構成 |
|---|---|
| `qwerty`（既定） | `qwertyuiop` / `asdfghjkl` / `zxcvbnm` + ⌫ |
| `abc` | `abcdefghij` / `klmnopqrs` / `tuvwxyz` + ⌫ |

- 設定 > 学習 で切り替える（FR-17）。ABC 配列は QWERTY に慣れていない中学生向け。
- ハイフン・アポストロフィ・スペースのキーは置かない（§1 のとおりアプリ側が最初から表示する）。

### 2.4 寸法と操作

- 高さ = 画面高の 30〜36%（`clamp`）。キー幅 = `(幅 - 左右余白) / 10`、キー高さ下限 44dp。
- キーラベルは `MediaQuery.textScaler` を 1.0 に固定する（[05_design_system.md] §3.3）。
- 押下: 80ms の `scale 0.94` ＋ `HapticFeedback.selectionClick()`。
- ⌫ は長押しで 60ms 間隔の連続削除。0文字になったら止める。
- 物理キーボード（iPad の外付け等）からの入力も受け付ける。`Focus` + `KeyboardListener` で
  a–z / Backspace / Enter を拾い、同じ `onKey` へ流す。画面上のキーボードは表示したままにする。

### 2.5 補助操作

| ボタン | 挙動 |
|---|---|
| ヒント (n) | 未入力の先頭1文字を開示し、`typed` に追加する。`hintUsed` を +1。押すたびに1文字ずつ増える |
| わからない | 即座に grade 0 で確定し、正解を表示する |
| 答え合わせ | `typed` が空でないときだけ有効 |

ヒントで全文字を開示した場合も「答え合わせ」を押させる。自動確定しない
（打ち終えた感触を残すため、および誤操作での確定を防ぐため）。

## 3. 判定

`SpellJudge.judge(input, answer)` は純粋関数。

```dart
sealed class SpellVerdict {}
class Correct extends SpellVerdict {}
class NearMiss extends SpellVerdict { final List<int> diffIndexes; }
class Wrong extends SpellVerdict {}
```

### 3.1 正規化

判定前に両方へ同じ正規化をかける。

1. 前後の空白を除去
2. 小文字化
3. 連続する空白を1つにまとめる
4. Unicode のアポストロフィ（`’` U+2019）を ASCII の `'` に統一

アクセント記号（`café` の `é`）は**除去しない**。別の綴りとして扱う。

### 3.2 判定順

| 条件 | 結果 |
|---|---|
| 正規化後に完全一致 | `Correct` |
| レーベンシュタイン距離が 1 かつ 正解の長さが 4 以上 | `NearMiss` |
| それ以外 | `Wrong` |

- **`NearMiss` は不正解として扱う**（FR-19）。SM-2 の grade は 2 で、正解数には数えない。
  綴り学習アプリで綴り誤りを正解にすると目的が壊れる。
  「惜しい」は、打ち間違いなのか覚えていないのかをユーザーが区別するための表示にとどめる。
- 長さ 4 未満で距離1を `NearMiss` にしない（`cat` と `car` は別の語であり、惜しくない）。
- 寛容判定の設定は用意しない。

### 3.3 差分の見せ方

`SpellDiffText` が入力と正解を上下に並べ、`diffIndexes` の位置だけ `nearMissText` の太字にする。

```
あなた   a p l e
正解     a p p l e
             ^
```

## 4. 解答後のフィードバック

`VerdictBanner` が下からスライドインする。画面は遷移しない。

| 判定 | 背景 | 内容 |
|---|---|---|
| `Correct` | `correct` | ✓ ＋ `apple /ˈæpl/` ＋ 例文（英日） ＋ 「次へ」 |
| `NearMiss` | `nearMissFill` | ⚠ 「惜しい」 ＋ `SpellDiffText` ＋ 例文 ＋ 「次へ」 |
| `Wrong` | `wrong` | ✕ ＋ 正解の綴りと発音記号 ＋ 例文 ＋ 「次へ」 |

- 正解時は英単語を自動で読み上げる（FR-20）。`PronunciationService.speakWord()` を使うので、
  音声ファイルがあればそれで、無ければ合成音声で鳴る（[pronunciation.md] §2）。
  再生が失敗しても帯は出したままにし、SnackBar で失敗を示す（無音のまま成功したように見せない）。
- 「次へ」は自動では進まない。設定「正解したら自動で次へ」（既定 OFF）が ON のときだけ、
  `Correct` に限り 1.2 秒後に進む。`NearMiss` / `Wrong` は設定に関わらず必ずタップで進む
  （間違えた語ほど見る時間が要る）。

## 5. 記録

1問確定ごとに1トランザクションで次を書く（[02_architecture.md] §1.1）。

| テーブル | 内容 |
|---|---|
| `learning_logs` | mode=`spell`, direction=`jaToEn`, isCorrect, grade, answeredText=正規化前の入力, hintUsed, elapsedMs |
| `word_reviews` | `Sm2Scheduler.apply` の結果（`masteryLevel` も同時に更新） |
| `daily_stats` | `answeredCount` +1、正解なら `correctCount` +1、`xp` 加算、`goalMet` 判定 |
| `study_sessions` | `answeredCount` / `correctCount` / `xpEarned` の加算 |

`elapsedMs` は出題が描画された時刻から「答え合わせ」を押すまで。ヒントを押した時間も含める。

## 6. テスト観点

- 正規化: 大小差・前後空白・アポストロフィの差が `Correct` になる。`é` と `e` は `Correct` にならない。
- `NearMiss`: 距離1かつ長さ4以上でのみ成立。`cat`/`car` は `Wrong`。
- `diffIndexes` が挿入・削除・置換のそれぞれで正しい位置を指す。
- ヒントを押した回数だけ `typed` の先頭が埋まり、`hintUsed` が増える。
- 「答え合わせ」が空入力で無効。
- ⌫ の長押しで 0 文字になったら停止する。
- ウィジェットテスト: 学習画面のどの状態でも `EditableText` が1つも存在しない
  （OS キーボードが出ないことの回帰テスト）。
- ウィジェットテスト: 幅 320dp・textScaler 1.6 でキーボードが溢れない。
