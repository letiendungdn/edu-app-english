package com.edu.english;

import com.edu.english.config.AiProperties;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.security.servlet.UserDetailsServiceAutoConfiguration;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

@SpringBootApplication(exclude = UserDetailsServiceAutoConfiguration.class)
@EnableConfigurationProperties(AiProperties.class)
public class EnglishApplication {
  public static void main(String[] args) {
    SpringApplication.run(EnglishApplication.class, args);
  }
}
