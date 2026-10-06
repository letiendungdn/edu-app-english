# EDU APP English

Ứng dụng học tiếng Anh viết bằng **Java 21 / Spring Boot** và **Angular 19**, dùng cùng lớp hạ tầng với EDU APP Nihongo.

| Lớp | Công nghệ |
|-----|-----------|
| Web | Angular 19 |
| API | Spring Boot 3.4, Spring Security, JWT, WebSocket `/ws/study` |
| Dữ liệu học | PostgreSQL 16 + Flyway (H2 khi chạy local không Docker) |
| Cache | Redis 7 |
| Audit | MongoDB 7 |
| Sự kiện | Kafka (`edu.vocab.reviewed`, `edu.session.completed`) |
| Auth | JWT. Keycloak realm `english` chạy trong Compose |
| Cổng | Nginx, healthcheck, trang chờ khi API hoặc web chưa sẵn sàng |
| Quan sát | Actuator + Prometheus, Grafana, Jaeger (OTLP), Alertmanager |
| Thư | Mailpit |
| Triển khai | Docker Compose, Helm `infra/helm/english`, GitHub Actions |

Stripe và LiveKit thuộc marketplace/coaching của app tiếng Nhật, không nằm trong app English.

Học từng phần, bám file code của repo này: [docs/learn-english.md](docs/learn-english.md).

## Chạy cả cụm

```powershell
docker compose up -d --build
```

| Việc | Địa chỉ |
|------|---------|
| App (qua Nginx) | http://localhost:8088 |
| API Spring | http://localhost:8082 |
| Keycloak | http://localhost:8083 (`admin` / `admin`) |
| Grafana | http://localhost:3002 (`admin` / `admin`) |
| Prometheus | http://localhost:9095 |
| Jaeger | http://localhost:16687 |
| Mailpit | http://localhost:8026 |

Tài khoản học: `demo@edu.app` / `demo123`.

Profile `platform` bật Postgres, Redis, MongoDB, Kafka, mail và trace. Postgres trên host là cổng **5434**.

## Chạy local không Docker

Cần Java 21 và Maven. Dữ liệu nằm trên H2, không cần Redis/Kafka.

```powershell
cd backend
mvn spring-boot:run
```

API: http://localhost:8080

```powershell
cd frontend
npm start
```

Giao diện: http://localhost:4200

Muốn gắn hạ tầng mà vẫn chạy Spring trên máy:

```powershell
docker compose up -d postgres redis mongodb zookeeper kafka mailpit jaeger
copy .env.example .env
cd backend
mvn spring-boot:run
```

Đặt `SPRING_PROFILES_ACTIVE=platform` và các biến trong `.env.example` trước khi chạy Maven.

## API

| Method | Đường dẫn |
|--------|-----------|
| POST | `/api/auth/login`, `/api/auth/register` |
| GET | `/api/auth/me` |
| GET | `/api/vocab`, `/api/vocab/picture`, `/api/vocab/review` |
| POST | `/api/vocab/review` |
| GET | `/api/grammar`, `/api/grammar/{id}` |
| GET/POST | `/api/reading`, `/api/listening`, `/api/dictation` |
| GET | `/api/analytics` |
| GET | `/actuator/health/liveness`, `/actuator/health/readiness`, `/actuator/prometheus` |
| WS | `/ws/study?token=` |
