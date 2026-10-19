import { Component, computed, effect, inject, signal } from '@angular/core';
import { NavigationEnd, Router, RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { filter } from 'rxjs';
import { ApiService } from './core/api.service';
import { AuthService } from './core/auth.service';
import { ProfileView } from './core/ielts.models';
import { RealtimeService } from './core/realtime.service';
import { IconComponent } from './shared/icon.component';

const THEME_KEY = 'ielts_theme';

interface NavItem {
  href: string;
  label: string;
  icon: string;
  exact: boolean;
}

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, RouterLink, RouterLinkActive, IconComponent],
  templateUrl: './app.component.html',
})
export class AppComponent {
  auth = inject(AuthService);
  realtime = inject(RealtimeService);
  private api = inject(ApiService);
  private router = inject(Router);

  menuOpen = signal(false);
  dark = signal(this.initialDark());
  profile = signal<ProfileView | null>(null);
  mistakeCount = signal(0);

  examDays = computed(() => this.profile()?.daysToExam ?? null);
  targetBand = computed(() => this.profile()?.targetBand?.toFixed(1) ?? '');
  initial = computed(() => (this.auth.user()?.name || this.auth.user()?.email || '?').trim().charAt(0).toUpperCase());

  nav: { label: string; items: NavItem[] }[] = [
    {
      label: 'Học',
      items: [
        { href: '/', label: 'Hôm nay', exact: true, icon: 'home' },
        { href: '/roadmap', label: 'Lộ trình', exact: false, icon: 'route' },
        { href: '/vocab', label: 'Từ vựng', exact: false, icon: 'vocab' },
        { href: '/grammar', label: 'Ngữ pháp', exact: false, icon: 'grammar' },
        { href: '/phonics', label: 'Phát âm', exact: false, icon: 'phonics' },
      ],
    },
    {
      label: 'Luyện thi',
      items: [
        { href: '/listening', label: 'Listening', exact: false, icon: 'listening' },
        { href: '/reading', label: 'Reading', exact: false, icon: 'reading' },
        { href: '/writing', label: 'Writing', exact: false, icon: 'writing' },
        { href: '/speaking', label: 'Speaking', exact: false, icon: 'speaking' },
        { href: '/tests', label: 'Thi thử', exact: false, icon: 'exam' },
      ],
    },
    {
      label: 'Theo dõi',
      items: [
        { href: '/mistakes', label: 'Sổ lỗi sai', exact: false, icon: 'mistakes' },
        { href: '/analytics', label: 'Tiến độ & band', exact: false, icon: 'chart' },
        { href: '/history', label: 'Lịch sử bài làm', exact: false, icon: 'history' },
      ],
    },
  ];

  bottomNav: NavItem[] = [
    { href: '/', label: 'Hôm nay', exact: true, icon: 'home' },
    { href: '/roadmap', label: 'Lộ trình', exact: false, icon: 'route' },
    { href: '/tests', label: 'Thi thử', exact: false, icon: 'exam' },
    { href: '/mistakes', label: 'Lỗi sai', exact: false, icon: 'mistakes' },
    { href: '/analytics', label: 'Tiến độ', exact: false, icon: 'chart' },
  ];

  constructor() {
    effect(() => {
      this.realtime.connect(this.auth.loggedIn() ? this.auth.token() : null);
    });
    effect(() => {
      if (!this.auth.loggedIn()) {
        this.profile.set(null);
        this.mistakeCount.set(0);
        return;
      }
      this.refresh();
    });
    // Hồ sơ và số câu sai đổi sau khi làm bài, onboarding: tải lại khi chuyển trang.
    this.router.events.pipe(filter((e) => e instanceof NavigationEnd)).subscribe(() => {
      if (this.auth.loggedIn()) this.refresh();
    });
  }

  toggleTheme() {
    const next = !this.dark();
    this.dark.set(next);
    const theme = next ? 'dark' : 'light';
    document.documentElement.dataset['theme'] = theme;
    try {
      localStorage.setItem(THEME_KEY, theme);
    } catch {
      // Trình duyệt chặn lưu trữ: theme chỉ giữ trong phiên này.
    }
  }

  private refresh() {
    this.api.profile().subscribe({ next: (p) => this.profile.set(p), error: () => this.profile.set(null) });
    this.api.mistakeCount().subscribe({ next: (c) => this.mistakeCount.set(c.open), error: () => this.mistakeCount.set(0) });
  }

  private initialDark() {
    const set = document.documentElement.dataset['theme'];
    if (set) return set === 'dark';
    return window.matchMedia?.('(prefers-color-scheme: dark)').matches ?? false;
  }
}
