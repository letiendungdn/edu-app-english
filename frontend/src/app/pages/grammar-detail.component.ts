import { Component, inject, OnInit, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { ApiService } from '../core/api.service';
import { GrammarDetail } from '../core/models';

@Component({
  selector: 'app-grammar-detail',
  imports: [RouterLink],
  template: `
    <div class="container page" style="max-width: 800px;">
      <a routerLink="/grammar" class="muted">← Ngữ pháp</a>
      @if (topic(); as topic) {
        <div style="margin: 1rem 0;">
          <span class="badge" [class]="'badge badge-' + topic.level">{{ topic.level }}</span>
          <h1 style="display: inline; margin-left: 0.5rem;">{{ topic.title }}</h1>
        </div>
        @if (topic.lessons.length > 1) {
          <div class="row" style="margin-bottom: 1rem;">
            @for (lesson of topic.lessons; track lesson.id; let i = $index) {
              <button class="btn" [class.btn-primary]="active() === i" (click)="active.set(i); answers.set({}); checked.set({})">{{ i + 1 }}. {{ lesson.title }}</button>
            }
          </div>
        }
        @if (lesson(); as lesson) {
          <div class="card" style="margin-bottom: 1.25rem; white-space: pre-wrap;">
            <h2>{{ lesson.title }}</h2>
            <p>{{ lesson.explanation }}</p>
            @if (lesson.examples.length) {
              <div style="margin-top: 1rem; border-left: 3px solid var(--accent); padding-left: 1rem;">
                <strong class="muted">Ví dụ</strong>
                @for (example of lesson.examples; track example) {
                  <p style="font-style: italic;">{{ example }}</p>
                }
              </div>
            }
          </div>
          <h2 style="margin-bottom: 0.75rem;">Bài tập ({{ lesson.exercises.length }})</h2>
          @for (ex of lesson.exercises; track ex.id; let i = $index) {
            <div class="card" style="margin-bottom: 0.75rem;" [style.border-left]="border(ex.id, ex.answer)">
              <p style="font-weight: 600;">{{ i + 1 }}. {{ ex.question }}</p>
              @for (opt of ex.options; track opt) {
                <label class="option" [class.selected]="answers()[ex.id] === opt && !checked()[ex.id]" [class.correct]="checked()[ex.id] && opt === ex.answer" [class.wrong]="checked()[ex.id] && answers()[ex.id] === opt && opt !== ex.answer">
                  <input type="radio" [name]="'ex-' + ex.id" [disabled]="checked()[ex.id]" [checked]="answers()[ex.id] === opt" (change)="choose(ex.id, opt)" />
                  {{ opt }}
                </label>
              }
              @if (!checked()[ex.id]) {
                <button class="btn btn-primary" style="margin-top: 0.5rem;" [disabled]="!answers()[ex.id]" (click)="mark(ex.id)">Kiểm tra</button>
              } @else {
                <p [style.color]="answers()[ex.id] === ex.answer ? 'var(--success)' : 'var(--danger)'">
                  {{ answers()[ex.id] === ex.answer ? 'Chính xác' : 'Đáp án đúng: ' + ex.answer }}
                </p>
              }
            </div>
          }
        }
      }
    </div>
  `,
})
export class GrammarDetailComponent implements OnInit {
  private api = inject(ApiService);
  private route = inject(ActivatedRoute);
  topic = signal<GrammarDetail | null>(null);
  active = signal(0);
  answers = signal<Record<number, string>>({});
  checked = signal<Record<number, boolean>>({});

  ngOnInit() {
    const id = Number(this.route.snapshot.paramMap.get('id'));
    this.api.grammarTopic(id).subscribe((topic) => this.topic.set(topic));
  }

  lesson() { return this.topic()?.lessons[this.active()]; }

  choose(id: number, value: string) {
    this.answers.update((current) => ({ ...current, [id]: value }));
  }

  mark(id: number) {
    this.checked.update((current) => ({ ...current, [id]: true }));
  }

  border(id: number, answer: string) {
    if (!this.checked()[id]) return '4px solid transparent';
    return this.answers()[id] === answer ? '4px solid var(--success)' : '4px solid var(--danger)';
  }
}
