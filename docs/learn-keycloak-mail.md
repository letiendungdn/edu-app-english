# Bài 14: Keycloak và Mailpit: có trong cụm, chưa dùng

**Mục tiêu:** hiểu đăng nhập tập trung (SSO, OAuth2, OpenID Connect) là gì và khác cách app đang đăng nhập ra sao; biết cách gửi email đúng kiểu. Hai dịch vụ này **đang chạy trong Docker nhưng app chưa dùng**. Bài này giúp bạn khỏi mất công tìm code không tồn tại, và chuẩn bị nếu sau này cần gắn vào.

**File:** `infra/keycloak/realm-english.json`, mục `keycloak`, `postgres-keycloak`, `mailpit` trong `docker-compose.yml`, `spring.mail` trong `application-platform.yml`.

---

## 1. Keycloak: đăng nhập tập trung

### Vấn đề

Công ty có 5 app: app tiếng Anh, tiếng Nhật, trang quản trị, diễn đàn, cửa hàng. Mỗi app tự lưu mật khẩu thì có:
- 5 tài khoản, 5 mật khẩu cho mỗi người dùng.
- 5 chỗ phải làm đúng băm mật khẩu, quên mật khẩu, xác thực hai lớp, khoá tài khoản khi đoán sai.
- Một người nghỉ việc phải khoá ở 5 nơi.

**SSO (Single Sign-On):** một hệ thống đăng nhập dùng chung. Đăng nhập một lần, vào được mọi app. **Keycloak** là phần mềm mã nguồn mở làm việc đó, nói giao thức chuẩn **OAuth 2.0** và **OpenID Connect (OIDC)**. Các dịch vụ "Đăng nhập bằng Google" cũng dùng chính các giao thức này.

### So sánh với cách app đang làm

| | Hiện tại (bài 4) | Với Keycloak |
|---|---|---|
| Ai lưu mật khẩu | bảng `users` của app | Keycloak |
| Ai cấp token | `JwtService.sign` (HMAC, secret chung) | Keycloak (RSA: ký bằng khoá riêng, kiểm tra bằng khoá công khai) |
| Trang đăng nhập | `pages/auth.component.ts` | trang của Keycloak, app chuyển hướng sang |
| Spring kiểm tra token | `JwtAuthFilter` tự viết | `spring-boot-starter-oauth2-resource-server`, tải khoá công khai từ Keycloak |
| Quên mật khẩu, 2FA, đăng nhập Google | phải tự viết | có sẵn, chỉ cấu hình |

**Ký bằng RSA tốt hơn HMAC ở chỗ nào?** HMAC dùng **một** secret cho cả ký lẫn kiểm tra: app nào kiểm tra được token thì cũng **tạo** được token. RSA tách đôi: chỉ Keycloak giữ khoá riêng để ký, các app chỉ cần khoá công khai để kiểm tra. Một app bị lộ thì kẻ xấu không giả mạo được token cho app khác.

### Luồng Authorization Code + PKCE (luồng chuẩn cho web app)

```text
1. Người dùng bấm "Đăng nhập"
2. Angular chuyển hướng sang Keycloak: /auth?client_id=english-web&redirect_uri=...&code_challenge=...
3. Người dùng nhập mật khẩu TRÊN TRANG KEYCLOAK (app không bao giờ thấy mật khẩu)
4. Keycloak chuyển về app kèm một "code" dùng một lần
5. Angular đổi code (+ code_verifier) lấy access token
6. Angular gọi API với Authorization: Bearer <access token>
7. Spring kiểm tra chữ ký bằng khoá công khai của Keycloak
```

**PKCE** (đọc là "pixy") chống việc kẻ xấu chặn được code ở bước 4: code chỉ đổi được khi có `code_verifier` bí mật mà chỉ trình duyệt gốc biết.

### Trong repo

`infra/keycloak/realm-english.json`:

```json
{
  "realm": "english",
  "clients": [{
    "clientId": "english-web",
    "publicClient": true,                         // app chạy trên trình duyệt, không giữ được secret
    "redirectUris": ["http://localhost:8088/*", "http://localhost:5174/*"],
    "standardFlowEnabled": true,                  // bật Authorization Code
    "directAccessGrantsEnabled": false            // TẮT việc gửi mật khẩu thẳng qua API: đúng
  }]
}
```

- Realm là một "không gian" người dùng riêng. Một Keycloak chứa được nhiều realm.
- `5174` là cổng dev của app tiếng Nhật, chép theo cấu hình bên đó. App English chạy dev ở **4200**, nên muốn thử phải thêm `http://localhost:4200/*`.
- Keycloak dùng **database riêng** (`en-postgres-keycloak`, cổng 5436), không đụng database `english`.

**Chưa có gì trong app dùng Keycloak:** `pom.xml` chưa có `oauth2-resource-server`, Angular chưa có thư viện OIDC, trang đăng nhập vẫn gọi `POST /api/auth/login`.

Mở thử: http://localhost:8083, đăng nhập `admin`/`admin`, chọn realm `english`, xem client `english-web`.

---

## 2. Mailpit: hộp thư để thử

Code gửi email trong lúc phát triển mà gửi thật thì dễ gửi nhầm cho người dùng thật, hoặc bị nhà mạng đánh dấu spam. **Mailpit** là một máy chủ SMTP **giả**: nhận mọi email nhưng không gửi đi đâu, và cho xem chúng trên web.

- Web xem thư: http://localhost:8026
- SMTP: trong Docker là `mailpit:1025`, từ máy bạn là `localhost:1026`.

`application-platform.yml` đã cấu hình `spring.mail.host` và `spring.mail.port`, `pom.xml` đã có `spring-boot-starter-mail`. Nhưng **chưa chỗ nào gọi `JavaMailSender`**. Mở Mailpit thấy hộp trống là đúng, không phải Mailpit hỏng.

### Gửi email đúng cách (khi bạn thêm vào)

```java
@Component
@Profile("platform")                              // local không có máy chủ mail → không tạo bean này
public class MailNotifier {
  private final JavaMailSender mail;
  ...
  public void send(String to, String subject, String body) {
    SimpleMailMessage msg = new SimpleMailMessage();
    msg.setTo(to); msg.setSubject(subject); msg.setText(body);
    mail.send(msg);
  }
}
```

Ba nguyên tắc:
1. **Không gửi email trong transaction của request.** Máy chủ mail chậm hoặc chết thì request chậm theo. Gửi sau commit, chạy nền, như chấm AI (bài 6) hoặc qua Kafka consumer (bài 11).
2. **Gửi email là việc không hoàn tác được.** Đã gửi thì không thu hồi. Phải chắc dữ liệu đã commit, và chống gửi trùng khi thử lại.
3. **Không chứa dữ liệu nhạy cảm** trong email, vì email đi qua nhiều máy chủ không kiểm soát được.

---

## 3. Việc tự làm

**Junior**
1. Mở Keycloak admin, tạo một user trong realm `english`. Mở Mailpit, xác nhận hộp trống.
2. Gửi thử một email vào Mailpit bằng PowerShell: `Send-MailMessage -SmtpServer localhost -Port 1026 -From a@test.local -To b@test.local -Subject "Thử" -Body "Xin chào"`. Mở Mailpit xem.

**Mid**
3. Viết `MailNotifier` như mục 2 và gửi email chào mừng sau khi đăng ký. Đảm bảo: chạy local không profile `platform` thì không lỗi; máy chủ mail chết thì đăng ký vẫn thành công.
4. Gửi email tổng kết tuần mỗi sáng thứ Hai (`@Scheduled(cron = "0 0 8 * * MON", zone = "Asia/Ho_Chi_Minh")`): số việc đã làm, band hiện tại. Chạy 2 bản backend thì email có bị gửi 2 lần không?

**Senior**
5. Lên kế hoạch chuyển đăng nhập sang Keycloak **mà không bắt người dùng cũ đặt lại mật khẩu**. Các bước, giai đoạn chạy song song hai cách đăng nhập, cách chuyển băm BCrypt sang Keycloak (Keycloak hỗ trợ import hash), cách quay lui nếu hỏng.
6. Có nên dùng Keycloak cho app này không? Liệt kê cái được và cái mất (một hệ thống nữa phải vận hành, sao lưu, vá lỗi, nâng cấp). Khi nào thì đáng?

---

## 4. Góc nhìn senior

- **Đừng tự viết hệ thống đăng nhập khi có lựa chọn tốt hơn,** nhưng cũng đừng thêm Keycloak chỉ vì nó "chuyên nghiệp". Một app, một nhóm nhỏ thì JWT tự cấp như hiện tại là đủ. Nhiều app, cần SSO, cần 2FA, cần đăng nhập doanh nghiệp thì đó là lúc dùng Keycloak hoặc một dịch vụ quản lý sẵn.
- **Hạ tầng "có sẵn nhưng chưa dùng" là nợ kỹ thuật.** Nó vẫn tốn RAM, vẫn cần vá bảo mật, và làm người mới bối rối. Tài liệu này tồn tại để bù cho điều đó. Ở dự án thật, cân nhắc gỡ khỏi compose cho tới khi thật sự cần.
- **Việc không hoàn tác được (gửi email, trừ tiền, gọi API bên ngoài) luôn làm sau commit, có chống trùng.**

---

Tiếp theo: [Bài 15: Chọn công nghệ](./learn-choosing-stack.md). Sau đó quay lại [bản đồ học](./learn-english.md), làm các bài tập cấp **Mid** bạn đã bỏ qua, rồi tới cấp **Senior**. Mỗi bài tập Senior trả lời được kèm lý lẽ về đánh đổi là bạn đã có thứ để kể trong một buổi phỏng vấn.
