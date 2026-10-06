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
@Table(name = "speaking_submissions")
public class SpeakingSubmission {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(nullable = false)
  private Long userId;

  @Column(nullable = false)
  private Long promptId;

  /** Đường dẫn tương đối trong app.storage.dir. */
  private String audioPath;

  private String transcript;
  private Integer durationSec;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private Enums.SubmissionStatus status = Enums.SubmissionStatus.PENDING;

  private Double scoreFc;
  private Double scoreLr;
  private Double scoreGra;

  /** Không chấm được phát âm từ transcript nên để NULL. */
  @Column(name = "score_p")
  private Double scoreP;

  private Double band;
  private String feedback;
  private String error;
  private Instant createdAt;
  private Instant gradedAt;

  @PrePersist
  void onCreate() {
    if (createdAt == null) createdAt = Instant.now();
  }
}
