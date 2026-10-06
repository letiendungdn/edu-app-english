import { Component, inject, OnInit, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { ApiService } from '../core/api.service';
import { LEVELS, PassageListItem } from '../core/models';

@Component({
  selector: 'app-reading-list',
  imports: [RouterLink],
  template: `
    <div class="container page">
      <h1>Đọc hiểu</h1>
      <div class="row" style="margin: 1rem 0;">
        <button class="btn" [class.btn-primary]="level() === ''" (click)="setLevel('')">Tất cả</button>
        @for (item of levels; track item) {
          <button class="btn" [class.btn-primary]="level() === item" (click)="setLevel(item)">{{ item }}</button>
        }
      </div>
      <div class="grid">
        @for (item of items(); track item.id) {
          <a class="card" [routerLink]="['/reading', item.id]" style="text-decoration: none;">
            <span class="badge" [class]="'badge badge-' + item.level">{{ item.level }}</span>
            @if (item.module !== 'BOTH') { <span class="badge badge-C2">{{ item.module === 'ACADEMIC' ? 'Academic' : 'General' }}</span> }
            <h2 style="margin-top: 0.4rem;">{{ item.title }}</h2>
            <p class="muted">
              ~{{ item.estimatedMin }} phút · {{ item.questionCount }} câu hỏi
              @if (item.bandMin != null) { · band {{ item.bandMin }}–{{ item.bandMax }} }
            </p>
          </a>
        }
      </div>
    </div>
  `,
})
export class ReadingListComponent implements OnInit {
  private api = inject(ApiService);
  levels = LEVELS;
  level = signal('');
  items = signal<PassageListItem[]>([]);
  ngOnInit() { this.load(); }
  setLevel(level: string) { this.level.set(level); this.load(); }
  private load() { this.api.reading(this.level()).subscribe((items) => this.items.set(items)); }
}
