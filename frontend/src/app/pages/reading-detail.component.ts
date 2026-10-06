import { Component, computed, inject, OnInit, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { ApiService } from '../core/api.service';
import { band } from '../core/ielts.models';
import { PassageDetail, SubmitResult } from '../core/models';
import { QuestionGroupComponent } from '../shared/question-group.component';

@Component({
  selector: 'app-reading-detail',
  imports: [RouterLink, QuestionGroupComponent],
  template: `
    <div class="container page">
      <a routerLink="/reading" class="muted">← Đọc hiểu</a>
      @if (passage(); as passage) {
        <div style="margin: 0.75rem 0;">
          <span class="badge" [class]="'badge badge-' + passage.level">{{ passage.level }}</span>
          <span class="muted"> ~{{ passage.estimatedMin }} phút · {{ questionCount() }} câu</span>
        </div>
        <h1 style="margin-bottom: 1rem;">{{ passage.title }}</h1>
        <div class="split">
          <article class="card passage">{{ passage.content }}</article>
          <div>
            @if (result(); as r) {
              <div class="card score-card">
                <div class="band-big">{{ r.correct }}/{{ r.total }}</div>
                @if (r.estimatedBand != null) {
                  <div>Band Reading ước lượng: <strong>{{ fmt(r.estimatedBand) }}</strong></div>
                } @else {
                  <div class="muted">Bài ngắn, chưa đủ câu để quy đổi band.</div>
                }
              </div>
            }
            @for (group of passage.groups; track group.id) {
              <app-question-group [group]="group" [answers]="answers()" [results]="result()?.results ?? null" (answer)="setAnswer($event)" />
            }
            @if (!result()) {
              <div class="row">
                <button class="btn btn-primary" [disabled]="busy()" (click)="submit()">Nộp bài</button>
                <span class="muted">Đã làm {{ answered() }}/{{ questionCount() }}</span>
              </div>
            } @else {
              <button class="btn" (click)="reset()">Làm lại</button>
            }
          </div>
        </div>
      }
    </div>
  `,
})
export class ReadingDetailComponent implements OnInit {
  private api = inject(ApiService);
  private route = inject(ActivatedRoute);
  passage = signal<PassageDetail | null>(null);
  answers = signal<Record<string, string>>({});
  result = signal<SubmitResult | null>(null);
  busy = signal(false);
  fmt = band;

  questionCount = computed(() => (this.passage()?.groups ?? []).reduce((n, g) => n + g.questions.length, 0));
  answered = computed(() => Object.values(this.answers()).filter((v) => v.trim()).length);

  ngOnInit() {
    this.api.readingDetail(Number(this.route.snapshot.paramMap.get('id'))).subscribe((p) => this.passage.set(p));
  }

  setAnswer(event: { questionId: number; value: string }) {
    this.answers.update((current) => ({ ...current, [event.questionId]: event.value }));
  }

  submit() {
    const passage = this.passage();
    if (!passage) return;
    this.busy.set(true);
    this.api.submitReading(passage.id, this.answers()).subscribe({
      next: (result) => {
        this.result.set(result);
        this.busy.set(false);
        window.scrollTo({ top: 0, behavior: 'smooth' });
      },
      error: () => this.busy.set(false),
    });
  }

  reset() {
    this.answers.set({});
    this.result.set(null);
  }
}
