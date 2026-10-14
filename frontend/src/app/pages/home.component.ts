import { Component, computed, inject, OnInit, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { ApiService } from '../core/api.service';
import { AuthService } from '../core/auth.service';
import {
  band,
  FEASIBILITY_LABELS,
  PHASE_LABELS,
  ProfileView,
  QuestionTypeStat,
  questionTypeLabel,
  SKILL_LABELS,
  TaskView,
  TodayView,
} from '../core/ielts.models';
import { IconComponent } from '../shared/icon.component';

const SKILL_CLASS: Record<string, string> = { LISTENING: 'skill-L', READING: 'skill-R', WRITING: 'skill-W', SPEAKING: 'skill-S' };

/** Trang chủ: khách thấy giới thiệu, người học thấy "hôm nay học gì". */
@Component({
  selector: 'app-home',
  imports: [RouterLink, IconComponent],
  template: `
    <div class="container page">
      @if (!auth.loggedIn()) {
        <section class="hero">
          <div style="position: relative; z-index: 1;">
            <p class="eyebrow" style="color: rgba(255,255,255,0.8);">IELTS Academic & General</p>
            <h1>Lên band mục tiêu theo lộ trình riêng</h1>
            <p class="hero-sub">Đặt band và ngày thi, làm bài kiểm tra đầu vào, rồi học theo danh sách việc mỗi ngày. Writing và Speaking được AI chấm theo 4 tiêu chí IELTS.</p>
            <div class="row" style="margin-top: 1.1rem;">
              <a class="btn btn-primary" routerLink="/login">Bắt đầu miễn phí</a>
              <a class="btn" routerLink="/reading">Thử một bài Reading</a>
            </div>
          </div>
        </section>
        <div class="feature-grid">
          @for (f of features; track f.title) {
            <div class="card">
              <span class="practice-mark" [class]="'practice-mark ' + f.cls"><app-icon [name]="f.icon" /></span>
              <h2>{{ f.title }}</h2>
              <p>{{ f.desc }}</p>
            </div>
          }
        </div>
      } @else if (needsOnboarding()) {
        <section class="hero">
          <div style="position: relative; z-index: 1;">
            <h1>Chào {{ auth.user()?.name || 'bạn' }}</h1>
            <p class="hero-sub">Cho app biết band mục tiêu và ngày thi để lập lộ trình riêng cho bạn. Mất khoảng 1 phút.</p>
            <div class="row" style="margin-top: 1rem;"><a class="btn btn-primary" routerLink="/onboarding">Lập lộ trình</a></div>
          </div>
        </section>
      } @else {
        @if (today(); as t) {
        <section class="hero">
          <div style="position: relative; z-index: 1;">
            <p class="eyebrow" style="color: rgba(255,255,255,0.8);">{{ dateLabel(t.date) }}</p>
            <h1>Chào {{ firstName() }}, hôm nay học gì?</h1>
            <p class="hero-sub">
              @if (t.phase) { Giai đoạn <strong>{{ phaseLabel(t.phase) }}</strong>. }
              @if (t.phaseGoal) { {{ t.phaseGoal }} }
            </p>
            <div class="row" style="margin-top: 0.9rem;">
              <span class="pill">{{ feasibility(t.feasibility) }}</span>
              <span class="pill"><app-icon name="flame" /> {{ t.streakDays }} ngày liên tiếp</span>
              @if (t.dueCards > 0) { <a class="pill" routerLink="/vocab/review" style="text-decoration: none;">{{ t.dueCards }} thẻ từ đến hạn</a> }
            </div>
          </div>
          <div class="hero-stats">
            @if (t.daysToExam != null) {
              <div class="hero-stat"><strong>{{ t.daysToExam }}</strong><span>ngày đến kỳ thi</span></div>
            }
            <div class="hero-stat"><strong>{{ fmt(t.bands.overall) }}</strong><span>band hiện tại</span></div>
            <div class="hero-stat"><strong>{{ fmt(t.bands.target) }}</strong><span>mục tiêu</span></div>
          </div>
        </section>

        @if (profile() && !profile()!.placementDone) {
          <a routerLink="/placement" class="card cta">
            <span class="practice-mark" style="--c: var(--hot); margin: 0;"><app-icon name="exam" /></span>
            <span>
              <strong>Làm bài kiểm tra đầu vào (~60 phút)</strong>
              <span class="muted small">Để app biết band thật của bạn và chỉnh lộ trình cho sát.</span>
            </span>
          </a>
        }

        <div class="dash">
          <div class="stack" style="gap: 1.25rem;">
            <div class="card">
              <div class="card-head">
                <div>
                  <h2>Việc cần làm hôm nay</h2>
                  <div class="muted small">{{ doneCount() }}/{{ t.tasks.length }} việc · {{ t.minutesDone }}/{{ t.minutesPlanned }} phút</div>
                </div>
                <div class="ring" [style.--p]="percent()"><span>{{ percent() }}%</span></div>
              </div>
              @if (t.tasks.length === 0) {
                <div class="empty"><strong>Hôm nay là ngày nghỉ</strong>Nghỉ ngơi cũng là một phần của lộ trình. Muốn học thêm thì ôn vài thẻ từ vựng.</div>
              }
              @for (task of t.tasks; track task.id) {
                <div class="task-row" [class.done]="task.status === 'DONE'">
                  <span class="task-skill" [class]="'task-skill ' + skillClass(task.skill)"></span>
                  <input type="checkbox" [checked]="task.status === 'DONE'" (change)="toggle(task)" [attr.aria-label]="'Đánh dấu xong: ' + task.title" />
                  <div style="flex: 1; min-width: 0;">
                    <div style="font-weight: 600;">{{ task.title }}</div>
                    <div class="muted small">{{ task.estimatedMin }} phút @if (task.skill) { · {{ skill(task.skill) }} }</div>
                  </div>
                  @if (task.status !== 'DONE') { <a class="btn btn-sm btn-primary" [routerLink]="task.link">Bắt đầu</a> }
                </div>
              }
              @if (t.overdue.length) {
                <details style="margin-top: 0.75rem;">
                  <summary class="muted small" style="cursor: pointer;">{{ t.overdue.length }} việc còn lại từ mấy ngày trước</summary>
                  @for (task of t.overdue; track task.id) {
                    <div class="task-row">
                      <input type="checkbox" (change)="toggle(task)" [attr.aria-label]="'Đánh dấu xong: ' + task.title" />
                      <div style="flex: 1;">{{ task.title }} <span class="muted small">({{ task.dueDate }})</span></div>
                      <a class="btn btn-sm" [routerLink]="task.link">Làm</a>
                    </div>
                  }
                </details>
              }
            </div>

            <div>
              <h2 class="section-title" style="margin-top: 0.5rem;">Luyện tập</h2>
              <div class="grid practice-grid">
                @for (item of sections; track item.href) {
                  <a [routerLink]="item.href" class="card practice-card">
                    <span class="practice-mark" [class]="'practice-mark ' + item.cls"><app-icon [name]="item.icon" /></span>
                    <strong>{{ item.label }}</strong>
                    <div class="muted small">{{ item.desc }}</div>
                  </a>
                }
              </div>
            </div>
          </div>

          <aside class="dash-side">
            <div class="card">
              <div class="card-head"><h2>Band theo kỹ năng</h2><a routerLink="/analytics">Chi tiết</a></div>
              <div class="skill-list">
                @for (s of skills; track s.key) {
                  <div class="skill-row" [class]="'skill-row ' + s.cls">
                    <span class="name"><span class="dot"></span>{{ s.label }}</span>
                    <div class="skill-track">
                      <div class="fill" [style.width.%]="bandPct($any(t.bands)[s.key])"></div>
                      @if (t.bands.target != null) { <div class="goal" [style.left.%]="bandPct(t.bands.target)" title="Mục tiêu"></div> }
                    </div>
                    <span class="val">{{ fmt($any(t.bands)[s.key]) }}</span>
                  </div>
                }
              </div>
              <p class="muted small" style="margin-top: 0.9rem;">Vạch đứng là band mục tiêu. Kỹ năng chưa có kết quả hiện “–”.</p>
            </div>

            <div class="card">
              <div class="card-head"><h2>Dạng câu cần luyện</h2><a routerLink="/mistakes">Sổ lỗi sai</a></div>
              @if (weakTypes().length === 0) {
                <p class="muted small">Làm vài bài Reading hoặc Listening, app sẽ chỉ ra dạng câu bạn hay sai nhất.</p>
              } @else {
                @for (s of weakTypes(); track s.type) {
                  <div class="type-row" [class.weak]="s.percent < 60" [class.mid]="s.percent >= 60 && s.percent < 80">
                    <span>{{ typeLabel(s.type) }}</span>
                    <span class="pct">{{ s.percent }}%</span>
                    <div class="bar"><div [style.width.%]="s.percent"></div></div>
                  </div>
                }
              }
              @if (mistakeCount() > 0) {
                <a class="btn btn-sm" routerLink="/mistakes" style="margin-top: 0.85rem; width: 100%;">Xem lại {{ mistakeCount() }} câu sai</a>
              }
            </div>
          </aside>
        </div>
        }
      }
    </div>
  `,
})
export class HomeComponent implements OnInit {
  private api = inject(ApiService);
  auth = inject(AuthService);
  today = signal<TodayView | null>(null);
  profile = signal<ProfileView | null>(null);
  needsOnboarding = signal(false);
  typeStats = signal<QuestionTypeStat[]>([]);
  mistakeCount = signal(0);
  fmt = band;
  typeLabel = questionTypeLabel;

  skills = [
    { key: 'listening', label: 'Listening', cls: 'skill-L' },
    { key: 'reading', label: 'Reading', cls: 'skill-R' },
    { key: 'writing', label: 'Writing', cls: 'skill-W' },
    { key: 'speaking', label: 'Speaking', cls: 'skill-S' },
  ];

  sections = [
    { href: '/tests', icon: 'exam', cls: '', label: 'Thi thử', desc: 'Đề đủ cấu trúc, tính giờ, quy đổi band' },
    { href: '/listening', icon: 'listening', cls: 'skill-L', label: 'Listening', desc: 'Part 1–4, đủ dạng câu' },
    { href: '/reading', icon: 'reading', cls: 'skill-R', label: 'Reading', desc: 'TFNG, headings, điền từ…' },
    { href: '/writing', icon: 'writing', cls: 'skill-W', label: 'Writing', desc: 'Task 1, Task 2, AI chấm' },
    { href: '/speaking', icon: 'speaking', cls: 'skill-S', label: 'Speaking', desc: 'Part 1–3, ghi âm, AI chấm' },
    { href: '/vocab/review', icon: 'vocab', cls: '', label: 'Ôn từ vựng', desc: 'Thẻ SRS đến hạn' },
    { href: '/grammar', icon: 'grammar', cls: '', label: 'Ngữ pháp', desc: 'Bài học theo cấp độ' },
    { href: '/dictation', icon: 'dictation', cls: 'skill-L', label: 'Nghe chép', desc: 'Luyện nghe từng từ' },
  ];

  features = [
    { icon: 'route', cls: '', title: 'Lộ trình theo ngày thi', desc: 'Chia giai đoạn, dồn thời gian vào kỹ năng yếu nhất.' },
    { icon: 'exam', cls: '', title: 'Thi thử tính giờ', desc: 'Listening, Reading, Writing đủ cấu trúc, quy đổi band.' },
    { icon: 'writing', cls: 'skill-W', title: 'AI chấm Writing & Speaking', desc: 'Điểm 4 tiêu chí, sửa lỗi từng câu.' },
    { icon: 'mistakes', cls: 'skill-S', title: 'Sổ lỗi sai', desc: 'Gom câu làm sai, chỉ ra dạng câu cần luyện thêm.' },
  ];

  percent = computed(() => {
    const t = this.today();
    if (!t || t.minutesPlanned === 0) return 0;
    return Math.min(100, Math.round((t.minutesDone / t.minutesPlanned) * 100));
  });

  doneCount = computed(() => this.today()?.tasks.filter((t) => t.status === 'DONE').length ?? 0);

  /** Bốn dạng yếu nhất; thống kê đã sắp tăng dần theo % đúng. */
  weakTypes = computed(() => this.typeStats().slice(0, 4));

  firstName = computed(() => {
    const name = this.auth.user()?.name?.trim();
    if (!name) return 'bạn';
    const parts = name.split(/\s+/);
    return parts[parts.length - 1];
  });

  ngOnInit() {
    if (!this.auth.loggedIn()) return;
    this.load();
    this.api.profile().subscribe({ next: (p) => this.profile.set(p), error: () => this.profile.set(null) });
    this.api.questionTypeStats().subscribe({ next: (s) => this.typeStats.set(s), error: () => this.typeStats.set([]) });
    this.api.mistakeCount().subscribe({ next: (c) => this.mistakeCount.set(c.open), error: () => this.mistakeCount.set(0) });
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

  /** Band 0–9 thành % độ dài thanh. */
  bandPct(value: number | null | undefined) {
    return value == null ? 0 : Math.max(0, Math.min(100, (value / 9) * 100));
  }

  dateLabel(iso: string) {
    const d = new Date(iso + 'T00:00:00');
    return d.toLocaleDateString('vi-VN', { weekday: 'long', day: 'numeric', month: 'long' });
  }

  skillClass(skill?: string | null) {
    return skill ? (SKILL_CLASS[skill] ?? '') : '';
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
