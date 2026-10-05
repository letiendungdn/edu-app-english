import { Component, inject, OnInit, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { ApiService } from '../core/api.service';
import { SubmitResult, TrackDetail } from '../core/models';

@Component({
  selector: 'app-listening-detail',
  imports: [RouterLink],
  template: `
    <div class="container page" style="max-width: 760px;">
      <a routerLink="/listening" class="muted">← Nghe</a>
      @if (track(); as track) {
        <h1 style="margin: 1rem 0;">{{ track.title }}</h1>
        <div class="card" style="margin-bottom: 1rem;">
          <p class="muted">{{ track.transcript }}</p>
          <button class="btn" style="margin-top: 0.75rem;" (click)="speak()">Nghe transcript</button>
        </div>
        @if (!result()) {
          @for (q of track.questions; track q.id; let i = $index) {
            <div class="card" style="margin-bottom: 0.75rem;">
              <p style="font-weight: 600;">{{ i + 1 }}. {{ q.question }}</p>
              @for (opt of q.options; track opt.id) {
                <label class="option" [class.selected]="answers()[q.id] === opt.text">
                  <input type="radio" [name]="'q-' + q.id" (change)="choose(q.id, opt.text)" />
                  {{ opt.text }}
                </label>
              }
            </div>
          }
          <button class="btn btn-primary" [disabled]="!complete() || busy()" (click)="submit()">Nộp bài</button>
        } @else {
          <div class="card" style="text-align: center;">
            <div style="font-size: 2.4rem; font-weight: 800;">{{ result()!.percent }}%</div>
            <div>{{ result()!.correct }}/{{ result()!.total }} câu đúng</div>
          </div>
          <button class="btn" style="margin-top: 1rem;" (click)="result.set(null); answers.set({})">Làm lại</button>
        }
      }
    </div>
  `,
})
export class ListeningDetailComponent implements OnInit {
  private api = inject(ApiService);
  private route = inject(ActivatedRoute);
  track = signal<TrackDetail | null>(null);
  answers = signal<Record<number, string>>({});
  result = signal<SubmitResult | null>(null);
  busy = signal(false);

  ngOnInit() {
    this.api.listeningDetail(Number(this.route.snapshot.paramMap.get('id'))).subscribe((track) => this.track.set(track));
  }

  speak() {
    const text = this.track()?.transcript;
    if (!text) return;
    const utter = new SpeechSynthesisUtterance(text);
    utter.lang = 'en-US';
    utter.rate = 0.9;
    speechSynthesis.cancel();
    speechSynthesis.speak(utter);
  }

  choose(id: number, text: string) {
    this.answers.update((current) => ({ ...current, [id]: text }));
  }

  complete() {
    const questions = this.track()?.questions ?? [];
    return questions.every((q) => this.answers()[q.id]);
  }

  submit() {
    const track = this.track();
    if (!track) return;
    const answers: Record<string, string> = {};
    for (const [key, value] of Object.entries(this.answers())) answers[String(key)] = value;
    this.busy.set(true);
    this.api.submitListening(track.id, answers).subscribe({
      next: (result) => { this.result.set(result); this.busy.set(false); },
      error: () => this.busy.set(false),
    });
  }
}
