# 08. プラットフォーム設定（Platform Setup）

## 1. 共通

| 項目 | 値 |
|---|---|
| Flutter | 安定版 3.44 系（実装時点 3.44.8） |
| Dart | 3.12（`environment: sdk: ^3.12.0`。実装時点 3.12.2） |
| アプリID | `com.encello.encello` |
| プロジェクト生成 | `flutter create --org com.encello --platforms=android,ios encello` |

`flutter create` の直後に不要なプラットフォーム（web / linux / macos / windows）のディレクトリを消す。
対象外のプラットフォームを残すと、依存の互換性チェックで解決不能になることがある。

## 2. Android

| 項目 | 値 | 理由 |
|---|---|---|
| `minSdkVersion` | 26（Android 8.0） | `flutter_tts` の voice 選択 API と、対象端末の想定に合わせる |
| `targetSdkVersion` | Flutter 既定（36） | ストア要件 |
| `compileSdk` | **37 に固定** | `receive_sharing_intent` 1.9.0 の AAR メタデータが `compileSdk >= 37` を要求する。API 37 はマイナーバージョン方式（`android-37.0`）配布のため AGP 9.1.1 以上が前提 |
| `namespace` | `com.encello.encello` | |
| AGP | 9.2.1（`android/settings.gradle.kts`） | `compileSdk 37` の前提。Kotlin は **AGP 9 の built-in Kotlin** でコンパイルし、KGP（`org.jetbrains.kotlin.android`）は適用しない |
| Gradle | 9.4.1（wrapper） | AGP 9.2.1 の前提 |

ビルド時に `emoji_picker_flutter` と `flutter_tts` が KGP を適用している旨の警告が出る
（Kotlin 2.2.10）。AGP 9 の built-in Kotlin と併存してビルドは通る。
上流が built-in Kotlin へ移行したら警告は消えるため、こちらでの対応は要らない。

### 2.0 Core library desugaring

`flutter_local_notifications` v22 は `java.time` 等の desugaring を要求する。
`android/app/build.gradle.kts` に次を置く。

```kotlin
compileOptions { isCoreLibraryDesugaringEnabled = true }
dependencies { coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") }
```

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
- 予約は `zonedSchedule` を使うため、端末のタイムゾーン名（IANA）が要る。
  `flutter_timezone` で OS から取り、`tz.setLocalLocation` に渡す。
  iOS/Android のどちらもプラグイン側で解決するので追加の設定は要らない。

### 3.2 共有シートの受信

`receive_sharing_intent` のため Share Extension を追加し、App Group を設定する。
テキスト（`public.plain-text`）だけを受け取り、それ以外の種別は宣言しない。

**未実施。リリース前に必要（M7-D 時点）。** Share Extension の追加・App Group の設定は
Xcode（`ios/Runner.xcodeproj`）が要る作業で、コード生成だけでは行えないため
このマイルストーンでは対応していない。Android 側（§2.3、`AndroidManifest.xml` の
intent-filter）と Dart 側の受信ロジック（[06_features/my_words.md] §4.2、
`shared_text_receiver.dart` / `shared_text_source_impl.dart`）は実装済みだが、
iOS では Xcode 側の設定が無いため他アプリからの共有を受け取れない。
iOS 版をリリースする前に、Xcode で Share Extension ターゲットを追加し、
本体アプリと Extension の両方に同じ App Group を設定すること。

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

## 5. アプリアイコンとスプラッシュ

### 5.1 図柄

綴りを打つ画面の文字タイル（`LetterTiles`）をそのまま図案にする。
開いた1枚のタイルに `e`、その右に未入力のタイルを2枚並べ、「これから綴る」状態を表す。
色は **pink パレット**（`AppColors` の `pinkPalette`）から取る。

### 5.2 原画の作り方

画像編集ソフトで作った PNG を置かない。**アプリと同じトークンから描き出す**。
配色を変えたときに画像だけ取り残されるのを防ぐため。

```
flutter test tool/build_brand_images.dart   # 原画とスプラッシュのロゴを描き出す
dart run flutter_launcher_icons             # ランチャーアイコンの各解像度を生成する
```

`tool/build_brand_images.dart` は Flutter のレンダラで描くため `flutter test` の上で走る。
テスト本体ではないので `test/` ではなく `tool/` に置く
（`flutter test` の既定の走査対象は `test/` なので、通常のテスト実行では拾われない）。

書き出す先:

| 用途 | 出力先 |
|---|---|
| アイコン原画 1024×1024 | `assets/icon/app_icon.png` |
| Android スプラッシュのロゴ | `android/app/src/main/res/drawable-{m,h,x,xx,xxx}dpi/splash_logo.png` |
| iOS スプラッシュのロゴ | `ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage{,@2x,@3x}.png` |

スプラッシュのロゴは**背景を塗らずに**描く（背景はネイティブ側が塗る。
両方で塗ると濃さのわずかな差が四角く見える）。
Android のレイヤーリストの `bitmap` は密度ごとの実寸で描かれるため、1枚では足りず
密度バケットごとに書き出す。

### 5.3 ランチャーアイコンの設定

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

前景に原画（背景ごと）を渡すのは意図的。`adaptive_icon_background` と原画の背景が
同じ `#FDF5F8` なので、18% の内寄せをしても継ぎ目が出ない。

`flutter_launcher_icons` は `android/app/src/main/res/values/colors.xml` に
`ic_launcher_background` を書き込む。同じファイルに置いた `splash_background`（§5.4）は
再生成しても消えないが、**実行後に colors.xml を確認すること**。

### 5.4 スプラッシュ

Flutter の最初のフレーム（`BootstrapGate`）が出るまでの間に表示される。
既定の白のままだと、白 → pink の切り替わりが見えてしまうので、
**ネイティブ側の背景を `BootstrapGate` と同じ `#FDF5F8` に揃える**。

| プラットフォーム | 触るファイル |
|---|---|
| Android | `res/values/colors.xml` の `splash_background`、`res/drawable/launch_background.xml` と `res/drawable-v21/launch_background.xml` |
| iOS | `ios/Runner/Base.lproj/LaunchScreen.storyboard` の `backgroundColor` と `<image>` の実寸宣言 |

`values-night/styles.xml` も同じ `@drawable/launch_background` を指す。
アプリはライトテーマ1本（[05_design_system.md]）なので、
端末のダークモードでも同じ pink の背景でよい。

iOS の storyboard は `<resources>` に `LaunchImage` の実寸を宣言している。
**ロゴの寸法を変えたらここも直す**（1x の画素数を書く。現在は 200×86）。

## 6. バージョン文字列

`pubspec.yaml` の `version` と `lib/core/utils/app_version.dart` の定数を対で更新する。
エクスポートの `meta.appVersion` と設定 > 情報が同じ値を見る。

## 7. 依存の更新

作業のたびに `flutter pub outdated` を確認する。
バージョンを上げられない依存が出た場合は、理由と解除条件を本書の §8 に記録する。

## 8. バージョンを固定している依存

| 依存 | 採用版 | 最新 | 理由 | 解除条件 |
|---|---|---|---|---|
| `drift_dev` | ^2.34.0 | 2.34.5 | 2.34.1+1 以降は `analyzer` の下限が上がり、`flutter_riverpod` 3 が**通常依存**に持つ `test` パッケージの analyzer 上限と衝突して解決できない（姉妹アプリ4本でも同じ上限を実測） | riverpod が `test` を dev 依存へ移すか、Flutter SDK の analyzer が上がったとき |
| `build_runner` | ^2.4.13（解決 2.15.1） | 2.16.0 | Flutter SDK が `meta 1.18.0` を pin しているため 2.15.1 が上限 | Flutter SDK の `meta` が 1.19 以上になったとき |
| `intl` | ^0.20.2 | 0.20.3 | `flutter_localizations` が `intl 0.20.2` を pin している | Flutter SDK 側の pin が上がったとき |
| `timezone` | ^0.11.0 | 0.11.x | `flutter_local_notifications` 22 が `timezone ^0.11.0` を要求する（設計当初の 0.10 系では解決できない） | — （最新に追従済み） |

上記以外の直接依存は、実装時点（2026-08-04）で最新安定版に揃っている。
