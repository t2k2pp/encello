"""文頭の可算名詞に限定詞が無い例文を挙げる。

`Company disclosed financial reports.` `Financial crisis hit the market.` の形。
「機能語ゼロ」の検査では、文の別の場所に冠詞があると挙がらないので、
主語の位置だけを見る検査を別に持つ。
"""
import json
import re
import sys
from pathlib import Path

SRC = Path("tool/wordbooks/src")

DET = {
    "a", "an", "the", "my", "your", "his", "her", "its", "our", "their",
    "this", "that", "these", "those", "some", "any", "no", "every", "each",
    "both", "all", "many", "much", "several", "few", "little", "other",
    "another", "such", "one", "two", "three", "four", "five", "what", "which",
    "whose", "there", "here", "it", "he", "she", "they", "we", "you", "i",
    "who", "how", "why", "when", "where", "if", "do", "does", "did", "please",
    "let", "don't", "never", "not", "most",
}
# 限定詞が要らない主語
MASS_OK = {
    "water", "air", "money", "time", "music", "food", "rice", "oil", "sugar",
    "salt", "snow", "rain", "ice", "gold", "blood", "coffee", "tea", "milk",
    "energy", "traffic", "weather", "smoke", "dust", "sand", "wood", "paper",
    "information", "advice", "news", "research", "evidence", "progress",
    "stress", "pollution", "poverty", "crime", "damage", "health", "safety",
    "science", "history", "english", "japanese", "japan", "tokyo", "kyoto",
    "nature", "sleep", "exercise", "education", "technology", "practice",
    "love", "life", "work", "help", "fun", "hope", "luck", "peace", "war",
}


def load(preset):
    book = json.loads((SRC / preset / "_book.json").read_text(encoding="utf-8"))
    out = []
    for chunk in book["chunks"]:
        data = json.loads((SRC / preset / f"{chunk}.json").read_text(encoding="utf-8"))
        for w in data["words"]:
            out.append((chunk, w))
    return out


def nouns():
    """全冊の名詞の見出し語（1語のもの）。"""
    got = set()
    for bd in sorted(p for p in SRC.iterdir() if p.is_dir()):
        book = json.loads((bd / "_book.json").read_text(encoding="utf-8"))
        for chunk in book["chunks"]:
            data = json.loads((bd / f"{chunk}.json").read_text(encoding="utf-8"))
            for w in data["words"]:
                if w["partOfSpeech"] == "noun" and " " not in w["headword"]:
                    got.add(w["headword"])
    return got


def main():
    noun_set = nouns()
    for preset in sys.argv[1:]:
        hits = []
        for chunk, w in load(preset):
            en = w.get("exampleEn") or ""
            if not en:
                continue
            tokens = re.findall(r"[A-Za-z']+", en)
            if not tokens:
                continue
            head = [t.lower() for t in tokens[:3]]
            if head[0] in DET:
                continue
            # 先頭の1〜2語のどこかが可算名詞で、その前に限定詞が無い
            subject = None
            for t in head[:2]:
                if t in noun_set and t not in MASS_OK:
                    subject = t
                    break
            if subject is None:
                continue
            hits.append((chunk, w["headword"], subject, en, w["exampleJa"]))
        print(f"== {preset}: 主語に限定詞が無い候補 {len(hits)} 件")
        for chunk, hw, subj, en, ja in hits:
            print(f"  {chunk} {hw} [{subj}] {en}")


if __name__ == "__main__":
    main()
