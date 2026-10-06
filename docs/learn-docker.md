# Học Docker — EDU APP English

Một file `docker-compose.yml` ở gốc repo dựng API Java, web Angular và hạ tầng. Không cần cài Postgres hay Kafka trên Windows.

## 1. Image, container, volume

| Khái niệm | Trong repo này |
|-----------|----------------|
| Image | `eclipse-temurin` + JAR (`backend/Dockerfile`), `nginx` + bản build Angular (`frontend/Dockerfile`), image sẵn `postgres:16-alpine`, `redis:7-alpine`, … |
| Container | tên `en-api`, `en-web`, `en-nginx`, `en-postgres`, … Tiền tố `en-` để không đụng container `edu-*` của app tiếng Nhật. |
| Volume | `postgres_data`, `postgres_keycloak_data`, `mongodb_data` |

`docker compose down` xóa container, giữ volume. Thêm `-v` thì xóa luôn dữ liệu.

## 2. Lệnh dùng hằng ngày

Chạy ở thư mục `edu-app-english`:

```powershell
docker compose up -d --build
docker compose ps
docker compose logs -f api
docker compose stop
docker compose down
```

Chỉ hạ tầng, Spring vẫn chạy bằng Maven trên máy:

```powershell
docker compose up -d postgres redis mongodb zookeeper kafka mailpit jaeger
```

Rồi đặt `SPRING_PROFILES_ACTIVE=platform` và biến trong `.env.example`. Host thì cổng là 5434, 6380, 27018, 9094, không phải cổng nội bộ 5432 / 6379.

## 3. Service nào phụ thuộc service nào

`api` chờ Postgres, Redis, Mongo, Kafka healthy rồi mới được coi là sống. Health của API là `GET /actuator/health/liveness` (process đã nghe cổng, không kiểm tra hết dependency).

`web` chờ `api` healthy, vì lúc build Angular đã trỏ API cùng host qua Nginx, và Compose vẫn xếp web sau API.

`nginx` chờ cả `api` và `web` healthy. Trước đó cổng 8088 chưa đưa traffic vào process chết.

Zookeeper chỉ tồn tại vì Kafka image `confluentinc/cp-kafka:7.6.1` trong file này dùng Zookeeper.

## 4. Cổng trên máy bạn

| Cổng | Việc |
|------|------|
| 8088 | Nginx, cửa chính của app |
| 8082 | Spring trực tiếp (bỏ qua Nginx) |
| 4200 | Angular container trực tiếp |
| 5434 | Postgres |
| 6380 | Redis |
| 27018 | MongoDB |
| 9094 | Kafka từ máy host |
| 8083 | Keycloak |
| 3002 | Grafana |
| 9095 | Prometheus |
| 16687 | Jaeger UI |
| 8026 | Mailpit |

## 5. Việc tự làm

```powershell
docker compose ps
```

Cột trạng thái của `en-api` phải là healthy. Nếu `starting` lâu, xem:

```powershell
docker compose logs api --tail 80
```

Lỗi thường gặp: profile `platform` không nối được Postgres, hoặc build Maven trong image thiếu mạng.

Tiếp: [learn-nginx.md](./learn-nginx.md).
