"""Áp dụng các sửa nghĩa từ vựng trong fix/*.txt vào content/vocab.json.

Mỗi dòng trong fix/*.txt: KIND<TAB>word<TAB>value
  EN   nghĩa tiếng Anh mới (kiểu từ điển cho người học)
  VI   nghĩa tiếng Việt mới
  DROP loại từ khỏi bộ từ vựng (value bỏ trống)
  EX   câu ví dụ mới: KIND<TAB>word<TAB>câu tiếng Anh<TAB>câu tiếng Việt
  POS  loại từ đúng (noun, verb, adjective, adverb...)
  IPA  phiên âm, ví dụ /ˈwɜːd/
Ngoài ra tự dọn nghĩa Việt của mọi từ: bỏ chữ Hán trong ngoặc, bỏ chú thích [..], bỏ mục trùng.
Chạy lại nhiều lần vẫn cho cùng kết quả.
"""
import glob, json, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
VOCAB = os.path.join(HERE, '..', '..', 'backend', 'src', 'main', 'resources', 'content', 'vocab.json')
CJK = r'㐀-鿿豈-﫿\U00020000-\U0003ffff'


def clean_vi(s):
    t = re.sub(r'\([^)]*[' + CJK + r'][^)]*\)', '', s)
    t = re.sub(r'\[[^\]]*\]', '', t)
    t = re.sub('[' + CJK + ']', '', t).replace('  ', ' ')
    segs = []
    for seg in t.split(';'):
        items, seen = [], set()
        for it in seg.split(','):
            it = it.strip(' .:/')
            if it and it.lower() not in seen:
                seen.add(it.lower())
                items.append(it)
        if items:
            segs.append(', '.join(items))
    return '; '.join(segs).strip() or s


def load_fixes():
    en, vi, ex, pos, ipa, drop = {}, {}, {}, {}, {}, set()
    for f in sorted(glob.glob(os.path.join(HERE, 'fix', '*.txt'))):
        for line in open(f, encoding='utf-8'):
            line = line.rstrip('\n')
            if not line.strip():
                continue
            kind, word, *rest = line.split('\t')
            if kind == 'EN':
                en[word.lower()] = rest[0]
            elif kind == 'VI':
                vi[word.lower()] = rest[0]
            elif kind == 'EX':
                ex[word.lower()] = (rest[0], rest[1])
            elif kind == 'IPA':
                ipa[word.lower()] = rest[0]
            elif kind == 'POS':
                pos[word.lower()] = rest[0]
            elif kind == 'DROP':
                drop.add(word.lower())
    return en, vi, ex, pos, ipa, drop


def main():
    dry = '--dry' in sys.argv
    data = json.load(open(VOCAB, encoding='utf-8'))
    en, vi, ex, pos, ipa, drop = load_fixes()
    words = {w['word'].lower(): w for w in data['words']}
    missing = [k for k in list(en) + list(vi) + list(ex) + list(pos) + list(drop) if k not in words]
    cleaned = 0
    for w in data['words']:
        c = clean_vi(w['meaningVi'])
        if c != w['meaningVi']:
            cleaned += 1
            w['meaningVi'] = c
    for k, v in en.items():
        if k in words:
            words[k]['meaningEn'] = v
    for k, v in vi.items():
        if k in words:
            words[k]['meaningVi'] = v
    for k, (e, v) in ex.items():
        if k in words:
            words[k]['exampleEn'] = e
            words[k]['exampleVi'] = v
    for k, v in ipa.items():
        if k in words:
            words[k]['phonetic'] = v
    for k, v in pos.items():
        if k in words:
            words[k]['partOfSpeech'] = v
    before = len(data['words'])
    data['words'] = [w for w in data['words'] if w['word'].lower() not in drop]
    if not dry:
        with open(VOCAB, 'w', encoding='utf-8') as fh:
            json.dump(data, fh, ensure_ascii=False, indent=2)
            fh.write('\n')
    print(f'EN {len(en)} VI {len(vi)} EX {len(ex)} POS {len(pos)} DROP {before - len(data["words"])} auto-cleaned VI {cleaned} missing {missing[:20]}')


if __name__ == '__main__':
    main()
