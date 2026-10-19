"""Đặt mức ưu tiên cho từ trong content/vocab.json: EXTRA cho từ hiếm (priority/extra_*.txt), còn lại CORE.

priority/extra_*.txt: từ hiếm rà tay trong các nhóm Core B1–C2 (lấy từ tần suất phụ đề): tên con vật, món ăn,
đồ vật hẹp nghĩa, từ tôn giáo/quân sự cổ, y khoa quá chuyên sâu, từ lóng.
priority/keep_core.txt: ngoại lệ giữ CORE (đồ vật hay gặp trong Listening Part 1).
Từ thuộc chủ đề IELTS và Academic luôn là CORE. Chạy lại nhiều lần vẫn cho cùng kết quả.
"""
import glob, json, os

HERE = os.path.dirname(os.path.abspath(__file__))
VOCAB = os.path.join(HERE, '..', '..', 'backend', 'src', 'main', 'resources', 'content', 'vocab.json')


def read_list(pattern):
    out = set()
    for path in glob.glob(os.path.join(HERE, 'priority', pattern)):
        for line in open(path, encoding='utf-8'):
            if line.startswith('#'):
                continue
            out.update(x.strip().lower() for x in line.split(',') if x.strip())
    return out


def main():
    data = json.load(open(VOCAB, encoding='utf-8'))
    extra = read_list('extra_*.txt') - read_list('keep_core.txt')
    counts = {'CORE': 0, 'EXTRA': 0}
    for w in data['words']:
        protected = w['topic'].startswith('IELTS ') or w['topic'] == 'Academic'
        w['priority'] = 'EXTRA' if w['word'].lower() in extra and not protected else 'CORE'
        counts[w['priority']] += 1
    with open(VOCAB, 'w', encoding='utf-8') as fh:
        json.dump(data, fh, ensure_ascii=False, indent=2)
        fh.write('\n')
    print(counts)


if __name__ == '__main__':
    main()
