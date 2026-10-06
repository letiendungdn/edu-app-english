# Học MongoDB — EDU APP English

MongoDB không chứa bài học. Bài học ở Postgres. Mongo chỉ nhận nhật ký request.

## 1. Chỗ ghi

`config/AuditFilter.java` chạy sau mọi request HTTP và gọi `PlatformGateway.audit`.

Chỉ ghi khi:

- profile `platform` (có `MongoTemplate`)
- path bắt đầu bằng `/api/`

Document trong database `english_audit`, collection `audit_logs`:

```text
{ method, path, status, at }
```

`/actuator` và file tĩnh không ghi. WebSocket không đi qua filter HTTP này.

Lỗi Mongo (chưa kịp lên, sai URI) bị nuốt, request của user vẫn trả bình thường. Audit không được phép làm hỏng API.

## 2. Cổng

Trong mạng Compose: `mongodb:27017`, database khởi tạo `english_audit`.

Từ máy Windows: `localhost:27018` để không đụng Mongo cổng 27017 của app tiếng Nhật.

## 3. Việc tự làm

```powershell
docker exec -it en-mongodb mongosh english_audit --eval "db.audit_logs.find().sort({at:-1}).limit(5)"
```

Tải lại `/vocab` trên app, chạy lại lệnh. Có dòng `GET` `/api/vocab` status 200.

Xóa thử cho đỡ đầy lúc học local:

```powershell
docker exec -it en-mongodb mongosh english_audit --eval "db.audit_logs.deleteMany({})"
```

Tiếp: [learn-kafka.md](./learn-kafka.md).
