import { Pipe, PipeTransform } from '@angular/core';


/**
 * Đổi phiên âm IPA (kiểu Mỹ trong vocab.json) sang cách đọc bằng chữ Việt để người chưa quen IPA vẫn đọc được.
 * Ví dụ /həˈloʊ/ → "hơ-LÂU", /ˈstɹaɪv/ → "STRAIV". Âm tiết nhấn chính viết hoa.
 * Đây là cách đọc gần đúng: phụ âm cuối tiếng Anh (s, v, z...) được giữ nguyên để người học nhớ phải bật âm cuối.
 */

export const VOWELS: Record<string, string> = {
  'eɪ': 'ây', 'aɪ': 'ai', 'aʊ': 'ao', 'ɔɪ': 'oi', 'oʊ': 'âu',
  i: 'i', ɪ: 'i', e: 'e', ɛ: 'e', æ: 'e', a: 'a', ɑ: 'a', ɒ: 'o', ɔ: 'o', o: 'ô',
  ʊ: 'u', u: 'u', ə: 'ơ', ʌ: 'ă', ɝ: 'ơr', ɜ: 'ơ',
};

const CONSONANTS: Record<string, string> = {
  'tʃ': 'ch', 'dʒ': 'j', p: 'p', b: 'b', t: 't', d: 'đ', k: 'k', ɡ: 'g', f: 'ph', v: 'v',
  θ: 'th', ð: 'đ', s: 's', z: 'z', ʃ: 'sh', ʒ: 'j', h: 'h', m: 'm', n: 'n', ŋ: 'ng',
  l: 'l', ɫ: 'l', ɹ: 'r', r: 'r', w: 'w', j: 'y',
};

// Phụ âm cuối: tiếng Việt không có "đ", "ph" ở cuối nên dùng chữ Latin quen thuộc.
const CODA: Record<string, string> = { d: 'd', ð: 'd', f: 'f', k: 'k' };

type Phone = { kind: 'v' | 'c'; ipa: string } | { kind: 'stress'; primary: boolean };

function tokenize(ipa: string): Phone[] {
  const out: Phone[] = [];
  let i = 0;
  while (i < ipa.length) {
    const ch = ipa[i];
    if (ch === 'ˈ' || ch === 'ˌ') { out.push({ kind: 'stress', primary: ch === 'ˈ' }); i++; continue; }
    if (ch === 'ː') { i++; continue; }
    const two = ipa.slice(i, i + 2);
    if (VOWELS[two]) { out.push({ kind: 'v', ipa: two }); i += 2; continue; }
    if (CONSONANTS[two]) { out.push({ kind: 'c', ipa: two }); i += 2; continue; }
    if (VOWELS[ch]) out.push({ kind: 'v', ipa: ch });
    else if (CONSONANTS[ch]) out.push({ kind: 'c', ipa: ch });
    i++;
  }
  return out;
}

interface Syllable { onset: string[]; vowel: string; coda: string[]; stressed: boolean }

function syllabify(phones: Phone[]): Syllable[] {
  const sylls: Syllable[] = [];
  let pending: string[] = [];
  let pendingStress = false;
  let markIndex = -1; // vị trí trong pending nơi dấu nhấn chen vào = ranh giới âm tiết
  for (const p of phones) {
    if (p.kind === 'stress') { pendingStress = p.primary; markIndex = pending.length; continue; }
    if (p.kind === 'c') { pending.push(p.ipa); continue; }
    const prev = sylls[sylls.length - 1];
    let split = 0;
    if (prev) {
      // Có dấu nhấn: ranh giới đúng theo từ điển. Không có: một phụ âm sang âm sau, còn lại ở lại âm trước.
      split = markIndex >= 0 ? markIndex : Math.max(0, pending.length - 1);
      prev.coda.push(...pending.slice(0, split));
    }
    sylls.push({ onset: pending.slice(split), vowel: p.ipa, coda: [], stressed: pendingStress });
    pending = [];
    pendingStress = false;
    markIndex = -1;
  }
  const last = sylls[sylls.length - 1];
  if (last) {
    // Âm tiết hóa ở cuối từ (/bl/ trong "able") thì thêm "ơ".
    const tail = pending.slice();
    if (tail.length >= 2 && (tail[tail.length - 1] === 'ɫ' || tail[tail.length - 1] === 'l')) {
      last.coda.push(...tail.slice(0, -2));
      sylls.push({ onset: [tail[tail.length - 2]], vowel: 'ə', coda: ['l'], stressed: false });
    } else {
      last.coda.push(...tail);
    }
  }
  return sylls;
}

function writeOnset(onset: string[], vowel: string): string {
  const letters = onset.map((c) => CONSONANTS[c] ?? '');
  const front = /^[ieêây]/.test(vowel);
  const lastIdx = letters.length - 1;
  if (lastIdx >= 0) {
    // Chính tả tiếng Việt: k/c và g/gh tùy nguyên âm theo sau.
    if (letters[lastIdx] === 'k' && !front) letters[lastIdx] = 'c';
    if (letters[lastIdx] === 'g' && front) letters[lastIdx] = 'gh';
  }
  return letters.join('');
}

function writeSyllable(s: Syllable): string {
  let vowel = VOWELS[s.vowel] ?? '';
  const coda = s.coda.map((c) => CODA[c] ?? CONSONANTS[c] ?? '').join('');
  // "ă" không đứng một mình trong tiếng Việt: không có âm cuối thì đọc như "ơ".
  if (vowel === 'ă' && !coda) vowel = 'ơ';
  // "ơr" + r ở âm cuối thì bỏ trùng.
  const tail = vowel.endsWith('r') && coda.startsWith('r') ? coda.slice(1) : coda;
  const text = writeOnset(s.onset, vowel) + vowel + tail;
  return s.stressed ? text.toUpperCase() : text;
}

function respellWord(ipa: string): string {
  const sylls = syllabify(tokenize(ipa));
  if (!sylls.length) return '';
  // Từ một âm tiết không có dấu nhấn vẫn coi là nhấn.
  if (sylls.length === 1) sylls[0].stressed = true;
  return sylls.map(writeSyllable).join('-');
}

/** "/ˈoʊpən ˈmaɪndəd/" → "ÂU-pơn MAIN-đơđ". Trả về chuỗi rỗng khi không có IPA. */
export function respell(phonetic: string | null | undefined): string {
  if (!phonetic) return '';
  const body = phonetic.replace(/[\/\[\]]/g, '').trim();
  if (!body) return '';
  return body.split(/\s+/).map(respellWord).filter(Boolean).join(' ');
}

/** Dùng trong template: {{ word.phonetic | respell }}. */
@Pipe({ name: 'respell', standalone: true })
export class RespellPipe implements PipeTransform {
  transform(phonetic: string | null | undefined): string {
    return respell(phonetic);
  }
}
