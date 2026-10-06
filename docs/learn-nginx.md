# Học Nginx — EDU APP English

Khi mở http://localhost:8088, trình duyệt chỉ nói chuyện với Nginx. Angular và Spring ở container khác, không public ý định đó ra ngoài — dù Compose vẫn mở thêm 4200 và 8082 để debug.

File: `infra/nginx/nginx.conf`. Image: `infra/nginx/Dockerfile`.

## 1. Ba nhánh

| URL vào Nginx | Đi tới |
|---------------|--------|
| `/api/`, `/actuator/`, `/ws/` | `http://api:8080` (Spring) |
| `/` | `http://web:80` (Angular đã build, nginx trong `frontend/nginx.conf`) |
| `/nginx-health` | Nginx tự trả `ok`, không gọi Spring |

`/ws/` bật `Upgrade` và `Connection: upgrade` để WebSocket không bị cắt thành HTTP thường.

Angular container cũng proxy `/api/` và `/ws/` sang `api:8080` (`frontend/nginx.conf`). Vì vậy http://localhost:4200 vẫn gọi được API khi chạy trong Compose. Bản `ng serve` thì không qua file này.

## 2. Trang chờ

`error_page 502 504` đổi lỗi "upstream chết" thành:

- API: JSON `SERVICE_STARTING` và header `Retry-After: 5`
- Web: HTML tự refresh sau 5 giây

502 xảy ra khi container chưa nghe cổng. Healthcheck của Compose giảm lúc này, nhưng Docker Desktop bật lại máy thì Nginx có thể dậy trước API. Trang chờ là cho khoảng đó.

## 3. Health của chính Nginx

`/nginx-health` không đụng Spring. Dockerfile của Nginx dùng URL này làm `HEALTHCHECK`. Nếu health gọi `/actuator` thì Nginx bị coi là chết mỗi lúc API restart.

## 4. Việc tự làm

Cụm đang chạy:

```powershell
curl http://localhost:8088/nginx-health
curl http://localhost:8088/api/vocab
```

Dòng hai phải là JSON từ vựng, cùng nội dung với `curl http://localhost:8082/api/vocab`.

Tiếp: [learn-redis.md](./learn-redis.md).
