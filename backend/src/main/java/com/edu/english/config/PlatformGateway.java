package com.edu.english.config;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.time.Duration;
import java.time.Instant;
import java.util.Map;
import java.util.concurrent.Executor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

/**
 * Cửa duy nhất tới Redis, Kafka, MongoDB. Không có profile platform thì các bean đó không tồn tại và mọi hàm ở đây
 * thành no-op. Kafka và Mongo chạy trên platformExecutor: broker hay Mongo chết không làm chậm request.
 */
@Component
public class PlatformGateway {
  public static final String VOCAB_REVIEWED = "edu.vocab.reviewed";
  public static final String SESSION_RECORDED = "edu.session.completed";

  private static final Logger log = LoggerFactory.getLogger(PlatformGateway.class);
  private final ObjectProvider<StringRedisTemplate> redis;
  private final ObjectProvider<KafkaTemplate<String, String>> kafka;
  private final ObjectProvider<MongoTemplate> mongo;
  private final ObjectMapper json;
  private final Executor executor;

  public PlatformGateway(
      ObjectProvider<StringRedisTemplate> redis,
      ObjectProvider<KafkaTemplate<String, String>> kafka,
      ObjectProvider<MongoTemplate> mongo,
      ObjectMapper json,
      @Qualifier("platformExecutor") Executor executor) {
    this.redis = redis;
    this.kafka = kafka;
    this.mongo = mongo;
    this.json = json;
    this.executor = executor;
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
        log.debug("Redis serialize skipped: {}", ex.getMessage());
      } catch (Exception ex) {
        log.debug("Redis write skipped: {}", ex.getMessage());
      }
    }
    return value;
  }

  /**
   * Gửi sự kiện sau khi transaction hiện tại commit. Rollback thì không gửi, để consumer không nhận sự kiện của dữ
   * liệu không tồn tại.
   */
  public void publish(String topic, Map<String, ?> payload) {
    KafkaTemplate<String, String> producer = kafka.getIfAvailable();
    if (producer == null) return;
    Runnable send =
        () ->
            executor.execute(
                () -> {
                  try {
                    producer.send(topic, json.writeValueAsString(payload));
                  } catch (Exception ex) {
                    log.warn("Kafka publish skipped: {}", ex.getMessage());
                  }
                });
    if (TransactionSynchronizationManager.isSynchronizationActive()) {
      TransactionSynchronizationManager.registerSynchronization(
          new TransactionSynchronization() {
            @Override
            public void afterCommit() {
              send.run();
            }
          });
    } else {
      send.run();
    }
  }

  public void audit(String method, String path, int status) {
    MongoTemplate store = mongo.getIfAvailable();
    if (store == null || !path.startsWith("/api/")) return;
    Instant at = Instant.now();
    executor.execute(
        () -> {
          try {
            store.insert(Map.of("method", method, "path", path, "status", status, "at", at), "audit_logs");
          } catch (Exception ex) {
            log.debug("Audit log skipped: {}", ex.getMessage());
          }
        });
  }
}
