# Bài 12: WebSocket, kết nối hai chiều

**Mục tiêu:** hiểu WebSocket khác HTTP thế nào, cách xác thực một kết nối dài, và nguyên tắc quan trọng nhất của mọi hệ thống mạng: **không tin dữ liệu client gửi lên**.

**File:** `frontend/src/app/core/realtime.service.ts`, `backend/.../config/StudySocketConfig.java`, `config/StudySocketHandler.java`.

---

## 1. HTTP và WebSocket

**HTTP:** client hỏi, server trả lời, xong. Server **không thể tự gửi** gì cho client khi client chưa hỏi.

**WebSocket:** mở **một** kết nối và giữ nó. Cả hai bên gửi tin cho nhau bất cứ lúc nào.

```text
HTTP         client ──request──► server
             client ◄─response── server     (kết thúc)

WebSocket    client ──"Upgrade: websocket"──► server
             client ◄────────101──────────── server   (nâng cấp xong, kết nối mở)
             client ◄═══════ tin nhắn hai chiều ═══════► server
```

Dùng WebSocket khi cần **cập nhật tức thời**: chat, thông báo, giá chứng khoán, game nhiều người, cộng tác cùng chỉnh tài liệu.

Các lựa chọn khác:
- **Polling**: client hỏi lại sau mỗi N giây. Đơn giản, tốn tài nguyên hơn. Trang kết quả Writing dùng cách này: hỏi lại mỗi 4 giây tới khi chấm xong.
- **Server-Sent Events (SSE)**: server đẩy một chiều xuống client, qua HTTP thường. Hợp với thông báo.

**App dùng WebSocket để làm gì?** Đếm thời gian học: khi trang đang mở, cứ 15 giây trình duyệt báo "tôi vẫn đang học", server cộng giờ vào `study_sessions`. Thật ra việc này polling HTTP cũng làm được. WebSocket có ở đây chủ yếu để học, nên đây là chỗ tốt để luyện **tư duy bảo mật**.

---

## 2. Phía Angular

`core/realtime.service.ts`:

```ts
connect(token: string | null) {
  this.disconnect();
  if (!token) return;
  const origin = window.location.origin.replace(/^http/, 'ws');      // http→ws, https→wss
  const socket = new WebSocket(`${origin}/ws/study`);                 // CÙNG origin với trang
  socket.onopen = () => {
    socket.send(JSON.stringify({ type: 'auth', token }));             // tin đầu tiên: xác thực
  };
  socket.onmessage = (event) => {
    if (String(event.data).includes('authenticated')) {
      this.status.set('trực tiếp');
      this.timer = window.setInterval(() => {
        if (socket.readyState === WebSocket.OPEN && document.visibilityState === 'visible') {
          socket.send(JSON.stringify({ seconds: 15 }));               // nhịp học, chỉ khi tab đang hiển thị
        }
      }, 15000);
    }
  };
  ...
}
```

`app.component.ts` gọi `connect` qua `effect()`: mỗi khi trạng thái đăng nhập đổi (đăng nhập, đăng xuất), socket mở lại hoặc đóng.

---

## 3. Phía Spring

`StudySocketConfig`:

```java
registry.addHandler(handler, "/ws/study").setAllowedOrigins(allowedOrigins);   // từ app.ws-origins
```

`StudySocketHandler.handleTextMessage`:

```java
Long userId = (Long) session.getAttributes().get(USER_ID);
if (userId == null) {                    // chưa xác thực → tin này phải là auth
  authenticate(session, body);
  return;
}
Instant now = clock.instant();
Instant last = (Instant) session.getAttributes().get(LAST_BEAT);
session.getAttributes().put(LAST_BEAT, now);
long elapsed = Math.max(0, now.getEpochSecond() - last.getEpochSecond());
int claimed = Math.max(0, body.path("seconds").asInt(15));
int seconds = (int) Math.min(MAX_CREDIT_SECONDS, Math.min(claimed, elapsed));   // không tin số client gửi
if (seconds <= 0) return;
vocab.addStudy(userId, seconds, 0);
platform.publish(PlatformGateway.SESSION_RECORDED, Map.of("userId", userId, "seconds", seconds));
```

`session.getAttributes()` là "túi đồ" riêng của mỗi kết nối: lưu user id, thời điểm nhịp trước.

---

## 4. Ba lỗi bảo mật đã sửa

### Lỗi 1: token nằm trên URL

Bản trước: `new WebSocket('ws://.../ws/study?token=eyJ...')`.

URL bị ghi vào **access log của Nginx**, log của proxy công ty, lịch sử trình duyệt, công cụ giám sát. Ai đọc được log là có token, giả danh người học được 30 ngày.

Vì sao bản trước làm vậy? Trình duyệt **không cho** đặt header `Authorization` khi mở WebSocket. Có ba cách thay thế:
1. **Gửi token trong tin đầu tiên** (repo dùng). Đơn giản. Đổi lại server phải xử lý kết nối "chưa xác thực" trong chốc lát.
2. Cookie: trình duyệt tự gửi khi mở kết nối. Cần chống CSRF và kiểm tra origin.
3. Vé ngắn hạn: gọi API (có header) lấy một vé dùng một lần, sống 30 giây, rồi đặt vé đó lên URL. Vé có lọt vào log thì cũng đã hết hạn.

### Lỗi 2: tin con số của client

Bản trước: `seconds = min(120, max(1, body.seconds))`, rồi cộng thẳng vào giờ học.

Mở DevTools console và chạy:

```js
for (let i = 0; i < 1000; i++) socket.send('{"seconds":120}')
```

Một giây sau, người đó có thêm 33 giờ học. Streak, thống kê, mọi thứ dựa trên giờ học đều thành vô nghĩa.

Bản mới: server tự đo **thời gian thật trôi qua** từ nhịp trước, giới hạn 60 giây, và không vượt số client khai. Gửi 1000 tin trong một giây thì cộng được khoảng 1 giây.

**Quy tắc vàng: mọi thứ từ client đều có thể bị làm giả.** Body, header, query string, thời gian, giá tiền, điểm số. Server phải tự tính hoặc tự kiểm tra lại. Đây là lý do giờ thi cũng do server giữ (bài 6).

### Lỗi 3: cho mọi origin

Bản trước: `setAllowedOriginPatterns("*")`.

Trang `evil.com` có thể mở WebSocket tới server của bạn. Với cách xác thực bằng cookie, trình duyệt của nạn nhân sẽ tự gửi cookie, và đó là tấn công **Cross-Site WebSocket Hijacking**. Với token thì rủi ro thấp hơn, nhưng không có lý do gì để mở cửa cho mọi trang. Bản mới chỉ nhận origin trong `app.ws-origins`:

```yaml
ws-origins: ${app.cors-origins},http://localhost:8088,http://127.0.0.1:8088
```

Phải có cả `:8088` vì qua Nginx, header `Host` là `localhost` (không kèm cổng) mà `Origin` lại là `http://localhost:8088`. Spring không coi hai cái này là cùng origin (bài 8).

---

## 5. Múi giờ: một lỗi không phải bảo mật

`addStudy` cộng vào dòng `study_sessions` của **hôm nay**. Bản trước dùng `LocalDate.now()`, tức ngày theo **múi giờ máy chủ**. Container Docker chạy giờ UTC, Việt Nam là UTC+7:

```text
6:30 sáng thứ Ba ở Hà Nội = 23:30 tối thứ Hai UTC → giờ học ghi vào THỨ HAI
```

Học buổi sáng mỗi ngày mà streak bị đứt, biểu đồ lệch ngày. Bản mới dùng `LocalDate.now(clock)` với `Clock` theo `app.timezone` (mặc định `Asia/Ho_Chi_Minh`).

App phục vụ nhiều nước thì múi giờ phải là **thuộc tính của từng người dùng**, không phải cấu hình chung. Đó là bài tập Senior bên dưới.

---

## 6. Thử trên máy

1. Đăng nhập, header hiện "trực tiếp".
2. DevTools → Network → lọc **WS** → bấm vào `study` → tab **Messages**. Thấy tin `auth` đi lên, `ready` và `authenticated` đi xuống, rồi mỗi 15 giây một tin `{"seconds":15}`.
3. Chuyển sang tab trình duyệt khác 1 phút rồi quay lại: không có tin nào trong lúc tab bị ẩn.
4. Thử gian lận trong console (giờ chỉ cộng khoảng 1 giây):

```sql
-- H2 console hoặc psql, trước và sau khi thử
SELECT study_date, seconds FROM study_sessions ORDER BY study_date DESC;
```

---

## 7. Việc tự làm

**Junior**
1. Làm theo mục 6, chụp lại các tin nhắn trong tab Messages.
2. Đổi nhịp từ 15 giây thành 30 giây ở cả frontend. Server có cần sửa gì không? Vì sao?

**Mid**
3. Server chưa có timeout xác thực: một client mở socket rồi không gửi `auth` thì kết nối treo mãi. Đóng kết nối nếu sau 10 giây chưa xác thực.
4. Mạng chập chờn làm socket đóng. Thêm tự kết nối lại phía Angular với **exponential backoff**: chờ 1s, 2s, 4s, tối đa 30s. Vì sao không thử lại ngay lập tức?
5. Viết test cho `StudySocketHandler` với `Clock` giả: hai nhịp cách nhau 15 giây thì cộng 15, cách nhau 5 phút thì cộng 60, hai nhịp cùng một giây thì cộng 0.

**Senior**
6. Đẩy thông báo **từ server xuống**: chấm Writing xong thì gửi `{"event":"writing-graded","id":...}` qua socket, để trang kết quả bỏ được polling 4 giây. Server chạy 3 bản sau load balancer thì bản chấm xong làm sao tìm được socket của người dùng đang nối vào bản khác? (gợi ý: Redis pub/sub, hoặc Kafka.)
7. Đưa múi giờ thành thuộc tính của người dùng (cột trong `users`, chọn ở onboarding). Liệt kê mọi chỗ trong code đang dùng `clock` để tính "hôm nay" và phải đổi.

---

## 8. Góc nhìn senior

- **Client là lãnh thổ của kẻ tấn công.** Mọi con số, mọi trạng thái từ client là "lời khai", server phải tự kiểm chứng.
- **Bí mật không đi trên URL.** URL được ghi lại ở quá nhiều nơi bạn không kiểm soát.
- **Kết nối dài có chi phí dài.** Mỗi socket mở chiếm bộ nhớ trên server. 10.000 người mở tab là 10.000 kết nối. Trước khi chọn WebSocket, hỏi "polling 30 giây có đủ không?". Thường là đủ.

Tiếp theo: [Bài 13: Quan sát hệ thống](./learn-observability.md).
