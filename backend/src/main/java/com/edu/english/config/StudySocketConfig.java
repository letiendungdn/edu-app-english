package com.edu.english.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;

@Configuration
@EnableWebSocket
public class StudySocketConfig implements WebSocketConfigurer {
  private final StudySocketHandler handler;
  private final String[] allowedOrigins;

  public StudySocketConfig(StudySocketHandler handler, @Value("${app.ws-origins}") String allowedOrigins) {
    this.handler = handler;
    this.allowedOrigins = allowedOrigins.split(",");
  }

  @Override
  public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
    // Chỉ origin đã khai báo: một trang lạ không mở được socket bằng token người học đã lưu.
    registry.addHandler(handler, "/ws/study").setAllowedOrigins(allowedOrigins);
  }
}
