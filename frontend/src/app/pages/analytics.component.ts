import { Component, computed, inject, OnInit, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { ApiService } from '../core/api.service';
import { AuthService } from '../core/auth.service';
import { band, BandSummary, SKILL_LABELS } from '../core/ielts.models';
import { AnalyticsView } from '../core/models';

/** Biểu đồ band: trục dọc từ band 3 đến 9, đủ cho mọi người học có ý nghĩa. */
const W = 640;
const H = 240;
const PAD = { l: 34, r: 14, t: 12, b: 26 };
const MIN_BAND = 3;
const MAX_BAND = 9;

const SERIES = [
  { skill: 'LISTENING', color: 'var(--skill-listening)' },
  { skill: 'READING', color: 'var(--skill-reading)' },
  { skill: 'WRITING', color: 'var(--skill-writing)' },
  { skill: 'SPEAKING', color: 'var(--skill-speaking)' },
  { skill: 'OVERALL', color: 'var(--text)' },
];

interface Line {
  skill: string;
  label: string;
  color: string;
  path: string;
  points: { x: number; y: number; title: string }[];
}

@Component({
  selector: 'app-analytics',
  imports: [RouterLink],
  template: `
    <div class="container page">
      <div class="page-head">
        <div>
          <p class="eyebrow">Theo dõi</p>
          <h1>Tiến độ & band</h1>
          <p>Band từng kỹ năng qua các bài thi và bài luyện, cùng thời gian học mỗi ngày.</p>
        </div>
      </div>
      @if (!auth.loggedIn()) {
        <div class="card empty">
          <strong>Đăng nhập để xem tiến độ</strong>
          <a class="btn btn-primary" routerLink="/login" style="margin-top: 0.75rem;">Đăng nhập</a>
        </div>
      } @else {
        <div class="card" style="margin-bottom: 1.25rem;">
          <div class="card-head">
            <h2>Band theo thời gian</h2>
            @if (bands()?.target != null) { <span class="pill">Mục tiêu {{ fmt(bands()!.target) }}</span> }
          </div>
          @if (lines().length === 0) {
            <div class="empty"><strong>Chưa có điểm band</strong>Làm bài kiểm tra đầu vào, thi thử, hoặc bài luyện từ 10 câu để có điểm đầu tiên.</div>
          } @else {
            <div class="row" style="gap: 1rem; margin-bottom: 0.5rem;">
              @for (l of lines(); track l.skill) {
                <span class="small" style="display: inline-flex; align-items: center; gap: 0.35rem;">
                  <span class="swatch" [style.background]="l.color"></span>{{ l.label }}
                </span>
              }
            </div>
            <div class="chart" style="margin-top: 0;">
              <svg [attr.viewBox]="'0 0 ' + w + ' ' + h" role="img" aria-label="Biểu đồ band theo thời gian">
                @for (g of gridBands; track g) {
                  <line class="grid-line" [attr.x1]="pad.l" [attr.x2]="w - pad.r" [attr.y1]="y(g)" [attr.y2]="y(g)" />
                  <text class="axis-text" [attr.x]="pad.l - 8" [attr.y]="y(g) + 4" text-anchor="end">{{ g }}</text>
                }
                @if (bands()?.target != null) {
                  <line [attr.x1]="pad.l" [attr.x2]="w - pad.r" [attr.y1]="y(bands()!.target!)" [attr.y2]="y(bands()!.target!)"
                        stroke="var(--accent)" stroke-width="1.5" stroke-dasharray="5 4" />
                }
                @for (l of lines(); track l.skill) {
                  <path [attr.d]="l.path" fill="none" [attr.stroke]="l.color" stroke-width="2.25" stroke-linejoin="round" stroke-linecap="round" />
                  @for (p of l.points; track $index) {
                    <circle [attr.cx]="p.x" [attr.cy]="p.y" r="3.5" [attr.fill]="l.color" stroke="var(--bg-card)" stroke-width="1.5"><title>{{ p.title }}</title></circle>
                  }
                }
                <text class="axis-text" [attr.x]="pad.l" [attr.y]="h - 6">{{ range().from }}</text>
                <text class="axis-text" [attr.x]="w - pad.r" [attr.y]="h - 6" text-anchor="end">{{ range().to }}</text>
              </svg>
            </div>
          }
        </div>

        @if (data(); as d) {
          <div class="grid" style="grid-template-columns: repeat(auto-fill, minmax(160px, 1fr)); margin-bottom: 1.25rem;">
            @for (s of stats(); track s.label) {
              <div class="card">
                <div class="band-big" style="font-size: 1.55rem;">{{ s.value }}</div>
                <div class="muted small">{{ s.label }}</div>
              </div>
            }
          </div>
          <div class="card">
            <div class="card-head"><h2>Thời gian học 14 ngày gần nhất</h2></div>
            @if (bars().length === 0) {
              <p class="muted small">Chưa có buổi học nào.</p>
            } @else {
              <div style="display: flex; align-items: flex-end; gap: 6px; height: 110px;">
                @for (bar of bars(); track bar.date) {
                  <div style="flex: 1; display: flex; flex-direction: column; align-items: center; gap: 4px; min-width: 0;">
                    <div [title]="bar.date + ': ' + minutes(bar.seconds)" [style.height.px]="4 + bar.height"
                         style="width: 100%; max-width: 28px; border-radius: 6px 6px 3px 3px; background: var(--accent);"></div>
                    <span class="axis-text" style="font-size: 0.65rem; color: var(--text-muted);">{{ bar.date.slice(8) }}</span>
                  </div>
                }
              </div>
            }
          </div>
        }
      }
    </div>
  `,
})
export class AnalyticsComponent implements OnInit {
  private api = inject(ApiService);
  auth = inject(AuthService);
  data = signal<AnalyticsView | null>(null);
  bands = signal<BandSummary | null>(null);
  bars = signal<{ date: string; seconds: number; height: number }[]>([]);
  fmt = band;
  w = W;
  h = H;
  pad = PAD;
  gridBands = [3, 4, 5, 6, 7, 8, 9];

  stats = computed(() => {
    const d = this.data();
    if (!d) return [];
    const o = d.overview;
    return [
      { label: 'Tổng thời gian', value: this.minutes(o.totalStudySeconds) },
      { label: 'Ngày đã học', value: String(o.daysStudied) },
      { label: 'Thẻ từ đã thuộc', value: `${o.masteredCards}/${o.totalCards}` },
      { label: 'Bài Reading', value: String(o.readingAttempts) },
      { label: 'Bài Listening', value: String(o.listeningAttempts) },
      { label: 'Lần nghe chép', value: String(o.dictationAttempts) },
    ];
  });

  /** Mốc thời gian chung cho mọi đường: điểm đầu tiên tới điểm cuối cùng. */
  private times = computed(() => {
    const history = this.bands()?.history ?? [];
    const ts = history.map((p) => new Date(p.at).getTime());
    return { min: Math.min(...ts), max: Math.max(...ts) };
  });

  range = computed(() => {
    const { min, max } = this.times();
    const f = (t: number) => (Number.isFinite(t) ? new Date(t).toLocaleDateString('vi-VN') : '');
    return { from: f(min), to: f(max) };
  });

  lines = computed<Line[]>(() => {
    const history = this.bands()?.history ?? [];
    if (history.length === 0) return [];
    const { min, max } = this.times();
    const span = Math.max(1, max - min);
    const x = (t: number) => (max === min ? (PAD.l + W - PAD.r) / 2 : PAD.l + ((t - min) / span) * (W - PAD.l - PAD.r));
    return SERIES.map((s) => {
      const pts = history
        .filter((p) => p.skill === s.skill)
        .sort((a, b) => a.at.localeCompare(b.at))
        .map((p) => ({
          x: x(new Date(p.at).getTime()),
          y: this.y(p.band),
          title: `${SKILL_LABELS[s.skill]} ${p.band.toFixed(1)} · ${new Date(p.at).toLocaleDateString('vi-VN')}`,
        }));
      return {
        skill: s.skill,
        label: SKILL_LABELS[s.skill],
        color: s.color,
        points: pts,
        path: pts.map((p, i) => `${i ? 'L' : 'M'}${p.x.toFixed(1)},${p.y.toFixed(1)}`).join(' '),
      };
    }).filter((l) => l.points.length > 0);
  });

  ngOnInit() {
    if (!this.auth.loggedIn()) return;
    this.api.bands().subscribe({ next: (b) => this.bands.set(b), error: () => this.bands.set(null) });
    this.api.analytics().subscribe((data) => {
      this.data.set(data);
      const recent = data.studySessions.slice(-14);
      const max = Math.max(1, ...recent.map((s) => s.seconds));
      this.bars.set(recent.map((s) => ({ date: s.date, seconds: s.seconds, height: Math.round((s.seconds / max) * 84) })));
    });
  }

  y(value: number) {
    const clamped = Math.max(MIN_BAND, Math.min(MAX_BAND, value));
    return PAD.t + ((MAX_BAND - clamped) / (MAX_BAND - MIN_BAND)) * (H - PAD.t - PAD.b);
  }

  minutes(seconds: number) {
    const m = Math.floor(seconds / 60);
    return m >= 60 ? `${Math.floor(m / 60)}g ${m % 60}p` : `${m} phút`;
  }
}
