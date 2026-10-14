"""Tìm câu ví dụ sinh theo khuôn (câu ghép từ vào một khung có sẵn) trong content/vocab.json.

Câu được chuẩn hoá: thay từ đang học bằng {W}, chủ ngữ/địa điểm/thời gian của các script sinh câu bằng *,
rồi đếm. Khung nào lặp lại từ MIN_REPEAT lần trở lên coi là câu khuôn.
In ra: word<TAB>frame cho từng từ có câu khuôn (dùng --list), hoặc thống kê khung.
"""
import collections, glob, json, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, '..', '..')
VOCAB = os.path.join(ROOT, 'backend', 'src', 'main', 'resources', 'content', 'vocab.json')
MIN_REPEAT = 4


def fillers():
    out = set()
    for f in glob.glob(os.path.join(ROOT, 'scripts', '*.rb')):
        for a in re.findall(r'\[\s*"([^"]{2,40})",\s*"[^"]*"\s*\]', open(f, encoding='utf-8').read()):
            if not re.search(r'[{}#%]', a):
                out.add(a)
    return sorted(out, key=len, reverse=True)


FILL = fillers()
FILL_RE = re.compile(r'\b(' + '|'.join(re.escape(x) for x in FILL) + r')\b')
LEAD = re.compile(r'^(?:\*|Still|Also|Again|Here|Today|Then|Now|Later|In reality|Sometimes|Usually),?\s+')


def frame(w):
    s = w.get('exampleEn') or ''
    word = w['word']
    stem = re.escape(word.lower())
    s = re.sub(r'(?i)\b' + stem + r'(?:s|es|ed|d|ing)?\b', '{W}', s)
    s = FILL_RE.sub('*', s)
    s = re.sub(r'\b[A-Z][a-z]+\b(?=\s)', lambda m: m.group(0) if m.start() == 0 and m.group(0) in ('The', 'A', 'An', 'My', 'Our', 'Her', 'His', 'We', 'She', 'He', 'They', 'I') else '*', s)
    prev = None
    while prev != s:
        prev = s
        s = LEAD.sub('', s).strip()
    return s


def templated():
    words = json.load(open(VOCAB, encoding='utf-8'))['words']
    frames = {w['word']: frame(w) for w in words}
    count = collections.Counter(frames.values())
    bad = {k: f for k, f in frames.items() if '{W}' in f and count[f] >= MIN_REPEAT}
    return words, frames, count, bad


if __name__ == '__main__':
    words, frames, count, bad = templated()
    if '--list' in sys.argv:
        for k, f in bad.items():
            print(f'{k}\t{f}')
    else:
        print('templated', len(bad), 'of', len(words))
        for f, n in count.most_common(400):
            if '{W}' in f and n >= MIN_REPEAT:
                print(n, f)
