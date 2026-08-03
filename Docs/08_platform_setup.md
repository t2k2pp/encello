# 08. プラットフォーム設定（Platform Setup）

## 1. 共通

| 項目 | 値 |
|---|---|
| Flutter | 安定版 3.44 系 |
| Dart | 3.12（`environment: sdk: ^3.12.0`） |
| アプリID | `com.encello.encello` |
| プロジェクト生成 | `flutter create --org com.encello --platforms=android,ios encello` |

`flutter create` の直後に不要なプラットフォーム（web / linux / macos / windows）のディレクトリを消す。
対象外のプラットフォームを残すと、依存の互換性チェックで解決不能になることがある。

## 2. Android

| 項目 | 値 | 理由 |
|---|---|---|
| `minSdkVersion` | 26（Android 8.0） | `flutter_tts` の voice 選択 API と、対象端末の想定に合わせる |
| `targetSdkVersion` / `compileSdk` | 最新安定 | ストア要件 |
| `namespace` | `com.encello.encello` | |
| Kotlin / AGP | Flutter 同梱の既定 | |

### 2.1 パーミッション

| パーミッション | 用途 |
|---|---|
| `POST_NOTIFICATIONS` | 学習リマインダー（Android 13+）。実行時に求める |

これ以外は必要としない。カメラ・位置情報・マイク・ネットワークのいずれも使わない。
`AndroidManifest.xml` に `INTERNET` も書かない（フォントを同梱し、TTS も音声再生も端末内で完結するため）。

`SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM` は**宣言しない**。
リマインダーは inexact スケジュールで予約する（[06_features/reminders.md] §3）。

### 2.2 TTS

Android の TTS は `TextToSpeech` エンジン（多くは Google 音声サービス）に依存する。
言語データが未ダウンロードだと voice が返らない。この場合の扱いは
[06_features/tts.md] §4（機能を非表示にし、理由を表示する）。

`<queries>` に TTS エンジンの intent を宣言する。宣言が無いと Android 11 以降で
インストール済みエンジンを列挙できない。

```xml
<queries>
  <intent>
    <action android:name="android.intent.action.TTS_SERVICE" />
  </intent>
</queries>
```

### 2.3 共有シートの受信

`receive_sharing_intent` のため、`AndroidManifest.xml` の `MainActivity` に
`text/plain` の `ACTION_SEND` / `ACTION_SEND_MULTIPLE` の intent-filter を宣言する。
受け取ったテキストの扱いは [06_features/my_words.md] §4.2。

### 2.4 音声ファイルの再生

`audioplayers` はパーミッションを必要としない（ローカルファイルとアセットのみを再生する）。
音声パックの展開先はアプリ文書ディレクトリで、外部ストレージを使わない。

### 2.5 画面のスリープ

`wakelock_plus` はパーミッションを必要としない（`FLAG_KEEP_SCREEN_ON` を使う）。

### 2.6 署名

リリース署名は `android/key.properties`（**リポジトリに含めない**）から読む。
`android/app/build.gradle.kts` に `signingConfigs` を定義する。

## 3. iOS

| 項目 | 値 |
|---|---|
| Deployment Target | 13.0 |
| Bundle Identifier | `com.encello.encello` |

### 3.1 Info.plist と AVAudioSession

- 追加の usage description は不要（カメラ・マイク・位置情報を使わない）。
- **サイレントスイッチが ON でも音を鳴らす**ため、`AVAudioSession` のカテゴリを
  `playback` にする。学習中に「音が鳴らない」原因の大半がこれになる。
- 他アプリの音楽を止めないよう `mixWithOthers` を併用する。
- **設定するのは1か所にする**。`flutter_tts` の `setIosAudioCategory` と
  `audioplayers` の `AudioContextIOS` が同じ `AVAudioSession` を触るため、
  両方から別々の設定を投げると後勝ちで挙動が変わる。
  起動時に `audioplayers` の `AudioPlayer.global.setAudioContext` で
  `playback` + `mixWithOthers` を1度だけ設定し、`flutter_tts` 側では変更しない。
- 通知は `flutter_local_notifications` の `requestPermissions` で許可を求める
  （リマインダーを ON にしようとしたときのみ。[06_features/reminders.md] §4）。

### 3.2 共有シートの受信

`receive_sharing_intent` のため Share Extension を追加し、App Group を設定する。
テキスト（`public.plain-text`）だけを受け取り、それ以外の種別は宣言しない。

### 3.3 TTS

iOS は OS 標準の音声が常に入っているため、voice が0件になることは通常ない。
ただし「拡張」音声が未ダウンロードの場合があるので、能力取得の扱いは Android と同じにする。

## 4. フォントの同梱

`assets/google_fonts/` に Noto Sans JP の静的ウェイト（400/500/600/700/800）を置き、
`GoogleFonts.config.allowRuntimeFetching = false` にする（[05_design_system.md] §2）。
ファイル名は `NotoSansJP-Regular.ttf` のように `<Family>-<Weight>.ttf` の規約に合わせる。
同フォルダの `OFL.txt` を `LicenseRegistry` に登録する。

**使用するウェイトは必ず同梱する**。未同梱のウェイトを指定すると、
プラットフォーム既定のフォントで無言のうちに描画される。

## 5. アプリアイコン

`flutter_launcher_icons` で生成する。

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#FDF5F8"   # pink パレットの bg
  adaptive_icon_foreground: "assets/icon/app_icon.png"
  adaptive_icon_foreground_inset: 18
  remove_alpha_ios: true
  background_color_ios: "#FDF5F8"
```

## 6. バージョン文字列

`pubspec.yaml` の `version` と `lib/core/utils/app_version.dart` の定数を対で更新する。
エクスポートの `meta.appVersion` と設定 > 情報が同じ値を見る。

## 7. 依存の更新

作業のたびに `flutter pub outdated` を確認する。
バージョンを上げられない依存が出た場合は、理由と解除条件を本書の §8 に記録する。

## 8. バージョンを固定している依存

（現時点ではなし）
