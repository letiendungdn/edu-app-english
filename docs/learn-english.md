# Học lập trình qua EDU APP English: từ người mới tới senior

Bộ tài liệu này dạy bạn **đọc, chạy, sửa và thiết kế** một ứng dụng web thật: app luyện IELTS viết bằng Angular (giao diện) và Spring Boot (máy chủ), kèm hạ tầng như các công ty hay dùng (Postgres, Redis, Kafka, Docker, Nginx...).

Mọi ví dụ đều trỏ vào **file có thật trong repo này**. Bạn không học lý thuyết suông: đọc một khái niệm, mở đúng file, chạy thử, sửa thử, rồi làm bài tập.

---

## 1. Bạn cần gì trước khi bắt đầu

| Thứ | Vì sao | Kiểm tra |
|-----|--------|----------|
| Biết lập trình cơ bản (biến, hàm, vòng lặp, class) bằng bất kỳ ngôn ngữ nào | Tài liệu không dạy lại cú pháp từ đầu | Viết được hàm đếm số chữ cái trong một chuỗi |
| Java 21 | Chạy backend | `java -version` |
| Maven 3.9+ | Build backend | `mvn -v` |
| Node 22 | Chạy frontend | `node -v` |
| Git | Lấy code, xem lịch sử | `git --version` |
| Docker Desktop (từ bài Docker trở đi) | Chạy cả cụm | `docker version` |
| VS Code hoặc IntelliJ | Đọc code có gợi ý | |

Chưa biết Java hay TypeScript cũng được, miễn biết một ngôn ngữ. Gặp cú pháp lạ thì tra nhanh rồi đọc tiếp. Đừng dừng lại học hết cú pháp trước.

---

## 2. Ứng dụng này làm gì (góc nhìn người dùng)

1. Đăng ký tài khoản.
2. **Onboarding**: chọn Academic hay General, band hiện tại, band mục tiêu, ngày thi, số phút học mỗi ngày.
3. Làm **bài kiểm tra đầu vào** khoảng 60 phút.
4. App sinh **lộ trình**: 4 giai đoạn, mỗi ngày một danh sách việc (ôn từ, đọc một bài, viết Task 2...).
5. Mỗi ngày vào trang "Hôm nay", bấm "Bắt đầu" từng việc. Làm xong thì việc tự được đánh dấu.
6. Writing và Speaking được AI chấm theo 4 tiêu chí IELTS.
7. Làm **thi thử**: app tính band, rồi lập lại lộ trình theo kết quả mới.

Trước khi đọc code, **hãy dùng app 15 phút**. Bạn sẽ hiểu code nhanh hơn nhiều khi đã biết nó tạo ra cái gì.

---

## 3. Chạy app lần đầu

Mở hai cửa sổ terminal.

**Terminal 1: backend**

```powershell
cd backend
mvn spring-boot:run
```

Đợi tới dòng `Started EnglishApplication`. Lần đầu Maven tải thư viện khá lâu, có thể vài phút.

**Terminal 2: frontend**

```powershell
cd frontend
npm install
npm start
```

Mở http://localhost:4200, đăng nhập `demo@edu.app` / `demo123`. Tài khoản này đã có hồ sơ IELTS và lộ trình.

> Lỗi Flyway khi khởi động backend (checksum mismatch, wrong column type) nghĩa là thư mục `backend/data` chứa database của bản cũ. Xoá thư mục đó rồi chạy lại.

---

## 4. Bản đồ repo

```text
edu-app-english/
├── backend/                         Máy chủ Java (Spring Boot)
│   ├── pom.xml                      Danh sách thư viện + cách build
│   └── src/
│       ├── main/java/com/edu/english/
│       │   ├── web/                 Controller: nhận HTTP, trả JSON
│       │   ├── service/             Nghiệp vụ: chấm bài, band, lộ trình, SRS
│       │   │   └── ai/              Gọi Claude chấm Writing/Speaking
│       │   ├── domain/              Entity: mỗi class ứng với một bảng
│       │   ├── repo/                Truy vấn database (Spring Data)
│       │   ├── security/            JWT, ai được gọi API nào
│       │   └── config/              Seed dữ liệu, Redis/Kafka/Mongo, WebSocket, thread pool
│       ├── main/resources/
│       │   ├── application.yml      Cấu hình
│       │   ├── db/migration/        Lịch sử thay đổi schema (Flyway)
│       │   ├── content/             Nội dung mẫu: bài đọc, bài nghe, đề Writing...
│       │   └── rubrics/             Tiêu chí chấm gửi cho AI
│       └── test/                    Test tự động
├── frontend/                        Giao diện Angular
│   ├── proxy.conf.json              Chuyển /api sang backend khi chạy ng serve
│   └── src/app/
│       ├── core/                    Gọi API, đăng nhập, kiểu dữ liệu, guard
│       ├── shared/                  Component dùng chung (câu hỏi, biểu đồ, đọc bài nghe)
│       └── pages/                   Từng màn hình
├── infra/                           Nginx, Prometheus, Grafana, Keycloak, Helm
├── docker-compose.yml               Dựng cả cụm bằng một lệnh
└── docs/                            Bạn đang ở đây
```

**Quy tắc vàng khi đọc một codebase lạ:** bắt đầu từ một việc người dùng làm (bấm nút), lần theo request đó qua từng lớp. Đừng đọc file theo thứ tự chữ cái.

---

## 5. Lộ trình học

Đọc theo thứ tự. Mỗi bài có phần "Việc tự làm" ba cấp: **Junior** (làm theo được là hiểu), **Mid** (phải tự nghĩ), **Senior** (phải cân nhắc đánh đổi). Lần đầu chỉ cần làm cấp Junior, lần hai quay lại làm Mid.

### Chặng 1: Một request đi từ trình duyệt tới database (2–4 tuần)

| # | Bài | Học được gì |
|---|-----|-------------|
| 1 | [Angular](./learn-angular.md) | Component, signal, template, gọi API, route, guard |
| 2 | [Spring Boot](./learn-spring.md) | Controller, service, dependency injection, transaction, xử lý lỗi |
| 3 | [Postgres, JPA, Flyway](./learn-postgres.md) | Bảng, quan hệ, entity, migration, N+1, index |
| 4 | [Đăng nhập JWT](./learn-auth.md) | Mật khẩu băm, token, filter, phân quyền |
| 5 | [Test](./learn-testing.md) | Unit test, integration test, viết code dễ test |

Hết chặng 1 bạn tự thêm được một tính năng nhỏ trọn vẹn: một bảng, một API, một màn hình, có test.

### Chặng 2: Nghiệp vụ thật (2–3 tuần)

| # | Bài | Học được gì |
|---|-----|-------------|
| 6 | [Các tính năng IELTS](./learn-ielts-features.md) | Thiết kế ngân hàng câu hỏi, chấm điểm, sinh lộ trình, gọi AI chạy nền |

Đây là bài quan trọng nhất để lên mid: cách biến yêu cầu nghiệp vụ mơ hồ thành code rõ ràng, test được.

### Chặng 3: Hạ tầng và vận hành (3–5 tuần)

| # | Bài | Học được gì |
|---|-----|-------------|
| 7 | [Docker](./learn-docker.md) | Image, container, volume, network, compose, healthcheck |
| 8 | [Nginx](./learn-nginx.md) | Reverse proxy, cùng origin, WebSocket, trang chờ |
| 9 | [Redis](./learn-redis.md) | Cache, TTL, cache invalidation, khi nào không nên cache |
| 10 | [MongoDB](./learn-mongodb.md) | Document database, audit log, ghi bất đồng bộ |
| 11 | [Kafka](./learn-kafka.md) | Sự kiện, producer, consumer, gửi sau commit, at-least-once |
| 12 | [WebSocket](./learn-websocket.md) | Kết nối hai chiều, xác thực, không tin client |
| 13 | [Quan sát hệ thống](./learn-observability.md) | Health check, metric, trace, log |
| 14 | [Keycloak và Mailpit](./learn-keycloak-mail.md) | SSO/OIDC, gửi mail: có trong cụm nhưng chưa dùng |

### Chặng 4: Chọn công nghệ

| # | Bài | Học được gì |
|---|-----|-------------|
| 15 | [Angular hay React, Spring hay NestJS](./learn-choosing-stack.md) | So sánh có ví dụ code, khi nào dùng cái nào, áp vào app Nihongo và app English, cách viết ADR |

Đọc sau khi xong chặng 1 và 2, lúc đã đủ hiểu để so sánh.

### Đặc tả sản phẩm

[IELTS_ROADMAP_SPEC.md](./IELTS_ROADMAP_SPEC.md) mô tả app **nên** làm gì. Mục 0 ghi phần nào đã làm, phần nào chưa. Đọc nó như đọc ticket ở công ty: so sánh với code và tìm chỗ lệch.

---

## 6. Junior, mid, senior khác nhau ở đâu

Không phải ở số công nghệ biết. Khác ở **câu hỏi bạn tự đặt ra** khi viết code:

| Cấp | Câu hỏi thường gặp | Ví dụ trong repo |
|-----|-------------------|------------------|
| Junior | "Làm sao cho nó chạy?" | Viết được API trả danh sách bài đọc |
| Mid | "Nó sai trong trường hợp nào? Ai bảo trì nó?" | Chấm câu điền từ phải chịu được viết hoa, thừa khoảng trắng, đáp án thay thế (`AnswerGrader`) |
| Senior | "Hệ thống chịu tải, lỗi, thay đổi thế nào? Đánh đổi gì?" | Gọi AI 30 giây nên chạy nền sau commit, không giữ request và kết nối DB (`GradingWorker`); Kafka chết không được làm chậm người dùng (`PlatformGateway`) |

Mỗi bài trong bộ này có mục **"Góc nhìn senior"** chỉ ra các đánh đổi kiểu đó. Đó là phần đáng đọc lại nhiều lần nhất.

---

## 7. Cách học hiệu quả với repo này

1. **Chạy trước, đọc sau.** Mỗi khái niệm, tìm cách nhìn thấy nó chạy (log, DevTools, câu SQL).
2. **Đặt breakpoint.** Trong IntelliJ/VS Code, chạy backend ở chế độ Debug, đặt breakpoint trong controller rồi bấm nút trên giao diện. Nhìn biến từng bước dạy nhanh hơn đọc 10 trang.
3. **Sửa rồi làm hỏng.** Đổi một dòng, đoán điều gì xảy ra, chạy để kiểm chứng. Đoán sai là lúc bạn học nhiều nhất.
4. **Chạy test sau mỗi thay đổi:** `cd backend && mvn test`. Test đỏ là tin tốt: nó bắt lỗi trước người dùng.
5. **Đọc git log.** `git log --oneline` rồi `git show <mã>` để xem một tính năng được thêm thế nào.
6. **Ghi chú bằng lời của bạn.** Sau mỗi bài, viết 5 dòng giải thích lại cho một người chưa biết gì. Không viết được nghĩa là chưa hiểu.

---

## 8. Một request thật, nhìn từ trên cao

Bạn mở trang "Hôm nay" khi đã đăng nhập:

```text
Trình duyệt (Angular, pages/home.component.ts)
  │  GET /api/roadmap/today   + header Authorization: Bearer <token>
  ▼
ng serve proxy (dev) hoặc Nginx (Docker)          → bài 1, bài 8
  ▼
Spring Boot
  ├─ JwtAuthFilter: đọc token, biết bạn là ai        → bài 4
  ├─ SecurityConfig: URL này cần đăng nhập không?    → bài 4
  ├─ RoadmapController.today()                        → bài 2
  └─ RoadmapService.today()
        ├─ đọc ielts_profiles, roadmaps, roadmap_tasks → bài 3
        ├─ chọn bài đọc/bài nghe hợp trình độ           → bài 6
        └─ BandService.summary(): band từng kỹ năng     → bài 6
  ▼
JSON → Angular vẽ danh sách việc và band
```

Hết bộ tài liệu, bạn giải thích được từng mũi tên trong sơ đồ này, kể cả khi nó hỏng.
