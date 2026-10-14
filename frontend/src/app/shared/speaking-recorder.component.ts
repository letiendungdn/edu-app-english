import { Component, computed, inject, input, OnDestroy, output, signal } from '@angular/core';
import { ApiService } from '../core/api.service';
import { SpeakingPromptView, SpeakingSubmissionView } from '../core/ielts.models';
import { FeedbackComponent } from './feedback.component';

/** Thời gian nói tối đa theo Part (giây). Part 2 có thêm 60 giây chuẩn bị. */
const MAX_SECONDS: Record<number, number> = { 1: 45, 2: 120, 3: 90 };
const PREP_SECONDS = 60;

type Stage = 'idle' | 'prep' | 'recording' | 'review' | 'submitted';

/**
 * Ghi âm một câu Speaking: chuẩn bị (Part 2), ghi âm kèm nhận dạng giọng nói trên trình duyệt, sửa văn bản, nộp.
 * Có attemptId thì bài nói thuộc bài thi thử: chỉ lưu, không hiện điểm ngay.
 */
@Component({
  selector: 'app-speaking-recorder',
  imports: [FeedbackComponent],
  template: `
    @switch (stage()) {
      @case ('idle') {
        @if (!recognitionSupported) {
          <div class="card warn" style="margin-top: 1rem;">
            Trình duyệt này không tự chuyển giọng nói thành chữ. Dùng Chrome hoặc Edge để được chấm tự động, hoặc gõ lại câu trả lời sau khi ghi âm.
          </div>
        }
        <div class="row" style="margin-top: 1rem;">
          @if (prompt().part === 2) {
            <button class="btn btn-primary" (click)="startPrep()">Bắt đầu 1 phút chuẩn bị</button>
          }
          <button class="btn" [class.btn-primary]="prompt().part !== 2" (click)="startRecording()">🎙 Nói ngay (tối đa {{ maxSeconds() }} giây)</button>
        </div>
        @if (error()) { <p class="error" style="margin-top: 0.5rem;">{{ error() }}</p> }
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
            <button class="btn btn-primary" (click)="submit()" [disabled]="busy()">{{ attemptId() == null ? 'Nộp để chấm' : 'Lưu câu trả lời' }}</button>
            <button class="btn" (click)="reset()">Nói lại</button>
          </div>
        </div>
      }
      @case ('submitted') {
        @if (submission(); as s) {
          <div style="margin-top: 1rem;">
            @if (attemptId() != null) {
              <div class="card" style="background: var(--success-soft); border-color: transparent;">
                <strong>Đã lưu câu trả lời.</strong> Điểm Speaking hiện ở trang kết quả sau khi nộp bài thi.
              </div>
              <button class="btn" style="margin-top: 0.75rem;" (click)="reset()">Nói lại câu này</button>
            } @else {
              @switch (s.status) {
                @case ('PENDING') { <div class="card warn">AI đang chấm, trang tự cập nhật.</div> }
                @case ('FAILED') { <div class="card warn">{{ s.error }}</div> }
                @case ('GRADED') { <app-feedback [band]="s.band" [criteria]="s.criteria" [feedback]="s.feedback" /> }
              }
              <p class="muted" style="font-size: 0.8rem; margin-top: 0.5rem;">
                Phát âm (Pronunciation) chưa chấm được từ văn bản nên band tính trên 3 tiêu chí còn lại.
              </p>
              <button class="btn" style="margin-top: 0.75rem;" (click)="reset()">Luyện lại câu này</button>
            }
          </div>
        }
      }
    }
  `,
})
export class SpeakingRecorderComponent implements OnDestroy {
  private api = inject(ApiService);
  prompt = input.required<SpeakingPromptView>();
  attemptId = input<number | null>(null);
  submitted = output<SpeakingSubmissionView>();

  readonly recognitionSupported = !!((window as any).SpeechRecognition || (window as any).webkitSpeechRecognition);

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

  maxSeconds = computed(() => MAX_SECONDS[this.prompt().part] ?? 60);
  countdown = computed(() => {
    const s = Math.max(0, this.remaining());
    return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`;
  });

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
    this.busy.set(true);
    this.api.submitSpeaking(p.id, this.transcript(), this.duration(), this.audio, this.attemptId()).subscribe({
      next: (s) => {
        this.busy.set(false);
        this.submission.set(s);
        this.stage.set('submitted');
        this.submitted.emit(s);
        // Trong bài thi chỉ lưu, kết quả xem ở trang kết quả sau khi nộp.
        if (this.attemptId() == null) this.watch(s);
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
