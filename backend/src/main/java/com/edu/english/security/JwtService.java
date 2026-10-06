package com.edu.english.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;
import javax.crypto.SecretKey;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class JwtService {
  private final SecretKey key;
  private final long expirationDays;

  public JwtService(
      @Value("${app.jwt.secret}") String secret,
      @Value("${app.jwt.expiration-days}") long expirationDays) {
    byte[] bytes = secret == null ? new byte[0] : secret.getBytes(StandardCharsets.UTF_8);
    if (bytes.length < 32) {
      throw new IllegalStateException(
          "APP_JWT_SECRET phải có tối thiểu 32 ký tự (profile dev có sẵn giá trị mặc định, profile khác bắt buộc đặt).");
    }
    this.key = Keys.hmacShaKeyFor(bytes);
    this.expirationDays = expirationDays;
  }

  public String sign(AuthUser user) {
    Instant now = Instant.now();
    return Jwts.builder()
        .subject(String.valueOf(user.id()))
        .claim("email", user.email())
        .claim("name", user.name())
        .claim("role", user.role())
        .claim("app", "english")
        .issuedAt(Date.from(now))
        .expiration(Date.from(now.plusSeconds(expirationDays * 24 * 60 * 60)))
        .signWith(key)
        .compact();
  }

  public AuthUser parse(String token) {
    Claims claims = Jwts.parser().verifyWith(key).build().parseSignedClaims(token).getPayload();
    if (!"english".equals(claims.get("app", String.class))) {
      throw new IllegalArgumentException("Wrong audience");
    }
    return new AuthUser(
        Long.valueOf(claims.getSubject()),
        claims.get("email", String.class),
        claims.get("name", String.class),
        claims.get("role", String.class));
  }
}
