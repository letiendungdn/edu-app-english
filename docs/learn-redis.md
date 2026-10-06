# Học Redis — EDU APP English

Redis trong app này là cache đọc, không phải database chính. Mất Redis thì mất cache, không mất từ hay user.

## 1. Khi nào có Redis

Chỉ profile `platform`. `PlatformConfig` tạo `StringRedisTemplate` nối `spring.data.redis.host`.

`EnglishApplication` tắt auto-config Redis. Không có profile `platform` thì không có bean Redis, `mvn spring-boot:run` không cần cài Redis.

`PlatformGateway.cache` gọi `redis.getIfAvailable()`. Null thì chạy loader (đọc Postgres hoặc H2) như bình thường.

## 2. Cái được cache

`VocabService.list`, **chỉ khi chưa đăng nhập** (`userId == null`).

Key: `vocab:{level}:{page}:{limit}`. TTL 30 giây. Giá trị là JSON của `VocabPage`.

Đã đăng nhập thì mỗi user có khối SRS khác nhau, nên không dùng chung một key. Request đó luôn vào database.

Ôn bài, nộp bài đọc, sửa từ: chưa xóa cache. Sau tối đa 30 giây khách chưa đăng nhập thấy dữ liệu mới. Đủ cho danh sách từ mẫu.

## 3. Thấy trên máy

Compose map Redis ra `localhost:6380`.

```powershell
docker exec -it en-redis redis-cli KEYS "vocab:*"
```

Mở http://localhost:8088/vocab khi chưa đăng nhập, rồi chạy lệnh trên. Phải có một key. `GET` key đó ra JSON.

`TTL tên_key` nhỏ hơn hoặc bằng 30.

## 4. Việc tự làm

Gọi `GET /api/vocab` hai lần sát nhau khi chưa đăng nhập. Lần hai Spring vẫn trả cùng JSON. Trong log API không có lỗi Redis.

Dừng Redis: `docker compose stop redis`. Gọi lại `/api/vocab`. Trang vẫn có dữ liệu vì gateway nuốt lỗi và đọc Postgres. Bật lại: `docker compose start redis`.

Tiếp: [learn-mongodb.md](./learn-mongodb.md).
