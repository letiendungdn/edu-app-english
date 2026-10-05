import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ApiService } from '../core/api.service';
import { DictationWord, LEVELS } from '../core/models';

function normalize(value: string) {
  return value.trim().toLowerCase().replace(/[.,!?'"]/g, '').replace(/\s+/g, ' ');
}

@Component({
  selector: 'app-dictation',
  imports: [FormsModule],
  template: `
    <div class="container page" style="max-width: 640px;">
      <h1>Nghe chép chính tả</h1>
      <p class="muted" style="margin-bottom: 1rem;">Nghe từ tiếng Anh rồi gõ lại chính xác.</p>
      @if (queue().length === 0) {
        <div class="card">
          <div class="row" style="margin-bottom: 1rem;">
            @for (item of levels; track item) {
              <button class="btn" type="button" [class.btn-primary]="level() === item" (click)="level.set(item)">{{ item }}</button>
            }
          </div>
          <button class="btn btn-primary" type="button" (click)="start()">Bắt đầu</button>
        </div>
      } @else if (finished()) {
        <div class="card" style="text-align: center;">
          <h2>{{ score().correct }}/{{ score().total }} đúng</h2>
          <button class="btn" style="margin-top: 1rem;" (click)="queue.set([])">Chọn cấp khác</button>
        </div>
      } @else {
        <p class="muted">{{ index() + 1 }} / {{ queue().length }} · điểm {{ score().correct }}/{{ score().total }}</p>
        <div class="card" style="margin-top: 0.75rem;">
          <button class="btn" type="button" (click)="speak()">Nghe lại</button>
          <input style="margin-top: 0.75rem;" [(ngModel)]="input" (keyup.enter)="check()" [disabled]="feedback() !== ''" placeholder="Gõ từ bạn nghe được" />
          @if (!feedback()) {
            <button class="btn btn-primary" style="margin-top: 0.75rem;" (click)="check()">Kiểm tra</button>
          } @else {
            <p [style.color]="feedback() === 'correct' ? 'var(--success)' : 'var(--danger)'" style="margin-top: 0.75rem;">
              {{ feedback() === 'correct' ? 'Đúng' : 'Đáp án: ' + current().word }}
            </p>
            <p class="muted">{{ current().meaningVi }}</p>
            <button class="btn" style="margin-top: 0.75rem;" (click)="next()">Tiếp</button>
          }
        </div>
      }
    </div>
  `,
})
export class DictationComponent {
  private api = inject(ApiService);
  levels = LEVELS;
  level = signal('A1');
  queue = signal<DictationWord[]>([]);
  index = signal(0);
  input = '';
  feedback = signal('');
  score = signal({ correct: 0, total: 0 });

  current() { return this.queue()[this.index()]; }
  finished() { return this.queue().length > 0 && this.index() >= this.queue().length; }

  start() {
    this.api.dictation(this.level()).subscribe((words) => {
      const shuffled = [...words].sort(() => Math.random() - 0.5);
      this.queue.set(shuffled);
      this.index.set(0);
      this.score.set({ correct: 0, total: 0 });
      this.input = '';
      this.feedback.set('');
      setTimeout(() => this.speak(), 200);
    });
  }

  speak() {
    const word = this.current();
    if (!word) return;
    const utter = new SpeechSynthesisUtterance(word.word);
    utter.lang = 'en-US';
    utter.rate = 0.8;
    speechSynthesis.cancel();
    speechSynthesis.speak(utter);
  }

  check() {
    const word = this.current();
    if (!word || this.feedback()) return;
    const correct = normalize(this.input) === normalize(word.word);
    this.feedback.set(correct ? 'correct' : 'wrong');
    this.score.update((s) => ({ correct: s.correct + (correct ? 1 : 0), total: s.total + 1 }));
    this.api.recordDictation(word.id, this.input, correct).subscribe({ error: () => undefined });
  }

  next() {
    this.index.update((i) => i + 1);
    this.input = '';
    this.feedback.set('');
    setTimeout(() => this.speak(), 100);
  }
}
