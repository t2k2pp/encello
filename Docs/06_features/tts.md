# 読み上げ（TTS）

対応要件: FR-47〜FR-50, NFR-04
実装: `domain/services/tts_service.dart`（抽象）, `data/services/flutter_tts_service.dart`,
`providers/tts_capability.dart`

## 1. 抽象インターフェース

```dart
enum TtsLang { en, ja }

class TtsVoice {
  final String name;    // 端末が返す voice 名
  final String locale;  // en-US / en-GB / ja-JP
}

class TtsCapability {
  final List<TtsVoice> enVoices;
  final List<TtsVoice> jaVoices;
  bool get hasEn => enVoices.isNotEmpty;
  bool get hasJa => jaVoices.isNotEmpty;
}

abstract class TtsService {
  Future<TtsCapability> capability();
  /// 読み上げ完了まで待つ。voice が無い言語では TtsUnavailableException を投げる。
  /// 再生中に別の speak が来たら、前の再生を止めてから新しい再生を始める。
  Future<void> speak(String text, TtsLang lang);
  Future<void> stop();
  Future<void> setRate(double rate);
  Future<void> setPitch(double pitch);
  Future<void> setVoice(TtsLang lang, String voiceName);
}
```

`flutter_tts` の `setCompletionHandler` / `setErrorHandler` を `Completer` に橋渡しし、
`speak()` を「完了まで待つ Future」にする。フラッシュカードの送り（[flashcard_mode.md] §2）が
この完了を契機にするため、awaitable であることが前提になる。

## 2. 起動時の能力取得

- 起動をブロックしない。ホーム表示後に `capability()` を非同期で呼ぶ（[02_architecture.md] §4）。
- 結果は `ttsCapabilityProvider`（`FutureProvider<TtsCapability>`）に載せる。
- 取得できるまでの間、読み上げボタンとリスニングモードは**表示しない**。
  判明した時点で現れる。押しても鳴らないボタンを先に出さない。

## 3. 言語と voice の選択

| 言語 | ロケール候補 | 設定 |
|---|---|---|
| 英語 | `en-US`（既定）/ `en-GB` / その他 `en-*` | 設定 > 学習「英語の音声」 |
| 日本語 | `ja-JP` | 設定 > 学習「日本語の音声」 |

- 選択肢には**端末に実在する voice だけ**を並べる（FR-49）。
  `en-GB` の voice が無い端末に「イギリス英語」を出さない。
- 設定値（`tts.enVoice` / `tts.jaVoice`）が空のときは端末既定を使う。
- 保存済みの voice 名が端末に存在しなくなった場合（OS の音声データが削除された等）は、
  **勝手に別の voice へ切り替えない**。設定画面に「選択中の音声が見つかりません」と表示し、
  選び直させる。読み上げは `TtsUnavailableException` にする。
- 速度 `tts.rate`（0.3〜0.7、既定 0.5）とピッチ `tts.pitch`（0.8〜1.2、既定 1.0）を
  スライダで設定し、その場で試聴できる（`This is a sample.` / `これはサンプルです。`）。

## 4. 音声が使えないときの扱い

| 状況 | UI |
|---|---|
| 英語 voice が無い | リスニングモードのカード・選択肢を非表示。単語詳細と学習画面の英語 🔊 を非表示 |
| 日本語 voice が無い | 日本語の 🔊 とフラッシュカード `speakJa` を非表示 |
| 両方無い | 設定 > 学習の読み上げカードごと非表示にし、「この端末では音声読み上げを利用できません」の1行に置き換える |
| 再生が失敗した | SnackBar「読み上げに失敗しました: 理由」。自動送りは止める |

Android では Google 音声サービスの言語データが未ダウンロードだと voice が返らないことがある。
その場合は上記の1行に加えて「端末の設定 > 言語と入力 > 読み上げ から音声データを追加できます」と案内する。
アプリから OS 設定を開くところまでは行わない（機種差が大きく、確実に開ける保証がない）。

## 5. 発音記号は読み上げに使わない

`words.phonetic` は**表示専用**。読み上げには `headword` をそのまま渡す。
IPA を TTS に渡すと記号をそのまま読む端末があるため。

## 6. 同時再生の制御

- `speak()` は前の再生を止めてから始める。フラッシュカードで手動送りを連打しても音が重ならない。
- 画面を離れるとき（`dispose`）は必ず `stop()` する。
- 学習画面の外（辞書・詳細）での再生は、押すたびに前の再生を止めて鳴らし直す。

## 7. テスト観点

`test/fakes/fake_tts_service.dart` で全モードのテストを回す。

- `speak` の完了 Future が解決するまでフラッシュカードが進まない。
- voice が空の `TtsCapability` でリスニングモードと 🔊 が現れない。
- 保存済み voice 名が `capability()` に無いとき、別の voice に切り替わらず設定に警告が出る。
- `speak` を連続で呼ぶと前の再生に `stop` が入る。
- 画面破棄時に `stop` が呼ばれる。
