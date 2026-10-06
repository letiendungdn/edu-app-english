# Bài 8: Nginx, cổng vào của hệ thống

**Mục tiêu:** hiểu reverse proxy, vì sao trình duyệt chỉ cần biết một địa chỉ, cách WebSocket đi qua proxy, và cách giấu những thứ không nên công khai.

**File:** `infra/nginx/nginx.conf` (Nginx chính, cổng 8088), `infra/nginx/Dockerfile`, `frontend/nginx.conf` (Nginx bên trong container web).

---

## 1. Reverse proxy là gì

Không có proxy thì trình duyệt phải biết hai địa chỉ: giao diện ở `:4200`, API ở `:8082`. Hai origin khác nhau nên phải cấu hình CORS, và lộ ra ngoài cấu trúc bên trong hệ thống.

**Reverse proxy** đứng trước mọi thứ, nhận **mọi** request rồi chuyển tiếp tới đúng chỗ:

```text
Trình duyệt ──► http://localhost:8088 (Nginx)
                    ├─ /api/...             ──► api:8080   (Spring)
                    ├─ /ws/...              ──► api:8080   (WebSocket)
                    ├─ /actuator/health     ──► api:8080
                    ├─ /nginx-health        ──► Nginx tự trả "ok"
                    └─ /...                 ──► web:80     (file Angular)
```

Lợi ích:
- **Cùng origin**: không cần CORS, cookie hoạt động tự nhiên.
- **Một cửa**: bảo mật, giới hạn kích thước upload, HTTPS, nén... cấu hình ở một chỗ.
- **Giấu bên trong**: người ngoài không biết có bao nhiêu dịch vụ, chạy ở cổng nào.
- **Mở rộng**: muốn chạy 3 bản api thì Nginx chia tải giữa chúng (load balancing).

"Forward proxy" (proxy công ty, VPN) đứng phía **người dùng**. "Reverse proxy" đứng phía **server**. Phỏng vấn hay hỏi phân biệt hai cái này.

---

## 2. Đọc `infra/nginx/nginx.conf`

```nginx
server {
    listen 80;
    client_max_body_size 10m;                   # body tối đa mặc định cho mọi location

    location /api/ {
        client_max_body_size 12m;               # riêng API: cho phép upload ghi âm Speaking (tối đa 10 MB + form)
        proxy_pass http://api:8080;             # chuyển tiếp, giữ nguyên đường dẫn /api/...
        proxy_http_version 1.1;
        proxy_set_header Host $host;            # cho Spring biết tên miền gốc người dùng gõ
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;   # IP thật của người dùng
        proxy_set_header X-Forwarded-Proto $scheme;                    # http hay https
        error_page 502 504 = @api_starting;     # api chưa sẵn sàng → trang chờ thay vì lỗi trắng
    }
```

**Header `X-Forwarded-*`:** khi đi qua proxy, Spring thấy mọi request đến từ IP của Nginx. Muốn biết IP thật của người dùng (để ghi log hay giới hạn đăng nhập sai) thì đọc `X-Forwarded-For`. Lưu ý: header này **giả được** nếu Spring nhận request không qua Nginx, nên chỉ tin nó khi chắc chắn mọi request đều đi qua proxy.

### `proxy_pass` có và không có dấu `/` cuối

```nginx
proxy_pass http://api:8080;        # /api/reading → http://api:8080/api/reading   (giữ nguyên)
proxy_pass http://api:8080/;       # /api/reading → http://api:8080/reading       (cắt bỏ /api/)
```

Một dấu `/` đổi hẳn hành vi. Đây là nguồn lỗi 404 khó hiểu kinh điển khi cấu hình Nginx.

### WebSocket

```nginx
    location /ws/ {
        proxy_pass http://api:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }
```

WebSocket bắt đầu bằng một request HTTP có header `Upgrade: websocket` để "nâng cấp" kết nối. Nginx mặc định **bỏ** header này khi chuyển tiếp, nên phải đặt lại tường minh. Thiếu hai dòng `Upgrade` và `Connection` thì WebSocket không bao giờ kết nối được.

> **Bẫy origin:** Nginx đặt `Host` là `localhost` (không kèm cổng), còn trình duyệt gửi `Origin: http://localhost:8088`. Spring so hai giá trị này để chống kết nối từ trang lạ, thấy khác nhau nên từ chối. Vì vậy `application.yml` liệt kê rõ `app.ws-origins` gồm cả `http://localhost:8088` (bài 12).

### Chỉ công khai `health`

```nginx
    # Chỉ health ra ngoài. /actuator/prometheus để Prometheus đọc trong mạng Docker, không công khai số liệu.
    location /actuator/health {
        proxy_pass http://api:8080;
        ...
    }
```

Bản trước chuyển tiếp toàn bộ `/actuator/`. Trong đó `/actuator/prometheus` lộ ra: danh sách mọi URL API, số request từng URL, bộ nhớ, phiên bản thư viện. Kẻ tấn công dùng những thông tin đó để dò điểm yếu. Prometheus vẫn đọc được vì nó gọi thẳng `api:8080` **trong mạng Docker**, không đi qua Nginx.

Nguyên tắc: **mặc định đóng, chỉ mở thứ cần.**

### Trang chờ khi dịch vụ chưa sẵn sàng

```nginx
    location @api_starting {
        default_type application/json;
        add_header Retry-After 5 always;
        return 503 '{"error":"SERVICE_STARTING","message":"Máy chủ đang khởi động, vui lòng thử lại sau ít giây."}';
    }
```

Spring khởi động mất 30–90 giây. Trong lúc đó Nginx kết nối tới `api:8080` thất bại, lẽ ra trả `502 Bad Gateway` trắng trơn. `error_page 502 504 = @api_starting` đổi thành một JSON có nghĩa, kèm `Retry-After` để client biết bao lâu nữa thử lại. Với trang web thì trả HTML tự tải lại sau 5 giây.

`@api_starting` là **named location**: không truy cập trực tiếp từ URL được, chỉ dùng nội bộ.

### Health của chính Nginx

```nginx
    location = /nginx-health {
        access_log off;
        return 200 "ok\n";
    }
```

`infra/nginx/Dockerfile` dùng URL này cho `HEALTHCHECK`. Nếu healthcheck của Nginx gọi `/actuator/health` của Spring, thì mỗi lần api khởi động lại Nginx cũng bị đánh dấu chết, kéo theo cả hệ thống. **Healthcheck của một thành phần chỉ nên kiểm tra chính nó.**

`location =` là khớp **chính xác**, nhanh hơn khớp tiền tố.

---

## 3. Hai lớp Nginx

Container `web` (`frontend/nginx.conf`) cũng là một Nginx:

```nginx
  location / {
    try_files $uri $uri/ /index.html;
  }
```

**`try_files` cho single-page app:** người dùng tải lại trang `/roadmap`. Trên đĩa không có file `roadmap`, Nginx thử lần lượt `$uri`, `$uri/`, cuối cùng trả `index.html`. Angular khởi động rồi router đọc URL và hiện đúng trang lộ trình. Thiếu dòng này thì tải lại bất kỳ trang nào khác trang chủ đều ra 404.

Nginx của `web` cũng chuyển tiếp `/api/` và `/ws/`, nên mở thẳng http://localhost:4200 trong Docker vẫn chạy. Đường đi chính vẫn là `Nginx chính → web`.

---

## 4. Thử bằng tay

```powershell
curl http://localhost:8088/nginx-health                 # ok
curl http://localhost:8088/api/tests                    # JSON danh sách bài thi
curl http://localhost:8088/actuator/health/liveness     # {"status":"UP"}
curl -i http://localhost:8088/actuator/prometheus       # KHÔNG phải metric (rơi vào location /, trả trang Angular)
curl http://localhost:8082/actuator/prometheus | more   # gọi thẳng Spring thì có metric
docker compose stop api
curl -i http://localhost:8088/api/tests                 # 503 + SERVICE_STARTING
docker compose start api
```

Xem log truy cập: `docker compose logs -f nginx`. Mỗi dòng là một request: IP, thời gian, URL, mã trạng thái, kích thước. Đây cũng là lý do token **không được** nằm trên URL: nó sẽ nằm trong log này.

---

## 5. Lỗi hay gặp

| Triệu chứng | Nguyên nhân |
|-------------|-------------|
| 404 cho mọi API qua 8088 nhưng 8082 thì chạy | `proxy_pass` có dấu `/` cuối làm mất tiền tố `/api` |
| WebSocket kết nối rồi đóng ngay | Thiếu header `Upgrade`/`Connection`, hoặc origin không nằm trong `app.ws-origins` |
| Upload ghi âm báo 413 | Vượt `client_max_body_size` (Nginx) hoặc `spring.servlet.multipart.max-file-size` (Spring) |
| Tải lại `/roadmap` ra 404 | Thiếu `try_files ... /index.html` |
| Sửa `nginx.conf` mà không có tác dụng | File được COPY vào image lúc build: `docker compose up -d --build nginx` |

---

## 6. Việc tự làm

**Junior**
1. Chạy các lệnh ở mục 4. Giải thích vì sao `/actuator/prometheus` qua 8088 trả về HTML.
2. Thêm `location = /robots.txt { return 200 "User-agent: *\nDisallow: /api/\n"; }`, build lại, thử.
3. Đọc log Nginx sau khi làm một bài đọc. Tìm dòng `POST /api/reading/.../submit`.

**Mid**
4. Bật nén gzip cho JSON và JS (`gzip on; gzip_types application/json application/javascript text/css;`). So sánh kích thước response trong DevTools trước và sau.
5. Thêm header bảo mật: `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `Referrer-Policy`. Tìm hiểu mỗi header chống tấn công gì.
6. Giới hạn tần suất gọi `/api/auth/login`: 5 request mỗi phút mỗi IP (`limit_req_zone`). Thử bằng vòng lặp curl.

**Senior**
7. Thêm HTTPS cho môi trường thật: chứng chỉ lấy ở đâu (Let's Encrypt), gia hạn tự động thế nào, chuyển hướng HTTP sang HTTPS, HSTS là gì và rủi ro khi bật nhầm.
8. Chạy 2 bản `api` sau Nginx (`upstream` + `server api1; server api2;`). WebSocket thì sao: một người mở socket tới api1, request sau sang api2 có vấn đề gì không? Còn file ghi âm lưu trên đĩa của api1, api2 có đọc được không? Đề xuất giải pháp.

---

## 7. Góc nhìn senior

- **Cửa vào là nơi rẻ nhất để chặn.** Giới hạn kích thước, giới hạn tần suất, header bảo mật, HTTPS, chặn đường dẫn nhạy cảm: làm ở proxy thì một lần cho mọi dịch vụ phía sau.
- **Mặc định đóng.** Mở `/actuator/` vì tiện là kiểu sai lầm không ai để ý, cho tới khi có người dùng nó để dò hệ thống.
- **Hệ thống phải "hỏng một cách tử tế".** Trang chờ 503 có `Retry-After` tốt hơn nhiều so với lỗi trắng. Người dùng biết chuyện gì đang xảy ra, client biết khi nào thử lại.

Tiếp theo: [Bài 9: Redis](./learn-redis.md).
