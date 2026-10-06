# Học quan sát — EDU APP English

Ba câu khác nhau: process còn sống không, số request thế nào, một request đi qua những lớp nào.

## 1. Sống hay chết: Actuator

`application.yml` bật probe.

| URL | Ý |
|-----|---|
| `/actuator/health/liveness` | JVM đã phục vụ HTTP. Docker dùng URL này cho `en-api`. |
| `/actuator/health/readiness` | Thêm kiểm tra database. Chưa nối được Postgres thì chưa nhận traffic. |
| `/actuator/prometheus` | Số liệu cho Prometheus. |

```powershell
curl http://localhost:8082/actuator/health/liveness
curl http://localhost:8088/actuator/health/liveness
```

Hai lệnh phải cùng kiểu `{"status":"UP"}` khi Nginx và API đều lên. Lệnh thứ hai đi qua Nginx location `/actuator/`.

## 2. Số liệu: Prometheus và Grafana

`infra/prometheus/prometheus.yml` kéo `api:8080/actuator/prometheus` mỗi 15 giây.

- Prometheus: http://localhost:9095
- Grafana: http://localhost:3002, user `admin`, mật khẩu `admin`
- Datasource Prometheus được provision trong `infra/grafana/provisioning`. Grafana trong Compose nói chuyện với `http://prometheus:9090` (cổng nội bộ), không phải 9095.

Vào Prometheus, gõ `jvm_memory_used_bytes`. Có series là API đang bị kéo.

Alertmanager http://localhost:9096 đang có receiver rỗng (`infra/alertmanager/alertmanager.yml`). Nó chạy để cùng mặt bằng với app tiếng Nhật. Chưa có rule nào gửi cảnh báo.

## 3. Một request đi đâu: Jaeger

Profile `platform` đặt `management.tracing.sampling.probability: 1.0` và endpoint OTLP `http://jaeger:4318/v1/traces`.

Profile `dev` đặt xác suất `0` để máy local không cố gửi trace.

UI Jaeger: http://localhost:16687. Service tên Spring Boot (`english-api` hoặc tên application). Gọi `/api/vocab` rồi bấm Find Traces.

Cổng 14318 trên host là OTLP, chỉ cần khi Spring chạy trên máy chứ không trong Compose.

## 4. Việc tự làm

1. Mở http://localhost:9095/targets. Job `english-gateway` phải **UP**. Tên job nằm trong file prometheus, target là service Docker `api`.
2. Gọi một API, mở Jaeger, thấy span mới.
3. Đọc một lần `/actuator/prometheus` và tìm dòng `http_server_requests_seconds_count`.

Tiếp: [learn-keycloak-mail.md](./learn-keycloak-mail.md).
