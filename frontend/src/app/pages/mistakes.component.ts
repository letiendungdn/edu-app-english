import { Component, computed, inject, OnInit, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { ApiService } from '../core/api.service';
import { MistakeView, QuestionTypeStat, questionTypeLabel, SKILL_LABELS } from '../core/ielts.models';

const SOURCE_LABELS: Record<string, string> = { PRACTICE: 'Bài luyện', MOCK: 'Thi thử', PLACEMENT: 'Đầu vào' };

/**
 * Sổ lỗi sai: mọi câu Reading/Listening đang sai ở lần làm gần nhất. Bấm "Đã hiểu" để cất đi; làm lại đúng thì câu
 * tự ra khỏi sổ. Bên cạnh là độ chính xác theo dạng câu hỏi trong 90 ngày.
 */
@Component({
  selector: 'app-mistakes',
  imports: [RouterLink],
  template: `
    <div class="container page">
      <div class="page-head">
        <div>
          <p class="eyebrow">Theo dõi</p>
          <h1>Sổ lỗi sai</h1>
          <p>Câu Reading và Listening bạn làm sai gần nhất, kèm đáp án, giải thích và đoạn chứa đáp án. Xem lại đều đặn là cách rẻ nhất để lên band.</p>
        </div>
      </div>

      <div class="dash">
        <div>
          <div class="chips" role="group" aria-label="Lọc theo kỹ năng">
            @for (f of filters; track f.value) {
              <button class="btn" [class.btn-primary]="skill() === f.value" (click)="setSkill(f.value)">{{ f.label }}</button>
            }
            @if (typeFilter()) {
              <button class="btn btn-primary" (click)="typeFilter.set('')">{{ typeLabel(typeFilter()) }} ✕</button>
            }
          </div>

          @if (loading()) {
            <p class="muted">Đang tải…</p>
          } @else if (visible().length === 0) {
            <div class="card empty">
              <strong>Không còn câu sai nào</strong>
              @if (items().length === 0) {
                Làm bài Reading, Listening hoặc thi thử, câu sai sẽ tự vào đây.
              } @else {
                Không có câu sai thuộc bộ lọc này.
              }
              <div class="row" style="justify-content: center; margin-top: 1rem;">
                <a class="btn btn-primary" routerLink="/reading">Luyện Reading</a>
                <a class="btn" routerLink="/listening">Luyện Listening</a>
              </div>
            </div>
          } @else {
            <p class="muted small" style="margin-bottom: 0.75rem;">{{ visible().length }} câu cần xem lại</p>
            <div class="stack">
              @for (m of shown(); track m.questionId) {
                <article class="card mistake">
                  <div class="mistake-meta">
                    <span class="badge" [class.badge-A1]="m.skill === 'READING'" [class.badge-A2]="m.skill === 'LISTENING'">{{ skillLabel(m.skill) }}</span>
                    <span class="badge badge-type">{{ typeLabel(m.questionType) }}</span>
                    <span>{{ m.ownerTitle }} · Câu {{ m.number }} · {{ sourceLabel(m.source) }} · {{ m.answeredAt.slice(0, 10) }}</span>
                  </div>
                  <div class="muted small">{{ m.instruction }}</div>
                  <div style="font-weight: 600;">{{ prompt(m.prompt) }}</div>
                  @if (m.options.length) {
                    <div class="option-box card">
                      @for (o of m.options; track o.key) {
                        <div><strong>{{ o.key }}</strong> {{ o.text }}</div>
                      }
                    </div>
                  }
                  <div class="answer-pair">
                    <div class="given"><small>Bạn trả lời</small>{{ m.given || '(bỏ trống)' }}</div>
                    <div class="right"><small>Đáp án</small>{{ m.correctAnswer }}</div>
                  </div>
                  @if (m.explanation) { <div class="small">{{ m.explanation }}</div> }
                  @if (m.evidence) { <div class="evidence small">“{{ m.evidence }}”</div> }
                  <div class="row" style="justify-content: flex-end;">
                    <a class="btn btn-sm" [routerLink]="m.link">Làm lại bài</a>
                    <button class="btn btn-sm btn-primary" (click)="reviewed(m)" [disabled]="busy() === m.questionId">Đã hiểu</button>
                  </div>
                </article>
              }
            </div>
            @if (visible().length > shown().length) {
              <button class="btn" style="width: 100%; margin-top: 0.75rem;" (click)="limit.set(limit() + PAGE)">
                Xem thêm {{ Math.min(PAGE, visible().length - shown().length) }} câu
              </button>
            }
          }
        </div>

        <aside class="dash-side">
          <div class="card">
            <div class="card-head"><h2>Độ chính xác theo dạng câu</h2></div>
            @if (stats().length === 0) {
              <p class="muted small">Chưa có dữ liệu. Thống kê lấy từ bài luyện và bài thi 90 ngày gần nhất.</p>
            }
            @for (s of stats(); track s.type) {
              <div class="type-row" [class.weak]="s.percent < 60" [class.mid]="s.percent >= 60 && s.percent < 80">
                <span>
                  <button class="btn-ghost" style="border: 0; background: none; padding: 0; font: inherit; color: inherit; cursor: pointer; text-align: left;" (click)="typeFilter.set(s.type); limit.set(PAGE)" [attr.aria-label]="'Chỉ xem câu sai dạng ' + typeLabel(s.type)">
                    {{ typeLabel(s.type) }}
                  </button>
                  <span class="muted small"> · {{ s.points }}/{{ s.maxPoints }}</span>
                </span>
                <span class="pct">{{ s.percent }}%</span>
                <div class="bar"><div [style.width.%]="s.percent"></div></div>
                @if (s.weak) {
                  <a class="small" style="grid-column: 1 / -1; color: var(--accent); font-weight: 600; text-decoration: none;"
                     [routerLink]="s.skill === 'LISTENING' ? '/listening' : '/reading'" [queryParams]="{ type: s.type }">Luyện dạng này →</a>
                }
              </div>
            }
            <p class="muted small" style="margin-top: 0.75rem;">Đỏ: dưới 60%, nên luyện thêm. Vàng: 60–79%. Xanh: từ 80%.</p>
          </div>
        </aside>
      </div>
    </div>
  `,
})
export class MistakesComponent implements OnInit {
  private api = inject(ApiService);
  items = signal<MistakeView[]>([]);
  stats = signal<QuestionTypeStat[]>([]);
  skill = signal('');
  typeFilter = signal('');
  loading = signal(true);
  busy = signal<number | null>(null);
  typeLabel = questionTypeLabel;
  readonly PAGE = 15;
  readonly Math = Math;
  limit = signal(this.PAGE);

  filters = [
    { value: '', label: 'Tất cả' },
    { value: 'READING', label: 'Reading' },
    { value: 'LISTENING', label: 'Listening' },
  ];

  visible = computed(() => {
    const type = this.typeFilter();
    return type ? this.items().filter((m) => m.questionType === type) : this.items();
  });

  shown = computed(() => this.visible().slice(0, this.limit()));

  ngOnInit() {
    this.load();
    this.api.questionTypeStats().subscribe((s) => this.stats.set(s));
  }

  setSkill(value: string) {
    this.skill.set(value);
    this.limit.set(this.PAGE);
    this.load();
  }

  reviewed(m: MistakeView) {
    this.busy.set(m.questionId);
    this.api.markMistakeReviewed(m.questionId).subscribe({
      next: () => {
        this.items.update((list) => list.filter((x) => x.questionId !== m.questionId));
        this.busy.set(null);
      },
      error: () => this.busy.set(null),
    });
  }

  /** Câu điền từ có {{blank}}: hiện thành chỗ trống. */
  prompt(text: string) {
    return text.replaceAll('{{blank}}', '______');
  }

  skillLabel(skill: string) {
    return SKILL_LABELS[skill] ?? skill;
  }

  sourceLabel(source: string) {
    return SOURCE_LABELS[source] ?? source;
  }

  private load() {
    this.loading.set(true);
    this.api.mistakes(this.skill()).subscribe({
      next: (items) => {
        this.items.set(items);
        this.loading.set(false);
      },
      error: () => this.loading.set(false),
    });
  }
}
