package com.edu.english.service;

import com.edu.english.domain.Enums.EnglishLevel;
import com.edu.english.domain.UserAccount;
import com.edu.english.repo.UserRepository;
import com.edu.english.security.AuthUser;
import com.edu.english.security.JwtService;
import com.edu.english.web.ApiModels.AuthResponse;
import com.edu.english.web.ApiModels.UserView;
import java.time.Instant;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class AuthService {
  private final UserRepository users;
  private final PasswordEncoder encoder;
  private final JwtService jwt;
  private final VocabService vocabService;

  public AuthService(
      UserRepository users, PasswordEncoder encoder, JwtService jwt, VocabService vocabService) {
    this.users = users;
    this.encoder = encoder;
    this.jwt = jwt;
    this.vocabService = vocabService;
  }

  @Transactional
  public AuthResponse login(String email, String password) {
    UserAccount user =
        users
            .findByEmailIgnoreCase(email == null ? "" : email.trim())
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Email hoặc mật khẩu không đúng"));
    if (!encoder.matches(password == null ? "" : password, user.getPasswordHash())) {
      throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Email hoặc mật khẩu không đúng");
    }
    user.setLastActiveAt(Instant.now());
    return tokenFor(user);
  }

  @Transactional
  public AuthResponse register(String email, String password, String name) {
    if (email == null || email.isBlank() || password == null || password.length() < 6) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Email và mật khẩu (tối thiểu 6 ký tự) là bắt buộc");
    }
    String normalized = email.trim().toLowerCase();
    if (users.existsByEmailIgnoreCase(normalized)) {
      throw new ResponseStatusException(HttpStatus.CONFLICT, "Email đã tồn tại");
    }
    UserAccount user = new UserAccount();
    user.setEmail(normalized);
    user.setPasswordHash(encoder.encode(password));
    user.setName(name == null || name.isBlank() ? null : name.trim());
    user.setLastActiveAt(Instant.now());
    users.save(user);
    vocabService.enrollStarterCards(user.getId());
    return tokenFor(user);
  }

  public UserView me(AuthUser user) {
    return new UserView(user.id(), user.email(), user.name(), user.role());
  }

  private AuthResponse tokenFor(UserAccount user) {
    UserView view =
        new UserView(user.getId(), user.getEmail(), user.getName(), user.getRole().name());
    return new AuthResponse(view, jwt.sign(new AuthUser(view.id(), view.email(), view.name(), view.role())));
  }

  public static EnglishLevel parseLevel(String value) {
    if (value == null || value.isBlank()) return null;
    try {
      return EnglishLevel.valueOf(value.trim());
    } catch (IllegalArgumentException ex) {
      return null;
    }
  }
}
