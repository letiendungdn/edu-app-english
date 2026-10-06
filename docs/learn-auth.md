# Học đăng nhập — JWT trên EDU APP English

App English đăng nhập bằng email và mật khẩu. Server trả JWT. Keycloak có trong Docker nhưng **chưa** là cửa đăng nhập của Angular. Xem [learn-keycloak-mail.md](./learn-keycloak-mail.md).

## 1. Luồng

`POST /api/auth/login` với `{ "email", "password" }`.

`AuthService.login`:

- tìm `users` theo email
- `BCrypt` so mật khẩu với `password_hash`
- `JwtService.sign` tạo chuỗi JWT, claim có `sub` (id), email, name, role, và `app=english`

Response: `{ user, token }`. Angular lưu token (`auth.service.ts`).

`GET /api/auth/me` đọc token. Không có token hợp lệ thì 401.

Đăng ký (`POST /api/auth/register`) tạo user role `USER`, mật khẩu tối thiểu 6 ký tự, rồi cấp token luôn.

## 2. Filter, không phải session

`JwtAuthFilter` chạy mỗi request. Có header `Authorization: Bearer ...` thì parse và gắn `AuthUser` vào `SecurityContext`. Token sai thì bỏ qua, không chặn tại filter.

`SecurityConfig` mới quyết định chặn:

| URL | Cần đăng nhập? |
|-----|----------------|
| `/api/auth/**`, `GET /api/**` | Không |
| `POST /api/reading/**`, `/api/listening/**`, `/api/dictation` | Không |
| `GET` và `POST /api/vocab/review` | Có |
| `GET /api/analytics` | Có |
| `/actuator/health/**`, `/actuator/prometheus`, `/ws/**` | Không |
| Còn lại | Có |

Vì vậy mở `/vocab` khi chưa đăng nhập vẫn thấy từ. Mở `/analytics` thì phải có token. WebSocket tự kiểm tra token trong query, không dựa vào rule "authenticated" của HTTP.

## 3. Secret

`application.yml` profile `dev` dùng biến `APP_JWT_SECRET`, không có thì dùng chuỗi dev ghi trong file.

Profile `platform` dùng `JWT_SECRET`. Đổi secret làm mọi token cũ hết hạn ngay, vì chữ ký không khớp.

`JwtService.parse` từ chối token không có `app=english`, để không nhận nhầm token của hệ thống khác.

## 4. Việc tự làm

```powershell
curl -s -X POST http://localhost:8080/api/auth/login -H "Content-Type: application/json" -d "{\"email\":\"demo@edu.app\",\"password\":\"demo123\"}"
```

Copy `token`. Gọi:

```powershell
curl -s http://localhost:8080/api/analytics -H "Authorization: Bearer TOKEN_Ở_ĐÂY"
```

Bỏ header thì nhận 401. Test tự động của luồng này: `backend/src/test/java/com/edu/english/web/AuthControllerTest.java`.

Tiếp: [learn-postgres.md](./learn-postgres.md).
