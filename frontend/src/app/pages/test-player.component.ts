import { Component, computed, HostListener, inject, OnDestroy, OnInit, signal } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { ApiService } from '../core/api.service';
import { AttemptView, SectionView, SKILL_LABELS } from '../core/ielts.models';
import { ChartComponent } from '../shared/chart.component';
import { QuestionGroupComponent } from '../shared/question-group.component';
import { TtsPlayerComponent } from '../shared/tts-player.component';

const AUTOSAVE_MS = 30_000;

@Component({
  selector: 'app-test-player',
  imports: [QuestionGroupComponent, TtsPlayerComponent, ChartComponent],
  template: `
    @if (attempt(); as a) {
      <div class="test-bar">
        <div class="container row" style="justify-content: space-between;">
          <strong>{{ a.title }}</strong>
          <div class="row">
            <span class="muted" style="font-size: 0.85rem;">{{ saveState() }}</span>
            <span class="timer" [class.urgent]="remaining() < 300">{{ clock() }}</span>
            <button class="btn btn-primary btn-sm" (click)="submit(false)" [disabled]="submitting()">Nộp bài</button>
          </div>
        </div>
        <div class="container tabs">
          @for (s of a.sections; track $index; let i = $index) {
            <button class="tab" [class.active]="i === index()" (click)="go(i)">
              {{ label(s) }}
              <span class="muted">{{ progress(s) }}</span>
            </button>
          }
        </div>
      </div>

      @if (section(); as s) {
        <div class="container page">
          <h2 style="margin-bottom: 0.75rem;">{{ label(s) }}: {{ s.title }}</h2>
          @switch (s.skill) {
            @case ('LISTENING') {
              <app-tts-player [script]="s.ttsScript" [audioUrl]="s.audioUrl" />
              <div style="margin-top: 1rem;">
                @for (g of s.groups; track g.id) {
                  <app-question-group [group]="g" [answers]="answers()" (answer)="setAnswer($event)" />
                }
              </div>
            }
            @case ('READING') {
              <div class="split">
                <article class="card passage">{{ s.body }}</article>
                <div>
                  @for (g of s.groups; track g.id) {
                    <app-question-group [group]="g" [answers]="answers()" (answer)="setAnswer($event)" />
                  }
                </div>
              </div>
            }
            @case ('WRITING') {
              @if (s.writing; as w) {
                <div class="split">
                  <div class="card">
                    <p class="passage">{{ w.prompt }}</p>
                    <app-chart [json]="w.chartData" />
                  </div>
                  <div>
                    <textarea class="essay" [value]="draft(w.id)" (input)="setDraft(w.id, $any($event.target).value)"
                      [attr.aria-label]="'Bài viết ' + s.title" spellcheck="false"></textarea>
                    <div class="row" style="justify-content: space-between;">
                      <span [class.error]="words(w.id) < w.minWords">{{ words(w.id) }} từ</span>
                      <span class="muted">tối thiểu {{ w.minWords }} từ</span>
                    </div>
                  </div>
                </div>
              }
            }
          }
          <div class="row" style="justify-content: space-between; margin-top: 1.5rem;">
            <button class="btn" (click)="go(index() - 1)" [disabled]="index() === 0">← Phần trước</button>
            @if (index() < a.sections.length - 1) {
              <button class="btn btn-primary" (click)="go(index() + 1)">Phần sau →</button>
            } @else {
              <button class="btn btn-primary" (click)="submit(false)" [disabled]="submitting()">Nộp bài</button>
            }
          </div>
        </div>
      }
    } @else {
      <div class="container page"><p class="muted">{{ error() || 'Đang tải bài thi…' }}</p></div>
    }
  `,
})
export class TestPlayerComponent implements OnInit, OnDestroy {
  private api = inject(ApiService);
  private route = inject(ActivatedRoute);
  private router = inject(Router);

  attempt = signal<AttemptView | null>(null);
  index = signal(0);
  answers = signal<Record<string, string>>({});
  drafts = signal<Record<string, string>>({});
  remaining = signal(0);
  dirty = signal(false);
  saving = signal(false);
  lastSaved = signal<Date | null>(null);
  submitting = signal(false);
  error = signal('');
  private timers: number[] = [];

  section = computed<SectionView | null>(() => this.attempt()?.sections[this.index()] ?? null);

  clock = computed(() => {
    const total = Math.max(0, this.remaining());
    const m = Math.floor(total / 60);
    const s = total % 60;
    return `${m}:${String(s).padStart(2, '0')}`;
  });

  saveState = computed(() => {
    if (this.saving()) return 'Đang lưu…';
    if (this.dirty()) return 'Chưa lưu';
    const saved = this.lastSaved();
    return saved ? `Đã lưu ${saved.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' })}` : '';
  });

  ngOnInit() {
    const id = Number(this.route.snapshot.paramMap.get('id'));
    this.api.attempt(id).subscribe({
      next: (a) => {
        if (a.status === 'SUBMITTED') {
          void this.router.navigate(['/tests/attempt', a.id, 'result'], { replaceUrl: true });
          return;
        }
        this.attempt.set(a);
        this.answers.set(a.answers ?? {});
        this.drafts.set(a.writingDrafts ?? {});
        this.tick();
        this.timers.push(window.setInterval(() => this.tick(), 1000));
        this.timers.push(window.setInterval(() => this.save(), AUTOSAVE_MS));
      },
      error: (err) => this.error.set(err?.error?.error ?? 'Không tải được bài thi'),
    });
  }

  ngOnDestroy() {
    this.timers.forEach((t) => window.clearInterval(t));
    if (this.dirty() && !this.submitting()) this.save();
  }

  @HostListener('window:beforeunload', ['$event'])
  warnBeforeLeaving(event: BeforeUnloadEvent) {
    if (this.dirty() && !this.submitting()) event.preventDefault();
  }

  private tick() {
    const a = this.attempt();
    if (!a) return;
    const left = Math.round((Date.parse(a.deadline) - Date.now()) / 1000);
    this.remaining.set(left);
    if (left <= 0 && !this.submitting()) this.submit(true);
  }

  go(i: number) {
    const count = this.attempt()?.sections.length ?? 0;
    if (i < 0 || i >= count) return;
    this.save();
    this.index.set(i);
    window.scrollTo({ top: 0 });
  }

  setAnswer(event: { questionId: number; value: string }) {
    this.answers.update((current) => ({ ...current, [event.questionId]: event.value }));
    this.dirty.set(true);
  }

  setDraft(promptId: number, text: string) {
    this.drafts.update((current) => ({ ...current, [promptId]: text }));
    this.dirty.set(true);
  }

  draft(promptId: number): string {
    return this.drafts()[promptId] ?? '';
  }

  words(promptId: number) {
    const text = this.draft(promptId).trim();
    return text ? text.split(/\s+/).filter((w) => /[\p{L}\p{N}]/u.test(w)).length : 0;
  }

  label(s: SectionView) {
    return SKILL_LABELS[s.skill] ?? s.skill;
  }

  progress(s: SectionView) {
    if (s.skill === 'WRITING' && s.writing) return `${this.words(s.writing.id)} từ`;
    const ids = s.groups.flatMap((g) => g.questions.map((q) => String(q.id)));
    const done = ids.filter((id) => (this.answers()[id] ?? '').trim()).length;
    return `${done}/${ids.length}`;
  }

  save() {
    const a = this.attempt();
    if (!a || !this.dirty() || this.saving() || this.submitting()) return;
    this.saving.set(true);
    this.dirty.set(false);
    this.api.saveAttempt(a.id, this.answers(), this.drafts()).subscribe({
      next: () => {
        this.saving.set(false);
        this.lastSaved.set(new Date());
      },
      error: (err) => {
        this.saving.set(false);
        this.dirty.set(true);
        if (err?.status === 409) this.submit(true);
      },
    });
  }

  submit(auto: boolean) {
    const a = this.attempt();
    if (!a || this.submitting()) return;
    if (!auto && !confirm('Nộp bài? Sau khi nộp không sửa được câu trả lời.')) return;
    this.submitting.set(true);
    this.api.submitAttempt(a.id, this.answers(), this.drafts()).subscribe({
      next: () => void this.router.navigate(['/tests/attempt', a.id, 'result'], { replaceUrl: true }),
      error: (err) => {
        this.submitting.set(false);
        this.error.set(err?.error?.error ?? 'Nộp bài thất bại, thử lại.');
        alert(this.error());
      },
    });
  }
}
