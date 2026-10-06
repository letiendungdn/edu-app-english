# Bài 11: Kafka và kiến trúc hướng sự kiện

**Mục tiêu:** hiểu vì sao hệ thống lớn dùng sự kiện thay cho gọi hàm trực tiếp, các khái niệm topic/partition/consumer group, và một lỗi tinh tế: gửi sự kiện trước khi dữ liệu thật sự được lưu.

**File:** `config/PlatformConfig.java` (producer), `config/PlatformGateway.java` (`publish`), nơi gửi: `VocabService.submitReview`, `StudySocketHandler`.

---

## 1. Vấn đề Kafka giải quyết

Người học ôn xong một thẻ từ vựng. Sau đó có thể muốn:
- cập nhật bảng xếp hạng
- gửi email chúc mừng khi thuộc 100 từ
- tính lại gợi ý bài học
- đẩy dữ liệu sang kho phân tích

**Cách 1: gọi trực tiếp** trong `submitReview`: `leaderboard.update(); email.maybeSend(); recommender.refresh(); ...`
- Ôn một thẻ phải chờ cả bốn việc xong.
- Dịch vụ email chết thì ôn thẻ cũng lỗi.
- Mỗi tính năng mới phải sửa `VocabService`.

**Cách 2: phát sự kiện.** `VocabService` chỉ nói "**đã xảy ra**: user 1 ôn thẻ 42, chất lượng 4" rồi làm việc tiếp. Ai quan tâm thì tự **đăng ký nghe**. Người gửi không biết, và không cần biết, có bao nhiêu người nghe.

```text
VocabService ──publish──► [ topic: edu.vocab.reviewed ] ──► consumer bảng xếp hạng
                                                       ──► consumer email
                                                       ──► consumer phân tích
```

Đó là **kiến trúc hướng sự kiện** (event-driven). Kafka là "đường ống" chứa sự kiện: bền (ghi xuống đĩa), giữ được lâu, đọc lại được, chịu tải rất lớn.

---

## 2. Khái niệm cốt lõi

| Khái niệm | Ý nghĩa | Trong repo |
|-----------|---------|-----------|
| **Broker** | một máy chủ Kafka | container `en-kafka` |
| **Topic** | một "kênh" sự kiện theo chủ đề | `edu.vocab.reviewed`, `edu.session.completed` |
| **Partition** | topic chia thành nhiều phần để chạy song song; thứ tự chỉ đảm bảo **trong một partition** | mặc định 1 partition |
| **Offset** | số thứ tự của sự kiện trong partition | consumer tự nhớ mình đọc tới đâu |
| **Producer** | bên gửi | `KafkaTemplate` trong `PlatformGateway` |
| **Consumer** | bên đọc | repo **chưa có** consumer nào |
| **Consumer group** | nhóm consumer chia nhau đọc một topic; mỗi sự kiện tới **một** consumer trong nhóm | |
| **Retention** | sự kiện được giữ bao lâu (mặc định 7 ngày), kể cả đã đọc | |

**Kafka khác hàng đợi thường (RabbitMQ, SQS):** hàng đợi xoá tin khi đã đọc. Kafka **giữ lại** theo thời gian, nhiều nhóm consumer độc lập đọc cùng dữ liệu, và có thể **đọc lại từ đầu**. Thêm một consumer mới hôm nay vẫn xử lý được sự kiện của tuần trước.

**Zookeeper:** image `confluentinc/cp-kafka:7.6.1` dùng Zookeeper để quản lý cụm. Kafka bản mới có chế độ KRaft, bỏ được Zookeeper.

---

## 3. Producer trong repo

`PlatformConfig.java` (chỉ chạy với profile `platform`):

```java
props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, brokers);
props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
props.put(ProducerConfig.MAX_BLOCK_MS_CONFIG, 2000);       // tối đa 2 giây chờ metadata khi broker không trả lời
props.put(ProducerConfig.REQUEST_TIMEOUT_MS_CONFIG, 2000);
```

Payload là chuỗi JSON: `{"userId":1,"vocabId":42,"quality":4}`.

### Lỗi đã sửa: gửi sự kiện trước khi commit

Bản trước:

```java
@Transactional
public SrsCard submitReview(...) {
  ...
  cards.save(card);
  platform.publish(VOCAB_REVIEWED, ...);    // gửi NGAY, transaction CHƯA commit
  return card;
}
```

Hai vấn đề:

**1. Sự kiện "ma".** Gửi xong, nếu transaction rollback (lỗi database sau đó) thì Kafka đã có sự kiện "user 1 ôn thẻ 42", nhưng database không có gì. Consumer xử lý một việc **không hề xảy ra**: bảng xếp hạng cộng điểm sai, email gửi nhầm.

**2. Chặn transaction.** Broker chết thì `send` chờ tới `MAX_BLOCK_MS` (2 giây) **trong khi đang giữ transaction và kết nối database**. Ôn mỗi thẻ chậm thêm 2 giây.

Bản mới, `PlatformGateway.publish`:

```java
Runnable send = () -> executor.execute(() -> {
  try { producer.send(topic, json.writeValueAsString(payload)); }
  catch (Exception ex) { log.warn("Kafka publish skipped: {}", ex.getMessage()); }
});
if (TransactionSynchronizationManager.isSynchronizationActive()) {
  TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
    @Override public void afterCommit() { send.run(); }          // chỉ gửi SAU KHI commit thành công
  });
} else {
  send.run();                                                     // không có transaction → gửi luôn
}
```

- Rollback thì `afterCommit` không bao giờ chạy, nên không có sự kiện ma.
- Việc gửi chạy trên `platformExecutor`, transaction không phải chờ.

### Vẫn còn một khe hở (đáng biết)

Commit xong, chuẩn bị gửi thì app sập (hoặc Kafka chết, hoặc hàng đợi đầy): database có dữ liệu, Kafka **không** có sự kiện. Gọi là "dual write problem": ghi vào hai hệ thống không thể đảm bảo cả hai cùng thành công.

Cách giải chuẩn là **Transactional Outbox**:
1. Trong **cùng transaction**, ghi sự kiện vào một bảng `outbox` trong Postgres.
2. Một tiến trình riêng đọc bảng `outbox` và gửi sang Kafka, gửi xong thì đánh dấu.

Database là nguồn sự thật duy nhất, sự kiện không bao giờ mất (có thể bị gửi **trùng** khi gửi xong mà chưa kịp đánh dấu). Với sự kiện "đã ôn thẻ" dùng để thống kê, mất một ít thì chấp nhận được, nên repo chưa làm outbox. Với sự kiện thanh toán thì bắt buộc.

---

## 4. Đảm bảo giao nhận (cho phỏng vấn)

| Mức | Nghĩa | Hệ quả |
|-----|-------|--------|
| At-most-once | gửi tối đa một lần, có thể mất | repo hiện tại gần như vậy |
| At-least-once | chắc chắn tới, có thể **trùng** | phổ biến nhất; consumer phải **idempotent** |
| Exactly-once | đúng một lần | Kafka hỗ trợ trong phạm vi hẹp, đắt, phức tạp |

**Idempotent consumer:** xử lý cùng một sự kiện hai lần cho kết quả như một lần. Ví dụ: lưu `eventId` đã xử lý, gặp lại thì bỏ qua. Hoặc thiết kế thao tác "đặt giá trị = X" thay vì "cộng thêm 1".

---

## 5. Thử trên máy

Cụm Docker đang chạy, đăng nhập demo, ôn vài thẻ ở `/vocab/review`, rồi:

```powershell
# Đọc sự kiện (lệnh chạy TRONG container nên dùng localhost:9092)
docker exec -it en-kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic edu.vocab.reviewed --from-beginning --max-messages 5

# Danh sách topic
docker exec -it en-kafka kafka-topics --bootstrap-server localhost:9092 --list

# Sự kiện nhịp học từ WebSocket (bài 12)
docker exec -it en-kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic edu.session.completed --from-beginning --max-messages 3
```

Từ máy bạn (ngoài Docker) thì dùng `localhost:9094`. Lý do là cấu hình hai listener: `INTERNAL://kafka:9092` cho container, `EXTERNAL://localhost:9094` cho máy. Kafka trả về cho client **địa chỉ quảng bá** (`advertised.listeners`). Nối nhầm listener thì client nhận địa chỉ `kafka:9092` mà máy bạn không phân giải được. Đây là lỗi cấu hình Kafka hay gặp nhất.

Topic tự được tạo lần đầu có sự kiện, vì `KAFKA_AUTO_CREATE_TOPICS_ENABLE=true`. Ở production nên tắt và tạo topic có chủ đích (số partition, retention).

---

## 6. Việc tự làm

**Junior**
1. Ôn 3 thẻ, đọc 3 sự kiện bằng lệnh ở mục 5. Đối chiếu `vocabId` với bảng `vocabulary`.
2. Dừng Kafka (`docker compose stop kafka`), ôn một thẻ. Thẻ vẫn lưu? Log `en-api` có gì?

**Mid**
3. Viết consumer đầu tiên: `@KafkaListener(topics = "edu.vocab.reviewed", groupId = "stats")` trong một class `@Profile("platform")`, đếm số lần ôn mỗi user trong bộ nhớ và log ra. Cần bật thêm cấu hình consumer gì trong `PlatformConfig`?
4. Phát thêm sự kiện `edu.writing.graded` khi chấm Writing xong (`WritingService.applyResult`). Nó chạy trong `TransactionTemplate`: `afterCommit` có hoạt động không?
5. Đặt `key` cho sự kiện là `userId` (`producer.send(topic, key, value)`). Vì sao điều này quan trọng khi topic có nhiều partition?

**Senior**
6. Cài Transactional Outbox cho `edu.writing.graded`: bảng `outbox_events`, ghi chung transaction, một `@Scheduled` gửi đi. Xử lý: gửi trùng, thứ tự, dọn bảng outbox.
7. Viết consumer gửi email (qua Mailpit, bài 14) khi người học có band Writing ≥ 7.0 lần đầu. Làm sao để không gửi trùng email khi sự kiện bị đọc lại?

---

## 7. Góc nhìn senior

- **Sự kiện mô tả điều đã xảy ra, ở thì quá khứ:** "đã ôn thẻ", "đã chấm xong", không phải "hãy gửi email". Người gửi không ra lệnh cho người nhận. Đó là cách giữ các phần hệ thống không dính chặt vào nhau.
- **"Gửi sau commit" là luật,** không phải chi tiết. Phát sự kiện cho dữ liệu chưa tồn tại là lỗi rất khó tìm, vì nó chỉ xảy ra khi có rollback.
- **Kafka là công cụ nặng.** Một app vài nghìn người dùng, chưa có consumer nào, thì chưa cần Kafka. Gọi hàm hoặc dùng `@TransactionalEventListener` nội bộ (như chấm AI ở bài 6) là đủ. Repo có Kafka để **học**. Biết lúc nào chưa cần là dấu hiệu trưởng thành.

Tiếp theo: [Bài 12: WebSocket](./learn-websocket.md).
