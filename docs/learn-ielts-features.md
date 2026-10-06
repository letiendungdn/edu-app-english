# Bài 6: Các tính năng IELTS, từ yêu cầu tới code

**Mục tiêu:** hiểu cách biến yêu cầu nghiệp vụ ("chấm bài như IELTS", "lập lộ trình học") thành mô hình dữ liệu, thuật toán và API. Đây là kỹ năng phân biệt mid với junior: không chỉ viết code chạy, mà **thiết kế** để nó đúng, test được và sửa được.

Đọc kèm: [IELTS_ROADMAP_SPEC.md](./IELTS_ROADMAP_SPEC.md) (yêu cầu) và [bài 5](./learn-testing.md) (test).

---

## 1. Nghiệp vụ trước, code sau

Đừng mở IDE trước khi hiểu luật chơi. Những điều về IELTS mà code phụ thuộc:

| Luật | Ảnh hưởng tới code |
|------|-------------------|
| Listening và Reading mỗi bài 40 câu, điểm thô /40 quy ra band 0–9 | bảng `band_conversions`, `BandScale.fromRaw` |
| Reading Academic và General quy đổi khác nhau | bảng có cột `module` |
| Band tổng là trung bình 4 kỹ năng, .25 làm tròn lên .5, .75 làm tròn lên số nguyên | `BandScale.roundOverall` |
| Writing Task 2 nặng gấp đôi Task 1 | `BandScale.writing` |
| Điền từ vượt "NO MORE THAN TWO WORDS" là sai dù đúng nội dung | `AnswerGrader.typed` kiểm tra `wordLimit` |
| Câu TRUE/FALSE trả lời YES là sai | `AnswerGrader.judgement` |
| "Choose TWO letters" tính như hai câu | `AnswerGrader.maxPoints` trả 2 |
| Writing/Speaking chấm theo 4 tiêu chí, mỗi tiêu chí 0–9 | 4 cột điểm, `BandScale.fromCriteria` |

Mỗi luật biến thành một dòng code **và một test**. Khi khách hàng hay giáo viên hỏi "app chấm câu này thế nào?", bạn mở test ra trả lời.

---

## 2. Ngân hàng câu hỏi: một mô hình cho 17 dạng câu hỏi

### Vấn đề

Bản cũ chỉ có trắc nghiệm: bảng `reading_questions(question, answer)` + `reading_options`. IELTS có 17 dạng: điền từ, TRUE/FALSE/NOT GIVEN, ghép heading, chọn hai đáp án... Thêm một bảng cho mỗi dạng thì sẽ có 17 bảng × 2 (Reading và Listening).

### Thiết kế

Quan sát đề thật: câu hỏi luôn đi theo **nhóm**. "Questions 1–5: Choose the correct heading from the list below" thì cả nhóm chung hướng dẫn, chung dạng câu, chung danh sách heading.

```text
question_groups      dạng câu, hướng dẫn, giới hạn số từ, thuộc bài đọc hay bài nghe nào
 ├─ question_group_options   lựa chọn DÙNG CHUNG cả nhóm (danh sách heading i–viii)
 └─ questions                số câu (1–40), đề, đáp án chấp nhận (mảng JSON), giải thích, đoạn trích
     └─ question_options     lựa chọn RIÊNG của câu (trắc nghiệm A–D)
```

Một mô hình chứa được mọi dạng:

| Dạng | Lựa chọn nằm ở | Đáp án lưu | Ví dụ |
|------|---------------|-----------|-------|
| Trắc nghiệm | `question_options` | `["B"]` | "What time does Lan wake up?" |
| Chọn hai | `question_options` | `["B","D"]` | "Which TWO conditions..." |
| TRUE/FALSE/NOT GIVEN | (cố định) | `["NOT GIVEN"]` | |
| Ghép heading | `question_group_options` | `["iv"]` | Paragraph E → iv |
| Điền từ | (gõ chữ) | `["pollinator corridors","corridors"]` | có `{{blank}}` trong đề |

**Phần trong ngoặc là tuỳ chọn:** `"(trained) keeper"` chấp nhận cả `trained keeper` lẫn `keeper`. Một chuỗi thay cho nhiều đáp án viết tay.

**Đề và đáp án tách nhau ở tầng API:** `QuestionBank.toView` chỉ đưa `prompt` và `options` vào `QuestionItem`, không bao giờ đưa `acceptedAnswers`. Đáp án chỉ rời server trong `AnswerResult` **sau khi nộp**.

**Thêm dạng câu mới mất bao nhiêu công?** Thêm một giá trị enum `QuestionType`, khai báo nó là dạng gõ chữ hay chọn trong `isTyped()`, thêm một nhánh hiển thị trong `question-group.component.ts`. Không cần bảng mới, không cần migration. Đó là dấu hiệu mô hình tốt.

---

## 3. Chấm câu trả lời: `AnswerGrader`

`service/AnswerGrader.java`. Toàn bộ là hàm `static`, không đụng database.

```java
public static int grade(QuestionType type, List<String> accepted, Integer wordLimit, String given) {
  if (given == null || given.isBlank() || accepted == null || accepted.isEmpty()) return 0;
  return switch (type) {
    case TRUE_FALSE_NOT_GIVEN -> judgement(given, "TRUE", "FALSE", accepted) ? 1 : 0;
    case YES_NO_NOT_GIVEN -> judgement(given, "YES", "NO", accepted) ? 1 : 0;
    case MULTIPLE_CHOICE_MULTI -> multi(given, accepted);
    default -> type.isTyped() ? (typed(given, accepted, wordLimit) ? 1 : 0) : (key(given, accepted) ? 1 : 0);
  };
}
```

### Chuẩn hoá chuỗi

Người học gõ `"  River   Bank. "`, đáp án là `"river bank"`. So sánh chuỗi thô thì sai. `normalize`:

1. Dấu nháy cong `’` thành `'`, gạch dài `–` thành `-` (bàn phím điện thoại hay tự đổi).
2. Chữ thường.
3. Bỏ dấu phẩy hàng nghìn: `1,500` thành `1500`.
4. Gộp nhiều khoảng trắng thành một.
5. Bỏ dấu câu ở hai đầu.
6. `20 %` thành `20%`.

Bản cũ dùng `q.answer().equals(given)`, khác một khoảng trắng là sai. Với câu điền từ, đó là lỗi chấm sai trong phần lớn trường hợp.

### Giới hạn số từ đặt **trước** khi so khớp

```java
if (wordLimit != null && wordLimit > 0 && wordCount(answer) > wordLimit) return false;
```

`"very old bridge"` với giới hạn 2 từ thì sai ngay, dù `"(very) old bridge"` có trong đáp án. Đúng như cách giám khảo chấm.

### Chọn hai đáp án và chống "chọn hết"

```java
long hits = chosen.stream().filter(expected::contains).count();
long penalty = Math.max(0, chosen.size() - expected.size());   // chọn thừa bao nhiêu thì trừ bấy nhiêu
return (int) Math.max(0, hits - penalty);
```

Không trừ điểm thì người học tick cả 5 ô là chắc được 2 điểm. Luôn hỏi: **người dùng có thể "chơi gian" hệ thống thế nào?**

---

## 4. Band: `BandScale` và `BandService`

### Hàm thuần `BandScale`

```java
public static double roundOverall(double average) {
  double whole = Math.floor(average + EPS);
  double fraction = average - whole;
  if (fraction < 0.25 - EPS) return whole;
  if (fraction < 0.75 - EPS) return whole + 0.5;
  return whole + 1.0;
}
```

`EPS` (1e-9) chống lỗi số thực: `6.25` trong máy tính có thể là `6.2499999999`. So sánh số thực luôn cần dung sai.

Bài luyện ngắn (13 câu) được **quy về thang 40** rồi mới tra bảng:

```java
int scaled = total == 40 ? raw : (int) Math.round(raw * 40.0 / total);
```

Vì kém chính xác, quy định: bài **dưới 10 câu không quy ra band** (`ContentService.PRACTICE_BAND_MIN_QUESTIONS`), và giao diện ghi rõ "ước lượng". Đúng 2/3 câu thì không nói lên band nào cả. Trung thực với người dùng về độ tin cậy của con số là một phần của sản phẩm.

### Band hiện tại theo thời gian: `BandService.currentSkillBands`

Mỗi lần có điểm (placement, thi thử, bài luyện), một dòng được ghi vào `band_records`. Band hiện tại của từng kỹ năng là **trung bình có trọng số** các kết quả trong 60 ngày gần nhất:
- Bài thi (placement, mock) nặng **gấp đôi** bài luyện lẻ, vì đề đủ dài và có giờ nên đáng tin hơn.
- Kết quả cũ hơn 60 ngày bị bỏ qua, vì trình độ đã thay đổi.

Thiết kế **append-only** (chỉ thêm, không sửa): không bao giờ ghi đè "band hiện tại" vào một cột, mà luôn tính ra từ lịch sử. Muốn đổi công thức (60 ngày thành 30 ngày) thì không cần migration dữ liệu, và vẽ được biểu đồ tiến bộ.

---

## 5. Sinh lộ trình: `RoadmapPlanner`

### Đầu vào và đầu ra

```java
public record Input(LocalDate today, LocalDate examDate, Double currentBand,
                    Map<Skill, Double> skillBands, double targetBand,
                    int dailyMinutes, int studyDaysPerWeek) {}

public record Plan(LocalDate start, LocalDate end, double startBand, double weeksNeeded,
                   double weeksAvailable, Feasibility feasibility,
                   List<PhasePlan> phases, List<TaskPlan> tasks) {}
```

Không có database, không có `LocalDate.now()`. **Mọi thứ cần biết đều nằm trong `Input`.** Nhờ vậy có 10 test chạy dưới nửa giây.

### Các bước

**1. Khoảng thời gian.** Từ hôm nay tới **ngày trước ngày thi** (ngày thi không học). Không có ngày thi thì 12 tuần.

**2. Có kịp không.**

```java
double minutesFactor = clamp(baselineDailyMinutes / dailyMinutes, 0.5, 3.0);   // 75 phút là chuẩn
double weeksNeeded = gap <= 0 ? 0 : Math.ceil(gap / 0.5) * weeksPerHalfBand * minutesFactor;
```

Mỗi 0.5 band cần khoảng 8 tuần nếu học 75 phút/ngày. Học 60 phút thì cần nhiều hơn theo tỉ lệ. Có đủ tuần → `ON_TRACK`, đủ 70% → `TIGHT`, ít hơn → `AT_RISK`, và giao diện khuyên tăng giờ học hoặc lùi ngày thi.

> Con số 8 tuần là **giả định**, nằm trong `application.yml` (`app.roadmap.weeks-per-half-band`), không ghi cứng trong code. Khi có dữ liệu người học thật, chỉnh lại mà không cần build lại. Đặc tả ghi rõ đây là giả định chưa kiểm chứng.

**3. Chia giai đoạn.**

```text
Nền tảng 25% → Luyện kỹ năng 45% → Luyện đề 20% → Ôn cuối 10% (tối thiểu 7 ngày nếu có ≥ 4 tuần)
```

Band từ 6.0 trở lên thì bỏ giai đoạn Nền tảng và dồn thời gian sang Luyện kỹ năng. Thi trong ≤ 7 ngày thì chỉ còn Ôn cuối.

**4. Ngày nghỉ.** 6 ngày/tuần thì nghỉ Chủ nhật. 5 ngày thì nghỉ cuối tuần. Bảng nằm ở `restDays`.

**5. Việc mỗi ngày.**
- Luôn mở đầu bằng ôn thẻ từ vựng (10–15 phút): SRS chỉ hiệu quả khi ôn đều.
- Mỗi tuần có ít nhất một bài Writing (ngày học thứ 2) và một bài Speaking (ngày học thứ 3).
- Giai đoạn Luyện đề: ngày học cuối mỗi tuần là thi thử 150 phút.
- Thời gian còn lại lấp bằng việc của kỹ năng **thiếu thời gian nhất so với trọng số**:

```java
weights.put(skill, Math.max(0.25, target - band_cua_ky_nang));   // càng xa mục tiêu càng nặng, tối thiểu 0.25
double ratio = allocated.get(skill) / weights.get(skill);        // chọn kỹ năng có ratio nhỏ nhất
```

Writing 5.0 mà mục tiêu 7.0 có trọng số 2.0. Reading 7.0 chỉ có 0.25. Writing nhận nhiều phút hơn. Đây là thuật toán **tham lam theo tỉ lệ** (giống cách chia thời gian CPU cho các tiến trình theo trọng số). Đơn giản, dễ giải thích, có test `weakSkillGetsMoreTime`.

---

## 6. Lưu lộ trình: `RoadmapService`

### Lộ trình có phiên bản

`generate(userId)`:
1. Bản đang chạy (`ACTIVE`) chuyển thành `ARCHIVED`.
2. Lưu bản mới với `version + 1`.
3. Việc **đã làm hôm nay** ở bản cũ được đánh dấu xong luôn ở bản mới, để người học không phải làm lại bài vừa làm.

Vì sao không sửa đè lên bản cũ? Sửa đè thì phải xử lý: task đã làm thuộc giai đoạn nào khi giai đoạn bị đổi ngày? Giữ bản cũ nguyên vẹn thì lịch sử không bao giờ sai, và code đơn giản hơn nhiều.

Lộ trình sinh lại khi:
- Lưu hồ sơ (`ProfileService.save`).
- Nộp placement hoặc thi thử (`TestService.afterResults`).
- Bỏ lỡ hơn 3 việc, hoặc lộ trình đã hết hạn (kiểm tra trong `today()`).
- Người học bấm "Lập lại từ hôm nay".

### Chọn bài cụ thể, nhưng chỉ khi cần

Task tạo ra chỉ ghi "Luyện một bài Reading", **chưa** chọn bài nào (`refId = null`). Lần đầu người học mở trang "Hôm nay", `resolveContent` mới chọn:
1. Bài **chưa làm** trước.
2. Bài có dải band gần **band hiện tại + 0.5** nhất (vừa sức, hơi thử thách).
3. Bài đúng module (Academic/General).

Rồi lưu `refId` lại để lần sau vẫn là bài đó.

Vì sao không chọn sẵn lúc sinh lộ trình? 250 task chọn trước 12 tuần thì không biết tuần 8 band của bạn là bao nhiêu, và không biết lúc đó có thêm bài mới. Chọn muộn (**lazy**) thì luôn dùng thông tin mới nhất.

### Tự đánh dấu xong

```java
roadmap.recordProgress(userId, TaskType.READING);
```

được gọi ở cuối mỗi hành động học: nộp bài đọc, bài nghe, nghe chép, chấm Writing xong, chấm Speaking xong, ôn **hết** thẻ đến hạn, nộp thi thử. Nó tìm task phù hợp đầu tiên của hôm nay (hoặc 3 ngày trước) còn TODO và đánh DONE. `matches()` có vài luật nới: nghe chép tính cho task Listening, làm bất kỳ bài nào cũng tính cho "Xem lại lỗi sai".

---

## 7. Bài thi: `TestService`

### Bắt đầu và mở lại

`start(userId, testId)`: có bài **đang làm dở** của chính đề đó thì trả lại bài đó, không tạo mới. Lỡ tải lại trang hay đóng trình duyệt thì quay lại vẫn còn nguyên bài.

### Lưu tự động

Frontend gọi `PATCH /api/tests/attempts/{id}` mỗi 30 giây và mỗi lần chuyển phần. `store()` chỉ ghi các câu **thay đổi**, không xoá câu cũ. Bản nháp Writing lưu dạng JSON trong cột `writing_drafts`.

### Giờ thi do server giữ

```java
deadline = startedAt + durationMin
if (now > deadline + GRACE) → 409 "Đã hết giờ làm bài"
```

Đồng hồ trên trình duyệt chỉ để **hiển thị**. Nếu tin đồng hồ của client, người học chỉnh giờ máy là có thêm thời gian. `GRACE` (2 phút) bù cho mạng chậm và lệch giờ. Nộp trễ thì vẫn chấm phần đã lưu, nhưng không nhận câu trả lời mới.

### Nộp bài

1. Chấm Listening và Reading ngay bằng `QuestionBank.grade`, quy ra band, ghi `band_records` (nguồn `PLACEMENT` hoặc `MOCK`).
2. Mỗi bài Writing tạo một `WritingSubmission` gắn `attemptId`, chấm nền.
3. Band tổng **chờ** Writing chấm xong (hiện "…" trên giao diện).
4. Writing xong thì sự kiện `AttemptWritingFinished` → `onWritingFinished` tính band Writing (Task 2 × 2), band tổng, cập nhật hồ sơ nếu là placement, sinh lại lộ trình.

Speaking **không** thi trong bài thi (ghi âm 3 phần trong một bài thi là một dự án riêng). Band Speaking lấy từ bài luyện gần nhất, chưa có thì band tổng tính trên các kỹ năng còn lại. Giao diện ghi chú điều này.

---

## 8. Chấm Writing và Speaking bằng AI

### Gọi Claude: `service/ai/IeltsAiGrader.java`

Dùng SDK chính thức `com.anthropic:anthropic-java`, model mặc định `claude-opus-5-5`.

**Structured output:** thay vì xin AI "trả lời dạng JSON" rồi cầu trời nó đúng định dạng, ta khai báo **record Java**, SDK tự sinh JSON schema và API **bảo đảm** kết quả khớp schema:

```java
public record WritingAssessment(
    @JsonPropertyDescription("Task Achievement (Task 1) hoặc Task Response (Task 2), số nguyên 0-9") int taskResponse,
    @JsonPropertyDescription("Coherence and Cohesion, số nguyên 0-9") int coherenceCohesion,
    ...
    List<Correction> corrections) {}

StructuredMessageCreateParams<T> params = MessageCreateParams.builder()
    .model(properties.getModel())
    .maxTokens(16000L)
    .system(system)                // tiêu chí chấm, đọc từ resources/rubrics/writing.md
    .outputConfig(type)            // ← kết quả phải đúng hình dạng record này
    .addUserMessage(userMessage)   // đề bài + bài làm + số từ
    .build();
```

**Prompt có cấu trúc:** đề, dữ liệu biểu đồ và bài làm được bọc trong thẻ `<task>`, `<chart_data>`, `<response>`, để AI phân biệt rõ đâu là đề, đâu là bài. Tiêu chí chấm nằm trong file `rubrics/*.md`, không trong code Java: giáo viên sửa được tiêu chí mà không cần biết Java.

**Không tin tuyệt đối kết quả AI:**

```java
static double clampScore(int score) { return Math.max(0, Math.min(9, score)); }
```

Schema bảo đảm là số nguyên, nhưng không bảo đảm nằm trong 0–9. Dữ liệu từ bên ngoài, kể cả từ AI, luôn được kiểm tra lại.

**Xử lý lỗi theo loại:**

| Lỗi | Thông báo cho người học | Chấm lại có ích không |
|-----|------------------------|----------------------|
| `RateLimitException` (429) | "Dịch vụ AI đang quá tải" | có |
| Lỗi 5xx | "Dịch vụ AI trả lỗi ..." | có |
| `AnthropicIoException` (mạng) | "Không kết nối được dịch vụ AI" | có |
| `stop_reason = refusal` | "AI từ chối chấm bài này" | không |
| `stop_reason = max_tokens` | "Kết quả chấm bị cắt giữa chừng" | có |
| Chưa có API key | "AI chưa được cấu hình" | khi bật key |

Bài lỗi chuyển `FAILED`, giữ nguyên nội dung, có nút "Chấm lại". **Không bao giờ mất bài người học đã viết** chỉ vì dịch vụ bên ngoài trục trặc.

**Kiểm soát chi phí:** mỗi người tối đa `app.ai.daily-limit` lượt mỗi ngày (`AiUsage`), vượt thì 429. Bài thi không bị tính hạn mức, để bài thi luôn được chấm đủ. Bài trống (dưới 20 từ) trong bài thi được cho 0 ngay, không tốn lượt gọi AI.

### Speaking: giới hạn phải nói rõ

- Ghi âm bằng `MediaRecorder`, file lưu trên đĩa (`AudioStorage`, chặn đường dẫn kiểu `../` thoát ra ngoài thư mục lưu).
- Giọng nói thành chữ chạy **trên trình duyệt** (Web Speech API, Chrome/Edge). Server không tự nhận dạng.
- AI chỉ nhận **văn bản**, nên **không chấm được phát âm**. Band tính trên 3 tiêu chí, và giao diện ghi rõ điều này.

Người học sửa được transcript trước khi nộp (máy hay nghe nhầm). Đánh đổi: người học có thể gõ thêm ý. Giao diện dặn "sửa chỗ máy nghe nhầm, đừng viết thêm ý mới". Muốn chặt hơn thì phải nhận dạng giọng nói ở server.

---

## 9. Nội dung: tự biên soạn, có bản quyền rõ ràng

Toàn bộ đề trong `resources/content/` do nhóm tự viết theo format IELTS. Không chép từ sách Cambridge hay trang luyện thi: đó là vi phạm bản quyền và có thể khiến app bị gỡ. Mỗi bài có trường `source` và `license`.

Một bài đọc gồm đoạn văn có đánh dấu đoạn A–F, các nhóm câu, đáp án, giải thích tiếng Việt, và đoạn trích chứa đáp án (`evidence`). `evidence` là phần giá trị nhất với người học: nó chỉ **vì sao** đáp án đúng.

---

## 10. Việc tự làm

**Junior**
1. Thêm một bài đọc mới vào `reading.json`: 300 chữ, một nhóm TRUE/FALSE/NOT GIVEN 4 câu, có `evidence`. Khởi động lại backend và làm thử.
2. Tính tay band tổng cho L 6.5, R 7.0, W 5.5, S 6.0. Kiểm tra bằng `BandScale.overall` trong một test.
3. Đọc `RoadmapPlannerTest` và vẽ ra giấy lộ trình 12 tuần cho band 5.5 → 6.5.

**Mid**
4. Thêm dạng câu `MATCHING_INFORMATION` vào một bài đọc (đoạn nào chứa thông tin X: A–F). Backend đã hỗ trợ, chỉ cần nội dung.
5. Người học muốn **nghỉ một tuần** (đi công tác). Thiết kế API và thay đổi `RoadmapPlanner.Input` để bỏ qua một khoảng ngày. Viết test trước.
6. Thêm biểu đồ band theo thời gian ở trang Tiến độ, dữ liệu từ `GET /api/ielts/bands` (`history`).

**Senior**
7. Kiểm định chất lượng chấm AI: chuẩn bị 20 bài Writing đã có giám khảo chấm, chạy qua `IeltsAiGrader`, đo độ lệch trung bình. Thiết kế quy trình để mỗi lần sửa `rubrics/writing.md` đều đo lại (đây gọi là **eval**). Ngân sách và tiêu chí "đủ tốt" là gì?
8. Tham số `weeks-per-half-band` đang là đoán. Thiết kế cách học nó từ dữ liệu: cần ghi lại gì, sau bao lâu thì đủ tin cậy, và làm sao để người học hiện tại không bị ảnh hưởng xấu khi công thức đổi.

---

## 11. Góc nhìn senior

- **Mô hình dữ liệu quyết định độ khó của mọi thứ phía sau.** Chọn "nhóm câu hỏi + đáp án là mảng" ngay từ đầu làm 17 dạng câu thành chuyện cấu hình. Chọn sai thì mỗi dạng mới là một tuần code.
- **Tách "quyết định" khỏi "thực thi".** `RoadmapPlanner` quyết định (thuần, có test), `RoadmapService` thực thi (đọc, ghi). `AnswerGrader` quyết định, `QuestionBank` thực thi. Mẫu này lặp đi lặp lại vì nó hiệu quả.
- **Trung thực về giới hạn.** Band "ước lượng", AI lệch ±0.5–1.0, Speaking chưa chấm phát âm, heuristic chưa kiểm chứng: đều được ghi ra ở giao diện và trong đặc tả. Phần mềm giáo dục mà hứa quá mức là làm hại người học.
- **Dịch vụ bên ngoài sẽ hỏng.** AI quá tải, mạng chập chờn, key hết hạn. Thiết kế sao cho lúc đó người học mất ít nhất: bài vẫn lưu, có thông báo rõ, chấm lại được.

Tiếp theo: [Bài 7: Docker](./learn-docker.md).
