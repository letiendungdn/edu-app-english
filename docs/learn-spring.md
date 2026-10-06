# Bài 2: Spring Boot, máy chủ của app

**Mục tiêu:** hiểu một request HTTP đi qua backend thế nào, vì sao code chia thành controller/service/repository, và tự thêm được một API mới đúng cách.

**Thư mục:** `backend/`. Java 21, Spring Boot 3.4. Package gốc `com.edu.english`.

---

## 1. Backend làm gì

Trình duyệt không được phép chạm thẳng vào database: ai cũng sửa được điểm của người khác, và mật khẩu bị lộ. Backend đứng giữa:

1. Nhận request HTTP (`GET /api/reading/3`).
2. Kiểm tra người gọi là ai, có quyền không.
3. Chạy **nghiệp vụ**: chấm bài, tính band, sinh lộ trình.
4. Đọc/ghi database.
5. Trả JSON.

**Spring Boot** là framework Java lo phần "ống nước": mở cổng HTTP, đổi JSON qua lại với object Java, kết nối database, quản lý transaction... Bạn chỉ viết phần nghiệp vụ.

---

## 2. Điểm khởi động

`EnglishApplication.java`:

```java
@SpringBootApplication(exclude = { RedisAutoConfiguration.class, MongoAutoConfiguration.class, KafkaAutoConfiguration.class, ... })
@EnableConfigurationProperties(AiProperties.class)
public class EnglishApplication {
  public static void main(String[] args) {
    SpringApplication.run(EnglishApplication.class, args);
  }
}
```

`@SpringBootApplication` bật ba thứ:
- **Component scan**: tìm mọi class có `@Component`, `@Service`, `@RestController`, `@Configuration`... trong package `com.edu.english` trở xuống, rồi tự tạo chúng.
- **Auto-configuration**: thấy thư viện H2 thì tự tạo kết nối database, thấy Spring Web thì tự mở Tomcat cổng 8080...
- **Cấu hình**: đọc `application.yml`.

`exclude = {...Redis, Mongo, Kafka...}`: tắt auto-config của mấy thứ đó. Nếu không tắt, chạy local không có Redis thì Spring vẫn cố kết nối và báo lỗi liên tục. Chúng được bật thủ công trong `config/PlatformConfig.java`, chỉ khi chạy profile `platform` (bài 9–11).

---

## 3. Ba lớp: controller, service, repository

```text
web/       Controller   "Cửa": đọc request, gọi service, trả kết quả. Không chứa nghiệp vụ.
service/   Service      "Bộ não": luật nghiệp vụ, transaction.
repo/      Repository   "Kho": đọc/ghi database.
domain/    Entity       Hình dạng dữ liệu, mỗi class một bảng.
```

**Vì sao không viết hết trong controller?**
- Một nghiệp vụ được nhiều nơi gọi. `RoadmapService.recordProgress` được gọi từ chấm bài đọc, chấm Writing, ôn từ vựng, nộp bài thi. Viết trong controller thì phải copy bốn lần.
- Test service không cần dựng HTTP.
- Đổi cách lưu (H2 sang Postgres) không ảnh hưởng nghiệp vụ.

### 3.1 Controller

`web/ReadingController.java`:

```java
@RestController                       // class này trả JSON
@RequestMapping("/api/reading")       // tiền tố URL chung
public class ReadingController {
  private final ContentService content;

  public ReadingController(ContentService content) {   // Spring tự truyền vào (DI)
    this.content = content;
  }

  @GetMapping("/{id}")                                  // GET /api/reading/3
  public Object readingDetail(@PathVariable Long id) {  // {id} trên URL thành tham số
    return content.reading(id);
  }

  @PostMapping("/{id}/submit")
  public Object submitReading(@PathVariable Long id, @RequestBody SubmitRequest body) {  // body JSON thành object
    var user = CurrentUser.optional();
    return content.submitReading(id, body.answers(), user == null ? null : user.id());
  }
}
```

| Annotation | Lấy dữ liệu từ đâu | Ví dụ |
|-----------|-------------------|-------|
| `@PathVariable` | đường dẫn | `/api/reading/{id}` |
| `@RequestParam` | query string | `/api/vocab?level=B1&page=2` |
| `@RequestBody` | thân request (JSON) | `{"answers": {...}}` |
| `@RequestPart` | form multipart (file) | upload ghi âm ở `SpeakingController` |

Controller trả về object Java, Spring dùng thư viện **Jackson** đổi thành JSON.

### 3.2 Dependency injection, phía Java

Không controller nào gọi `new ContentService(...)`. Spring tạo mỗi service **đúng một lần** (gọi là **bean**), rồi truyền vào constructor của ai cần.

Repo này dùng **constructor injection**: field `final`, truyền qua constructor. Đây là cách được khuyên dùng vì:
- Field `final` thì không ai gán lại được.
- Thiếu dependency thì app **dừng ngay lúc khởi động**, thay vì lỗi `NullPointerException` lúc có người dùng gọi.
- Test chỉ cần `new ContentService(fakeA, fakeB, ...)`.

> **Mùi code cần để ý:** constructor có 15–20 tham số (như `RoadmapService`) là dấu hiệu class làm quá nhiều việc. Ở đây chấp nhận được vì nó điều phối nhiều nguồn dữ liệu. Nhưng nếu thêm nữa, nên tách phần "chọn bài phù hợp" ra một class riêng, ví dụ `ContentPicker`.

### 3.3 Service

`service/ContentService.java`, đoạn nộp bài đọc:

```java
@Transactional
public SubmitResult submitReading(Long id, Map<String, String> answers, Long userId) {
  ReadingPassage passage = requirePassage(id);                        // 404 nếu không có
  QuestionBank.Graded graded = questionBank.grade(OwnerType.READING_PASSAGE, id, answers);
  Double band = graded.maxPoints() >= PRACTICE_BAND_MIN_QUESTIONS     // từ 10 câu mới quy đổi band
      ? bands.convert(Skill.READING, readingModule(passage, userId), graded.points(), graded.maxPoints())
      : null;
  SubmitResult result = toResult(graded, band);
  if (userId != null) {                       // khách vẫn làm bài được, chỉ không lưu
    ... readingAttempts.save(attempt);
    vocabService.addStudy(userId, 60, 0);
    if (band != null) bands.record(userId, Skill.READING, band, BandSource.PRACTICE, attempt.getId());
    roadmap.recordProgress(userId, TaskType.READING);   // tự tick việc "Luyện một bài Reading" hôm nay
  }
  return result;
}
```

Một hành động của người dùng kéo theo năm việc ghi: lần nộp, giờ học, band, tiến độ lộ trình. **`@Transactional`** đảm bảo năm việc đó **hoặc thành công hết, hoặc không có việc nào** (bài 3 giải thích kỹ).

### 3.4 Record làm "hình dạng" JSON

`web/ApiModels.java` và `web/IeltsModels.java` chứa các `record`:

```java
public record SubmitResult(int correct, int total, int percent, Double estimatedBand, List<AnswerResult> results) {}
```

`record` (Java 16+) là class chỉ chứa dữ liệu, bất biến, tự có constructor, getter, `equals`. Rất hợp làm **DTO** (Data Transfer Object): hình dạng dữ liệu trao đổi với client.

**Vì sao không trả thẳng entity ra JSON?**
- Entity `Question` có trường `acceptedAnswers`. Trả thẳng entity là **lộ đáp án** cho người học.
- Entity có quan hệ lazy. Jackson đi theo quan hệ có thể kéo cả database lên, hoặc lỗi `LazyInitializationException`.
- Đổi cột trong database không được phép làm vỡ API mà frontend đang dùng.

DTO là "hợp đồng" với frontend. Entity là chi tiết bên trong, đổi lúc nào cũng được.

---

## 4. Xử lý lỗi

Service gặp lỗi nghiệp vụ thì ném `ResponseStatusException`:

```java
throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Band mục tiêu tối thiểu là 4.0");
```

`web/ApiExceptionHandler.java` bắt nó và trả JSON thống nhất:

```java
@ExceptionHandler(ResponseStatusException.class)
public ResponseEntity<Map<String, String>> handle(ResponseStatusException ex) {
  return ResponseEntity.status(ex.getStatusCode()).body(Map.of("error", message));
}
```

Mọi lỗi có dạng `{"error": "..."}`. Frontend chỉ cần `err?.error?.error` là hiện được thông báo tiếng Việt.

Chọn mã HTTP cho đúng nghĩa:

| Mã | Khi nào | Ví dụ trong repo |
|----|---------|------------------|
| 400 | Dữ liệu gửi lên sai | band 6.3 (không phải bước 0.5), bài viết dưới 20 từ |
| 401 | Chưa đăng nhập hoặc token hỏng | gọi `/api/roadmap` không có token |
| 404 | Không tồn tại, **hoặc không phải của bạn** | xem bài viết của người khác |
| 409 | Xung đột trạng thái | lưu bài thi đã nộp, chưa có hồ sơ IELTS |
| 413 | File quá lớn | ghi âm hơn 10 MB |
| 429 | Vượt hạn mức | quá số lần chấm AI trong ngày |

> **Vì sao xem bài người khác trả 404 chứ không phải 403?** 403 ("cấm") xác nhận bài đó **có tồn tại**. Kẻ xấu đoán id lần lượt sẽ biết id nào có thật. 404 không tiết lộ gì. Xem `requireOwned` trong `WritingService`.

---

## 5. Cấu hình và profile

`src/main/resources/application.yml` có nhiều "document" cách nhau bởi `---`:

```yaml
app:
  ai:
    api-key: ${APP_AI_API_KEY:}        # đọc biến môi trường, không có thì rỗng
    model: ${APP_AI_MODEL:claude-opus-5-5}
---
spring:
  config:
    activate:
      on-profile: dev                  # chỉ áp dụng khi profile dev đang bật
app:
  jwt:
    secret: ${APP_JWT_SECRET:edu-english-dev-secret-key-please-change-32}
```

- `${TEN:mac_dinh}`: đọc biến môi trường `TEN`, không có thì dùng `mac_dinh`.
- **Profile** là bộ cấu hình theo môi trường. `dev` là mặc định (`spring.profiles.default: dev`). Docker bật `platform` (`application-platform.yml`).
- **Bí mật** (JWT secret, API key) **không bao giờ** ghi cứng giá trị thật vào file cấu hình được commit. Đọc từ biến môi trường.

Đọc cấu hình vào code có hai cách:

```java
// 1. Từng giá trị
public JwtService(@Value("${app.jwt.secret}") String secret, ...)

// 2. Cả nhóm vào một class (config/AiProperties.java)
@ConfigurationProperties(prefix = "app.ai")
public class AiProperties { private String apiKey; private String model; private int dailyLimit; ... }
```

Cách 2 tốt hơn khi có nhiều giá trị liên quan: có kiểu dữ liệu, có giá trị mặc định, một chỗ duy nhất.

### Bean tự định nghĩa

`config/AppConfig.java` tạo các bean mà Spring không tự tạo được:

```java
@Bean
Clock clock(@Value("${app.timezone}") String zone) {
  return Clock.system(ZoneId.of(zone));
}
```

Code nghiệp vụ dùng `LocalDate.now(clock)` thay vì `LocalDate.now()`. Có hai lợi ích:
1. "Hôm nay" tính theo giờ Việt Nam kể cả khi máy chủ chạy giờ UTC. Container Docker mặc định chạy UTC: 6 giờ sáng ở Hà Nội vẫn là "hôm qua" theo UTC, nên streak học bị tính sai.
2. Test có thể truyền vào một `Clock` cố định.

---

## 6. Nội dung mẫu: `DataSeeder`

`config/DataSeeder.java` implement `CommandLineRunner`: chạy một lần sau khi app khởi động xong. Nó đọc JSON trong `resources/content/`:

```text
vocab.json, grammar.json        từ vựng, ngữ pháp
reading.json, listening.json    bài đọc, bài nghe kèm nhóm câu hỏi
writing.json, speaking.json     đề Writing (Task 1 có dữ liệu biểu đồ), câu hỏi Speaking
tests.json                      bài thi, tham chiếu nội dung theo TIÊU ĐỀ
```

Seeder **nạp phần còn thiếu**: bài đọc, bài nghe, đề Writing kiểm tra theo tiêu đề; từ vựng, ngữ pháp, Speaking, bài thi nạp khi bảng rỗng. Thêm một bài đọc mới vào `reading.json` rồi khởi động lại là có, không mất dữ liệu người dùng.

**Vì sao bài thi tham chiếu theo tiêu đề mà không theo id?** Id do database sinh, phụ thuộc thứ tự nạp. Máy bạn bài "Sleep and the Teenage Brain" có thể là id 4, máy khác là id 7. Tiêu đề thì ổn định.

---

## 7. Chạy việc nền: sự kiện và `@Async`

Chấm Writing bằng AI mất 20–60 giây. Bắt người dùng chờ HTTP chừng đó là tệ: request dễ timeout, và luồng xử lý của Tomcat bị chiếm. Luồng làm việc:

```text
POST /api/writing/submissions
  └─ WritingService.create (trong transaction)
       ├─ lưu bài, status = PENDING
       └─ events.publishEvent(new WritingSubmitted(id))
  ← trả 202 Accepted ngay

(sau khi transaction COMMIT)
GradingWorker.onWriting   @TransactionalEventListener(AFTER_COMMIT) + @Async("gradingExecutor")
  └─ WritingService.grade(id)
       ├─ gọi Claude (NGOÀI transaction)
       └─ lưu điểm (transaction mới), status = GRADED

Frontend gọi GET /api/writing/submissions/{id} mỗi 4 giây tới khi hết PENDING
```

Ba quyết định, mỗi cái tránh một lỗi thật:

1. **Đợi commit rồi mới chấm (`AFTER_COMMIT`).** Nếu luồng nền chạy trước commit, nó đọc database **chưa thấy** bài vừa lưu, vì transaction kia chưa xong.
2. **Gọi AI ngoài transaction.** Một transaction giữ một kết nối database. Pool mặc định khoảng 10 kết nối. Mười người nộp bài cùng lúc mà mỗi người giữ một kết nối 30 giây thì cả app đứng.
3. **Thread pool riêng (`gradingExecutor`, 2–4 luồng).** Chấm AI chậm không được ăn hết luồng của việc khác.

`WritingService.grade` dùng `TransactionTemplate` thay vì `@Transactional`, vì gọi một method `@Transactional` **từ chính class đó** (`this.applyResult(...)`) thì annotation **không có tác dụng**: Spring áp transaction qua một lớp bọc (proxy), mà gọi nội bộ thì không đi qua lớp bọc. Đây là câu hỏi phỏng vấn kinh điển.

---

## 8. Đi một request trọn vẹn

`PUT /api/ielts/profile` (lưu hồ sơ ở trang onboarding):

1. `JwtAuthFilter` đọc token → biết user id (bài 4).
2. `IeltsController.saveProfile` → `ProfileService.save(userId, body)`.
3. `save` kiểm tra từng trường: band 0–9 bước 0.5, phút 15–300, ngày thi sau hôm nay. Sai thì 400.
4. Lưu `IeltsProfile` → gọi `RoadmapService.generate(userId)`.
5. `generate` đọc band hiện tại, gọi `RoadmapPlanner.plan(...)` (hàm thuần, không đụng database), lưu khoảng 250 task.
6. Cả bước 4 và 5 nằm trong **một** transaction: sinh lộ trình lỗi thì hồ sơ cũng không được lưu nửa vời.
7. Trả `ProfileView` dạng JSON.

Thử: đặt breakpoint ở `ProfileService.save`, chạy backend ở chế độ Debug, lưu hồ sơ trên giao diện, rồi đi từng bước (F8 trong IntelliJ).

---

## 9. Lỗi hay gặp

| Triệu chứng | Nguyên nhân |
|-------------|-------------|
| `Schema-validation: missing column` lúc khởi động | Sửa entity mà chưa thêm migration (bài 3) |
| `LazyInitializationException` | Đọc quan hệ lazy ngoài transaction. Thêm `@Transactional(readOnly = true)` cho method service |
| `@Transactional` như không có tác dụng | Gọi method từ chính class đó, hoặc method không phải `public` |
| `NoSuchBeanDefinitionException` | Class thiếu `@Service`/`@Component`, hoặc nằm ngoài package `com.edu.english` |
| `The dependencies of some beans form a cycle` | A cần B, B cần A. Tách phần dùng chung ra class thứ ba, hoặc dùng sự kiện |
| Mọi API trả 401 dù đã đăng nhập | Đổi `APP_JWT_SECRET` nên token cũ không hợp lệ nữa. Đăng nhập lại |

---

## 10. Việc tự làm

**Junior**
1. Chạy `curl http://localhost:8080/api/writing/prompts`. Đối chiếu từng trường JSON với record `WritingPromptView` trong `IeltsModels.java`.
2. Thêm `@GetMapping("/count")` vào `ReadingController` trả số bài đọc. Gợi ý: `passages.count()` trong service.
3. Gọi `PUT /api/ielts/profile` với `targetBand: 6.3` và đọc thông báo lỗi trả về.

**Mid**
4. Thêm API `GET /api/writing/prompts?task=TASK1` lọc theo task. Thêm vào service, không lọc trong controller.
5. `ProfileService.save` đang kiểm tra dữ liệu bằng `if` tay. Đổi sang Bean Validation (`@Min`, `@Max`, `@Valid` trên record `ProfileRequest`), viết thêm handler cho `MethodArgumentNotValidException` để lỗi vẫn có dạng `{"error": ...}`.
6. Tách phần chọn bài (`pickPassage`, `pickTrack`...) khỏi `RoadmapService` ra class `ContentPicker`. Chạy `mvn test` để chắc không hỏng gì.

**Senior**
7. Máy chủ khởi động lại khi đang có bài Writing `PENDING`: bài đó kẹt mãi. Thiết kế cách khôi phục, ví dụ lúc khởi động quét bài PENDING quá 5 phút rồi xếp chấm lại. Cân nhắc: chạy hai bản backend cùng lúc thì một bài có bị chấm hai lần không?
8. Hạn mức AI đang đếm bằng `count(*)` trong database rồi so sánh. Hai request đến đồng thời đều thấy "còn 1 lượt" và cùng được nhận. Đề xuất cách sửa và nêu đánh đổi (khoá dòng, bảng đếm riêng, Redis `INCR`).

---

## 11. Góc nhìn senior

- **Nghiệp vụ khó nằm trong hàm thuần.** `AnswerGrader`, `BandScale`, `RoadmapPlanner` không biết gì về Spring hay database. Test chạy trong mili giây, đọc là hiểu luật. Service chỉ "đi lấy dữ liệu, gọi hàm thuần, lưu kết quả". Chia như vậy là kỹ năng thiết kế quan trọng nhất bộ tài liệu này dạy.
- **Ranh giới transaction là quyết định thiết kế,** không phải chi tiết kỹ thuật. Câu hỏi đúng là "những việc nào phải cùng thành công hoặc cùng thất bại?", và "việc nào **không được** nằm trong transaction?" (gọi mạng, gọi AI).
- **Hệ thống phụ không được làm hỏng hệ thống chính.** Kafka, Mongo, Redis chết thì người học vẫn nộp bài được (bài 9–11). Luôn hỏi: "cái này chết thì người dùng thấy gì?"

Tiếp theo: [Bài 3: Postgres, JPA, Flyway](./learn-postgres.md).
