import { Component, inject, OnInit, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { forkJoin } from 'rxjs';
import { ApiService } from '../core/api.service';
import { AttemptSummary, band, SpeakingSubmissionView, WritingSubmissionView } from '../core/ielts.models';

/** Bài đã làm: thi thử, Writing, Speaking. Task "Xem lại lỗi sai" của lộ trình trỏ về đây. */
@Component({
  selector: 'app-history',
  imports: [RouterLink],
  template: `
    <div class="container page" style="max-width: 900px;">
      <h1>Bài đã làm</h1>
      <p class="muted" style="margin: 0.5rem 0 1rem;">Xem lại phản hồi và lỗi sai gần đây trước khi làm bài mới.</p>

      <h2 class="section-title">Thi thử</h2>
      @for (a of attempts(); track a.id) {
        <div class="task-row">
          <span style="flex: 1;">{{ date(a.startedAt) }} · {{ a.status === 'SUBMITTED' ? 'Đã nộp' : 'Đang làm' }}</span>
          <span class="muted">Overall {{ fmt(a.bandOverall) }}</span>
          <a class="btn btn-sm" [routerLink]="a.status === 'SUBMITTED' ? ['/tests/attempt', a.id, 'result'] : ['/tests/attempt', a.id]">Xem</a>
        </div>
      } @empty { <p class="muted">Chưa có bài thi nào.</p> }

      <h2 class="section-title">Writing</h2>
      @for (w of writing(); track w.id) {
        <div class="task-row">
          <span style="flex: 1;">{{ date(w.createdAt) }} · {{ w.promptTitle }}</span>
          <span class="muted">{{ w.status === 'GRADED' ? 'Band ' + fmt(w.band) : w.status === 'PENDING' ? 'Đang chấm' : 'Lỗi chấm' }}</span>
          <a class="btn btn-sm" [routerLink]="['/writing/submissions', w.id]">Xem</a>
        </div>
      } @empty { <p class="muted">Chưa có bài viết nào.</p> }

      <h2 class="section-title">Speaking</h2>
      @for (s of speaking(); track s.id) {
        <details class="card" style="margin-bottom: 0.5rem;">
          <summary class="row" style="justify-content: space-between;">
            <span>{{ date(s.createdAt) }} · Part {{ s.part }}: {{ s.question }}</span>
            <span class="muted">{{ s.status === 'GRADED' ? 'Band ' + fmt(s.band) : s.status === 'PENDING' ? 'Đang chấm' : 'Lỗi' }}</span>
          </summary>
          <p class="passage" style="margin-top: 0.5rem;">{{ s.transcript }}</p>
          @if (s.feedback) {
            <p>{{ s.feedback.summary }}</p>
            @for (c of s.feedback.corrections; track $index) {
              <div class="correction"><del>{{ c.original }}</del> <span class="fix">→ {{ c.suggestion }}</span></div>
            }
          }
          @if (s.error) { <p class="error">{{ s.error }}</p> }
        </details>
      } @empty { <p class="muted">Chưa có bài nói nào.</p> }
    </div>
  `,
})
export class HistoryComponent implements OnInit {
  private api = inject(ApiService);
  attempts = signal<AttemptSummary[]>([]);
  writing = signal<WritingSubmissionView[]>([]);
  speaking = signal<SpeakingSubmissionView[]>([]);
  fmt = band;

  ngOnInit() {
    forkJoin([this.api.attempts(), this.api.writingSubmissions(), this.api.speakingSubmissions()]).subscribe(([a, w, s]) => {
      this.attempts.set(a);
      this.writing.set(w);
      this.speaking.set(s);
    });
  }

  date(iso: string) {
    return new Date(iso).toLocaleString('vi-VN', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' });
  }
}
