package com.edu.english;

import com.edu.english.config.AiProperties;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.data.mongo.MongoDataAutoConfiguration;
import org.springframework.boot.autoconfigure.data.redis.RedisAutoConfiguration;
import org.springframework.boot.autoconfigure.data.redis.RedisRepositoriesAutoConfiguration;
import org.springframework.boot.autoconfigure.kafka.KafkaAutoConfiguration;
import org.springframework.boot.autoconfigure.mongo.MongoAutoConfiguration;
import org.springframework.boot.autoconfigure.security.servlet.UserDetailsServiceAutoConfiguration;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

@SpringBootApplication(
    exclude = {
      UserDetailsServiceAutoConfiguration.class,
      RedisAutoConfiguration.class,
      RedisRepositoriesAutoConfiguration.class,
      MongoAutoConfiguration.class,
      MongoDataAutoConfiguration.class,
      KafkaAutoConfiguration.class
    })
@EnableConfigurationProperties(AiProperties.class)
public class EnglishApplication {
  public static void main(String[] args) {
    SpringApplication.run(EnglishApplication.class, args);
  }
}
