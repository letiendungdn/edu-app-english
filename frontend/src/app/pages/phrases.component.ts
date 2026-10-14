import { Component, computed, inject, OnInit, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { ApiService } from '../core/api.service';
import { WritingPhraseView } from '../core/ielts.models';

/** Ngân hàng cụm từ Writing: từ nối, mở bài, mô tả số liệu, viết thư. Lọc theo task và tìm nhanh. */
@Component({
  selector: 'app-phrases',
  imports: [RouterLink],
  template: `
    <div class="container page">
      <a routerLink="/writing" class="muted">← Writing</a>
      <div class="page-head" style="margin-top: 0.5rem;">
        <div>
          <p class="eyebrow">Writing</p>
          <h1>Cụm từ hay dùng</h1>
          <p>Từ nối và cấu trúc cho Task 1, Task 2 và viết thư. Dùng đúng chỗ giúp tăng điểm Coherence & Cohesion và Lexical Resource. Đừng nhồi nhét: mỗi đoạn 2–3 từ nối là đủ.</p>
        </div>
      </div>

      <div class="chips" role="group" aria-label="Lọc theo task">
        @for (f of filters; track f.value) {
          <button class="btn" [class.btn-primary]="task() === f.value" (click)="task.set(f.value)">{{ f.label }}</button>
        }
      </div>
      <input type="search" placeholder="Tìm cụm từ hoặc nghĩa, ví dụ: however, tăng, kết luận…" [value]="query()"
             (input)="query.set($any($event.target).value)" aria-label="Tìm cụm từ" style="max-width: 32rem; margin-bottom: 1.25rem;" />

      @for (g of groups(); track g.category) {
        <h2 class="section-title">{{ g.category }}</h2>
        <div class="grid" style="grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));">
          @for (p of g.items; track p.id) {
            <div class="card" style="display: flex; flex-direction: column; gap: 0.35rem;">
              <div class="row" style="justify-content: space-between; align-items: flex-start; flex-wrap: nowrap;">
                <strong style="font-size: 1rem;">{{ p.phrase }}</strong>
                @if (p.bandMin) { <span class="badge badge-type" title="Nên dùng khi đã vững band này">Band {{ p.bandMin }}+</span> }
              </div>
              <div class="muted small">{{ p.meaningVi }}</div>
              <div class="evidence small" style="font-style: normal;">{{ p.example }}</div>
              <button class="btn btn-sm btn-ghost" style="align-self: flex-end; margin-top: auto;" (click)="copy(p)">
                {{ copied() === p.id ? 'Đã chép ✓' : 'Chép ví dụ' }}
              </button>
            </div>
          }
        </div>
      } @empty {
        <p class="muted">Không có cụm từ nào khớp.</p>
      }
    </div>
  `,
})
export class PhrasesComponent implements OnInit {
  private api = inject(ApiService);
  phrases = signal<WritingPhraseView[]>([]);
  task = signal<'' | 'TASK1' | 'TASK2' | 'BOTH'>('');
  query = signal('');
  copied = signal<number | null>(null);

  filters: { value: '' | 'TASK1' | 'TASK2' | 'BOTH'; label: string }[] = [
    { value: '', label: 'Tất cả' },
    { value: 'TASK1', label: 'Task 1 (biểu đồ, quy trình)' },
    { value: 'TASK2', label: 'Task 2 (nghị luận)' },
    { value: 'BOTH', label: 'Viết thư (General)' },
  ];

  groups = computed(() => {
    const q = this.query().trim().toLowerCase();
    const list = this.phrases().filter(
      (p) =>
        (!this.task() || p.task === this.task()) &&
        (!q || p.phrase.toLowerCase().includes(q) || p.meaningVi.toLowerCase().includes(q) || p.example.toLowerCase().includes(q)),
    );
    const byCategory = new Map<string, WritingPhraseView[]>();
    for (const p of list) byCategory.set(p.category, [...(byCategory.get(p.category) ?? []), p]);
    return [...byCategory.entries()].map(([category, items]) => ({ category, items }));
  });

  ngOnInit() {
    this.api.writingPhrases().subscribe((p) => this.phrases.set(p));
  }

  copy(p: WritingPhraseView) {
    navigator.clipboard?.writeText(p.example).then(
      () => {
        this.copied.set(p.id);
        window.setTimeout(() => this.copied.set(null), 1500);
      },
      () => {},
    );
  }
}
