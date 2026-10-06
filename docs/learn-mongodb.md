# Bài 10: MongoDB và nhật ký request

**Mục tiêu:** hiểu database dạng document khác database quan hệ ở đâu, khi nào dùng cái nào, và cách ghi log mà không làm chậm người dùng.

**File:** `config/AuditFilter.java`, `config/PlatformGateway.java` (`audit`), `config/PlatformConfig.java` (tạo `MongoTemplate`).

---

## 1. Document database là gì

Postgres lưu **bảng** với cột cố định. Muốn thêm cột phải viết migration.

MongoDB lưu **document**: mỗi bản ghi là một object giống JSON, không cần khai báo cấu trúc trước:

```json
{ "_id": "66f...", "method": "GET", "path": "/api/vocab", "status": 200, "at": "2026-10-06T07:12:03Z" }
{ "_id": "66f...", "method": "POST", "path": "/api/reading/3/submit", "status": 200, "at": "...", "userId": 1 }
```

Document thứ hai có thêm `userId` mà không cần sửa gì. Document nằm trong **collection** (tương đương bảng), collection nằm trong **database**.

| | Postgres | MongoDB |
|---|---|---|
| Cấu trúc | cố định, có migration | linh hoạt |
| Quan hệ giữa bản ghi | `JOIN`, khoá ngoại | thường nhúng dữ liệu vào nhau, ít join |
| Transaction nhiều bản ghi | mạnh, mặc định | có, nhưng không phải thế mạnh |
| Hợp với | dữ liệu nghiệp vụ liên kết chặt | log, sự kiện, dữ liệu nhiều hình dạng, ghi khối lượng lớn |

**App này dùng cả hai, mỗi cái đúng việc của nó:** bài học, điểm, lộ trình nằm ở Postgres vì liên kết chặt và cần transaction. Nhật ký request nằm ở Mongo vì chỉ ghi thêm, không cần join, hình dạng có thể đổi theo thời gian.

Dùng nhiều loại database trong một hệ thống, mỗi loại cho một việc, gọi là **polyglot persistence**. Đổi lại phải vận hành thêm một hệ thống: backup, giám sát, vá lỗi.

---

## 2. Luồng ghi audit

```text
Request bất kỳ
  └─ AuditFilter.doFilterInternal
       ├─ filterChain.doFilter(...)          request chạy bình thường
       └─ finally: platform.audit(method, path, status)
             └─ executor.execute(...)        đẩy sang luồng nền, trả về NGAY
                   └─ mongo.insert(..., "audit_logs")
```

`AuditFilter`:

```java
try {
  filterChain.doFilter(request, response);
} finally {
  platform.audit(request.getMethod(), request.getRequestURI(), response.getStatus());
}
```

Ghi trong `finally` để request lỗi (exception) **cũng** được ghi lại, vì request lỗi thường là cái đáng xem nhất.

`PlatformGateway.audit`:

```java
public void audit(String method, String path, int status) {
  MongoTemplate store = mongo.getIfAvailable();
  if (store == null || !path.startsWith("/api/")) return;       // không có Mongo, hoặc không phải API → bỏ qua
  Instant at = Instant.now();                                   // lấy giờ NGAY, trước khi sang luồng khác
  executor.execute(() -> {
    try {
      store.insert(Map.of("method", method, "path", path, "status", status, "at", at), "audit_logs");
    } catch (Exception ex) {
      log.debug("Audit log skipped: {}", ex.getMessage());
    }
  });
}
```

### Lỗi đã sửa: ghi đồng bộ

Bản trước gọi `store.insert(...)` **ngay trong luồng của request**. Kết nối Mongo cấu hình `serverSelectionTimeout = 2 giây`. Hậu quả khi Mongo chết:

```text
Mỗi request /api/... → chạy xong việc chính → chờ Mongo 2 giây → timeout → nuốt lỗi → trả về
```

**Mọi** API chậm thêm 2 giây, dù không request nào liên quan tới Mongo. Người dùng thấy app "lag" mà không ai hiểu vì sao, vì log chỉ ghi ở mức debug.

Giờ việc ghi chạy trên `platformExecutor` (`config/AppConfig.java`):

```java
executor.setCorePoolSize(1);
executor.setMaxPoolSize(2);
executor.setQueueCapacity(1000);
executor.setRejectedExecutionHandler(new ThreadPoolExecutor.DiscardPolicy());   // hàng đợi đầy → BỎ việc mới
```

- Request trả về ngay, không chờ Mongo.
- Mongo chết: hàng đợi dần đầy 1000 việc, sau đó việc mới **bị bỏ**. Mất một ít log, nhưng bộ nhớ không phình vô hạn và người dùng không bị ảnh hưởng.

**Hàng đợi không giới hạn là một quả bom hẹn giờ.** Mongo chết một giờ, mỗi giây 100 request, thì hàng đợi chứa 360.000 việc và app hết bộ nhớ. Luôn đặt giới hạn, và quyết định rõ khi đầy thì làm gì: bỏ, chặn, hay chạy luôn trên luồng gọi.

---

## 3. Những gì KHÔNG được ghi

Document audit chỉ có method, đường dẫn, mã trạng thái, thời gian. **Không** ghi:
- Body request: có mật khẩu (`/api/auth/login`), bài viết của người học.
- Header `Authorization`: có token, ai đọc được log là giả danh được người dùng.
- Query string chứa dữ liệu cá nhân.

Log thường được nhiều người đọc hơn database, và được giữ lâu hơn. Dữ liệu nhạy cảm lọt vào log là một kiểu rò rỉ rất phổ biến. Đây cũng là lý do token WebSocket chuyển từ URL sang tin nhắn (bài 12).

---

## 4. Thử trên máy

```powershell
docker exec -it en-mongodb mongosh english_audit --eval "db.audit_logs.find().sort({at:-1}).limit(5)"

# Request lỗi gần đây
docker exec -it en-mongodb mongosh english_audit --eval "db.audit_logs.find({status: {`$gte: 400}}).sort({at:-1}).limit(10)"

# Đếm request theo đường dẫn (aggregation pipeline)
docker exec -it en-mongodb mongosh english_audit --eval "db.audit_logs.aggregate([{`$group: {_id: '`$path', n: {`$sum: 1}}}, {`$sort: {n: -1}}, {`$limit: 10}])"

# Mongo chết, app vẫn nhanh
docker compose stop mongodb
curl -w "%{time_total}s\n" -o NUL http://localhost:8088/api/tests     # vẫn nhanh, không +2 giây
docker compose start mongodb
```

(Trong PowerShell, ký tự `` ` `` thoát dấu `$`.)

Giao diện đồ hoạ: MongoDB Compass, kết nối `mongodb://localhost:27018`.

---

## 5. Việc tự làm

**Junior**
1. Chạy các truy vấn ở mục 4. Tìm request lỗi gần nhất của bạn.
2. Giải thích bằng lời vì sao `Instant at = Instant.now()` được lấy **trước** `executor.execute`.

**Mid**
3. Thêm thời gian xử lý (`durationMs`) vào document audit. Đo ở `AuditFilter` bằng `System.nanoTime()`. Viết truy vấn tìm 10 đường dẫn chậm nhất trung bình.
4. Thêm `userId` vào document khi có (đọc từ `CurrentUser.optional()` trong filter). Cẩn thận: filter audit chạy trước hay sau `JwtAuthFilter`?
5. Log tăng mãi. Tạo **TTL index** để Mongo tự xoá document cũ hơn 30 ngày: `db.audit_logs.createIndex({at: 1}, {expireAfterSeconds: 2592000})`. Làm sao để index này được tạo tự động khi app khởi động?

**Senior**
6. Audit hiện có thể mất bản ghi (hàng đợi đầy, app tắt khi còn việc trong hàng đợi). Với log truy cập thì chấp nhận được. Nếu là **audit pháp lý** (ai đã sửa điểm của học sinh), mất là không chấp nhận được. Thiết kế lại cho trường hợp đó. Gợi ý: ghi chung transaction với thay đổi vào bảng Postgres (outbox), rồi chuyển sang kho lưu trữ sau.
7. Có nên dùng Mongo ở đây không, hay chỉ cần ghi log ra stdout rồi để công cụ log (Loki, Elasticsearch) thu gom? So sánh chi phí vận hành, khả năng truy vấn, thời gian lưu trữ.

---

## 6. Góc nhìn senior

- **Đường đi chính không bao giờ chờ việc phụ.** Audit, metric, gửi sự kiện là việc phụ. Đẩy sang nền, có giới hạn, có chiến lược khi quá tải.
- **Chọn database theo cách dữ liệu được dùng,** không theo mốt. Log chỉ ghi thêm và đọc theo khoảng thời gian thì hợp với Mongo hoặc công cụ log chuyên dụng. Dữ liệu nghiệp vụ cần transaction thì ở lại Postgres.
- **Mất dữ liệu nào chấp nhận được, phải là quyết định có ý thức.** `DiscardPolicy` ghi rõ: log truy cập được phép mất khi quá tải. Viết điều đó ra, để người sau không ngạc nhiên.

Tiếp theo: [Bài 11: Kafka](./learn-kafka.md).
