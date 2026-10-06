# Bài 4: Đăng nhập, JWT và phân quyền

**Mục tiêu:** hiểu cách app biết "bạn là ai" ở mỗi request, vì sao mật khẩu không bao giờ được lưu thật, và đâu là ranh giới bảo mật thật sự.

**File chính:** `backend/.../security/` (`JwtService`, `JwtAuthFilter`, `SecurityConfig`, `CurrentUser`), `service/AuthService.java`, `frontend/src/app/core/auth.*`.

---

## 1. Hai câu hỏi khác nhau

| Câu hỏi | Tên gọi | Trong repo |
|---------|---------|-----------|
| Bạn là ai? | **Authentication** (xác thực) | email + mật khẩu → JWT |
| Bạn được làm gì? | **Authorization** (phân quyền) | `SecurityConfig` + kiểm tra chủ sở hữu trong service |

Người mới hay chỉ làm câu một mà quên câu hai: đăng nhập rồi thì xem được bài viết của **người khác** bằng cách đổi id trên URL. Lỗi đó tên là **IDOR** (Insecure Direct Object Reference), nằm trong nhóm lỗi bảo mật phổ biến nhất của web.

---

## 2. Mật khẩu: băm, không lưu

`AuthService.register`:

```java
user.setPasswordHash(encoder.encode(password));   // encoder = BCryptPasswordEncoder
```

`AuthService.login`:

```java
if (!encoder.matches(password, user.getPasswordHash())) throw ... 401 "Email hoặc mật khẩu không đúng";
```

- **Băm (hash)** là biến đổi một chiều: từ mật khẩu ra chuỗi băm thì dễ, từ chuỗi băm ngược ra mật khẩu thì không thể. Database bị lộ, kẻ tấn công vẫn không có mật khẩu.
- **BCrypt** cố tình **chậm** (khoảng 100 ms mỗi lần) và có **salt** (chuỗi ngẫu nhiên riêng cho từng người). Đoán thử hàng tỉ mật khẩu trở nên quá tốn, và hai người cùng mật khẩu `123456` vẫn có chuỗi băm khác nhau.
- Thông báo lỗi giống hệt nhau cho "sai email" và "sai mật khẩu". Nếu báo "email không tồn tại", kẻ xấu dò được email nào đã đăng ký.

> Đừng bao giờ tự viết hàm băm mật khẩu, và đừng dùng MD5 hay SHA-256 trần cho mật khẩu: chúng quá nhanh nên đoán thử rất rẻ.

---

## 3. JWT: "vé" chứng minh bạn đã đăng nhập

HTTP **không nhớ** gì giữa hai request. Đăng nhập xong, request sau làm sao server biết vẫn là bạn?

**Cách 1, session:** server lưu "phiên 42 = user 1" trong bộ nhớ, đưa trình duyệt cookie `session=42`. Chạy nhiều server thì phiên phải được chia sẻ giữa chúng.

**Cách 2, JWT (repo này dùng):** server đưa cho bạn một **vé có chữ ký**. Vé tự chứa thông tin, server chỉ cần kiểm tra chữ ký, không cần nhớ gì.

Một JWT trông như sau:

```text
eyJhbGciOiJIUzI1NiJ9 . eyJzdWIiOiIxIiwiZW1haWwiOiJkZW1v... . k3Jd8s...
      header                       payload (dữ liệu)              chữ ký
```

Dán token vào https://jwt.io để xem payload. `JwtService.sign`:

```java
Jwts.builder()
    .subject(String.valueOf(user.id()))   // sub: id người dùng
    .claim("email", user.email())
    .claim("role", user.role())
    .claim("app", "english")              // vé này chỉ dành cho app English
    .issuedAt(...)
    .expiration(... + 30 ngày)
    .signWith(key)                        // ký bằng HMAC-SHA256 với APP_JWT_SECRET
    .compact();
```

**Điều quan trọng nhất về JWT:** payload chỉ được **mã hoá base64**, không được **mã hoá bí mật**. Ai cầm token cũng đọc được nội dung. Chữ ký chỉ đảm bảo **không ai sửa được** nội dung mà server không phát hiện. Đừng bao giờ bỏ thông tin bí mật vào JWT.

**Vì sao có claim `app=english`?** App tiếng Nhật cùng hệ sinh thái cũng dùng JWT. Nếu hai app lỡ dùng chung secret, token app này sẽ được app kia chấp nhận. `JwtService.parse` từ chối token không có `app=english`.

### Secret

```java
byte[] bytes = secret.getBytes(StandardCharsets.UTF_8);
if (bytes.length < 32) throw new IllegalStateException("APP_JWT_SECRET phải có tối thiểu 32 ký tự ...");
```

HMAC-SHA256 cần khoá ít nhất 256 bit (32 byte). Bản trước để thư viện tự ném `WeakKeyException` khó hiểu. Giờ app dừng ngay lúc khởi động với thông báo rõ ràng. Nguyên tắc **fail fast**: cấu hình sai thì chết sớm, khi còn đang deploy, chứ không chết lúc người dùng đang đăng nhập.

- Profile `dev` có secret mặc định để chạy local cho tiện.
- Môi trường thật **bắt buộc** đặt `APP_JWT_SECRET`. Helm chart đọc nó từ Kubernetes Secret, không ghi trong `values.yaml` (vì file đó được commit lên git).
- Đổi secret thì **mọi** token cũ mất hiệu lực, frontend nhận 401 và tự đăng xuất (interceptor ở bài 1).

---

## 4. Request đi qua lớp bảo mật thế nào

```text
GET /api/roadmap/today   Authorization: Bearer eyJ...
  │
  ▼  JwtAuthFilter (chạy với MỌI request)
  │    có header Bearer? → JwtService.parse → hợp lệ? → đặt AuthUser vào SecurityContext
  │    token hỏng → bỏ qua, coi như khách (KHÔNG chặn ở đây)
  ▼  SecurityConfig: URL này cần đăng nhập?
  │    cần mà là khách → 401 {"error":"Unauthorized"}
  ▼  Controller → CurrentUser.require().id()
  ▼  Service: bản ghi này có phải của user này không?
```

### 4.1 Filter

`JwtAuthFilter`:

```java
String header = request.getHeader(HttpHeaders.AUTHORIZATION);
if (header != null && header.startsWith("Bearer ")) {
  try {
    AuthUser user = jwtService.parse(header.substring(7));
    var auth = new UsernamePasswordAuthenticationToken(user, null, List.of(new SimpleGrantedAuthority("ROLE_" + user.role())));
    SecurityContextHolder.getContext().setAuthentication(auth);
  } catch (Exception ignored) {
    SecurityContextHolder.clearContext();
  }
}
filterChain.doFilter(request, response);
```

Filter **không chặn**, chỉ "gắn danh tính". Quyết định chặn hay không thuộc về `SecurityConfig`. Mỗi lớp một việc nên dễ đọc và dễ test.

### 4.2 Luật theo URL

`SecurityConfig`, luật được xét **từ trên xuống, khớp luật nào trước thì dùng luật đó**:

```java
auth.requestMatchers("/h2/**", "/actuator/health", "/actuator/health/**", "/actuator/prometheus", "/ws/**").permitAll()
    .requestMatchers("/api/auth/**").permitAll()
    .requestMatchers(HttpMethod.GET, "/api/vocab/review").authenticated()
    ...
    .requestMatchers(HttpMethod.GET, "/api/ielts/**", "/api/roadmap/**", "/api/tests/attempts/**",
                     "/api/writing/submissions/**", "/api/speaking/submissions/**").authenticated()
    .requestMatchers(HttpMethod.GET, "/api/**").permitAll()      // còn lại: GET công khai
    .requestMatchers(HttpMethod.POST, "/api/reading/**", "/api/listening/**", "/api/dictation").permitAll()
    .anyRequest().authenticated();                                // mọi thứ khác: phải đăng nhập
```

| URL | Cần đăng nhập? | Vì sao |
|-----|---------------|--------|
| `/api/auth/**` | Không | đang đi đăng nhập |
| `GET /api/reading`, `/api/tests`, `/api/writing/prompts` | Không | khách xem thử được nội dung |
| `POST /api/reading/{id}/submit` | Không | khách làm thử bài đọc, chỉ không lưu kết quả |
| `GET /api/ielts/**`, `/api/roadmap/**`, các `.../submissions/**`, `/api/tests/attempts/**` | Có | dữ liệu cá nhân |
| `POST` nộp Writing, Speaking, bài thi, `PUT` hồ sơ | Có | rơi vào `anyRequest().authenticated()` |
| `/ws/**` | Không ở tầng HTTP | trình duyệt không gửi header khi mở WebSocket, nên xác thực nằm trong handler (bài 12) |

**Bẫy thứ tự:** nếu đặt `GET /api/**` permitAll **lên trên** dòng `/api/roadmap/**`, lộ trình thành công khai ở tầng filter. Controller vẫn gọi `CurrentUser.require()` nên vẫn trả 401, đó là **phòng thủ nhiều lớp** (defense in depth). Nhưng đừng trông vào may mắn: luật cụ thể đặt trước, luật chung đặt sau.

### 4.3 Kiểm tra chủ sở hữu, lớp quan trọng nhất

`WritingService`:

```java
private WritingSubmission requireOwned(Long userId, Long id) {
  WritingSubmission s = submissions.findById(id).orElseThrow(() -> 404);
  if (!s.getUserId().equals(userId)) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy bài");
  return s;
}
```

`SecurityConfig` chỉ biết "đã đăng nhập chưa". Nó **không** biết bài viết số 57 là của ai. Mọi service đọc dữ liệu cá nhân theo id đều phải tự kiểm tra: `TestService.requireOwned`, `SpeakingService.requireOwned`, `RoadmapService.updateTask`. Thiếu một chỗ là lỗi IDOR.

---

## 5. Phía frontend

- `core/auth.service.ts` lưu token vào `localStorage` khoá `english_token`, user vào `english_user`. `loggedIn` là một `computed` signal.
- `core/auth.interceptor.ts` gắn `Authorization: Bearer ...`, và gặp 401 thì đăng xuất.
- `core/guards.ts` chặn trang cần đăng nhập, chuyển tới `/login?next=...`.

> **`localStorage` và XSS:** script nào chạy trên trang cũng đọc được `localStorage`. Nếu app có lỗi **XSS** (kẻ xấu chèn được JavaScript vào trang), token bị đánh cắp. Angular tự escape mọi thứ in bằng `{{ }}`, nên XSS khó xảy ra miễn là không dùng `innerHTML` với dữ liệu người dùng. Cách an toàn hơn là cookie `HttpOnly` (JavaScript không đọc được), đổi lại phải chống CSRF. Đây là đánh đổi kinh điển, nên biết cả hai phía.

---

## 6. Thử bằng tay

```powershell
# Đăng nhập, lấy token
curl -s -X POST http://localhost:8080/api/auth/login -H "Content-Type: application/json" -d "{\"email\":\"demo@edu.app\",\"password\":\"demo123\"}"

# Có token
curl -s http://localhost:8080/api/roadmap/today -H "Authorization: Bearer <TOKEN>"

# Không token → 401
curl -i http://localhost:8080/api/roadmap/today

# Token sửa một ký tự → 401 (chữ ký sai)
curl -i http://localhost:8080/api/roadmap/today -H "Authorization: Bearer <TOKEN_SUA_1_KY_TU>"
```

Test tự động: `AuthControllerTest` (đăng ký, đăng nhập, `/me`, sai mật khẩu, mật khẩu ngắn) và `IeltsFlowTest.personalEndpointsRequireLogin`.

---

## 7. Lỗi hay gặp

| Triệu chứng | Nguyên nhân |
|-------------|-------------|
| Mọi request 401 sau khi khởi động lại backend | Đổi `APP_JWT_SECRET`, token cũ hết giá trị. Đăng nhập lại |
| App không khởi động: "APP_JWT_SECRET phải có tối thiểu 32 ký tự" | Profile khác `dev` mà chưa đặt biến, hoặc secret quá ngắn |
| Đăng nhập được nhưng trang IELTS 409 | Chưa có hồ sơ IELTS, không phải lỗi đăng nhập. Vào `/onboarding` |
| API mới thêm ai cũng gọi được | Là `GET` dưới `/api/**` nên rơi vào luật permitAll. Thêm luật cụ thể |

---

## 8. Việc tự làm

**Junior**
1. Dán token của bạn vào jwt.io. Đọc `sub`, `email`, `exp`. Đổi `exp` từ dạng số sang ngày giờ.
2. Thử gọi `GET /api/writing/submissions/1` bằng token của một tài khoản mới tạo (không phải chủ bài). Nhận mã gì? Vì sao không phải 403?
3. Đổi thời hạn token thành 1 ngày (`app.jwt.expiration-days`).

**Mid**
4. Thêm API `POST /api/auth/change-password` (mật khẩu cũ, mật khẩu mới). Viết test.
5. Thêm role `ADMIN` cho một API `GET /api/admin/stats`. Gợi ý: `.requestMatchers("/api/admin/**").hasRole("ADMIN")`. Tạo admin bằng SQL rồi thử.
6. Viết test chứng minh user A không đọc được bài Writing của user B.

**Senior**
7. Đăng nhập không giới hạn số lần thử: kẻ xấu đoán mật khẩu được. Thiết kế giới hạn (theo IP, theo email, khoá tạm thời). Nêu đánh đổi: kẻ xấu cố tình khoá tài khoản người khác thì sao?
8. JWT 30 ngày không thu hồi được: bị lộ là kẻ xấu dùng được 30 ngày. Thiết kế **access token ngắn + refresh token**, hoặc danh sách token bị thu hồi. Cái nào hợp với app này, vì sao?

---

## 9. Góc nhìn senior

- **Mọi thứ trên trình duyệt là của người dùng.** Guard, ẩn nút, kiểm tra ở frontend chỉ giúp trải nghiệm tốt hơn. Bảo mật nằm ở server, và ở **từng service** chứ không chỉ ở filter.
- **Báo lỗi ít thông tin cho người ngoài, nhiều thông tin cho người vận hành.** Người dùng thấy "Email hoặc mật khẩu không đúng" và 404. Log của server ghi chi tiết.
- **Bí mật nằm ngoài code.** Secret, API key đi qua biến môi trường hoặc secret manager, không bao giờ vào git. Lỡ commit một key là phải coi như key đã lộ và đổi ngay, xoá commit không đủ.

Tiếp theo: [Bài 5: Test](./learn-testing.md).
