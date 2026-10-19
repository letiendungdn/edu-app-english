import { Component, computed, input } from '@angular/core';
import { RouterLink } from '@angular/router';
import { phonicsHints } from './phonics';

/** Gợi ý đọc theo mặt chữ: từ này theo quy tắc phonics nào, hay là ngoại lệ cần nhớ. */
@Component({
  selector: 'app-phonics-hints',
  imports: [RouterLink],
  template: `
    @if (hints().length) {
      <div class="ph-hints" (click)="$event.stopPropagation()">
        @for (h of hints(); track $index) {
          <a class="ph-hint" [class.ph-exc]="!h.follows" routerLink="/phonics" [fragment]="h.rule?.id ?? 'irregular'"
             [title]="h.rule?.explain ?? 'Xem danh sách từ đọc bất quy tắc'">
            <span class="ph-mark" aria-hidden="true">{{ h.follows ? '✓' : '!' }}</span>
            @if (h.focus) {
              <span class="ph-word">{{ word().slice(0, h.focus[0]) }}<b>{{ word().slice(h.focus[0], h.focus[1]) }}</b>{{ word().slice(h.focus[1]) }}</span>
            }
            <span>{{ h.note }}</span>
          </a>
        }
      </div>
    }
  `,
})
export class PhonicsHintsComponent {
  word = input.required<string>();
  phonetic = input<string | null | undefined>();
  pos = input<string | null | undefined>();
  hints = computed(() => phonicsHints(this.word(), this.phonetic(), this.pos()));
}
