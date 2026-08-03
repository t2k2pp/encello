# 05. デザインシステム（Design System）

姉妹アプリ共通の規約は [../../Docs/STYLE_GUIDE.md]（正本）。本書は encello 固有の追加分だけを定める。
矛盾したら STYLE_GUIDE が優先する。

## 1. カラー

### 1.1 テーマ配色

共通6配色（`orange` / `yellow` / `green` / `blue` / `purple` / `pink`）をそのまま持つ。
encello の**既定は `pink`**（[STYLE_GUIDE §1.2] の既定表に追加済み）。

配色は**学習者ごと**に選ぶ（`profiles.palette`）。1台を家族で使うため、
画面の色がそのまま「いま誰の番か」の手がかりになる。
学習者を切り替えたときは、配色 id だけでなくプロファイル id もキーに含めて
ルートを作り直す（[06_features/profiles.md] §5）。

| トークン | pink の値 |
|---|---|
| `bg` | `#FDF5F8` |
| `card` | `#FFFFFF` |
| `ink` | `#4A2A38` |
| `ink2` | `#7C5866` |
| `ink3` | `#B89AA6` |
| `line` | `#F3E2EA` |
| `accent` | `#D86A93` |
| `accentSoft` | `#F7E3EC` |
| `accentDeep` | `#B84A73` |
| `chipBg` | `#F6E7EE` |

実装方式（`AppPalette` / `AppColors` の getter / `KeyedSubtree` での再描画）は [STYLE_GUIDE §1.2] のとおり。
**`AppColors` を参照する式に `const` を付けてはならない**（getter は定数式にならない）。

### 1.2 判定色（semantic・テーマ切替で変えない）

正誤のフィードバックはアプリの中核なので、配色を変えても意味が変わらないよう固定する。

| トークン | 値 | 白背景での文字 | 塗り＋白文字 | 用途 |
|---|---|---|---|---|
| `correct` | `#379B5C` | 3.5:1（**バッジ・アイコンのみ**） | 3.5:1 | 正解 |
| `correctText` | `#2A7746` | 5.3:1 | — | 正解の説明文 |
| `nearMissFill` | `#BE8C0E` | — | 3.0:1 | 「惜しい」帯の背景 |
| `nearMissText` | `#96700B` | 4.6:1 | — | 「惜しい」の文字 |
| `wrong` | `#C43A34` | 5.2:1 | 5.2:1 | 不正解 |
| `masteryTrack` | `#EDE7EA` | — | — | 習熟度リングの背景 |

- 本文サイズ（14px 以下）の文字には `correctText` / `nearMissText` / `wrong` を使う。
  `correct` と `nearMissFill` は塗りとアイコン、または18px以上の太字にだけ使う。
- **色だけで正誤を伝えない**。必ずアイコン（`check` / `error_outline` / `close`）と文言を添える。

### 1.3 習熟度色

| 習熟度 | 色 | 説明 |
|---|---|---|
| 未学習 | `line` | まだ一度も解いていない |
| 学習中 | `accent` | 出題間隔が短い |
| 定着 | `#7BA7D4` | 出題間隔が21日以上 |
| マスター | `correct` | 出題間隔が90日以上かつ直近が正解 |

「定着」は配色を変えても意味が変わらないよう semantic 側に置く。判定条件は
[06_features/srs_scheduler.md] §5。

### 1.4 単語帳の識別色

アクセント9色のパレットを持ち、`palette[colorSeed % 9]` で安定して割り当てる
（[STYLE_GUIDE §1.1]）。辞書一覧のサムネ背景に使う。

## 2. タイポグラフィ

- 日本語: **Noto Sans JP**（400/500/600/700/800 を `assets/google_fonts/` に静的同梱、
  `GoogleFonts.config.allowRuntimeFetching = false`、OFL を `LicenseRegistry` に登録）。
- **英単語の表示にはラテン用の等幅寄り書体を使わない**。Noto Sans JP のラテングリフをそのまま使う。
  書体を混ぜるとカードごとに行高が変わり、フラッシュカードの自動送りで文字位置が跳ねるため。
- `AppText` のスタイルは [STYLE_GUIDE §1.3] と同じ。encello 固有に次を足す。

| スタイル | 定義 | 用途 |
|---|---|---|
| `AppText.headword()` | 34 / w700 / letterSpacing 0.5 | 学習画面・単語詳細の英単語 |
| `AppText.phonetic()` | 14 / w400 / ink2 | 発音記号 |
| `AppText.prompt()` | 24 / w700 | スペルモードの和訳提示 |

- `headword` と `prompt` は `FittedBox(fit: BoxFit.scaleDown)` で包み、長い語でも1行に収める。

## 3. 共通部品（`ui/widgets/`）

### 3.1 姉妹アプリから移植するもの

`SoftCard` / `EmptyState` / `CenteredContent` / `SoftDropdown` / `SearchField` / `RoundedFab` /
`confirmDestructive` / `pickEmoji` / `DonutChart` は pricello の実装をそのまま移植する。

### 3.2 encello 固有の部品

| 部品 | 仕様 |
|---|---|
| `EnglishKeyboard` | アプリ内英字キーボード。QWERTY / ABC 配列。キーは最小 44×44、押下時 `Transform.scale(0.94)` ＋ `HapticFeedback.selectionClick()`。⌫ は長押しで連続削除。詳細は [06_features/spell_mode.md] §2 |
| `LetterTiles` | 綴り入力の文字タイル。入力済み = `ink` の文字＋下線 `accent`、未入力 = 下線 `line`。ヒント開示済みは `accentSoft` の背景。文字数が多いときは `Wrap` で折り返す（横スクロールにしない） |
| `WordThumb` | 辞書一覧のサムネ。見出し語の先頭1文字（大文字）＋ 単語帳色の背景 ＋ 習熟度リング（外周2.5px）。54px 正方、角丸 = size×0.24 |
| `MasteryBadge` | 習熟度のピル。色＋ラベル（未学習/学習中/定着/マスター）。色だけに頼らない |
| `ProgressRing` | 円形進捗（`CustomPainter`）。ホームの今日の進捗、結果画面の正解率 |
| `BarChart` | 直近30日の学習量（`CustomPainter`）。目標線を破線で重ねる。pricello の `PriceChart` と同じ描画作法 |
| `StreakFlame` | 🔥＋日数。0日のときは描画しない（灰色の炎を出さない） |
| `VerdictBanner` | 解答後のフィードバック帯。判定色の背景＋アイコン＋文言＋正解の綴り＋例文＋「次へ」 |
| `SpellDiffText` | 「惜しい」のときに入力と正解を並べ、異なる文字だけ `nearMissText` の太字で強調する |
| `WordbookChip` | 所属単語帳のピル。絵文字＋名前。`Wrap` で折り返す |
| `ProfileAvatar` | 学習者の絵文字＋識別色の丸。ホーム右上（36px）とプロファイルゲート（72px）で使う。名前を添えるかは呼び出し側で選ぶ |
| `WordPartsCard` | 語のつくりの分解表示。部品を横に並べ、下に意味、右に矢印と結論。部品は `InkWell` で SCR-16 へ |
| `WordFamilyCard` | 語族の表。品詞（固定幅）｜見出し語｜訳（ellipsis）｜習熟度ドット。現在の語は `accentSoft` 背景 |
| `BandProgressBar` | 語彙力測定の級帯ごとの到達率。ラベル＋10分割のバー＋パーセント＋概算語数 |
| `CountdownBar` | スピードモードの残り時間。高さ4の細いバー。色は `accent` から `wrong` へ補間しない（点滅・色変化で急かさない） |
| `ChoicePairCard` | 取り違えドリルの2択。横並びの大きなカード2枚。解答後に両方の訳と品詞を出す |
| `StreakCalendar` | 月カレンダー。達成日 `accent` / 学習したが未達 `accentSoft` / 未学習は無地。凡例つき |

### 3.3 `EnglishKeyboard` の寸法

- 高さは画面高の 30〜36%（`clamp`）。キー幅は `(利用可能幅 - 余白) / 10`。
- 3段（10 / 9 / 7+⌫）＋確定行。確定行は `FilledButton`「答え合わせ」で、幅いっぱい・高さ48。
- 文字が未入力のとき「答え合わせ」は無効化する。
- キーラベルは常に**小文字**で表示する（入力も小文字で保持し、判定時に正規化する）。
- 端末の文字拡大に追従させると10列が破綻するため、**キーラベルだけは `textScaler` を 1.0 に固定**し、
  代わりにキー高さを下限44dpで確保する。これは [STYLE_GUIDE §8]（端末の文字拡大を尊重する）からの
  意図的な逸脱で、キーボードのみに限る。

## 4. レイアウト

- 余白は `AppSpacing.of(context)`（standard / compact）を参照する。直値を書かない。
- 学習画面は `CenteredContent` を**使わない**（最大幅640に絞るとキーボードが中央に浮いて押しにくい）。
  代わりに横方向の最大幅を 720 とし、キーボードは画面幅いっぱいに置く。
  これは [STYLE_GUIDE §2] からの逸脱で、学習系4画面（SCR-03〜SCR-06）に限る。
- 一覧・設定・統計は [STYLE_GUIDE] どおり `CenteredContent`（640）。

## 5. アニメーション

| 対象 | 仕様 |
|---|---|
| キー押下 | 80ms / `Curves.easeOut` の `scale 0.94` |
| フィードバック帯 | 下から 200ms のスライドイン＋フェード |
| フラッシュカードの送り | 180ms のクロスフェード。カードを回転させない（連続表示で目が疲れるため） |
| 正解の演出 | チェックアイコンの 240ms スケールインのみ。紙吹雪・全画面エフェクトは使わない |
| ストリーク更新 | 結果画面で炎が1度だけ 400ms 拡大する |
| スピードモードの正誤 | 0.4秒の背景色フラッシュのみ。移動・拡大を伴う演出を入れない（連続50問で目が疲れる） |
| 残り時間バー | 線形に減る。残りが少なくなっても点滅・振動・色変化をさせない |
| 語彙力測定の送り | 送りのアニメーションを入れない。2〜3秒に1問なので、動きがあるとかえって遅く感じる |

`prefers-reduced-motion` に相当する `MediaQuery.disableAnimations` が true のときは、
上記をすべて即時表示に切り替える。

## 6. オーバーフロー規約

[STYLE_GUIDE §7] に従う。encello で特に崩れやすい箇所を明示する。

| 箇所 | 対策 |
|---|---|
| 長い見出し語（`internationalization` 等） | `AppText.headword()` を `FittedBox(scaleDown)` で包む |
| `LetterTiles` の文字数が多い | `Wrap` で折り返す。1行あたりの上限は幅から計算する |
| 長い和訳（「〜を…する；〜に…させる」） | 一覧では `maxLines: 2` + ellipsis、詳細では折り返して全部見せる |
| 4択の選択肢 | `SoftCard` 内で `maxLines: 3` + ellipsis。選択肢の高さを固定しない |
| 単語帳名が長い | チップは `Flexible` + ellipsis |
| キーボード | 幅 320dp でも 10 列が収まる（キー幅の下限を設けず、幅から等分する） |

検証は `test/widget/overflow_matrix_test.dart` で「幅 320/390/768 × textScaler 1.0/1.3/1.6」の
マトリクスを回し、`tester.takeException()` が null であることを確認する。
