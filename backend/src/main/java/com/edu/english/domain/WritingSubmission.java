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
@Table(name = "writing_submissions")
public class WritingSubmission {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(nullable = false)
  private Long userId;

  @Column(nullable = false)
  private Long promptId;

  /** Bài viết nộp trong mock/placement test. NULL nếu luyện riêng. */
  private Long attemptId;

  @Column(nullable = false)
  private String text;

  private int wordCount;
  private Integer timeSpentSec;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private Enums.SubmissionStatus status = Enums.SubmissionStatus.PENDING;

  private Double scoreTa;
  private Double scoreCc;
  private Double scoreLr;
  private Double scoreGra;
  private Double band;

  /** JSON: {summary, strengths[], improvements[], corrections[{original, suggestion, reason}]}. */
  private String feedback;

  private String error;
  private String grader;
  private Instant createdAt;
  private Instant gradedAt;

  @PrePersist
  void onCreate() {
    if (createdAt == null) createdAt = Instant.now();
  }
}
