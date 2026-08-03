# 間隔反復と出題キュー（SRS Scheduler）

対応要件: FR-11, FR-12, FR-30〜FR-34
実装: `domain/usecases/sm2_scheduler.dart`, `domain/usecases/study_queue_builder.dart`

## 1. 値オブジェクト

```dart
// domain/entities/review_state.dart
class ReviewState {
  final int repetition;      // 連続正解回数 n
  final double intervalDays; // 現在の出題間隔 I
  final double easeFactor;   // 容易度係数 EF（下限 1.3）
  final DateTime? dueAt;
  final int lapses;
  final int correctStreak;
  final int totalCorrect;
  final int totalIncorrect;
  final DateTime? firstLearnedAt;
  final DateTime? lastReviewedAt;

  static const initial = ReviewState(
    repetition: 0, intervalDays: 0, easeFactor: 2.5, dueAt: null,
    lapses: 0, correctStreak: 0, totalCorrect: 0, totalIncorrect: 0,
    firstLearnedAt: null, lastReviewedAt: null,
  );
}
```

`Sm2Scheduler` は `ReviewState` と grade と解答時刻を受け取り、新しい `ReviewState` を返す純粋関数。
Drift にも Flutter にも依存しない。

## 2. grade の決め方

SM-2 の grade（0〜5）を、モードごとに次の表で決める。判定は `domain/usecases/grade_resolver.dart`。

| モード | 条件 | grade |
|---|---|---|
| spell / listening | 正解 かつ 所要時間が速い | 5 |
| spell / listening | 正解 | 4 |
| spell / listening | 正解 だが ヒントを使った | 3 |
| spell / listening | 惜しい（編集距離1） | 2 |
| spell / listening | 不正解 | 1 |
| spell / listening | 「わからない」を押した | 0 |
| choice | 正解 かつ 所要時間が速い | 4 |
| choice | 正解 | 4 |
| choice | 不正解 | 1 |
| flashcard | 「覚えた」 | 4 |
| flashcard | 「あやしい」 | 2 |
| flashcard | 何も押さずに送った | 更新しない |
| speed | 時間内に正解 | 4 |
| speed | **時間切れ** | 更新しない（「知らない」ではなく「遅い」） |
| speed | 時間内に誤答 | 1 |
| parts | 正解 / 不正解 | 4 / 1（`part_reviews` を更新する） |
| parts（推測問題） | 正解 / 不正解 | 更新しない（[word_parts.md] §6） |
| family | スペルモードと同じ | 答えた語の `word_reviews` だけを更新する |
| confusion | 正解 | 出題した語のみ 4 |
| confusion | 不正解 | **両方の語**を 1（[confusion_drill.md] §5） |

- **4択で 5 を出さない**。4択は 25% が当てずっぽうで当たるため、綴りモードと同じ強さで
  間隔を伸ばすと定着していない語がマスター判定に入り込む。
- 「速い」の閾値: spell 8,000ms / listening 10,000ms / choice 4,000ms（`GradeResolver` の定数）。
- フラッシュカードで自己評価しなかった場合は `word_reviews` を更新しない。
  「押さなければ状態は変えない」（FR-26）を守り、眺めただけの語を既習にしない。

## 3. SM-2 の更新式

```dart
ReviewState apply(ReviewState s, int grade, DateTime answeredAt) {
  // EF は grade によらず毎回更新する（SM-2 原典どおり）
  final ef = max(1.3, s.easeFactor + (0.1 - (5 - grade) * (0.08 + (5 - grade) * 0.02)));

  final int repetition;
  final double interval;
  if (grade >= 3) {
    repetition = s.repetition + 1;
    interval = switch (s.repetition) {
      0 => 1.0,
      1 => 6.0,
      _ => (s.intervalDays * ef).roundToDouble(),
    };
  } else {
    repetition = 0;
    interval = 1.0; // 翌日に必ずもう一度出す
  }
  ...
}
```

| grade | EF の増減 |
|---|---|
| 5 | +0.10 |
| 4 | 0 |
| 3 | −0.14 |
| 2 | −0.32 |
| 1 | −0.54 |
| 0 | −0.80 |

- `intervalDays` の上限は **365日**。これ以上伸ばしても学習体験に差が出ず、
  端末を替えたときに「一生出てこない語」が生まれるため。
- `lapses` は `repetition >= 2`（＝一度は定着していた）状態で grade < 3 になったときだけ +1 する。
- `correctStreak` は grade >= 3 で +1、それ以外で 0 に戻す。
- `firstLearnedAt` は最初に grade >= 3 になったときにだけ設定する。

## 4. `dueAt` の決め方

```dart
// 学習日の 04:00 を起点に interval 日を足す（[03_data_model.md] §4）
final base = studyDayStart(answeredAt);          // 例 2026-08-03 04:00
final dueAt = base.add(Duration(days: interval.round()));
```

解答した時刻ではなく**学習日の起点**に足す。22時に解いた語の `interval = 1` を
「翌日22時」にすると、翌朝の学習で出てこないため。この式なら翌日の 04:00 以降いつでも出る。

同日中の再出題（FR-31）は `dueAt` では表現しない。セッション内のキュー操作で行う（§6）。

## 5. 習熟度（Mastery）の導出

`domain/entities/mastery.dart` の `Mastery.from(ReviewState)` だけが判定する。

| 習熟度 | 条件 |
|---|---|
| 未学習 (0) | `word_reviews` の行が無い |
| 学習中 (1) | 行があり、`intervalDays < 21` |
| 定着 (2) | `intervalDays >= 21` |
| マスター (3) | `intervalDays >= 90` かつ `correctStreak >= 3` |

`word_reviews.masteryLevel` は、学習状態を書き換える同一トランザクション内で必ずこの関数の結果に更新する
（[03_data_model.md] §2.4）。

## 6. 出題キューの生成

`StudyQueueBuilder.build()` は純粋関数。DB から読んだ候補リストと設定を受け取り、出題順を返す。

### 6.1 候補プール

現在の学習者が選んでいる単語帳に属する単語のうち、次をすべて満たすもの。

```sql
(words.ownerProfileId IS NULL OR words.ownerProfileId = :profileId)
AND words.isExcluded = false
AND words.isDraft   = false
```

- 他の学習者のマイ単語は入らない（[my_words.md] §2）。
- 訳の無い下書きは入らない。答え合わせができないため。
- 同じ単語が複数の単語帳に属していても **1度しか入らない**（`wordId` で一意化する）。
- 語のつくりモードだけはプールが `word_parts` になる（[word_parts.md] §5.3）。

### 6.2 出題方針ごとの取り方

| 方針 | 取り方 |
|---|---|
| 復習優先（既定） | ① `dueAt <= now` を `dueAt` の昇順で取る ② 不足分を未学習語で埋める（単語帳の掲載順） ③ まだ不足なら `dueAt` が近い順に前借りする |
| 新規のみ | 未学習語だけを掲載順に取る |
| 苦手のみ | 解答10回以上かつ正解率60%未満の語を、正解率の昇順で取る |

- ③の前借りは、復習も新規も尽きた場合の措置。前借りした語には結果画面で
  「先取り復習」と表示し、通常の復習と区別する。
- どの方針でも候補が 0 件ならセッションを開始せず、モード選択シートに理由を出す
  （[04_screens_and_flows.md] §4.2）。

### 6.3 並び替え

取得したリストを Fisher–Yates でシャッフルする。乱数はセッションIDから作るシード付き
（`Random(sessionId.hashCode)`）にして、同じセッションの再現とテストの決定性を確保する。

### 6.4 セッション中の再出題

- 誤答（grade < 3）した語は、キューの**末尾に1回だけ**戻す。
- 戻した語は `learning_logs` に2件記録されるが、`word_reviews` の更新は毎回行う
  （2回目に正解すれば grade 4 で間隔が伸びる）。
- 2回目も誤答した場合は戻さない。1セッションが終わらなくなるため。

## 7. 「今日の復習 N語」の数え方

ホームと FAB のバッジに出す件数は、
**現在の学習者の候補プール（§6.1）のうち `dueAt <= now` の語の数**。
上限を設けず実数を出す（「99+」で丸めない。何語残っているかが学習計画の材料になる）。

語の部品（`part_reviews`）の期限到来分はこの件数に含めない。
単語と部品を足すと「何語覚え直すのか」が分からなくなるため、
語のつくりモードのカードに別途「復習 8個」と出す。

## 8. テスト観点

`test/domain/sm2_scheduler_test.dart` / `study_queue_builder_test.dart`

- grade 0〜5 それぞれで EF の増減が表どおりになる。EF が 1.3 を下回らない。
- `repetition` 0→1→2 で interval が 1 → 6 → `6*EF` になる。
- grade < 3 で `repetition` が 0、`interval` が 1 に戻る。
- `intervalDays` が 365 を超えない。
- 22:00 に解いた語の `dueAt` が翌日 04:00 になる（時刻ではなく学習日起点）。
- `lapses` が「一度定着した語の誤答」でのみ増える。
- `Mastery.from` の 4 段階の境界値（20.9/21.0 日、89.9/90.0 日、`correctStreak` 2/3）。
- キュー生成: 復習が足りないとき未学習語で埋まる／両方尽きたら前借りする／0件なら空を返す。
- 同じ単語が2つの単語帳にあってもキューに1度しか入らない。
- 同じシードなら同じ順序、違うシードなら違う順序になる。
