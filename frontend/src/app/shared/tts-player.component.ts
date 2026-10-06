import { Component, input, OnDestroy, signal } from '@angular/core';

/**
 * Đọc lời thoại bằng giọng máy của trình duyệt khi bài nghe chưa có file audio. Mỗi dòng "Tên: lời" được đọc riêng,
 * người nói khác nhau dùng giọng khác nhau nếu trình duyệt có nhiều giọng tiếng Anh.
 */
@Component({
  selector: 'app-tts-player',
  template: `
    <div class="card tts">
      @if (audioUrl()) {
        <audio [src]="audioUrl()" controls style="width: 100%;"></audio>
      } @else {
        <div class="row">
          @if (!playing()) {
            <button class="btn btn-primary" type="button" (click)="play()" [disabled]="!supported">▶ Nghe</button>
          } @else {
            <button class="btn" type="button" (click)="stop()">■ Dừng</button>
          }
          <label class="row muted" style="gap: 0.3rem;">
            Tốc độ
            <select style="width: auto;" (change)="rate.set(+$any($event.target).value)">
              <option value="0.85">Chậm</option>
              <option value="1" selected>Bình thường</option>
            </select>
          </label>
          @if (playing()) { <span class="muted">Đang đọc câu {{ line() + 1 }}/{{ total() }}</span> }
        </div>
        @if (!supported) { <p class="error">Trình duyệt này không hỗ trợ đọc giọng máy. Hãy dùng Chrome hoặc Edge.</p> }
        <p class="muted" style="font-size: 0.8rem; margin-top: 0.5rem;">Bài nghe chưa có file audio, đang dùng giọng đọc máy của trình duyệt.</p>
      }
    </div>
  `,
})
export class TtsPlayerComponent implements OnDestroy {
  readonly script = input<string | null | undefined>(null);
  readonly audioUrl = input<string | null | undefined>(null);
  readonly supported = typeof window !== 'undefined' && 'speechSynthesis' in window;
  readonly playing = signal(false);
  readonly line = signal(0);
  readonly total = signal(0);
  readonly rate = signal(1);

  play() {
    const text = this.script();
    if (!text || !this.supported) return;
    speechSynthesis.cancel();
    const voices = speechSynthesis.getVoices().filter((v) => v.lang.startsWith('en'));
    const speakers = new Map<string, number>();
    const lines = text.split('\n').map((l) => l.trim()).filter(Boolean);
    this.total.set(lines.length);
    this.playing.set(true);
    lines.forEach((raw, index) => {
      const match = raw.match(/^([A-Z][\w ]{0,20}):\s*(.*)$/);
      const speaker = match ? match[1] : '';
      const words = match ? match[2] : raw;
      if (!speakers.has(speaker)) speakers.set(speaker, speakers.size);
      const utter = new SpeechSynthesisUtterance(words);
      utter.lang = 'en-GB';
      utter.rate = this.rate();
      if (voices.length) utter.voice = voices[speakers.get(speaker)! % voices.length];
      utter.onstart = () => this.line.set(index);
      if (index === lines.length - 1) utter.onend = () => this.playing.set(false);
      speechSynthesis.speak(utter);
    });
  }

  stop() {
    if (this.supported) speechSynthesis.cancel();
    this.playing.set(false);
  }

  ngOnDestroy() {
    this.stop();
  }
}
