import { Component, computed, HostListener, inject, OnInit, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { ApiService } from '../core/api.service';
import { AuthService } from '../core/auth.service';
import { ReviewCard } from '../core/models';
import { FlipCardComponent, speakEnglish } from '../shared/flip-card.component';

/** Ôn thẻ đến hạn theo SM-2: lật thẻ, tự chấm mức nhớ, app xếp lịch ôn tiếp theo. */
@Component({
  selector: 'app-review',
  imports: [RouterLink, FlipCardComponent],
  template: `
    <div class="container page" style="max-width: 720px;">
      <a routerLink="/vocab" class="muted small">← Từ vựng</a>
      <div class="deck-head" style="margin-top: 0.5rem;">
        <div>
          <p class="eyebrow">Từ vựng</p>
          <h1>Ôn thẻ đến hạn</h1>
        </div>
        <a class="btn btn-sm" routerLink="/vocab/flashcard">Học từ mới</a>
      </div>

      @if (!auth.loggedIn()) {
        <div class="card empty">
          <strong>Đăng nhập để ôn theo lịch</strong>
          App dùng thuật toán SM-2: từ nào hay quên sẽ gặp lại sớm, từ đã thuộc sẽ giãn dần.
          <div style="margin-top: 1rem;"><a class="btn btn-primary" routerLink="/login">Đăng nhập</a></div>
        </div>
      } @else if (loading()) {
        <p class="muted">Đang tải…</p>
      } @else if (done() || !current()) {
        <div class="card deck-done">
          <div class="big">{{ total() ? '🎉' : '✅' }}</div>
          <h2>{{ total() ? 'Xong ' + total() + ' thẻ hôm nay' : 'Không có thẻ nào đến hạn' }}</h2>
          @if (total()) {
            <div class="deck-stats">
              <div><strong class="ok">{{ remembered() }}</strong><span class="muted small">Nhớ</span></div>
              <div><strong style="color: var(--danger);">{{ forgotten() }}</strong><span class="muted small">Quên / khó</span></div>
            </div>
          } @else {
            <p class="muted" style="margin: 0.5rem 0 1.25rem;">Học thêm từ mới ở Flashcard, chúng sẽ được đưa vào lịch ôn.</p>
          }
          <div class="row" style="justify-content: center;">
            <a class="btn btn-primary" routerLink="/vocab/flashcard">Học từ mới</a>
            <button class="btn" (click)="reload()">Kiểm tra lại</button>
          </div>
        </div>
      } @else {
        <div class="deck-progress">
          <span>Còn {{ cards().length - index() }} thẻ</span>
          <div class="progress"><div [style.width.%]="(index() / cards().length) * 100"></div></div>
          <span>{{ index() + 1 }}/{{ cards().length }}</span>
        </div>

        @for (one of [current()!]; track one.id) {
          <app-flip-card [word]="one.vocab" [flipped]="flipped()" (flip)="flipped.set(!flipped())" />
        }

        @if (flipped()) {
          <p class="muted small" style="text-align: center; margin-top: 1rem;">Bạn nhớ từ này đến mức nào?</p>
          <div class="grade-row" style="margin-top: 0.5rem;">
            @for (g of grades; track g.q; let i = $index) {
              <button class="grade-btn" [style.--c]="g.color" [disabled]="busy()" (click)="grade(g.q)">
                {{ g.label }}
                <small>{{ g.hint }} · phím {{ i + 1 }}</small>
              </button>
            }
          </div>
        } @else {
          <button class="btn btn-primary" style="width: 100%; min-height: 3rem; margin-top: 1rem; border-radius: 14px;" (click)="flipped.set(true)">
            Xem nghĩa <kbd style="color: inherit; border-color: currentColor; background: transparent;">Space</kbd>
          </button>
        }
        <div class="key-hints"><span><kbd>Space</kbd> lật thẻ</span><span><kbd>1</kbd>–<kbd>5</kbd> chấm mức nhớ</span><span><kbd>P</kbd> nghe phát âm</span></div>
      }
    </div>
  `,
})
export class ReviewComponent implements OnInit {
  private api = inject(ApiService);
  auth = inject(AuthService);
  cards = signal<ReviewCard[]>([]);
  index = signal(0);
  flipped = signal(false);
  done = signal(false);
  loading = signal(true);
  busy = signal(false);
  total = signal(0);
  remembered = signal(0);
  forgotten = signal(0);
  grades = [
    { q: 0, label: 'Quên', hint: 'ôn lại ngay', color: 'var(--danger)' },
    { q: 2, label: 'Khó', hint: 'nhớ lờ mờ', color: 'var(--hot)' },
    { q: 3, label: 'Được', hint: 'nghĩ một lúc', color: 'var(--warn)' },
    { q: 4, label: 'Dễ', hint: 'nhớ ngay', color: 'var(--success)' },
    { q: 5, label: 'Rất dễ', hint: 'quá quen', color: 'var(--accent)' },
  ];

  current = computed(() => this.cards()[this.index()]);

  ngOnInit() {
    if (this.auth.loggedIn()) this.reload();
    else this.loading.set(false);
  }

  @HostListener('window:keydown', ['$event'])
  onKey(e: KeyboardEvent) {
    const target = e.target as HTMLElement | null;
    if (target && /^(INPUT|TEXTAREA|SELECT)$/.test(target.tagName)) return;
    if (this.done() || !this.current()) return;
    if (e.key === ' ') {
      e.preventDefault();
      this.flipped.update((f) => !f);
    } else if (e.key.toLowerCase() === 'p') speakEnglish(this.current()?.vocab.word);
    else if (this.flipped() && /^[1-5]$/.test(e.key)) this.grade(this.grades[Number(e.key) - 1].q);
  }

  reload() {
    this.loading.set(true);
    this.done.set(false);
    this.index.set(0);
    this.flipped.set(false);
    this.remembered.set(0);
    this.forgotten.set(0);
    this.api.review().subscribe({
      next: (cards) => {
        this.cards.set(cards);
        this.total.set(cards.length);
        this.loading.set(false);
      },
      error: () => this.loading.set(false),
    });
  }

  grade(quality: number) {
    const card = this.current();
    if (!card || this.busy()) return;
    this.busy.set(true);
    this.api.submitReview(card.vocab.id, quality).subscribe({
      next: () => {
        this.busy.set(false);
        (quality >= 3 ? this.remembered : this.forgotten).update((n) => n + 1);
        if (this.index() + 1 >= this.cards().length) this.done.set(true);
        else {
          this.index.update((i) => i + 1);
          this.flipped.set(false);
        }
      },
      error: () => this.busy.set(false),
    });
  }
}
