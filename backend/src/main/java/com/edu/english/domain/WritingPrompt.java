package com.edu.english.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import java.time.Instant;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "writing_prompts")
public class WritingPrompt {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private Enums.IeltsModule module;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private Enums.WritingTask task;

  /** Task 1: LINE, BAR, PIE, TABLE, PROCESS, MAP, LETTER. Task 2: OPINION, DISCUSSION, PROBLEM_SOLUTION... */
  @Column(nullable = false)
  private String taskKind;

  @Column(nullable = false)
  private String title;

  @Column(nullable = false)
  private String prompt;

  /** Dữ liệu biểu đồ Task 1 dạng JSON, frontend tự vẽ. */
  private String chartData;

  private String imageUrl;
  private int minWords;
  private String topic;
  private String sampleAnswer;
  private Double sampleBand;
  private int sortOrder;
  private Instant createdAt;

  @PrePersist
  void onCreate() {
    if (createdAt == null) createdAt = Instant.now();
  }
}
