# english-web — Học tiếng Anh

Frontend Next.js cho app học tiếng Anh (CEFR A1–C2). **Chỉ UI** — mọi API đi qua `api-gateway`.

## Chạy dev

```bash
# Terminal 1 — gateway (cần ENGLISH_DATABASE_URL trong services/.env)
npm run dev:gateway

# Terminal 2 — frontend
cp .env.example .env   # API_URL=http://localhost:3000
npm run dev            # http://localhost:3001
```

## API routing

Browser gọi `/api/vocab` → `next.config.ts` rewrite → `http://localhost:3000/api/english/vocab`

Xem đầy đủ routes trong [docs/system-design.md](../../docs/system-design.md).

## Database (seed / schema)

Schema nằm ở `packages/prisma-english/`, không còn trong app này:

```bash
npm run db:push -w @edu/prisma-english
npm run seed -w @edu/prisma-english
```
