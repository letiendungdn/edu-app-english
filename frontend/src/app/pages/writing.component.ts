import { Component, computed, inject, OnDestroy, OnInit, signal } from '@angular/core';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { ApiService } from '../core/api.service';
import { AuthService } from '../core/auth.service';
import { AiStatus, WritingPromptView, WritingSubmissionView } from '../core/ielts.models';
import { ChartComponent } from '../shared/chart.component';
import { FeedbackComponent } from '../shared/feedback.component';

const KIND_LABELS: Record<string, string> = {
  LINE: 'Biểu đồ đường',
  BAR: 'Biểu đồ cột',
  PIE: 'Biểu đồ tròn',
  TABLE: 'Bảng số liệu',
  PROCESS: 'Quy trình',
  MAP: 'Bản đồ',
  LETTER: 'Viết thư',
  OPINION: 'Agree / Disagree',
  DISCUSSION: 'Discuss both views',
  PROBLEM_SOLUTION: 'Problem & Solution',
  ADVANTAGE_DISADVANTAGE: 'Advantages & Disadvantages',
  TWO_PART: 'Two-part question',
};

/** Banner trạng thái AI: chưa bật thì báo trước, để người học không viết xong mới biết không chấm được. */
@Component({
  selector: 'app-ai-banner',
  template: `
    @if (status(); as s) {
      @if (!s.enabled) {
        <div class="card warn">AI chấm bài chưa được bật trên máy chủ (thiếu APP_AI_API_KEY). Bài vẫn được lưu và có thể chấm lại sau.</div>
      } @else {
        <p class="muted" style="font-size: 0.85rem;">Hôm nay đã chấm {{ s.usedToday }}/{{ s.dailyLimit }} bài.</p>
      }
    }
  `,
})
export class AiBannerComponent implements OnInit {
  private api = inject(ApiService);
  private auth = inject(AuthService);
  status = signal<AiStatus | null>(null);
  ngOnInit() {
    if (this.auth.loggedIn()) this.api.aiStatus().subscribe((s) => this.status.set(s));
  }
}

@Component({
  selector: 'app-writing',
  imports: [RouterLink, AiBannerComponent],
  template: `
    <div class="container page" style="max-width: 900px;">
      <div class="row" style="justify-content: space-between;">
        <h1>Writing</h1>
        <a class="btn" routerLink="/history">Bài đã nộp</a>
      </div>
      <app-ai-banner />
      <div class="row" style="margin: 1rem 0;">
        <button class="btn" [class.btn-primary]="task() === 'TASK1'" (click)="task.set('TASK1')">Task 1</button>
        <button class="btn" [class.btn-primary]="task() === 'TASK2'" (click)="task.set('TASK2')">Task 2</button>
      </div>
      <div class="grid">
        @for (p of filtered(); track p.id) {
          <a class="card" [routerLink]="['/writing', p.id]" style="text-decoration: none;">
            <span class="badge badge-B2">{{ kind(p.taskKind) }}</span>
            @if (p.module === 'GENERAL') { <span class="badge badge-C2">General</span> }
            @if (p.attempted) { <span class="badge badge-A2">Đã viết</span> }
            <h2 style="margin-top: 0.4rem;">{{ p.title }}</h2>
            <p class="muted">{{ p.topic }} · tối thiểu {{ p.minWords }} từ</p>
          </a>
        }
      </div>
    </div>
  `,
})
export class WritingComponent implements OnInit {
  private api = inject(ApiService);
  prompts = signal<WritingPromptView[]>([]);
  task = signal<'TASK1' | 'TASK2'>('TASK2');
  filtered = computed(() => this.prompts().filter((p) => p.task === this.task()));
  ngOnInit() {
    this.api.writingPrompts().subscribe((p) => this.prompts.set(p));
  }
  kind(k: string) {
    return KIND_LABELS[k] ?? k;
  }
}

@Component({
  selector: 'app-writing-editor',
  imports: [RouterLink, ChartComponent, AiBannerComponent],
  template: `
    <div class="container page">
      <a routerLink="/writing" class="muted">← Writing</a>
      @if (prompt(); as p) {
        <h1 style="margin: 0.75rem 0;">{{ p.task === 'TASK1' ? 'Task 1' : 'Task 2' }}: {{ p.title }}</h1>
        <app-ai-banner />
        <div class="split">
          <div class="card">
            <p class="passage">{{ p.prompt }}</p>
            <app-chart [json]="p.chartData" />
          </div>
          <div>
            <textarea class="essay" [value]="text()" (input)="onInput($any($event.target).value)" spellcheck="false"
              placeholder="Viết bài ở đây…" aria-label="Bài viết"></textarea>
            <div class="row" style="justify-content: space-between;">
              <span [class.error]="words() < p.minWords">{{ words() }} / {{ p.minWords }} từ</span>
              <span class="muted">⏱ {{ elapsed() }} · gợi ý {{ p.task === 'TASK1' ? 20 : 40 }} phút</span>
            </div>
            @if (error()) { <p class="error">{{ error() }}</p> }
            <button class="btn btn-primary" style="margin-top: 0.75rem;" (click)="submit()" [disabled]="busy() || words() < 20">Nộp bài để chấm</button>
            <p class="muted" style="font-size: 0.8rem; margin-top: 0.5rem;">Bản nháp tự lưu trên máy này.</p>
          </div>
        </div>
      }
    </div>
  `,
})
export class WritingEditorComponent implements OnInit, OnDestroy {
  private api = inject(ApiService);
  private route = inject(ActivatedRoute);
  private router = inject(Router);
  prompt = signal<WritingPromptView | null>(null);
  text = signal('');
  seconds = signal(0);
  busy = signal(false);
  error = signal('');
  private timer: number | null = null;
  private draftKey = '';

  words = computed(() => {
    const t = this.text().trim();
    return t ? t.split(/\s+/).filter((w) => /[\p{L}\p{N}]/u.test(w)).length : 0;
  });

  elapsed = computed(() => `${Math.floor(this.seconds() / 60)}:${String(this.seconds() % 60).padStart(2, '0')}`);

  ngOnInit() {
    const id = Number(this.route.snapshot.paramMap.get('id'));
    this.draftKey = `writing_draft_${id}`;
    try {
      this.text.set(localStorage.getItem(this.draftKey) ?? '');
    } catch {
      this.text.set('');
    }
    this.api.writingPrompt(id).subscribe((p) => this.prompt.set(p));
    this.timer = window.setInterval(() => this.seconds.update((s) => s + 1), 1000);
  }

  ngOnDestroy() {
    if (this.timer != null) window.clearInterval(this.timer);
  }

  onInput(value: string) {
    this.text.set(value);
    try {
      localStorage.setItem(this.draftKey, value);
    } catch {
      /* bộ nhớ trình duyệt bị chặn: vẫn viết được, chỉ không lưu nháp */
    }
  }

  submit() {
    const p = this.prompt();
    if (!p) return;
    if (this.words() < p.minWords && !confirm(`Bài mới có ${this.words()} từ, ít hơn yêu cầu ${p.minWords} từ. Bài thiếu từ sẽ bị trừ điểm. Vẫn nộp?`)) {
      return;
    }
    this.busy.set(true);
    this.error.set('');
    this.api.submitWriting(p.id, this.text(), this.seconds()).subscribe({
      next: (s) => {
        try {
          localStorage.removeItem(this.draftKey);
        } catch {
          /* bỏ qua */
        }
        void this.router.navigate(['/writing/submissions', s.id]);
      },
      error: (err) => {
        this.busy.set(false);
        this.error.set(err?.error?.error ?? 'Không nộp được bài');
      },
    });
  }
}

@Component({
  selector: 'app-writing-submission',
  imports: [RouterLink, FeedbackComponent],
  template: `
    <div class="container page" style="max-width: 900px;">
      <a routerLink="/writing" class="muted">← Writing</a>
      @if (submission(); as s) {
        <h1 style="margin: 0.75rem 0;">{{ s.promptTitle }}</h1>
        @switch (s.status) {
          @case ('PENDING') { <div class="card warn">AI đang chấm bài, thường mất 20–60 giây. Trang tự cập nhật.</div> }
          @case ('FAILED') {
            <div class="card warn">
              {{ s.error }}
              <button class="btn btn-sm" style="margin-left: 0.5rem;" (click)="regrade()">Chấm lại</button>
            </div>
          }
          @case ('GRADED') { <app-feedback [band]="s.band" [criteria]="s.criteria" [feedback]="s.feedback" /> }
        }
        <details class="card" style="margin-top: 1rem;" [open]="s.status !== 'GRADED'">
          <summary><strong>Bài của bạn</strong> <span class="muted">({{ s.wordCount }} từ)</span></summary>
          <p class="passage" style="margin-top: 0.5rem;">{{ s.text }}</p>
        </details>
        <a class="btn" style="margin-top: 1rem;" [routerLink]="['/writing', s.promptId]">Viết lại đề này</a>
      }
    </div>
  `,
})
export class WritingSubmissionComponent implements OnInit, OnDestroy {
  private api = inject(ApiService);
  private route = inject(ActivatedRoute);
  submission = signal<WritingSubmissionView | null>(null);
  private timer: number | null = null;

  ngOnInit() {
    this.load();
  }

  ngOnDestroy() {
    if (this.timer != null) window.clearTimeout(this.timer);
  }

  private load() {
    this.api.writingSubmission(Number(this.route.snapshot.paramMap.get('id'))).subscribe((s) => {
      this.submission.set(s);
      if (s.status === 'PENDING') this.timer = window.setTimeout(() => this.load(), 4000);
    });
  }

  regrade() {
    const s = this.submission();
    if (!s) return;
    this.api.regradeWriting(s.id).subscribe({
      next: () => this.load(),
      error: (err) => alert(err?.error?.error ?? 'Không chấm lại được'),
    });
  }
}
