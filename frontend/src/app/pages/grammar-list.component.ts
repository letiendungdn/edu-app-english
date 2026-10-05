import { Component, inject, OnInit, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { ApiService } from '../core/api.service';
import { GrammarListItem, LEVELS } from '../core/models';

@Component({
  selector: 'app-grammar-list',
  imports: [RouterLink],
  template: `
    <div class="container page">
      <h1>Ngữ pháp</h1>
      <div class="row" style="margin: 1rem 0;">
        <button class="btn" [class.btn-primary]="level() === ''" (click)="setLevel('')">Tất cả</button>
        @for (item of levels; track item) {
          <button class="btn" [class.btn-primary]="level() === item" (click)="setLevel(item)">{{ item }}</button>
        }
      </div>
      <div class="grid">
        @for (topic of topics(); track topic.id) {
          <a class="card" [routerLink]="['/grammar', topic.id]" style="text-decoration: none;">
            <span class="badge" [class]="'badge badge-' + topic.level">{{ topic.level }}</span>
            <h2 style="margin-top: 0.4rem;">{{ topic.title }}</h2>
            <p class="muted">{{ topic.description }}</p>
            <p class="muted" style="margin-top: 0.4rem;">{{ topic.lessonCount }} bài học</p>
          </a>
        }
      </div>
    </div>
  `,
})
export class GrammarListComponent implements OnInit {
  private api = inject(ApiService);
  levels = LEVELS;
  level = signal('');
  topics = signal<GrammarListItem[]>([]);

  ngOnInit() { this.load(); }
  setLevel(level: string) { this.level.set(level); this.load(); }
  private load() { this.api.grammar(this.level()).subscribe((topics) => this.topics.set(topics)); }
}
