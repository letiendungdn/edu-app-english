import { Component, computed, inject, OnInit, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { ApiService } from '../core/api.service';
import { band, FEASIBILITY_LABELS, PHASE_LABELS, PhaseView, RoadmapView, TaskView } from '../core/ielts.models';

interface Week {
  start: string;
  tasks: TaskView[];
  done: number;
  minutes: number;
}

@Component({
  selector: 'app-roadmap',
  imports: [RouterLink],
  template: `
    <div class="container page" style="max-width: 900px;">
      @if (roadmap(); as r) {
        <div class="row" style="justify-content: space-between; margin-bottom: 1rem;">
          <div>
            <h1>Lộ trình</h1>
            <div class="muted">
              {{ r.startDate }} → {{ r.endDate }}
              @if (r.examDate) { · thi ngày {{ r.examDate }} }
              · band {{ fmt(r.startBand) }} → <strong>{{ fmt(r.targetBand) }}</strong>
              · <span [class]="'pill pill-' + r.feasibility">{{ feasibility(r.feasibility) }}</span>
            </div>
          </div>
          <div class="row">
            <a class="btn" routerLink="/onboarding">Sửa mục tiêu</a>
            <button class="btn" (click)="regenerate()" [disabled]="busy()">Lập lại từ hôm nay</button>
          </div>
        </div>
        @if (r.feasibility === 'AT_RISK') {
          <div class="card warn">
            Với thời gian còn lại và số phút học mỗi ngày hiện tại, mục tiêu band {{ fmt(r.targetBand) }} khó kịp.
            Hãy cân nhắc tăng thời gian học mỗi ngày hoặc lùi ngày thi.
          </div>
        }

        <div class="card">
          <div class="row" style="justify-content: space-between;">
            <strong>Tiến độ</strong>
            <span class="muted">{{ r.tasksDone }}/{{ r.tasksTotal }} việc</span>
          </div>
          <div class="progress" style="margin-top: 0.5rem;"><div [style.width.%]="r.tasksTotal ? (r.tasksDone * 100) / r.tasksTotal : 0"></div></div>
          <div class="phase-bar">
            @for (p of r.phases; track p.id) {
              <div class="phase" [class.current]="isCurrent(p)" [style.flex]="days(p)">
                <strong>{{ phaseLabel(p.kind) }}</strong>
                <span class="muted">{{ p.startDate.slice(5) }} → {{ p.endDate.slice(5) }}</span>
              </div>
            }
          </div>
          @if (currentPhase(); as p) { <p class="muted" style="margin-top: 0.5rem;">{{ p.goal }}</p> }
        </div>

        <h2 class="section-title">Theo tuần</h2>
        @for (w of weeks(); track w.start; let i = $index) {
          <details class="card week" [open]="isThisWeek(w)">
            <summary class="row" style="justify-content: space-between;">
              <strong>Tuần {{ i + 1 }} · từ {{ w.start }}</strong>
              <span class="muted">{{ w.done }}/{{ w.tasks.length }} việc · {{ hours(w.minutes) }}</span>
            </summary>
            @for (t of w.tasks; track t.id) {
              <div class="task-row" [class.done]="t.status === 'DONE'" [class.skipped]="t.status === 'SKIPPED'">
                <span class="muted day">{{ weekday(t.dueDate) }}</span>
                <span style="flex: 1;">{{ t.title }}</span>
                <span class="muted">{{ t.estimatedMin }}′</span>
                @if (t.status === 'DONE') { <span class="ok">✓</span> }
              </div>
            }
          </details>
        }
      } @else if (error()) {
        <p class="error">{{ error() }}</p>
        <a class="btn btn-primary" routerLink="/onboarding">Tạo hồ sơ</a>
      }
    </div>
  `,
})
export class RoadmapComponent implements OnInit {
  private api = inject(ApiService);
  roadmap = signal<RoadmapView | null>(null);
  busy = signal(false);
  error = signal('');
  fmt = band;
  private todayIso = new Date().toLocaleDateString('sv-SE');

  weeks = computed<Week[]>(() => {
    const result: Week[] = [];
    for (const task of this.roadmap()?.tasks ?? []) {
      const monday = this.monday(task.dueDate);
      let week = result.find((w) => w.start === monday);
      if (!week) {
        week = { start: monday, tasks: [], done: 0, minutes: 0 };
        result.push(week);
      }
      week.tasks.push(task);
      week.minutes += task.estimatedMin;
      if (task.status === 'DONE') week.done++;
    }
    return result;
  });

  currentPhase = computed(() => this.roadmap()?.phases.find((p) => this.isCurrent(p)) ?? null);

  ngOnInit() {
    this.api.roadmap().subscribe({
      next: (r) => this.roadmap.set(r),
      error: (err) => this.error.set(err?.error?.error ?? 'Không tải được lộ trình'),
    });
  }

  regenerate() {
    this.busy.set(true);
    this.api.regenerateRoadmap().subscribe({
      next: (r) => {
        this.roadmap.set(r);
        this.busy.set(false);
      },
      error: () => this.busy.set(false),
    });
  }

  isCurrent(p: PhaseView) {
    return p.startDate <= this.todayIso && this.todayIso <= p.endDate;
  }

  isThisWeek(w: Week) {
    return w.start === this.monday(this.todayIso);
  }

  days(p: PhaseView) {
    return (Date.parse(p.endDate) - Date.parse(p.startDate)) / 86_400_000 + 1;
  }

  monday(iso: string) {
    const d = new Date(iso + 'T00:00:00');
    const shift = (d.getDay() + 6) % 7;
    d.setDate(d.getDate() - shift);
    return d.toLocaleDateString('sv-SE');
  }

  weekday(iso: string) {
    return ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'][new Date(iso + 'T00:00:00').getDay()];
  }

  hours(minutes: number) {
    return minutes >= 60 ? `${Math.floor(minutes / 60)}g${minutes % 60 ? ' ' + (minutes % 60) + 'p' : ''}` : `${minutes} phút`;
  }

  phaseLabel(kind: string) {
    return PHASE_LABELS[kind] ?? kind;
  }

  feasibility(value: string) {
    return FEASIBILITY_LABELS[value] ?? value;
  }
}
