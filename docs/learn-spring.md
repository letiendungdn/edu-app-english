# Học Spring Boot — EDU APP English

API là một process Java. Package gốc: `com.edu.english`.

```text
web/        HTTP, chỉ nhận request và trả JSON
service/    luật nghiệp vụ (SRS, chấm bài, đăng ký)
domain/     bảng, map bởi JPA
repo/       query Spring Data
security/   JWT
config/     seed dữ liệu, Redis/Kafka/Mongo, WebSocket
```

Controller không viết SQL. Service không biết Angular.

## 1. Đi một request

`GET /api/vocab?page=1`

1. `web/VocabController.java` đọc query `level`, `page`, `limit`.
2. `security/CurrentUser.optional()` trả user nếu có Bearer token, không thì `null`.
3. `service/VocabService.list` phân trang `vocabulary`.
4. Record trong `web/ApiModels.java` (`VocabPage`, `VocabView`) thành JSON.

User chưa đăng nhập thì `list` còn hỏi Redis. Xem [learn-redis.md](./learn-redis.md). Không có Redis (chạy local không profile `platform`) thì `PlatformGateway` bỏ qua cache và vẫn đọc database.

## 2. SRS nằm ở Sm2

`service/Sm2.java` là hàm thuần: nhận thẻ và điểm 0–5, trả lịch ôn mới. Không đụng HTTP.

`VocabService.submitReview` tìm hoặc tạo `SrsCard`, gọi `Sm2.apply`, lưu, cộng thời gian học, rồi publish Kafka.

Test: `src/test/java/com/edu/english/service/Sm2Test.java`. Sửa công thức SRS thì sửa test này trước.

## 3. Nội dung bài học không hard-code trong Java

`config/DataSeeder.java` đọc JSON:

```text
backend/src/main/resources/content/vocab.json
backend/src/main/resources/content/grammar.json
backend/src/main/resources/content/reading.json
backend/src/main/resources/content/listening.json
```

Thêm một từ mẫu: sửa `vocab.json`, xóa database local (file `backend/data` nếu dùng H2, hoặc volume Postgres), chạy lại. Seeder không ghi đè user `demo@edu.app` nếu email đó đã có.

## 4. Profile

`src/main/resources/application.yml` mặc định profile `dev`:

- Database H2 file `backend/data`
- JWT có secret mặc định cho dev
- Flyway chạy `classpath:db/migration`

`application-platform.yml` chỉ có hiệu lực khi `SPRING_PROFILES_ACTIVE=platform` (Docker Compose đặt sẵn):

- Postgres
- Redis, MongoDB, Kafka, Mailpit
- Gửi trace sang Jaeger

Đừng bật `platform` nếu chưa có Postgres. App sẽ không lên.

## 5. Việc tự làm

1. Chạy API local, gọi:

```powershell
curl http://localhost:8080/api/grammar
```

2. Mở `GrammarController` và `ContentService.grammarTopics`. Đối chiếu field JSON với record `GrammarListItem`.
3. Đặt breakpoint hoặc thêm một log trong `VocabController.vocab`, tải lại `/vocab` trên Angular, thấy log.

Tiếp: [learn-auth.md](./learn-auth.md).
