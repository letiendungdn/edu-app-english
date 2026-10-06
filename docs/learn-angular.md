# Bài 1: Angular, giao diện của app

**Mục tiêu:** hiểu một màn hình Angular được dựng thế nào, dữ liệu đi từ API lên màn hình ra sao, và tự viết được một trang mới.

**Thư mục:** `frontend/`. Angular 19, kiểu **standalone component** (không có `NgModule`) và **signal**.

---

## 1. Angular là gì, giải quyết vấn đề gì

Trình duyệt chỉ hiểu HTML, CSS, JavaScript. Viết app nhiều màn hình bằng JavaScript thuần thì rất nhanh rối: đâu là dữ liệu, đâu là giao diện, khi dữ liệu đổi thì phần nào của trang phải vẽ lại?

Angular là một **framework** giải quyết đúng mấy việc đó:

| Vấn đề | Angular giải quyết bằng |
|--------|------------------------|
| Chia giao diện thành mảnh nhỏ dùng lại được | **Component** |
| Dữ liệu đổi thì giao diện tự đổi theo | **Signal** + template binding |
| Nhiều màn hình, mỗi màn hình một URL | **Router** |
| Gọi API, gắn token | **HttpClient** + **interceptor** |
| Logic dùng chung (đăng nhập, gọi API) | **Service** + **dependency injection** |

Code viết bằng **TypeScript**: JavaScript có thêm kiểu dữ liệu. Kiểu giúp trình soạn thảo báo lỗi ngay khi bạn gõ sai tên trường, thay vì đợi tới lúc chạy.

---

## 2. Khởi động: từ `index.html` tới màn hình đầu tiên

```text
src/index.html          có thẻ <app-root>
src/main.ts             bootstrapApplication(AppComponent, appConfig)
src/app/app.config.ts   khai báo router, HttpClient, interceptor
src/app/app.component   khung chung: menu, nút đăng xuất, <router-outlet>
src/app/app.routes.ts   URL nào hiện component nào
```

`app.config.ts`:

```ts
export const appConfig: ApplicationConfig = {
  providers: [
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(routes),
    provideHttpClient(withInterceptors([authInterceptor])),
  ],
};
```

Đọc từng dòng:
- `provideRouter(routes)`: bật router với danh sách route trong `app.routes.ts`.
- `provideHttpClient(withInterceptors([authInterceptor]))`: bật `HttpClient` để gọi API, và **mọi** request đi qua `authInterceptor` trước khi gửi.

`<router-outlet />` trong `app.component.html` là "cái lỗ": router nhét component của URL hiện tại vào đó. Menu và footer nằm ngoài lỗ nên đổi trang không vẽ lại chúng.

---

## 3. Component: một mảnh giao diện

Mở `src/app/pages/reading-detail.component.ts`. Một component gồm ba phần:

```ts
@Component({
  selector: 'app-reading-detail',              // tên thẻ HTML nếu nhúng vào chỗ khác
  imports: [RouterLink, QuestionGroupComponent], // component/directive template này dùng
  template: ` ...HTML... `,                     // giao diện
})
export class ReadingDetailComponent implements OnInit {
  passage = signal<PassageDetail | null>(null);  // trạng thái
  answers = signal<Record<string, string>>({});
  ...
  submit() { ... }                               // hành vi
}
```

**`imports`**: component standalone phải khai báo rõ nó dùng gì. Template dùng `<app-question-group>` mà quên import `QuestionGroupComponent` thì build báo lỗi ngay. Nhờ vậy nhìn một file là biết nó phụ thuộc gì.

### 3.1 Signal: trạng thái biết tự báo khi đổi

```ts
passage = signal<PassageDetail | null>(null);   // tạo, giá trị đầu là null
this.passage.set(p);                           // ghi
this.passage()                                 // đọc: GỌI như hàm
this.answers.update((cur) => ({ ...cur, [id]: value }));  // ghi dựa trên giá trị cũ
```

Template đọc `passage()` thì Angular ghi nhớ "chỗ này phụ thuộc `passage`". Khi `passage.set(...)` chạy, chỉ những chỗ đó được vẽ lại.

**`computed`**: giá trị suy ra từ signal khác, tự tính lại khi nguồn đổi:

```ts
questionCount = computed(() => (this.passage()?.groups ?? []).reduce((n, g) => n + g.questions.length, 0));
answered = computed(() => Object.values(this.answers()).filter((v) => v.trim()).length);
```

> **Lỗi người mới hay mắc:** sửa trực tiếp object bên trong signal, kiểu `this.answers()[id] = value`. Signal không biết có thay đổi vì vẫn là object cũ, nên giao diện không vẽ lại. Luôn tạo object mới bằng `update(cur => ({...cur, ...}))`. Nguyên tắc này gọi là **immutable update**.

### 3.2 Template: cú pháp điều khiển mới

Angular 17+ dùng `@if`, `@for`, `@switch` thay cho `*ngIf`, `*ngFor` cũ:

```html
@if (passage(); as passage) {          <!-- chỉ vẽ khi khác null, đặt tên tạm "passage" -->
  <h1>{{ passage.title }}</h1>          <!-- {{ }} in giá trị ra -->
  @for (group of passage.groups; track group.id) {   <!-- track: khoá để Angular nhận ra phần tử nào đổi -->
    <app-question-group [group]="group" (answer)="setAnswer($event)" />
  }
}
```

| Cú pháp | Ý nghĩa | Ví dụ |
|---------|---------|-------|
| `{{ x }}` | in giá trị | `{{ passage.title }}` |
| `[prop]="x"` | truyền dữ liệu **vào** (property binding) | `[group]="group"` |
| `(event)="f()"` | nghe sự kiện **ra** (event binding) | `(click)="submit()"` |
| `[class.ten]="dk"` | bật tắt class CSS | `[class.done]="task.status === 'DONE'"` |

**Một bẫy thật trong repo:** `@else if (today(); as t)` **không** hợp lệ ở Angular 19, vì `as` chỉ dùng được với `@if`. `home.component.ts` phải viết `@else { @if (today(); as t) { ... } }`. Gặp lỗi lạ `Property 't' does not exist` thì nhớ chỗ này.

### 3.3 Component cha truyền dữ liệu cho component con

`shared/question-group.component.ts` là component con dùng ở bốn nơi (bài đọc, bài nghe, thi thử...). Nó khai báo cổng vào và cổng ra:

```ts
readonly group = input.required<QuestionGroupView>();   // bắt buộc truyền
readonly answers = input<Record<string, string>>({});   // tuỳ chọn, mặc định {}
readonly results = input<AnswerResult[] | null>(null);
readonly answer = output<{ questionId: number; value: string }>();  // phát sự kiện ra ngoài
```

Con **không tự sửa** `answers`. Khi người học gõ, con chỉ báo ra ngoài:

```ts
set(q: QuestionItem, value: string) {
  this.answer.emit({ questionId: q.id, value });
}
```

Cha nhận rồi tự cập nhật trạng thái của mình:

```html
<app-question-group [group]="g" [answers]="answers()" (answer)="setAnswer($event)" />
```

Mô hình này gọi là **dữ liệu chảy xuống, sự kiện chảy lên** (one-way data flow). Một trạng thái chỉ có **một chủ** (component cha), nên không bao giờ có hai bản sao lệch nhau. Đây là lý do cùng một component con dùng được cho cả luyện lẻ lẫn bài thi có lưu tự động: cha quyết định làm gì với câu trả lời.

---

## 4. Service và dependency injection

Nhiều component cần gọi API. Copy code gọi API vào từng component thì sửa một chỗ phải sửa mười chỗ. Ta gom vào một **service**.

`core/api.service.ts`:

```ts
@Injectable({ providedIn: 'root' })   // Angular tạo đúng MỘT bản dùng chung toàn app
export class ApiService {
  private http = inject(HttpClient);
  private base = '/api';

  readingDetail(id: number) {
    return this.http.get<PassageDetail>(`${this.base}/reading/${id}`);
  }
}
```

Component lấy service bằng `inject(ApiService)`. Component không tự `new ApiService()`: Angular tạo và đưa vào. Đó là **dependency injection (DI)**. Lợi ích:
- Dùng chung một bản (giữ được trạng thái chung như user đang đăng nhập).
- Khi test, thay service thật bằng service giả mà không sửa component.

Spring ở backend dùng đúng ý tưởng này (bài 2). Hiểu DI ở một bên là hiểu luôn bên kia.

---

## 5. Gọi API và Observable

`http.get(...)` **chưa gửi request**. Nó trả về một **Observable**: một "công thức" lấy dữ liệu. Request chỉ đi khi có ai `subscribe`:

```ts
this.api.readingDetail(id).subscribe((p) => this.passage.set(p));
```

Xử lý lỗi:

```ts
this.api.submitReading(passage.id, this.answers()).subscribe({
  next: (result) => { this.result.set(result); this.busy.set(false); },
  error: () => this.busy.set(false),   // quên dòng này thì nút "Nộp" bị khoá mãi khi lỗi mạng
});
```

Gọi nhiều API song song rồi đợi tất cả (`pages/history.component.ts`):

```ts
forkJoin([this.api.attempts(), this.api.writingSubmissions(), this.api.speakingSubmissions()])
  .subscribe(([a, w, s]) => { ... });
```

### Vì sao `base = '/api'`, không phải `http://localhost:8080/api`

Trang chạy ở `localhost:4200`, API ở `localhost:8080`. Khác cổng nghĩa là **khác origin**, và trình duyệt chặn gọi chéo origin trừ khi server cho phép (CORS). Thay vì cấu hình CORS phức tạp, ta làm cho mọi thứ **cùng origin**:

- Chạy `npm start`: `frontend/proxy.conf.json` bảo dev server chuyển tiếp `/api` và `/ws` sang `localhost:8080`.
- Chạy Docker: Nginx làm việc đó (bài 8).

Trình duyệt chỉ thấy một origin. Bản trước dùng URL tuyệt đối rồi lúc build Docker phải chạy `sed` sửa source code, rất dễ quên và khó debug. Cách mới không phải sửa gì khi đổi môi trường.

---

## 6. Interceptor: việc làm cho MỌI request

`core/auth.interceptor.ts`:

```ts
export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const auth = inject(AuthService);
  const token = localStorage.getItem('english_token');
  const request = token ? req.clone({ setHeaders: { Authorization: `Bearer ${token}` } }) : req;
  return next(request).pipe(
    catchError((error: HttpErrorResponse) => {
      if (error.status === 401 && token && !req.url.includes('/auth/')) auth.logout();
      return throwError(() => error);
    }),
  );
};
```

Hai việc:
1. **Gắn token** vào mọi request. Request là bất biến nên phải `clone`.
2. **Server trả 401** (token hết hạn hoặc server đổi secret): đăng xuất luôn. Không có dòng này thì giao diện vẫn hiện "đã đăng nhập" nhưng mọi trang đều lỗi, người dùng không hiểu vì sao.

`!req.url.includes('/auth/')`: đăng nhập sai mật khẩu cũng trả 401, nhưng lúc đó không có phiên nào để xoá.

---

## 7. Router, lazy loading và guard

`app.routes.ts` có hai kiểu khai báo:

```ts
{ path: 'reading/:id', component: ReadingDetailComponent },     // tải ngay khi mở app

{
  path: 'roadmap',
  canActivate: [profileGuard],
  loadComponent: () => import('./pages/roadmap.component').then((m) => m.RoadmapComponent),  // tải khi cần
},
```

**Lazy loading** (`loadComponent`): code trang lộ trình chỉ tải về khi người dùng mở `/roadmap`. App có nhiều trang thì gói tải lần đầu nhỏ lại, mở nhanh hơn. Chạy `npm run build` sẽ thấy bảng "Initial" (tải ngay, khoảng 386 kB) và "Lazy chunk files" (tải sau).

`:id` là tham số đường dẫn. Đọc trong component:

```ts
Number(this.route.snapshot.paramMap.get('id'))
```

**Guard** quyết định có cho vào trang không (`core/guards.ts`):

```ts
export const profileGuard: CanActivateFn = (_route, state) => {
  ...
  if (!auth.loggedIn()) return router.createUrlTree(['/login'], { queryParams: { next: state.url } });
  return api.profile().pipe(
    map(() => true),
    catchError((error) => of(error?.status === 404 ? router.createUrlTree(['/onboarding']) : true)),
  );
};
```

- Chưa đăng nhập: chuyển tới `/login?next=/roadmap`, đăng nhập xong quay lại đúng trang (xem `auth.component.ts`).
- Chưa có hồ sơ IELTS (API trả 404): chuyển tới `/onboarding`.
- Lỗi khác (mạng chập chờn): vẫn cho vào, để trang tự báo lỗi, thay vì chặn người dùng ở ngoài.

> **Guard không phải bảo mật.** Người dùng sửa được mọi thứ chạy trên trình duyệt của họ. Guard chỉ giúp trải nghiệm tốt hơn. Bảo mật thật nằm ở server (bài 4): API vẫn phải tự kiểm tra token.

---

## 8. Đi một luồng trọn vẹn: nộp bài đọc

1. Mở `/reading/3` → router tạo `ReadingDetailComponent` → `ngOnInit` gọi `api.readingDetail(3)`.
2. Server trả JSON gồm `content` và `groups` (nhóm câu hỏi, **không có đáp án**).
3. Template lặp `groups`, mỗi nhóm vẽ bằng `<app-question-group>`. Component con chọn cách vẽ theo `group.type`: ô trống, nút TRUE/FALSE/NOT GIVEN, dropdown ghép heading...
4. Người học gõ → con `emit` → cha `setAnswer` → `answers` đổi → `answered()` tự tính lại → chữ "Đã làm 5/13" cập nhật.
5. Bấm "Nộp bài" → `submitReading(id, answers)` → server chấm → trả `results`.
6. `result.set(...)` → template truyền `[results]` xuống con → con chuyển sang chế độ xem đáp án: khoá ô nhập, tô xanh/đỏ, hiện đoạn trích chứa đáp án.

Mở DevTools (F12) → tab Network, nộp một bài và nhìn request `submit` cùng response của nó.

---

## 9. Các thứ dùng trình duyệt trong app

| Tính năng | API trình duyệt | File |
|-----------|-----------------|------|
| Đọc bài nghe bằng giọng máy | `speechSynthesis` | `shared/tts-player.component.ts` |
| Ghi âm Speaking | `MediaRecorder`, `getUserMedia` | `pages/speaking.component.ts` |
| Giọng nói thành chữ | `SpeechRecognition` (Chrome/Edge) | `pages/speaking.component.ts` |
| Lưu nháp Writing | `localStorage` | `pages/writing.component.ts` |
| Nhịp "đang học" | `WebSocket` | `core/realtime.service.ts` |
| Cảnh báo khi đóng tab lúc chưa lưu | sự kiện `beforeunload` | `pages/test-player.component.ts` |

Lưu ý `localStorage` có thể bị chặn (chế độ ẩn danh, chính sách công ty), nên mọi lần đọc/ghi trong `writing.component.ts` đều bọc `try/catch`.

---

## 10. Lỗi hay gặp

| Triệu chứng | Nguyên nhân thường gặp |
|-------------|----------------------|
| Mọi API lỗi 504 hoặc `ECONNREFUSED` | Backend chưa chạy. `ng serve` chuyển tiếp tới 8080 mà không có ai nghe |
| Gõ mà giao diện không đổi | Sửa trực tiếp object trong signal thay vì `update` với object mới |
| `NG8001: 'app-x' is not a known element` | Quên thêm component vào `imports` |
| Trang trắng, console báo `NullInjectorError` | Service thiếu `@Injectable({ providedIn: 'root' })` |
| Nút bị khoá mãi | Quên tắt `busy` trong nhánh `error` của `subscribe` |
| Bị đá ra trang đăng nhập liên tục | Token hết hạn, interceptor đăng xuất. Đăng nhập lại |

---

## 11. Việc tự làm

**Junior**
1. Đổi nhãn menu "Thi thử" thành "Luyện đề" trong `app.component.ts`. Lưu lại, trang tự tải lại.
2. Trong `reading-list.component.ts`, hiện thêm chủ đề (`item.topic`) dưới tiêu đề mỗi bài.
3. Mở DevTools → Network, làm một bài nghe, tìm request `submit` và đọc JSON trả về.

**Mid**
4. Thêm nút "Ẩn bài đọc" ở trang đọc: bấm thì `.split` chỉ còn một cột câu hỏi. Dùng một signal `boolean`.
5. Trang Writing: hiện cảnh báo màu cam khi đã viết quá 25 phút cho Task 1 hoặc 45 phút cho Task 2.
6. Viết một `computed` trong `test-player.component.ts` đếm tổng số câu chưa trả lời của cả bài thi, hiện cạnh nút "Nộp bài".

**Senior**
7. `home.component.ts` gọi `today()` lại toàn bộ sau mỗi lần tick checkbox. Đổi sang **optimistic update**: đổi trạng thái trên giao diện ngay, gọi API, lỗi thì hoàn lại. Nghĩ xem: người dùng bấm hai lần liên tiếp rất nhanh thì sao?
8. Trang thi lưu tự động mỗi 30 giây. Nếu người học mở **hai tab** cùng một bài thi, câu trả lời của tab này có thể ghi đè tab kia. Thiết kế cách phát hiện và xử lý (gợi ý: số phiên bản, hoặc cảnh báo khi phát hiện tab khác).

---

## 12. Góc nhìn senior

- **Một chủ cho mỗi trạng thái.** Câu trả lời bài thi chỉ sống trong `TestPlayerComponent`. Component con, autosave, nút nộp đều đọc từ đó. Hai nơi giữ cùng một dữ liệu sớm muộn sẽ lệch nhau.
- **Giao diện không phải nơi giữ bí mật.** Server không gửi đáp án xuống trước khi nộp (có test kiểm tra điều này: `IeltsFlowTest.readingNeverLeaksAnswersAndGradesAllQuestionTypes`). Nhưng lời thoại bài nghe vẫn được gửi xuống để trình duyệt đọc bằng giọng máy, nên người rành DevTools đọc được. Đó là một **đánh đổi có ý thức**, ghi rõ trong đặc tả, chấp nhận được cho tới khi có file audio thật.
- **Thiết kế cho mạng chập chờn.** Bài thi 150 phút mà mất câu trả lời vì rớt mạng là lỗi nghiêm trọng nhất app có thể gây ra. Vì vậy có lưu tự động, cảnh báo khi đóng tab, server giữ giờ, và hết giờ thì tự nộp.

Tiếp theo: [Bài 2: Spring Boot](./learn-spring.md).
