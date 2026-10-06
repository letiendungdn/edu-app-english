import { Component, computed, inject, OnInit, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { ApiService } from '../core/api.service';
import { AuthService } from '../core/auth.service';
import { band, FEASIBILITY_LABELS, PHASE_LABELS, ProfileView, SKILL_LABELS, TaskView, TodayView } from '../core/ielts.models';

/** Trang chủ: khách thấy giới thiệu, người học thấy "hôm nay học gì". */
@Component({
  selector: 'app-home',
  imports: [RouterLink],
  template: `
    <div class="container page" style="max-width: 900px;">
      @if (!auth.loggedIn()) {
        <h1>Luyện IELTS theo lộ trình</h1>
        <p class="muted" style="margin: 0.5rem 0 1.5rem;">
          Đặt band mục tiêu và ngày thi, làm bài kiểm tra đầu vào, rồi học theo danh sách việc mỗi ngày. Writing và Speaking được AI chấm theo tiêu chí IELTS.
        </p>
        <div class="row" style="margin-bottom: 2rem;">
          <a class="btn btn-primary" routerLink="/login">Đăng ký / Đăng nhập</a>
          <a class="btn" routerLink="/reading">Thử một bài Reading</a>
        </div>
      } @else if (needsOnboarding()) {
        <div class="card" style="text-align: center; padding: 2rem;">
          <h1>Chào {{ auth.user()?.name || 'bạn' }}</h1>
          <p class="muted" style="margin: 0.5rem 0 1rem;">Cho app biết band mục tiêu và ngày thi để lập lộ trình riêng cho bạn.</p>
          <a class="btn btn-primary" routerLink="/onboarding">Bắt đầu</a>
        </div>
      } @else {
        @if (today(); as t) {
        <div class="row" style="justify-content: space-between; margin-bottom: 1rem;">
          <div>
            <h1>Hôm nay</h1>
            <div class="muted">
              @if (t.phase) { Giai đoạn: <strong>{{ phaseLabel(t.phase) }}</strong> · }
              @if (t.daysToExam != null) { Còn <strong>{{ t.daysToExam }}</strong> ngày đến ngày thi · }
              <span [class]="'pill pill-' + t.feasibility">{{ feasibility(t.feasibility) }}</span>
            </div>
          </div>
          <div class="row">
            <span class="pill">🔥 {{ t.streakDays }} ngày liên tiếp</span>
            <a class="btn" routerLink="/roadmap">Xem lộ trình</a>
          </div>
        </div>

        @if (profile() && !profile()!.placementDone) {
          <a routerLink="/placement" class="card cta">
            <strong>Làm bài kiểm tra đầu vào (~60 phút)</strong>
            <div>Để app biết band thật của bạn và điều chỉnh lộ trình cho sát.</div>
          </a>
        }

        <div class="card">
          <div class="row" style="justify-content: space-between;">
            <h2>Việc cần làm</h2>
            <span class="muted">{{ t.minutesDone }}/{{ t.minutesPlanned }} phút</span>
          </div>
          <div class="progress" style="margin: 0.5rem 0 0.75rem;"><div [style.width.%]="percent()"></div></div>
          @if (t.tasks.length === 0) {
            <p class="muted">Hôm nay là ngày nghỉ theo lộ trình. Có thể ôn lại từ vựng nếu muốn.</p>
          }
          @for (task of t.tasks; track task.id) {
            <div class="task-row" [class.done]="task.status === 'DONE'">
              <input type="checkbox" [checked]="task.status === 'DONE'" (change)="toggle(task)" [attr.aria-label]="'Đánh dấu xong: ' + task.title" />
              <div style="flex: 1;">
                <div>{{ task.title }}</div>
                <div class="muted" style="font-size: 0.8rem;">{{ task.estimatedMin }} phút @if (task.skill) { · {{ skill(task.skill) }} }</div>
              </div>
              @if (task.status !== 'DONE') { <a class="btn btn-sm btn-primary" [routerLink]="task.link">Bắt đầu</a> }
            </div>
          }
          @if (t.overdue.length) {
            <details style="margin-top: 0.75rem;">
              <summary class="muted">{{ t.overdue.length }} việc còn lại từ mấy ngày trước</summary>
              @for (task of t.overdue; track task.id) {
                <div class="task-row">
                  <input type="checkbox" (change)="toggle(task)" [attr.aria-label]="'Đánh dấu xong: ' + task.title" />
                  <div style="flex: 1;">{{ task.title }} <span class="muted">({{ task.dueDate }})</span></div>
                  <a class="btn btn-sm" [routerLink]="task.link">Làm</a>
                </div>
              }
            </details>
          }
        </div>

        <h2 class="section-title">Band hiện tại</h2>
        <div class="band-grid">
          @for (s of skills; track s.key) {
            <div class="card band-card">
              <div class="muted">{{ s.label }}</div>
              <div class="band-big">{{ fmt($any(t.bands)[s.key]) }}</div>
            </div>
          }
          <div class="card band-card target">
            <div class="muted">Mục tiêu</div>
            <div class="band-big">{{ fmt(t.bands.target) }}</div>
          </div>
        </div>
        <p class="muted" style="font-size: 0.8rem; margin-top: 0.4rem;">
          Band từng kỹ năng lấy từ bài thi và bài luyện 60 ngày gần nhất. Kỹ năng chưa có kết quả hiện “–”.
        </p>
        }
      }

      <h2 class="section-title">Luyện tập</h2>
      <div class="grid">
        @for (item of sections; track item.href) {
          <a [routerLink]="item.href" class="card" style="text-decoration: none;">
            <div style="font-size: 1.3rem;">{{ item.icon }}</div>
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
  today = signal<TodayView | null>(null);
  profile = signal<ProfileView | null>(null);
  needsOnboarding = signal(false);
  fmt = band;
  skills = [
    { key: 'listening', label: 'Listening' },
    { key: 'reading', label: 'Reading' },
    { key: 'writing', label: 'Writing' },
    { key: 'speaking', label: 'Speaking' },
    { key: 'overall', label: 'Overall' },
  ];
  sections = [
    { href: '/tests', icon: '⏱', label: 'Thi thử', desc: 'Đề đủ cấu trúc, tính giờ, quy đổi band' },
    { href: '/listening', icon: '♪', label: 'Listening', desc: 'Part 1–4 và bài nghe ngắn' },
    { href: '/reading', icon: '☰', label: 'Reading', desc: 'Đủ các dạng câu hỏi IELTS' },
    { href: '/writing', icon: '✎', label: 'Writing', desc: 'Task 1, Task 2, AI chấm' },
    { href: '/speaking', icon: '🎙', label: 'Speaking', desc: 'Part 1–3, ghi âm, AI chấm' },
    { href: '/vocab/review', icon: '↻', label: 'Ôn từ vựng', desc: 'Thẻ SRS đến hạn' },
    { href: '/grammar', icon: '¶', label: 'Ngữ pháp', desc: 'Bài học theo cấp độ' },
    { href: '/dictation', icon: '⌨', label: 'Nghe chép', desc: 'Luyện nghe từng từ' },
  ];

  percent = computed(() => {
    const t = this.today();
    if (!t || t.minutesPlanned === 0) return 0;
    return Math.round((t.minutesDone / t.minutesPlanned) * 100);
  });

  ngOnInit() {
    if (!this.auth.loggedIn()) return;
    this.load();
    this.api.profile().subscribe({ next: (p) => this.profile.set(p), error: () => this.profile.set(null) });
  }

  private load() {
    this.api.today().subscribe({
      next: (t) => this.today.set(t),
      error: (err) => this.needsOnboarding.set(err?.status === 409),
    });
  }

  toggle(task: TaskView) {
    const next = task.status === 'DONE' ? 'TODO' : 'DONE';
    this.api.updateTask(task.id, next).subscribe(() => this.load());
  }

  phaseLabel(kind: string) {
    return PHASE_LABELS[kind] ?? kind;
  }

  feasibility(value: string) {
    return FEASIBILITY_LABELS[value] ?? value;
  }

  skill(value: string) {
    return SKILL_LABELS[value] ?? value;
  }
}
