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
import java.time.Instant;
import lombok.Getter;
import lombok.Setter;

/** Câu hỏi của bài nghe nằm trong question_groups (ownerType = LISTENING_TRACK). */
@Getter
@Setter
@Entity
@Table(name = "listening_tracks")
public class ListeningTrack {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(nullable = false)
  private String title;

  private String youtubeUrl;
  private String audioUrl;

  @Column
  private String transcript;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private Enums.EnglishLevel level;

  /** Part 1-4 của đề IELTS. NULL với bài nghe luyện chung. */
  private Integer ieltsPart;

  private Double bandMin;
  private Double bandMax;
  private String source;
  private String license;
  private Integer durationSec;
  private int sortOrder;
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
