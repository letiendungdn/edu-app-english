package com.edu.english.security;

import org.springframework.http.HttpStatus;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.server.ResponseStatusException;

public final class CurrentUser {
  private CurrentUser() {}

  public static AuthUser optional() {
    var auth = SecurityContextHolder.getContext().getAuthentication();
    if (auth != null && auth.getPrincipal() instanceof AuthUser user) return user;
    return null;
  }

  public static AuthUser require() {
    AuthUser user = optional();
    if (user == null) throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Unauthorized");
    return user;
  }
}
