import { Component, effect, inject } from '@angular/core';
import { RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { AuthService } from './core/auth.service';
import { RealtimeService } from './core/realtime.service';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, RouterLink, RouterLinkActive],
  templateUrl: './app.component.html',
})
export class AppComponent {
  auth = inject(AuthService);
  realtime = inject(RealtimeService);
  year = new Date().getFullYear();
  nav = [
    { href: '/', label: 'Hôm nay', exact: true },
    { href: '/roadmap', label: 'Lộ trình', exact: false },
    { href: '/tests', label: 'Thi thử', exact: false },
    { href: '/listening', label: 'Listening', exact: false },
    { href: '/reading', label: 'Reading', exact: false },
    { href: '/writing', label: 'Writing', exact: false },
    { href: '/speaking', label: 'Speaking', exact: false },
    { href: '/vocab', label: 'Từ vựng', exact: false },
    { href: '/grammar', label: 'Ngữ pháp', exact: false },
    { href: '/analytics', label: 'Tiến độ', exact: false },
  ];

  constructor() {
    effect(() => {
      this.realtime.connect(this.auth.loggedIn() ? this.auth.token() : null);
    });
  }
}
