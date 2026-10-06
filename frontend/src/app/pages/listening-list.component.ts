import { Component, inject, OnInit, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { ApiService } from '../core/api.service';
import { LEVELS, TrackListItem } from '../core/models';

@Component({
  selector: 'app-listening-list',
  imports: [RouterLink],
  template: `
    <div class="container page">
      <h1>Nghe</h1>
      <div class="row" style="margin: 1rem 0;">
        <button class="btn" [class.btn-primary]="level() === ''" (click)="setLevel('')">Tất cả</button>
        @for (item of levels; track item) {
          <button class="btn" [class.btn-primary]="level() === item" (click)="setLevel(item)">{{ item }}</button>
        }
      </div>
      <div class="grid">
        @for (item of items(); track item.id) {
          <a class="card" [routerLink]="['/listening', item.id]" style="text-decoration: none;">
            @if (item.ieltsPart) { <span class="badge badge-C1">IELTS Part {{ item.ieltsPart }}</span> }
            <span class="badge" [class]="'badge badge-' + item.level">{{ item.level }}</span>
            <h2 style="margin-top: 0.4rem;">{{ item.title }}</h2>
            <p class="muted">{{ item.questionCount }} câu hỏi</p>
          </a>
        }
      </div>
    </div>
  `,
})
export class ListeningListComponent implements OnInit {
  private api = inject(ApiService);
  levels = LEVELS;
  level = signal('');
  items = signal<TrackListItem[]>([]);
  ngOnInit() { this.load(); }
  setLevel(level: string) { this.level.set(level); this.load(); }
  private load() { this.api.listening(this.level()).subscribe((items) => this.items.set(items)); }
}
