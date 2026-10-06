import { Component, inject, OnDestroy, OnInit, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { ApiService } from '../core/api.service';
import { AttemptResult, band, SKILL_LABELS } from '../core/ielts.models';
import { FeedbackComponent } from '../shared/feedback.component';

@Component({
  selector: 'app-test-result',
  imports: [RouterLink, FeedbackComponent],
  template: `
    <div class="container page" style="max-width: 900px;">
      <a routerLink="/tests" class="muted">← Thi thử</a>
      @if (result(); as r) {
        <h1 style="margin: 0.75rem 0;">{{ r.title }}</h1>
        <div class="band-grid">
          <div class="card band-card"><div class="muted">Listening</div><div class="band-big">{{ fmt(r.listening?.band) }}</div>
            @if (r.listening) { <div class="muted">{{ r.listening.raw }}/{{ r.listening.total }}</div> }</div>
          <div class="card band-card"><div class="muted">Reading</div><div class="band-big">{{ fmt(r.reading?.band) }}</div>
            @if (r.reading) { <div class="muted">{{ r.reading.raw }}/{{ r.reading.total }}</div> }</div>
          <div class="card band-card"><div class="muted">Writing</div><div class="band-big">{{ pending() ? '…' : fmt(r.bandWriting) }}</div></div>
          <div class="card band-card"><div class="muted">Speaking*</div><div class="band-big">{{ fmt(r.bandSpeaking) }}</div></div>
          <div class="card band-card target"><div class="muted">Overall</div><div class="band-big">{{ pending() ? '…' : fmt(r.bandOverall) }}</div></div>
        </div>
        <p class="muted" style="font-size: 0.8rem; margin: 0.4rem 0 1rem;">
          * Speaking không thi trong bài này: lấy band Speaking gần đây của bạn, chưa có thì Overall tính trên các kỹ năng còn lại.
          @if (shortTest()) { Bài ít hơn 40 câu nên band Listening/Reading được quy đổi theo tỉ lệ, chỉ mang tính ước lượng. }
        </p>
        @if (pending()) { <div class="card warn">Writing đang được AI chấm, trang tự cập nhật khi xong.</div> }

        @for (w of r.writing; track w.id) {
          <h2 class="section-title">Writing: {{ w.promptTitle }}</h2>
          @if (w.status === 'GRADED') {
            <app-feedback [band]="w.band" [criteria]="w.criteria" [feedback]="w.feedback" />
          } @else if (w.status === 'FAILED') {
            <div class="card warn">{{ w.error }} <a [routerLink]="['/writing/submissions', w.id]">Xem bài và chấm lại</a></div>
          } @else {
            <div class="card muted">Đang chấm…</div>
          }
        }

        @for (s of r.sections; track $index) {
          <details class="card" style="margin-top: 1rem;">
            <summary class="row" style="justify-content: space-between;">
              <strong>{{ skill(s.skill) }}: {{ s.title }}</strong>
              <span class="muted">{{ points(s.results) }}</span>
            </summary>
            <table class="data-table" style="margin-top: 0.5rem;">
              <tr><th>Câu</th><th>Bạn trả lời</th><th>Đáp án</th><th></th></tr>
              @for (a of s.results; track a.questionId) {
                <tr [class.row-wrong]="a.points < a.maxPoints">
                  <td>{{ a.number }}</td>
                  <td>{{ a.given || '–' }}</td>
                  <td>{{ a.correctAnswer }}</td>
                  <td>{{ a.points === a.maxPoints ? '✓' : a.points > 0 ? '½' : '✗' }}</td>
                </tr>
                @if (a.points < a.maxPoints && (a.explanation || a.evidence)) {
                  <tr><td></td><td colspan="3" class="muted">{{ a.explanation }} @if (a.evidence) { <em>“{{ a.evidence }}”</em> }</td></tr>
                }
              }
            </table>
          </details>
        }
        <div class="row" style="margin-top: 1.5rem;">
          <a class="btn btn-primary" routerLink="/">Về trang Hôm nay</a>
          <a class="btn" routerLink="/roadmap">Xem lộ trình đã cập nhật</a>
        </div>
      }
    </div>
  `,
})
export class TestResultComponent implements OnInit, OnDestroy {
  private api = inject(ApiService);
  private route = inject(ActivatedRoute);
  result = signal<AttemptResult | null>(null);
  fmt = band;
  private timer: number | null = null;

  ngOnInit() {
    this.load();
  }

  ngOnDestroy() {
    if (this.timer != null) window.clearTimeout(this.timer);
  }

  private load() {
    this.api.attemptResult(Number(this.route.snapshot.paramMap.get('id'))).subscribe((r) => {
      this.result.set(r);
      if (this.pending()) this.timer = window.setTimeout(() => this.load(), 5000);
    });
  }

  pending() {
    return (this.result()?.writing ?? []).some((w) => w.status === 'PENDING');
  }

  shortTest() {
    const r = this.result();
    return (r?.listening?.total ?? 40) < 40 || (r?.reading?.total ?? 40) < 40;
  }

  points(results: { points: number; maxPoints: number }[]) {
    const got = results.reduce((n, r) => n + r.points, 0);
    const max = results.reduce((n, r) => n + r.maxPoints, 0);
    return `${got}/${max}`;
  }

  skill(value: string) {
    return SKILL_LABELS[value] ?? value;
  }
}
