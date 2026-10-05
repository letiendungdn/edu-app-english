package com.edu.english.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
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
@Table(name = "listening_attempts")
public class ListeningAttempt {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  private Long userId;

  @Column(nullable = false)
  private Long trackId;

  private int correctCount;
  private int total;
  private double percent;
  private Instant submittedAt;

  @PrePersist
  void onCreate() {
    if (submittedAt == null) submittedAt = Instant.now();
  }
}
