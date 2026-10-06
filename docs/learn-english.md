# Lộ trình học EDU APP English

Đọc theo thứ tự dưới đây. Mỗi file gắn với **file code đang có trong repo này**, không phải lý thuyết chung và không phải stack NestJS của app tiếng Nhật.

`docs/IELTS_ROADMAP_SPEC.md` là đặc tả sản phẩm (onboarding, band, lộ trình học). Nó không thay bộ tài liệu này.

## Cách học

1. Chạy được một thứ trước khi đọc khái niệm.
2. Đi một luồng request từ Angular tới Spring rồi tới Postgres.
3. Cuối mỗi file có một việc nhỏ để tự kiểm tra.

Hai cách chạy:

| Cách | Lệnh | Có Redis, Kafka, Mongo, Nginx? |
|------|------|--------------------------------|
| Local | `mvn spring-boot:run` và `npm start` | Không. API dùng H2. Học Angular, Spring, JWT, SRS trước. |
| Cả cụm | `docker compose up -d --build` | Có. App ở http://localhost:8088 |

Tài khoản mẫu: `demo@edu.app` / `demo123`.

## Bản đồ thư mục

| Chỗ | Vai trò | Đọc khi học |
|-----|---------|-------------|
| `frontend/src/app` | Angular: route, gọi API, WebSocket | [learn-angular.md](./learn-angular.md) |
| `backend/src/main/java/com/edu/english/web` | REST controller | [learn-spring.md](./learn-spring.md) |
| `backend/.../security` | JWT, filter, rule URL nào phải đăng nhập | [learn-auth.md](./learn-auth.md) |
| `backend/.../service` | Từ vựng, SRS, chấm bài | [learn-spring.md](./learn-spring.md) |
| `backend/.../domain` + `resources/db` | Bảng và migration | [learn-postgres.md](./learn-postgres.md) |
| `backend/.../config/Platform*.java` | Redis, Mongo, Kafka | các file hạ tầng |
| `docker-compose.yml` | Cả cụm | [learn-docker.md](./learn-docker.md) |
| `infra/nginx` | Cổng vào | [learn-nginx.md](./learn-nginx.md) |

## Thứ tự

1. [Angular](./learn-angular.md) — màn hình và lời gọi API.
2. [Spring Boot](./learn-spring.md) — một request vào controller rồi service.
3. [Đăng nhập JWT](./learn-auth.md) — token, filter, URL công khai.
4. [Postgres và H2](./learn-postgres.md) — schema, Flyway, profile `platform`.
5. [Docker](./learn-docker.md) — bật cả cụm.
6. [Nginx](./learn-nginx.md) — vì sao trình duyệt chỉ thấy cổng 8088.
7. [Redis](./learn-redis.md) — cache danh sách từ.
8. [MongoDB](./learn-mongodb.md) — nhật ký request.
9. [Kafka](./learn-kafka.md) — sự kiện sau khi ôn từ.
10. [WebSocket](./learn-websocket.md) — nhịp học khi đang đăng nhập.
11. [Quan sát](./learn-observability.md) — health, Prometheus, Grafana, Jaeger.
12. [Keycloak và Mailpit](./learn-keycloak-mail.md) — thứ đang có trong Compose nhưng app chưa dùng để đăng nhập hay gửi thư.

## Một request thật

Mở http://localhost:8088/vocab khi cụm Docker đang chạy:

```text
Trình duyệt
  → Nginx :8088  (infra/nginx/nginx.conf)
      /           → container web (Angular, file tĩnh)
      /api/vocab  → container api :8080
          VocabController
            → VocabService.list
                → Redis (nếu chưa đăng nhập và profile platform)
                → Postgres bảng vocabulary
            → AuditFilter ghi MongoDB collection audit_logs
  → JSON về Angular, vẽ danh sách từ
```

Ôn một thẻ SRS thêm một bước: `POST /api/vocab/review` lưu `srs_cards` rồi gửi Kafka topic `edu.vocab.reviewed`. Chưa có consumer đọc topic đó.
