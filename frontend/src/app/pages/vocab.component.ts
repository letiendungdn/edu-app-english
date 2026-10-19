import { AfterViewInit, Component, computed, ElementRef, inject, OnDestroy, OnInit, signal, viewChild } from '@angular/core';
import { RouterLink } from '@angular/router';
import { ApiService } from '../core/api.service';
import { LEVELS, VocabPage, VocabWord } from '../core/models';
import { RespellPipe } from '../shared/respell';
import { PhonicsHintsComponent } from '../shared/phonics-hints.component';

@Component({
  selector: 'app-vocab',
  imports: [PhonicsHintsComponent, RespellPipe, RouterLink],
  template: `
    <div class="container page">
      <div class="row" style="justify-content: space-between; margin-bottom: 1rem;">
        <div>
          <h1>Từ vựng</h1>
          <p class="muted">{{ data()?.total ?? 0 }} từ · nhấn thẻ để xem nghĩa</p>
          <p class="muted" style="font-size: 0.8rem; max-width: 42rem;">Cấp độ theo CEFR-J Wordlist 1.5 (Tono Laboratory, TUFS) và Octanove C1–C2 (CC BY-SA 4.0). Từ ngoài danh sách đó xếp theo tần suất OpenSubtitles (FrequencyWords, CC BY-SA 4.0). Nghĩa tiếng Việt từ Wiktionary (CC BY-SA 3.0). Nghĩa tiếng Anh từ Wordset (CC BY-SA 4.0), dựa trên WordNet 3.0, bản quyền 2006 Princeton University, cung cấp nguyên trạng. Câu ví dụ từ Tatoeba (CC BY 2.0 FR) và Wiktionary (CC BY-SA 3.0).</p>
        </div>
        <div class="row">
          <a class="btn" routerLink="/vocab/flashcard">Flashcard</a>
          <a class="btn" routerLink="/vocab/picture">Từ điển tranh</a>
          <a class="btn" routerLink="/phonics">Quy tắc phát âm</a>
          <a class="btn btn-primary" routerLink="/vocab/review">SRS Review</a>
        </div>
      </div>
      <div class="row" style="margin-bottom: 1rem;">
        <button class="btn" [class.btn-primary]="level() === ''" (click)="setLevel('')">Tất cả</button>
        @for (item of levels; track item) {
          <button class="btn" [class.btn-primary]="level() === item" (click)="setLevel(item)">{{ item }}</button>
        }
      </div>
      <div class="row" style="margin-bottom: 1rem;" role="group" aria-label="Mức ưu tiên">
        @for (p of priorities; track p.value) {
          <button class="btn btn-sm" [class.btn-primary]="priority() === p.value" (click)="setPriority(p.value)" [title]="p.hint">{{ p.label }}</button>
        }
        @if (query().trim()) { <span class="muted small" style="align-self: center;">Khi tìm kiếm, hiện mọi từ.</span> }
      </div>
      <input type="search" placeholder="Tìm từ hoặc nghĩa, ví dụ: apple, táo…" [value]="query()"
             (input)="onSearch($any($event.target).value)" aria-label="Tìm từ vựng"
             style="max-width: 32rem; margin-bottom: 1.25rem;" />
      @if (loading() && !words().length) { <p class="muted">Đang tải...</p> }
      @else if (!words().length) { <p class="muted">Không có từ nào khớp.</p> }
      <div class="grid">
        @for (word of words(); track word.id) {
          <button class="card" style="text-align: left; cursor: pointer;" (click)="flip(word.id)">
            <div class="row" style="justify-content: space-between;">
              <span class="row" style="gap: 0.3rem;">
                <span class="badge" [class]="'badge badge-' + word.level">{{ word.level }}</span>
                @if (word.priority === 'EXTRA') { <span class="badge badge-extra" title="Từ hiếm, ít gặp trong đề IELTS">Ít gặp</span> }
              </span>
              <span class="muted" style="font-size: 0.75rem;">{{ word.partOfSpeech }}</span>
            </div>
            <div style="font-size: 1.25rem; font-weight: 700;">{{ word.word }}</div>
            @if (word.phonetic) { <div class="muted">{{ word.phonetic }} <span class="respell">· {{ word.phonetic | respell }}</span></div> }
            @if (open() === word.id) {
              <div style="color: var(--accent); font-weight: 600; margin-top: 0.4rem;">{{ word.meaningVi }}</div>
              @if (word.meaningEn) { <div class="muted">{{ word.meaningEn }}</div> }
              @if (word.exampleEn) { <div class="muted" style="font-style: italic;">"{{ word.exampleEn }}"</div> }
              @if (word.exampleVi) { <div class="muted">→ {{ word.exampleVi }}</div> }
              <app-phonics-hints [word]="word.word" [phonetic]="word.phonetic" [pos]="word.partOfSpeech" />
              @if (word.family) { <div class="small" style="margin-top: 0.3rem;"><span class="muted">Họ từ:</span> {{ word.family }}</div> }
              <span class="btn" style="margin-top: 0.5rem;" (click)="speak(word.word, $event)">Nghe</span>
            } @else {
              <div class="muted" style="margin-top: 0.4rem;">Nhấn để xem nghĩa</div>
            }
            @if (word.topic) { <div class="muted" style="margin-top: 0.4rem;">#{{ word.topic.name }}</div> }
          </button>
        }
      </div>
      <!-- Mốc cuối danh sách: lọt vào màn hình thì tự tải thêm. -->
      <div #sentinel style="height: 1px;"></div>
      @if (words().length) {
        <p class="muted small" style="text-align: center; margin-top: 1rem;">
          @if (loading()) { Đang tải thêm... }
          @else if (hasMore()) { Đang hiện {{ words().length }} / {{ data()?.total ?? 0 }} từ · kéo xuống để xem thêm }
          @else { Đã hiện hết {{ words().length }} từ }
        </p>
      }
    </div>
  `,
})
export class VocabComponent implements OnInit, AfterViewInit, OnDestroy {
  private api = inject(ApiService);
  levels = LEVELS;
  level = signal('');
  query = signal('');
  /** Mặc định chỉ học phần cốt lõi; từ hiếm để sau. */
  priority = signal<'core' | 'extra' | ''>('core');
  priorities: { value: 'core' | 'extra' | ''; label: string; hint: string }[] = [
    { value: 'core', label: 'Cốt lõi IELTS', hint: 'Từ cần cho IELTS: học trước' },
    { value: 'extra', label: 'Mở rộng (ít gặp)', hint: 'Từ hiếm, ít gặp trong đề: học sau' },
    { value: '', label: 'Tất cả', hint: 'Cả cốt lõi và mở rộng' },
  ];
  page = signal(1);
  private searchTimer?: number;
  data = signal<VocabPage | null>(null);
  words = signal<VocabWord[]>([]);
  hasMore = computed(() => this.words().length < (this.data()?.total ?? 0));
  private request = 0;
  private sentinel = viewChild<ElementRef<HTMLElement>>('sentinel');
  private observer?: IntersectionObserver;
  loading = signal(true);
  open = signal<number | null>(null);

  ngOnInit() { this.load(); }

  ngAfterViewInit() {
    const el = this.sentinel()?.nativeElement;
    if (!el || !('IntersectionObserver' in window)) return;
    // Tải trước khi người dùng chạm hẳn đáy trang.
    this.observer = new IntersectionObserver((entries) => {
      if (entries.some((e) => e.isIntersecting)) this.loadMore();
    }, { rootMargin: '600px 0px' });
    this.observer.observe(el);
  }

  ngOnDestroy() {
    this.observer?.disconnect();
    window.clearTimeout(this.searchTimer);
  }

  /** Màn hình cao mà một trang chưa lấp đầy thì mốc vẫn nằm trong vùng nhìn: quan sát lại để tải tiếp. */
  private recheck() {
    const el = this.sentinel()?.nativeElement;
    if (!el || !this.observer) return;
    this.observer.unobserve(el);
    this.observer.observe(el);
  }

  setPriority(value: 'core' | 'extra' | '') {
    this.priority.set(value);
    this.resetAndLoad();
  }

  setLevel(level: string) {
    this.level.set(level);
    this.resetAndLoad();
  }

  onSearch(value: string) {
    this.query.set(value);
    window.clearTimeout(this.searchTimer);
    this.searchTimer = window.setTimeout(() => this.resetAndLoad(), 250);
  }

  private resetAndLoad() {
    this.page.set(1);
    this.words.set([]);
    this.open.set(null);
    this.load();
  }

  loadMore() {
    if (this.loading() || !this.hasMore()) return;
    this.page.update((p) => p + 1);
    this.load();
  }

  flip(id: number) {
    this.open.set(this.open() === id ? null : id);
  }

  speak(text: string, event: Event) {
    event.stopPropagation();
    event.preventDefault();
    const utter = new SpeechSynthesisUtterance(text);
    utter.lang = 'en-US';
    speechSynthesis.cancel();
    speechSynthesis.speak(utter);
  }

  private load() {
    // Đổi cấp độ giữa chừng thì bỏ kết quả của lần tải cũ.
    const request = ++this.request;
    this.loading.set(true);
    this.api.vocab(this.level(), this.page(), 30, '', this.query(), this.query().trim() ? '' : this.priority()).subscribe({
      next: (data) => {
        if (request !== this.request) return;
        this.data.set(data);
        this.words.update((list) => [...list, ...data.words.filter((w) => !list.some((x) => x.id === w.id))]);
        this.loading.set(false);
        setTimeout(() => this.recheck());
      },
      error: () => { if (request === this.request) this.loading.set(false); },
    });
  }
}
