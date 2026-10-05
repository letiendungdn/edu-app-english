import { Component, inject, OnInit, signal } from '@angular/core';
import { ApiService } from '../core/api.service';
import { LEVELS, VocabWord } from '../core/models';

@Component({
  selector: 'app-flashcard',
  template: `
    <div class="container page" style="max-width: 640px;">
      <h1>Flashcard</h1>
      <div class="row" style="margin: 1rem 0;">
        @for (item of levels; track item) {
          <button class="btn" [class.btn-primary]="level() === item" (click)="setLevel(item)">{{ item }}</button>
        }
      </div>
      @if (words().length === 0) {
        <p class="muted">Chưa có từ ở cấp này.</p>
      } @else {
        <p class="muted" style="text-align: center;">{{ index() + 1 }} / {{ words().length }}</p>
        <button class="card flashcard" (click)="flipped.set(!flipped())">
          <span class="badge" [class]="'badge badge-' + current()!.level">{{ current()!.level }}</span>
          @if (!flipped()) {
            <div style="font-size: 2rem; font-weight: 800;">{{ current()!.word }}</div>
            <div class="muted">{{ current()!.phonetic }}</div>
            <div class="muted" style="margin-top: 1rem;">Nhấn để lật thẻ</div>
          } @else {
            <div style="font-size: 1.4rem; font-weight: 700; color: var(--accent);">{{ current()!.meaningVi }}</div>
            @if (current()!.exampleEn) { <div class="muted" style="font-style: italic; margin-top: 0.75rem;">"{{ current()!.exampleEn }}"</div> }
          }
        </button>
        <div class="row" style="justify-content: center; margin-top: 1rem;">
          <button class="btn" (click)="step(-1)">Trước</button>
          <button class="btn" type="button" (click)="speak()">Nghe</button>
          <button class="btn" (click)="step(1)">Sau</button>
        </div>
      }
    </div>
  `,
})
export class FlashcardComponent implements OnInit {
  private api = inject(ApiService);
  levels = LEVELS;
  level = signal('A1');
  words = signal<VocabWord[]>([]);
  index = signal(0);
  flipped = signal(false);

  ngOnInit() { this.load(); }

  current() { return this.words()[this.index()]; }

  setLevel(level: string) {
    this.level.set(level);
    this.load();
  }

  step(delta: number) {
    const next = this.index() + delta;
    if (next < 0 || next >= this.words().length) return;
    this.index.set(next);
    this.flipped.set(false);
  }

  speak() {
    const word = this.current();
    if (!word) return;
    const utter = new SpeechSynthesisUtterance(word.word);
    utter.lang = 'en-US';
    speechSynthesis.cancel();
    speechSynthesis.speak(utter);
  }

  private load() {
    this.api.vocab(this.level(), 1).subscribe((page) => {
      this.words.set(page.words);
      this.index.set(0);
      this.flipped.set(false);
    });
  }
}
