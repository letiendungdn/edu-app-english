import { respell, VOWELS } from './respell';

/**
 * Quy tắc phonics: nhìn mặt chữ đoán cách đọc. Đúng cho phần lớn từ thông dụng, không phải mọi từ.
 * Mỗi quy tắc có mẫu chữ (re) và âm đọc mong đợi (ipa). Với một từ cụ thể, hàm phonicsHints so mẫu chữ với
 * phiên âm thật của từ: khớp thì từ "theo quy tắc", lệch thì từ là ngoại lệ của quy tắc đó.
 */

export interface PhonicsExample { word: string; ipa: string }

export interface PhonicsRule {
  id: string;
  group: string;
  /** Mẫu chữ để hiển thị, ví dụ "a_e". */
  pattern: string;
  /** Âm đọc bằng chữ Việt, khớp với cách đọc của respell. */
  sound: string;
  explain: string;
  /** Phần chữ khớp với re được tô đậm. */
  re: RegExp;
  /** Âm IPA mong đợi (đã chuẩn hóa). Bỏ trống khi dùng check. */
  ipa?: string[];
  /** norm: IPA đã chuẩn hóa; raw: IPA gốc (còn dấu nhấn). */
  check?: (norm: string, word: string, raw: string) => boolean;
  /** Chỉ áp dụng khi điều kiện đúng (số âm tiết, loại từ...). */
  when?: (word: string, ipa: string, pos?: string | null) => boolean;
  examples: PhonicsExample[];
  exceptions?: string;
}

export const PHONICS_GROUPS = [
  { id: 'short', title: 'Nguyên âm ngắn', intro: 'Từ một âm tiết có một nguyên âm kẹp giữa phụ âm (kiểu C-V-C) thì nguyên âm đọc ngắn.' },
  { id: 'magic-e', title: 'E câm cuối từ', intro: 'Chữ e ở cuối không đọc, nhưng làm nguyên âm đứng trước đọc theo "tên chữ cái": a → ây, i → ai, o → âu, u → yu.' },
  { id: 'team', title: 'Hai nguyên âm đi liền', intro: '"When two vowels go walking, the first one does the talking": hai nguyên âm đi cùng nhau thường đọc thành một âm.' },
  { id: 'r', title: 'Nguyên âm + r', intro: 'Chữ r sau nguyên âm làm thay đổi cách đọc của nguyên âm đó (giọng Mỹ đọc rõ âm r).' },
  { id: 'consonant', title: 'Phụ âm và chữ câm', intro: 'Các cụm phụ âm đọc thành một âm, và một số chữ không được đọc.' },
  { id: 'ending', title: 'Đuôi từ thường gặp', intro: 'Đuôi từ có cách đọc cố định, nhận ra là đọc đúng ngay.' },
  { id: 'stress', title: 'Trọng âm', intro: 'Đọc sai trọng âm thì người nghe khó hiểu dù đọc đúng từng âm. Âm tiết được nhấn đọc to, dài và cao hơn.' },
] as const;

/** Đưa IPA về một dạng để so sánh: bỏ dấu nhấn và dấu dài, gộp ký hiệu Anh–Mỹ. */
export function normalizeIpa(ipa: string | null | undefined): string {
  return (ipa ?? '')
    .replace(/[\/\[\]ˈˌː.\s]/g, '')
    .replace(/ɫ/g, 'l').replace(/ɹ/g, 'r').replace(/ɡ/g, 'g')
    .replace(/ɜr|ɜ|ər/g, 'ɝ').replace(/əʊ/g, 'oʊ').replace(/ɒ/g, 'ɑ').replace(/e(?!ɪ)/g, 'ɛ');
}

function vowelGroups(word: string): number {
  return (word.replace(/e$/, '').match(/[aeiouy]+/g) ?? []).length || 1;
}

function syllables(ipa: string): string[] {
  return respell(ipa).split(/[-\s]/).filter(Boolean);
}

function stressIndex(ipa: string): number {
  // Dữ liệu đôi khi có hai dấu nhấn chính (/ˈdʊˈɹeɪʃən/): lấy dấu sau, thường là dấu đúng.
  const marks = syllables(ipa).map((x) => x === x.toUpperCase() && /[A-ZĐÂÊÔƠƯĂ]/.test(x));
  return marks.lastIndexOf(true);
}

const oneSyllable = (w: string) => vowelGroups(w) === 1 && !/\s/.test(w);
/** Từ một âm tiết, hoặc âm tiết cuối được nhấn (quy tắc e câm chỉ đúng ở âm tiết nhấn). */
const lastStressed = (_w: string, ipa: string) => {
  const n = syllables(ipa).length;
  return n <= 1 || stressIndex(ipa) === n - 1;
};
/** Đuôi -tion phiên âm /ʃn/ (n làm âm tiết) thì respell đếm thiếu một âm tiết. */
function syllableCount(raw: string): number {
  return syllables(raw).length + (/[ʃʒ]n\/?$/.test(raw.replace(/ː/g, '')) ? 1 : 0);
}
const CH_K = /^chr|sch|tech|ache$|^chem|psych|^chor(?!e)|chaos|archi|^chara|mechan|stomach|orchestra/;
// Động từ hai âm tiết tận cùng thế này thường nhấn âm đầu (visit, open, answer, finish, study, follow).
const VERB_FIRST_STRESS = /(?:ish|[^aeiou]y|er|en|ow|el|le|on|it|ice|age)$/;
const STRESS_SUFFIX = /(?:[ts]ion|ic|ical|ity|ian|ial|ious)$/;
const startsWith = (sound: string) => (norm: string) => norm.startsWith(sound);
const endsWith = (...sounds: string[]) => (norm: string) => sounds.some((x) => norm.endsWith(x));

export const PHONICS_RULES: PhonicsRule[] = [
  // Nguyên âm ngắn
  {
    id: 'short-a', group: 'short', pattern: 'a', sound: 'e (miệng mở rộng)', ipa: ['æ'], when: oneSyllable,
    re: /(?<=^[^aeiouy]*)(?<!w|qu)a(?=[^aeiouyrlw][^aeiouy]*$)/,
    explain: 'Chữ a trong từ ngắn kiểu cat, map đọc như "e" nhưng mở miệng rộng, hạ hàm xuống.',
    examples: [{ word: 'cat', ipa: '/ˈkæt/' }, { word: 'map', ipa: '/ˈmæp/' }, { word: 'bag', ipa: '/ˈbæɡ/' }, { word: 'hand', ipa: '/ˈhænd/' }, { word: 'black', ipa: '/ˈblæk/' }],
  },
  {
    id: 'short-e', group: 'short', pattern: 'e', sound: 'e', ipa: ['ɛ'], when: oneSyllable,
    re: /(?<=^[^aeiouy]*)e(?=[^aeiouyrw][^aeiouy]*$)/,
    explain: 'Chữ e trong từ ngắn đọc là "e" như tiếng Việt.',
    examples: [{ word: 'bed', ipa: '/ˈbɛd/' }, { word: 'pen', ipa: '/ˈpɛn/' }, { word: 'desk', ipa: '/ˈdɛsk/' }, { word: 'red', ipa: '/ˈrɛd/' }, { word: 'help', ipa: '/ˈhɛlp/' }],
  },
  {
    id: 'short-i', group: 'short', pattern: 'i', sound: 'i (ngắn)', ipa: ['ɪ'], when: oneSyllable,
    re: /(?<=^[^aeiouy]*)i(?!gh|gn)(?=[^aeiouyr][^aeiouy]*$)(?!.*(?:nd|ld)$)/,
    explain: 'Chữ i trong từ ngắn đọc "i" ngắn, gọn, miệng hơi thả lỏng.',
    examples: [{ word: 'sit', ipa: '/ˈsɪt/' }, { word: 'big', ipa: '/ˈbɪɡ/' }, { word: 'fish', ipa: '/ˈfɪʃ/' }, { word: 'milk', ipa: '/ˈmɪlk/' }, { word: 'ship', ipa: '/ˈʃɪp/' }],
  },
  {
    id: 'short-o', group: 'short', pattern: 'o', sound: 'a / o', ipa: ['ɑ', 'ɔ'], when: oneSyllable,
    re: /(?<=^[^aeiouy]*)o(?=[^aeiouyrlw][^aeiouy]*$)/,
    explain: 'Chữ o trong từ ngắn: giọng Mỹ đọc gần "a" (hot = hat), giọng Anh đọc "o" ngắn.',
    examples: [{ word: 'hot', ipa: '/ˈhɑt/' }, { word: 'stop', ipa: '/ˈstɑp/' }, { word: 'box', ipa: '/ˈbɑks/' }, { word: 'shop', ipa: '/ˈʃɑp/' }, { word: 'dog', ipa: '/ˈdɔɡ/' }],
  },
  {
    id: 'short-u', group: 'short', pattern: 'u', sound: 'ă', ipa: ['ʌ', 'ə'], when: oneSyllable,
    re: /(?<=^[^aeiouy]*)u(?=[^aeiouyr][^aeiouy]*$)/,
    explain: 'Chữ u trong từ ngắn đọc như "ă" (cup ≈ căp), không đọc "u".',
    examples: [{ word: 'cup', ipa: '/ˈkəp/' }, { word: 'bus', ipa: '/ˈbəs/' }, { word: 'sun', ipa: '/ˈsən/' }, { word: 'run', ipa: '/ˈrən/' }, { word: 'jump', ipa: '/ˈdʒəmp/' }],
  },
  {
    id: 'old-ind', group: 'short', pattern: 'old / ind / ild', sound: 'âu / ai', ipa: ['oʊ', 'aɪ'],
    re: /(?<![aeiou])(?:o(?=ld$)|i(?=nd$|ld$))/,
    explain: 'Ngoại lệ có quy luật: o trước ld đọc "âu", i trước nd/ld đọc "ai".',
    examples: [{ word: 'cold', ipa: '/ˈkoʊld/' }, { word: 'gold', ipa: '/ˈɡoʊld/' }, { word: 'find', ipa: '/ˈfaɪnd/' }, { word: 'kind', ipa: '/ˈkaɪnd/' }, { word: 'child', ipa: '/ˈtʃaɪld/' }],
  },

  // E câm
  {
    id: 'a_e', group: 'magic-e', pattern: 'a_e', sound: 'ây', ipa: ['eɪ'],
    re: /(?<![aeiouy])a[^aeiouyrx]e$/, when: lastStressed,
    explain: 'a + một phụ âm + e cuối: a đọc "ây", e không đọc. So sánh: mat (met) → mate (mâyt).',
    examples: [{ word: 'make', ipa: '/ˈmeɪk/' }, { word: 'name', ipa: '/ˈneɪm/' }, { word: 'late', ipa: '/ˈleɪt/' }, { word: 'cake', ipa: '/ˈkeɪk/' }, { word: 'plane', ipa: '/ˈpleɪn/' }],
  },
  {
    id: 'i_e', group: 'magic-e', pattern: 'i_e', sound: 'ai', ipa: ['aɪ'],
    re: /(?<![aeiouy])i[^aeiouyrx]e$/, when: lastStressed,
    explain: 'i + một phụ âm + e cuối: i đọc "ai". So sánh: kit (kit) → kite (kait).',
    examples: [{ word: 'time', ipa: '/ˈtaɪm/' }, { word: 'bike', ipa: '/ˈbaɪk/' }, { word: 'like', ipa: '/ˈlaɪk/' }, { word: 'nice', ipa: '/ˈnaɪs/' }, { word: 'write', ipa: '/ˈraɪt/' }],
  },
  {
    id: 'o_e', group: 'magic-e', pattern: 'o_e', sound: 'âu', ipa: ['oʊ'],
    re: /(?<![aeiouy])o[^aeiouyrx]e$/, when: lastStressed,
    explain: 'o + một phụ âm + e cuối: o đọc "âu". So sánh: hop (hap) → hope (hâup).',
    examples: [{ word: 'home', ipa: '/ˈhoʊm/' }, { word: 'nose', ipa: '/ˈnoʊz/' }, { word: 'hope', ipa: '/ˈhoʊp/' }, { word: 'phone', ipa: '/ˈfoʊn/' }, { word: 'note', ipa: '/ˈnoʊt/' }],
  },
  {
    id: 'u_e', group: 'magic-e', pattern: 'u_e', sound: 'yu / u', ipa: ['ju', 'u'],
    re: /(?<![aeiouy])u[^aeiouyrx]e$/, when: lastStressed,
    explain: 'u + một phụ âm + e cuối: u đọc "yu" (cute) hoặc "u" sau r, l, j (rule, June).',
    examples: [{ word: 'cute', ipa: '/ˈkjut/' }, { word: 'use', ipa: '/ˈjuz/' }, { word: 'tube', ipa: '/ˈtub/' }, { word: 'rule', ipa: '/ˈrul/' }, { word: 'June', ipa: '/ˈdʒun/' }],
  },
  {
    id: 'e_e', group: 'magic-e', pattern: 'e_e', sound: 'i (dài)', ipa: ['i'],
    re: /(?<![aeiouy])e[^aeiouyrx]e$/, when: lastStressed,
    explain: 'e + một phụ âm + e cuối: e đầu đọc "i" dài.',
    examples: [{ word: 'these', ipa: '/ˈðiz/' }, { word: 'theme', ipa: '/ˈθim/' }, { word: 'complete', ipa: '/kəmˈplit/' }, { word: 'Chinese', ipa: '/tʃaɪˈniz/' }, { word: 'extreme', ipa: '/ɪkˈstrim/' }],
  },

  // Hai nguyên âm
  {
    id: 'ai-ay', group: 'team', pattern: 'ai / ay', sound: 'ây', ipa: ['eɪ'],
    re: /a[iy](?![aeiour])/, when: (w) => !(vowelGroups(w) >= 2 && /ain$/.test(w)),
    explain: 'ai (giữa từ) và ay (cuối từ) đều đọc "ây".',
    examples: [{ word: 'rain', ipa: '/ˈreɪn/' }, { word: 'wait', ipa: '/ˈweɪt/' }, { word: 'day', ipa: '/ˈdeɪ/' }, { word: 'play', ipa: '/ˈpleɪ/' }, { word: 'train', ipa: '/ˈtreɪn/' }],
    exceptions: 'air đọc "er": hair, chair, airport.',
  },
  {
    id: 'ee', group: 'team', pattern: 'ee', sound: 'i (dài)', ipa: ['i'],
    re: /ee(?!r)/,
    explain: 'ee luôn đọc "i" kéo dài.',
    examples: [{ word: 'see', ipa: '/ˈsi/' }, { word: 'tree', ipa: '/ˈtri/' }, { word: 'green', ipa: '/ˈɡrin/' }, { word: 'sleep', ipa: '/ˈslip/' }, { word: 'meet', ipa: '/ˈmit/' }],
  },
  {
    id: 'ea', group: 'team', pattern: 'ea', sound: 'i (dài)', ipa: ['i'],
    re: /ea(?!r|bl)/,
    explain: 'ea thường đọc "i" kéo dài. Đây là quy tắc có nhiều ngoại lệ nhất.',
    examples: [{ word: 'eat', ipa: '/ˈit/' }, { word: 'sea', ipa: '/ˈsi/' }, { word: 'teach', ipa: '/ˈtitʃ/' }, { word: 'read', ipa: '/ˈrid/' }, { word: 'clean', ipa: '/ˈklin/' }],
  },
  {
    id: 'oa', group: 'team', pattern: 'oa', sound: 'âu', ipa: ['oʊ'],
    re: /oa(?!r)/,
    explain: 'oa đọc "âu".',
    examples: [{ word: 'boat', ipa: '/ˈboʊt/' }, { word: 'road', ipa: '/ˈroʊd/' }, { word: 'coat', ipa: '/ˈkoʊt/' }, { word: 'soap', ipa: '/ˈsoʊp/' }, { word: 'coach', ipa: '/ˈkoʊtʃ/' }],
  },
  {
    id: 'oo', group: 'team', pattern: 'oo', sound: 'u', ipa: ['u', 'ʊ'],
    re: /oo(?!r)/,
    explain: 'oo đọc "u": dài trong moon, food; ngắn trong book, good.',
    examples: [{ word: 'moon', ipa: '/ˈmun/' }, { word: 'food', ipa: '/ˈfud/' }, { word: 'school', ipa: '/ˈskul/' }, { word: 'book', ipa: '/ˈbʊk/' }, { word: 'good', ipa: '/ˈɡʊd/' }],
  },
  {
    id: 'ou', group: 'team', pattern: 'ou', sound: 'ao', ipa: ['aʊ'],
    re: /ou(?!r|gh|ld|s$)/,
    explain: 'ou thường đọc "ao".',
    examples: [{ word: 'house', ipa: '/ˈhaʊs/' }, { word: 'out', ipa: '/ˈaʊt/' }, { word: 'loud', ipa: '/ˈlaʊd/' }, { word: 'mouth', ipa: '/ˈmaʊθ/' }, { word: 'cloud', ipa: '/ˈklaʊd/' }],
  },
  {
    id: 'ow', group: 'team', pattern: 'ow', sound: 'ao / âu', ipa: ['aʊ', 'oʊ'],
    re: /ow/,
    explain: 'ow có hai cách đọc: "ao" (cow, now) hoặc "âu" (snow, slow). Phải nhớ theo từ.',
    examples: [{ word: 'cow', ipa: '/ˈkaʊ/' }, { word: 'now', ipa: '/ˈnaʊ/' }, { word: 'town', ipa: '/ˈtaʊn/' }, { word: 'snow', ipa: '/ˈsnoʊ/' }, { word: 'slow', ipa: '/ˈsloʊ/' }],
  },
  {
    id: 'oi-oy', group: 'team', pattern: 'oi / oy', sound: 'oi', ipa: ['ɔɪ'],
    re: /o[iy]/,
    explain: 'oi (giữa từ) và oy (cuối từ) đọc "oi".',
    examples: [{ word: 'coin', ipa: '/ˈkɔɪn/' }, { word: 'boil', ipa: '/ˈbɔɪl/' }, { word: 'boy', ipa: '/ˈbɔɪ/' }, { word: 'toy', ipa: '/ˈtɔɪ/' }, { word: 'enjoy', ipa: '/ɛnˈdʒɔɪ/' }],
  },
  {
    id: 'igh', group: 'team', pattern: 'igh', sound: 'ai', ipa: ['aɪ'],
    re: /(?<!e)igh/,
    explain: 'igh đọc "ai", chữ gh không đọc.',
    examples: [{ word: 'high', ipa: '/ˈhaɪ/' }, { word: 'night', ipa: '/ˈnaɪt/' }, { word: 'light', ipa: '/ˈlaɪt/' }, { word: 'right', ipa: '/ˈraɪt/' }, { word: 'fight', ipa: '/ˈfaɪt/' }],
  },
  {
    id: 'eigh', group: 'team', pattern: 'eigh', sound: 'ây', ipa: ['eɪ'],
    re: /eigh/,
    explain: 'eigh đọc "ây", gh không đọc.',
    examples: [{ word: 'eight', ipa: '/ˈeɪt/' }, { word: 'weight', ipa: '/ˈweɪt/' }, { word: 'neighbour', ipa: '/ˈneɪbɝ/' }, { word: 'freight', ipa: '/ˈfreɪt/' }, { word: 'sleigh', ipa: '/ˈsleɪ/' }],
  },
  {
    id: 'au-aw', group: 'team', pattern: 'au / aw', sound: 'o / a', ipa: ['ɔ', 'ɑ'],
    re: /(?<!e)a(?:u|w(?![aeiou]))/,
    explain: 'au, aw đọc "o" dài (giọng Mỹ gần "a").',
    examples: [{ word: 'law', ipa: '/ˈlɔ/' }, { word: 'saw', ipa: '/ˈsɔ/' }, { word: 'draw', ipa: '/ˈdrɔ/' }, { word: 'cause', ipa: '/ˈkɔz/' }, { word: 'August', ipa: '/ˈɔɡəst/' }],
  },
  {
    id: 'ew', group: 'team', pattern: 'ew', sound: 'u / yu', ipa: ['u', 'ju'],
    re: /ew(?![aeiouh])/,
    explain: 'ew đọc "u" hoặc "yu".',
    examples: [{ word: 'new', ipa: '/ˈnu/' }, { word: 'few', ipa: '/ˈfju/' }, { word: 'grew', ipa: '/ˈɡru/' }, { word: 'news', ipa: '/ˈnuz/' }, { word: 'flew', ipa: '/ˈflu/' }],
  },

  // Nguyên âm + r
  {
    id: 'ar', group: 'r', pattern: 'ar', sound: 'ar', ipa: ['ɑr', 'ɝ', 'ɑ', 'ə'],
    re: /(?<!w|qu|e|o)ar(?![aeiouyr])/,
    explain: 'ar đọc "a" kéo dài kèm âm r: car, park. Ở âm tiết không nhấn đọc nhẹ thành "ơr" (popular, sugar).',
    examples: [{ word: 'car', ipa: '/ˈkɑr/' }, { word: 'park', ipa: '/ˈpɑrk/' }, { word: 'star', ipa: '/ˈstɑr/' }, { word: 'farm', ipa: '/ˈfɑrm/' }, { word: 'hard', ipa: '/ˈhɑrd/' }],
    exceptions: 'Sau w thì ar đọc "or": war, warm.',
  },
  {
    id: 'or', group: 'r', pattern: 'or', sound: 'or', ipa: ['ɔr', 'oʊr', 'or', 'ɝ', 'ɔ', 'ə'],
    re: /(?<!w|o)or(?![aeiouyr])/,
    explain: 'or đọc "o" kèm âm r. Ở âm tiết không nhấn đọc nhẹ thành "ơr" (doctor, visitor).',
    examples: [{ word: 'fork', ipa: '/ˈfɔrk/' }, { word: 'short', ipa: '/ˈʃɔrt/' }, { word: 'born', ipa: '/ˈbɔrn/' }, { word: 'horse', ipa: '/ˈhɔrs/' }, { word: 'sport', ipa: '/ˈspɔrt/' }],
    exceptions: 'Sau w thì or đọc "ơr": word, work, world.',
  },
  {
    id: 'er-ir-ur', group: 'r', pattern: 'er / ir / ur', sound: 'ơr', ipa: ['ɝ', 'ər', 'ə'],
    re: /(?<![aeiou])[eiu]r(?![aeiouyr])/,
    explain: 'er, ir, ur đều đọc giống nhau là "ơr".',
    examples: [{ word: 'her', ipa: '/ˈhɝ/' }, { word: 'bird', ipa: '/ˈbɝd/' }, { word: 'girl', ipa: '/ˈɡɝl/' }, { word: 'turn', ipa: '/ˈtɝn/' }, { word: 'nurse', ipa: '/ˈnɝs/' }],
  },

  // Phụ âm
  {
    id: 'ph', group: 'consonant', pattern: 'ph', sound: 'ph (f)', ipa: ['f'], re: /ph/, when: (_w, ipa) => !normalizeIpa(ipa).includes('ph'),
    explain: 'ph đọc như "ph" tiếng Việt (âm f).',
    examples: [{ word: 'phone', ipa: '/ˈfoʊn/' }, { word: 'photo', ipa: '/ˈfoʊtoʊ/' }, { word: 'graph', ipa: '/ˈɡræf/' }, { word: 'alphabet', ipa: '/ˈælfəˌbɛt/' }, { word: 'elephant', ipa: '/ˈɛləfənt/' }],
  },
  {
    id: 'ch', group: 'consonant', pattern: 'ch', sound: 'ch', ipa: ['tʃ'], re: /(?<!t)ch/, when: (w) => !CH_K.test(w),
    explain: 'ch thường đọc "ch" bật hơi, mạnh hơn tiếng Việt.',
    examples: [{ word: 'chair', ipa: '/ˈtʃɛr/' }, { word: 'much', ipa: '/ˈmətʃ/' }, { word: 'lunch', ipa: '/ˈləntʃ/' }, { word: 'teach', ipa: '/ˈtitʃ/' }, { word: 'cheese', ipa: '/ˈtʃiz/' }],
  },
  {
    id: 'ch-k', group: 'consonant', pattern: 'ch (gốc Hy Lạp)', sound: 'k', ipa: ['k'], re: CH_K,
    explain: 'Từ gốc Hy Lạp có ch đọc "k": chr-, sch-, tech-, -ache, chem-, psych-, mechan-.',
    examples: [{ word: 'school', ipa: '/ˈskul/' }, { word: 'technology', ipa: '/tɛkˈnɑlədʒi/' }, { word: 'chemistry', ipa: '/ˈkɛmɪstri/' }, { word: 'headache', ipa: '/ˈhɛdeɪk/' }, { word: 'Christmas', ipa: '/ˈkrɪsməs/' }],
  },
  {
    id: 'sh', group: 'consonant', pattern: 'sh', sound: 'sh', ipa: ['ʃ'], re: /sh/, when: (_w, ipa) => !normalizeIpa(ipa).includes('sh'),
    explain: 'sh đọc như "s" uốn lưỡi, môi hơi chu ra.',
    examples: [{ word: 'ship', ipa: '/ˈʃɪp/' }, { word: 'fish', ipa: '/ˈfɪʃ/' }, { word: 'shop', ipa: '/ˈʃɑp/' }, { word: 'wash', ipa: '/ˈwɑʃ/' }, { word: 'short', ipa: '/ˈʃɔrt/' }],
  },
  {
    id: 'th', group: 'consonant', pattern: 'th', sound: 'th (đặt lưỡi giữa răng)', ipa: ['θ', 'ð'], re: /th/, when: (_w, ipa) => !normalizeIpa(ipa).includes('th'),
    explain: 'th đặt đầu lưỡi giữa hai răng rồi thổi hơi. Không rung cổ trong think, rung cổ trong this.',
    examples: [{ word: 'think', ipa: '/ˈθɪŋk/' }, { word: 'three', ipa: '/ˈθri/' }, { word: 'mouth', ipa: '/ˈmaʊθ/' }, { word: 'this', ipa: '/ˈðɪs/' }, { word: 'mother', ipa: '/ˈməðɝ/' }],
    exceptions: 'Thomas, Thailand đọc "t".',
  },
  {
    id: 'ck', group: 'consonant', pattern: 'ck', sound: 'k', ipa: ['k'], re: /ck/,
    explain: 'ck đọc một âm "k".',
    examples: [{ word: 'back', ipa: '/ˈbæk/' }, { word: 'clock', ipa: '/ˈklɑk/' }, { word: 'duck', ipa: '/ˈdək/' }, { word: 'kick', ipa: '/ˈkɪk/' }, { word: 'pocket', ipa: '/ˈpɑkət/' }],
  },
  {
    id: 'wh', group: 'consonant', pattern: 'wh', sound: 'w', ipa: ['w'], re: /^wh/,
    explain: 'wh đầu từ đọc "w", chữ h không đọc.',
    examples: [{ word: 'what', ipa: '/ˈwət/' }, { word: 'when', ipa: '/ˈwɛn/' }, { word: 'white', ipa: '/ˈwaɪt/' }, { word: 'which', ipa: '/ˈwɪtʃ/' }, { word: 'why', ipa: '/ˈwaɪ/' }],
  },
  {
    id: 'kn', group: 'consonant', pattern: 'kn', sound: 'n (k câm)', re: /^kn/, check: startsWith('n'),
    explain: 'kn đầu từ: chữ k không đọc.',
    examples: [{ word: 'know', ipa: '/ˈnoʊ/' }, { word: 'knife', ipa: '/ˈnaɪf/' }, { word: 'knee', ipa: '/ˈni/' }, { word: 'knock', ipa: '/ˈnɑk/' }, { word: 'knit', ipa: '/ˈnɪt/' }],
  },
  {
    id: 'wr', group: 'consonant', pattern: 'wr', sound: 'r (w câm)', re: /^wr/, check: startsWith('r'),
    explain: 'wr đầu từ: chữ w không đọc.',
    examples: [{ word: 'write', ipa: '/ˈraɪt/' }, { word: 'wrong', ipa: '/ˈrɔŋ/' }, { word: 'wrap', ipa: '/ˈræp/' }, { word: 'wrist', ipa: '/ˈrɪst/' }, { word: 'writer', ipa: '/ˈraɪtɝ/' }],
  },
  {
    id: 'mb', group: 'consonant', pattern: 'mb', sound: 'm (b câm)', re: /mb$/, check: endsWith('m'),
    explain: 'mb cuối từ: chữ b không đọc.',
    examples: [{ word: 'tomb', ipa: '/ˈtum/' }, { word: 'comb', ipa: '/ˈkoʊm/' }, { word: 'thumb', ipa: '/ˈθəm/' }, { word: 'lamb', ipa: '/ˈlæm/' }, { word: 'bomb', ipa: '/ˈbɑm/' }],
  },
  {
    id: 'qu', group: 'consonant', pattern: 'qu', sound: 'kw', ipa: ['kw'], re: /qu(?!e$|et$)/,
    explain: 'qu đọc "kw" (giống "qu" tiếng Việt).',
    examples: [{ word: 'queen', ipa: '/ˈkwin/' }, { word: 'quick', ipa: '/ˈkwɪk/' }, { word: 'question', ipa: '/ˈkwɛstʃən/' }, { word: 'quiet', ipa: '/ˈkwaɪət/' }, { word: 'quality', ipa: '/ˈkwɑləti/' }],
  },
  {
    id: 'tch-dge', group: 'consonant', pattern: 'tch / dge', sound: 'ch / j', ipa: ['tʃ', 'dʒ'], re: /tch|dge/,
    explain: 'tch đọc "ch", dge đọc "j" (t và d không đọc riêng).',
    examples: [{ word: 'watch', ipa: '/ˈwɑtʃ/' }, { word: 'kitchen', ipa: '/ˈkɪtʃən/' }, { word: 'catch', ipa: '/ˈkætʃ/' }, { word: 'bridge', ipa: '/ˈbrɪdʒ/' }, { word: 'judge', ipa: '/ˈdʒədʒ/' }],
  },
  {
    id: 'soft-c', group: 'consonant', pattern: 'c + e/i/y', sound: 's', ipa: ['s'], re: /c(?=e(?![aou])|i(?![aeou])|y)/,
    explain: 'c đứng trước e, i, y đọc "s" (c mềm). Trước a, o, u và phụ âm đọc "k".',
    examples: [{ word: 'city', ipa: '/ˈsɪti/' }, { word: 'face', ipa: '/ˈfeɪs/' }, { word: 'nice', ipa: '/ˈnaɪs/' }, { word: 'cycle', ipa: '/ˈsaɪkəl/' }, { word: 'centre', ipa: '/ˈsɛntɝ/' }],
    exceptions: 'ocean đọc "sh".',
  },
  {
    id: 'ci-sh', group: 'consonant', pattern: 'ci / ce + nguyên âm', sound: 'sh', ipa: ['ʃ'], re: /(?<!s)c(?=i[aeou]|ean$)/,
    explain: 'ci, ce đứng trước một nguyên âm khác đọc "sh": special, ancient, ocean.',
    examples: [{ word: 'special', ipa: '/ˈspɛʃəl/' }, { word: 'social', ipa: '/ˈsoʊʃəl/' }, { word: 'ancient', ipa: '/ˈeɪnʃənt/' }, { word: 'delicious', ipa: '/dɪˈlɪʃəs/' }, { word: 'official', ipa: '/əˈfɪʃəl/' }],
  },
  {
    id: 'soft-g', group: 'consonant', pattern: 'g + e/i/y', sound: 'j', ipa: ['dʒ'], re: /g(?=[eiy])/,
    explain: 'g đứng trước e, i, y thường đọc "j" (g mềm). Trước a, o, u đọc "g".',
    examples: [{ word: 'age', ipa: '/ˈeɪdʒ/' }, { word: 'giant', ipa: '/ˈdʒaɪənt/' }, { word: 'energy', ipa: '/ˈɛnɝdʒi/' }, { word: 'page', ipa: '/ˈpeɪdʒ/' }, { word: 'gym', ipa: '/ˈdʒɪm/' }],
  },
  {
    id: 'y-one', group: 'consonant', pattern: 'y cuối từ (1 âm tiết)', sound: 'ai', ipa: ['aɪ'],
    re: /(?<=^[^aeiouy]+)y$/,
    explain: 'y cuối từ một âm tiết đọc "ai".',
    examples: [{ word: 'my', ipa: '/ˈmaɪ/' }, { word: 'fly', ipa: '/ˈflaɪ/' }, { word: 'cry', ipa: '/ˈkraɪ/' }, { word: 'try', ipa: '/ˈtraɪ/' }, { word: 'sky', ipa: '/ˈskaɪ/' }],
  },
  {
    id: 'y-many', group: 'consonant', pattern: 'y cuối từ (nhiều âm tiết)', sound: 'i', ipa: ['i'],
    re: /(?<=[aeiou].*[^aeiouy])(?<!f|pl|fl)y$/,
    explain: 'y cuối từ nhiều âm tiết đọc "i".',
    examples: [{ word: 'happy', ipa: '/ˈhæpi/' }, { word: 'city', ipa: '/ˈsɪti/' }, { word: 'baby', ipa: '/ˈbeɪbi/' }, { word: 'family', ipa: '/ˈfæməli/' }, { word: 'very', ipa: '/ˈvɛri/' }],
  },

  {
    id: 'fy-ply', group: 'consonant', pattern: '-fy / -ply', sound: 'ai', ipa: ['aɪ'], re: /(?:[^f]fy|ply)$/,
    // Trạng từ -ly (sharply, deeply) không thuộc quy tắc này.
    when: (w, _ipa, pos) => vowelGroups(w) >= 2 && pos !== 'adverb',
    explain: 'Động từ tận cùng -fy, -ply thì y đọc "ai", không đọc "i".',
    examples: [{ word: 'identify', ipa: '/aɪˈdɛntəˌfaɪ/' }, { word: 'classify', ipa: '/ˈklæsəˌfaɪ/' }, { word: 'apply', ipa: '/əˈplaɪ/' }, { word: 'supply', ipa: '/səˈplaɪ/' }, { word: 'reply', ipa: '/rɪˈplaɪ/' }],
  },

  // Đuôi từ
  {
    id: 'tion', group: 'ending', pattern: '-tion / -sion', sound: 'shơn / jơn', ipa: ['ʃən', 'ʃn', 'ʒən', 'tʃən'],
    re: /[ts]ion$/,
    explain: '-tion đọc "shơn"; -sion đọc "shơn" hoặc "jơn" (television).',
    examples: [{ word: 'station', ipa: '/ˈsteɪʃən/' }, { word: 'nation', ipa: '/ˈneɪʃən/' }, { word: 'action', ipa: '/ˈækʃən/' }, { word: 'decision', ipa: '/dɪˈsɪʒən/' }, { word: 'mission', ipa: '/ˈmɪʃən/' }],
  },
  {
    id: 'ture', group: 'ending', pattern: '-ture', sound: 'chơr', ipa: ['tʃɝ', 'tʃər'], re: /ture$/,
    explain: '-ture đọc "chơr".',
    examples: [{ word: 'picture', ipa: '/ˈpɪktʃɝ/' }, { word: 'nature', ipa: '/ˈneɪtʃɝ/' }, { word: 'future', ipa: '/ˈfjutʃɝ/' }, { word: 'culture', ipa: '/ˈkəltʃɝ/' }, { word: 'temperature', ipa: '/ˈtɛmpɝətʃɝ/' }],
  },
  {
    id: 'ous', group: 'ending', pattern: '-ous', sound: 'ơs', ipa: ['əs'], re: /ous$/,
    explain: '-ous đọc nhẹ là "ơs", không đọc "ao".',
    examples: [{ word: 'famous', ipa: '/ˈfeɪməs/' }, { word: 'dangerous', ipa: '/ˈdeɪndʒɝəs/' }, { word: 'nervous', ipa: '/ˈnɝvəs/' }, { word: 'various', ipa: '/ˈvɛriəs/' }, { word: 'delicious', ipa: '/dɪˈlɪʃəs/' }],
  },
  {
    id: 'le', group: 'ending', pattern: 'phụ âm + le', sound: 'ơl', re: /(?<=[^aeiouy])le$/, check: endsWith('əl', 'l'),
    when: (w) => /[aeiouy]/.test(w.slice(0, -3)),
    explain: 'Phụ âm + le cuối từ đọc "ơl": table = TÂY-bơl.',
    examples: [{ word: 'table', ipa: '/ˈteɪbəl/' }, { word: 'little', ipa: '/ˈlɪtəl/' }, { word: 'apple', ipa: '/ˈæpəl/' }, { word: 'simple', ipa: '/ˈsɪmpəl/' }, { word: 'middle', ipa: '/ˈmɪdəl/' }],
  },
  {
    id: 'age', group: 'ending', pattern: '-age (không nhấn)', sound: 'ij', re: /age$/, check: endsWith('ɪdʒ', 'ədʒ'),
    when: (w) => vowelGroups(w) >= 2,
    explain: '-age ở âm tiết không nhấn đọc "ij", không đọc "ây".',
    examples: [{ word: 'village', ipa: '/ˈvɪlɪdʒ/' }, { word: 'message', ipa: '/ˈmɛsɪdʒ/' }, { word: 'language', ipa: '/ˈlæŋɡwɪdʒ/' }, { word: 'manage', ipa: '/ˈmænɪdʒ/' }, { word: 'image', ipa: '/ˈɪmɪdʒ/' }],
  },
  {
    id: 'ed', group: 'ending', pattern: '-ed', sound: 't / d / id', re: /(?!)/,
    explain: '-ed quá khứ: đọc "t" sau âm p, k, s, sh, ch, f (stopped); đọc "id" sau t, d (wanted, needed); còn lại đọc "d" (played).',
    examples: [{ word: 'stopped', ipa: '/ˈstɑpt/' }, { word: 'watched', ipa: '/ˈwɑtʃt/' }, { word: 'played', ipa: '/ˈpleɪd/' }, { word: 'wanted', ipa: '/ˈwɑntɪd/' }, { word: 'needed', ipa: '/ˈnidɪd/' }],
  },

  // Trọng âm
  {
    id: 'stress-noun', group: 'stress', pattern: 'danh từ / tính từ 2 âm tiết', sound: 'nhấn âm đầu', re: /^.+$/,
    when: (w, ipa, pos) => (pos === 'noun' || pos === 'adjective') && syllableCount(ipa) === 2 && !STRESS_SUFFIX.test(w),
    check: (_n, _w, raw) => stressIndex(raw) === 0,
    explain: 'Phần lớn danh từ và tính từ hai âm tiết nhấn âm thứ nhất.',
    examples: [{ word: 'table', ipa: '/ˈteɪbəl/' }, { word: 'happy', ipa: '/ˈhæpi/' }, { word: 'student', ipa: '/ˈstudənt/' }, { word: 'water', ipa: '/ˈwɔtɝ/' }, { word: 'pretty', ipa: '/ˈprɪti/' }],
  },
  {
    id: 'stress-verb', group: 'stress', pattern: 'động từ 2 âm tiết', sound: 'nhấn âm sau', re: /^.+$/,
    when: (w, ipa, pos) => pos === 'verb' && syllableCount(ipa) === 2 && !VERB_FIRST_STRESS.test(w),
    check: (_n, _w, raw) => stressIndex(raw) === 1,
    explain: 'Phần lớn động từ hai âm tiết nhấn âm thứ hai, trừ khi tận cùng -er, -en, -ish, -y, -ow, -el, -it (answer, open, finish, study, follow).',
    examples: [{ word: 'begin', ipa: '/bɪˈɡɪn/' }, { word: 'relax', ipa: '/rɪˈlæks/' }, { word: 'decide', ipa: '/dɪˈsaɪd/' }, { word: 'forget', ipa: '/fɝˈɡɛt/' }, { word: 'enjoy', ipa: '/ɛnˈdʒɔɪ/' }],
    exceptions: 'promise, practise, offer nhấn âm đầu.',
  },
  {
    id: 'stress-suffix', group: 'stress', pattern: '-tion, -sion, -ic, -ical, -ity, -ian, -ial, -ious', sound: 'nhấn ngay trước đuôi',
    re: STRESS_SUFFIX, when: (w) => vowelGroups(w) >= (/ity$/.test(w) ? 3 : 2),
    check: (_n, w, raw) => {
      const n = syllableCount(raw);
      const i = stressIndex(raw);
      // -ical, -ity chiếm hai âm tiết. -ious/-ial/-ian đọc tách "i-ơs" (serious) cũng chiếm hai.
      const twoSyllableSuffix = /(?:ical|ity)$/.test(w) || /i[əɪ][sln]$/.test(_n);
      return twoSyllableSuffix ? i === n - 3 : i === n - 2;
    },
    explain: 'Từ có các đuôi này luôn nhấn vào âm tiết ngay trước đuôi: eduCAtion, ecoNOmic, uniVERsity (trước -ity), muSIcian.',
    examples: [{ word: 'education', ipa: '/ˌɛdʒəˈkeɪʃən/' }, { word: 'information', ipa: '/ˌɪnfɝˈmeɪʃən/' }, { word: 'economic', ipa: '/ˌɛkəˈnɑmɪk/' }, { word: 'electricity', ipa: '/ɪˌlɛkˈtrɪsəti/' }, { word: 'musician', ipa: '/mjuˈzɪʃən/' }],
  },
];

/** Từ thông dụng đọc khác mặt chữ, cần nhớ riêng. */
export const IRREGULAR_WORDS: { word: string; ipa: string; note: string }[] = [
  { word: 'one', ipa: '/ˈwən/', note: 'đọc như "won", có âm w ở đầu' },
  { word: 'two', ipa: '/ˈtu/', note: 'w không đọc' },
  { word: 'said', ipa: '/ˈsɛd/', note: 'ai đọc "e", không đọc "ây"' },
  { word: 'says', ipa: '/ˈsɛz/', note: 'ay đọc "e"' },
  { word: 'have', ipa: '/ˈhæv/', note: 'e câm nhưng a vẫn đọc ngắn' },
  { word: 'give', ipa: '/ˈɡɪv/', note: 'e câm nhưng i vẫn đọc ngắn' },
  { word: 'come', ipa: '/ˈkəm/', note: 'o đọc "ă"' },
  { word: 'some', ipa: '/ˈsəm/', note: 'o đọc "ă"' },
  { word: 'love', ipa: '/ˈləv/', note: 'o đọc "ă"' },
  { word: 'done', ipa: '/ˈdən/', note: 'o đọc "ă"' },
  { word: 'move', ipa: '/ˈmuv/', note: 'o đọc "u"' },
  { word: 'were', ipa: '/ˈwɝ/', note: 'đọc "wơr"' },
  { word: 'women', ipa: '/ˈwɪmən/', note: 'o đầu đọc "i": WI-mơn' },
  { word: 'woman', ipa: '/ˈwʊmən/', note: 'o đọc "u"' },
  { word: 'friend', ipa: '/ˈfrɛnd/', note: 'ie đọc "e"' },
  { word: 'people', ipa: '/ˈpipəl/', note: 'eo đọc "i"' },
  { word: 'busy', ipa: '/ˈbɪzi/', note: 'u đọc "i"' },
  { word: 'business', ipa: '/ˈbɪznəs/', note: 'u đọc "i", i giữa không đọc' },
  { word: 'build', ipa: '/ˈbɪld/', note: 'u không đọc' },
  { word: 'blood', ipa: '/ˈbləd/', note: 'oo đọc "ă"' },
  { word: 'does', ipa: '/ˈdəz/', note: 'oe đọc "ă"' },
  { word: 'eye', ipa: '/ˈaɪ/', note: 'đọc "ai"' },
  { word: 'laugh', ipa: '/ˈlæf/', note: 'augh đọc "ef"' },
  { word: 'enough', ipa: '/ɪˈnəf/', note: 'ough đọc "ăf"' },
  { word: 'though', ipa: '/ˈðoʊ/', note: 'ough đọc "âu"' },
  { word: 'through', ipa: '/ˈθru/', note: 'ough đọc "u"' },
  { word: 'thought', ipa: '/ˈθɔt/', note: 'ough đọc "o"' },
  { word: 'cough', ipa: '/ˈkɔf/', note: 'ough đọc "of"' },
  { word: 'would', ipa: '/ˈwʊd/', note: 'l không đọc' },
  { word: 'could', ipa: '/ˈkʊd/', note: 'l không đọc' },
  { word: 'should', ipa: '/ˈʃʊd/', note: 'l không đọc' },
  { word: 'walk', ipa: '/ˈwɔk/', note: 'l không đọc' },
  { word: 'talk', ipa: '/ˈtɔk/', note: 'l không đọc' },
  { word: 'half', ipa: '/ˈhæf/', note: 'l không đọc' },
  { word: 'listen', ipa: '/ˈlɪsən/', note: 't không đọc' },
  { word: 'castle', ipa: '/ˈkæsəl/', note: 't không đọc' },
  { word: 'often', ipa: '/ˈɔfən/', note: 't thường không đọc' },
  { word: 'answer', ipa: '/ˈænsɝ/', note: 'w không đọc' },
  { word: 'island', ipa: '/ˈaɪlənd/', note: 's không đọc: AI-lơnd' },
  { word: 'hour', ipa: '/ˈaʊɝ/', note: 'h không đọc' },
  { word: 'honest', ipa: '/ˈɑnəst/', note: 'h không đọc' },
  { word: 'debt', ipa: '/ˈdɛt/', note: 'b không đọc' },
  { word: 'doubt', ipa: '/ˈdaʊt/', note: 'b không đọc' },
  { word: 'receipt', ipa: '/rɪˈsit/', note: 'p không đọc' },
  { word: 'psychology', ipa: '/saɪˈkɑlədʒi/', note: 'p không đọc' },
  { word: 'Wednesday', ipa: '/ˈwɛnzdeɪ/', note: 'd và e giữa không đọc: WENZ-dây' },
  { word: 'colour', ipa: '/ˈkəlɝ/', note: 'o đầu đọc "ă"' },
  { word: 'color', ipa: '/ˈkəlɝ/', note: 'o đầu đọc "ă"' },
  { word: 'sugar', ipa: '/ˈʃʊɡɝ/', note: 's đọc "sh"' },
  { word: 'sure', ipa: '/ˈʃʊr/', note: 's đọc "sh"' },
  { word: 'ocean', ipa: '/ˈoʊʃən/', note: 'c đọc "sh"' },
  { word: 'machine', ipa: '/məˈʃin/', note: 'ch đọc "sh", i đọc "i" dài' },
  { word: 'police', ipa: '/pəˈlis/', note: 'i đọc "i" dài, nhấn âm sau' },
  { word: 'minute', ipa: '/ˈmɪnət/', note: 'u_e không đọc "yu": MI-nơt' },
  { word: 'recipe', ipa: '/ˈrɛsəpi/', note: 'e cuối có đọc: RE-sơ-pi' },
  { word: 'iron', ipa: '/ˈaɪɝn/', note: 'đọc "AI-ơrn"' },
  { word: 'heart', ipa: '/ˈhɑrt/', note: 'ear đọc "ar"' },
  { word: 'bear', ipa: '/ˈbɛr/', note: 'ear đọc "er"' },
  { word: 'great', ipa: '/ˈɡreɪt/', note: 'ea đọc "ây"' },
  { word: 'break', ipa: '/ˈbreɪk/', note: 'ea đọc "ây"' },
  { word: 'head', ipa: '/ˈhɛd/', note: 'ea đọc "e"' },
  { word: 'bread', ipa: '/ˈbrɛd/', note: 'ea đọc "e"' },
  { word: 'country', ipa: '/ˈkəntri/', note: 'ou đọc "ă"' },
  { word: 'young', ipa: '/ˈjəŋ/', note: 'ou đọc "ă"' },
  { word: 'stomach', ipa: '/ˈstəmək/', note: 'o đọc "ă", ch đọc "k"' },
  { word: 'foreign', ipa: '/ˈfɔrən/', note: 'g không đọc' },
  { word: 'knowledge', ipa: '/ˈnɑlɪdʒ/', note: 'k không đọc, ow đọc "a"' },
];

const IRREGULAR = new Map(IRREGULAR_WORDS.map((w) => [w.word.toLowerCase(), w]));

export interface PhonicsHint {
  rule?: PhonicsRule;
  /** true: từ đọc đúng theo quy tắc. false: từ là ngoại lệ của quy tắc. */
  follows: boolean;
  focus?: [number, number];
  note: string;
}

/** Vị trí phần chữ khớp quy tắc, để tô đậm. */
export function ruleFocus(rule: PhonicsRule, word: string): [number, number] | undefined {
  const m = rule.re.exec(word.toLowerCase());
  return m ? [m.index, m.index + m[0].length] : undefined;
}

function confirms(rule: PhonicsRule, ipa: string, word: string): boolean {
  const norm = normalizeIpa(ipa);
  if (rule.check) return rule.check(norm, word, ipa);
  return (rule.ipa ?? []).some((s) => norm.includes(normalizeIpa(s) || s));
}

/**
 * Ngoại lệ có quy luật của từng quy tắc: nhóm từ đọc khác quy tắc chính nhưng giống nhau, học theo nhóm dễ hơn nhớ từng từ.
 * re dò trên mặt chữ; ipa hoặc check xác nhận bằng phiên âm thật (giống PhonicsRule).
 */
export interface ExceptionFamily {
  re: RegExp;
  ipa?: string[];
  check?: (norm: string, word: string, raw: string) => boolean;
  note: string;
  examples: string;
}

const stressAt = (index: number) => (_n: string, _w: string, raw: string) => stressIndex(raw) === index;
const stressLast = (_n: string, _w: string, raw: string) => {
  const n = syllables(raw).length;
  return n >= 2 && stressIndex(raw) === n - 1;
};

export const EXCEPTION_FAMILIES: Record<string, ExceptionFamily[]> = {
  'short-a': [
    { re: /(?:w|qu)a/, ipa: ['ɑ', 'ɔ', 'ə'], note: 'Sau w, qu thì a đọc gần "o"', examples: 'want, wash, what, quality' },
  ],
  'short-o': [
    { re: /o(?=n$|nt$|nth|nk|m$|ve)/, ipa: ['ʌ', 'ə'], note: 'o trước n, nt, nk, nth, m cuối từ thường đọc "ă"', examples: 'son, front, month, monk, from' },
    { re: /o(?=st$|th$|ll$|lt$)/, ipa: ['oʊ'], note: 'o trước -st, -th, -ll, -lt thường đọc "âu"', examples: 'most, post, both, roll, bolt' },
  ],
  'short-u': [
    { re: /(?<=[pbf])u(?=ll|sh|t$|ss)/, ipa: ['ʊ'], note: 'u sau p, b, f và trước ll, sh, t thường đọc "u" ngắn', examples: 'put, push, pull, full, bull, bush' },
    { re: /u(?=th$)/, ipa: ['u'], note: 'u trong -uth đọc "u" dài', examples: 'truth, youth' },
  ],
  'old-ind': [
    { re: /ind$/, ipa: ['ɪ'], note: 'Danh từ wind (gió) và các từ ghép của nó đọc "i" ngắn', examples: 'wind, whirlwind' },
  ],
  a_e: [
    { re: /a(?=[gr]e$|ge$)/, ipa: ['ɑ'], note: 'Từ mượn tiếng Pháp tận cùng -age, -ade đọc "a" dài', examples: 'garage, massage, mirage' },
    { re: /a(?=ve$)/, ipa: ['æ'], note: 'have không theo quy tắc e câm', examples: 'have' },
  ],
  i_e: [
    { re: /i(?=ve$)/, ipa: ['ɪ'], note: 'i trước -ve đọc "i" ngắn ở động từ give, live và đuôi -ive', examples: 'give, live, forgive, active' },
    { re: /i(?=(?:n|m|qu|ch|g|t)e$)/, ipa: ['i'], note: 'Từ mượn tiếng Pháp tận cùng -ine, -ime, -ique, -ite đọc "i" dài', examples: 'machine, routine, regime, elite, police' },
  ],
  o_e: [
    { re: /o(?=[vmn]e$)/, ipa: ['ʌ', 'ə'], note: 'o trước -ve, -me, -ne thường đọc "ă"', examples: 'love, glove, above, come, become, done' },
    { re: /o(?=[vs]e$)/, ipa: ['u'], note: 'move, prove, lose, whose: o đọc "u"', examples: 'move, prove, improve, lose' },
  ],
  e_e: [
    { re: /e(?=ge$)/, ipa: ['ɛ', 'ɪ', 'ə'], note: '-ege đọc "ej/ij"', examples: 'allege, college' },
  ],
  'ai-ay': [
    { re: /ai(?=n$|nly)/, ipa: ['ə', 'ɪ'], note: '-ain ở âm tiết không nhấn đọc nhẹ "ơn"', examples: 'mountain, captain, certain' },
    { re: /ai(?=d$|s$)/, ipa: ['ɛ'], note: 'said, says: ai/ay đọc "e"', examples: 'said, says' },
  ],
  ea: [
    { re: /ea(?=d|th|lth|lous|sure|ther|ven|vy|vil|kfast|pon)/, ipa: ['ɛ'], note: 'ea trước d, th, -sure, -ther, -vy thường đọc "e"', examples: 'head, bread, breath, health, pleasure, weather, heavy' },
    { re: /ea(?=[kt]$|k[^n])/, ipa: ['eɪ'], note: 'great, break, steak: ea đọc "ây"', examples: 'great, break, steak' },
    { re: /eau/, ipa: ['ju', 'oʊ'], note: 'eau (gốc Pháp) đọc "yu" hoặc "âu"', examples: 'beauty, beautiful, bureau' },
  ],
  oa: [
    { re: /broad/, ipa: ['ɔ'], note: 'broad (và abroad, broadcast) đọc "o"', examples: 'broad, abroad, broadband' },
  ],
  oo: [
    { re: /oo(?=d)/, ipa: ['ʌ', 'ə'], note: 'blood, flood: oo đọc "ă"', examples: 'blood, flood' },
    { re: /oo(?=p[eɝ])/, ipa: ['oʊ'], note: 'coo-p (cooperate): hai chữ o thuộc hai âm tiết', examples: 'cooperate, coordinate' },
  ],
  ou: [
    { re: /ou(?=ch|ng|ble|ple|rage|ntry|sin|gh$)/, ipa: ['ʌ', 'ə'], note: 'ou trước ch, ng, -ble, -ple, -ntry đọc "ă"', examples: 'touch, young, double, couple, country, cousin' },
    { re: /ou(?=p|te|th|ve|ti|r$)|^you/, ipa: ['u'], note: 'ou trong từ gốc Pháp và you đọc "u"', examples: 'soup, route, routine, youth, souvenir, you' },
    { re: /ou(?=l(?!d$))/, ipa: ['oʊ'], note: 'ou trước l đọc "âu"', examples: 'soul, shoulder, poultry' },
    { re: /ou(?=ld$)/, ipa: ['ʊ'], note: 'could, would, should: ou đọc "u" ngắn, l câm', examples: 'could, would, should' },
    { re: /ou(?=sly|sness)/, ipa: ['ə'], note: 'Đuôi -ous(ly) đọc nhẹ "ơs"', examples: 'previously, seriously' },
  ],
  'oi-oy': [
    { re: /oi(?=n|r)|oy(?=o)/, ipa: ['oʊ', 'aɪ', 'wɑ', 'kwaɪ'], note: 'oi tách thành hai âm tiết hoặc từ mượn (heroin, choir, reservoir)', examples: 'heroin, coincide, choir, reservoir' },
  ],
  'au-aw': [
    { re: /au(?=gh|nt)/, ipa: ['æ'], note: 'laugh, aunt: au đọc "e" (giọng Mỹ)', examples: 'laugh, laughter, aunt' },
    { re: /au(?=th)/, ipa: ['ə', 'ɔ'], note: 'au trước th ở âm tiết không nhấn đọc nhẹ', examples: 'authentic, authority' },
  ],
  ew: [
    { re: /ew/, ipa: ['oʊ'], note: 'sew đọc "sâu"', examples: 'sew' },
  ],
  ow: [
    { re: /ow(?=l)/, ipa: ['ɑ'], note: 'knowledge, acknowledge: ow đọc "a"', examples: 'knowledge, acknowledge' },
  ],
  ar: [
    { re: /ar(?=c|ce)/, ipa: ['ɛr'], note: 'scarce, scarcely: ar đọc "er"', examples: 'scarce, scarcely' },
    { re: /ar(?=sh)/, ipa: ['ɝ', 'əʃ'], note: 'ar ở âm tiết không nhấn đọc nhẹ "ơ"', examples: 'scholarship' },
  ],
  'er-ir-ur': [
    { re: /ur(?=p)|er(?=g)/, ipa: ['ə'], note: 'Âm tiết không nhấn đọc nhẹ thành "ơ"', examples: 'surprise, sergeant' },
  ],
  ch: [
    { re: /^ch(?=ef|ic|ampagne|alet|auffeur|ure)|chine|chure|ache$|ch(?=ute|ure)/, ipa: ['ʃ'], note: 'Từ gốc Pháp có ch đọc "sh"', examples: 'chef, machine, brochure, parachute, moustache' },
    { re: /ch/, ipa: ['k'], note: 'Một số từ gốc Hy Lạp khác cũng đọc ch là "k"', examples: 'anchor, hierarchy, cholesterol, archaic' },
  ],
  'ch-k': [
    { re: /ache$/, ipa: ['ʃ'], note: 'moustache (gốc Pháp): ch đọc "sh"', examples: 'moustache' },
    { re: /sch(?=ief)/, ipa: ['stʃ'], note: 'mischief: s và ch đọc riêng', examples: 'mischief' },
  ],
  'ci-sh': [
    { re: /ci(?=e|o)/, ipa: ['s'], note: 'Khi i được nhấn (so-CI-ety) thì c vẫn đọc "s"', examples: 'society, sociology' },
  ],
  'soft-c': [
    { re: /c(?=e[l]|e[r]t)/, ipa: ['tʃ'], note: 'Từ mượn tiếng Ý: c đọc "ch"', examples: 'cello, concerto' },
  ],
  'soft-g': [
    { re: /gg/, ipa: ['g'], note: 'gg luôn đọc "g" cứng', examples: 'foggy, bigger, luggage (ngoại lệ: suggest)' },
    { re: /(?<=n)g(?=e[rs]|est)/, ipa: ['ŋg'], note: 'ng + ge/ger/gest đọc "ng-g" (cả hai âm)', examples: 'finger, longer, stronger, youngest' },
    { re: /g(?=e$)/, ipa: ['ʒ'], note: 'Từ gốc Pháp: -ge cuối từ đọc "j" nhẹ', examples: 'garage, beige, massage' },
    { re: /g(?=e[tr]|iv|ir|ift|ear|ild|ive|ig|il)|ng(?=er|ing)|(?<=be)gin|(?<=to)ge|(?<=ti)ger/, ipa: ['g'], note: 'Từ gốc Anh cổ giữ g cứng trước e, i', examples: 'get, give, girl, gift, finger, begin, together, tiger' },
  ],
  qu: [
    { re: /qu(?=e(?:t|ue)?$|ette|in)/, ipa: ['k'], note: 'Từ gốc Pháp: qu đọc "k" (u câm)', examples: 'queue, etiquette, mannequin, mosque' },
    { re: /(?<=n)qu|(?<=s)qu(?=i)/, ipa: ['k'], note: 'conquer, mosquito: qu đọc "k"', examples: 'conquer, mosquito' },
  ],
  wh: [
    { re: /^who/, check: (n) => n.startsWith('h'), note: 'who, whose, whole: wh đọc "h"', examples: 'who, whose, whom, whole' },
  ],
  th: [
    { re: /sth/, check: (n) => !n.includes('θ') && !n.includes('ð'), note: 'asthma, isthmus: th không đọc', examples: 'asthma' },
  ],
  sh: [],
  igh: [
    { re: /aigh/, ipa: ['eɪ'], note: 'aigh đọc "ây"', examples: 'straight' },
  ],
  eigh: [
    { re: /eigh(?=t$)/, ipa: ['aɪ'], note: 'height đọc "hait"', examples: 'height' },
  ],
  'y-many': [
    { re: /(?:by|ny|cry|ly)$/, ipa: ['aɪ'], note: 'Từ ghép với by, ally, deny, July: y đọc "ai"', examples: 'nearby, deny, July, ally, lullaby' },
  ],
  'fy-ply': [],
  age: [
    { re: /age$/, ipa: ['ɑʒ', 'ɑdʒ'], note: 'Từ mượn tiếng Pháp tận cùng -age đọc "aj" và nhấn âm cuối', examples: 'garage, massage, sabotage, mirage' },
  ],
  ture: [
    { re: /ture$/, ipa: ['tʃʊr', 'kʃɝ'], note: 'mature, premature nhấn vào -ture; fracture đọc "k-chơr"', examples: 'mature, fracture' },
  ],
  'stress-noun': [
    { re: /^(?:a|be|de|re|ex|ef|e|pre|pro|per|con|com|dis|mis|in|im|ac|ad|af|ap|as|at|ob|of|op|sup|sus|un|en|em)(?=[a-z]{2})/, check: stressAt(1), note: 'Từ có tiền tố (a-, be-, de-, re-, ex-, con-, per-…) thường nhấn vào gốc từ ở âm sau', examples: 'alone, afraid, delay, device, effect, research, exam, percent' },
    { re: /(?:ee|eer|ese|oo|oon|ique|ette)$/, check: stressLast, note: 'Đuôi -ee, -eer, -ese, -oon, -ique, -ette luôn được nhấn', examples: 'degree, career, Chinese, balloon, technique, cassette' },
    { re: /teen$/, check: stressLast, note: 'Số đếm -teen nhấn vào -teen', examples: 'thirteen, fifteen' },
    { re: /^(?:hotel|police|ballet|cafe|café|machine|routine|technique|cassette|cigarette|garage|massage|bouquet|champagne)$/, check: stressLast, note: 'Từ mượn tiếng Pháp giữ trọng âm ở âm cuối', examples: 'hotel, police, ballet, garage' },
  ],
  'stress-verb': [
    { re: /ate$/, check: stressAt(0), note: 'Động từ hai âm tiết tận cùng -ate thường nhấn âm đầu (giọng Mỹ)', examples: 'locate, migrate, donate, rotate' },
    { re: /^(?:down|up|out|over|under|back|for|fore|with|by|in)(?=[a-z]{3})/, check: stressAt(0), note: 'Động từ ghép (download, upload) thường nhấn âm đầu', examples: 'download, upload, forward' },
    { re: /^(?:import|export|refuse|record|present|object|produce|increase|decrease|permit|contrast|protest|insult)$/, check: stressAt(0), note: 'Cặp danh từ/động từ: danh từ nhấn âm đầu, động từ nhấn âm sau; từ điển này đang ghi cách đọc danh từ', examples: 'IMport (n) / imPORT (v), REcord (n) / reCORD (v)' },
  ],
  'stress-suffix': [
    { re: /ic$/, check: (_n, _w, raw) => stressIndex(raw) === syllables(raw).length - 3, note: 'Ngoại lệ quen thuộc của -ic: Arabic, politics, rhetoric, catholic, heretic, lunatic nhấn âm đầu', examples: 'politics, rhetoric, Arabic' },
    { re: /sion$/, check: stressAt(0), note: 'television nhấn âm đầu', examples: 'television' },
  ],
};

/** Âm nguyên âm trong IPA, theo thứ tự xuất hiện, kèm cách đọc chữ Việt. */
function ipaVowels(raw: string): string[] {
  const norm = normalizeIpa(raw);
  const out: string[] = [];
  const keys = Object.keys(VOWELS).sort((a, b) => b.length - a.length).map((k) => (k === 'e' ? 'ɛ' : k));
  for (let i = 0; i < norm.length; ) {
    const hit = keys.find((k) => norm.startsWith(k, i));
    if (hit) {
      let label = VOWELS[hit] ?? VOWELS[hit === 'ɛ' ? 'ɛ' : hit] ?? '';
      if (norm[i + hit.length] === 'r' && !label.endsWith('r')) label += 'r';
      out.push(label);
      i += hit.length;
    } else {
      i++;
    }
  }
  return out;
}

/** Thứ tự nhóm nguyên âm (theo mặt chữ) chứa vị trí start. */
function vowelGroupIndex(word: string, start: number): number {
  return (word.slice(0, start).match(/[aeiou]+|(?<=[^aeiou])y/g) ?? []).length;
}

/** Cách đọc thật của phần chữ tô đậm trong từ này (chỉ cho quy tắc về nguyên âm). */
function actualVowel(word: string, raw: string, focus: [number, number]): string | null {
  const vowels = ipaVowels(raw);
  const groups = (word.match(/[aeiou]+|(?<=[^aeiou])y/g) ?? []).length - (/[^aeiou]e$/.test(word) ? 1 : 0);
  // Số nhóm nguyên âm theo mặt chữ khác số nguyên âm trong phiên âm thì khó gióng chính xác: bỏ qua.
  if (groups !== vowels.length) return null;
  return vowels[vowelGroupIndex(word, focus[0])] ?? null;
}

const VOWEL_GROUPS = new Set(['short', 'magic-e', 'team', 'r']);

function familyFor(rule: PhonicsRule, word: string, raw: string): ExceptionFamily | undefined {
  const norm = normalizeIpa(raw);
  return (EXCEPTION_FAMILIES[rule.id] ?? []).find((f) => {
    if (!f.re.test(word)) return false;
    if (f.check) return f.check(norm, word, raw);
    return (f.ipa ?? []).some((x) => norm.includes(normalizeIpa(x) || x));
  });
}

/** Âm mong đợi của quy tắc nguyên âm, viết bằng chữ Việt để so với âm thật. */
function expectedVowels(rule: PhonicsRule): string[] {
  return (rule.ipa ?? []).map((x) => ipaVowels(`/${x}/`).join(''));
}

/**
 * Từ có theo quy tắc không. Quy tắc nguyên âm so đúng âm ở vị trí phần chữ tô đậm (heavy: ea đọc "e", dù cuối từ
 * có âm "i"); không gióng được vị trí thì so trên cả phiên âm.
 */
function followsRule(rule: PhonicsRule, word: string, raw: string, focus: [number, number]): boolean {
  if (VOWEL_GROUPS.has(rule.group) && rule.ipa) {
    const actual = actualVowel(word, raw, focus);
    if (actual !== null) return expectedVowels(rule).includes(actual);
  }
  return confirms(rule, raw, word);
}

/** Giải thích vì sao từ này không theo quy tắc. */
function explainException(rule: PhonicsRule, word: string, raw: string, focus: [number, number]): string {
  const family = familyFor(rule, word, raw);
  if (family) return `Ngoại lệ có quy luật: ${family.note} (${family.examples}).`;
  const part = word.slice(focus[0], focus[1]);
  if (rule.group === 'stress') {
    const sylls = syllables(raw);
    const i = stressIndex(raw);
    if (i >= 0) return `Ngoại lệ: từ này nhấn âm thứ ${i + 1} (${sylls[i]}), không theo quy tắc "${rule.sound}".`;
  }
  if (VOWEL_GROUPS.has(rule.group)) {
    const actual = actualVowel(word, raw, focus);
    if (actual) return `Ngoại lệ: "${part}" ở từ này đọc "${actual}" (thường đọc "${rule.sound}").`;
  }
  return `Ngoại lệ: "${part}" thường đọc "${rule.sound}", nhưng từ này đọc ${respell(raw)}.`;
}

/** Quy tắc nào áp dụng cho từ này và từ có theo quy tắc không. Ngoại lệ xếp trước. */
export function phonicsHints(word: string, phonetic: string | null | undefined, pos?: string | null, limit = 4): PhonicsHint[] {
  const lower = word.toLowerCase().trim();
  // Bỏ qua cụm từ, từ ghép có gạch nối (mỗi phần đã có thẻ riêng) và chữ viết tắt (OK, USB).
  if (!phonetic || /[\s-]/.test(lower) || lower.length < 2 || (word === word.toUpperCase() && /[A-Z]{2}/.test(word))) return [];
  const irregular = IRREGULAR.get(lower);
  if (irregular) return [{ follows: false, note: `Đọc bất quy tắc: ${irregular.note}.` }];
  const out: PhonicsHint[] = [];
  for (const rule of PHONICS_RULES) {
    if (rule.id === 'ed') continue;
    const focus = ruleFocus(rule, lower);
    if (!focus) continue;
    if (rule.when && !rule.when(lower, phonetic, pos)) continue;
    const follows = followsRule(rule, lower, phonetic, focus);
    const note = follows ? `${rule.pattern} → ${rule.sound}` : explainException(rule, lower, phonetic, focus);
    out.push({ rule, follows, focus: rule.group === 'stress' ? undefined : focus, note });
  }
  // Ngoại lệ trước, quy tắc trọng âm sau cùng.
  const rank = (h: PhonicsHint) => (h.follows ? 1 : 0) * 2 + (h.rule?.group === 'stress' ? 1 : 0);
  return out.sort((a, b) => rank(a) - rank(b)).slice(0, limit);
}
