# Học Kafka — EDU APP English

Kafka ở đây là hàng đợi sự kiện đã xảy ra. API trả lời user trước. Việc phụ (thống kê, email, gợi ý) có thể đọc sau.

Hiện app chỉ gửi, chưa có consumer. Topic vẫn được tạo vì `KAFKA_AUTO_CREATE_TOPICS_ENABLE` bật trên broker.

## 1. Hai topic

Khai báo trong `PlatformGateway`:

| Topic | Khi nào gửi |
|-------|-------------|
| `edu.vocab.reviewed` | `VocabService.submitReview` lưu thẻ SRS xong |
| `edu.session.completed` | WebSocket nhận `{ "seconds": ... }` và cộng giờ học xong |

Payload là một chuỗi JSON (`userId`, `vocabId`, `quality` hoặc `seconds`).

`PlatformConfig` tạo `KafkaTemplate`. `MAX_BLOCK_MS` 2 giây: broker chết thì lời gọi không treo request mãi. Lỗi bị log, response ôn bài vẫn về.

Không có profile `platform` thì không có producer. Local H2 vẫn ôn bài được.

## 2. Broker trong Compose

`zookeeper` cổng host 2182, `kafka` cổng host **9094**.

Trong mạng Docker, Spring nối `kafka:9092` (listener `INTERNAL`).

Từ máy Windows, tool ngoài nối `localhost:9094` (listener `EXTERNAL`). Advertised listener ghi trong `docker-compose.yml`. Nối nhầm 9092 từ host sẽ không tới.

## 3. Đọc một message

Cụm đang chạy, đăng nhập `demo@edu.app`, ôn một thẻ ở `/vocab/review`.

```powershell
docker exec -it en-kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic edu.vocab.reviewed --from-beginning --max-messages 1
```

Lệnh này chạy trong container nên dùng `localhost:9092`. Phải thấy JSON có `vocabId` và `quality`.

Chưa có process nào trừ consumer tay này đọc topic. Thêm consumer sau này là một `@KafkaListener` trong profile `platform`, không ghi vào request ôn bài.

## 4. Việc tự làm

Ôn một thẻ rồi chạy lệnh consumer ở trên. Nếu trống, xem log `en-api` có dòng `Kafka publish skipped` không. Broker chưa healthy thì lần ôn đó không có message, lần sau (broker đã lên) sẽ có.

Tiếp: [learn-websocket.md](./learn-websocket.md).
