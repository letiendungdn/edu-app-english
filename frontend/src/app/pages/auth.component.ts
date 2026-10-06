import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { AuthService } from '../core/auth.service';

@Component({
  selector: 'app-auth',
  imports: [FormsModule],
  template: `
    <div class="container page" style="max-width: 420px;">
      <h1>{{ mode() === 'login' ? 'Đăng nhập' : 'Đăng ký' }}</h1>
      <p class="muted" style="margin: 0.4rem 0 1rem;">Tài khoản mẫu: demo&#64;edu.app / demo123</p>
      <form class="card" style="display: grid; gap: 0.75rem;" (ngSubmit)="submit()">
        @if (mode() === 'register') {
          <input name="name" placeholder="Tên" [(ngModel)]="name" />
        }
        <input name="email" type="email" placeholder="Email" [(ngModel)]="email" required />
        <input name="password" type="password" placeholder="Mật khẩu" [(ngModel)]="password" required />
        @if (error()) { <div class="error">{{ error() }}</div> }
        <button class="btn btn-primary" type="submit" [disabled]="busy()">{{ busy() ? 'Đang xử lý...' : 'Tiếp tục' }}</button>
        <button class="btn" type="button" (click)="toggle()">
          {{ mode() === 'login' ? 'Chưa có tài khoản? Đăng ký' : 'Đã có tài khoản? Đăng nhập' }}
        </button>
      </form>
    </div>
  `,
})
export class AuthComponent {
  private auth = inject(AuthService);
  private router = inject(Router);
  private route = inject(ActivatedRoute);
  mode = signal<'login' | 'register'>('login');
  email = 'demo@edu.app';
  password = 'demo123';
  name = '';
  error = signal('');
  busy = signal(false);

  toggle() {
    this.mode.set(this.mode() === 'login' ? 'register' : 'login');
    this.error.set('');
  }

  submit() {
    this.busy.set(true);
    this.error.set('');
    const req = this.mode() === 'login'
      ? this.auth.login(this.email, this.password)
      : this.auth.register(this.email, this.password, this.name);
    req.subscribe({
      next: () => void this.router.navigateByUrl(this.route.snapshot.queryParamMap.get('next') || '/'),
      error: (err) => {
        this.error.set(err?.error?.error ?? 'Không thể đăng nhập');
        this.busy.set(false);
      },
    });
  }
}
