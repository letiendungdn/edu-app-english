import { Component, computed, DestroyRef, inject, OnInit, signal } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { EXCEPTION_FAMILIES, IRREGULAR_WORDS, PHONICS_GROUPS, PHONICS_RULES, PhonicsRule, ruleFocus } from '../shared/phonics';
import { respell } from '../shared/respell';
import { speakEnglish } from '../shared/flip-card.component';

interface Question {
  rule: PhonicsRule;
  word: string;
  ipa: string;
  parts: [string, string, string];
  prompt: string;
  options: string[];
  answer: number;
}

const QUIZ_SIZE = 10;

function shuffle<T>(items: T[]): T[] {
  const out = [...items];
  for (let i = out.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [out[i], out[j]] = [out[j], out[i]];
  }
  return out;
}

/** Trang quy tắc phát âm (phonics): nhìn mặt chữ đoán cách đọc, kèm bài luyện và danh sách từ bất quy tắc. */
@Component({
  selector: 'app-phonics',
  template: `
    <div class="container page">
      <div class="page-head">
        <div>
          <p class="eyebrow">Phát âm</p>
          <h1>Nhìn chữ đọc đúng</h1>
          <p>Tiếng Anh không đọc đúng 100% theo mặt chữ, nhưng các quy tắc dưới đây đúng cho phần lớn từ thông dụng. Học quy tắc trước, sau đó nhớ riêng các từ ngoại lệ. Bấm vào ví dụ để nghe.</p>
        </div>
      </div>

      <section class="card ph-quiz" aria-live="polite">
        @if (quiz(); as q) {
          @if (current(); as cur) {
            <div class="row" style="justify-content: space-between;">
              <span class="muted small">Câu {{ q.index + 1 }}/{{ q.questions.length }} · đúng {{ q.score }}</span>
              <button class="btn btn-sm btn-ghost" (click)="quiz.set(null)">Dừng</button>
            </div>
            <p class="muted" style="margin: 0.75rem 0 0.25rem;">{{ cur.prompt }}</p>
            <div class="ph-quiz-word">{{ cur.parts[0] }}<b>{{ cur.parts[1] }}</b>{{ cur.parts[2] }}</div>
            <div class="ph-options">
              @for (opt of cur.options; track $index) {
                <button class="option" [class.correct]="q.picked !== null && $index === cur.answer"
                        [class.wrong]="q.picked === $index && $index !== cur.answer"
                        [disabled]="q.picked !== null" (click)="pick($index)">{{ opt }}</button>
              }
            </div>
            @if (q.picked !== null) {
              <div class="ph-feedback">
                <strong>{{ q.picked === cur.answer ? 'Đúng rồi!' : 'Chưa đúng.' }}</strong>
                Đọc: <span class="respell">{{ respellOf(cur.ipa) }}</span> · {{ cur.rule.pattern }} → {{ cur.rule.sound }}.
                <span class="muted">{{ cur.rule.explain }}</span>
                <div class="row" style="margin-top: 0.75rem;">
                  <button class="btn btn-sm" (click)="say(cur.word)">Nghe lại</button>
                  <button class="btn btn-sm btn-primary" (click)="next()">{{ q.index + 1 < q.questions.length ? 'Câu tiếp' : 'Xem kết quả' }}</button>
                </div>
              </div>
            }
          } @else {
            <h2 style="margin: 0;">Bạn đúng {{ q.score }}/{{ q.questions.length }} câu</h2>
            <p class="muted">{{ q.score >= q.questions.length * 0.8 ? 'Rất tốt, chuyển sang nhóm quy tắc khác nhé.' : 'Đọc lại các quy tắc bên dưới rồi luyện thêm một lượt.' }}</p>
            <button class="btn btn-primary" (click)="start()">Luyện lượt mới</button>
          }
        } @else {
          <div class="row" style="justify-content: space-between; align-items: center;">
            <div>
              <h2 style="margin: 0;">Luyện tập</h2>
              <p class="muted small" style="margin: 0.25rem 0 0;">{{ quizSize }} câu: nhìn phần chữ tô đậm và chọn cách đọc, hoặc chọn âm tiết được nhấn.</p>
            </div>
            <div class="row">
              <select [value]="quizGroup()" (change)="quizGroup.set($any($event.target).value)" aria-label="Nhóm quy tắc để luyện">
                <option value="">Tất cả quy tắc</option>
                @for (g of groups; track g.id) { <option [value]="g.id">{{ g.title }}</option> }
              </select>
              <button class="btn btn-primary" (click)="start()">Bắt đầu</button>
            </div>
          </div>
        }
      </section>

      <div class="chips" role="navigation" aria-label="Nhóm quy tắc" style="margin: 1.5rem 0 0.5rem;">
        @for (g of groups; track g.id) { <a class="btn btn-sm" [href]="'#group-' + g.id" (click)="jump($event, 'group-' + g.id)">{{ g.title }}</a> }
        <a class="btn btn-sm" href="#irregular" (click)="jump($event, 'irregular')">Từ bất quy tắc</a>
      </div>

      @for (g of groups; track g.id) {
        <h2 class="section-title" [id]="'group-' + g.id">{{ g.title }}</h2>
        <p class="muted" style="max-width: 46rem; margin-top: -0.25rem;">{{ g.intro }}</p>
        <div class="grid" style="grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));">
          @for (rule of rulesOf(g.id); track rule.id) {
            <article class="card ph-rule" [id]="rule.id" [class.ph-target]="target() === rule.id">
              <div class="row" style="justify-content: space-between; align-items: baseline;">
                <span class="ph-pattern">{{ rule.pattern }}</span>
                <span class="respell">→ {{ rule.sound }}</span>
              </div>
              <p class="small" style="margin: 0.4rem 0;">{{ rule.explain }}</p>
              <div class="ph-examples">
                @for (ex of rule.examples; track ex.word) {
                  <button class="ph-example" (click)="say(ex.word)" [attr.aria-label]="'Nghe ' + ex.word">
                    <span class="ph-word">{{ split(rule, ex.word)[0] }}<b>{{ split(rule, ex.word)[1] }}</b>{{ split(rule, ex.word)[2] }}</span>
                    <span class="muted small">{{ respellOf(ex.ipa) }}</span>
                  </button>
                }
              </div>
              @if (rule.exceptions || familiesOf(rule.id).length) {
                <div class="ph-exceptions small">
                  <b>Ngoại lệ</b>
                  <ul>
                    @for (f of familiesOf(rule.id); track f.note) { <li>{{ f.note }}: <i>{{ f.examples }}</i></li> }
                    @if (rule.exceptions) { <li>{{ rule.exceptions }}</li> }
                  </ul>
                </div>
              }
            </article>
          }
        </div>
      }

      <h2 class="section-title" id="irregular" [class.ph-target]="target() === 'irregular'">Từ đọc bất quy tắc cần nhớ</h2>
      <p class="muted" style="max-width: 46rem; margin-top: -0.25rem;">Những từ rất thông dụng nhưng không đọc theo quy tắc. Không có mẹo nào: nghe và nhớ từng từ.</p>
      <div class="grid" style="grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));">
        @for (w of irregular; track w.word) {
          <button class="card ph-irregular" (click)="say(w.word)" [attr.aria-label]="'Nghe ' + w.word">
            <div class="row" style="justify-content: space-between; align-items: baseline;">
              <strong style="font-size: 1.1rem;">{{ w.word }}</strong>
              <span class="respell">{{ respellOf(w.ipa) }}</span>
            </div>
            <div class="muted small">{{ w.note }}</div>
          </button>
        }
      </div>
    </div>
  `,
})
export class PhonicsComponent implements OnInit {
  private route = inject(ActivatedRoute);
  private destroyRef = inject(DestroyRef);
  groups = PHONICS_GROUPS;
  irregular = IRREGULAR_WORDS;
  quizSize = QUIZ_SIZE;
  quizGroup = signal('');
  target = signal<string | null>(null);
  quiz = signal<{ questions: Question[]; index: number; picked: number | null; score: number } | null>(null);
  current = computed(() => {
    const q = this.quiz();
    return q && q.index < q.questions.length ? q.questions[q.index] : null;
  });

  ngOnInit() {
    // Mở từ gợi ý trên thẻ từ vựng (/phonics#a_e) thì cuộn tới quy tắc đó.
    const sub = this.route.fragment.subscribe((id) => {
      if (!id) return;
      this.target.set(id);
      setTimeout(() => document.getElementById(id)?.scrollIntoView({ behavior: 'smooth', block: 'center' }), 50);
    });
    this.destroyRef.onDestroy(() => sub.unsubscribe());
  }

  familiesOf(ruleId: string) {
    return EXCEPTION_FAMILIES[ruleId] ?? [];
  }

  rulesOf(group: string) {
    return PHONICS_RULES.filter((r) => r.group === group);
  }

  split(rule: PhonicsRule, word: string): [string, string, string] {
    const f = rule.group === 'stress' ? undefined : ruleFocus(rule, word);
    return f ? [word.slice(0, f[0]), word.slice(f[0], f[1]), word.slice(f[1])] : [word, '', ''];
  }

  respellOf(ipa: string) {
    return respell(ipa);
  }

  say(word: string) {
    speakEnglish(word);
  }

  jump(event: Event, id: string) {
    event.preventDefault();
    document.getElementById(id)?.scrollIntoView({ behavior: 'smooth', block: 'start' });
  }

  start() {
    const group = this.quizGroup();
    const pool = PHONICS_RULES.filter((r) => r.id !== 'ed' && (!group || r.group === group));
    const items = shuffle(pool.flatMap((rule) => rule.examples.map((ex) => ({ rule, ex })))).slice(0, QUIZ_SIZE);
    const questions = items.map(({ rule, ex }) => this.question(rule, ex.word, ex.ipa));
    this.quiz.set({ questions, index: 0, picked: null, score: 0 });
  }

  pick(index: number) {
    const q = this.quiz();
    const cur = this.current();
    if (!q || !cur || q.picked !== null) return;
    this.quiz.set({ ...q, picked: index, score: q.score + (index === cur.answer ? 1 : 0) });
    speakEnglish(cur.word);
  }

  next() {
    const q = this.quiz();
    if (q) this.quiz.set({ ...q, index: q.index + 1, picked: null });
  }

  private question(rule: PhonicsRule, word: string, ipa: string): Question {
    if (rule.group === 'stress') {
      // Câu trọng âm: chọn âm tiết được nhấn trong cách đọc.
      const syllables = respell(ipa).split('-');
      const answer = Math.max(0, syllables.findIndex((s) => s === s.toUpperCase() && /\p{Lu}/u.test(s)));
      return {
        rule, word, ipa, parts: [word, '', ''], prompt: 'Âm tiết nào được nhấn?',
        options: syllables.map((s) => s.toLowerCase()), answer,
      };
    }
    // Đáp án nhiễu ưu tiên quy tắc cùng nhóm, khác âm đọc.
    const others = shuffle(PHONICS_RULES.filter((r) => r.group !== 'stress' && r.id !== 'ed' && r.sound !== rule.sound))
      .sort((a, b) => Number(b.group === rule.group) - Number(a.group === rule.group));
    const distractors = [...new Set(others.map((r) => r.sound))].slice(0, 3);
    const options = shuffle([rule.sound, ...distractors]);
    return {
      rule, word, ipa, parts: this.split(rule, word), prompt: 'Phần tô đậm đọc là gì?',
      options, answer: options.indexOf(rule.sound),
    };
  }
}
