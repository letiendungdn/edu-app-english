import { Component, input, output } from '@angular/core';
import { VocabWord } from '../core/models';
import { RespellPipe } from './respell';

/** Đọc một đoạn tiếng Anh bằng giọng của trình duyệt. */
export function speakEnglish(text: string | null | undefined) {
  if (!text || !('speechSynthesis' in window)) return;
  const utter = new SpeechSynthesisUtterance(text);
  utter.lang = 'en-US';
  utter.rate = 0.95;
  speechSynthesis.cancel();
  speechSynthesis.speak(utter);
}

const POS_LABELS: Record<string, string> = {
  noun: 'danh từ',
  verb: 'động từ',
  adjective: 'tính từ',
  adverb: 'trạng từ',
  preposition: 'giới từ',
  conjunction: 'liên từ',
  pronoun: 'đại từ',
  interjection: 'thán từ',
  phrase: 'cụm từ',
  phrasal_verb: 'cụm động từ',
};

/** Thẻ từ vựng hai mặt, lật 3D. Mặt trước: từ, phiên âm. Mặt sau: nghĩa, ví dụ, hình. */
@Component({
  selector: 'app-flip-card',
  imports: [RespellPipe],
  template: `
    <div class="flip" [class.flipped]="flipped()" role="button" tabindex="0"
         [attr.aria-label]="flipped() ? 'Mặt sau: ' + word().meaningVi : 'Mặt trước: ' + word().word + '. Nhấn để lật'"
         (click)="flip.emit()" (keydown.enter)="flip.emit()">
      <div class="flip-inner">
        <section class="flip-face flip-front">
          <div class="flip-meta">
            <span [class]="'badge badge-' + word().level">{{ word().level }}</span>
            @if (word().partOfSpeech) { <span class="badge">{{ pos(word().partOfSpeech) }}</span> }
            @if (word().topic?.name) { <span class="flip-topic">{{ word().topic!.name }}</span> }
          </div>
          <div class="flip-center">
            <div class="flip-word">{{ word().word }}</div>
            @if (word().phonetic) {
              <div class="flip-phonetic">{{ word().phonetic }}</div>
              <div class="flip-respell" title="Cách đọc gần đúng bằng chữ Việt, âm tiết viết hoa là âm nhấn">Đọc: {{ word().phonetic | respell }}</div>
            }
            <button class="speak-btn" type="button" (click)="say($event, word().word)" aria-label="Nghe phát âm">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M11 5 6 9H2v6h4l5 4z"/><path d="M15.5 8.5a5 5 0 0 1 0 7"/><path d="M19 5a10 10 0 0 1 0 14"/></svg>
            </button>
          </div>
          <div class="flip-hint">Nhấn thẻ hoặc phím Space để xem nghĩa</div>
        </section>

        <section class="flip-face flip-back">
          <div class="flip-meta">
            <span class="flip-small-word">{{ word().word }}</span>
            @if (word().phonetic) { <span class="muted small">{{ word().phonetic }} · {{ word().phonetic | respell }}</span> }
          </div>
          <div class="flip-back-body">
            @if (word().imageUrl) { <img class="flip-img" [src]="word().imageUrl" alt="" /> }
            <div style="min-width: 0;">
              <div class="flip-meaning">{{ word().meaningVi }}</div>
              @if (word().meaningEn) { <div class="flip-meaning-en">{{ word().meaningEn }}</div> }
            </div>
          </div>
          @if (word().family) {
            <div class="flip-family"><span class="muted small">Họ từ</span> {{ word().family }}</div>
          }
          @if (word().exampleEn) {
            <div class="flip-example">
              <button class="speak-btn sm" type="button" (click)="say($event, word().exampleEn)" aria-label="Nghe câu ví dụ">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M11 5 6 9H2v6h4l5 4z"/><path d="M15.5 8.5a5 5 0 0 1 0 7"/></svg>
              </button>
              <div>
                <div class="flip-example-en">{{ word().exampleEn }}</div>
                @if (word().exampleVi) { <div class="muted small">{{ word().exampleVi }}</div> }
              </div>
            </div>
          }
        </section>
      </div>
    </div>
  `,
})
export class FlipCardComponent {
  word = input.required<VocabWord>();
  flipped = input(false);
  flip = output<void>();

  pos(value: string | null | undefined) {
    return value ? (POS_LABELS[value] ?? value.replace('_', ' ')) : '';
  }

  say(event: Event, text: string | null | undefined) {
    // Không lật thẻ khi bấm loa.
    event.stopPropagation();
    speakEnglish(text);
  }
}
