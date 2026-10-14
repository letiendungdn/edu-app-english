import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { catchError, map, of } from 'rxjs';
import { ApiService } from './api.service';
import { AuthService } from './auth.service';

/** Trang cần đăng nhập. */
export const loginGuard: CanActivateFn = (_route, state) => {
  const auth = inject(AuthService);
  const router = inject(Router);
  return auth.loggedIn() ? true : router.createUrlTree(['/login'], { queryParams: { next: state.url } });
};

/** Trang IELTS cần hồ sơ: chưa onboarding thì chuyển về /onboarding. */
export const profileGuard: CanActivateFn = (_route, state) => {
  const auth = inject(AuthService);
  const router = inject(Router);
  const api = inject(ApiService);
  if (!auth.loggedIn()) return router.createUrlTree(['/login'], { queryParams: { next: state.url } });
  return api.profile().pipe(
    map(() => true),
    catchError((error) => of(error?.status === 404 ? router.createUrlTree(['/onboarding']) : true)),
  );
};

/** Trang đăng nhập: đã đăng nhập thì về trang định tới, hoặc trang chủ. */
export const guestGuard: CanActivateFn = (route) => {
  const auth = inject(AuthService);
  const router = inject(Router);
  const next = route.queryParamMap.get('next');
  return auth.loggedIn() ? router.parseUrl(next && next.startsWith('/') ? next : '/') : true;
};
