# English API (BFF)

Microservice backend cho app học tiếng Anh.

## Hiện tại

API routes chạy trong **Next.js Route Handlers** tại `apps/english-web/app/api/`.

- Database: PostgreSQL `english_learning` (Prisma 7)
- Auth: JWT qua cookie + Bearer (`apps/english-web/lib/auth.ts`)
- Port dev: **3001**

## Endpoints

| Route | Mô tả |
|-------|--------|
| `POST /api/auth/login` | Đăng nhập |
| `POST /api/auth/register` | Đăng ký |
| `GET /api/vocab` | Danh sách từ vựng |
| `GET /api/vocab/picture` | Picture dictionary |
| `GET /api/vocab/review` | SRS review |
| `GET /api/grammar` | Ngữ pháp |
| `GET /api/reading` | Đọc hiểu |
| `GET /api/listening` | Nghe |
| `GET /api/dictation` | Chép chính tả |
| `GET /api/analytics` | Thống kê |

## Roadmap

Tách thành NestJS/Fastify service độc lập trong folder này khi cần scale.
