package com.edu.english.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import java.time.Instant;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(
    name = "srs_cards",
    uniqueConstraints =
        @UniqueConstraint(columnNames = {"userId", "contentType", "contentId"}))
public class SrsCard {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(nullable = false)
  private Long userId;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private Enums.ContentType contentType;

  @Column(nullable = false)
  private Long contentId;

  private double easeFactor = 2.5;
  private int intervalDays;
  private int repetitions;
  private Instant nextReviewAt = Instant.now();
  private Instant lastReviewAt;
  private int correctCount;
  private int wrongCount;
  private int reviewStreak;
  private boolean mastered;

  private Instant createdAt;
  private Instant updatedAt;

  @PrePersist
  void onCreate() {
    Instant now = Instant.now();
    createdAt = now;
    updatedAt = now;
  }

  @PreUpdate
  void onUpdate() {
    updatedAt = Instant.now();
  }
}
