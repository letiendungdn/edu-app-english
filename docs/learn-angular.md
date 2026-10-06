# Học Angular — EDU APP English

Web nằm trong `frontend/`. Angular 19, standalone component, không có module `NgModule`.

## 1. App này vẽ gì

Route khai báo ở `frontend/src/app/app.routes.ts`.

| URL | Component | API |
|-----|-----------|-----|
| `/` | `pages/home.component.ts` | không |
| `/login` | `pages/auth.component.ts` | `POST /api/auth/login` hoặc `register` |
| `/vocab` | `pages/vocab.component.ts` | `GET /api/vocab` |
| `/vocab/review` | `pages/review.component.ts` | `GET/POST /api/vocab/review` |
| `/grammar`, `/grammar/:id` | list + detail | `GET /api/grammar` |
| `/reading/:id`, `/listening/:id` | làm bài rồi nộp | `POST .../submit` |
| `/dictation` | nghe chép | `GET/POST /api/dictation` |
| `/analytics` | tiến độ | `GET /api/analytics` |

Khung chung (menu, tên user, trạng thái WebSocket) là `app.component.ts` và `app.component.html`.

## 2. Mọi lời gọi API đi qua một chỗ

`frontend/src/app/core/api.service.ts` giữ base URL:

```ts
private base = 'http://localhost:8080/api';
```

`ng serve` dùng đúng dòng này, nên Angular ở cổng 4200 gọi Spring ở cổng 8080.

Image Docker đổi dòng đó lúc build. `frontend/Dockerfile` chạy:

```text
sed thay http://localhost:8080/api thành /api
```

Trình duyệt mở http://localhost:8088 thì gọi `/api/...` cùng host. Nginx chuyển tiếp sang Spring. Không hard-code cổng 8080 trong bản Docker.

## 3. Token đi kèm request

`core/auth.service.ts` lưu token vào `localStorage` khóa `english_token`.

`core/auth.interceptor.ts` gắn header `Authorization: Bearer ...` cho các lời gọi sau khi đăng nhập. Đọc interceptor đó trước khi sửa bất kỳ màn hình nào cần user.

`SecurityConfig` bên Java quyết định URL nào thực sự cần token. Angular gửi token không có nghĩa là server bắt buộc token. Xem [learn-auth.md](./learn-auth.md).

## 4. Trạng thái "trực tiếp"

`core/realtime.service.ts` mở WebSocket khi `auth.loggedIn()` đổi thành true. `app.component.ts` dùng `effect()` để gọi `connect` / ngắt khi đăng xuất.

Chi tiết socket: [learn-websocket.md](./learn-websocket.md).

## 5. Việc tự làm

1. `cd frontend` rồi `npm start`.
2. Mở http://localhost:4200/vocab. Trong DevTools → Network, thấy `GET http://localhost:8080/api/vocab`.
3. Sửa nhãn menu trong `app.component.ts` (mảng `nav`), lưu, trang tự tải lại.
4. Đổi lại nhãn cũ.

Backend phải đang chạy, nếu không danh sách từ lỗi mạng. Local: `cd backend` rồi `mvn spring-boot:run`.

Tiếp: [learn-spring.md](./learn-spring.md).
