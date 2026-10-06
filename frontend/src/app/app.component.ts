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
    { href: '/', label: 'Home', exact: true },
    { href: '/vocab', label: 'Từ vựng', exact: true },
    { href: '/vocab/flashcard', label: 'Flashcard', exact: false },
    { href: '/vocab/picture', label: 'Từ điển tranh', exact: false },
    { href: '/vocab/review', label: 'SRS', exact: false },
    { href: '/grammar', label: 'Ngữ pháp', exact: false },
    { href: '/reading', label: 'Đọc hiểu', exact: false },
    { href: '/listening', label: 'Nghe', exact: false },
    { href: '/dictation', label: 'Nghe chép', exact: false },
    { href: '/analytics', label: 'Tiến độ', exact: false },
  ];

  constructor() {
    effect(() => {
      this.realtime.connect(this.auth.loggedIn() ? this.auth.token() : null);
    });
  }
}
