# 11. リリース手順クイックリファレンス（Android / iOS）

ストア提出までにやることの実務チェックリスト。機能評価・QA は別途（本書のスコープ外）。
プラットフォーム設定の詳細は [08_platform_setup](08_platform_setup.md)、
ライセンス遵守は [10_oss_licenses](10_oss_licenses.md)、
掲載文は [12_store_listing](12_store_listing.md) を参照。

## 0. 両OS共通（先にやる）

| # | 項目 | 状態 / メモ |
|---|---|---|
| C-1 | プライバシーポリシーの作成と公開URL | 原本は `PRIVACY_POLICY.md`、アプリ内表示は 設定 > 情報 > プライバシーポリシー（対応済み）。**公開URLはまだ無い**。提出フォームは URL を必須とするため、GitHub Pages 等でホスティングすること。改定時は原本・アプリ内表示・公開サイトの3点を同時に更新する |
| C-2 | OSSライセンス表示画面 | ✅ 対応済み（設定 > 情報 > オープンソースライセンス。[10_oss_licenses](10_oss_licenses.md) §6） |
| C-3 | 外部サービスの利用規約 | **該当なし**。通信先が1つも無く、Android は `INTERNET` 権限も宣言していない（[10_oss_licenses](10_oss_licenses.md) §5） |
| C-4 | バージョン設定 | `pubspec.yaml` の `version: 1.0.0+1`（`+n` が Android versionCode / iOS build number になる。提出のたびに +n を増やす）。`lib/core/utils/app_version.dart` の `kAppVersion` と**対で更新する**（[08](08_platform_setup.md) §6） |
| C-5 | アプリ名・ID の最終確認 | 表示名「encello」/ ID `com.encello.encello`。**一度公開すると変更不可**。商標・同名アプリの事前検索を推奨 |
| C-6 | ストア素材 | アイコン（済: `tool/build_brand_images.dart` → `flutter_launcher_icons`）、スプラッシュ（済）、スクリーンショット（下記各OS）、説明文（原稿済み: [12_store_listing](12_store_listing.md)）、サポート連絡先（`AppInfo.supportEmail`） |
| C-7 | `flutter analyze` 無警告・全テストパス | ロードマップのマイルストーン完了条件と同じ。統合テストは `flutter test -d flutter-tester integration_test/study_flow_test.dart`（[07](07_testing_strategy.md) §5.1） |
| C-8 | リリースビルドでの実機スモーク | debug と release で挙動が変わりやすい箇所: TTS（voice 列挙）、通知の予約、音声パック ZIP の展開、共有インテントの受信 |

## 1. Android（Google Play）

### ビルド準備

| # | 項目 | 状態 / コマンド・メモ |
|---|---|---|
| A-1 | **リリース署名鍵の作成** | **未**（現状 release が debug 署名のまま）。`keytool -genkey -v -keystore encello-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`。**鍵とパスワードは絶対に紛失・コミットしない**（`key.properties` を gitignore） |
| A-2 | signingConfig の設定 | `android/key.properties` → `app/build.gradle.kts` に `signingConfigs.release` を追加し `buildTypes.release` から参照（Flutter 公式ドキュメントの定型） |
| A-3 | Play アプリ署名 | Console 側で有効化（推奨・既定）。A-1 の鍵は「アップロード鍵」になり、紛失時もリセット申請可能 |
| A-4 | compileSdk / targetSdk | `compileSdk = 37` に固定（`receive_sharing_intent` 1.9.0 の AAR メタデータが要求。[08](08_platform_setup.md)）。`targetSdk` は Flutter 既定。**Play 要件（毎年8月更新）を提出時に再確認** |
| A-5 | minSdk | 26。`flutter_local_notifications` 22 と Java 8+ API desugaring の前提 |
| A-6 | リリースビルド | `flutter build appbundle --release`（AAB 必須。APK は提出不可） |
| A-7 | R8 縮小後の動作確認 | release ビルドで TTS・通知・ZIP 展開・共有受信を一通り。keep ルール不足はここで発覚する |
| A-8 | 権限の申告 | 宣言しているのは `POST_NOTIFICATIONS` のみ。`SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM` / `INTERNET` は宣言しない（[08](08_platform_setup.md) §2.1）。**依存が勝手に足していないか、マージ後のマニフェストを確認する** |

### Play Console

| # | 項目 | メモ |
|---|---|---|
| A-9 | デベロッパー登録 | $25（買い切り・初回のみ）。本人確認あり（数日みる） |
| A-10 | **個人アカウントのテスト要件** | 2023/11/13 以降に作成した個人アカウントは、**製品版公開の前にクローズドテストでテスター12人以上を14日間継続**が必須。**リリース日程に直結するため最初に確認**（法人アカウントは対象外） |
| A-11 | ストア掲載情報 | タイトル≤30字 / 短い説明≤80字 / 詳細≤4000字 / スクリーンショット（スマホ最低2枚、あればタブレット）/ フィーチャーグラフィック 1024×500 |
| A-12 | コンテンツレーティング | 質問票に回答（全年齢想定。暴力・性表現・課金・UGC いずれも無し） |
| A-13 | **データセーフティフォーム** | **「収集なし・共有なし」で申告できる**。全データ端末内保存で、通信先が1つも無い。読み上げは OS のエンジンへ文字列を渡すだけで端末外へ出ない。生成AI 連携はクリップボード経由でアプリ自身は通信しない（[10_oss_licenses](10_oss_licenses.md) §3・§5） |
| A-14 | 広告の有無申告 | 「広告なし」（[00_overview](00_overview.md) の Non-Goals） |
| A-15 | 公開フロー | 内部テスト（即時）→ クローズド（A-10 の14日）→ 製品版。審査は通常数時間〜数日 |

## 2. iOS / iPadOS（App Store）

### ビルド準備（Mac 必須）

| # | 項目 | メモ |
|---|---|---|
| I-1 | Apple Developer Program | 年額 $99（約1.5万円）。登録に1〜2日 |
| I-2 | Bundle ID 登録・署名 | Xcode の Automatically manage signing で可。Bundle ID は C-5 と一致させる |
| I-3 | **共有 Extension の追加** | **未**。Android 側と Dart 側は実装済みだが、iOS は Xcode で Share Extension ターゲットを追加し、本体と Extension に同じ App Group を設定しないと他アプリからの共有を受け取れない（[08](08_platform_setup.md) §3.2）。**追加しない場合は、掲載文から共有受信の記述を落とす** |
| I-4 | 輸出コンプライアンス | 暗号を使わない → `ITSAppUsesNonExemptEncryption = false` を Info.plist に追加しておくと毎回の質問をスキップできる |
| I-5 | プライバシーマニフェスト | 2024/5 以降必須。各プラグインが `PrivacyInfo.xcprivacy` を同梱する（lock の版は対応済み世代）。**Xcode の Archive 時に警告が出ないことを確認** |
| I-6 | サイレントスイッチ | `main.dart` で `AVAudioSession` を `playback` + `mixWithOthers` に設定済み（[08](08_platform_setup.md) §3.1）。**実機で消音スイッチ ON でも鳴ることを確認する**（自動テストでは担保できない。[07](07_testing_strategy.md) §6） |
| I-7 | ビルド | Mac で `flutter build ipa` → Xcode Organizer か Transporter でアップロード |
| I-8 | iPad レイアウト確認 | ユニバーサル配布のため iPad スクリーンショット・回転・Split View の確認が審査対象（`CenteredContent` 対応済み） |

### App Store Connect

| # | 項目 | メモ |
|---|---|---|
| I-9 | App 作成・メタデータ | 名前≤30字 / サブタイトル≤30字 / キーワード≤100字 / 説明 / サポートURL / プライバシーポリシーURL（C-1） |
| I-10 | スクリーンショット | iPhone 6.9" または 6.5"（必須）＋ **iPad 13"（ユニバーサルのため必須）** |
| I-11 | App プライバシー質問 | 「データを収集しない（Data Not Collected）」で申告できる（A-13 と同じ整理）。プライバシーポリシーと矛盾させないこと |
| I-12 | 年齢制限 | 質問票回答（4+ 想定） |
| I-13 | TestFlight | 内部テスター（審査なし・即時）→ 必要なら外部テスト（簡易審査） |
| I-14 | 審査提出 | 通常1〜3日。リジェクト時は Resolution Center で対話 |

## 3. リリース直前の最終チェック（両OS）

- [ ] 初回起動が**プロファイルゲート**から始まり、学習者0人の状態が案内になっていること
      （ストア審査員が最初に見る画面）
- [ ] サンプルデータが**初期状態で入っていない**こと。プリセット単語帳は入るが、
      学習記録・マイ単語は空であること
- [ ] 空状態の各画面が「次に何をすべきか」を示していること
- [ ] **機内モードで起動・学習・辞書がすべて動く**こと（NFR-04。TTS は端末の音声に依存）
- [ ] 通知権限を**拒否**した状態で、リマインダー以外が普通に使えること
- [ ] エクスポート → 新規インストール → インポートのラウンドトリップ（端末移行シナリオ）
- [ ] 学習画面で OS の IME が一度も出ないこと（Android / iOS 各1台。[07](07_testing_strategy.md) §6）
- [ ] フラッシュカードの自動送り中に画面が消灯しないこと（NFR-10）
- [ ] `version` の build 番号を上げたか（C-4）
- [ ] アイコン・スプラッシュを描き直したなら `flutter test tool/build_brand_images.dart` →
      `dart run flutter_launcher_icons` を実行済みか（[08](08_platform_setup.md) §5.2）

## 4. 提出後に備えるもの

- クラッシュ・ANR の監視: Play Console / App Store Connect の標準メトリクスをまず使う。
  Crashlytics 等の導入は「外部送信なし」方針とのトレードオフになるため、
  入れるならプライバシーポリシー改訂とセットで判断する
- 問い合わせ対応窓口（`AppInfo.supportEmail`）とストアレビューへの返信運用
- 更新サイクル: Play の targetSdk 要件（毎年8月）と iOS SDK 要件（毎年春）で
  年1回は必ずビルド更新が必要
- 単語帳データの訂正: 訳・例文の誤りが報告されたら
  `tool/wordbooks/src/` を直して `dart run tool/build_wordbooks.dart`、
  `seedVersion` を上げてアプリ更新で配る（差分適用されるため、
  ユーザーの編集は保護される。[06_features/wordbooks.md] §3.1）
