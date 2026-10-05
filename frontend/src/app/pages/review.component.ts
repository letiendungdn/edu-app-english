import { Component, inject, OnInit, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { ApiService } from '../core/api.service';
import { AuthService } from '../core/auth.service';
import { ReviewCard } from '../core/models';

@Component({
  selector: 'app-review',
  imports: [RouterLink],
  template: `
    <div class="container page" style="max-width: 640px;">
      <h1>SRS Review</h1>
      @if (!auth.loggedIn()) {
        <p class="muted" style="margin-top: 1rem;">Đăng nhập để ôn thẻ theo thuật toán SM-2.</p>
        <a class="btn btn-primary" routerLink="/login">Đăng nhập</a>
      } @else if (loading()) {
        <p class="muted">Đang tải...</p>
      } @else if (done()) {
        <div class="card" style="text-align: center; margin-top: 1rem;">
          <h2>Xong {{ total() }} thẻ</h2>
          <p class="muted">Không còn thẻ nào cần ôn hôm nay.</p>
          <button class="btn btn-primary" style="margin-top: 1rem;" (click)="reload()">Ôn lại</button>
        </div>
      } @else if (!current()) {
        <p class="muted" style="margin-top: 1rem;">Không có thẻ nào cần ôn hôm nay.</p>
      } @else {
        <p class="muted">{{ index() + 1 }} / {{ cards().length }}</p>
        <button class="card flashcard" (click)="flipped.set(true)">
          <span class="badge" [class]="'badge badge-' + current()!.vocab.level">{{ current()!.vocab.level }}</span>
          <div style="font-size: 2rem; font-weight: 800;">{{ current()!.vocab.word }}</div>
          <div class="muted">{{ current()!.vocab.phonetic }}</div>
          @if (flipped()) {
            <div style="margin-top: 0.8rem; color: var(--accent); font-weight: 700;">{{ current()!.vocab.meaningVi }}</div>
          } @else {
            <div class="muted" style="margin-top: 0.8rem;">Nhấn để lật thẻ</div>
          }
        </button>
        @if (flipped()) {
          <div class="row" style="margin-top: 1rem;">
            @for (item of grades; track item.q) {
              <button class="btn" [disabled]="busy()" (click)="grade(item.q)" [style.border-color]="item.color" [style.color]="item.color">{{ item.label }}</button>
            }
          </div>
        }
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
  grades = [
    { q: 0, label: 'Không biết', color: '#ef4444' },
    { q: 2, label: 'Khó', color: '#f97316' },
    { q: 3, label: 'Được', color: '#eab308' },
    { q: 4, label: 'Dễ', color: '#22c55e' },
    { q: 5, label: 'Rất dễ', color: '#3b82f6' },
  ];

  ngOnInit() {
    if (this.auth.loggedIn()) this.reload();
    else this.loading.set(false);
  }

  current() { return this.cards()[this.index()]; }

  reload() {
    this.loading.set(true);
    this.done.set(false);
    this.index.set(0);
    this.flipped.set(false);
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
    if (!card) return;
    this.busy.set(true);
    this.api.submitReview(card.vocab.id, quality).subscribe({
      next: () => {
        this.busy.set(false);
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
