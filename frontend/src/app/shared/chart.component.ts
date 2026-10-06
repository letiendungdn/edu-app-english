import { Component, computed, input } from '@angular/core';
import { ChartData } from '../core/ielts.models';

const COLORS = ['#2563eb', '#ea580c', '#16a34a', '#9333ea', '#dc2626'];

/** Vẽ dữ liệu Writing Task 1 bằng SVG thuần: line, bar, pie, table, process, map. */
@Component({
  selector: 'app-chart',
  template: `
    @if (data(); as d) {
      <figure class="chart">
        @switch (d.type) {
          @case ('line') {
            <svg [attr.viewBox]="'0 0 ' + W + ' ' + H" role="img" [attr.aria-label]="'Biểu đồ đường, đơn vị ' + d.unit">
              @for (tick of ticks(); track tick) {
                <line [attr.x1]="P" [attr.x2]="W - 10" [attr.y1]="y(tick)" [attr.y2]="y(tick)" class="grid-line" />
                <text [attr.x]="P - 6" [attr.y]="y(tick) + 4" text-anchor="end" class="axis-text">{{ tick }}</text>
              }
              @for (label of d.labels; track label; let i = $index) {
                <text [attr.x]="x(i)" [attr.y]="H - 8" text-anchor="middle" class="axis-text">{{ label }}</text>
              }
              @for (s of d.series; track s.name; let si = $index) {
                <polyline [attr.points]="points(s.values)" fill="none" [attr.stroke]="color(si)" stroke-width="2.5" />
                @for (v of s.values; track $index; let i = $index) {
                  <circle [attr.cx]="x(i)" [attr.cy]="y(v)" r="3.5" [attr.fill]="color(si)" />
                }
              }
            </svg>
          }
          @case ('bar') {
            <svg [attr.viewBox]="'0 0 ' + W + ' ' + H" role="img" [attr.aria-label]="'Biểu đồ cột, đơn vị ' + d.unit">
              @for (tick of ticks(); track tick) {
                <line [attr.x1]="P" [attr.x2]="W - 10" [attr.y1]="y(tick)" [attr.y2]="y(tick)" class="grid-line" />
                <text [attr.x]="P - 6" [attr.y]="y(tick) + 4" text-anchor="end" class="axis-text">{{ tick }}</text>
              }
              @for (label of d.labels; track label; let i = $index) {
                @for (s of d.series; track s.name; let si = $index) {
                  <rect [attr.x]="barX(i, si)" [attr.y]="y(s.values[i])" [attr.width]="barWidth()" [attr.height]="H - 30 - y(s.values[i])"
                    [attr.fill]="color(si)" rx="2" />
                  <text [attr.x]="barX(i, si) + barWidth() / 2" [attr.y]="y(s.values[i]) - 4" text-anchor="middle" class="value-text">{{ s.values[i] }}</text>
                }
                <text [attr.x]="x(i)" [attr.y]="H - 8" text-anchor="middle" class="axis-text">{{ label }}</text>
              }
            </svg>
          }
          @case ('pie') {
            <div class="pie-row">
              @for (s of d.series; track s.name) {
                <div style="text-align: center;">
                  <svg viewBox="-110 -110 220 220" width="200" role="img" [attr.aria-label]="'Biểu đồ tròn ' + s.name">
                    @for (slice of slices(s.values); track $index; let i = $index) {
                      <path [attr.d]="slice" [attr.fill]="color(i)" stroke="var(--bg)" stroke-width="2" />
                    }
                  </svg>
                  <div><strong>{{ s.name }}</strong></div>
                </div>
              }
            </div>
            <table class="data-table">
              <tr><th></th>@for (s of d.series; track s.name) { <th>{{ s.name }}</th> }</tr>
              @for (label of d.labels; track label; let i = $index) {
                <tr>
                  <td><span class="swatch" [style.background]="color(i)"></span>{{ label }}</td>
                  @for (s of d.series; track s.name) { <td>{{ s.values[i] }}%</td> }
                </tr>
              }
            </table>
          }
          @case ('table') {
            <table class="data-table">
              <tr><th></th>@for (s of d.series; track s.name) { <th>{{ s.name }}</th> }</tr>
              @for (label of d.labels; track label; let i = $index) {
                <tr><td>{{ label }}</td>@for (s of d.series; track s.name) { <td>{{ s.values[i] }}</td> }</tr>
              }
            </table>
          }
          @case ('process') {
            <ol class="process">
              @for (step of d.steps; track $index) { <li>{{ step }}</li> }
            </ol>
          }
          @case ('map') {
            <div class="grid" style="grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));">
              <div class="card"><strong>Trước</strong><ul>@for (b of d.before; track $index) { <li>{{ b }}</li> }</ul></div>
              <div class="card"><strong>Hiện nay</strong><ul>@for (a of d.after; track $index) { <li>{{ a }}</li> }</ul></div>
            </div>
          }
        }
        @if (d.series && (d.type === 'line' || d.type === 'bar')) {
          <figcaption class="row">
            @for (s of d.series; track s.name; let si = $index) {
              <span><span class="swatch" [style.background]="color(si)"></span>{{ s.name }}</span>
            }
            <span class="muted">Đơn vị: {{ d.unit }}</span>
          </figcaption>
        }
      </figure>
    }
  `,
})
export class ChartComponent {
  readonly json = input<string | null | undefined>(null);
  readonly W = 560;
  readonly H = 280;
  readonly P = 44;

  readonly data = computed<ChartData | null>(() => {
    const raw = this.json();
    if (!raw) return null;
    try {
      return JSON.parse(raw) as ChartData;
    } catch {
      return null;
    }
  });

  private readonly max = computed(() => {
    const values = (this.data()?.series ?? []).flatMap((s) => s.values);
    const top = Math.max(10, ...values);
    const step = Math.pow(10, Math.floor(Math.log10(top)));
    return Math.ceil(top / step) * step;
  });

  ticks() {
    const max = this.max();
    return [0, 1, 2, 3, 4].map((i) => Math.round((max / 4) * i));
  }

  color(i: number) {
    return COLORS[i % COLORS.length];
  }

  x(i: number) {
    const n = this.data()?.labels?.length ?? 1;
    const inner = this.W - this.P - 30;
    return this.P + 10 + (n === 1 ? inner / 2 : (inner / (n - 1)) * i);
  }

  y(value: number) {
    return this.H - 30 - (value / this.max()) * (this.H - 50);
  }

  points(values: number[]) {
    return values.map((v, i) => `${this.x(i)},${this.y(v)}`).join(' ');
  }

  barWidth() {
    const d = this.data();
    const groups = d?.labels?.length ?? 1;
    const series = d?.series?.length ?? 1;
    return Math.max(8, ((this.W - this.P - 30) / groups) * 0.7 / series);
  }

  barX(i: number, si: number) {
    const series = this.data()?.series?.length ?? 1;
    return this.x(i) - (this.barWidth() * series) / 2 + si * this.barWidth();
  }

  slices(values: number[]) {
    const total = values.reduce((a, b) => a + b, 0) || 1;
    let angle = -Math.PI / 2;
    return values.map((v) => {
      const sweep = (v / total) * Math.PI * 2;
      const x1 = 100 * Math.cos(angle);
      const y1 = 100 * Math.sin(angle);
      angle += sweep;
      const x2 = 100 * Math.cos(angle);
      const y2 = 100 * Math.sin(angle);
      const large = sweep > Math.PI ? 1 : 0;
      return `M0,0 L${x1},${y1} A100,100 0 ${large} 1 ${x2},${y2} Z`;
    });
  }
}
