package com.edu.english.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "test_attempts")
public class TestAttempt {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(nullable = false)
  private Long userId;

  @Column(nullable = false)
  private Long testId;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private Enums.AttemptStatus status = Enums.AttemptStatus.IN_PROGRESS;

  @Column(nullable = false)
  private Instant startedAt;

  private Instant submittedAt;

  /** Bản nháp Writing trong lúc thi: JSON {promptId: text}. */
  private String writingDrafts;

  private Integer rawListening;
  private Integer totalListening;
  private Integer rawReading;
  private Integer totalReading;
  private Double bandListening;
  private Double bandReading;
  private Double bandWriting;
  private Double bandSpeaking;
  private Double bandOverall;
}
