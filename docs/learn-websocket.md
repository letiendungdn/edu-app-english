# Học WebSocket — EDU APP English

HTTP hỏi một lần, trả một lần. WebSocket giữ kết nối để trang đang mở gửi nhịp "tôi vẫn đang học".

App tiếng Nhật dùng Socket.io trên Nest. App English dùng WebSocket của Spring, đường dẫn `/ws/study`.

## 1. Phía Angular

`frontend/src/app/core/realtime.service.ts`

Khi đã đăng nhập, `app.component.ts` gọi `connect(token)`. URL lấy từ `ApiService.studySocketUrl`:

- `ng serve`: `ws://localhost:8080/ws/study?token=...`
- bản Docker (`base` là `/api`): `ws://localhost:8088/ws/study?token=...` nếu đang mở qua Nginx

Mỗi 15 giây gửi `{ "seconds": 15 }`. Header hiện chữ **trực tiếp**. Đăng xuất thì đóng socket, chữ thành **ngoại tuyến**.

## 2. Phía Spring

`StudySocketConfig` đăng ký `StudySocketHandler` tại `/ws/study`, cho mọi origin (Angular 4200 khác cổng với API 8080).

Handler:

1. Vừa nối thì gửi `{"event":"ready"}`.
2. Đọc query `token`, `JwtService.parse`. Sai thì đóng socket.
3. Message text: lấy `seconds` (1–120, mặc định 15), `VocabService.addStudy`, rồi Kafka `edu.session.completed`.

`addStudy` cộng vào `study_sessions` của ngày UTC hiện tại. Unique `(user_id, study_date)` nên trong một ngày chỉ một dòng, số giây tăng dần.

`/ws/**` trong `SecurityConfig` là `permitAll` vì trình duyệt không gắn header `Authorization` lúc mở WebSocket. Token nằm trên query. Đó là lý do phải parse trong handler, không dựa vào `JwtAuthFilter`.

## 3. Việc tự làm

Đăng nhập trên http://localhost:4200 hoặc http://localhost:8088. Header phải thành "trực tiếp".

DevTools → Network → WS → message gửi đi mỗi 15 giây.

Nếu cụm Docker và profile platform:

```powershell
docker exec -it en-postgres psql -U english -d english -c "select study_date, seconds from study_sessions order by study_date desc limit 5;"
```

Đợi hơn 15 giây, `seconds` của hôm nay tăng.

Local không Docker vẫn cộng giờ trên H2. Kafka thì không có message.

Tiếp: [learn-observability.md](./learn-observability.md).
