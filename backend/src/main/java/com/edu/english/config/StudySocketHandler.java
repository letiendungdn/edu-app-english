package com.edu.english.config;

import com.edu.english.security.JwtService;
import com.edu.english.service.VocabService;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

@Component
public class StudySocketHandler extends TextWebSocketHandler {
  private static final Logger log = LoggerFactory.getLogger(StudySocketHandler.class);
  private final JwtService jwt;
  private final VocabService vocab;
  private final PlatformGateway platform;
  private final ObjectMapper json;

  public StudySocketHandler(
      JwtService jwt, VocabService vocab, PlatformGateway platform, ObjectMapper json) {
    this.jwt = jwt;
    this.vocab = vocab;
    this.platform = platform;
    this.json = json;
  }

  @Override
  public void afterConnectionEstablished(WebSocketSession session) throws Exception {
    session.sendMessage(new TextMessage("{\"event\":\"ready\"}"));
  }

  @Override
  protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
    Long userId = userId(session);
    if (userId == null) {
      session.close(CloseStatus.NOT_ACCEPTABLE.withReason("Unauthorized"));
      return;
    }
    JsonNode body = json.readTree(message.getPayload());
    int seconds = Math.min(120, Math.max(1, body.path("seconds").asInt(15)));
    vocab.addStudy(userId, seconds, 0);
    platform.publish(PlatformGateway.SESSION_RECORDED, Map.of("userId", userId, "seconds", seconds));
  }

  @Override
  public void handleTransportError(WebSocketSession session, Throwable exception) {
    log.debug("Study socket closed: {}", exception.getMessage());
  }

  private Long userId(WebSocketSession session) {
    String query = session.getUri() == null ? "" : session.getUri().getQuery();
    if (query == null) return null;
    String token = null;
    for (String part : query.split("&")) {
      if (part.startsWith("token=")) token = part.substring("token=".length());
    }
    if (token == null || token.isBlank()) return null;
    try {
      return jwt.parse(URLDecoder.decode(token, StandardCharsets.UTF_8)).id();
    } catch (Exception ex) {
      return null;
    }
  }
}
