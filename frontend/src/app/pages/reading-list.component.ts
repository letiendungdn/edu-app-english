import { Component, computed, inject, OnInit, signal } from '@angular/core';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { ApiService } from '../core/api.service';
import { questionTypeLabel } from '../core/ielts.models';
import { LEVELS, PassageListItem } from '../core/models';

@Component({
  selector: 'app-reading-list',
  imports: [RouterLink],
  template: `
    <div class="container page">
      <div class="page-head">
        <div>
          <p class="eyebrow">Luyện thi</p>
          <h1>Reading</h1>
          <p>Bài đọc có đủ các dạng câu IELTS. Chọn một dạng câu để luyện riêng điểm yếu.</p>
        </div>
      </div>
      <div class="chips" role="group" aria-label="Lọc theo cấp độ">
        <span class="chips-label">Cấp độ</span>
        <button class="btn" [class.btn-primary]="level() === ''" (click)="setLevel('')">Tất cả</button>
        @for (item of levels; track item) {
          <button class="btn" [class.btn-primary]="level() === item" (click)="setLevel(item)">{{ item }}</button>
        }
      </div>
      <div class="chips" role="group" aria-label="Lọc theo dạng câu">
        <span class="chips-label">Dạng câu</span>
        <button class="btn" [class.btn-primary]="type() === ''" (click)="setType('')">Tất cả</button>
        @for (t of types(); track t) {
          <button class="btn" [class.btn-primary]="type() === t" (click)="setType(t)">{{ typeLabel(t) }}</button>
        }
      </div>
      <div class="grid">
        @for (item of visible(); track item.id) {
          <a class="card" [routerLink]="['/reading', item.id]">
            <span [class]="'badge badge-' + item.level">{{ item.level }}</span>
            @if (item.module !== 'BOTH') { <span class="badge badge-C2">{{ item.module === 'ACADEMIC' ? 'Academic' : 'General' }}</span> }
            <h2 style="margin-top: 0.5rem;">{{ item.title }}</h2>
            <p class="muted small" style="margin-top: 0.25rem;">
              ~{{ item.estimatedMin }} phút · {{ item.questionCount }} câu
              @if (item.bandMin != null) { · band {{ item.bandMin }}–{{ item.bandMax }} }
            </p>
            <div class="row" style="gap: 0.3rem; margin-top: 0.6rem;">
              @for (t of item.questionTypes; track t) { <span class="badge badge-type">{{ typeLabel(t) }}</span> }
            </div>
          </a>
        } @empty {
          <p class="muted">Không có bài nào khớp bộ lọc.</p>
        }
      </div>
    </div>
  `,
})
export class ReadingListComponent implements OnInit {
  private api = inject(ApiService);
  private route = inject(ActivatedRoute);
  private router = inject(Router);
  levels = LEVELS;
  level = signal('');
  type = signal(this.route.snapshot.queryParamMap.get('type') ?? '');
  items = signal<PassageListItem[]>([]);
  typeLabel = questionTypeLabel;
  types = computed(() => [...new Set(this.items().flatMap((i) => i.questionTypes))].sort());
  visible = computed(() => (this.type() ? this.items().filter((i) => i.questionTypes.includes(this.type())) : this.items()));
  ngOnInit() { this.load(); }
  setLevel(level: string) { this.level.set(level); this.load(); }
  setType(type: string) {
    this.type.set(type);
    void this.router.navigate([], { queryParams: { type: type || null }, replaceUrl: true });
  }
  private load() { this.api.reading(this.level()).subscribe((items) => this.items.set(items)); }
}
