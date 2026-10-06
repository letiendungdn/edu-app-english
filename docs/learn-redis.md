# Bài 9: Redis và cache

**Mục tiêu:** hiểu cache là gì, khi nào nên dùng, cái giá phải trả (dữ liệu cũ), và vì sao app phải chạy được khi Redis chết.

**File:** `config/PlatformConfig.java` (tạo kết nối), `config/PlatformGateway.java` (`cache`), `service/VocabService.java` (nơi dùng).

---

## 1. Cache là gì

Đọc database tốn vài mili giây đến vài chục mili giây: qua mạng, đọc đĩa, chạy SQL. Đọc RAM tốn vài micro giây, nhanh hơn hàng nghìn lần. **Cache** là bản sao dữ liệu hay đọc, đặt ở chỗ nhanh hơn.

**Redis** là kho key-value nằm trong RAM, có mạng, nhiều server dùng chung được:

```text
SET vocab::1:30  '{"total":25,"words":[...]}'   EX 30     # lưu, tự xoá sau 30 giây
GET vocab::1:30                                           # đọc
TTL vocab::1:30                                           # còn bao nhiêu giây
```

Ngoài cache, Redis còn hay dùng làm: bộ đếm (`INCR`), giới hạn tần suất, khoá phân tán, hàng đợi, bảng xếp hạng (sorted set), lưu phiên đăng nhập.

---

## 2. Mẫu cache-aside trong repo

`PlatformGateway.cache`:

```java
public <T> T cache(String key, Class<T> type, Supplier<T> loader) {
  StringRedisTemplate cache = redis.getIfAvailable();          // không có Redis → null
  if (cache != null) {
    try {
      String hit = cache.opsForValue().get(key);
      if (hit != null) return json.readValue(hit, type);        // 1. có trong cache → trả luôn
    } catch (Exception ex) { log.debug("Redis read skipped: {}", ex.getMessage()); }
  }
  T value = loader.get();                                       // 2. không có → đọc database
  if (cache != null && value != null) {
    try {
      cache.opsForValue().set(key, json.writeValueAsString(value), Duration.ofSeconds(30));  // 3. lưu vào cache
    } catch (Exception ex) { log.debug("Redis write skipped: {}", ex.getMessage()); }
  }
  return value;
}
```

Mẫu này tên là **cache-aside** (cache đứng cạnh): code tự hỏi cache trước, trượt thì đọc database rồi tự ghi vào cache. Mẫu phổ biến nhất ngoài đời.

Ba điều đáng học:
1. **`getIfAvailable()`**: chạy local không có profile `platform` thì không có bean Redis, hàm vẫn chạy và chỉ bỏ qua cache. Code nghiệp vụ không cần biết Redis có tồn tại hay không.
2. **Mọi lỗi Redis đều bị nuốt** (`catch` rồi ghi log debug). Redis chết thì app chậm hơn chút, **không** hỏng. Cache là để tăng tốc, không bao giờ được thành điểm hỏng của hệ thống.
3. Lỗi được ghi ở mức `debug`, không phải `warn`: Redis chết thì mỗi request sẽ lỗi một lần, và log mức `warn` sẽ ngập.

> Bản trước có một nhánh `catch` cho `JsonProcessingException` nhưng không bắt lỗi kết nối khi ghi. Redis chết giữa chừng lúc ghi là request lỗi 500. Giờ cả hai loại lỗi đều được bắt.

---

## 3. Cái gì được cache, và vì sao chỉ cái đó

`VocabService.list`:

```java
public VocabPage list(String levelParam, int page, int limit, Long userId) {
  if (userId != null) return loadPage(levelParam, page, limit, userId);       // đã đăng nhập: KHÔNG cache
  String key = "vocab:" + (levelParam == null ? "" : levelParam) + ":" + page + ":" + limit;
  return platform.cache(key, VocabPage.class, () -> loadPage(levelParam, page, limit, null));
}
```

Chỉ cache danh sách từ vựng **cho khách chưa đăng nhập**. Vì sao?
- Người đã đăng nhập thấy kèm trạng thái SRS **của riêng họ** (đến hạn ôn ngày nào). Dùng chung một key thì người này thấy dữ liệu của người kia, một lỗi bảo mật thật. Muốn cache thì key phải chứa `userId`, khi đó tỉ lệ trúng cache rất thấp nên cache không đáng.
- Danh sách từ ít khi đổi và nhiều người cùng đọc: đúng kiểu dữ liệu đáng cache.

**Key phải chứa đủ mọi tham số ảnh hưởng tới kết quả** (level, page, limit). Thiếu một tham số là trả nhầm trang. Đây là nguồn lỗi cache phổ biến nhất.

---

## 4. Cái giá: dữ liệu cũ

> "Trong khoa học máy tính chỉ có hai việc khó: đặt tên và làm mất hiệu lực cache." (Phil Karlton)

Thêm từ mới vào database, khách vẫn thấy danh sách cũ tới **30 giây**. Có ba chiến lược:

| Chiến lược | Cách | Ưu | Nhược |
|-----------|------|-----|------|
| **TTL** (repo dùng) | Tự hết hạn sau N giây | đơn giản, không thể quên | cũ tối đa N giây |
| **Xoá khi ghi** | Sửa dữ liệu thì `DEL` key liên quan | gần như luôn mới | phải nhớ xoá ở **mọi** chỗ ghi; key có nhiều biến thể (`vocab:B1:1:30`, `vocab:B1:2:30`...) |
| **Ghi xuyên** | Ghi database và cache cùng lúc | luôn mới | phức tạp, hai nơi có thể lệch nếu một bên lỗi |

Với danh sách từ mẫu ít khi đổi, cũ 30 giây là chấp nhận được. **Không** nên cache: điểm bài thi, trạng thái bài đang chấm, lộ trình hôm nay. Người dùng vừa làm xong phải thấy ngay kết quả.

**Câu hỏi để chọn:** "Người dùng thấy dữ liệu cũ N giây thì hậu quả là gì?" Danh sách từ: không sao. Số dư tài khoản ngân hàng: rất nghiêm trọng.

---

## 5. Các vấn đề cache kinh điển (cho phỏng vấn)

- **Cache stampede** (đàn bò giẫm đạp): key phổ biến hết hạn, 1000 request cùng lúc trượt cache và cùng đánh vào database. Cách xử lý: khoá để chỉ một request tải lại, hoặc cho TTL lệch ngẫu nhiên, hoặc làm mới sớm trước khi hết hạn.
- **Cache penetration**: truy vấn thứ không tồn tại (`level=ZZZ`), luôn trượt cache, luôn đánh database. Cách xử lý: cache cả kết quả rỗng trong thời gian ngắn.
- **Cache avalanche**: nhiều key hết hạn cùng một lúc (ví dụ cùng được tạo lúc khởi động). Cách xử lý: thêm độ lệch ngẫu nhiên vào TTL.
- **Bộ nhớ đầy**: Redis nằm trong RAM. Cấu hình `maxmemory` và chính sách loại bỏ (`allkeys-lru`: xoá key lâu không dùng nhất).

---

## 6. Thử trên máy

Chạy cụm Docker, rồi:

```powershell
# Mở danh sách từ khi CHƯA đăng nhập (cửa sổ ẩn danh): http://localhost:8088/vocab
docker exec -it en-redis redis-cli KEYS "vocab:*"
docker exec -it en-redis redis-cli GET "vocab::1:30"
docker exec -it en-redis redis-cli TTL "vocab::1:30"        # ≤ 30

# Redis chết thì app vẫn chạy
docker compose stop redis
curl http://localhost:8088/api/vocab                         # vẫn có dữ liệu, đọc thẳng database
docker compose start redis
```

> `KEYS *` quét **toàn bộ** Redis và chặn mọi lệnh khác trong lúc quét. Dùng để học thì được, ở production phải dùng `SCAN`.

---

## 7. Việc tự làm

**Junior**
1. Làm theo mục 6. Ghi lại thời gian response của `/api/vocab` lần đầu và lần hai (DevTools → Network → Timing).
2. Đổi TTL thành 60 giây. Đặt TTL ra `application.yml` thay vì ghi cứng trong code.

**Mid**
3. Cache danh sách bài đọc (`ContentService.readings`) cho mọi người, vì nó không phụ thuộc người dùng. Chọn key và TTL. Khi seeder thêm bài mới thì sao?
4. Viết test cho `PlatformGateway.cache` khi không có Redis: hàm phải gọi `loader` và trả đúng giá trị.

**Senior**
5. Đổi hạn mức chấm AI (`AiUsage`) sang Redis `INCR` + `EXPIRE` theo ngày. Phân tích: giải quyết được race condition hai request đồng thời không? Redis chết thì nên cho chấm (mở) hay chặn (đóng)? Chọn và bảo vệ lựa chọn.
6. Thiết kế cache cho `GET /api/roadmap/today`, endpoint gọi nhiều nhất. Dữ liệu đổi khi người học tick task, nộp bài, sinh lại lộ trình. Có đáng cache không? Nếu có, làm mất hiệu lực ở đâu?

---

## 8. Góc nhìn senior

- **Đừng cache trước khi đo.** Cache thêm độ phức tạp và lỗi dữ liệu cũ. Chỉ thêm khi đo được chỗ chậm (bài 13) và chỗ đó đọc nhiều hơn ghi rất nhiều.
- **Cache phải "vô hình" khi hỏng.** Redis chết, hệ thống chậm đi chứ không sập. Code trong repo được thiết kế đúng như vậy.
- **Dữ liệu cá nhân và cache chung không đi cùng nhau.** Cache nhầm key là một trong những cách rò rỉ dữ liệu người dùng phổ biến nhất ngoài đời.

Tiếp theo: [Bài 10: MongoDB](./learn-mongodb.md).
