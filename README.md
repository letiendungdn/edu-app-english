# EDU APP English

Ứng dụng học tiếng Anh (CEFR A1–C2).

| Thư mục | Công nghệ |
|---------|-----------|
| `backend` | Java 21, Spring Boot, Spring Security, JPA |
| `frontend` | Angular |

Dữ liệu mẫu chạy trên H2. Có thể chuyển sang PostgreSQL bằng profile `postgres`.

## Chạy backend

Cần Java 21 và Maven.

```bash
cd backend
mvn spring-boot:run
```

API: http://localhost:8080

Tài khoản mẫu: `demo@edu.app` / `demo123`

## Chạy frontend

```bash
cd frontend
npm start
```

Giao diện: http://localhost:4200

## API chính

| Method | Đường dẫn | Mô tả |
|--------|-----------|--------|
| POST | `/api/auth/login` | Đăng nhập, trả JWT |
| POST | `/api/auth/register` | Đăng ký |
| GET | `/api/vocab` | Danh sách từ vựng |
| GET | `/api/vocab/picture` | Từ điển tranh |
| GET/POST | `/api/vocab/review` | Ôn SRS (SM-2), cần đăng nhập |
| GET | `/api/grammar` | Chủ đề ngữ pháp |
| GET | `/api/reading` | Bài đọc |
| POST | `/api/reading/{id}/submit` | Nộp bài đọc |
| GET | `/api/listening` | Bài nghe |
| POST | `/api/listening/{id}/submit` | Nộp bài nghe |
| GET/POST | `/api/dictation` | Nghe chép |
| GET | `/api/analytics` | Tiến độ, cần đăng nhập |
