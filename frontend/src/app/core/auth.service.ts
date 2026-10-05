import { Injectable, computed, inject, signal } from '@angular/core';
import { Router } from '@angular/router';
import { tap } from 'rxjs';
import { ApiService } from './api.service';
import { AuthResponse, UserView } from './models';

const TOKEN_KEY = 'english_token';
const USER_KEY = 'english_user';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private api = inject(ApiService);
  private router = inject(Router);
  private userState = signal<UserView | null>(this.readUser());

  readonly user = this.userState.asReadonly();
  readonly loggedIn = computed(() => this.userState() !== null);

  token() {
    return localStorage.getItem(TOKEN_KEY);
  }

  login(email: string, password: string) {
    return this.api.login(email, password).pipe(tap((res) => this.persist(res)));
  }

  register(email: string, password: string, name: string) {
    return this.api.register(email, password, name).pipe(tap((res) => this.persist(res)));
  }

  logout() {
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(USER_KEY);
    this.userState.set(null);
    void this.router.navigateByUrl('/');
  }

  private persist(res: AuthResponse) {
    localStorage.setItem(TOKEN_KEY, res.token);
    localStorage.setItem(USER_KEY, JSON.stringify(res.user));
    this.userState.set(res.user);
  }

  private readUser(): UserView | null {
    const raw = localStorage.getItem(USER_KEY);
    if (!raw || !localStorage.getItem(TOKEN_KEY)) return null;
    try {
      return JSON.parse(raw) as UserView;
    } catch {
      return null;
    }
  }
}
