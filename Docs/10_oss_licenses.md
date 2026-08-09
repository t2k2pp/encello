# 10. 使用OSS・ライセンス一覧（OSS Licenses）

リリース（ストア配布）に向けた、使用ライブラリのライセンス棚卸しと遵守事項のまとめ。
バージョンは `pubspec.lock` の解決値（2026-08 時点）。ライセンス本文は
各パッケージ同梱の LICENSE を確認済み。

## 結論（サマリ）

- **コピーレフト（GPL / LGPL / AGPL）系は直接依存に一切ない**。すべて
  MIT / BSD / Apache-2.0 のパーミッシブライセンスであり、**ソース公開義務・
  改変公開義務は発生しない**。商用・無償いずれの配布も可。
- パーミッシブライセンス共通の義務は「**著作権表示とライセンス本文の同梱（表示）**」。
  Flutter は Dart パッケージの LICENSE を `LicenseRegistry` に自動収集する。
  表示画面は **設定 > 情報 > オープンソースライセンス**（`showLicensePage`）で対応済み（§6）。
- 同梱フォント Noto Sans JP（OFL-1.1）は自動収集の対象外なので、
  `main.dart` で `LicenseRegistry.addLicense` に明示登録している（§4）。
- **通信先が1つも無い**ため、外部サービスの利用規約に起因する制約は存在しない（§5）。
  Android は `INTERNET` 権限自体を宣言していない。

## 1. 直接依存パッケージ（Dart / Flutter）

### アプリ本体に同梱されるもの（dependencies）

| パッケージ | 版 | ライセンス | 備考 |
|---|---|---|---|
| flutter_riverpod | 3.4.2 | MIT | |
| drift | 2.34.3 | MIT | SQLite 本体はパブリックドメイン |
| sqlite3 | 3.5.0 | MIT | build hooks で SQLite 本体を同梱（sqlite3_flutter_libs は EOL のため不使用） |
| path_provider | 2.1.6 | BSD-3-Clause | Flutter Authors |
| path | 1.9.1 | BSD-3-Clause | Dart Authors |
| flutter_tts | 4.2.5 | MIT | ラッパーのみ。音声合成エンジン本体は OS の機能（§3） |
| audioplayers | 6.8.1 | MIT | 音声パックの録音再生 |
| archive | 4.0.9 | MIT | 音声パック（ZIP）の展開 |
| flutter_local_notifications | 22.2.0 | BSD-3-Clause | 学習リマインダー |
| timezone | 0.11.1 | BSD-2-Clause | IANA タイムゾーンデータを同梱（データは public domain） |
| flutter_timezone | 5.1.0 | Apache-2.0 | 端末のタイムゾーン名の取得 |
| receive_sharing_intent | 1.9.0 | Apache-2.0 | 他アプリからの共有テキスト受信 |
| wakelock_plus | 1.7.0 | BSD-3-Clause | フラッシュカード自動送り中の消灯抑止（NFR-10） |
| google_fonts | 8.2.1 | BSD-3-Clause | 同梱フォント Noto Sans JP は OFL-1.1（§4）。ランタイム取得は無効化 |
| emoji_picker_flutter | 4.5.3 | MIT | |
| intl | 0.20.2 | BSD-3-Clause | Dart Authors |
| csv | 8.0.0 | MIT | 単語帳の CSV 入出力 |
| charset | 2.0.1 | Apache-2.0 | CSV の Shift_JIS デコード |
| share_plus | 13.3.0 | BSD-3-Clause | |
| file_selector | 1.1.0 | BSD-3-Clause | |
| shared_preferences | 2.5.5 | BSD-3-Clause | |
| uuid | 4.6.0 | MIT | セッション ID |
| meta | 1.18.0 | BSD-3-Clause | Dart Authors |
| characters | 1.4.1 | BSD-3-Clause | Dart Authors。絵文字1文字判定（surrogate pair） |
| cupertino_icons | 1.0.9 | MIT | |
| Flutter SDK / Dart SDK | 3.44 / 3.12 | BSD-3-Clause | エンジン（Skia 等）込みで `LicenseRegistry` に収集される |

### 開発時のみ（dev_dependencies — 配布物に含まれず表示義務なし）

`flutter_test` / `integration_test` / `flutter_lints` / `drift_dev` / `build_runner` /
`mocktail` / `flutter_launcher_icons`。いずれも MIT / BSD 系。
**アプリバイナリに含まれないため、アプリ内表記は不要**。

### 推移的依存

推移的依存（`http` / `collection` / `crypto` / `ffi` / `win32` など）も
pub.dev 掲載の MIT / BSD / Apache-2.0 系のみ。`LicenseRegistry` が自動収集する。

## 2. ネイティブ側に同梱されるもの

| 対象 | ライセンス | 備考 |
|---|---|---|
| SQLite | パブリックドメイン | `sqlite3` の build hooks が同梱 |
| IANA タイムゾーンデータ | パブリックドメイン | `timezone` パッケージが同梱 |

画像処理・地図・機械学習のような、独自の規約を持つネイティブ SDK は使っていない。

## 3. 音声合成エンジン（OS の機能）

読み上げは `flutter_tts` を通じて **OS の音声合成エンジン**を呼ぶ。
エンジン本体（Android の Google 音声サービス、iOS の AVSpeechSynthesizer 等）は
アプリに同梱されず、**本アプリの配布物には含まれない**。したがってライセンス表記の
対象外だが、次の点はプライバシーポリシーに明記している（`PRIVACY_POLICY.md`）。

- 読み上げる文字列（見出し語・和訳）はエンジンへ渡されるが、外部へは送信されない
- 音声データが未ダウンロードの場合の追加取得は OS の設定から行うもので、
  本アプリは関与しない

## 4. 同梱フォント（Noto Sans JP）

`assets/google_fonts/` に静的ウェイト（Regular / Medium / SemiBold / Bold / ExtraBold）と
`OFL.txt` を置いている。ライセンスは **SIL Open Font License 1.1**。

OFL は「フォントファイル単体の販売禁止」「予約フォント名の改変版への流用禁止」を課すが、
**アプリへの同梱・再配布は自由**で、義務はライセンス本文の同梱のみ。

Flutter の `LicenseRegistry` はアセットのライセンスを自動収集しないため、
`lib/main.dart` で `OFL.txt` を読み込んで明示登録している。
**フォントを差し替えたときはこの登録も更新すること。**

## 5. 通信先とその規約

**無し。** 本アプリはインターネット通信を行わない。

- フォントは同梱し、`GoogleFonts.config.allowRuntimeFetching = false` でランタイム取得を禁止（NFR-04）
- 読み上げは端末内で完結する（§3）
- 生成AI に単語帳を作ってもらう機能は、定型文をクリップボードへコピーするだけで、
  アプリ自身は AI サービスと通信しない（[06_features/ai_import.md]）
- Android の `AndroidManifest.xml` に `INTERNET` を宣言していない

このため、姉妹アプリ（pricello の地図タイル等）で必要だった「外部サービスの
利用ポリシー確認」に相当する項目は存在しない。

## 6. アプリ内のライセンス表示

**設定 > 情報 > オープンソースライセンス** で `showLicensePage` を開く
（`lib/ui/screens/settings_screen.dart`）。アプリ名とバージョンは `AppInfo` /
`kAppVersion` を渡す。

同じタブに **プライバシーポリシー**（`lib/ui/screens/privacy_policy_screen.dart`）を並べる。
原本は `PRIVACY_POLICY.md`。

## 7. 同梱コンテンツの権利

ライブラリとは別に、アセットとして同梱する**学習コンテンツ**の出所を明記しておく。

| アセット | 内容 | 権利関係 |
|---|---|---|
| `assets/wordbooks/` | プリセット単語帳6冊（延べ6,927語） | 見出し語の集合は事実の列挙。**訳語・例文・発音記号は本プロジェクトで用意したもの**で、既存の単語帳・辞書の記述は写していない（[06_features/wordbooks.md] §2） |
| `assets/word_parts.json` | 語の部品（接頭辞51 / 語根82 / 接尾辞30）と派生語ファミリー | 同上。語源の事実に基づき、説明文は本プロジェクトで書いたもの |
| `assets/pseudowords.json` | 語彙力測定の擬似語120語 | 本プロジェクトで生成。実在語でないことを同梱6冊＋プールとの突合でテストしている（[06_features/vocab_size_test.md] §4） |
| `assets/prompts/` | 生成AI への依頼文の定型文 | 本プロジェクトで作成 |

頻度リスト（NGSL 等）は**ライセンス種別が明示されていない**ため同梱していない。
`words.frequencyRank` は null のままとし、頻度順のソート項目自体を表示しない
（[03_data_model.md] §7、[09_roadmap.md] の v2 候補）。

## 8. 更新時の手順

依存を足す・上げるたびに次を行う（[08_platform_setup.md] §7）。

1. `flutter pub outdated` で差分を確認する
2. 新規依存は pub.dev のライセンス欄と同梱 LICENSE の**両方**を見る
3. コピーレフト（GPL / LGPL / AGPL）なら採用しない。採用せざるを得ないときは
   本書に理由と影響範囲を書く
4. 本書 §1 の表を更新する
5. アセット（フォント・コンテンツ）を足したときは §4 / §7 も更新する
