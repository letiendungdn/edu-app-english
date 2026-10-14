import { Component, inject, OnInit, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { ApiService } from '../core/api.service';
import { SpeakingPromptView } from '../core/ielts.models';
import { SpeakingRecorderComponent } from '../shared/speaking-recorder.component';
import { AiBannerComponent } from './writing.component';

@Component({
  selector: 'app-speaking',
  imports: [RouterLink, AiBannerComponent],
  template: `
    <div class="container page" style="max-width: 900px;">
      <div class="row" style="justify-content: space-between;">
        <h1>Speaking</h1>
        <a class="btn" routerLink="/history">Bài đã nộp</a>
      </div>
      <app-ai-banner />
      @for (part of [1, 2, 3]; track part) {
        <h2 class="section-title">Part {{ part }} · {{ partDesc[part] }}</h2>
        <div class="grid">
          @for (p of byPart(part); track p.id) {
            <a class="card" [routerLink]="['/speaking', p.id]" style="text-decoration: none;">
              <span class="badge badge-B1">{{ p.topic }}</span>
              @if (p.attempted) { <span class="badge badge-A2">Đã nói</span> }
              <p style="margin-top: 0.4rem;">{{ p.question }}</p>
            </a>
          }
        </div>
      }
    </div>
  `,
})
export class SpeakingComponent implements OnInit {
  private api = inject(ApiService);
  prompts = signal<SpeakingPromptView[]>([]);
  partDesc: Record<number, string> = { 1: 'Hỏi đáp ngắn', 2: 'Nói 1–2 phút theo thẻ', 3: 'Thảo luận' };
  ngOnInit() {
    this.api.speakingPrompts().subscribe((p) => this.prompts.set(p));
  }
  byPart(part: number) {
    return this.prompts().filter((p) => p.part === part);
  }
}

@Component({
  selector: 'app-speaking-practice',
  imports: [RouterLink, AiBannerComponent, SpeakingRecorderComponent],
  template: `
    <div class="container page" style="max-width: 820px;">
      <a routerLink="/speaking" class="muted">← Speaking</a>
      @if (prompt(); as p) {
        <div style="margin: 0.75rem 0;"><span class="badge badge-C1">Part {{ p.part }}</span> <span class="badge badge-B1">{{ p.topic }}</span></div>
        <div class="card cue-card">
          <h2>{{ p.question }}</h2>
          @if (p.cueCardPoints.length) {
            <p class="muted" style="margin-top: 0.5rem;">You should say:</p>
            <ul>@for (point of p.cueCardPoints; track $index) { <li>{{ point }}</li> }</ul>
          }
        </div>
        @if (p.sampleAnswer) {
          <details class="card" style="margin-top: 1rem;">
            <summary><strong>Bài nói mẫu</strong></summary>
            <p class="passage" style="margin-top: 0.75rem; white-space: pre-wrap;">{{ p.sampleAnswer }}</p>
          </details>
        }
        <app-ai-banner />
        <app-speaking-recorder [prompt]="p" />
      }
    </div>
  `,
})
export class SpeakingPracticeComponent implements OnInit {
  private api = inject(ApiService);
  private route = inject(ActivatedRoute);
  prompt = signal<SpeakingPromptView | null>(null);

  ngOnInit() {
    this.api.speakingPrompt(Number(this.route.snapshot.paramMap.get('id'))).subscribe((p) => this.prompt.set(p));
  }
}
