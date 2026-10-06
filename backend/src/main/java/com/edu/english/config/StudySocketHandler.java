package com.edu.english.config;

import com.edu.english.security.JwtService;
import com.edu.english.service.VocabService;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.time.Clock;
import java.time.Instant;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

/**
 * Nhịp "đang học" từ trang đang mở.
 *
 * <p>Tin đầu tiên phải là {"type":"auth","token":"..."}: token không nằm trên URL vì URL bị ghi vào access log.
 * Mỗi nhịp sau đó cộng số giây thực sự trôi qua kể từ nhịp trước, tối đa 60 giây, nên client không thể tự khai
 * thêm giờ học bằng cách gửi số lớn hoặc gửi dồn dập.
 */
@Component
public class StudySocketHandler extends TextWebSocketHandler {
  static final int MAX_CREDIT_SECONDS = 60;
  private static final String USER_ID = "userId";
  private static final String LAST_BEAT = "lastBeat";
  private static final Logger log = LoggerFactory.getLogger(StudySocketHandler.class);

  private final JwtService jwt;
  private final VocabService vocab;
  private final PlatformGateway platform;
  private final ObjectMapper json;
  private final Clock clock;

  public StudySocketHandler(
      JwtService jwt, VocabService vocab, PlatformGateway platform, ObjectMapper json, Clock clock) {
    this.jwt = jwt;
    this.vocab = vocab;
    this.platform = platform;
    this.json = json;
    this.clock = clock;
  }

  @Override
  public void afterConnectionEstablished(WebSocketSession session) throws Exception {
    session.sendMessage(new TextMessage("{\"event\":\"ready\"}"));
  }

  @Override
  protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
    JsonNode body = json.readTree(message.getPayload());
    Long userId = (Long) session.getAttributes().get(USER_ID);
    if (userId == null) {
      authenticate(session, body);
      return;
    }
    Instant now = clock.instant();
    Instant last = (Instant) session.getAttributes().get(LAST_BEAT);
    session.getAttributes().put(LAST_BEAT, now);
    long elapsed = Math.max(0, now.getEpochSecond() - last.getEpochSecond());
    int claimed = Math.max(0, body.path("seconds").asInt(15));
    int seconds = (int) Math.min(MAX_CREDIT_SECONDS, Math.min(claimed, elapsed));
    if (seconds <= 0) return;
    vocab.addStudy(userId, seconds, 0);
    platform.publish(PlatformGateway.SESSION_RECORDED, Map.of("userId", userId, "seconds", seconds));
  }

  private void authenticate(WebSocketSession session, JsonNode body) throws Exception {
    String token = body.path("token").asText("");
    if (!"auth".equals(body.path("type").asText()) || token.isBlank()) {
      session.close(CloseStatus.POLICY_VIOLATION.withReason("Unauthorized"));
      return;
    }
    try {
      Long userId = jwt.parse(token).id();
      session.getAttributes().put(USER_ID, userId);
      session.getAttributes().put(LAST_BEAT, clock.instant());
      session.sendMessage(new TextMessage("{\"event\":\"authenticated\"}"));
    } catch (Exception ex) {
      session.close(CloseStatus.POLICY_VIOLATION.withReason("Unauthorized"));
    }
  }

  @Override
  public void handleTransportError(WebSocketSession session, Throwable exception) {
    log.debug("Study socket closed: {}", exception.getMessage());
  }
}
