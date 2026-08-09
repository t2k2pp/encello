# plan_<book>.md の計画に従って、既存6冊＋プールからレコードを回収し、
# チャンクごとの下書き JSON をスクラッチパッドに作る。
#   python harvest.py <presetId>
# 出力: <book>/draft_<chunk>.json, <book>/dropped.json, <book>/todo.tsv
import glob, io, json, os, re, sys

SC = os.path.dirname(os.path.abspath(__file__))
SRC = 'tool/wordbooks/src'
POOL = 'tool/wordbooks/pool'
BOOKS = ['jhs_v1', 'hs_basic_v1', 'hs_advanced_v1', 'eiken_pre2_v1', 'eiken_2_v1', 'toeic_basic_v1']

book = sys.argv[1]
# 同じ語が複数の冊にあるとき、どの冊のレコードを優先するか（作る冊に近い順）
PRIORITY = {
    'hs_basic_v1': ['hs_basic_v1', 'eiken_pre2_v1', 'jhs_v1', 'eiken_2_v1', 'toeic_basic_v1', 'hs_advanced_v1'],
    'eiken_2_v1': ['eiken_2_v1', 'eiken_pre2_v1', 'hs_basic_v1', 'toeic_basic_v1', 'hs_advanced_v1', 'jhs_v1'],
    'hs_advanced_v1': ['hs_advanced_v1', 'eiken_2_v1', 'hs_basic_v1', 'toeic_basic_v1', 'eiken_pre2_v1', 'jhs_v1'],
}[book]
PRIORITY = PRIORITY + ['pool:eiken_pre2_v1']

records = {}
for b in BOOKS:
    for f in sorted(glob.glob(os.path.join(SRC, b, '*.json'))):
        if f.endswith('_book.json'):
            continue
        for w in json.load(io.open(f, encoding='utf-8'))['words']:
            records.setdefault('%s:%s' % (w['headword'], w['partOfSpeech']), {})[b] = w
for f in sorted(glob.glob(os.path.join(POOL, '*.json'))):
    tag = 'pool:' + os.path.basename(f).replace('_dropped.json', '')
    for w in json.load(io.open(f, encoding='utf-8'))['words']:
        records.setdefault('%s:%s' % (w['headword'], w['partOfSpeech']), {})[tag] = w


def pick(key):
    got = records.get(key)
    if not got:
        return None, None
    for b in PRIORITY:
        if b in got:
            return got[b], b
    b = next(iter(got))
    return got[b], b


outdir = os.path.join(SC, book)
os.makedirs(outdir, exist_ok=True)
for f in glob.glob(os.path.join(outdir, 'draft_*.json')):
    os.remove(f)

plan = io.open(os.path.join(SC, 'plan_%s.md' % book), encoding='utf-8').read()
chunks = re.findall(r'^## (\S+)\s+「([^」]*)」(.*?)(?=^## |\Z)', plan, re.M | re.S)

summary, planned, todo, seen = [], [], [], {}
for slug, name, body in chunks:
    keys = re.findall(r"\b([a-z][a-z '-]*?:[a-z]+)(?=\s|$)", body)
    words, missing, sources = [], [], {}
    for key in keys:
        if key in seen:
            summary.append('  !! 重複: %s（%s と %s）' % (key, seen[key], slug))
            continue
        seen[key] = slug
        planned.append(key)
        rec, src = pick(key)
        if rec is None:
            hw, pos = key.rsplit(':', 1)
            missing.append(key)
            todo.append('%s\t%s\t%s' % (slug, hw, pos))
            words.append({'headword': hw, 'partOfSpeech': pos, 'phonetic': '', 'meaning': '',
                          'exampleEn': '', 'exampleJa': '', 'level': 0, '_todo': '新規作成'})
        else:
            w = dict(rec)
            w['_from'] = src
            words.append(w)
            sources[src] = sources.get(src, 0) + 1
    io.open(os.path.join(outdir, 'draft_%s.json' % slug), 'w', encoding='utf-8', newline='\n').write(
        json.dumps({'chunk': slug, 'note': name, 'words': words}, ensure_ascii=False, indent=2))
    summary.append('%-28s %3d語  新規 %3d  流用元 %s' % (
        slug, len(words), len(missing), sorted(sources.items(), key=lambda x: -x[1])))

# 計画に載らなかった現行の語 = プールへ退避する語
kept = set(planned)
dropped = []
for f in sorted(glob.glob(os.path.join(SRC, book, '*.json'))):
    if f.endswith('_book.json'):
        continue
    for w in json.load(io.open(f, encoding='utf-8'))['words']:
        if '%s:%s' % (w['headword'], w['partOfSpeech']) not in kept:
            dropped.append(w)
io.open(os.path.join(outdir, 'dropped.json'), 'w', encoding='utf-8', newline='\n').write(
    json.dumps({'chunk': 'pool_%s' % book, 'note': '作り直しで外した語', 'words': dropped},
               ensure_ascii=False, indent=2))
io.open(os.path.join(outdir, 'todo.tsv'), 'w', encoding='utf-8', newline='\n').write('\n'.join(todo))

abc = sum(1 for k in planned if k[0] in 'abc')
print('\n'.join(summary))
print('計画 %d 語 / 新規 %d 語 / 退避 %d 語' % (len(planned), len(todo), len(dropped)))
print('頭文字 a+b+c: %d (%.1f%%)' % (abc, 100.0 * abc / max(1, len(planned))))
