import { Component, inject, OnInit, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { ApiService } from '../core/api.service';
import { LEVELS, VocabPage } from '../core/models';

@Component({
  selector: 'app-vocab',
  imports: [RouterLink],
  template: `
    <div class="container page">
      <div class="row" style="justify-content: space-between; margin-bottom: 1rem;">
        <div>
          <h1>Từ vựng</h1>
          <p class="muted">{{ data()?.total ?? 0 }} từ · nhấn thẻ để xem nghĩa</p>
        </div>
        <div class="row">
          <a class="btn" routerLink="/vocab/flashcard">Flashcard</a>
          <a class="btn" routerLink="/vocab/picture">Từ điển tranh</a>
          <a class="btn btn-primary" routerLink="/vocab/review">SRS Review</a>
        </div>
      </div>
      <div class="row" style="margin-bottom: 1rem;">
        <button class="btn" [class.btn-primary]="level() === ''" (click)="setLevel('')">Tất cả</button>
        @for (item of levels; track item) {
          <button class="btn" [class.btn-primary]="level() === item" (click)="setLevel(item)">{{ item }}</button>
        }
      </div>
      @if (loading()) { <p class="muted">Đang tải...</p> }
      <div class="grid">
        @for (word of data()?.words ?? []; track word.id) {
          <button class="card" style="text-align: left; cursor: pointer;" (click)="flip(word.id)">
            <div class="row" style="justify-content: space-between;">
              <span class="badge" [class]="'badge badge-' + word.level">{{ word.level }}</span>
              <span class="muted" style="font-size: 0.75rem;">{{ word.partOfSpeech }}</span>
            </div>
            <div style="font-size: 1.25rem; font-weight: 700;">{{ word.word }}</div>
            <div class="muted">{{ word.phonetic }}</div>
            @if (open() === word.id) {
              <div style="color: var(--accent); font-weight: 600; margin-top: 0.4rem;">{{ word.meaningVi }}</div>
              @if (word.exampleEn) { <div class="muted" style="font-style: italic;">"{{ word.exampleEn }}"</div> }
              @if (word.exampleVi) { <div class="muted">→ {{ word.exampleVi }}</div> }
            } @else {
              <div class="muted" style="margin-top: 0.4rem;">Nhấn để xem nghĩa</div>
            }
            @if (word.topic) { <div class="muted" style="margin-top: 0.4rem;">#{{ word.topic.name }}</div> }
          </button>
        }
      </div>
      @if ((data()?.total ?? 0) > (data()?.limit ?? 30)) {
        <div class="row" style="justify-content: center; margin-top: 1rem;">
          <button class="btn" [disabled]="page() === 1" (click)="changePage(-1)">Trước</button>
          <span class="muted">Trang {{ page() }}</span>
          <button class="btn" (click)="changePage(1)">Sau</button>
        </div>
      }
    </div>
  `,
})
export class VocabComponent implements OnInit {
  private api = inject(ApiService);
  levels = LEVELS;
  level = signal('');
  page = signal(1);
  data = signal<VocabPage | null>(null);
  loading = signal(true);
  open = signal<number | null>(null);

  ngOnInit() { this.load(); }

  setLevel(level: string) {
    this.level.set(level);
    this.page.set(1);
    this.load();
  }

  changePage(delta: number) {
    this.page.update((p) => Math.max(1, p + delta));
    this.load();
  }

  flip(id: number) {
    this.open.set(this.open() === id ? null : id);
  }

  private load() {
    this.loading.set(true);
    this.api.vocab(this.level(), this.page()).subscribe({
      next: (data) => { this.data.set(data); this.loading.set(false); },
      error: () => this.loading.set(false),
    });
  }
}
