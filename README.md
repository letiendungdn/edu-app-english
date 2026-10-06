# EDU APP English: luyện IELTS theo lộ trình

Người học đặt band mục tiêu và ngày thi, làm bài kiểm tra đầu vào, rồi học theo danh sách việc mỗi ngày. Lộ trình tự điều chỉnh sau mỗi bài thi thử. Writing và Speaking được AI (Claude) chấm theo tiêu chí IELTS công khai.

| Lớp | Công nghệ |
|-----|-----------|
| Web | Angular 19 (standalone, signals) |
| API | Java 21, Spring Boot 3.4, Spring Security, JWT, WebSocket `/ws/study` |
| Dữ liệu | PostgreSQL 16 + Flyway. Chạy local không Docker thì dùng H2 ở chế độ PostgreSQL, chung một bộ migration |
| Chấm AI | Claude qua SDK `anthropic-java`, model mặc định `claude-opus-5-5` |
| Hạ tầng (profile `platform`) | Redis (cache), MongoDB (audit), Kafka (sự kiện), Mailpit, Keycloak (chưa dùng để đăng nhập) |
| Quan sát | Actuator, Prometheus, Grafana, Jaeger, Alertmanager |
| Triển khai | Docker Compose, Helm `infra/helm/english`, GitHub Actions |

Đặc tả sản phẩm: [docs/IELTS_ROADMAP_SPEC.md](docs/IELTS_ROADMAP_SPEC.md). Học từng phần của codebase: [docs/learn-english.md](docs/learn-english.md).

## Tính năng

- **Onboarding**: Academic/General, band hiện tại (hoặc "chưa biết"), band mục tiêu, ngày thi, phút học mỗi ngày.
- **Bài kiểm tra đầu vào** (~60 phút): 2 phần Listening, 1 bài Reading, 1 bài Writing Task 2. Kết quả thành band hiện tại.
- **Lộ trình**: 4 giai đoạn (Nền tảng → Luyện kỹ năng → Luyện đề → Ôn cuối), chia theo ngày. Kỹ năng yếu được nhiều thời gian hơn. App cảnh báo khi mục tiêu khó kịp. Lộ trình sinh lại sau mỗi bài thi thử, khi sửa hồ sơ hoặc khi bỏ lỡ hơn 3 việc.
- **Hôm nay học gì**: danh sách việc kèm link tới đúng bài phù hợp trình độ; tự đánh dấu xong khi làm bài.
- **Reading / Listening**: ngân hàng câu hỏi chung, đủ 17 dạng câu hỏi IELTS. Chấm theo cách thi thật (giới hạn số từ, đáp án thay thế, TRUE ≠ YES). Bài từ 10 câu trở lên được quy đổi ra band.
- **Thi thử**: 40 câu Listening, 40 câu Reading, Writing Task 1 và 2. Đếm giờ phía server, lưu tự động mỗi 30 giây, hết giờ tự nộp.
- **Writing**: 14 đề (Task 1 có biểu đồ vẽ bằng SVG), đếm từ, AI chấm 4 tiêu chí, sửa lỗi kèm giải thích tiếng Việt.
- **Speaking**: 17 câu hỏi Part 1–3, ghi âm, trình duyệt chuyển giọng nói thành chữ, AI chấm 3 tiêu chí. Phát âm chưa chấm được vì AI chỉ nhận văn bản.
- Từ vựng (SRS), ngữ pháp, nghe chép, thống kê tiến độ: giữ từ bản trước.

Toàn bộ nội dung đề do nhóm tự biên soạn theo format IELTS, **không** chép từ sách Cambridge hay trang luyện thi.

## Chạy local (không Docker)

Cần Java 21, Maven, Node 22.

```powershell
cd backend
mvn spring-boot:run
```

```powershell
cd frontend
npm install
npm start
```

Mở http://localhost:4200. Tài khoản mẫu: `demo@edu.app` / `demo123` (đã có hồ sơ IELTS và lộ trình).

**Bật chấm AI**: đặt biến môi trường trước khi chạy Maven:

```powershell
$env:APP_AI_API_KEY = "sk-ant-..."
```

Không có key thì bài Writing/Speaking vẫn được lưu và báo "AI chưa được cấu hình", có thể chấm lại sau khi bật.

> **Nâng cấp từ bản trước:** database H2 cũ trong `backend/data` không tương thích với bộ migration mới. Gặp lỗi Flyway khi khởi động thì xoá thư mục `backend/data` và chạy lại.

## Chạy cả cụm bằng Docker

```powershell
copy .env.example .env   # điền APP_AI_API_KEY nếu muốn bật chấm AI
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

File ghi âm Speaking lưu trong volume `uploads_data`.

## Biến môi trường

| Biến | Mặc định | Ý nghĩa |
|------|----------|---------|
| `APP_JWT_SECRET` / `JWT_SECRET` | có giá trị dev | Tối thiểu 32 ký tự. Bắt buộc đặt ở môi trường thật |
| `APP_AI_API_KEY` | trống | Key Claude API. Trống thì tắt chấm AI |
| `APP_AI_MODEL` | `claude-opus-5-5` | Model chấm bài |
| `APP_AI_DAILY_LIMIT` | `10` | Số bài AI chấm mỗi người mỗi ngày |
| `APP_TIMEZONE` | `Asia/Ho_Chi_Minh` | "Hôm nay" của người học: streak, giờ học, lộ trình |
| `APP_STORAGE_DIR` | `./data/uploads` | Thư mục lưu file ghi âm |

## API

| Method | Đường dẫn | Ghi chú |
|--------|-----------|---------|
| POST | `/api/auth/login`, `/api/auth/register` | |
| GET/PUT | `/api/ielts/profile` | 404 = chưa onboarding. PUT sinh lại lộ trình |
| GET | `/api/ielts/bands`, `/api/ielts/ai-status` | |
| GET | `/api/roadmap`, `/api/roadmap/today` | |
| POST | `/api/roadmap/generate` | Sinh lại từ hôm nay |
| PATCH | `/api/roadmap/tasks/{id}` | `{status: TODO\|DONE\|SKIPPED}` |
| GET | `/api/tests` | Danh sách bài thi |
| POST | `/api/tests/{id}/attempts`, `/api/tests/placement/attempts` | Bắt đầu hoặc mở lại bài đang làm |
| GET/PATCH | `/api/tests/attempts/{id}` | PATCH = lưu tự động |
| POST | `/api/tests/attempts/{id}/submit` | |
| GET | `/api/tests/attempts/{id}/result`, `/api/tests/attempts` | |
| GET | `/api/writing/prompts[/{id}]` | |
| POST | `/api/writing/submissions` | Trả 202, chấm nền |
| GET | `/api/writing/submissions[/{id}]` | |
| POST | `/api/writing/submissions/{id}/regrade` | Chỉ bài `FAILED` |
| GET | `/api/speaking/prompts[/{id}]` | |
| POST | `/api/speaking/submissions` | multipart: `promptId`, `transcript`, `durationSec`, `audio` |
| GET | `/api/speaking/submissions[/{id}]`, `.../{id}/audio` | |
| GET/POST | `/api/reading`, `/api/reading/{id}`, `/api/reading/{id}/submit` | Câu hỏi trả theo `groups` |
| GET/POST | `/api/listening`, `/api/listening/{id}`, `/api/listening/{id}/submit` | |
| GET/POST | `/api/vocab`, `/api/vocab/picture`, `/api/vocab/review`, `/api/grammar`, `/api/dictation`, `/api/analytics` | Như bản trước |
| GET | `/actuator/health/liveness`, `/actuator/health/readiness` | |
| WS | `/ws/study` | Tin đầu tiên: `{"type":"auth","token":"..."}` |

## Test

```powershell
cd backend
mvn verify
```

39 test, gồm: chấm câu trả lời, quy đổi và làm tròn band, sinh lộ trình, SM-2, migration dữ liệu câu hỏi cũ, và luồng tích hợp (onboarding, lộ trình, bài đọc, placement test, nộp Writing khi tắt AI).
