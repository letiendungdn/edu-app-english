# Bài 7: Docker và Docker Compose

**Mục tiêu:** hiểu image, container, volume, network; đọc được `Dockerfile` và `docker-compose.yml` của repo; tự dựng và gỡ lỗi cả cụm 15 dịch vụ.

**File:** `backend/Dockerfile`, `frontend/Dockerfile`, `infra/nginx/Dockerfile`, `docker-compose.yml`, `.env.example`.

---

## 1. Docker giải quyết vấn đề gì

"Máy em chạy được mà!" Máy bạn có Java 21, máy đồng nghiệp có Java 17. Máy bạn có Postgres 16, server có Postgres 14. Cài Kafka trên Windows là một buổi chiều mất trắng.

Docker đóng gói **ứng dụng cùng mọi thứ nó cần** (hệ điều hành rút gọn, runtime, thư viện) thành một khối chạy giống hệt nhau ở mọi nơi.

| Khái niệm | So sánh đời thường | Trong repo |
|-----------|-------------------|-----------|
| **Image** | Bản thiết kế, khuôn bánh (chỉ đọc) | `postgres:16-alpine`, image build từ `backend/Dockerfile` |
| **Container** | Cái bánh làm từ khuôn, đang chạy | `en-api`, `en-postgres` |
| **Volume** | Ổ cứng gắn ngoài, còn lại khi container bị xoá | `postgres_data`, `uploads_data` |
| **Network** | Mạng LAN riêng giữa các container | `english-app_default` |
| **Registry** | Kho image (Docker Hub, quay.io) | nơi tải `redis:7-alpine` |

**Container khác máy ảo:** máy ảo giả lập cả phần cứng và chạy hệ điều hành đầy đủ (nặng, khởi động hàng phút). Container dùng chung nhân hệ điều hành của máy chủ, chỉ cô lập tiến trình (nhẹ, khởi động trong giây).

---

## 2. Đọc `backend/Dockerfile`

```dockerfile
FROM maven:3.9-eclipse-temurin-21 AS build      # giai đoạn 1: có Maven + JDK để BUILD
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn -B -DskipTests package                  # ra file target/english-api-0.1.0.jar

FROM eclipse-temurin:21-jre                      # giai đoạn 2: chỉ có JRE để CHẠY
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*
COPY --from=build /app/target/english-api-*.jar /app/app.jar   # chỉ lấy file jar từ giai đoạn 1
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
```

**Multi-stage build:** giai đoạn 1 nặng (Maven, JDK, mã nguồn, thư viện tải về). Giai đoạn 2 chỉ chép **file jar** sang một image nhẹ. Image cuối nhỏ hơn nhiều và không chứa mã nguồn hay công cụ build, nên cũng ít thứ cho kẻ tấn công lợi dụng hơn.

`curl` được cài thêm vì healthcheck trong compose dùng nó.

**Cache theo tầng:** mỗi dòng `RUN`/`COPY` là một tầng (layer). Docker chỉ build lại từ tầng đầu tiên có thay đổi. Cải tiến bạn có thể làm (bài tập Mid): chép `pom.xml` rồi chạy `mvn dependency:go-offline` **trước** khi chép `src`. Sửa code thì thư viện không phải tải lại.

### `frontend/Dockerfile`

```dockerfile
FROM node:22-alpine AS build
COPY package.json package-lock.json ./
RUN npm ci                        # cài đúng phiên bản trong lock file
COPY . .
RUN npm run build                 # ra dist/frontend/browser: HTML, JS, CSS tĩnh

FROM nginx:1.27-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist/frontend/browser /usr/share/nginx/html
```

Angular sau khi build chỉ còn là **file tĩnh**, không cần Node để chạy, nên Nginx phục vụ thẳng.

Bản trước có thêm `ARG API_BASE` và một lệnh `sed` sửa URL API trong source lúc build. Giờ frontend luôn gọi `/api` (cùng origin, xem bài 1), nên image không phụ thuộc môi trường: cùng một image chạy được ở mọi nơi. Đây là nguyên tắc **build một lần, chạy nhiều nơi**.

`npm ci` khác `npm install`: cài **chính xác** theo `package-lock.json` và báo lỗi nếu lệch. Build trên CI và trong Docker luôn dùng `npm ci`.

---

## 3. Đọc `docker-compose.yml`

Compose khai báo **nhiều container cùng lúc** và quan hệ giữa chúng. Một dịch vụ tiêu biểu:

```yaml
  api:
    build: ./backend                       # build image từ backend/Dockerfile
    container_name: en-api
    ports:
      - '8082:8080'                        # cổng MÁY:cổng CONTAINER
    environment:
      SPRING_PROFILES_ACTIVE: platform
      ENGLISH_DATABASE_URL: jdbc:postgresql://postgres:5432/english   # "postgres" là TÊN DỊCH VỤ
      JWT_SECRET: ${JWT_SECRET:-edu-english-dev-secret-key-please-change-32}
      APP_AI_API_KEY: ${APP_AI_API_KEY:-}  # đọc từ file .env hoặc biến môi trường máy
      APP_STORAGE_DIR: /app/uploads
    volumes:
      - uploads_data:/app/uploads          # file ghi âm Speaking còn lại khi container bị xoá
    healthcheck:
      test: ['CMD-SHELL', 'curl -fsS http://127.0.0.1:8080/actuator/health/liveness || exit 1']
      start_period: 90s                    # Spring khởi động chậm, chưa tính lỗi trong 90 giây đầu
    depends_on:
      postgres:
        condition: service_healthy         # đợi Postgres SẴN SÀNG, không chỉ "đã chạy"
```

### Mạng: gọi nhau bằng tên dịch vụ

Trong mạng compose, container `api` gọi Postgres bằng địa chỉ `postgres:5432`. Docker có DNS nội bộ đổi tên dịch vụ thành IP. **Từ máy của bạn** (ngoài Docker) thì gọi qua cổng đã map: `localhost:5434`.

```text
Máy bạn                         Mạng Docker
localhost:5434 ─────────────►  postgres:5432
localhost:8082 ─────────────►  api:8080
localhost:8088 ─────────────►  nginx:80 ──► api:8080, web:80
```

Đây là nguồn nhầm lẫn số một: trong container mà dùng `localhost` là trỏ vào **chính container đó**, không phải máy bạn.

### Vì sao cổng lạ (5434, 6380, 27018...)

Để chạy song song với app tiếng Nhật (dùng 5433, 6379, 27017...) mà không đụng cổng. Tên container có tiền tố `en-` cũng vì lý do đó.

### `depends_on` + healthcheck

`depends_on` không có `condition` chỉ đợi container **khởi động**, không đợi nó **sẵn sàng**. Postgres khởi động mất vài giây mới nhận kết nối, nên Spring có thể kết nối hụt rồi chết. `condition: service_healthy` đợi healthcheck báo xanh.

Thứ tự trong repo: `postgres, redis, mongodb, kafka` khỏe → `api` khỏe → `web` → `nginx`.

### Biến môi trường và file `.env`

`${APP_AI_API_KEY:-}` lấy từ biến môi trường hoặc file `.env` cạnh `docker-compose.yml`, không có thì để trống. File `.env` nằm trong `.gitignore`, nên bí mật không lên git. `.env.example` là mẫu có commit, không chứa bí mật thật.

---

## 4. Lệnh dùng hằng ngày

Chạy ở thư mục gốc repo:

```powershell
copy .env.example .env                 # lần đầu
docker compose up -d --build           # build và chạy nền (-d = detached)
docker compose ps                      # trạng thái, cột STATUS phải có (healthy)
docker compose logs -f api             # xem log api liên tục (Ctrl+C để thoát)
docker compose logs api --tail 100     # 100 dòng cuối
docker compose restart api             # khởi động lại một dịch vụ
docker compose up -d --build api       # build lại chỉ api sau khi sửa code
docker compose stop                    # dừng, giữ container
docker compose down                    # xoá container, GIỮ volume (dữ liệu còn)
docker compose down -v                 # xoá luôn volume: MẤT DỮ LIỆU
docker exec -it en-postgres psql -U english -d english    # mở shell bên trong container
```

Chỉ chạy hạ tầng, còn Spring chạy trên máy để debug cho dễ:

```powershell
docker compose up -d postgres redis mongodb zookeeper kafka mailpit jaeger
# đặt các biến trong .env.example vào môi trường, rồi:
cd backend
mvn spring-boot:run
```

---

## 5. Bảng cổng

| Cổng máy | Dịch vụ | Dùng để |
|----------|---------|---------|
| 8088 | Nginx | **Cửa chính của app** |
| 8082 | Spring | Gọi API trực tiếp, xem `/actuator/prometheus` |
| 4200 | Angular (Nginx trong container) | Debug giao diện bỏ qua Nginx chính |
| 5434 | Postgres | Công cụ SQL (DBeaver, psql) |
| 6380 | Redis | `redis-cli -p 6380` |
| 27018 | MongoDB | MongoDB Compass |
| 9094 | Kafka | Công cụ Kafka ngoài Docker |
| 8083 | Keycloak | Trang quản trị |
| 3002 | Grafana | Dashboard |
| 9095 | Prometheus | Truy vấn metric |
| 16687 | Jaeger | Xem trace |
| 8026 | Mailpit | Hộp thư thử |

---

## 6. Lỗi hay gặp

| Triệu chứng | Nguyên nhân và cách xử lý |
|-------------|---------------------------|
| `en-api` mãi `starting` rồi `unhealthy` | `docker compose logs api --tail 200`, tìm `Caused by`. Thường là chưa kết nối được Postgres hoặc Flyway lỗi |
| `port is already allocated` | Cổng đang bị chương trình khác dùng. `netstat -ano \| findstr :8088` để tìm |
| Sửa code mà không thấy thay đổi | Quên `--build`. Compose dùng lại image cũ |
| Mở 8088 thấy trang "Hệ thống đang khởi động" | API hoặc web chưa khỏe, Nginx trả trang chờ (bài 8). Đợi 1–2 phút |
| Mất dữ liệu sau khi khởi động lại | Đã chạy `down -v`, hoặc lưu file ở chỗ không gắn volume |
| Docker Desktop báo thiếu bộ nhớ | 15 container ngốn khoảng 4–6 GB RAM. Chỉ bật dịch vụ cần, hoặc tăng RAM trong Settings |

---

## 7. Việc tự làm

**Junior**
1. Chạy cả cụm, mở http://localhost:8088, đăng nhập demo, làm một bài đọc.
2. `docker compose ps`: dịch vụ nào **không có** healthcheck? (gợi ý: jaeger, grafana...)
3. `docker exec -it en-postgres psql -U english -d english -c "select count(*) from questions;"`

**Mid**
4. Tối ưu `backend/Dockerfile` để sửa code Java không phải tải lại thư viện Maven. Đo thời gian build lần hai trước và sau.
5. Image backend đang chạy bằng user `root`. Thêm user thường (`USER app`) và kiểm tra app vẫn ghi được vào `/app/uploads`.
6. Viết `docker-compose.override.yml` chỉ chạy `postgres` + `api` + `web` + `nginx` (bỏ Kafka, Mongo...) cho máy yếu. Spring phải chạy được với profile nào?

**Senior**
7. `JWT_SECRET` có giá trị mặc định trong compose. Đổi sao cho compose **từ chối chạy** nếu thiếu secret ở môi trường không phải dev (gợi ý: cú pháp `${VAR:?thông báo}`). Cân nhắc trải nghiệm của người mới clone repo.
8. Helm chart ở `infra/helm/english` mới có api và web, không có Postgres, Redis... Phác thảo cách đưa app lên Kubernetes thật: database tự quản hay dịch vụ cloud (RDS, Cloud SQL)? file ghi âm lưu đâu khi có 3 bản api chạy song song (volume của một pod thì pod khác không thấy)?

---

## 8. Góc nhìn senior

- **Image bất biến, cấu hình qua biến môi trường.** Cùng một image chạy ở dev, staging, production, chỉ khác biến môi trường. Bản cũ dùng `sed` sửa source lúc build là vi phạm nguyên tắc này.
- **Trạng thái nằm ngoài container.** Container có thể bị xoá và tạo lại bất cứ lúc nào. Database, file upload phải nằm trong volume hoặc dịch vụ ngoài. Bản trước lưu file ghi âm trong container nên sẽ mất sau mỗi lần deploy, giờ đã gắn volume `uploads_data`.
- **"Đang chạy" khác "sẵn sàng".** Healthcheck, `start_period`, `condition: service_healthy` là cách nói cho hệ thống biết sự khác nhau đó. Thiếu chúng thì khởi động cụm như chơi xổ số.
- **Cụm 15 container là để học, không phải để chạy một app nhỏ.** Ngoài đời, app quy mô này chỉ cần Postgres + api + web. Mỗi thành phần thêm vào là thêm một thứ phải giám sát và vá lỗi. Biết khi nào **không** thêm công nghệ cũng là kỹ năng senior.

Tiếp theo: [Bài 8: Nginx](./learn-nginx.md).
