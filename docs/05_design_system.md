# Encello - デザインシステム (Design System)

## 1. カラーパレット (Color Palette)

`pricello` に倣い、視認性が高くモダンで洗練されたカラーシステムを定義します。

### 1.1 プライマリ & アクセント
- **Primary Deep Dark**: `#0F172A` (Slate 900) - ダークモード背景
- **Primary Light**: `#F8FAFC` (Slate 50) - ライトモード背景
- **Accent Indigo / Electric**: `#6366F1` (Indigo 500) - メインブランドカラー・ボタン
- **Accent Purple**: `#8B5CF6` (Purple 500) - 進行状況グラデーション

### 1.2 セマンティックカラー (学習判定・ステータス)
- **Correct Green**: `#10B981` (Emerald 500) - 正解・マスター完了
- **Warning / Near Miss Yellow**: `#F59E0B` (Amber 500) - 惜しい・タイピング1文字違い
- **Incorrect Red**: `#EF4444` (Red 500) - 不正解・要復習
- **Info Cyan**: `#06B6D4` (Cyan 500) - ストーリー穴埋めハイライト

---

## 2. タイポグラフィ (Typography)

- **英語フォント**: `Outfit` または `Inter` (Google Fonts)
  - ディスプレイ・単語表示: `Outfit` (Bold / SemiBold)
  - 本文・例文: `Inter` (Regular / Medium)
- **日本語フォント**: `Noto Sans JP` (Google Fonts)

| スタイル名 | フォントサイズ | ウェイト | 用途 |
|---|---|---|---|
| `Display Large` | 32pt | Bold | 単語カードの英単語表示 |
| `Title Large` | 22pt | SemiBold | 画面タイトル・セクションヘッダー |
| `Title Medium` | 18pt | Medium | 日本語訳・プログレス表示 |
| `Body Large` | 16pt | Regular | 例文英語・ストーリー本文 |
| `Body Medium` | 14pt | Regular | 日本語訳例文・補足解説 |
| `Caption` | 12pt | Regular | 品詞バッジ・タイムスタンプ |

---

## 3. UIコンポーネント ガイドライン

### 3.1 カード (Cards)
- `BorderRadius`: 16px (角丸)
- `Elevations`: フラットデザイン + 微細なドロップシャドウ (`Color(0x0A000000)`, blurRadius: 10)
- `Glassmorphism`: 必要に応じて背景ぼかし (`BackdropFilter`) を適用

### 3.2 スペルキーボード (Interactive Keypad)
- キーボタンサイズ: 最小 44x44 dp (タッチターゲット確保)
- アニメーション: タップ時に `Transform.scale(0.95)` のフィードバック

### 3.3 プログレス & アニメーション
- クイズ回答時のカードフリップ (180度回転アニメーション 300ms)
- 正解時の紙吹雪 / スパークエフェクト (`CustomPainter` または `Lottie`)
