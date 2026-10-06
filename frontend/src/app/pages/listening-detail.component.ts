import { Component, computed, inject, OnInit, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { ApiService } from '../core/api.service';
import { band } from '../core/ielts.models';
import { SubmitResult, TrackDetail } from '../core/models';
import { QuestionGroupComponent } from '../shared/question-group.component';
import { TtsPlayerComponent } from '../shared/tts-player.component';

@Component({
  selector: 'app-listening-detail',
  imports: [RouterLink, QuestionGroupComponent, TtsPlayerComponent],
  template: `
    <div class="container page" style="max-width: 820px;">
      <a routerLink="/listening" class="muted">← Nghe</a>
      @if (track(); as track) {
        <div style="margin: 0.75rem 0;">
          @if (track.ieltsPart) { <span class="badge badge-C1">Part {{ track.ieltsPart }}</span> }
          <span class="badge" [class]="'badge badge-' + track.level">{{ track.level }}</span>
        </div>
        <h1 style="margin-bottom: 1rem;">{{ track.title }}</h1>
        <app-tts-player [script]="track.transcript" [audioUrl]="track.audioUrl" />
        <p class="muted" style="margin: 0.75rem 0;">Đọc trước câu hỏi, sau đó bấm Nghe. Lời thoại chỉ hiện sau khi nộp bài.</p>

        @if (result(); as r) {
          <div class="card score-card">
            <div class="band-big">{{ r.correct }}/{{ r.total }}</div>
            @if (r.estimatedBand != null) {
              <div>Band Listening ước lượng: <strong>{{ fmt(r.estimatedBand) }}</strong></div>
            }
          </div>
        }
        @for (group of track.groups; track group.id) {
          <app-question-group [group]="group" [answers]="answers()" [results]="result()?.results ?? null" (answer)="setAnswer($event)" />
        }
        @if (!result()) {
          <div class="row">
            <button class="btn btn-primary" [disabled]="busy()" (click)="submit()">Nộp bài</button>
            <span class="muted">Đã làm {{ answered() }}/{{ questionCount() }}</span>
          </div>
        } @else {
          <details class="card" style="margin-bottom: 1rem;">
            <summary><strong>Lời thoại</strong></summary>
            <p class="passage" style="margin-top: 0.5rem;">{{ track.transcript }}</p>
          </details>
          <button class="btn" (click)="reset()">Làm lại</button>
        }
      }
    </div>
  `,
})
export class ListeningDetailComponent implements OnInit {
  private api = inject(ApiService);
  private route = inject(ActivatedRoute);
  track = signal<TrackDetail | null>(null);
  answers = signal<Record<string, string>>({});
  result = signal<SubmitResult | null>(null);
  busy = signal(false);
  fmt = band;

  questionCount = computed(() => (this.track()?.groups ?? []).reduce((n, g) => n + g.questions.length, 0));
  answered = computed(() => Object.values(this.answers()).filter((v) => v.trim()).length);

  ngOnInit() {
    this.api.listeningDetail(Number(this.route.snapshot.paramMap.get('id'))).subscribe((t) => this.track.set(t));
  }

  setAnswer(event: { questionId: number; value: string }) {
    this.answers.update((current) => ({ ...current, [event.questionId]: event.value }));
  }

  submit() {
    const track = this.track();
    if (!track) return;
    this.busy.set(true);
    this.api.submitListening(track.id, this.answers()).subscribe({
      next: (result) => {
        this.result.set(result);
        this.busy.set(false);
      },
      error: () => this.busy.set(false),
    });
  }

  reset() {
    this.answers.set({});
    this.result.set(null);
  }
}
