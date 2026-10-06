# Đặc tả: Chuyển EDU APP English thành app học IELTS theo lộ trình

> Tài liệu dành cho AI coding agent (Cursor) và dev triển khai.
> Làm **theo từng giai đoạn** ở mục 7. Hết mỗi giai đoạn phải build được, chạy được và đạt tiêu chí nghiệm thu rồi mới làm tiếp.

---

## 0. Trạng thái triển khai (cập nhật 06/10/2026)

| Giai đoạn | Trạng thái | Ghi chú |
|---|---|---|
| P0 Nền móng | Xong | Một bộ migration chung cho H2 và Postgres (H2 chạy chế độ PostgreSQL), controller tách theo module, secret qua biến môi trường, seeder đọc JSON |
| P1 Hồ sơ + ngân hàng câu hỏi | Xong | Migration `V3__ielts.sql` chuyển câu hỏi trắc nghiệm cũ sang `questions`; `AnswerGrader` + test |
| P2 Placement + lộ trình + dashboard | Xong | `RoadmapPlanner` là hàm thuần có test; lộ trình lưu theo phiên bản (`roadmaps.version`, bản cũ `ARCHIVED`) |
| P3 Writing chấm AI | Xong | Claude qua SDK `anthropic-java`, structured output, chấm nền sau commit |
| P4 Speaking | Xong, có giới hạn | Speech-to-text chạy **trên trình duyệt** (Web Speech API, cần Chrome/Edge), server chỉ lưu file audio. Pronunciation chưa chấm |
| P5 Mock test + điều chỉnh lộ trình | Xong, có giới hạn | Mock test gồm L + R + W. **Speaking không thi trong bài thi**: band Speaking lấy từ bài luyện gần nhất |
| P6 Admin + import nội dung | **Chưa làm** | Thêm nội dung hiện tại bằng cách sửa JSON trong `backend/src/main/resources/content` |

Khác với đặc tả ban đầu:
- Bài nghe chưa có file audio: trình duyệt đọc lời thoại bằng giọng máy (`shared/tts-player.component.ts`). Khi có audio thật, điền `audioUrl` cho bài nghe là player tự dùng file đó. Trong bài thi, lời thoại vẫn được gửi xuống trình duyệt để đọc, nên người rành kỹ thuật có thể xem được qua DevTools.
- Placement test khoảng 60 phút (2 phần Listening, 1 bài Reading, 1 bài Writing Task 2), không có Speaking.
- Bảng quy đổi điểm thô sang band (mục 3.2) lấy từ nguồn luyện thi phổ biến, không phải bảng chính thức. Bảng nằm trong DB (`band_conversions`), sửa bằng migration mới.
- Heuristic thời gian cần để tăng band (`app.roadmap.weeks-per-half-band: 8` ở 75 phút/ngày) là giả định, chưa kiểm chứng bằng dữ liệu người học thật.

Việc nên làm tiếp: P6 (admin import JSON), thêm đề (hiện có 1 mock test, dùng lại bài luyện), audio thật cho Listening, dashboard biểu đồ band theo thời gian (dữ liệu đã có ở `GET /api/ielts/bands`), test E2E giao diện.

---

## 1. Mục tiêu sản phẩm

Người học nhập **band mục tiêu** và **ngày thi**, làm **bài kiểm tra đầu vào**. Từ đó app sinh ra **lộ trình học theo tuần và theo ngày** cho cả 4 kỹ năng (Listening, Reading, Writing, Speaking) cộng với từ vựng. Sau mỗi bài thi thử, lộ trình tự điều chỉnh theo điểm.

Luồng chính:

```
Đăng ký → Onboarding (Academic/General, band hiện tại, band mục tiêu, ngày thi, số phút học/ngày)
       → Placement test (~45 phút, rút gọn 4 kỹ năng)
       → Sinh lộ trình (các giai đoạn → tuần → nhiệm vụ hằng ngày)
       → Dashboard "Hôm nay học gì"
       → Luyện kỹ năng / ôn từ (SRS) / thi thử
       → Ước lượng band theo từng kỹ năng → điều chỉnh lộ trình
```

Không làm trong phạm vi này: thanh toán, app mobile native, chat giữa các người học.

---

## 2. Review code hiện tại

### Đã có và giữ lại
| Phần | Vị trí | Ghi chú |
|---|---|---|
| Auth JWT | `backend/.../security/*`, `frontend/src/app/core/auth.*` | Dùng tiếp |
| Từ vựng + SRS (SM-2) | `service/VocabService.java`, `service/Sm2.java`, `pages/review.component.ts` | Dùng làm module "Vocabulary" của IELTS; thêm bộ từ học thuật (AWL) |
| Reading / Listening | `domain/Reading*`, `domain/Listening*`, `service/ContentService.java` | **Phải mở rộng**: hiện chỉ có trắc nghiệm |
| Dictation | `domain/DictationAttempt.java` | Giữ lại, làm bài tập bổ trợ cho Listening |
| Analytics, StudySession | `domain/StudySession.java`, `pages/analytics.component.ts` | Mở rộng thêm band theo kỹ năng và streak |
| Grammar | `domain/Grammar*` | Giữ lại, gắn vào giai đoạn Foundation |

### Vấn đề cần sửa trước khi làm tiếp
1. **Câu hỏi chỉ có trắc nghiệm.** `ReadingQuestion`/`ListeningQuestion` chỉ có `answer` + `options`. IELTS có khoảng 14 dạng câu hỏi (xem mục 4.2), nên cần một model câu hỏi chung.
2. **Chấm điểm so khớp tuyệt đối.** `ContentService.grade()` dùng `q.answer().equals(given)` nên dạng điền từ sẽ chấm sai: không bỏ qua hoa/thường, khoảng trắng, đáp án thay thế, giới hạn số từ. Xem mục 5.3.
3. **Schema do Hibernate tự sinh** (`ddl-auto: update`). Cần chuyển sang **Flyway** migration vì sắp thêm nhiều bảng.
4. **Một controller duy nhất** (`web/EnglishController.java`) cho mọi thứ. Cần tách theo module trước khi thêm tính năng.
5. **Dữ liệu mẫu hard-code** trong `config/DataSeeder.java` (368 dòng). Chuyển sang import từ file JSON trong `backend/src/main/resources/content/` để dễ thêm đề.
6. **JWT secret nằm trong `application.yml`.** Đọc từ biến môi trường `APP_JWT_SECRET`, chỉ giữ giá trị mặc định cho profile dev.
7. **Không có test** ở cả backend lẫn frontend. Tối thiểu cần unit test cho: chấm điểm, quy đổi band, sinh lộ trình, SM-2.
8. `UserAccount.targetLevel` là CEFR. Thêm hồ sơ IELTS riêng thay vì sửa field này (xem 4.1).

---

## 3. Kiến thức nghiệp vụ IELTS (để code đúng)

### 3.1 Cấu trúc bài thi
| Kỹ năng | Cấu trúc | Thời gian |
|---|---|---|
| Listening | 4 part, 40 câu | ~30 phút |
| Reading | 3 passage, 40 câu (Academic và General khác nội dung) | 60 phút |
| Writing | Task 1 (Academic: mô tả biểu đồ, quy trình, bản đồ; General: viết thư, ≥150 từ) + Task 2 (essay, ≥250 từ; Task 2 có trọng số gấp đôi Task 1) | 60 phút |
| Speaking | Part 1 (hỏi đáp ngắn), Part 2 (cue card: 1 phút chuẩn bị, nói 1–2 phút), Part 3 (thảo luận) | 11–14 phút |

### 3.2 Quy đổi điểm thô sang band (Listening / Academic Reading)
Lưu vào **bảng cấu hình trong DB**, không hard-code, vì bảng chính thức có thể thay đổi nhẹ giữa các đề. General Reading dùng bảng riêng.

| Band | Listening (/40) | Academic Reading (/40) |
|---|---|---|
| 9.0 | 39–40 | 39–40 |
| 8.5 | 37–38 | 37–38 |
| 8.0 | 35–36 | 35–36 |
| 7.5 | 32–34 | 33–34 |
| 7.0 | 30–31 | 30–32 |
| 6.5 | 26–29 | 27–29 |
| 6.0 | 23–25 | 23–26 |
| 5.5 | 18–22 | 19–22 |
| 5.0 | 16–17 | 15–18 |
| 4.5 | 13–15 | 13–14 |
| 4.0 | 10–12 | 10–12 |

**Band tổng** = trung bình 4 kỹ năng, làm tròn đến 0.5 gần nhất. Phần lẻ .25 làm tròn **lên** .5; phần lẻ .75 làm tròn **lên** số nguyên kế tiếp. Ví dụ: 6.25 → 6.5; 6.75 → 7.0; 6.1 → 6.0.

### 3.3 Tiêu chí chấm Writing và Speaking (band descriptors công khai)
- Writing: Task Achievement/Response, Coherence & Cohesion, Lexical Resource, Grammatical Range & Accuracy.
- Speaking: Fluency & Coherence, Lexical Resource, Grammatical Range & Accuracy, Pronunciation.
- Mỗi tiêu chí chấm 0–9; band kỹ năng = trung bình 4 tiêu chí, làm tròn như trên.

### 3.4 Quy đổi CEFR ↔ IELTS (để tái dùng nội dung CEFR đang có)
| CEFR | IELTS |
|---|---|
| B1 | 4.0–5.0 |
| B2 | 5.5–6.5 |
| C1 | 7.0–8.0 |
| C2 | 8.5–9.0 |

Nội dung A1–A2 hiện có dùng cho giai đoạn Foundation với người dưới band 4.0.

---

## 4. Mô hình dữ liệu mới

Tất cả tạo bằng Flyway (`backend/src/main/resources/db/migration/V{n}__*.sql`). Tên bảng snake_case, entity trong `com.edu.english.domain`.

### 4.1 Hồ sơ và tiến độ
```
ielts_profile
  user_id (PK, FK users), module (ACADEMIC|GENERAL),
  current_band DECIMAL(2,1) NULL, target_band DECIMAL(2,1),
  exam_date DATE NULL, daily_minutes INT, study_days_per_week INT DEFAULT 6,
  created_at, updated_at

band_record                      -- lịch sử band theo kỹ năng
  id, user_id, skill (LISTENING|READING|WRITING|SPEAKING|OVERALL),
  band DECIMAL(2,1), source (PLACEMENT|MOCK|PRACTICE|SELF_REPORT), source_ref_id, recorded_at
```

### 4.2 Ngân hàng câu hỏi dùng chung cho Reading/Listening
Thay thế dần `ReadingQuestion`/`ListeningQuestion`. Viết migration chuyển dữ liệu cũ sang thành `MULTIPLE_CHOICE`.

```
question_group                   -- 1 nhóm câu chung hướng dẫn, VD "Questions 1–5: TRUE/FALSE/NOT GIVEN"
  id, owner_type (READING_PASSAGE|LISTENING_TRACK), owner_id,
  question_type, instruction TEXT, word_limit INT NULL,   -- "NO MORE THAN TWO WORDS" → 2
  shared_options JSON NULL,      -- danh sách headings / endings / features dùng chung
  image_url NULL,                -- cho diagram / map / flow-chart
  sort_order

question
  id, group_id, number INT,      -- số câu 1–40 như đề thật
  prompt TEXT,                   -- câu hỏi, hoặc câu có chỗ trống đánh dấu bằng {{blank}}
  options JSON NULL,             -- options riêng của câu (MCQ)
  accepted_answers JSON,         -- ["1990", "nineteen ninety"]; MCQ: ["B"]; multi-select: ["A","D"]
  explanation TEXT NULL, evidence TEXT NULL   -- trích đoạn trong bài chứa đáp án
```

`question_type` (enum):
`MULTIPLE_CHOICE`, `MULTIPLE_CHOICE_MULTI`, `TRUE_FALSE_NOT_GIVEN`, `YES_NO_NOT_GIVEN`, `MATCHING_HEADINGS`, `MATCHING_INFORMATION`, `MATCHING_FEATURES`, `MATCHING_SENTENCE_ENDINGS`, `SENTENCE_COMPLETION`, `SUMMARY_COMPLETION`, `NOTE_COMPLETION`, `TABLE_COMPLETION`, `FLOW_CHART_COMPLETION`, `DIAGRAM_LABEL`, `SHORT_ANSWER`, `FORM_COMPLETION` (Listening), `MAP_LABELLING` (Listening).

Thêm vào `reading_passage`: `module` (ACADEMIC|GENERAL|BOTH), `band_min`, `band_max`, `topic`.
Thêm vào `listening_track`: `ielts_part` (1–4), `band_min`, `band_max`.

### 4.3 Writing
```
writing_prompt
  id, module, task (TASK1|TASK2), task1_kind NULL (LINE|BAR|PIE|TABLE|PROCESS|MAP|MIXED|LETTER),
  task2_kind NULL (OPINION|DISCUSSION|PROBLEM_SOLUTION|ADVANTAGE_DISADVANTAGE|TWO_PART),
  prompt TEXT, image_url NULL, min_words, sample_answer TEXT NULL, sample_band NULL, topic

writing_submission
  id, user_id, prompt_id, text TEXT, word_count, time_spent_sec,
  status (DRAFT|PENDING|GRADED|FAILED),
  score_ta, score_cc, score_lr, score_gra, band DECIMAL(2,1),
  feedback JSON,                 -- {summary, strengths[], improvements[], corrections:[{original, suggestion, reason}]}
  grader (AI|TEACHER), created_at, graded_at
```

### 4.4 Speaking
```
speaking_prompt
  id, part (1|2|3), topic, question TEXT,
  cue_card_points JSON NULL,     -- Part 2: các gạch đầu dòng "You should say..."
  follow_up_of NULL              -- Part 3 gắn với chủ đề Part 2

speaking_submission
  id, user_id, prompt_id, audio_url, transcript TEXT, duration_sec,
  status, score_fc, score_lr, score_gra, score_p NULL, band, feedback JSON, created_at
```

### 4.5 Bài thi (placement / mock / luyện một phần)
```
test
  id, kind (PLACEMENT|MOCK|SECTION), module, title, duration_min, is_published

test_section
  id, test_id, skill, sort_order, ref_type, ref_id   -- trỏ tới passage / track / writing_prompt / speaking_prompt

test_attempt
  id, user_id, test_id, started_at, submitted_at,
  status (IN_PROGRESS|SUBMITTED|GRADED),
  raw_listening, raw_reading, band_listening, band_reading,
  band_writing, band_speaking, band_overall

attempt_answer
  id, attempt_id, question_id, given TEXT, is_correct BOOLEAN
```
Bài làm dở phải **lưu tự động** (PATCH mỗi 30 giây và khi chuyển section), để reload trang không mất bài.

### 4.6 Lộ trình
```
roadmap
  id, user_id, status (ACTIVE|ARCHIVED), start_date, exam_date, start_band, target_band,
  generated_at, version INT

roadmap_phase
  id, roadmap_id, kind (FOUNDATION|SKILL_BUILDING|EXAM_PRACTICE|FINAL_REVIEW),
  start_date, end_date, goal TEXT, sort_order

roadmap_task
  id, roadmap_id, phase_id, due_date,
  type (VOCAB_REVIEW|VOCAB_NEW|GRAMMAR|READING|LISTENING|DICTATION|WRITING_T1|WRITING_T2|SPEAKING|MOCK_TEST|REVIEW_MISTAKES),
  ref_type NULL, ref_id NULL,    -- nội dung cụ thể; NULL = app tự chọn khi mở
  title, estimated_min, status (TODO|DONE|SKIPPED), completed_at
```

---

## 5. Logic nghiệp vụ

### 5.1 Sinh lộ trình (`RoadmapService.generate(userId)`)
Đầu vào: `ielts_profile` + band mới nhất từng kỹ năng (từ `band_record`).

1. `weeks` = số tuần từ hôm nay đến `exam_date`. Không có ngày thi thì mặc định 12 tuần.
2. `gap` = `target_band − current_overall`. Ước lượng thời gian cần: ~8 tuần cho mỗi 0.5 band khi học 60–90 phút/ngày (**heuristic**, để trong `application.yml` dưới `app.roadmap.*`). Thời gian không đủ thì vẫn sinh lộ trình, kèm cảnh báo `feasibility: "AT_RISK"` và đề xuất tăng `daily_minutes` hoặc lùi ngày thi.
3. Chia giai đoạn theo tỉ lệ cấu hình được:
   - FOUNDATION 25%: ngữ pháp, từ vựng nền, các dạng câu hỏi. **Bỏ qua** nếu band hiện tại ≥ 6.0.
   - SKILL_BUILDING 45%: luyện từng dạng câu hỏi, Writing theo từng dạng đề.
   - EXAM_PRACTICE 20%: mỗi tuần 1 mock test đầy đủ + chữa lỗi.
   - FINAL_REVIEW 10% (tối thiểu 1 tuần): ôn lỗi sai, đề ngắn, không học nội dung mới.
4. Trọng số kỹ năng: kỹ năng có `target − band_kỹ_năng` lớn hơn được nhiều phút hơn (tỉ lệ thuận với gap, mỗi kỹ năng tối thiểu 15% thời lượng tuần).
5. Mỗi ngày học: luôn bắt đầu bằng `VOCAB_REVIEW` (10–15 phút, số thẻ SRS đến hạn). Phần còn lại lấp bằng các task theo trọng số, tổng `estimated_min` ≤ `daily_minutes`. Mỗi tuần có ít nhất 1 Writing và 1 Speaking.
6. Chọn nội dung: ưu tiên bài có `band_min ≤ band_hiện_tại + 0.5 ≤ band_max` mà user chưa làm.
7. **Điều chỉnh lại**: chạy lại thuật toán cho các ngày **từ hôm nay trở đi** khi (a) nộp xong một mock test, (b) user sửa hồ sơ, (c) quá 3 task bị bỏ lỡ. Không đụng vào task đã DONE. Tăng `roadmap.version`.

Thuật toán phải là hàm thuần (input → danh sách task) để unit test được với ngày cố định.

### 5.2 Ước lượng band
- Listening/Reading: điểm thô → bảng quy đổi (3.2). Bài luyện ngắn (<40 câu) thì quy đổi theo tỉ lệ và gắn nhãn "ước lượng".
- Writing/Speaking: lấy từ chấm AI (5.4). Writing của một mock test = (T1 + 2×T2) / 3, làm tròn 0.5.
- Band hiện tại của từng kỹ năng = trung bình có trọng số các `band_record` trong 30 ngày gần nhất (MOCK ×2, PRACTICE ×1).

### 5.3 Chấm câu trả lời tự động (`AnswerGrader`, viết unit test cho mọi nhánh)
- Chuẩn hoá: trim, lowercase, gộp nhiều khoảng trắng, bỏ dấu câu ở đầu/cuối, chuẩn hoá dấu nháy.
- So khớp với **bất kỳ** phần tử nào trong `accepted_answers`.
- Kiểm tra `word_limit` (số được tính là 1 từ). Vượt giới hạn thì sai, dù đúng nội dung.
- TFNG/YNNG: chấp nhận `T/F/NG` và `TRUE/FALSE/NOT GIVEN`; **không** chấp nhận lẫn YES cho dạng TRUE.
- `MULTIPLE_CHOICE_MULTI`: mỗi đáp án đúng được 1 điểm, thứ tự không quan trọng.
- Kết quả trả về: đúng/sai, đáp án chuẩn, `explanation`, `evidence`.

### 5.4 Chấm Writing/Speaking bằng AI
- Tạo interface `EssayGrader` và `SpeechGrader`; implementation đầu tiên gọi LLM API (cấu hình provider/model qua `app.ai.*`, key lấy từ biến môi trường, **không commit**).
- Prompt gửi kèm: đề bài, bài làm, loại task, **toàn văn band descriptors** (lưu ở `resources/rubrics/`), yêu cầu trả về **JSON đúng schema** của `feedback` + 4 điểm tiêu chí. Validate JSON, sai schema thì retry 1 lần rồi đặt `status=FAILED`.
- Chấm **bất đồng bộ**: POST trả `202` + id, frontend poll `GET /api/writing/submissions/{id}`.
- Speaking: ghi âm bằng `MediaRecorder` trên trình duyệt → upload → speech-to-text → chấm như Writing trên transcript. Tiêu chí Pronunciation **không chấm được từ transcript**: để `NULL` và tính band trên 3 tiêu chí, ghi chú rõ trên UI.
- UI luôn hiển thị: *"Điểm do AI ước lượng, có thể lệch so với giám khảo thật ±0.5–1.0 band."*
- Giới hạn số lần chấm AI/ngày/user (cấu hình được) để kiểm soát chi phí.

---

## 6. API và màn hình

### 6.1 Backend: tách controller theo module (`com.edu.english.web.*`)
| Controller | Endpoint chính |
|---|---|
| `ProfileController` | `GET/PUT /api/ielts/profile` |
| `RoadmapController` | `POST /api/roadmap/generate`, `GET /api/roadmap`, `GET /api/roadmap/today`, `PATCH /api/roadmap/tasks/{id}` (DONE/SKIPPED) |
| `TestController` | `GET /api/tests?kind=`, `POST /api/tests/{id}/attempts`, `PATCH /api/attempts/{id}` (autosave), `POST /api/attempts/{id}/submit`, `GET /api/attempts/{id}/result` |
| `ReadingController`, `ListeningController` | giữ các route cũ, response trả thêm `groups[]` theo model mới |
| `WritingController` | `GET /api/writing/prompts`, `POST /api/writing/submissions`, `GET /api/writing/submissions/{id}` |
| `SpeakingController` | `GET /api/speaking/prompts`, `POST /api/speaking/submissions` (multipart) |
| `VocabController`, `GrammarController`, `DictationController`, `AnalyticsController` | tách từ `EnglishController`, **giữ nguyên URL hiện có** |
| `AdminContentController` (role ADMIN) | CRUD + import JSON cho passage, track, prompt, test |

**Không bao giờ** trả `accepted_answers` cho client trước khi nộp bài.

### 6.2 Frontend Angular (giữ phong cách hiện tại: standalone component + `signal`)
| Route | Màn hình |
|---|---|
| `/onboarding` | Wizard 4 bước: module → band hiện tại (hoặc "chưa biết") → band mục tiêu + ngày thi → phút/ngày |
| `/placement` | Placement test, dùng chung player với mock test |
| `/` (đã đăng nhập) | Dashboard: band hiện tại vs mục tiêu từng kỹ năng, đếm ngược ngày thi, **checklist hôm nay**, streak |
| `/roadmap` | Timeline các giai đoạn → tuần → task; đánh dấu xong / bỏ qua |
| `/practice/reading/:id`, `/practice/listening/:id` | Màn chia đôi (bài đọc trái, câu hỏi phải); một component render riêng cho mỗi `question_type` |
| `/writing`, `/writing/:promptId` | Editor có đếm từ + đồng hồ, nộp bài, xem feedback (điểm 4 tiêu chí, sửa lỗi inline) |
| `/speaking`, `/speaking/:promptId` | Ghi âm, đếm giờ chuẩn bị Part 2, xem transcript + feedback |
| `/tests`, `/tests/:attemptId` | Danh sách đề, player đếm giờ toàn bài, autosave, trang kết quả |
| `/vocab/*`, `/grammar/*`, `/dictation`, `/analytics` | Giữ nguyên, thêm biểu đồ band theo thời gian vào analytics |
| `/admin/*` | Quản lý nội dung (chỉ ADMIN) |

Guard: user chưa có `ielts_profile` thì luôn bị chuyển về `/onboarding`.

---

## 7. Kế hoạch triển khai theo giai đoạn

### P0: Dọn nền móng
- Thêm Flyway; tạo `V1__baseline.sql` khớp schema hiện tại; đổi `ddl-auto` thành `validate`.
- Tách `EnglishController` theo bảng 6.1, URL giữ nguyên.
- JWT secret và AI key lấy từ biến môi trường.
- Chuyển `DataSeeder` sang đọc JSON trong `resources/content/`.
- Thêm test: `Sm2Test`, test controller cho auth.
- **Nghiệm thu:** `mvn verify` pass; tất cả màn hình frontend hiện có vẫn chạy.

### P1: Hồ sơ IELTS + ngân hàng câu hỏi mới
- Bảng 4.1, 4.2; migration dữ liệu câu hỏi cũ.
- `AnswerGrader` (5.3) + bảng quy đổi band (3.2) + test.
- Frontend: onboarding, component cho từng `question_type`.
- Seed ít nhất: 3 passage Academic (mỗi passage ≥3 dạng câu hỏi khác nhau), 4 track Listening (part 1–4).
- **Nghiệm thu:** làm được một bài Reading có TFNG + matching headings + sentence completion, chấm đúng các trường hợp viết hoa / thừa từ / đáp án thay thế.

### P2: Placement + lộ trình + dashboard
- Bảng 4.5 (PLACEMENT), 4.6; `RoadmapService` (5.1) dạng hàm thuần + test với ngày cố định.
- Dashboard, `/roadmap`, guard onboarding.
- **Nghiệm thu:** user mới → onboarding → placement → thấy lộ trình đến đúng ngày thi; tick xong task thì tiến độ cập nhật; sửa ngày thi thì lộ trình sinh lại, task DONE vẫn giữ nguyên.

### P3: Writing có chấm AI
- Bảng 4.3, `EssayGrader`, chấm bất đồng bộ, rubric trong `resources/rubrics/`.
- Seed ≥ 6 đề Task 1 (các dạng biểu đồ khác nhau) và ≥ 6 đề Task 2 (đủ 5 dạng).
- **Nghiệm thu:** nộp bài → có điểm 4 tiêu chí + feedback JSON hợp lệ; bài < số từ tối thiểu bị cảnh báo trước khi nộp; LLM lỗi thì trạng thái FAILED và cho chấm lại.

### P4: Speaking
- Bảng 4.4, ghi âm, upload, speech-to-text, `SpeechGrader`.
- **Nghiệm thu:** hoàn thành được Part 2 có đủ 1 phút chuẩn bị + tối đa 2 phút nói, nhận transcript và feedback.

### P5: Mock test đầy đủ + điều chỉnh lộ trình
- Player thi đủ 4 kỹ năng, đếm giờ, autosave, trang kết quả theo band.
- Nộp mock → ghi `band_record` → sinh lại phần còn lại của lộ trình.
- **Nghiệm thu:** reload giữa chừng không mất câu trả lời; band tổng làm tròn đúng quy tắc 3.2 (có test).

### P6: Admin + mở rộng nội dung
- CRUD + import/export JSON cho mọi loại nội dung; preview đề trước khi publish.

---

## 8. Quy ước cho agent

- Không đổi URL API đang có; chỉ thêm mới.
- Mọi thay đổi schema đi qua Flyway migration, không sửa migration đã tồn tại.
- Backend: Java 21, Spring Boot 3.4, Lombok, package theo `domain / repo / service / web / security / config`.
- Frontend: Angular 19, standalone component, `signal`, gọi API qua `core/api.service.ts`.
- Mỗi giai đoạn có unit test cho logic thuần (grader, quy đổi band, roadmap generator).
- **Bản quyền nội dung:** không sao chép đề từ sách Cambridge IELTS hay các trang luyện thi. Chỉ dùng nội dung tự viết, do AI sinh rồi biên tập lại, hoặc từ nguồn có giấy phép phù hợp ở mục 9. Mỗi nội dung lưu `source` và `license`.

---

## 9. Tài liệu và nguồn nội dung

### 9.1 Chính thức: dùng để tham chiếu format và rubric
| Tài liệu | Link | Dùng cho |
|---|---|---|
| Writing Band Descriptors (bản công khai, cập nhật 05/2023) | https://ielts.org/cdn/Guides/ielts-writing-band-descriptors.pdf | Rubric chấm AI Writing |
| Speaking Band Descriptors (bản công khai) | https://ielts.org/cdn/ielts-guides/ielts-speaking-band-descriptors.pdf | Rubric chấm AI Speaking |
| Academic Reading sample tasks | https://ielts.org/cdn/Sample-tests/ielts-academic-reading-sample-tasks-2023.pdf | Mẫu đủ các dạng câu hỏi |
| General Reading sample tasks | https://ielts.org/cdn/Sample-tests/ielts-general-reading-sample-tasks-2023.pdf | Như trên, cho General |
| Format Academic Reading | https://ielts.org/take-a-test/test-types/ielts-academic-test/ielts-academic-format-reading | Định nghĩa dạng câu hỏi |
| Các dạng câu hỏi Reading (IDP) | https://ielts.idp.com/prepare/article-question-types-academic-reading | Định nghĩa dạng câu hỏi |
| Hướng dẫn bài Reading (British Council) | https://takeielts.britishcouncil.org/what-is-ielts/how-it-works/test-format/reading | Định nghĩa dạng câu hỏi |

Các tài liệu trên **chỉ để tham chiếu**: không import nguyên đề vào app để phát hành. Riêng band descriptors có thể đưa vào prompt chấm AI, kèm ghi nguồn.

### 9.2 Nội dung có giấy phép mở: có thể đưa vào app
| Nguồn | Giấy phép | Dùng cho |
|---|---|---|
| VOA Learning English (https://learningenglish.voanews.com) | Public domain, cần ghi credit `learningenglish.voanews.com` | Audio + transcript cho Listening/Dictation, bài đọc nền (band 4–6) |
| Tatoeba (https://tatoeba.org/en/downloads) | CC BY 2.0 FR (một phần CC0) | Câu ví dụ cho từ vựng |
| Free Dictionary API (https://dictionaryapi.dev) | Miễn phí, không cần key | Phiên âm, audio phát âm, định nghĩa |
| LanguageTool (mã nguồn mở, tự host được) | LGPL | Bắt lỗi ngữ pháp/chính tả cho Writing trước khi gửi AI |

### 9.3 Danh sách từ vựng: kiểm tra điều khoản trước khi phát hành
| Danh sách | Link | Ghi chú |
|---|---|---|
| Academic Word List (Coxhead, 570 họ từ, 10 sublist) | https://www.wgtn.ac.nz/lals/resources/academicwordlist | Cốt lõi cho IELTS Academic; tự soạn nghĩa tiếng Việt + ví dụ |
| Oxford 3000 / 5000 theo CEFR | https://www.oxfordlearnersdictionaries.com/wordlists/oxford3000-5000 | Bản quyền OUP: chỉ tham chiếu để gán level, không phân phối lại file |

### 9.4 Đề luyện miễn phí cho người học (link ra ngoài, không nhúng)
- British Council IELTS Ready: https://takeielts.britishcouncil.org/prepare/ielts-ready
- British Council free practice tests: https://takeielts.britishcouncil.org/take-ielts/prepare/free-ielts-english-practice-tests/reading
- IDP IELTS Prepare: https://ielts.idp.com/prepare

Có thể làm một trang "Tài nguyên ngoài" trong app liệt kê các link này.
