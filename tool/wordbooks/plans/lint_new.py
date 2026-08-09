# 新規作成したレコードの下ごしらえ検査。
# 本番の検証（build_wordbooks.dart --check）に通す前に、機械で拾えるものを拾う。
#   python lint_new.py <dir>
import glob, io, json, os, re, sys

KEYS = ['headword', 'partOfSpeech', 'phonetic', 'meaning', 'exampleEn', 'exampleJa', 'level']
POS = {'noun', 'verb', 'adjective', 'adverb', 'preposition', 'conjunction',
       'pronoun', 'interjection', 'phrase'}
# 日本語として出てよい文字。ここに無い文字（キリル文字・ハングル等）は混入とみなす。
JA_OK = re.compile(r'^[　-〿぀-ゟ゠-ヿ一-鿿'
                   r'！-｠‐-‟0-9A-Za-z .,%\-]+$')

bad, seen, n = [], {}, 0
for f in sorted(glob.glob(os.path.join(sys.argv[1], 'new_*.json'))):
    base = os.path.basename(f)
    for w in json.load(io.open(f, encoding='utf-8'))['words']:
        n += 1
        key = '%s:%s' % (w.get('headword'), w.get('partOfSpeech'))
        tag = '%s %s' % (base, key)
        for k in KEYS:
            if k not in w:
                bad.append('%s: 項目が無い %s' % (tag, k))
        if key in seen:
            bad.append('%s: 重複（%s にもある）' % (tag, seen[key]))
        seen[key] = base
        pos, hw = w.get('partOfSpeech'), w.get('headword', '')
        if pos not in POS:
            bad.append('%s: 品詞が不正' % tag)
        if not re.match(r"^[a-z][a-z '-]*$", hw):
            bad.append('%s: 見出し語に使えない文字' % tag)
        if (' ' in hw) != (pos == 'phrase'):
            bad.append('%s: 複数語と phrase が対応していない' % tag)
        m = w.get('meaning', '')
        if not m:
            bad.append('%s: 訳が空' % tag)
        if ';' in m:
            bad.append('%s: 訳に半角セミコロン' % tag)
        if '（' in m or '(' in m:
            bad.append('%s: 訳に丸括弧: %s' % (tag, m))
        if len(m.split('；')) > 3:
            bad.append('%s: 語義が4つ以上' % tag)
        ph = w.get('phonetic', '')
        if pos == 'phrase':
            if ph:
                bad.append('%s: 句に発音記号' % tag)
        elif not (ph.startswith('/') and ph.endswith('/') and len(ph) > 2):
            bad.append('%s: 発音記号の形が不正: %s' % (tag, ph))
        en, ja = w.get('exampleEn', ''), w.get('exampleJa', '')
        if bool(en) != bool(ja):
            bad.append('%s: 例文と和訳が対でない' % tag)
        if en:
            words = en.split()
            if len(words) > 10:
                bad.append('%s: 例文が %d 語: %s' % (tag, len(words), en))
            if en[-1] not in '.!?':
                bad.append('%s: 例文の終止符' % tag)
            stem = hw.split()[0]
            if stem[:max(3, len(stem) - 2)].lower() not in en.lower():
                bad.append('%s: 例文に見出し語が見当たらない: %s' % (tag, en))
        if ja:
            if ja[-1] not in '。！？':
                bad.append('%s: 和訳の終止符' % tag)
            if not JA_OK.match(ja):
                strays = ''.join(sorted({c for c in ja if not JA_OK.match(c)}))
                bad.append('%s: 和訳に想定外の文字 [%s]: %s' % (tag, strays, ja))
        lv = w.get('level')
        if lv not in (1, 2, 3, 4, 5):
            bad.append('%s: level が範囲外: %s' % (tag, lv))

print('\n'.join(bad) if bad else '問題なし')
print('検査 %d 語 / 指摘 %d 件' % (n, len(bad)))
