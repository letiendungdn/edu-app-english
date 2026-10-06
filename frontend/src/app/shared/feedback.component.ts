import { Component, input } from '@angular/core';
import { band, CriterionScore, Feedback } from '../core/ielts.models';

/** Kết quả chấm Writing/Speaking: band, điểm từng tiêu chí, nhận xét và các lỗi đã sửa. */
@Component({
  selector: 'app-feedback',
  template: `
    <div class="card">
      <div class="row" style="justify-content: space-between;">
        <div>
          <div class="muted" style="font-size: 0.8rem;">BAND ƯỚC LƯỢNG</div>
          <div class="band-big">{{ fmt(band()) }}</div>
        </div>
        <div class="criteria">
          @for (c of criteria(); track c.code) {
            <div class="criterion"><span class="muted">{{ c.name }}</span><strong>{{ c.score == null ? '–' : c.score }}</strong></div>
          }
        </div>
      </div>
      <p class="muted" style="font-size: 0.8rem; margin-top: 0.75rem;">
        Điểm do AI ước lượng theo band descriptors công khai, có thể lệch ±0.5–1.0 band so với giám khảo thật.
      </p>
    </div>
    @if (feedback(); as f) {
      <div class="card" style="margin-top: 0.75rem;">
        <p>{{ f.summary }}</p>
        <div class="grid" style="margin-top: 0.75rem; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));">
          <div>
            <h2 style="font-size: 0.95rem;">Điểm mạnh</h2>
            <ul>@for (s of f.strengths; track $index) { <li>{{ s }}</li> }</ul>
          </div>
          <div>
            <h2 style="font-size: 0.95rem;">Cần cải thiện</h2>
            <ul>@for (s of f.improvements; track $index) { <li>{{ s }}</li> }</ul>
          </div>
        </div>
      </div>
      @if (f.corrections.length) {
        <div class="card" style="margin-top: 0.75rem;">
          <h2 style="font-size: 0.95rem; margin-bottom: 0.5rem;">Sửa lỗi</h2>
          @for (c of f.corrections; track $index) {
            <div class="correction">
              <div><del>{{ c.original }}</del></div>
              <div class="fix">→ {{ c.suggestion }}</div>
              <div class="muted">{{ c.reason }}</div>
            </div>
          }
        </div>
      }
    }
  `,
})
export class FeedbackComponent {
  readonly band = input<number | null | undefined>(null);
  readonly criteria = input<CriterionScore[]>([]);
  readonly feedback = input<Feedback | null | undefined>(null);
  fmt = band;
}
