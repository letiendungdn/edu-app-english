import { Component, inject, OnInit, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { ApiService } from '../core/api.service';
import { BANDS, ProfileRequest } from '../core/ielts.models';

/** Tạo hoặc sửa hồ sơ IELTS. Lưu xong, lộ trình được sinh lại từ hôm nay. */
@Component({
  selector: 'app-onboarding',
  imports: [FormsModule],
  template: `
    <div class="container page" style="max-width: 620px;">
      <h1>{{ editing() ? 'Sửa mục tiêu' : 'Bắt đầu lộ trình IELTS' }}</h1>
      <p class="muted" style="margin-bottom: 1.25rem;">
        App dùng các thông tin này để chia lộ trình theo tuần và gợi ý bài học mỗi ngày. Có thể sửa lại bất cứ lúc nào.
      </p>

      <form class="card stack" (ngSubmit)="save()">
        <fieldset>
          <legend>Bạn thi dạng nào?</legend>
          <div class="row">
            <label class="option" [class.selected]="form.module === 'ACADEMIC'">
              <input type="radio" name="module" value="ACADEMIC" [(ngModel)]="form.module" /> Academic (du học, đại học)
            </label>
            <label class="option" [class.selected]="form.module === 'GENERAL'">
              <input type="radio" name="module" value="GENERAL" [(ngModel)]="form.module" /> General Training (định cư, việc làm)
            </label>
          </div>
        </fieldset>

        <label>
          Band hiện tại
          <select name="current" [(ngModel)]="current">
            <option value="">Chưa biết, tôi sẽ làm bài kiểm tra đầu vào</option>
            @for (b of bands; track b) { <option [value]="b">{{ b.toFixed(1) }}</option> }
          </select>
        </label>

        <label>
          Band mục tiêu
          <select name="target" [(ngModel)]="form.targetBand" required>
            @for (b of targetBands; track b) { <option [ngValue]="b">{{ b.toFixed(1) }}</option> }
          </select>
        </label>

        <label>
          Ngày thi (để trống nếu chưa đăng ký)
          <input type="date" name="examDate" [(ngModel)]="examDate" [min]="tomorrow" />
        </label>

        <div class="grid" style="grid-template-columns: 1fr 1fr;">
          <label>
            Phút học mỗi ngày
            <select name="minutes" [(ngModel)]="form.dailyMinutes">
              @for (m of minuteOptions; track m) { <option [ngValue]="m">{{ m }} phút</option> }
            </select>
          </label>
          <label>
            Số ngày học mỗi tuần
            <select name="days" [(ngModel)]="form.studyDaysPerWeek">
              @for (d of [3, 4, 5, 6, 7]; track d) { <option [ngValue]="d">{{ d }} ngày</option> }
            </select>
          </label>
        </div>

        @if (error()) { <p class="error">{{ error() }}</p> }
        <div class="row">
          <button class="btn btn-primary" type="submit" [disabled]="busy()">{{ editing() ? 'Lưu và lập lại lộ trình' : 'Tạo lộ trình' }}</button>
          @if (!current && !editing()) {
            <span class="muted">Sau khi tạo, bạn sẽ làm bài kiểm tra đầu vào khoảng 60 phút.</span>
          }
        </div>
      </form>
    </div>
  `,
})
export class OnboardingComponent implements OnInit {
  private api = inject(ApiService);
  private router = inject(Router);
  bands = BANDS;
  targetBands = BANDS.filter((b) => b >= 4);
  minuteOptions = [30, 45, 60, 90, 120, 180];
  tomorrow = new Date(Date.now() + 86_400_000).toISOString().slice(0, 10);
  editing = signal(false);
  busy = signal(false);
  error = signal('');

  form: ProfileRequest = {
    module: 'ACADEMIC',
    currentBand: null,
    targetBand: 6.5,
    examDate: null,
    dailyMinutes: 60,
    studyDaysPerWeek: 6,
  };
  current = '';
  examDate = '';

  ngOnInit() {
    this.api.profile().subscribe({
      next: (p) => {
        this.editing.set(true);
        this.form = { ...this.form, module: p.module, targetBand: p.targetBand, dailyMinutes: p.dailyMinutes, studyDaysPerWeek: p.studyDaysPerWeek };
        this.current = p.currentBand == null ? '' : String(p.currentBand);
        this.examDate = p.examDate ?? '';
      },
      error: () => this.editing.set(false),
    });
  }

  save() {
    this.busy.set(true);
    this.error.set('');
    const body: ProfileRequest = {
      ...this.form,
      currentBand: this.current === '' ? null : Number(this.current),
      examDate: this.examDate || null,
    };
    this.api.saveProfile(body).subscribe({
      next: (profile) => {
        this.busy.set(false);
        if (!profile.placementDone && profile.currentBand == null) void this.router.navigateByUrl('/placement');
        else void this.router.navigateByUrl('/');
      },
      error: (err) => {
        this.busy.set(false);
        this.error.set(err?.error?.error ?? 'Không lưu được hồ sơ');
      },
    });
  }
}
