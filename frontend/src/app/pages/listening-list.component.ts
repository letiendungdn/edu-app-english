import { Component, computed, inject, OnInit, signal } from '@angular/core';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { ApiService } from '../core/api.service';
import { questionTypeLabel } from '../core/ielts.models';
import { LEVELS, TrackListItem } from '../core/models';

@Component({
  selector: 'app-listening-list',
  imports: [RouterLink],
  template: `
    <div class="container page">
      <div class="page-head">
        <div>
          <p class="eyebrow">Luyện thi</p>
          <h1>Listening</h1>
          <p>Bài nghe theo 4 part của đề thật. Lọc theo part hoặc dạng câu để luyện đúng chỗ yếu.</p>
        </div>
      </div>
      <div class="chips" role="group" aria-label="Lọc theo part">
        <span class="chips-label">Part</span>
        <button class="btn" [class.btn-primary]="part() === 0" (click)="part.set(0)">Tất cả</button>
        @for (p of [1, 2, 3, 4]; track p) {
          <button class="btn" [class.btn-primary]="part() === p" (click)="part.set(p)">Part {{ p }}</button>
        }
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
          <a class="card" [routerLink]="['/listening', item.id]">
            @if (item.ieltsPart) { <span class="badge badge-C1">Part {{ item.ieltsPart }}</span> }
            <span [class]="'badge badge-' + item.level">{{ item.level }}</span>
            <h2 style="margin-top: 0.5rem;">{{ item.title }}</h2>
            <p class="muted small" style="margin-top: 0.25rem;">{{ item.questionCount }} câu</p>
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
export class ListeningListComponent implements OnInit {
  private api = inject(ApiService);
  private route = inject(ActivatedRoute);
  private router = inject(Router);
  levels = LEVELS;
  level = signal('');
  part = signal(0);
  type = signal(this.route.snapshot.queryParamMap.get('type') ?? '');
  items = signal<TrackListItem[]>([]);
  typeLabel = questionTypeLabel;
  types = computed(() => [...new Set(this.items().flatMap((i) => i.questionTypes))].sort());
  visible = computed(() =>
    this.items().filter(
      (i) => (!this.type() || i.questionTypes.includes(this.type())) && (!this.part() || i.ieltsPart === this.part()),
    ),
  );
  ngOnInit() { this.load(); }
  setLevel(level: string) { this.level.set(level); this.load(); }
  setType(type: string) {
    this.type.set(type);
    void this.router.navigate([], { queryParams: { type: type || null }, replaceUrl: true });
  }
  private load() { this.api.listening(this.level()).subscribe((items) => this.items.set(items)); }
}
