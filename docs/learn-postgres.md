# Học Postgres và H2 — EDU APP English

Dữ liệu học (user, từ, ngữ pháp, bài đọc, bài nghe, thẻ SRS) nằm ở database quan hệ. Có hai chế độ. Đừng trộn hai file dữ liệu.

## 1. Local: H2

Profile `dev` (mặc định của `mvn spring-boot:run`):

```text
jdbc:h2:file:./data/english
```

File nằm trong `backend/data/`. Xóa thư mục đó là mất user và tiến độ local.

Flyway chạy script `backend/src/main/resources/db/migration`. Hibernate `ddl-auto` là `validate`: sửa entity mà không thêm migration thì app không lên.

Console H2 khi chạy local: http://localhost:8080/h2 (JDBC URL giống cấu hình, user `sa`, mật khẩu trống).

## 2. Docker: Postgres 16

Service `postgres` trong `docker-compose.yml`:

- user / password / database: `english` / `english` / `english`
- trên máy host cổng **5434** (5433 là Postgres của app tiếng Nhật nếu cả hai cùng chạy)
- volume `postgres_data`: `docker compose down` không xóa dữ liệu; `docker compose down -v` thì xóa

Profile `platform` trỏ Flyway sang `backend/src/main/resources/db/postgresql`. Bản SQL này dùng `VARCHAR` cho enum, vì Hibernate lưu enum dạng chuỗi, không dùng kiểu ENUM của Postgres.

## 3. Bảng đáng nhớ

| Bảng | Ý nghĩa |
|------|---------|
| `users` | tài khoản, `password_hash` |
| `vocabulary`, `vocab_topics` | từ |
| `srs_cards` | một user + một nội dung, lịch SM-2 |
| `grammar_*` | chủ đề, bài, ví dụ, câu hỏi |
| `reading_*`, `listening_*` | đề và lần nộp |
| `dictation_attempts` | nghe chép |
| `study_sessions` | giây học theo ngày, unique `(user_id, study_date)` |

Entity tương ứng trong `backend/src/main/java/com/edu/english/domain`. Tên cột snake_case nằm ở annotation hoặc ở quy ước Spring, đối chiếu với file SQL khi thêm cột.

## 4. Thêm cột

1. Không sửa `V1__baseline.sql` sau khi đã chạy ở máy khác.
2. Thêm `V2__mô_tả.sql` trong **cả** `db/migration` (H2) và `db/postgresql` nếu hai bên khác cú pháp.
3. Sửa entity.
4. Chạy lại app. Flyway áp dụng V2 một lần, ghi vào `flyway_schema_history`.

## 5. Việc tự làm

Cụm Docker đang chạy:

```powershell
docker exec -it en-postgres psql -U english -d english -c "select email, role from users;"
```

Phải thấy `demo@edu.app`. Đếm từ: `select count(*) from vocabulary;`

Tiếp: [learn-docker.md](./learn-docker.md).
