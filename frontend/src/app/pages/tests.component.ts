import { Component, inject, OnInit, signal } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { ApiService } from '../core/api.service';
import { AuthService } from '../core/auth.service';
import { band, SKILL_LABELS, TestListItem } from '../core/ielts.models';

@Component({
  selector: 'app-tests',
  imports: [RouterLink],
  template: `
    <div class="container page" style="max-width: 900px;">
      <h1>Thi thử</h1>
      <p class="muted" style="margin: 0.5rem 0 1.25rem;">
        Làm bài có giờ như thi thật. Bài làm tự lưu mỗi 30 giây, tải lại trang không mất câu trả lời.
      </p>
      @if (error()) { <p class="error">{{ error() }}</p> }
      <div class="grid" style="grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));">
        @for (t of tests(); track t.id) {
          <div class="card stack">
            <div>
              <span class="badge" [class.badge-B1]="t.kind === 'PLACEMENT'" [class.badge-C1]="t.kind === 'MOCK'">
                {{ t.kind === 'PLACEMENT' ? 'Đầu vào' : t.kind === 'MOCK' ? 'Thi thử' : 'Một phần' }}
              </span>
              <span class="muted"> {{ t.durationMin }} phút</span>
            </div>
            <h2>{{ t.title }}</h2>
            <p class="muted">{{ t.description }}</p>
            <div class="row">@for (s of t.skills; track s) { <span class="pill">{{ skill(s) }}</span> }</div>
            @if (t.lastAttempt; as a) {
              <div class="muted" style="font-size: 0.85rem;">
                @if (a.status === 'SUBMITTED') {
                  Lần gần nhất: Overall {{ fmt(a.bandOverall) }} (L {{ fmt(a.bandListening) }} · R {{ fmt(a.bandReading) }} · W {{ fmt(a.bandWriting) }})
                  · <a [routerLink]="['/tests/attempt', a.id, 'result']">Xem kết quả</a>
                } @else {
                  Bạn đang làm dở bài này.
                }
              </div>
            }
            <button class="btn btn-primary" (click)="start(t)" [disabled]="busy()">
              {{ t.lastAttempt?.status === 'IN_PROGRESS' ? 'Làm tiếp' : 'Bắt đầu' }}
            </button>
          </div>
        }
      </div>
    </div>
  `,
})
export class TestsComponent implements OnInit {
  private api = inject(ApiService);
  private router = inject(Router);
  private auth = inject(AuthService);
  tests = signal<TestListItem[]>([]);
  busy = signal(false);
  error = signal('');
  fmt = band;

  ngOnInit() {
    this.api.tests().subscribe((t) => this.tests.set(t));
  }

  start(test: TestListItem) {
    if (!this.auth.loggedIn()) {
      void this.router.navigate(['/login'], { queryParams: { next: '/tests' } });
      return;
    }
    this.busy.set(true);
    this.api.startTest(test.id).subscribe({
      next: (attempt) => void this.router.navigate(['/tests/attempt', attempt.id]),
      error: (err) => {
        this.busy.set(false);
        this.error.set(err?.error?.error ?? 'Không bắt đầu được bài thi');
      },
    });
  }

  skill(value: string) {
    return SKILL_LABELS[value] ?? value;
  }
}

/** /placement: tạo (hoặc mở lại) bài kiểm tra đầu vào rồi chuyển sang trang làm bài. */
@Component({
  selector: 'app-placement',
  template: `<div class="container page"><p class="muted">{{ message() }}</p></div>`,
})
export class PlacementComponent implements OnInit {
  private api = inject(ApiService);
  private router = inject(Router);
  message = signal('Đang chuẩn bị bài kiểm tra đầu vào…');

  ngOnInit() {
    this.api.startPlacement().subscribe({
      next: (attempt) => void this.router.navigate(['/tests/attempt', attempt.id], { replaceUrl: true }),
      error: (err) => this.message.set(err?.error?.error ?? 'Không tạo được bài kiểm tra'),
    });
  }
}
