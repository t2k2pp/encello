# 見出し語の選定計画と作り直しの道具

`Docs/06_features/wordbooks.md` §2.2 (a) の「見出し語の選定やり直し」で使うもの。
**チャンクファイルそのものではない**（ビルドの対象外）。

```
plan_<presetId>.md          その単語帳に入れる見出し語の一覧（チャンクごと）
harvest.py                  計画に対し、既存6冊＋プールからレコードを回収する
assemble.py                 回収分と新規作成分を合成し、src/<presetId>/ を差し替える
lint_new.py                 新規作成したレコードを、本番の検証に通す前に検査する
<presetId>_todo.tsv         まだ新しく書けていない語（作業が途中の単語帳のみ）
```

## 手順

作業用ディレクトリを1つ決め（`$W`）、`plan_*.md` をそこに置いて実行する。

```
python harvest.py <presetId>     # $W/<presetId>/draft_*.json と todo.tsv ができる
# todo.tsv の語を $W/<presetId>/new_*.json に書く（形式は既存のチャンクと同じ7項目）
python lint_new.py <presetId>    # 語数・終止符・丸括弧・和訳の文字種などを先に潰す
python assemble.py <presetId>            # 数字だけ見る
python assemble.py <presetId> --apply    # src/ を差し替え、外れた語は pool/ へ退避
dart run tool/build_wordbooks.dart --check --book <presetId>
dart run tool/build_wordbooks.dart --check-all
dart run tool/build_wordbooks.dart
```

`assemble.py` は `todo` の語のレコードが1つでも欠けていれば**書き込まない**。
半分だけ作り直した単語帳を残さないため。

`lint_new.py` の「例文に見出し語が見当たらない」は、不規則活用
（`undertake` → `undertook`、`break out` → `broke out`）で誤検知する。
本番の検証（`--check`）は活用を展開して見るので、そちらの結果を正とする。

## 実績と残り

| 単語帳 | 状態 | 設計 | 流用 | 新規 | 退避 |
|---|---|---|---|---|---|
| `eiken_pre2_v1` | 完了 | 880 | 775 | 105 | 1,109 |
| `hs_basic_v1` | 完了 | 1,206 | 966 | 240 | 754 |
| `eiken_2_v1` | 完了 | 1,045 | 756 | 289 | 1,104 |
| `hs_advanced_v1` | **計画のみ** | 1,002 | 449 | **553** | 1,088 |

`hs_advanced_v1` は計画（13チャンク・1,002語・頭文字 a+b+c 22%）まで済み、
**新しく書く553語が未着手**。対象語は `hs_advanced_v1_todo.tsv`
（`チャンク <TAB> 見出し語 <TAB> 品詞`）。

流用率が 72% → 45% と落ちるのは、難関大の語（`ubiquitous` `paradigm` `jurisdiction` など）が
他の5冊にほとんど無いため。ここは新しく書くしかない。
