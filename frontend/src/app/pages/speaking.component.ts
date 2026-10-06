import { Component, computed, inject, OnDestroy, OnInit, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { ApiService } from '../core/api.service';
import { SpeakingPromptView, SpeakingSubmissionView } from '../core/ielts.models';
import { FeedbackComponent } from '../shared/feedback.component';
import { AiBannerComponent } from './writing.component';

/** Thời gian nói tối đa theo Part (giây). Part 2 có thêm 60 giây chuẩn bị. */
const MAX_SECONDS: Record<number, number> = { 1: 45, 2: 120, 3: 90 };
const PREP_SECONDS = 60;

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

type Stage = 'idle' | 'prep' | 'recording' | 'review' | 'submitted';

@Component({
  selector: 'app-speaking-practice',
  imports: [RouterLink, FeedbackComponent, AiBannerComponent],
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
        <app-ai-banner />

        @switch (stage()) {
          @case ('idle') {
            @if (!recognitionSupported) {
              <div class="card warn">
                Trình duyệt này không tự chuyển giọng nói thành chữ. Dùng Chrome hoặc Edge để được chấm tự động, hoặc gõ lại câu trả lời sau khi ghi âm.
              </div>
            }
            <div class="row" style="margin-top: 1rem;">
              @if (p.part === 2) {
                <button class="btn btn-primary" (click)="startPrep()">Bắt đầu 1 phút chuẩn bị</button>
              }
              <button class="btn" [class.btn-primary]="p.part !== 2" (click)="startRecording()">🎙 Nói ngay (tối đa {{ maxSeconds() }} giây)</button>
            </div>
          }
          @case ('prep') {
            <div class="card" style="margin-top: 1rem; text-align: center;">
              <div class="timer">{{ countdown() }}</div>
              <p class="muted">Ghi chú nhanh ý chính. Hết giờ sẽ tự bắt đầu ghi âm.</p>
              <textarea rows="4" placeholder="Ghi chú…" aria-label="Ghi chú chuẩn bị"></textarea>
              <button class="btn" style="margin-top: 0.5rem;" (click)="startRecording()">Nói luôn</button>
            </div>
          }
          @case ('recording') {
            <div class="card recording" style="margin-top: 1rem;">
              <div class="row" style="justify-content: space-between;">
                <strong>● Đang ghi âm</strong>
                <span class="timer">{{ countdown() }}</span>
              </div>
              <p class="muted transcript">{{ transcript() || '…' }}<span class="interim">{{ interim() }}</span></p>
              <button class="btn btn-primary" (click)="stopRecording()">Dừng</button>
            </div>
          }
          @case ('review') {
            <div class="card" style="margin-top: 1rem;">
              @if (audioUrl()) { <audio [src]="audioUrl()" controls style="width: 100%;"></audio> }
              <label style="display: block; margin-top: 0.75rem;">
                Văn bản nhận dạng được ({{ duration() }} giây). Sửa những chỗ máy nghe nhầm, đừng viết thêm ý mới.
                <textarea rows="6" [value]="transcript()" (input)="transcript.set($any($event.target).value)"></textarea>
              </label>
              @if (error()) { <p class="error">{{ error() }}</p> }
              <div class="row" style="margin-top: 0.75rem;">
                <button class="btn btn-primary" (click)="submit()" [disabled]="busy()">Nộp để chấm</button>
                <button class="btn" (click)="reset()">Nói lại</button>
              </div>
            </div>
          }
          @case ('submitted') {
            @if (submission(); as s) {
              <div style="margin-top: 1rem;">
                @switch (s.status) {
                  @case ('PENDING') { <div class="card warn">AI đang chấm, trang tự cập nhật.</div> }
                  @case ('FAILED') { <div class="card warn">{{ s.error }}</div> }
                  @case ('GRADED') { <app-feedback [band]="s.band" [criteria]="s.criteria" [feedback]="s.feedback" /> }
                }
                <p class="muted" style="font-size: 0.8rem; margin-top: 0.5rem;">
                  Phát âm (Pronunciation) chưa chấm được từ văn bản nên band tính trên 3 tiêu chí còn lại.
                </p>
                <button class="btn" style="margin-top: 0.75rem;" (click)="reset()">Luyện lại câu này</button>
              </div>
            }
          }
        }
      }
    </div>
  `,
})
export class SpeakingPracticeComponent implements OnInit, OnDestroy {
  private api = inject(ApiService);
  private route = inject(ActivatedRoute);
  readonly recognitionSupported = !!((window as any).SpeechRecognition || (window as any).webkitSpeechRecognition);

  prompt = signal<SpeakingPromptView | null>(null);
  stage = signal<Stage>('idle');
  remaining = signal(0);
  duration = signal(0);
  transcript = signal('');
  interim = signal('');
  audioUrl = signal<string | null>(null);
  submission = signal<SpeakingSubmissionView | null>(null);
  busy = signal(false);
  error = signal('');

  private recorder: MediaRecorder | null = null;
  private recognition: any = null;
  private stream: MediaStream | null = null;
  private chunks: Blob[] = [];
  private audio: Blob | null = null;
  private timer: number | null = null;
  private poll: number | null = null;
  private startedAt = 0;

  maxSeconds = computed(() => MAX_SECONDS[this.prompt()?.part ?? 1] ?? 60);
  countdown = computed(() => {
    const s = Math.max(0, this.remaining());
    return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`;
  });

  ngOnInit() {
    this.api.speakingPrompt(Number(this.route.snapshot.paramMap.get('id'))).subscribe((p) => this.prompt.set(p));
  }

  ngOnDestroy() {
    this.cleanup();
    if (this.poll != null) window.clearTimeout(this.poll);
  }

  startPrep() {
    this.stage.set('prep');
    this.countFrom(PREP_SECONDS, () => this.startRecording());
  }

  async startRecording() {
    this.clearTimer();
    this.error.set('');
    try {
      this.stream = await navigator.mediaDevices.getUserMedia({ audio: true });
    } catch {
      this.error.set('Không mở được micro. Hãy cho phép trình duyệt dùng micro.');
      this.stage.set('idle');
      alert(this.error());
      return;
    }
    this.chunks = [];
    this.recorder = new MediaRecorder(this.stream);
    this.recorder.ondataavailable = (e) => e.data.size && this.chunks.push(e.data);
    this.recorder.onstop = () => {
      this.audio = new Blob(this.chunks, { type: this.recorder?.mimeType || 'audio/webm' });
      this.audioUrl.set(URL.createObjectURL(this.audio));
    };
    this.recorder.start();
    this.startRecognition();
    this.startedAt = Date.now();
    this.stage.set('recording');
    this.countFrom(this.maxSeconds(), () => this.stopRecording());
  }

  stopRecording() {
    this.clearTimer();
    this.duration.set(Math.round((Date.now() - this.startedAt) / 1000));
    this.recognition?.stop();
    if (this.recorder?.state === 'recording') this.recorder.stop();
    this.stream?.getTracks().forEach((t) => t.stop());
    this.transcript.update((t) => (t + ' ' + this.interim()).trim());
    this.interim.set('');
    this.stage.set('review');
  }

  submit() {
    const p = this.prompt();
    if (!p) return;
    this.busy.set(true);
    this.api.submitSpeaking(p.id, this.transcript(), this.duration(), this.audio).subscribe({
      next: (s) => {
        this.busy.set(false);
        this.submission.set(s);
        this.stage.set('submitted');
        this.watch(s);
      },
      error: (err) => {
        this.busy.set(false);
        this.error.set(err?.error?.error ?? 'Không nộp được bài');
      },
    });
  }

  reset() {
    this.cleanup();
    this.transcript.set('');
    this.interim.set('');
    this.audioUrl.set(null);
    this.audio = null;
    this.submission.set(null);
    this.stage.set('idle');
  }

  private watch(s: SpeakingSubmissionView) {
    if (s.status !== 'PENDING') return;
    this.poll = window.setTimeout(
      () => this.api.speakingSubmission(s.id).subscribe((next) => {
        this.submission.set(next);
        this.watch(next);
      }),
      4000,
    );
  }

  private startRecognition() {
    const Recognition = (window as any).SpeechRecognition || (window as any).webkitSpeechRecognition;
    if (!Recognition) return;
    this.recognition = new Recognition();
    this.recognition.lang = 'en-US';
    this.recognition.continuous = true;
    this.recognition.interimResults = true;
    this.recognition.onresult = (event: any) => {
      let interim = '';
      for (let i = event.resultIndex; i < event.results.length; i++) {
        const text = event.results[i][0].transcript;
        if (event.results[i].isFinal) this.transcript.update((t) => (t + ' ' + text).trim());
        else interim += text;
      }
      this.interim.set(interim);
    };
    // Chrome tự dừng nhận dạng sau một quãng im lặng: khởi động lại nếu vẫn đang ghi âm.
    this.recognition.onend = () => {
      if (this.stage() === 'recording') {
        try {
          this.recognition.start();
        } catch {
          /* đã chạy */
        }
      }
    };
    this.recognition.start();
  }

  private countFrom(seconds: number, done: () => void) {
    this.clearTimer();
    this.remaining.set(seconds);
    this.timer = window.setInterval(() => {
      this.remaining.update((s) => s - 1);
      if (this.remaining() <= 0) done();
    }, 1000);
  }

  private clearTimer() {
    if (this.timer != null) window.clearInterval(this.timer);
    this.timer = null;
  }

  private cleanup() {
    this.clearTimer();
    try {
      this.recognition?.stop();
    } catch {
      /* chưa chạy */
    }
    if (this.recorder?.state === 'recording') this.recorder.stop();
    this.stream?.getTracks().forEach((t) => t.stop());
  }
}
