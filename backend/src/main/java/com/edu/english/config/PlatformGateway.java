package com.edu.english.config;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.time.Duration;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

@Component
public class PlatformGateway {
  public static final String VOCAB_REVIEWED = "edu.vocab.reviewed";
  public static final String SESSION_RECORDED = "edu.session.completed";

  private static final Logger log = LoggerFactory.getLogger(PlatformGateway.class);
  private final ObjectProvider<StringRedisTemplate> redis;
  private final ObjectProvider<KafkaTemplate<String, String>> kafka;
  private final ObjectProvider<MongoTemplate> mongo;
  private final ObjectMapper json;

  public PlatformGateway(
      ObjectProvider<StringRedisTemplate> redis,
      ObjectProvider<KafkaTemplate<String, String>> kafka,
      ObjectProvider<MongoTemplate> mongo,
      ObjectMapper json) {
    this.redis = redis;
    this.kafka = kafka;
    this.mongo = mongo;
    this.json = json;
  }

  public <T> T cache(String key, Class<T> type, java.util.function.Supplier<T> loader) {
    StringRedisTemplate cache = redis.getIfAvailable();
    if (cache != null) {
      try {
        String hit = cache.opsForValue().get(key);
        if (hit != null) return json.readValue(hit, type);
      } catch (Exception ex) {
        log.debug("Redis read skipped: {}", ex.getMessage());
      }
    }
    T value = loader.get();
    if (cache != null && value != null) {
      try {
        cache.opsForValue().set(key, json.writeValueAsString(value), Duration.ofSeconds(30));
      } catch (JsonProcessingException ex) {
        log.debug("Redis write skipped: {}", ex.getMessage());
      }
    }
    return value;
  }

  public void publish(String topic, Map<String, ?> payload) {
    KafkaTemplate<String, String> producer = kafka.getIfAvailable();
    if (producer == null) return;
    try {
      producer.send(topic, json.writeValueAsString(payload));
    } catch (Exception ex) {
      log.warn("Kafka publish skipped: {}", ex.getMessage());
    }
  }

  public void audit(String method, String path, int status) {
    MongoTemplate store = mongo.getIfAvailable();
    if (store == null || !path.startsWith("/api/")) return;
    try {
      store.insert(Map.of("method", method, "path", path, "status", status, "at", java.time.Instant.now()), "audit_logs");
    } catch (Exception ex) {
      log.debug("Audit log skipped: {}", ex.getMessage());
    }
  }
}
