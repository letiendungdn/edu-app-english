package com.edu.english.config;

import com.edu.english.service.RoadmapPlanner;
import java.time.Clock;
import java.time.ZoneId;
import java.util.concurrent.Executor;
import java.util.concurrent.ThreadPoolExecutor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

@Configuration
@EnableAsync
public class AppConfig {
  /** "Hôm nay" của người học: streak, giờ học, lộ trình đều tính theo múi giờ này, không theo máy chủ. */
  @Bean
  Clock clock(@Value("${app.timezone}") String zone) {
    return Clock.system(ZoneId.of(zone));
  }

  /** Chấm Writing/Speaking bằng AI mất vài chục giây nên chạy nền, không giữ request HTTP. */
  @Bean(name = "gradingExecutor")
  Executor gradingExecutor() {
    ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
    executor.setThreadNamePrefix("grading-");
    executor.setCorePoolSize(2);
    executor.setMaxPoolSize(4);
    executor.setQueueCapacity(200);
    executor.initialize();
    return executor;
  }

  /**
   * Gửi Kafka và ghi audit Mongo. Hàng đợi có giới hạn và bỏ việc khi đầy: hạ tầng phụ chết không được làm chậm
   * hay làm hỏng request của người học.
   */
  @Bean(name = "platformExecutor")
  Executor platformExecutor() {
    ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
    executor.setThreadNamePrefix("platform-");
    executor.setCorePoolSize(1);
    executor.setMaxPoolSize(2);
    executor.setQueueCapacity(1000);
    executor.setRejectedExecutionHandler(new ThreadPoolExecutor.DiscardPolicy());
    executor.initialize();
    return executor;
  }

  @Bean
  RoadmapPlanner.Settings roadmapSettings(
      @Value("${app.roadmap.default-weeks}") int defaultWeeks,
      @Value("${app.roadmap.weeks-per-half-band}") int weeksPerHalfBand,
      @Value("${app.roadmap.baseline-daily-minutes}") int baselineDailyMinutes,
      @Value("${app.roadmap.phase-ratio.foundation}") double foundation,
      @Value("${app.roadmap.phase-ratio.skill-building}") double skillBuilding,
      @Value("${app.roadmap.phase-ratio.exam-practice}") double examPractice,
      @Value("${app.roadmap.phase-ratio.final-review}") double finalReview) {
    return new RoadmapPlanner.Settings(
        defaultWeeks, weeksPerHalfBand, baselineDailyMinutes, foundation, skillBuilding, examPractice, finalReview);
  }
}
