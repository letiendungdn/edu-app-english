# Bài 3: Database: Postgres, H2, JPA và Flyway

**Mục tiêu:** hiểu dữ liệu của app được lưu thế nào, cách Java nói chuyện với database, cách thay đổi cấu trúc bảng an toàn, và các lỗi hiệu năng hay gặp.

---

## 1. Database quan hệ trong 5 phút

Dữ liệu nằm trong **bảng** (table). Mỗi **dòng** (row) là một bản ghi, mỗi **cột** (column) là một thuộc tính.

```text
users
┌────┬─────────────────┬──────────────┐
│ id │ email           │ password_hash│
├────┼─────────────────┼──────────────┤
│  1 │ demo@edu.app    │ $2a$10$...   │
└────┴─────────────────┴──────────────┘

ielts_profiles
┌─────────┬──────────┬─────────────┬─────────────┐
│ user_id │ module   │ target_band │ exam_date   │
├─────────┼──────────┼─────────────┼─────────────┤
│       1 │ ACADEMIC │         6.5 │ 2027-01-12  │
└─────────┴──────────┴─────────────┴─────────────┘
```

- **Khoá chính** (primary key): cột định danh duy nhất mỗi dòng, thường là `id`.
- **Khoá ngoại** (foreign key): cột trỏ tới dòng ở bảng khác. `ielts_profiles.user_id` trỏ tới `users.id`. Database **từ chối** lưu hồ sơ cho user không tồn tại.
- **SQL**: ngôn ngữ truy vấn. `SELECT email FROM users WHERE id = 1;`

**Vì sao dùng database quan hệ cho app này?** Dữ liệu có cấu trúc rõ và liên kết chặt (user ↔ hồ sơ ↔ lộ trình ↔ task), và cần **transaction**: nộp bài thi phải ghi điểm, ghi band, cập nhật lộ trình cùng lúc.

---

## 2. Hai database: H2 và Postgres

| | H2 | PostgreSQL |
|---|---|---|
| Khi nào | `mvn spring-boot:run` local, khi chạy test | Docker (profile `platform`), môi trường thật |
| Cài đặt | Không cần, là thư viện Java | Container `en-postgres` |
| Dữ liệu ở | File `backend/data/english.mv.db` | Volume `postgres_data` |
| Xem dữ liệu | http://localhost:8080/h2 (user `sa`, mật khẩu trống) | `docker exec -it en-postgres psql -U english -d english` |

H2 chạy ở **chế độ PostgreSQL** (`MODE=PostgreSQL` trong URL ở `application.yml`), nên cả hai dùng **cùng một bộ migration**. Bản trước có hai thư mục migration riêng (`db/migration` cho H2, `db/postgresql` cho Postgres): mỗi thay đổi phải viết hai lần, sớm muộn sẽ lệch nhau.

> **Đánh đổi:** H2 chế độ PostgreSQL **giống**, không phải **là** Postgres. Một số hàm và kiểu dữ liệu khác nhau (ví dụ `TEXT`, xem mục 6). Ở công ty, test tích hợp thường chạy trên Postgres thật bằng **Testcontainers** (thư viện dựng Postgres trong Docker riêng cho test). Đó là bước nâng cấp tốt khi bạn đã quen Docker.

---

## 3. JPA và Hibernate: bảng thành class Java

Viết SQL tay cho mọi thao tác rất mệt và dễ sai. **JPA** là chuẩn Java để ánh xạ bảng thành class. **Hibernate** là thư viện cài đặt chuẩn đó. Spring Data JPA thêm một lớp tiện lợi lên trên.

### 3.1 Entity

`domain/IeltsProfile.java`:

```java
@Getter @Setter                     // Lombok tự sinh getter/setter khi build
@Entity                             // class này ứng với một bảng
@Table(name = "ielts_profiles")
public class IeltsProfile {
  @Id private Long userId;          // khoá chính

  @Enumerated(EnumType.STRING)      // lưu enum dạng chữ "ACADEMIC", không phải số 0
  @Column(nullable = false)
  private Enums.IeltsModule module = Enums.IeltsModule.ACADEMIC;

  private Double currentBand;       // Double (có thể null) vs double (không thể null)
  private double targetBand;
  private LocalDate examDate;
  ...
  @PrePersist void onCreate() { createdAt = updatedAt = Instant.now(); }  // chạy trước khi INSERT
}
```

**Tên cột tự suy ra:** Spring đổi `targetBand` thành `target_band`. Có một bẫy thật đã gặp trong repo: `scoreP` (chữ hoa ở **cuối** tên) thành `scorep` chứ không phải `score_p`, vì quy tắc chỉ chèn gạch dưới khi có chữ thường đứng **sau**. Cách sửa là ghi rõ tên cột:

```java
@Column(name = "score_p")
private Double scoreP;
```

**Vì sao `EnumType.STRING`?** Mặc định JPA lưu enum theo **thứ tự** (0, 1, 2). Ai đó chèn giá trị mới vào giữa enum là toàn bộ dữ liệu cũ đổi nghĩa mà không ai hay. Lưu chữ thì an toàn.

### 3.2 Quan hệ

`domain/QuestionGroup.java`:

```java
@OneToMany(mappedBy = "group", cascade = CascadeType.ALL, orphanRemoval = true)
@OrderBy("number ASC")
private List<Question> questions = new ArrayList<>();
```

`domain/Question.java`:

```java
@ManyToOne(fetch = FetchType.LAZY)
@JoinColumn(name = "group_id", nullable = false)
private QuestionGroup group;
```

- Một nhóm có nhiều câu (`@OneToMany`), một câu thuộc một nhóm (`@ManyToOne`). Cột khoá ngoại `group_id` nằm ở bảng `questions`.
- `cascade = ALL`: lưu nhóm thì lưu luôn các câu bên trong. `DataSeeder.saveGroups` chỉ gọi `groups.save(group)` một lần.
- `orphanRemoval = true`: bỏ một câu khỏi danh sách thì nó bị xoá khỏi database.
- `LAZY`: đọc câu hỏi thì **chưa** đọc nhóm, chỉ đọc khi code gọi `getGroup()`.

**Khi nào KHÔNG dùng quan hệ JPA?** `RoadmapTask` lưu `roadmapId` là một `Long` thường, không phải `@ManyToOne Roadmap`. Task không cần điều hướng ngược lên lộ trình. Quan hệ JPA thêm độ phức tạp (lazy loading, cascade), chỉ dùng khi thật sự cần đi theo nó.

Một kiểu đặc biệt: nhóm câu hỏi thuộc **hoặc** bài đọc **hoặc** bài nghe. Đó là quan hệ **đa hình**, JPA không biểu diễn gọn được, nên lưu hai cột `owner_type` + `owner_id`. Đánh đổi: database **không** kiểm tra được khoá ngoại cho `owner_id`, nên code phải tự đảm bảo.

### 3.3 Lưu danh sách vào một cột

`Question.acceptedAnswers` là `List<String>`, lưu thành chuỗi JSON `["1990","nineteen ninety"]` trong cột `VARCHAR` nhờ `domain/StringListConverter.java`:

```java
@Convert(converter = StringListConverter.class)
private List<String> acceptedAnswers;
```

Vì sao không dùng kiểu `JSONB` của Postgres? H2 không có `JSONB`, mà ta muốn **một** bộ migration. Đánh đổi: không truy vấn được bên trong JSON bằng SQL. Với đáp án câu hỏi thì không bao giờ cần, nên chấp nhận được.

### 3.4 Repository: truy vấn không cần viết SQL

`repo/RoadmapTaskRepository.java`:

```java
public interface RoadmapTaskRepository extends JpaRepository<RoadmapTask, Long> {
  List<RoadmapTask> findByRoadmapIdAndDueDateOrderByIdAsc(Long roadmapId, LocalDate dueDate);
  long countByRoadmapIdAndStatusAndDueDateBefore(Long roadmapId, TaskStatus status, LocalDate before);
}
```

Chỉ là **interface**, không có code bên trong. Spring Data đọc **tên method** và tự sinh SQL:

```text
findBy RoadmapId And DueDate OrderBy Id Asc
→ SELECT * FROM roadmap_tasks WHERE roadmap_id = ? AND due_date = ? ORDER BY id ASC
```

`JpaRepository` cho sẵn `save`, `findById`, `findAll`, `count`, `delete`...

Tên quá dài hoặc truy vấn phức tạp thì viết JPQL (giống SQL nhưng dùng tên class và field):

```java
@Query("select g.ownerId, count(q) from QuestionGroup g join g.questions q"
     + " where g.ownerType = :ownerType group by g.ownerId")
List<Object[]> countQuestionsByOwner(@Param("ownerType") OwnerType ownerType);
```

Truy vấn này đếm câu hỏi của **mọi** bài trong **một** câu SQL, để trang danh sách bài đọc không phải tải từng bài (xem N+1 ở mục 7).

---

## 4. Transaction

Transaction là nhóm thao tác **hoặc thành công hết, hoặc không có gì xảy ra**.

Ví dụ: nộp bài thi (`TestService.submit`) ghi điểm từng câu, band Listening, band Reading, trạng thái bài, bài Writing, tiến độ lộ trình. Nếu ghi band xong rồi mất điện trước khi ghi trạng thái, người học thấy band mà bài vẫn "đang làm". Transaction ngăn chuyện đó.

```java
@Transactional                    // bắt đầu trước khi vào method, commit khi ra, rollback khi có exception
public AttemptResult submit(...)

@Transactional(readOnly = true)   // chỉ đọc: Hibernate bỏ bước kiểm tra thay đổi, nhanh hơn
public List<TestListItem> list(...)
```

**Dirty checking:** trong transaction, entity đọc từ database được Hibernate "theo dõi". Bạn chỉ cần `setStatus(...)`, không cần gọi `save()`, vì Hibernate tự `UPDATE` lúc commit. Xem `RoadmapService.updateTask`: chỉ có `task.setStatus(status)`, không có `save`.

Bốn tính chất **ACID** (đáng thuộc cho phỏng vấn):
- **Atomicity**: tất cả hoặc không có gì.
- **Consistency**: ràng buộc (khoá ngoại, `NOT NULL`, `UNIQUE`) luôn đúng.
- **Isolation**: transaction chạy song song không thấy dữ liệu dở dang của nhau.
- **Durability**: commit xong là dữ liệu còn, kể cả khi mất điện.

---

## 5. Flyway: lịch sử thay đổi cấu trúc bảng

Code thay đổi thì bảng cũng phải đổi theo: thêm cột, thêm bảng. Làm tay trên từng máy thì sớm muộn có máy thiếu cột. **Flyway** giải quyết bằng các file SQL đánh số:

```text
backend/src/main/resources/db/migration/
  V1__baseline.sql                 các bảng ban đầu (users, vocabulary, reading_passages...)
  V2__long_text_as_varchar.sql     đổi kiểu 3 cột văn bản dài
  V3__ielts.sql                    toàn bộ schema IELTS + chuyển dữ liệu câu hỏi cũ
```

Mỗi lần app khởi động, Flyway:
1. Đọc bảng `flyway_schema_history`: các file nào đã chạy.
2. Chạy các file mới theo thứ tự số.
3. Ghi lại tên và **checksum** (dấu vân tay nội dung) của từng file.

**Luật bất di bất dịch: không sửa migration đã chạy ở máy khác.** Sửa thì checksum đổi, Flyway từ chối khởi động. Muốn đổi gì thì viết file mới. Ví dụ, header của `V1__baseline.sql` vẫn ghi "Baseline cho PostgreSQL" và nhắc tới `TEXT`. Nó đã lỗi thời nhưng không được sửa.

`application.yml` đặt `ddl-auto: validate`: Hibernate **không** tự sửa bảng, chỉ kiểm tra entity khớp bảng. Lệch là app không lên, và đó là điều tốt: lỗi lộ ra lúc khởi động thay vì lúc người dùng bấm nút.

### Migration chuyển dữ liệu

`V3__ielts.sql` không chỉ tạo bảng mà còn **chuyển dữ liệu**: câu hỏi trắc nghiệm cũ lưu đáp án là chữ ("Blue"), bảng mới lưu chữ cái ("B"). Đoạn quan trọng:

```sql
INSERT INTO questions (group_id, number, prompt, accepted_answers, explanation, legacy_id)
SELECT g.id,
       ROW_NUMBER() OVER (PARTITION BY q.passage_id ORDER BY q.sort_order, q.id),   -- đánh số 1, 2, 3 trong từng bài
       q.question,
       '["' || COALESCE((SELECT CASE o.sort_order WHEN 1 THEN 'A' WHEN 2 THEN 'B' ... END
                         FROM reading_options o
                         WHERE o.question_id = q.id AND o.text = q.answer      -- tìm lựa chọn trùng đáp án cũ
                         ORDER BY o.sort_order FETCH FIRST 1 ROWS ONLY), 'A') || '"]',
       ...
```

Cột tạm `legacy_id` nối câu hỏi cũ với câu hỏi mới để chép các lựa chọn sang, rồi bị xoá ở cuối file. Migration dữ liệu rủi ro hơn migration schema nhiều, nên có test riêng: `test/.../config/QuestionMigrationTest.java` dựng database tới V2, chèn dữ liệu kiểu cũ, chạy V3, rồi kiểm tra kết quả.

---

## 6. Một bài học thật: `TEXT` và CLOB

Khi gộp hai bộ migration, app không khởi động được:

```text
Schema-validation: wrong column type in column [explanation] in table [grammar_lessons];
found [character large object (Types#CLOB)], but expecting [text (Types#VARCHAR)]
```

Nguyên nhân: Postgres coi `TEXT` là chuỗi bình thường, H2 lại coi `TEXT` là CLOB (đối tượng lớn). Hibernate validate thấy hai kiểu khác nhau. Cách sửa trong `V2`:

```sql
ALTER TABLE grammar_lessons ALTER COLUMN explanation SET DATA TYPE VARCHAR;   -- VARCHAR không giới hạn độ dài
```

Trên Postgres, `VARCHAR` không độ dài và `TEXT` hoàn toàn như nhau, còn trên H2 nó là chuỗi bình thường. Quy ước của repo từ đó: **văn bản dài dùng `VARCHAR` không độ dài**.

Bài học lớn hơn: lỗi không nằm ở code, mà ở **khác biệt giữa hai môi trường**. Senior luôn hỏi "môi trường test có giống môi trường thật không?".

---

## 7. Hiệu năng: N+1 và index

### N+1

Trang danh sách bài đọc cần số câu hỏi của mỗi bài. Cách ngây thơ:

```java
for (ReadingPassage p : passages.findAll()) {                    // 1 câu SQL
  int count = groups.findByOwner(..., p.getId()).stream()         // +1 câu SQL MỖI bài
      .mapToInt(g -> g.getQuestions().size()).sum();               // +1 câu SQL MỖI nhóm (lazy)
}
```

100 bài thành vài trăm câu SQL. Đó là **lỗi N+1**, lỗi hiệu năng phổ biến nhất khi dùng JPA. Repo dùng **một** câu `countQuestionsByOwner` (mục 3.4) trả về map `bài → số câu`.

Phát hiện N+1: thêm vào `application.yml` khi đang debug

```yaml
spring.jpa.show-sql: true
```

rồi đếm số câu SQL trong log sau mỗi request.

### Index

`V3__ielts.sql` tạo index cho những truy vấn chạy thường xuyên:

```sql
CREATE INDEX ix_roadmap_tasks_roadmap_due ON roadmap_tasks (roadmap_id, due_date);
```

`today()` chạy mỗi lần người học mở app, lọc theo `roadmap_id` và `due_date`. Không có index thì database đọc **toàn bộ** bảng task (người dùng × khoảng 250 task). Có index thì nhảy thẳng tới đúng dòng, như mục lục sách.

Index không miễn phí: mỗi lần INSERT/UPDATE phải cập nhật thêm index. Chỉ tạo cho truy vấn thật sự hay chạy.

---

## 8. Bảng đáng nhớ

| Bảng | Ý nghĩa |
|------|---------|
| `users` | tài khoản, `password_hash` (không bao giờ lưu mật khẩu thật) |
| `vocabulary`, `vocab_topics`, `srs_cards` | từ vựng và lịch ôn SM-2 theo từng người |
| `grammar_*` | chủ đề, bài, ví dụ, bài tập ngữ pháp |
| `reading_passages`, `listening_tracks` | bài đọc, bài nghe (có `module`, `ielts_part`, `band_min/max`) |
| `question_groups`, `questions`, `question_options`, `question_group_options` | ngân hàng câu hỏi chung, 17 dạng |
| `reading_attempts`, `listening_attempts`, `dictation_attempts` | lần nộp bài luyện |
| `ielts_profiles` | mục tiêu, ngày thi, phút học |
| `band_records` | lịch sử band theo kỹ năng và nguồn (placement, mock, luyện) |
| `band_conversions` | bảng quy đổi điểm thô /40 sang band |
| `ielts_tests`, `test_sections`, `test_attempts`, `attempt_answers` | bài thi và bài làm |
| `writing_prompts`, `writing_submissions` | đề và bài viết, điểm 4 tiêu chí, feedback JSON |
| `speaking_prompts`, `speaking_submissions` | câu hỏi và bài nói, transcript, đường dẫn file ghi âm |
| `roadmaps`, `roadmap_phases`, `roadmap_tasks` | lộ trình có phiên bản |
| `study_sessions` | giây học mỗi ngày, `UNIQUE(user_id, study_date)` |

---

## 9. Thực hành với SQL

Mở http://localhost:8080/h2 (JDBC URL copy từ `application.yml`, user `sa`). Chạy thử:

```sql
-- Lộ trình đang chạy của demo, đếm task theo trạng thái
SELECT t.status, COUNT(*) FROM roadmap_tasks t
JOIN roadmaps r ON r.id = t.roadmap_id
JOIN users u ON u.id = r.user_id
WHERE u.email = 'demo@edu.app' AND r.status = 'ACTIVE'
GROUP BY t.status;

-- Bài đọc nào có nhiều câu hỏi nhất
SELECT p.title, COUNT(q.id) AS so_cau
FROM reading_passages p
JOIN question_groups g ON g.owner_type = 'READING_PASSAGE' AND g.owner_id = p.id
JOIN questions q ON q.group_id = g.id
GROUP BY p.title ORDER BY so_cau DESC;

-- Bảng quy đổi Listening
SELECT raw_min, raw_max, band FROM band_conversions WHERE skill = 'LISTENING' ORDER BY band DESC;
```

---

## 10. Việc tự làm

**Junior**
1. Chạy ba câu SQL ở mục 9. Giải thích từng `JOIN` bằng lời.
2. Tìm trong `V3__ielts.sql` câu tạo bảng `writing_submissions`. Đối chiếu từng cột với `WritingSubmission.java`.
3. Thêm method `countByUserId(Long userId)` vào `WritingSubmissionRepository`, dùng nó hiện tổng số bài đã viết ở đâu đó.

**Mid**
4. Thêm cột `difficulty` (INTEGER, có thể null) cho `writing_prompts`: viết `V4__writing_difficulty.sql`, thêm field vào entity, chạy `mvn test`.
5. Bật `show-sql`, mở trang "Hôm nay", đếm số câu SQL. Tìm chỗ có thể gộp.
6. Viết test giống `QuestionMigrationTest` cho chính migration V4 của bạn.

**Senior**
7. `RoadmapService.generate` lưu khoảng 250 task bằng `saveAll`. Với `GenerationType.IDENTITY`, Hibernate **không** gộp INSERT thành batch được. Tìm hiểu vì sao, và đề xuất cách (sequence + `hibernate.jdbc.batch_size`). Đo thời gian trước và sau.
8. Lộ trình sinh lại tạo **bản mới**, bản cũ chuyển `ARCHIVED`. Sau một năm, một người có thể có 100 bản × 250 task. Đề xuất chính sách dọn dữ liệu mà vẫn giữ được thống kê "đã làm bao nhiêu việc".

---

## 11. Góc nhìn senior

- **Schema là hợp đồng lâu dài nhất trong hệ thống.** Code đổi hằng tuần, dữ liệu sống nhiều năm. Đặt tên cột rõ, dùng `NOT NULL` khi có thể, enum lưu chữ.
- **Migration phải chạy được trên dữ liệu thật,** không chỉ trên database trống. V3 có test riêng cho phần chuyển dữ liệu vì hỏng ở đó là mất câu hỏi của người dùng.
- **Thiết kế có phiên bản thay vì sửa đè.** Lộ trình và band đều là lịch sử chỉ thêm, không sửa (append-only). Nhờ vậy vẽ được biểu đồ band theo thời gian và không bao giờ mất "việc đã làm" khi sinh lại lộ trình.

Tiếp theo: [Bài 4: Đăng nhập JWT](./learn-auth.md).
