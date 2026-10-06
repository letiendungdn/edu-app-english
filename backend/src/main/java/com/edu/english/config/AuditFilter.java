package com.edu.english.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
public class AuditFilter extends OncePerRequestFilter {
  private final PlatformGateway platform;

  public AuditFilter(PlatformGateway platform) {
    this.platform = platform;
  }

  @Override
  protected void doFilterInternal(
      HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
      throws ServletException, IOException {
    try {
      filterChain.doFilter(request, response);
    } finally {
      platform.audit(request.getMethod(), request.getRequestURI(), response.getStatus());
    }
  }
}
