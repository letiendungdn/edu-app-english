import { Component, inject, OnInit, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { ApiService } from '../core/api.service';
import { AuthService } from '../core/auth.service';
import { AnalyticsView } from '../core/models';

@Component({
  selector: 'app-home',
  imports: [RouterLink],
  template: `
    <div class="container page" style="max-width: 800px;">
      <h1>English Learning</h1>
      <p class="muted" style="margin-bottom: 1.5rem;">Luyện từ vựng, ngữ pháp, đọc và nghe mỗi ngày.</p>

      @if (due() > 0) {
        <a routerLink="/vocab/review" class="card" style="display: block; text-decoration: none; margin-bottom: 1.25rem; background: var(--accent); color: white;">
          <strong>{{ due() }} thẻ cần ôn hôm nay</strong>
          <div style="font-size: 0.85rem; opacity: 0.9;">Ôn ngay để không quên kiến thức</div>
        </a>
      }

      @if (stats()) {
        <div class="grid" style="margin-bottom: 1.5rem;">
          <div class="card" style="text-align: center;"><div style="font-size: 1.4rem; font-weight: 800;">{{ stats()!.daysStudied }}</div><div class="muted">Ngày đã học</div></div>
          <div class="card" style="text-align: center;"><div style="font-size: 1.4rem; font-weight: 800;">{{ stats()!.masteredCards }}</div><div class="muted">Thẻ đã thuộc</div></div>
          <div class="card" style="text-align: center;"><div style="font-size: 1.4rem; font-weight: 800;">{{ stats()!.totalCards }}</div><div class="muted">Tổng thẻ</div></div>
          <div class="card" style="text-align: center;"><div style="font-size: 1.4rem; font-weight: 800;">{{ minutes(stats()!.totalStudySeconds) }}</div><div class="muted">Thời gian</div></div>
        </div>
      }

      <h2 class="muted" style="font-size: 0.85rem; margin-bottom: 0.75rem;">LUYỆN TẬP</h2>
      <div class="grid">
        @for (item of sections; track item.href) {
          <a [routerLink]="item.href" class="card" style="text-decoration: none;">
            <div style="font-size: 1.4rem;">{{ item.icon }}</div>
            <strong>{{ item.label }}</strong>
            <div class="muted" style="font-size: 0.85rem;">{{ item.desc }}</div>
          </a>
        }
      </div>
    </div>
  `,
})
export class HomeComponent implements OnInit {
  private api = inject(ApiService);
  auth = inject(AuthService);
  stats = signal<AnalyticsView['overview'] | null>(null);
  due = signal(0);
  sections = [
    { href: '/vocab', icon: 'Aa', label: 'Từ vựng', desc: 'Học và quản lý từ vựng' },
    { href: '/vocab/review', icon: '↻', label: 'SRS Review', desc: 'Ôn tập thẻ đến hạn' },
    { href: '/vocab/flashcard', icon: '▭', label: 'Flashcard', desc: 'Luyện nhanh bằng thẻ' },
    { href: '/grammar', icon: '✎', label: 'Ngữ pháp', desc: 'Bài học ngữ pháp theo cấp' },
    { href: '/reading', icon: '☰', label: 'Đọc hiểu', desc: 'Bài đọc có câu hỏi kiểm tra' },
    { href: '/listening', icon: '♪', label: 'Nghe', desc: 'Luyện nghe theo level' },
    { href: '/dictation', icon: '✎', label: 'Nghe chép', desc: 'Tăng kỹ năng chính tả' },
    { href: '/analytics', icon: '▣', label: 'Tiến độ', desc: 'Thống kê quá trình học' },
  ];

  ngOnInit() {
    if (!this.auth.loggedIn()) return;
    this.api.analytics().subscribe({ next: (data) => this.stats.set(data.overview) });
    this.api.review().subscribe({ next: (cards) => this.due.set(cards.length), error: () => this.due.set(0) });
  }

  minutes(seconds: number) {
    const h = Math.floor(seconds / 3600);
    const m = Math.floor((seconds % 3600) / 60);
    return h > 0 ? `${h}g ${m}p` : `${m} phút`;
  }
}
