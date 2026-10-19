"""Thêm từ mới cho band 7+ từ add/*.tsv vào content/vocab.json.

Mỗi dòng trong add/*.tsv (tách bằng TAB):
  nhóm  từ  loại_từ  cấp_độ  IPA  nghĩa_Việt  nghĩa_Anh  ví_dụ_Anh  ví_dụ_Việt
Nhóm quyết định chủ đề (xem TOPIC). IPA có thể để trống (cụm từ dài, thành ngữ).
Từ đã có trong vocab.json thì bỏ qua, nên chạy lại nhiều lần vẫn cho cùng kết quả.
Danh sách từ cần có nằm ở lists/band7.txt; lists/awl.txt là Academic Word List (Coxhead).
"""
import glob, json, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
VOCAB = os.path.join(HERE, '..', '..', 'backend', 'src', 'main', 'resources', 'content', 'vocab.json')

TOPIC = {
    'awl': 'Academic',
    'adverb': 'IELTS Academic Language',
    'linking': 'IELTS Academic Language',
    'evaluation': 'IELTS Academic Language',
    'environment': 'IELTS Environment',
    'education': 'IELTS Education',
    'health': 'IELTS Health',
    'technology': 'IELTS Technology',
    'crime': 'IELTS Crime & Law',
    'society': 'IELTS Government & Society',
    'work': 'IELTS Work & Economy',
    'urban': 'IELTS Urban Life',
    'media': 'IELTS Media & Advertising',
    'tourism': 'IELTS Globalisation & Tourism',
    'family': 'IELTS Family & Science',
    'science': 'IELTS Family & Science',
    'data': 'IELTS Task 1 Data',
    'phrasal': 'IELTS Phrasal Verbs',
    'idiom': 'IELTS Speaking Idioms',
}

NEW_TOPICS = [
    {'name': 'IELTS Academic Language', 'icon': '🎓'},
    {'name': 'IELTS Phrasal Verbs', 'icon': '🔗'},
    {'name': 'IELTS Speaking Idioms', 'icon': '💬'},
]

POS = {'noun', 'verb', 'adjective', 'adverb', 'phrase', 'phrasal_verb', 'preposition', 'conjunction', 'pronoun', 'interjection'}
LEVELS = {'A1', 'A2', 'B1', 'B2', 'C1', 'C2'}


def variant_known(word, have):
    """Đã có từ này, kể cả dạng có mạo từ hoặc số nhiều ("the cost of living", "crime rates")."""
    w = word.lower()
    forms = {w, w + 's', w + 'es', 'a ' + w, 'an ' + w, 'the ' + w, 'the ' + w + 's', 'a ' + w + 's'}
    if w.endswith('s'):
        forms.add(w[:-1])
    return any(f in have for f in forms)


def main():
    dry = '--dry' in sys.argv
    data = json.load(open(VOCAB, encoding='utf-8'))
    names = {t['name'] for t in data['topics']}
    order = max(t['sortOrder'] for t in data['topics'])
    for t in NEW_TOPICS:
        if t['name'] not in names:
            order += 1
            data['topics'].append({**t, 'sortOrder': order})
            names.add(t['name'])
    have = {w['word'].lower() for w in data['words']}
    sort = max(w['sortOrder'] for w in data['words'])
    added, skipped, errors = 0, 0, []
    for path in sorted(glob.glob(os.path.join(HERE, 'add', '*.tsv'))):
        for n, line in enumerate(open(path, encoding='utf-8'), 1):
            line = line.rstrip('\n')
            if not line.strip() or line.startswith('#'):
                continue
            cols = line.split('\t')
            if len(cols) != 9:
                errors.append(f'{os.path.basename(path)}:{n} cần 9 cột, có {len(cols)}')
                continue
            cat, word, pos, level, ipa, vi, en, ex_en, ex_vi = (c.strip() for c in cols)
            if cat not in TOPIC or pos not in POS or level not in LEVELS or not (word and vi and en and ex_en and ex_vi):
                errors.append(f'{os.path.basename(path)}:{n} sai nhóm/loại từ/cấp độ hoặc thiếu cột: {word}')
                continue
            if variant_known(word, have):
                skipped += 1
                continue
            sort += 1
            data['words'].append({
                'topic': TOPIC[cat], 'word': word, 'phonetic': ipa or None, 'meaningVi': vi, 'level': level,
                'partOfSpeech': pos, 'exampleEn': ex_en, 'exampleVi': ex_vi, 'sortOrder': sort, 'meaningEn': en,
            })
            have.add(word.lower())
            added += 1
    if errors:
        print('\n'.join(errors))
        sys.exit(1)
    if not dry:
        with open(VOCAB, 'w', encoding='utf-8') as fh:
            json.dump(data, fh, ensure_ascii=False, indent=2)
            fh.write('\n')
    print(f'thêm {added}, bỏ qua (đã có) {skipped}, tổng {len(data["words"])}')


if __name__ == '__main__':
    main()
