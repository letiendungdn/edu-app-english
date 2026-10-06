import { Component, computed, input, output } from '@angular/core';
import { AnswerResult, QuestionGroupView, QuestionItem } from '../core/models';

const TYPED = new Set([
  'SENTENCE_COMPLETION',
  'SUMMARY_COMPLETION',
  'NOTE_COMPLETION',
  'TABLE_COMPLETION',
  'FLOW_CHART_COMPLETION',
  'DIAGRAM_LABEL',
  'SHORT_ANSWER',
  'FORM_COMPLETION',
  'MAP_LABELLING',
]);
const MATCHING = new Set(['MATCHING_HEADINGS', 'MATCHING_INFORMATION', 'MATCHING_FEATURES', 'MATCHING_SENTENCE_ENDINGS']);

/**
 * Vẽ một nhóm câu hỏi IELTS theo dạng của nhóm. Khi có results thì chuyển sang chế độ xem đáp án: khoá ô nhập,
 * đánh dấu đúng/sai, hiện đáp án, giải thích và đoạn trích chứa đáp án.
 */
@Component({
  selector: 'app-question-group',
  template: `
    <section class="q-group">
      <p class="q-instruction">{{ group().instruction }}</p>
      @if (group().wordLimit) {
        <span class="badge badge-B1">Tối đa {{ group().wordLimit }} từ</span>
      }
      @if (kind() === 'matching' && group().options.length) {
        <div class="card option-box">
          @for (o of group().options; track o.key) {
            <div><strong>{{ o.key }}</strong>&nbsp; {{ o.text }}</div>
          }
        </div>
      }

      @for (q of group().questions; track q.id) {
        <div class="q-item" [class.q-correct]="mark(q) === 'ok'" [class.q-wrong]="mark(q) === 'bad'" [class.q-partial]="mark(q) === 'part'">
          @switch (kind()) {
            @case ('typed') {
              <p>
                <span class="q-number">{{ q.number }}</span>
                @for (part of parts(q); track $index; let last = $last) {
                  <span>{{ part }}</span>
                  @if (!last) {
                    <input class="blank-input" [value]="value(q)" [disabled]="locked()" [attr.aria-label]="'Câu ' + q.number"
                      (input)="set(q, $any($event.target).value)" autocomplete="off" spellcheck="false" />
                  }
                }
              </p>
              @if (!hasBlank(q)) {
                <input class="blank-input wide" [value]="value(q)" [disabled]="locked()" [attr.aria-label]="'Câu ' + q.number"
                  (input)="set(q, $any($event.target).value)" autocomplete="off" spellcheck="false" />
              }
            }
            @case ('judgement') {
              <p><span class="q-number">{{ q.number }}</span>{{ q.prompt }}</p>
              <div class="row">
                @for (choice of judgementChoices(); track choice) {
                  <button type="button" class="btn btn-sm" [class.btn-primary]="value(q) === choice" [disabled]="locked()" (click)="set(q, choice)">
                    {{ choice }}
                  </button>
                }
              </div>
            }
            @case ('matching') {
              <div class="row" style="flex-wrap: nowrap;">
                <span class="q-number">{{ q.number }}</span>
                <span style="flex: 1;">{{ q.prompt }}</span>
                <select style="width: auto; min-width: 5rem;" [value]="value(q)" [disabled]="locked()" (change)="set(q, $any($event.target).value)"
                  [attr.aria-label]="'Câu ' + q.number">
                  <option value="">–</option>
                  @for (o of group().options; track o.key) {
                    <option [value]="o.key" [selected]="value(q) === o.key">{{ o.key }}</option>
                  }
                </select>
              </div>
            }
            @case ('multi') {
              <p><span class="q-number">{{ q.number }}</span>{{ q.prompt }}</p>
              @for (o of q.options; track o.key) {
                <label class="option" [class.selected]="chosen(q).includes(o.key)">
                  <input type="checkbox" [checked]="chosen(q).includes(o.key)" [disabled]="locked()" (change)="toggle(q, o.key)" />
                  <strong>{{ o.key }}</strong> {{ o.text }}
                </label>
              }
            }
            @default {
              <p><span class="q-number">{{ q.number }}</span>{{ q.prompt }}</p>
              @for (o of q.options; track o.key) {
                <label class="option" [class.selected]="value(q) === o.key">
                  <input type="radio" [name]="'q-' + q.id" [checked]="value(q) === o.key" [disabled]="locked()" (change)="set(q, o.key)" />
                  <strong>{{ o.key }}</strong> {{ o.text }}
                </label>
              }
            }
          }

          @if (result(q); as r) {
            <div class="q-feedback">
              <span>{{ r.points }}/{{ r.maxPoints }} · Đáp án: <strong>{{ r.correctAnswer }}</strong></span>
              @if (r.given) { <span class="muted"> · Bạn trả lời: {{ r.given }}</span> }
              @if (r.explanation) { <p class="muted">{{ r.explanation }}</p> }
              @if (r.evidence) { <p class="evidence">“{{ r.evidence }}”</p> }
            </div>
          }
        </div>
      }
    </section>
  `,
})
export class QuestionGroupComponent {
  readonly group = input.required<QuestionGroupView>();
  readonly answers = input<Record<string, string>>({});
  readonly results = input<AnswerResult[] | null>(null);
  readonly disabled = input(false);
  readonly answer = output<{ questionId: number; value: string }>();

  readonly kind = computed(() => {
    const type = this.group().type;
    if (TYPED.has(type)) return 'typed';
    if (MATCHING.has(type)) return 'matching';
    if (type === 'TRUE_FALSE_NOT_GIVEN' || type === 'YES_NO_NOT_GIVEN') return 'judgement';
    if (type === 'MULTIPLE_CHOICE_MULTI') return 'multi';
    return 'choice';
  });

  readonly judgementChoices = computed(() =>
    this.group().type === 'YES_NO_NOT_GIVEN' ? ['YES', 'NO', 'NOT GIVEN'] : ['TRUE', 'FALSE', 'NOT GIVEN'],
  );

  private readonly resultById = computed(() => {
    const map = new Map<number, AnswerResult>();
    for (const r of this.results() ?? []) map.set(r.questionId, r);
    return map;
  });

  locked() {
    return this.disabled() || this.results() != null;
  }

  value(q: QuestionItem) {
    return this.answers()[String(q.id)] ?? '';
  }

  chosen(q: QuestionItem) {
    return this.value(q).split(',').filter(Boolean);
  }

  hasBlank(q: QuestionItem) {
    return q.prompt.includes('{{blank}}');
  }

  parts(q: QuestionItem) {
    return this.hasBlank(q) ? q.prompt.split('{{blank}}') : [q.prompt];
  }

  set(q: QuestionItem, value: string) {
    this.answer.emit({ questionId: q.id, value });
  }

  toggle(q: QuestionItem, key: string) {
    const current = this.chosen(q);
    const next = current.includes(key) ? current.filter((k) => k !== key) : [...current, key].sort();
    this.set(q, next.join(','));
  }

  result(q: QuestionItem) {
    return this.resultById().get(q.id) ?? null;
  }

  mark(q: QuestionItem) {
    const r = this.result(q);
    if (!r) return null;
    if (r.points === r.maxPoints) return 'ok';
    return r.points > 0 ? 'part' : 'bad';
  }
}
