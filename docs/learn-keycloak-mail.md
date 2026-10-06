# Keycloak và Mailpit — thứ có trong cụm, app chưa dùng hết

Hai service này nằm trong `docker-compose.yml` cho cùng mặt bằng với EDU APP Nihongo. Đọc file này để khỏi tìm mã đăng nhập Google hay hộp thư trong Angular.

## Keycloak

- URL: http://localhost:8083
- Admin: `admin` / `admin` (biến `KEYCLOAK_ADMIN`, `KEYCLOAK_ADMIN_PASSWORD`)
- Database riêng: container `en-postgres-keycloak`, cổng host 5436, không dùng database `english`
- Realm import: `infra/keycloak/realm-english.json`, client public `english-web`, redirect `localhost:8088` và `localhost:5174`

Lệnh container là `start-dev --import-realm`.

**Đăng nhập app không đi qua Keycloak.** Angular gọi `POST /api/auth/login`. Spring so BCrypt và ký JWT. Xem [learn-auth.md](./learn-auth.md).

Realm là chỗ để lần sau gắn OIDC nếu cần. Chưa có dependency OAuth2 resource server trong `pom.xml`, chưa có nút "Đăng nhập bằng Keycloak" trên `/login`.

Đổi mật khẩu admin bằng biến môi trường trước khi đưa máy này ra mạng khác. Giá trị `admin` chỉ để học local.

## Mailpit

- Hộp thư xem trên web: http://localhost:8026
- SMTP: trong Compose là `mailpit:1025`. Từ Windows là `localhost:1026`.

Profile `platform` set `spring.mail.host`. Thư viện `spring-boot-starter-mail` có trên classpath.

**Chưa có chỗ nào gọi `JavaMailSender`.** Ôn bài, đăng ký, nộp bài không gửi email. Mở Mailpit sẽ thấy hộp trống. Đó là đúng, không phải Mailpit hỏng.

Khi thêm gửi thư: inject `JavaMailSender` trong một listener Kafka hoặc sau khi đăng ký, và chỉ trong profile `platform`. Local H2 không có host mail, đừng gửi lúc `mvn spring-boot:run` thường.

## Việc tự làm

1. Mở http://localhost:8083, đăng nhập admin, thấy realm `english` và client `english-web`.
2. Mở http://localhost:8026, xác nhận chưa có thư.
3. Đọc lại `AuthController` và chắc chắn không có redirect sang Keycloak.

Hết lộ trình hạ tầng. Quay lại [learn-english.md](./learn-english.md) nếu cần xem bản đồ. Phần nghiệp vụ IELTS (band, lộ trình, dạng câu hỏi) nằm ở [IELTS_ROADMAP_SPEC.md](./IELTS_ROADMAP_SPEC.md).
