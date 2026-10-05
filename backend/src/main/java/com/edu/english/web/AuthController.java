package com.edu.english.web;

import com.edu.english.security.CurrentUser;
import com.edu.english.service.AuthService;
import com.edu.english.web.ApiModels.AuthResponse;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
  private final AuthService auth;

  public AuthController(AuthService auth) {
    this.auth = auth;
  }

  @PostMapping("/login")
  public AuthResponse login(@RequestBody LoginRequest body) {
    return auth.login(body.email(), body.password());
  }

  @PostMapping("/register")
  public AuthResponse register(@RequestBody RegisterRequest body) {
    return auth.register(body.email(), body.password(), body.name());
  }

  @GetMapping("/me")
  public ApiModels.UserView me() {
    return auth.me(CurrentUser.require());
  }

  public record LoginRequest(String email, String password) {}

  public record RegisterRequest(String email, String password, String name) {}
}
