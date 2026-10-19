import { Component, computed, HostListener, inject, OnInit, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { ApiService } from '../core/api.service';
import { AuthService } from '../core/auth.service';
import { LEVELS, TopicCount, VocabWord } from '../core/models';
import { FlipCardComponent, speakEnglish } from '../shared/flip-card.component';

/** Học theo bộ nhỏ: tải cả cấp độ (hơn 1000 từ) một lần vừa chậm vừa ngợp. */
const SET_SIZE = 20;
const SET_KEY = 'flashcard_set_';
const EXTRA_KEY = 'flashcard_with_extra';

/** Chất lượng gửi cho SM-2: "Chưa nhớ" cho ôn lại sớm, "Đã nhớ" giãn lịch ôn. */
const QUALITY_AGAIN = 1;
const QUALITY_KNOW = 4;

@Component({
  selector: 'app-flashcard',
  imports: [RouterLink, FlipCardComponent],
  template: `
    <div class="container page" style="max-width: 720px;">
      <a routerLink="/vocab" class="muted small">← Từ vựng</a>
      <div class="deck-head" style="margin-top: 0.5rem;">
        <div>
          <p class="eyebrow">Từ vựng</p>
          <h1>Flashcard</h1>
        </div>
        <div class="row">
          <button class="btn btn-sm" (click)="toggleShuffle()" [class.btn-primary]="shuffled()" [attr.aria-pressed]="shuffled()">Trộn thẻ</button>
          <a class="btn btn-sm" routerLink="/vocab/review">Ôn thẻ đến hạn</a>
        </div>
      </div>

      <div class="chips" role="group" aria-label="Cách chọn từ">
        <button class="btn" [class.btn-primary]="!topic()" (click)="setLevel(level())">Theo cấp độ</button>
        <button class="btn" [class.btn-primary]="!!topic()" (click)="setTopic(topic() || firstTopic())" [disabled]="!ieltsTopics().length">Theo chủ đề IELTS</button>
      </div>
      @if (topic()) {
        <div class="chips" role="group" aria-label="Chủ đề IELTS">
          @for (t of ieltsTopics(); track t.name) {
            <button class="btn" [class.btn-primary]="topic() === t.name" (click)="setTopic(t.name)">{{ t.icon }} {{ topicLabel(t.name) }} <span class="muted">{{ t.count }}</span></button>
          }
        </div>
      } @else {
        <div class="chips" role="group" aria-label="Cấp độ">
          <span class="chips-label">Cấp độ</span>
          @for (item of levels; track item) {
            <button class="btn" [class.btn-primary]="level() === item" (click)="setLevel(item)">{{ item }}</button>
          }
          <span class="muted small" style="align-self: center;">Band 6.5 nên chắc B2–C1.</span>
          <label class="small" style="align-self: center; display: inline-flex; gap: 0.35rem; align-items: center;" title="Mặc định chỉ học từ cốt lõi cho IELTS">
            <input type="checkbox" [checked]="withExtra()" (change)="toggleExtra($any($event.target).checked)" /> Gồm từ ít gặp
          </label>
        </div>
      }

      @if (loading()) {
        <p class="muted">Đang tải…</p>
      } @else if (words().length === 0) {
        <div class="card empty"><strong>Chưa có từ ở cấp này</strong></div>
      } @else if (finished()) {
        <div class="card deck-done">
          <div class="big">🎉</div>
          <h2>Xong bộ {{ setNo() }}/{{ setCount() }}</h2>
          <div class="deck-stats">
            <div><strong class="ok">{{ known().size }}</strong><span class="muted small">Đã nhớ</span></div>
            <div><strong style="color: var(--danger);">{{ again().size }}</strong><span class="muted small">Chưa nhớ</span></div>
          </div>
          @if (auth.loggedIn()) {
            <p class="muted small" style="margin-bottom: 1rem;">Các từ đã được thêm vào lịch ôn SRS. Từ chưa nhớ sẽ quay lại sớm hơn.</p>
          } @else {
            <p class="muted small" style="margin-bottom: 1rem;"><a routerLink="/login">Đăng nhập</a> để app nhắc ôn đúng lúc theo thuật toán SM-2.</p>
          }
          <div class="row" style="justify-content: center;">
            @if (again().size) { <button class="btn btn-again" (click)="retryAgain()">Học lại {{ again().size }} từ chưa nhớ</button> }
            <button class="btn" (click)="restart()">Học lại cả bộ</button>
            @if (setNo() < setCount()) { <button class="btn btn-primary" (click)="goSet(setNo() + 1)">Bộ tiếp theo →</button> }
          </div>
        </div>
      } @else if (current()) {
        <div class="deck-progress">
          <button class="btn btn-sm btn-ghost" (click)="goSet(setNo() - 1)" [disabled]="setNo() <= 1" aria-label="Bộ trước">‹</button>
          <span>Bộ {{ setNo() }}/{{ setCount() }}</span>
          <button class="btn btn-sm btn-ghost" (click)="goSet(setNo() + 1)" [disabled]="setNo() >= setCount()" aria-label="Bộ sau">›</button>
          <div class="progress"><div [style.width.%]="percent()"></div></div>
          <span>{{ index() + 1 }}/{{ deck().length }}</span>
        </div>

        <!-- Đổi thẻ thì tạo thẻ mới, để thẻ mới luôn hiện mặt trước, không lật ngược. -->
        @for (one of [current()!]; track one.id) {
          <app-flip-card [word]="one" [flipped]="flipped()" (flip)="flipped.set(!flipped())" />
        }

        <div class="deck-actions">
          <button class="btn nav-step" (click)="step(-1)" [disabled]="index() === 0" aria-label="Thẻ trước">←</button>
          <button class="btn btn-again" (click)="mark(false)">Chưa nhớ <kbd>1</kbd></button>
          <button class="btn btn-know" (click)="mark(true)">Đã nhớ <kbd>2</kbd></button>
          <button class="btn nav-step" (click)="step(1)" aria-label="Thẻ sau">→</button>
        </div>
        <div class="key-hints">
          <span><kbd>Space</kbd> lật thẻ</span>
          <span><kbd>←</kbd> <kbd>→</kbd> chuyển thẻ</span>
          <span><kbd>P</kbd> nghe phát âm</span>
        </div>
      }
    </div>
  `,
})
export class FlashcardComponent implements OnInit {
  private api = inject(ApiService);
  auth = inject(AuthService);
  levels = LEVELS;
  level = signal('A1');
  /** Tên chủ đề đang học; rỗng là học theo cấp độ. */
  topic = signal('');
  /** Học cả từ hiếm (EXTRA). Mặc định tắt: chỉ học từ cốt lõi cho IELTS. */
  withExtra = signal(this.savedExtra());
  ieltsTopics = signal<TopicCount[]>([]);
  setNo = signal(1);
  total = signal(0);
  words = signal<VocabWord[]>([]);
  /** Thứ tự đang học: cả bộ, bộ đã trộn, hoặc chỉ các từ chưa nhớ. */
  deck = signal<VocabWord[]>([]);
  index = signal(0);
  flipped = signal(false);
  shuffled = signal(false);
  loading = signal(true);
  finished = signal(false);
  known = signal(new Set<number>());
  again = signal(new Set<number>());

  current = computed(() => this.deck()[this.index()]);
  setCount = computed(() => Math.max(1, Math.ceil(this.total() / SET_SIZE)));
  percent = computed(() => (this.deck().length ? ((this.index() + 1) / this.deck().length) * 100 : 0));

  ngOnInit() {
    this.setNo.set(this.savedSet(this.deckKey()));
    this.load();
    this.api.vocabTopics().subscribe({
      next: (list) => this.ieltsTopics.set(list.filter((t) => t.name.startsWith('IELTS '))),
      error: () => this.ieltsTopics.set([]),
    });
  }

  firstTopic() {
    const list = this.ieltsTopics();
    return list.length ? list[0].name : '';
  }

  topicLabel(name: string) {
    return name.replace(/^IELTS /, '');
  }

  setTopic(name: string) {
    if (!name) return;
    this.topic.set(name);
    this.setNo.set(this.savedSet(this.deckKey()));
    this.load();
  }

  /** Khoá nhớ bộ đang học: theo chủ đề hoặc theo cấp độ (bộ có từ ít gặp đánh số riêng). */
  private deckKey() {
    return this.topic() ? 'topic:' + this.topic() : this.level() + (this.withExtra() ? ':all' : '');
  }

  toggleExtra(on: boolean) {
    this.withExtra.set(on);
    try {
      localStorage.setItem(EXTRA_KEY, on ? '1' : '0');
    } catch {
      // Không lưu được (chế độ riêng tư): chỉ áp dụng trong phiên này.
    }
    this.setNo.set(this.savedSet(this.deckKey()));
    this.load();
  }

  private savedExtra() {
    try {
      return localStorage.getItem(EXTRA_KEY) === '1';
    } catch {
      return false;
    }
  }

  @HostListener('window:keydown', ['$event'])
  onKey(e: KeyboardEvent) {
    const target = e.target as HTMLElement | null;
    if (target && /^(INPUT|TEXTAREA|SELECT)$/.test(target.tagName)) return;
    if (this.finished() || !this.current()) return;
    if (e.key === ' ') {
      e.preventDefault();
      this.flipped.update((f) => !f);
    } else if (e.key === 'ArrowRight') this.step(1);
    else if (e.key === 'ArrowLeft') this.step(-1);
    else if (e.key === '1') this.mark(false);
    else if (e.key === '2') this.mark(true);
    else if (e.key.toLowerCase() === 'p') speakEnglish(this.current()?.word);
  }

  setLevel(level: string) {
    this.topic.set('');
    this.level.set(level);
    this.setNo.set(this.savedSet(this.deckKey()));
    this.load();
  }

  goSet(n: number) {
    if (n < 1 || n > this.setCount()) return;
    this.setNo.set(n);
    try {
      localStorage.setItem(SET_KEY + this.deckKey(), String(n));
    } catch {
      // Không lưu được thì lần sau bắt đầu lại từ bộ 1.
    }
    this.load();
  }

  toggleShuffle() {
    this.shuffled.update((s) => !s);
    this.startDeck(this.words());
  }

  step(delta: number) {
    const next = this.index() + delta;
    if (next < 0) return;
    if (next >= this.deck().length) {
      this.finished.set(true);
      return;
    }
    this.index.set(next);
    this.flipped.set(false);
  }

  /** Đánh dấu rồi sang thẻ sau. Đăng nhập thì ghi vào SRS để app nhắc ôn. */
  mark(remembered: boolean) {
    const w = this.current();
    if (!w) return;
    this.known.update((s) => {
      const n = new Set(s);
      remembered ? n.add(w.id) : n.delete(w.id);
      return n;
    });
    this.again.update((s) => {
      const n = new Set(s);
      remembered ? n.delete(w.id) : n.add(w.id);
      return n;
    });
    if (this.auth.loggedIn()) this.api.submitReview(w.id, remembered ? QUALITY_KNOW : QUALITY_AGAIN).subscribe({ error: () => {} });
    this.step(1);
  }

  retryAgain() {
    const ids = this.again();
    this.startDeck(this.words().filter((w) => ids.has(w.id)), false);
  }

  restart() {
    this.startDeck(this.words());
  }

  private startDeck(words: VocabWord[], resetMarks = true) {
    const list = [...words];
    if (this.shuffled()) {
      for (let i = list.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [list[i], list[j]] = [list[j], list[i]];
      }
    }
    this.deck.set(list);
    this.index.set(0);
    this.flipped.set(false);
    this.finished.set(false);
    if (resetMarks) {
      this.known.set(new Set());
      this.again.set(new Set());
    }
  }

  private load() {
    this.loading.set(true);
    this.api.vocab(this.topic() ? '' : this.level(), this.setNo(), SET_SIZE, this.topic(), '', this.topic() || this.withExtra() ? '' : 'core').subscribe({
      next: (page) => {
        this.total.set(page.total);
        // Bộ đã lưu vượt quá số bộ hiện có (dữ liệu đổi): quay về bộ 1.
        if (page.words.length === 0 && this.setNo() > 1) {
          this.setNo.set(1);
          this.load();
          return;
        }
        this.words.set(page.words);
        this.startDeck(page.words);
        this.loading.set(false);
      },
      error: () => this.loading.set(false),
    });
  }

  private savedSet(key: string) {
    try {
      return Math.max(1, Number(localStorage.getItem(SET_KEY + key)) || 1);
    } catch {
      return 1;
    }
  }
}
