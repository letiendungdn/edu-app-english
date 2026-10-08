# Bài 15: Chọn công nghệ: Angular hay React, Java (Spring) hay NestJS

**Mục tiêu:** hiểu mỗi công nghệ mạnh ở đâu, yếu ở đâu, và **tự đưa ra quyết định có lý lẽ** cho một dự án cụ thể. Phỏng vấn senior gần như luôn có câu "vì sao bạn chọn X mà không chọn Y?". Câu trả lời "vì em quen" là câu trả lời junior.

Bài này dùng chính hai dự án của bạn làm ví dụ: **EDU APP Nihongo** (NestJS) và **EDU APP English** (đã chuyển từ Next.js + NestJS sang Angular + Spring Boot).

---

## 1. Trước khi so sánh: chọn công nghệ là chọn đánh đổi

Không có công nghệ "tốt nhất". Chỉ có công nghệ **hợp nhất với tình huống**. Tình huống gồm:

| Yếu tố | Câu hỏi |
|--------|---------|
| **Đội ngũ** | Đội đang giỏi gì? Tuyển người ở thị trường của bạn có dễ không? |
| **Quy mô và tuổi thọ** | Dự án sống 6 tháng hay 10 năm? 3 người hay 50 người cùng sửa? |
| **Loại sản phẩm** | Trang nội dung cần SEO? Ứng dụng nội bộ nhiều form? Hệ thống tài chính? |
| **Hệ sinh thái** | Có sẵn thư viện cho việc cần làm không? (thanh toán, AI, xuất PDF...) |
| **Vận hành** | Ai deploy, ai trực sự cố? Hạ tầng hiện có là gì? |
| **Tốc độ ra sản phẩm** | Cần bản demo trong 2 tuần, hay cần nền móng chắc cho 5 năm? |

Đội 3 người toàn dân JavaScript mà chọn Java chỉ vì "Java chuyên nghiệp hơn" là quyết định sai, dù Java rất tốt.

---

## 2. Frontend: Angular và React

### 2.1 Bản chất khác nhau

| | Angular | React |
|---|---|---|
| Là gì | **Framework** đầy đủ | **Thư viện** vẽ giao diện |
| Ai làm | Google | Meta |
| Đi kèm sẵn | router, HTTP client, form, DI, test, build, i18n | chỉ có phần vẽ giao diện và quản lý trạng thái component |
| Phần còn lại | đã chọn sẵn cho bạn | bạn tự chọn: router (React Router, TanStack Router), gọi API (TanStack Query, SWR), form (React Hook Form), state (Zustand, Redux)... |
| Ngôn ngữ | TypeScript bắt buộc | JavaScript hoặc TypeScript |
| Giao diện viết bằng | template HTML riêng (`@if`, `@for`) | JSX: HTML viết trong JavaScript |
| Framework "đầy đủ" phổ biến | chính nó | **Next.js** (thêm render phía server, router theo file, API route) |

Ví von: Angular là **căn hộ bàn giao nội thất**: vào ở được ngay, mọi phòng theo một phong cách, muốn đổi bếp thì khó. React là **căn hộ thô**: tự chọn từng món, đẹp theo ý mình, nhưng phải tự quyết rất nhiều thứ, và mỗi nhà một kiểu.

### 2.2 Cùng một tính năng, viết hai cách

Hiện danh sách bài đọc, gọi API, có trạng thái đang tải.

**Angular** (giống `pages/reading-list.component.ts` trong repo):

```ts
@Component({
  selector: 'app-reading-list',
  imports: [RouterLink],
  template: `
    @if (loading()) { <p>Đang tải…</p> }
    @for (item of items(); track item.id) {
      <a [routerLink]="['/reading', item.id]">{{ item.title }}</a>
    }
  `,
})
export class ReadingListComponent implements OnInit {
  private api = inject(ApiService);          // dependency injection có sẵn
  items = signal<PassageListItem[]>([]);
  loading = signal(true);

  ngOnInit() {
    this.api.reading('').subscribe((items) => {
      this.items.set(items);
      this.loading.set(false);
    });
  }
}
```

**React** (với TanStack Query, thư viện gọi API phổ biến nhất):

```tsx
export function ReadingList() {
  const { data: items = [], isLoading } = useQuery({
    queryKey: ['reading'],
    queryFn: () => fetch('/api/reading').then((r) => r.json()),
  });

  if (isLoading) return <p>Đang tải…</p>;
  return items.map((item) => (
    <Link key={item.id} to={`/reading/${item.id}`}>{item.title}</Link>
  ));
}
```

Nhận xét:
- React **ngắn hơn**: component là một hàm, giao diện là giá trị trả về. Cache, tải lại, trạng thái lỗi đến từ thư viện TanStack Query mà **bạn phải chọn và học thêm**.
- Angular **dài hơn nhưng đồng dạng**: mọi component trong mọi dự án Angular trông giống nhau. Người mới vào đội đọc là hiểu ngay.

### 2.3 So sánh chi tiết

| Tiêu chí | Angular | React |
|----------|---------|-------|
| **Đường học ban đầu** | dốc: component, DI, RxJS, signal, router, decorator cùng lúc | thoải: một hàm trả JSX là có giao diện |
| **Đường học về sau** | phẳng: học một lần, dự án nào cũng giống nhau | dốc theo kiểu khác: mỗi dự án một bộ thư viện, phải học lại |
| **Tính thống nhất trong đội lớn** | cao: framework áp quy ước | phụ thuộc kỷ luật của đội |
| **Tự do kiến trúc** | thấp | cao |
| **Hệ sinh thái và cộng đồng** | lớn, tập trung | lớn nhất ngành frontend, rất phân mảnh |
| **Thị trường việc làm** | nhiều ở doanh nghiệp, ngân hàng, outsourcing châu Âu, Nhật | nhiều nhất, đặc biệt startup và công ty sản phẩm |
| **Render phía server, SEO** | có (Angular SSR) nhưng ít người dùng | rất mạnh qua Next.js |
| **Form phức tạp, nhiều kiểm tra** | rất mạnh (Reactive Forms có sẵn) | tốt nhưng cần thư viện ngoài |
| **Nâng cấp phiên bản** | lịch rõ ràng, có công cụ tự sửa code (`ng update`) | thư viện lõi ít thay đổi phá vỡ, nhưng phải nâng từng thư viện ngoài |
| **Kích thước app nhỏ** | khung nặng hơn một chút (repo này: khoảng 386 kB lần tải đầu) | nhẹ hơn khi app nhỏ |
| **Mobile cùng codebase** | Ionic | React Native: mạnh hơn hẳn |

### 2.4 Khi nào chọn cái nào

**Chọn Angular khi:**
- Ứng dụng **nội bộ, doanh nghiệp, nhiều màn hình form**: quản trị, ngân hàng, bảo hiểm, ERP, hệ thống học tập có nhiều trang nghiệp vụ.
- **Đội lớn hoặc hay đổi người**: cần mọi người viết giống nhau, người mới vào đọc được ngay.
- Dự án **sống lâu** (5–10 năm), cần lộ trình nâng cấp có kế hoạch.
- Đội đến từ **Java/C#**: DI, decorator, class, service gần như giống hệt Spring.

**Chọn React khi:**
- **Sản phẩm hướng người dùng cuối**, cần ra nhanh, đổi giao diện liên tục: startup, app tiêu dùng.
- **SEO và tốc độ tải trang đầu quan trọng**: trang nội dung, thương mại điện tử, landing page. Dùng Next.js.
- Có kế hoạch làm **app mobile** chung kiến thức (React Native).
- Đội nhỏ, giỏi, muốn tự chọn từng mảnh.
- Muốn **tuyển dễ**: nhiều ứng viên biết React nhất.

**Đừng chọn chỉ vì:** "nhanh hơn". Ở quy mô gần như mọi app, cả hai đều đủ nhanh. Chậm thường đến từ code của bạn (vẽ lại quá nhiều, gọi API thừa), không phải từ framework.

---

## 3. Backend: Java (Spring Boot) và NestJS

### 3.1 Bản chất khác nhau

| | Spring Boot | NestJS |
|---|---|---|
| Ngôn ngữ | Java (hoặc Kotlin) | TypeScript |
| Chạy trên | JVM | Node.js |
| Tuổi | Spring từ 2003, Boot từ 2014 | từ 2017 |
| Cảm hứng | chính nó là chuẩn mực | **lấy cảm hứng từ Angular và Spring**: module, DI, decorator |
| ORM phổ biến | JPA/Hibernate, jOOQ | Prisma, TypeORM, Drizzle |
| Mô hình chạy | nhiều luồng; Java 21 có **virtual thread** để xử lý rất nhiều việc chờ I/O | một luồng sự kiện (event loop), bất đồng bộ bằng `async/await` |

NestJS **trông rất giống Spring**. Đó là chủ đích của nó: mang kiến trúc Spring sang thế giới TypeScript.

### 3.2 Cùng một tính năng, viết hai cách

API `GET /api/reading/:id`.

**Spring Boot** (rút gọn từ `ReadingController` và `ContentService` trong repo):

```java
@RestController
@RequestMapping("/api/reading")
public class ReadingController {
  private final ContentService content;
  public ReadingController(ContentService content) { this.content = content; }

  @GetMapping("/{id}")
  public PassageDetail readingDetail(@PathVariable Long id) {
    return content.reading(id);
  }
}

@Service
public class ContentService {
  @Transactional(readOnly = true)
  public PassageDetail reading(Long id) {
    ReadingPassage p = passages.findById(id)
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy bài đọc"));
    return new PassageDetail(p.getId(), p.getTitle(), ...);
  }
}
```

**NestJS** (viết minh hoạ theo kiểu app tiếng Nhật, dùng Prisma):

```ts
@Controller('api/reading')
export class ReadingController {
  constructor(private readonly content: ContentService) {}

  @Get(':id')
  readingDetail(@Param('id', ParseIntPipe) id: number) {
    return this.content.reading(id);
  }
}

@Injectable()
export class ContentService {
  constructor(private readonly prisma: PrismaService) {}

  async reading(id: number) {
    const p = await this.prisma.readingPassage.findUnique({ where: { id } });
    if (!p) throw new NotFoundException('Không tìm thấy bài đọc');
    return { id: p.id, title: p.title, ... };
  }
}
```

Gần như từng dòng tương ứng: `@RestController` ↔ `@Controller`, `@GetMapping` ↔ `@Get`, constructor injection ↔ constructor injection. **Học kỹ một bên thì sang bên kia rất nhanh.** Đó là lý do bộ tài liệu này nhấn mạnh khái niệm (DI, transaction, tầng lớp) hơn cú pháp.

Khác biệt thật nằm ở những thứ bên dưới.

### 3.3 So sánh chi tiết

| Tiêu chí | Spring Boot (Java) | NestJS (Node/TypeScript) |
|----------|-------------------|--------------------------|
| **Chung ngôn ngữ với frontend** | không | **có**: chia sẻ kiểu dữ liệu, người làm full-stack dễ hơn |
| **Tốc độ khởi động, bộ nhớ** | chậm hơn (repo này: 20–40 giây, vài trăm MB) | nhanh (vài giây, ít RAM) |
| **Hiệu năng việc nặng CPU** | rất tốt, đa luồng thật | kém: tính toán nặng chặn event loop, cần worker thread |
| **Hiệu năng việc chờ I/O** (gọi DB, gọi API) | rất tốt, nhất là với virtual thread | rất tốt, đó là thế mạnh của Node |
| **Transaction, ORM** | JPA/Hibernate cực mạnh nhưng nhiều "phép thuật" (lazy loading, dirty checking) | Prisma rõ ràng, dễ đọc, nhưng truy vấn phức tạp đôi khi phải viết SQL tay |
| **Hệ sinh thái doanh nghiệp** | rộng nhất: bảo mật, batch, tích hợp hệ thống cũ, chuẩn công nghiệp | đủ cho web và API, mỏng hơn ở mảng doanh nghiệp |
| **Kiểu dữ liệu lúc chạy** | Java kiểm tra kiểu cả lúc chạy | TypeScript **mất kiểu khi chạy**: dữ liệu từ ngoài vào phải kiểm tra lại bằng `class-validator` hoặc Zod |
| **Độ ổn định thư viện** | rất cao, ít phá vỡ | thư viện npm thay đổi nhanh, rủi ro chuỗi cung ứng cao hơn |
| **Thị trường việc làm** | ngân hàng, viễn thông, doanh nghiệp lớn, outsourcing (rất nhiều ở Việt Nam) | startup, công ty sản phẩm, team JavaScript |
| **Tốc độ làm bản đầu** | chậm hơn, nhiều cấu hình hơn | nhanh hơn |
| **Serverless (Lambda, Cloud Functions)** | khởi động chậm, cần GraalVM native image | hợp tự nhiên |

### 3.4 Khi nào chọn cái nào

**Chọn Spring Boot khi:**
- Nghiệp vụ **phức tạp, nhiều transaction, cần đúng tuyệt đối**: tài chính, bảo hiểm, đặt chỗ, chấm điểm thi.
- Hệ thống **lớn, sống lâu, nhiều đội**.
- Phải **tích hợp hệ thống doanh nghiệp** (Oracle, SAP, hàng đợi IBM MQ, SOAP).
- Có **xử lý nặng CPU**: tính toán, xử lý dữ liệu lớn, batch.
- Đội hoặc thị trường tuyển dụng mạnh Java.

**Chọn NestJS khi:**
- **Đội JavaScript/TypeScript** làm cả frontend lẫn backend, muốn một ngôn ngữ.
- **API cho web/mobile, nhiều I/O, ít tính toán nặng**: CRUD, BFF (backend-for-frontend), realtime với Socket.io.
- Cần **ra sản phẩm nhanh**, startup, MVP.
- Chạy **serverless** hoặc container nhỏ, cần khởi động nhanh, tốn ít RAM.

---

## 4. Áp vào dự án thật của bạn

### 4.1 EDU APP Nihongo: NestJS + Next.js

Đặc điểm (theo những gì repo English còn nhắc tới): marketplace, coaching qua LiveKit, thanh toán Stripe, Socket.io, nhiều tính năng hướng người dùng cuối.

Phù hợp với NestJS + Next.js vì:
- Nhiều tích hợp dịch vụ bên ngoài có SDK JavaScript tốt (Stripe, LiveKit).
- Trang công khai (giới thiệu khoá học, marketplace) cần SEO, nên Next.js mạnh.
- Realtime với Socket.io rất tự nhiên trên Node.
- Một ngôn ngữ cho cả đội, ra tính năng nhanh.

### 4.2 EDU APP English: chuyển sang Angular + Spring Boot

Đặc điểm:
- **Nhiều màn hình nghiệp vụ, nhiều form, ít trang công khai cần SEO**: onboarding, làm bài, thi có giờ, lộ trình, Writing editor.
- **Nghiệp vụ cần đúng**: chấm điểm theo luật IELTS, quy đổi band, nộp bài thi ghi nhiều bảng cùng lúc (transaction).
- Có **mục tiêu học tập**: bạn học hệ sinh thái Java/Angular, vốn rất phổ biến ở doanh nghiệp và outsourcing tại Việt Nam.

Những gì Angular + Spring làm tốt **trong repo này**:
- `@Transactional` của Spring cho nộp bài thi: ghi điểm, band, Writing, lộ trình trong một transaction, lỗi thì quay lui toàn bộ.
- `@TransactionalEventListener(AFTER_COMMIT)` + `@Async`: chấm AI chạy nền **sau khi** bài đã lưu chắc chắn, chỉ vài dòng khai báo.
- Hibernate validate + Flyway: entity lệch bảng thì app không khởi động, lỗi lộ ra sớm.
- Angular component `question-group` dùng lại ở 4 nơi, kiểu dữ liệu chặt từ API tới template.

Cái giá phải trả, cũng thấy rõ trong repo:
- Backend khởi động 20–40 giây, test tích hợp mất khoảng 30 giây mỗi lớp. NestJS nhanh hơn nhiều.
- Hibernate có bẫy: `scoreP` thành cột `scorep`, `@Lob` lệch kiểu giữa H2 và Postgres, `@Transactional` không chạy khi gọi nội bộ. Prisma ít "phép thuật" hơn.
- Frontend và backend **không chung kiểu dữ liệu**: `IeltsModels.java` và `ielts.models.ts` phải sửa tay cho khớp. Với NestJS + Angular/React có thể chia sẻ trực tiếp, hoặc sinh tự động từ OpenAPI.

**Kết luận cho dự án này:** lựa chọn **hợp lý**, nhưng không phải lựa chọn **duy nhất đúng**. NestJS + React cũng làm tốt app này. Lý do mạnh nhất để chọn Angular + Spring ở đây là **tính chất nghiệp vụ** (nhiều form, nhiều transaction) **cộng với mục tiêu học tập và nghề nghiệp**. Nói được cả hai vế đó trong phỏng vấn là câu trả lời senior.

### 4.3 Bảng gợi ý nhanh

| Loại dự án | Frontend | Backend | Vì sao |
|-----------|----------|---------|--------|
| Landing page, blog, trang bán hàng cần SEO | React (Next.js) | Next.js API hoặc NestJS | render phía server, tải nhanh, một ngôn ngữ |
| MVP startup, đội 2–5 người JS | React | NestJS | nhanh, một ngôn ngữ, tuyển dễ |
| Ứng dụng quản trị nội bộ, nhiều form | Angular | Spring Boot hoặc NestJS | quy ước chặt, form mạnh |
| Ngân hàng, bảo hiểm, chứng khoán | Angular | Spring Boot | transaction, bảo mật, hệ sinh thái doanh nghiệp |
| App web + app mobile chung đội | React + React Native | NestJS | chia sẻ kiến thức và code |
| Realtime: chat, game, cộng tác | React | NestJS (Socket.io) | event loop hợp việc giữ nhiều kết nối |
| Xử lý dữ liệu nặng, batch, tính toán | (bất kỳ) | Spring Boot | đa luồng, hiệu năng CPU |
| Nền tảng học tập nhiều nghiệp vụ (như app này) | Angular hoặc React | Spring Boot hoặc NestJS | quyết theo đội ngũ |

---

## 5. Những sai lầm hay gặp khi chọn

1. **Chọn theo trend.** "Công nghệ X đang hot" không phải lý do. Hỏi: 3 năm nữa ai bảo trì?
2. **Chọn theo benchmark.** "Framework A nhanh hơn B 30%" trong bài đo "hello world" gần như không liên quan tới app có database và gọi API.
3. **Đổi công nghệ để chữa vấn đề không nằm ở công nghệ.** Code rối vì thiếu kiến trúc thì viết lại bằng ngôn ngữ khác vẫn rối.
4. **Viết lại toàn bộ cùng một lúc.** Chuyển công nghệ an toàn là chuyển **từng phần**, hệ thống cũ và mới chạy song song (gọi là "strangler fig"). App English làm được viết lại một lần vì còn nhỏ và chưa có người dùng thật.
5. **Bỏ qua chi phí vận hành.** Thêm một ngôn ngữ backend nghĩa là thêm một bộ công cụ build, giám sát, vá bảo mật, và người trực sự cố phải biết nó.

---

## 6. Lời khuyên cho lộ trình học của bạn

- **Học sâu một bộ trước** (bạn đang có Angular + Spring trong repo này). Hiểu thật kỹ DI, transaction, tầng lớp, test, bảo mật.
- **Sau đó học bộ còn lại bằng cách so sánh.** Viết lại **một** tính năng của repo này (ví dụ API bài đọc) bằng NestJS + Prisma, và một màn hình bằng React. Ghi lại cái gì dễ hơn, cái gì khó hơn. Đó là kinh nghiệm thật, đáng giá hơn mọi bảng so sánh.
- **Khái niệm sống lâu hơn công cụ.** Angular hay React, Spring hay NestJS đều sẽ đổi. HTTP, SQL, transaction, cache, bảo mật, test, thiết kế dữ liệu thì không. Senior là người chuyển công cụ trong vài tuần vì đã nắm chắc khái niệm.

---

## 7. Việc tự làm

**Junior**
1. Viết lại `reading-list.component.ts` bằng React (Vite + TypeScript), gọi cùng API `/api/reading`. Ghi lại 3 điểm khác biệt bạn thấy.
2. Đọc lại code NestJS của app tiếng Nhật, tìm 5 cặp tương ứng với Spring (`@Controller` ↔ `@RestController`...).

**Mid**
3. Viết API `GET /api/reading/:id` và `POST /api/reading/:id/submit` bằng NestJS + Prisma, đọc cùng database Postgres. Chấm bài bằng một bản TypeScript của `AnswerGrader`, chạy chung bộ test case với `AnswerGraderTest`.
4. Sinh kiểu dữ liệu TypeScript tự động từ backend Spring (springdoc-openapi + openapi-typescript), thay cho `ielts.models.ts` viết tay. Đánh giá: đáng công không?

**Senior**
5. Viết một **ADR** (Architecture Decision Record, tài liệu ghi quyết định kiến trúc) cho câu "Vì sao EDU APP English dùng Angular + Spring Boot". Gồm: bối cảnh, các phương án đã cân nhắc, quyết định, hệ quả (tốt và xấu), khi nào nên xem lại quyết định.
6. Giả sử app English có 200.000 người dùng và cần app mobile. Đề xuất có đổi stack không, đổi phần nào, chuyển theo lộ trình nào để không phải dừng sản phẩm.

---

## 8. Góc nhìn senior

- **Câu trả lời đúng gần như luôn là "tuỳ"**, nhưng phải nói được **tuỳ vào cái gì** và **vì sao**.
- **Đội ngũ quan trọng hơn công nghệ.** Một đội giỏi NestJS sẽ làm sản phẩm tốt hơn chính họ làm bằng Spring mà chưa quen.
- **Quyết định phải được ghi lại** (ADR). Hai năm sau, người mới hỏi "sao lại dùng cái này?" thì có câu trả lời, kèm điều kiện để xem lại quyết định.

Quay lại [bản đồ học](./learn-english.md).
