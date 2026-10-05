import { Component, inject, OnInit, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { ApiService } from '../core/api.service';
import { PassageDetail, SubmitResult } from '../core/models';

@Component({
  selector: 'app-reading-detail',
  imports: [RouterLink],
  template: `
    <div class="container page" style="max-width: 760px;">
      <a routerLink="/reading" class="muted">← Đọc hiểu</a>
      @if (passage(); as passage) {
        <div style="margin: 1rem 0 0.25rem;">
          <span class="badge" [class]="'badge badge-' + passage.level">{{ passage.level }}</span>
          <span class="muted"> ~{{ passage.estimatedMin }} phút</span>
        </div>
        <h1 style="margin-bottom: 1rem;">{{ passage.title }}</h1>
        <div class="card" style="white-space: pre-wrap; margin-bottom: 1.5rem;">{{ passage.content }}</div>
        @if (!result()) {
          @for (q of passage.questions; track q.id; let i = $index) {
            <div class="card" style="margin-bottom: 0.75rem;">
              <p style="font-weight: 600;">{{ i + 1 }}. {{ q.question }}</p>
              @for (opt of q.options; track opt.id) {
                <label class="option" [class.selected]="answers()[q.id] === opt.text">
                  <input type="radio" [name]="'q-' + q.id" (change)="choose(q.id, opt.text)" />
                  {{ opt.text }}
                </label>
              }
            </div>
          }
          <button class="btn btn-primary" [disabled]="!complete() || busy()" (click)="submit()">Nộp bài</button>
        } @else {
          <div class="card" style="text-align: center; margin-bottom: 1rem;">
            <div style="font-size: 2.4rem; font-weight: 800;">{{ result()!.percent }}%</div>
            <div>{{ result()!.correct }}/{{ result()!.total }} câu đúng</div>
          </div>
          @for (q of passage.questions; track q.id; let i = $index) {
            <div class="card" style="margin-bottom: 0.6rem;">
              <p style="font-weight: 600;">{{ i + 1 }}. {{ q.question }}</p>
              <p class="muted">Đáp án: <strong>{{ answerFor(q.id) }}</strong></p>
              @if (explain(q.id)) { <p class="muted">{{ explain(q.id) }}</p> }
            </div>
          }
          <button class="btn" (click)="reset()">Làm lại</button>
        }
      }
    </div>
  `,
})
export class ReadingDetailComponent implements OnInit {
  private api = inject(ApiService);
  private route = inject(ActivatedRoute);
  passage = signal<PassageDetail | null>(null);
  answers = signal<Record<number, string>>({});
  result = signal<SubmitResult | null>(null);
  busy = signal(false);

  ngOnInit() {
    this.api.readingDetail(Number(this.route.snapshot.paramMap.get('id'))).subscribe((p) => this.passage.set(p));
  }

  choose(id: number, text: string) {
    this.answers.update((current) => ({ ...current, [id]: text }));
  }

  complete() {
    const questions = this.passage()?.questions ?? [];
    return questions.length > 0 && questions.every((q) => this.answers()[q.id]);
  }

  submit() {
    const passage = this.passage();
    if (!passage) return;
    const answers: Record<string, string> = {};
    for (const [key, value] of Object.entries(this.answers())) answers[String(key)] = value;
    this.busy.set(true);
    this.api.submitReading(passage.id, answers).subscribe({
      next: (result) => { this.result.set(result); this.busy.set(false); },
      error: () => this.busy.set(false),
    });
  }

  answerFor(id: number) {
    return this.result()?.results.find((item) => item.questionId === id)?.correctAnswer;
  }

  explain(id: number) {
    return this.result()?.results.find((item) => item.questionId === id)?.explanation;
  }

  reset() {
    this.answers.set({});
    this.result.set(null);
  }
}
