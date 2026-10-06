# Bài 5: Test tự động

**Mục tiêu:** hiểu vì sao phải viết test, các loại test trong repo, cách viết code dễ test, và đọc được kết quả `mvn test`.

**Thư mục:** `backend/src/test/java/com/edu/english/`.

---

## 1. Vì sao viết test

Không có test, mỗi lần sửa code bạn phải bấm lại tay mọi màn hình để chắc không hỏng gì. Không ai làm nổi, nên lỗi lọt ra người dùng.

Một bộ test tốt cho bạn ba thứ:
1. **Dám sửa code.** Refactor xong chạy `mvn test`, toàn xanh là yên tâm.
2. **Tài liệu sống.** `AnswerGraderTest` cho biết luật chấm chính xác hơn mọi văn bản, và nó không bao giờ lỗi thời vì lỗi thời là test đỏ.
3. **Thiết kế tốt hơn.** Code khó test thường là code dính chùm quá nhiều thứ.

Chạy toàn bộ:

```powershell
cd backend
mvn test
```

Kết quả hiện tại: **39 test, 0 lỗi**. Chạy một lớp: `mvn test -Dtest=AnswerGraderTest`.

---

## 2. Kim tự tháp test

```text
          ▲  ít, chậm, giống thật nhất
         ╱ ╲      E2E: bấm giao diện thật (repo CHƯA có)
        ╱───╲
       ╱     ╲    Integration: dựng Spring + database, gọi HTTP
      ╱───────╲       AuthControllerTest, IeltsFlowTest, QuestionMigrationTest
     ╱         ╲
    ╱───────────╲ Unit: một hàm, không Spring, không database
   ╱             ╲     AnswerGraderTest, BandScaleTest, RoadmapPlannerTest, Sm2Test
  ▼  nhiều, nhanh, rẻ
```

| Loại | Thời gian | Bắt lỗi gì |
|------|-----------|-----------|
| Unit | vài mili giây | sai logic: làm tròn band, chấm TFNG, chia giai đoạn |
| Integration | 10–30 giây (dựng Spring) | lắp ghép sai: SQL, migration, bảo mật, JSON |
| E2E | phút | luồng người dùng thật trên trình duyệt |

Nguyên tắc: logic càng nhiều nhánh thì càng nên test ở tầng unit, vì rẻ và chính xác. Integration test chỉ cần chứng minh các mảnh **ghép được** với nhau.

---

## 3. Unit test: đọc `AnswerGraderTest`

```java
class AnswerGraderTest {
  @Test
  void completionOverWordLimitIsWrongEvenIfContentMatches() {
    List<String> accepted = List.of("(very) old bridge");
    assertThat(grade(QuestionType.SUMMARY_COMPLETION, accepted, 2, "old bridge")).isEqualTo(1);
    assertThat(grade(QuestionType.SUMMARY_COMPLETION, accepted, 2, "very old bridge")).isZero();
  }
}
```

Giải phẫu một test:
- **Tên test là một câu** mô tả luật: "điền từ vượt giới hạn là sai dù đúng nội dung". Test đỏ thì đọc tên là biết luật nào bị vỡ.
- Cấu trúc **Arrange, Act, Assert**: chuẩn bị dữ liệu, gọi hàm, kiểm tra kết quả.
- **AssertJ** (`assertThat(x).isEqualTo(y)`) đọc như tiếng Anh, và báo lỗi rõ ràng kiểu "expected 1 but was 0".

Test **trường hợp biên**, không chỉ trường hợp đẹp. Các test trong file này kiểm tra:
- hoa thường, khoảng trắng thừa, dấu chấm cuối câu
- đáp án thay thế, phần trong ngoặc là tuỳ chọn
- `1,500` bằng `1500`, `20 %` bằng `20%`
- `NG` = `NOT GIVEN`, nhưng `YES` không được nhận cho câu TRUE/FALSE
- chọn 2 đáp án: thứ tự không quan trọng, chọn thừa bị trừ điểm
- câu trả lời trống

Mỗi dòng ứng với một lỗi có thể xảy ra trong đời thật. Viết test là **nghĩ trước** những cách người dùng có thể làm khác bạn tưởng.

### Vì sao `AnswerGrader` dễ test

```java
public static int grade(QuestionType type, List<String> accepted, Integer wordLimit, String given)
```

- `static`, không có field: không cần tạo object, không cần Spring.
- Chỉ phụ thuộc tham số: cùng input luôn ra cùng output.
- Không đụng database, không đọc đồng hồ, không gọi mạng.

Hàm như vậy gọi là **hàm thuần** (pure function). Thiết kế cho dễ test là **đẩy logic vào hàm thuần**, để phần "bẩn" (database, HTTP, thời gian) mỏng nhất có thể.

---

## 4. Thời gian: kẻ thù của test

`RoadmapPlanner` cần biết "hôm nay". Nếu bên trong gọi `LocalDate.now()`:
- Hôm nay test pass, tuần sau ngày rơi vào Chủ nhật thì fail.
- Không test được tình huống "thi vào ngày mai".

Cách giải: **truyền "hôm nay" vào làm tham số**.

```java
public record Input(LocalDate today, LocalDate examDate, Double currentBand, ...) {}
```

`RoadmapPlannerTest`:

```java
private static final LocalDate TODAY = LocalDate.of(2026, 10, 5);   // thứ Hai, cố định

@Test
void examTomorrowGivesSingleReviewDay() {
  Plan plan = plan(TODAY.plusDays(1), 6.0, 6.5, 60, 7);
  assertThat(plan.phases()).hasSize(1);
  assertThat(plan.phases().get(0).kind()).isEqualTo(PhaseKind.FINAL_REVIEW);
}
```

Ở tầng service, "hôm nay" lấy từ bean `Clock` (`config/AppConfig.java`). Test service có thể thay bằng `Clock.fixed(...)`.

### Test tính chất, không chỉ test ví dụ

```java
@Test
void dailyLoadStaysWithinBudgetExceptMockTests() {
  Plan plan = plan(TODAY.plusWeeks(12), 5.0, 6.5, 60, 6);
  Map<LocalDate, Integer> perDay = ... tổng phút mỗi ngày ...;
  assertThat(perDay.values()).allSatisfy(minutes -> assertThat(minutes).isBetween(30, 60));
}
```

Test này không kiểm tra "ngày 12/10 có đúng 3 task". Nó kiểm tra một **tính chất phải luôn đúng**: không ngày nào vượt số phút người học đặt. Đổi thuật toán chọn task, test vẫn đúng nghĩa. Cách viết này bền hơn và bắt được nhiều lỗi hơn.

Các tính chất khác trong file: các giai đoạn nối liền không hở, ngày nghỉ không có task, mỗi tuần luyện kỹ năng có Writing và Speaking, kỹ năng yếu nhận nhiều phút hơn.

---

## 5. Integration test: dựng cả app

`web/IeltsFlowTest.java`:

```java
@SpringBootTest(properties = {
    "spring.datasource.url=jdbc:h2:mem:ielts_flow;MODE=PostgreSQL;...",   // database trong RAM, riêng cho test
    "app.ai.api-key="                                                     // tắt AI: test không gọi mạng, không tốn tiền
})
@AutoConfigureMockMvc   // gọi HTTP giả, không mở cổng thật
class IeltsFlowTest {
  @Autowired private MockMvc mvc;
```

- `@SpringBootTest` dựng **toàn bộ** app: Flyway chạy migration, seeder nạp dữ liệu mẫu, security bật. Lỗi entity lệch bảng, migration sai, luật bảo mật sai đều lộ ra ở đây.
- `MockMvc` gửi request vào app như trình duyệt, nhưng không qua mạng.
- Mỗi lớp test dùng database trong RAM tên riêng (`english_p0`, `ielts_flow`) để không ảnh hưởng nhau.

Một test đi trọn luồng placement:

```java
@Test
void placementTestGivesBandsAndUpdatesProfileWithoutAi() throws Exception {
  saveProfile(null, 7.0);                                         // onboarding, chưa biết band
  JsonNode attempt = read(auth(post("/api/tests/placement/attempts")));
  ... trả lời "A" cho mọi câu, viết một bài essay ...
  mvc.perform(auth(patch("/api/tests/attempts/" + attemptId)) ...);          // lưu tự động

  JsonNode reopened = read(auth(post("/api/tests/placement/attempts")));
  assertThat(reopened.path("id").asLong()).isEqualTo(attemptId);   // mở lại thì vẫn là bài cũ
  assertThat(reopened.path("answers").size()).isEqualTo(answers.size());   // câu trả lời còn nguyên

  JsonNode submitted = read(auth(post("/api/tests/attempts/" + attemptId + "/submit")));
  assertThat(submitted.path("listening").path("total").asInt()).isEqualTo(20);

  JsonNode result = read(auth(get("/api/tests/attempts/" + attemptId + "/result")));
  assertThat(result.path("writing").get(0).path("status").asText()).isEqualTo("FAILED");  // AI tắt
  assertThat(result.path("bandOverall").isNull()).isFalse();     // vẫn có band tổng từ L + R

  JsonNode profile = read(auth(get("/api/ielts/profile")));
  assertThat(profile.path("currentBand").asDouble()).isEqualTo(result.path("bandOverall").asDouble());
}
```

Test này canh một lỗi thật đã gặp lúc viết `TestService`: khi AI tắt, Writing lỗi ngay, nên band tổng của placement không bao giờ được ghi vào hồ sơ. Lỗi được sửa trong `TestService.onWritingFinished`, và hai dòng assert cuối giữ cho nó không quay lại.

### Test bảo mật: kiểm tra điều KHÔNG được xảy ra

```java
String raw = mvc.perform(get("/api/reading/" + passageId)).andReturn().getResponse().getContentAsString();
assertThat(raw).doesNotContain("acceptedAnswers").doesNotContain("ornamental\"");
```

Kiểm tra đề bài gửi xuống **không chứa đáp án**. Loại test này hay bị quên nhất mà lại đáng giá nhất: nó canh lỗi bảo mật xảy ra khi ai đó vô tình thêm trường vào DTO.

### Test migration

`config/QuestionMigrationTest.java` không dựng Spring. Nó dùng Flyway trực tiếp:

```java
Flyway.configure().dataSource(ds).locations("classpath:db/migration").target("2").load().migrate();  // dừng ở V2
jdbc.update("insert into reading_questions ... 'Blue' ...");                                      // dữ liệu kiểu cũ
Flyway.configure().dataSource(ds).locations("classpath:db/migration").load().migrate();           // chạy V3
assertThat(questions).extracting(q -> q.get("accepted_answers")).containsExactly("[\"B\"]", "[\"C\"]");
```

Migration chuyển dữ liệu chạy **một lần duy nhất** trên dữ liệu thật của người dùng, sai là mất dữ liệu. Đáng một test riêng.

---

## 6. Những gì CHƯA được test (và nên test)

| Phần | Vì sao chưa | Cách test |
|------|-------------|-----------|
| `IeltsAiGrader` gọi Claude | gọi mạng thật, tốn tiền | tách interface, dùng bản giả trả kết quả cố định trong test |
| Chấm nền (`GradingWorker`) | bất đồng bộ, khó đợi | thư viện Awaitility: "đợi tối đa 5 giây tới khi status = GRADED" |
| Frontend Angular | chưa viết spec | Jasmine/Karma có sẵn (`ng test`), hoặc Vitest |
| Toàn luồng giao diện | chưa có E2E | Playwright: mở trình duyệt thật, đăng nhập, làm bài |
| Postgres thật | test chạy H2 | Testcontainers |

Biết rõ **mình chưa test gì** cũng là kỹ năng senior. Đừng nói "đã test kỹ" khi chỉ test một phần.

---

## 7. Đọc kết quả khi test đỏ

```text
[ERROR] Tests run: 5, Failures: 1, Errors: 0
[ERROR] AnswerGraderTest.chooseTwoScoresEachLetterAndPenalisesExtraChoices:52
expected: 2
 but was: 1
```

- **Failure**: assert sai, code chạy ra kết quả khác mong đợi.
- **Error**: có exception, thường là cấu hình hoặc `NullPointerException`.
- Integration test lỗi khởi động thì kéo lên tìm dòng `Caused by:` **cuối cùng**. Đó thường là nguyên nhân gốc, ví dụ `Schema-validation: missing column [scorep]`.

Báo cáo chi tiết nằm ở `backend/target/surefire-reports/`.

---

## 8. Việc tự làm

**Junior**
1. Thêm vào `AnswerGraderTest` một test: `"The Town Hall."` được chấp nhận cho đáp án `"(the) town hall"` với giới hạn 3 từ.
2. Cố tình làm hỏng `BandScale.roundOverall` (đổi `0.25` thành `0.3`), chạy test, đọc thông báo lỗi, rồi sửa lại.
3. Chạy `mvn test -Dtest=RoadmapPlannerTest` và đếm thời gian so với `IeltsFlowTest`.

**Mid**
4. Viết test cho `WritingService.wordCount`: chuỗi rỗng, nhiều khoảng trắng, dấu câu đứng riêng (`" - "` không tính là một từ).
5. Viết integration test: hai user, user B gọi `GET /api/writing/submissions/{id}` của user A thì nhận 404.
6. Viết test cho `RoadmapService.recordProgress`: nộp một bài đọc thì task READING hôm nay chuyển DONE.

**Senior**
7. Tách `IeltsAiGrader` sau một interface `EssayGrader`. Viết bản giả cho test, rồi viết test: nộp Writing → đợi tới khi GRADED → band được ghi vào `band_records` → task Writing hôm nay DONE.
8. Đặt mục tiêu cho CI: test phải xong dưới 2 phút. Đo hiện tại, tìm phần chậm nhất (gợi ý: mỗi lớp `@SpringBootTest` có cấu hình khác nhau thì dựng context riêng), đề xuất cách giảm.

---

## 9. Góc nhìn senior

- **Test là để dám thay đổi,** không phải để đạt con số coverage. 100% coverage mà không assert gì thì vô nghĩa.
- **Code khó test là tín hiệu thiết kế.** Muốn test mà phải dựng cả Spring cho một phép tính, thì phép tính đó nằm sai chỗ.
- **Test viết cho người đọc sau.** Tên test như một câu, dữ liệu tối thiểu, một ý mỗi test. Sáu tháng sau đọc test đỏ phải hiểu ngay luật nào vỡ.
- **CI chạy test với mọi push** (`.github/workflows/ci.yml`). Test chỉ chạy trên máy bạn thì sớm muộn sẽ bị quên.

Tiếp theo: [Bài 6: Các tính năng IELTS](./learn-ielts-features.md).
