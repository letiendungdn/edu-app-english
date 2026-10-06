import { HttpErrorResponse, HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { catchError, throwError } from 'rxjs';
import { AuthService } from './auth.service';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const auth = inject(AuthService);
  const token = localStorage.getItem('english_token');
  const request = token ? req.clone({ setHeaders: { Authorization: `Bearer ${token}` } }) : req;
  return next(request).pipe(
    catchError((error: HttpErrorResponse) => {
      // Token hết hạn hoặc secret đổi: xoá phiên cũ thay vì để giao diện vẫn hiện "đã đăng nhập".
      if (error.status === 401 && token && !req.url.includes('/auth/')) auth.logout();
      return throwError(() => error);
    }),
  );
};
