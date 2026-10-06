# Bài 13: Quan sát hệ thống: health, metric, trace, log

**Mục tiêu:** khi hệ thống chậm hoặc lỗi lúc 2 giờ sáng, bạn trả lời được "cái gì hỏng, từ khi nào, vì sao" mà không phải đoán.

**File:** `backend/src/main/resources/application.yml` (mục `management`), `application-platform.yml`, `infra/prometheus/`, `infra/grafana/`, `infra/alertmanager/`, `docker-compose.yml`.

---

## 1. Ba trụ cột

| Trụ cột | Trả lời câu hỏi | Công cụ trong repo |
|---------|----------------|-------------------|
| **Metric** (số đo) | "Hệ thống đang thế nào? Bao nhiêu request, chậm bao nhiêu, lỗi bao nhiêu?" | Actuator + Micrometer → Prometheus → Grafana |
| **Trace** (dấu vết) | "Request **này** đi qua đâu, chậm ở bước nào?" | Micrometer Tracing + OpenTelemetry → Jaeger |
| **Log** (nhật ký) | "Chính xác chuyện gì đã xảy ra?" | log Spring ra stdout, `docker compose logs` |

Thêm một thứ đứng trước cả ba: **health check**, cho biết "có sống không, có nhận việc được không".

Có cả ba thì quy trình điều tra là: metric báo **có** vấn đề (tỉ lệ lỗi tăng vọt lúc 14:05) → trace chỉ **chỗ** vấn đề (bước gọi database mất 3 giây) → log cho biết **lý do** (`Connection pool exhausted`).

---

## 2. Health check: sống và sẵn sàng

`application.yml`:

```yaml
management:
  endpoint:
    health:
      probes:
        enabled: true
      group:
        readiness:
          include: readinessState,db        # readiness kiểm tra cả database
```

| URL | Câu hỏi | Ai hỏi | Trả lời "không" thì |
|-----|---------|-------|---------------------|
| `/actuator/health/liveness` | Tiến trình còn sống, không treo? | Docker healthcheck, Kubernetes liveness | **khởi động lại** container |
| `/actuator/health/readiness` | Sẵn sàng nhận request chưa? (database nối được chưa?) | Kubernetes readiness, load balancer | **tạm ngừng gửi** request tới, **không** khởi động lại |

**Vì sao phải tách hai cái?** Database chết 30 giây:
- Nếu liveness kiểm tra database: mọi bản api bị khởi động lại liên tục. Khởi động lại mất 60 giây, database sống lại rồi mà app vẫn đang khởi động. Sự cố 30 giây kéo thành vài phút.
- Đúng cách: liveness vẫn xanh (tiến trình không hỏng), readiness đỏ (tạm thời đừng gửi request). Database sống lại thì readiness xanh, phục vụ tiếp ngay.

> Bản trước tài liệu ghi "readiness kiểm tra database" nhưng cấu hình **chưa bật**. Mặc định Spring Boot readiness chỉ có `readinessState`. Dòng `include: readinessState,db` làm cho tài liệu đúng với thực tế. Bài học: tài liệu chỉ đúng khi có ai đó kiểm chứng nó với code.

Helm chart dùng `readinessProbe` trỏ vào `/actuator/health/readiness`. Docker compose dùng liveness.

---

## 3. Metric: Prometheus và Grafana

### Spring xuất số đo

Thư viện **Micrometer** tự đếm rất nhiều thứ và xuất ra `/actuator/prometheus` theo định dạng văn bản:

```text
http_server_requests_seconds_count{method="POST",uri="/api/reading/{id}/submit",status="200"} 42
http_server_requests_seconds_sum{method="POST",uri="/api/reading/{id}/submit",status="200"} 3.81
jvm_memory_used_bytes{area="heap",id="G1 Eden Space"} 4.1943E7
hikaricp_connections_active{pool="HikariPool-1"} 2
```

Để ý `uri="/api/reading/{id}/submit"` là **mẫu đường dẫn**, không phải `/api/reading/3/submit`. Nếu mỗi id là một nhãn riêng thì có hàng triệu chuỗi số đo và Prometheus cạn bộ nhớ. Vấn đề này gọi là **high cardinality**, nguồn sự cố metric phổ biến nhất.

### Prometheus kéo số đo

`infra/prometheus/prometheus.yml`:

```yaml
scrape_configs:
  - job_name: english-gateway
    metrics_path: /actuator/prometheus
    static_configs:
      - targets: ['api:8080']        # gọi thẳng trong mạng Docker, KHÔNG qua Nginx
```

Cứ 15 giây Prometheus **kéo** (pull) số đo từ api về và lưu theo thời gian. `/actuator/prometheus` không được công khai qua Nginx (bài 8), Prometheus vẫn đọc được vì đi đường nội bộ.

### Truy vấn PromQL

Mở http://localhost:9095 và thử:

```promql
# Số request mỗi giây, trung bình 5 phút gần nhất, theo đường dẫn
sum by (uri) (rate(http_server_requests_seconds_count[5m]))

# Thời gian xử lý trung bình
sum by (uri) (rate(http_server_requests_seconds_sum[5m])) / sum by (uri) (rate(http_server_requests_seconds_count[5m]))

# Tỉ lệ lỗi 5xx
sum(rate(http_server_requests_seconds_count{status=~"5.."}[5m])) / sum(rate(http_server_requests_seconds_count[5m]))

# Kết nối database đang dùng: chạm trần pool thì request phải xếp hàng
hikaricp_connections_active
```

`rate(...[5m])` đổi bộ đếm tăng dần thành "bao nhiêu mỗi giây". Hầu như mọi biểu đồ request đều bắt đầu bằng `rate`.

### Grafana vẽ biểu đồ

http://localhost:3002 (`admin`/`admin`). Datasource Prometheus đã được khai sẵn trong `infra/grafana/provisioning` (gọi `http://prometheus:9090` trong mạng Docker). Tạo dashboard: Add → Visualization → dán một truy vấn PromQL ở trên.

### Bốn tín hiệu vàng

Google SRE khuyên mọi dịch vụ theo dõi tối thiểu bốn tín hiệu:
1. **Latency**: chậm bao nhiêu (nên nhìn p95, p99, không chỉ trung bình).
2. **Traffic**: bao nhiêu request.
3. **Errors**: bao nhiêu lỗi.
4. **Saturation**: đầy tới đâu (CPU, bộ nhớ, pool kết nối, hàng đợi).

**Vì sao không nhìn trung bình?** 99 request mất 50 ms và 1 request mất 10 giây thì trung bình là 150 ms, trông ổn, nhưng cứ 100 người có 1 người chờ 10 giây. p99 (99% request nhanh hơn con số này) cho thấy điều đó.

---

## 4. Trace: Jaeger

Một request "nộp bài đọc" đi qua: HTTP vào → filter bảo mật → controller → service → nhiều câu SQL → trả về. Chậm 2 giây thì chậm ở đâu?

**Distributed tracing** gắn cho mỗi request một **trace id**, mỗi bước là một **span** có thời điểm bắt đầu và kết thúc. Jaeger vẽ chúng thành biểu đồ thác nước.

`application-platform.yml`:

```yaml
management:
  tracing:
    sampling:
      probability: 1.0                 # ghi 100% request (dev). Production thường 1–10%
  otlp:
    tracing:
      endpoint: ${OTEL_EXPORTER_OTLP_ENDPOINT:http://jaeger:4318/v1/traces}
```

Profile `dev` đặt `probability: 0.0` để máy local không cố gửi trace tới nơi không tồn tại.

Mở http://localhost:16687, chọn service `english-api` (từ `spring.application.name`), bấm Find Traces.

Trace phát huy tác dụng thật khi có **nhiều dịch vụ**: trace id được truyền qua header HTTP và qua Kafka, nên thấy được một hành động đi qua 5 dịch vụ khác nhau.

---

## 5. Log

Spring ghi log ra stdout. Docker thu lại:

```powershell
docker compose logs -f api
docker compose logs api --since 10m | findstr ERROR
```

Mức log và khi nào dùng:

| Mức | Khi nào | Ví dụ trong repo |
|-----|---------|------------------|
| `ERROR` | lỗi cần người xem | `Writing {} grading crashed` (lỗi không lường trước khi chấm AI) |
| `WARN` | bất thường nhưng đã xử lý | `Writing {} not graded: Dịch vụ AI đang quá tải`, `Kafka publish skipped` |
| `INFO` | mốc quan trọng | `Started EnglishApplication` |
| `DEBUG` | chi tiết để gỡ lỗi, tắt ở production | `Redis read skipped`, `Audit log skipped` |

**Chọn mức cho đúng là kỹ năng.** Redis chết thì **mỗi** request sinh một lỗi Redis. Ghi `WARN` là log ngập hàng nghìn dòng mỗi phút, che mất lỗi thật. Vì vậy lỗi Redis và Mongo ghi ở `DEBUG`.

**Log có cấu trúc:** ghi `Writing {} not graded: {}` với tham số thay vì nối chuỗi. Ở production nên xuất log dạng JSON và gom về một chỗ (Loki, Elasticsearch) để tìm theo trường (`userId=1`, `traceId=...`). Gắn trace id vào mỗi dòng log thì từ trace nhảy được sang log của đúng request đó.

**Không ghi bí mật vào log:** mật khẩu, token, nội dung bài viết (bài 10).

---

## 6. Cảnh báo: Alertmanager

http://localhost:9096. Hiện **chưa có luật cảnh báo nào** (`infra/alertmanager/alertmanager.yml` có receiver rỗng). Nó có trong cụm để cùng cấu hình với app tiếng Nhật.

Một luật tốt cảnh báo theo **triệu chứng người dùng thấy**, không theo nguyên nhân:
- Tốt: "tỉ lệ lỗi 5xx > 5% trong 5 phút", "p95 latency > 2 giây".
- Kém: "CPU > 80%". CPU cao mà người dùng không bị ảnh hưởng thì không cần đánh thức ai lúc 2 giờ sáng.

---

## 7. Việc tự làm

**Junior**
1. Gọi `curl http://localhost:8082/actuator/health/readiness`. Dừng Postgres (`docker compose stop postgres`), gọi lại. Liveness thì sao?
2. Trong Prometheus, chạy 4 truy vấn PromQL ở mục 3. Làm vài bài đọc rồi xem số liệu thay đổi.
3. Tìm một trace của `POST /api/reading/{id}/submit` trong Jaeger. Có bao nhiêu span?

**Mid**
4. Tạo dashboard Grafana có 4 biểu đồ cho bốn tín hiệu vàng. Xuất JSON, lưu vào `infra/grafana/provisioning` để tự nạp khi khởi động.
5. Thêm metric nghiệp vụ: đếm số bài Writing chấm thành công/thất bại. Dùng `MeterRegistry` trong `WritingService`: `registry.counter("ielts.writing.graded", "result", "ok").increment()`.
6. Thêm metric thời gian gọi Claude (`Timer`). Biết thời gian chấm thật thì giao diện có thể hiện "thường mất khoảng X giây" chính xác hơn.

**Senior**
7. Viết luật Alertmanager: cảnh báo khi hơn 20% bài Writing chấm thất bại trong 15 phút. Gửi đi đâu (Mailpit để thử)? Làm sao tránh báo động giả lúc chỉ có 2 bài, 1 bài lỗi?
8. Định nghĩa **SLO** cho tính năng chấm Writing (ví dụ "95% bài được chấm trong 90 giây, đo theo tháng"). Đo bằng metric nào? Còn **error budget** dùng thế nào khi quyết định có nên ra bản mới không?

---

## 8. Góc nhìn senior

- **Không đo được thì không cải thiện được.** Trước khi tối ưu bất cứ thứ gì (thêm cache, thêm index), đo để biết nó thật sự là chỗ chậm.
- **Liveness khác readiness.** Lẫn hai cái là cách phổ biến để biến một sự cố nhỏ thành sập toàn bộ.
- **Cảnh báo theo triệu chứng, gỡ lỗi theo nguyên nhân.** Bị đánh thức vì thứ người dùng không cảm nhận được thì sớm muộn sẽ phớt lờ mọi cảnh báo, kể cả cảnh báo thật.

Tiếp theo: [Bài 14: Keycloak và Mailpit](./learn-keycloak-mail.md).
