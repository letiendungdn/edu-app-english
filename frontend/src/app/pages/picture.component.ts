import { Component, computed, inject, OnInit, signal } from '@angular/core';
import { ApiService } from '../core/api.service';
import { LEVELS, VocabWord } from '../core/models';

@Component({
  selector: 'app-picture',
  template: `
    <div class="container page">
      <h1>Từ điển tranh</h1>
      <div class="row" style="margin: 1rem 0;">
        <button class="btn" [class.btn-primary]="level() === ''" (click)="setLevel('')">Tất cả</button>
        @for (item of levels; track item) {
          <button class="btn" [class.btn-primary]="level() === item" (click)="setLevel(item)">{{ item }}</button>
        }
      </div>
      @for (group of groups(); track group.name) {
        <h2 style="margin: 1rem 0 0.6rem;">{{ group.icon }} {{ group.name }}</h2>
        <div class="picture-grid">
          @for (word of group.words; track word.id) {
            <button class="picture-card" (click)="selected.set(word)">
              <img [src]="word.imageUrl || ''" [alt]="word.word" />
              <div style="padding: 0.65rem 0.75rem;">
                <strong>{{ word.word }}</strong>
                <div class="muted">{{ word.meaningVi }}</div>
              </div>
            </button>
          }
        </div>
      }
      @if (selected(); as word) {
        <div style="position: fixed; inset: 0; background: rgba(0,0,0,.55); display: flex; align-items: center; justify-content: center; padding: 1rem;" (click)="selected.set(null)">
          <div class="card" style="max-width: 420px; width: 100%; text-align: center;" (click)="$event.stopPropagation()">
            <img [src]="word.imageUrl || ''" [alt]="word.word" style="max-height: 180px; width: 100%; object-fit: contain;" />
            <h2>{{ word.word }}</h2>
            <div class="muted">{{ word.phonetic }}</div>
            <div style="color: var(--accent); font-weight: 700; margin-top: 0.4rem;">{{ word.meaningVi }}</div>
            @if (word.exampleEn) { <p class="muted" style="font-style: italic; margin-top: 0.5rem;">"{{ word.exampleEn }}"</p> }
            <button class="btn" style="margin-top: 1rem;" (click)="selected.set(null)">Đóng</button>
          </div>
        </div>
      }
    </div>
  `,
})
export class PictureComponent implements OnInit {
  private api = inject(ApiService);
  levels = LEVELS;
  level = signal('');
  items = signal<VocabWord[]>([]);
  selected = signal<VocabWord | null>(null);
  groups = computed(() => {
    const map = new Map<string, { name: string; icon: string; words: VocabWord[] }>();
    for (const word of this.items()) {
      const name = word.topic?.name ?? 'Khác';
      const icon = word.topic?.icon ?? '•';
      const group = map.get(name) ?? { name, icon, words: [] };
      group.words.push(word);
      map.set(name, group);
    }
    return [...map.values()];
  });

  ngOnInit() { this.load(); }

  setLevel(level: string) {
    this.level.set(level);
    this.load();
  }

  private load() {
    this.api.picture(this.level()).subscribe((page) => this.items.set(page.items));
  }
}
