# draft_*.json（既存レコードの回収分）と new_*.json（新規作成分）を合成し、
# tool/wordbooks/src/<book>/ のチャンクを差し替える。
# 構成から外れた語は tool/wordbooks/pool/ へ退避する（捨てない。Docs §3.4）。
#   python assemble.py <presetId> [--apply]
import glob, io, json, os, sys

SC = os.path.dirname(os.path.abspath(__file__))
book = sys.argv[1]
apply = '--apply' in sys.argv
SRC = 'tool/wordbooks/src/%s' % book
POOL = 'tool/wordbooks/pool'
WORK = os.path.join(SC, book)
KEYS = ['headword', 'partOfSpeech', 'phonetic', 'meaning', 'exampleEn', 'exampleJa', 'level']

new = {}
for f in sorted(glob.glob(os.path.join(WORK, 'new_*.json'))):
    for w in json.load(io.open(f, encoding='utf-8'))['words']:
        new['%s:%s' % (w['headword'], w['partOfSpeech'])] = w

chunks, missing = [], []
for f in sorted(glob.glob(os.path.join(WORK, 'draft_*.json'))):
    d = json.load(io.open(f, encoding='utf-8'))
    words = []
    for w in d['words']:
        key = '%s:%s' % (w['headword'], w['partOfSpeech'])
        if w.get('_todo'):
            src = new.get(key)
            if src is None:
                missing.append(key)
                continue
            w = src
        words.append({k: w[k] for k in KEYS})
    chunks.append({'chunk': d['chunk'], 'note': '%s（%d語）' % (d['note'], len(words)),
                   'words': words})

dropped = json.load(io.open(os.path.join(WORK, 'dropped.json'), encoding='utf-8'))
dropped['words'] = [{k: w[k] for k in KEYS} for w in dropped['words']]
dropped['note'] = '%s（%d語）' % (dropped['note'], len(dropped['words']))

if apply and not missing:
    for f in glob.glob(os.path.join(SRC, '[0-9]*.json')):
        os.remove(f)
    for c in chunks:
        io.open(os.path.join(SRC, c['chunk'] + '.json'), 'w', encoding='utf-8', newline='\n').write(
            json.dumps(c, ensure_ascii=False, indent=2))
    manifest = json.load(io.open(os.path.join(SRC, '_book.json'), encoding='utf-8'))
    manifest['chunks'] = [c['chunk'] for c in chunks]
    manifest['levelRange'] = [min(w['level'] for c in chunks for w in c['words']),
                              max(w['level'] for c in chunks for w in c['words'])]
    io.open(os.path.join(SRC, '_book.json'), 'w', encoding='utf-8', newline='\n').write(
        json.dumps(manifest, ensure_ascii=False, indent=2))
    io.open(os.path.join(POOL, '%s_dropped.json' % book), 'w', encoding='utf-8', newline='\n').write(
        json.dumps(dropped, ensure_ascii=False, indent=2))

total = sum(len(c['words']) for c in chunks)
hw = [w['headword'] for c in chunks for w in c['words']]
abc = sum(1 for h in hw if h[0] in 'abc')
lv = {}
for c in chunks:
    for w in c['words']:
        lv[w['level']] = lv.get(w['level'], 0) + 1
print('チャンク %d / 収録 %d 語 / 退避 %d 語' % (len(chunks), total, len(dropped['words'])))
print('頭文字 a+b+c: %d (%.1f%%)' % (abc, 100.0 * abc / total))
print('レベル: ' + ' '.join('%s=%d' % (k, lv[k]) for k in sorted(lv)))
if missing:
    print('新規レコードが見つからない語 %d: %s' % (len(missing), ' '.join(missing[:10])))
print('APPLIED' if apply and not missing else 'DRY RUN（--apply で書き込み）')
