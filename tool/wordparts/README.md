# 語の部品と派生語ファミリーのソース

`Docs/06_features/word_parts.md` §8 と `word_families.md` §7 が正本。

```
src/prefixes.json    接頭辞
src/roots.json       語根
src/suffixes.json    接尾辞
src/links_1..4.json  語と部品の紐付け
src/families.json    派生語ファミリー
```

```
dart run tool/build_wordparts.dart --check   # 検証だけ
dart run tool/build_wordparts.dart           # assets/word_parts.json を書き出す
```

## 書くときの規則

- `form` のハイフンの位置が種別を表す（`re-` / `port` / `-able`）。
- 紐付けの `headword` は**出荷6冊にある見出し語だけ**。無い語は検証で落ちる。
  足したいなら、その語を単語帳に収録するのが先（`word_families.md` §5）。
- `parts` の並びがそのまま `position`（0 から）になる。
- `partsNote` は「部品の意味 → 語の意味」の橋渡しが要る語だけに書く。
  無ければ部品の意味を `+` で繋いだ表示になる。**機械生成しない。**
- **語源で検算する。** 綴りが似ていても語源が別のものが必ず混ざる
  （`refund` は fundere で `fund`(fundus) ではない、
  `deliberate` は librare で `liber` ではない）。
  取り違えた実例は `word_parts.md` §8.3 の表にある。

## 新しい語根を足すとき

1. `roots.json` に足す。
2. 異形（`vert`/`vers` のような）を `note` に書く。
3. `links_*.json` に紐付けを足す。**3語以上にしないと出題されない**
   （`word_parts.md` §5.3）。
4. `--check` を通す。
5. `dart run tool/build_wordparts.dart` で書き出し、`flutter test` を通す。

`seedVersion` はビルドツールが単語帳の `_book.json` から読む。手で書かない。
