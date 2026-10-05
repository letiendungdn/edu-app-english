import { Component, inject, OnInit, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { ApiService } from '../core/api.service';
import { AuthService } from '../core/auth.service';
import { AnalyticsView } from '../core/models';

@Component({
  selector: 'app-analytics',
  imports: [RouterLink],
  template: `
    <div class="container page" style="max-width: 860px;">
      <h1>Tiến độ học</h1>
      @if (!auth.loggedIn()) {
        <p class="muted" style="margin: 1rem 0;">Đăng nhập để xem tiến độ của bạn.</p>
        <a class="btn btn-primary" routerLink="/login">Đăng nhập</a>
      } @else if (data()) {
        <div class="grid" style="margin: 1rem 0;">
          <div class="card"><strong>{{ minutes(data()!.overview.totalStudySeconds) }}</strong><div class="muted">Tổng thời gian</div></div>
          <div class="card"><strong>{{ data()!.overview.daysStudied }}</strong><div class="muted">Ngày đã học</div></div>
          <div class="card"><strong>{{ data()!.overview.masteredCards }}/{{ data()!.overview.totalCards }}</strong><div class="muted">Thẻ thuộc</div></div>
          <div class="card"><strong>{{ data()!.overview.readingAttempts }}</strong><div class="muted">Bài đọc</div></div>
          <div class="card"><strong>{{ data()!.overview.listeningAttempts }}</strong><div class="muted">Bài nghe</div></div>
          <div class="card"><strong>{{ data()!.overview.dictationAttempts }}</strong><div class="muted">Lần nghe chép</div></div>
        </div>
        <div class="card">
          <h2 style="margin-bottom: 0.75rem;">14 ngày gần nhất</h2>
          <div class="row" style="align-items: flex-end;">
            @for (bar of bars(); track bar.date) {
              <div [title]="bar.date + ': ' + bar.seconds + 's'" [style.height.px]="8 + bar.height" [style.width.px]="18" [style.background]="'var(--accent)'" style="border-radius: 4px;"></div>
            }
          </div>
        </div>
      }
    </div>
  `,
})
export class AnalyticsComponent implements OnInit {
  private api = inject(ApiService);
  auth = inject(AuthService);
  data = signal<AnalyticsView | null>(null);
  bars = signal<{ date: string; seconds: number; height: number }[]>([]);

  ngOnInit() {
    if (!this.auth.loggedIn()) return;
    this.api.analytics().subscribe((data) => {
      this.data.set(data);
      const max = Math.max(1, ...data.studySessions.map((s) => s.seconds));
      this.bars.set(data.studySessions.slice(-14).map((s) => ({
        date: s.date,
        seconds: s.seconds,
        height: Math.round((s.seconds / max) * 80),
      })));
    });
  }

  minutes(seconds: number) {
    const m = Math.floor(seconds / 60);
    return m >= 60 ? `${Math.floor(m / 60)}g ${m % 60}p` : `${m} phút`;
  }
}
