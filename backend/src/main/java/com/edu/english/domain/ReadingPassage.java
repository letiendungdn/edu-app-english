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

/** Câu hỏi của bài đọc nằm trong question_groups (ownerType = READING_PASSAGE). */
@Getter
@Setter
@Entity
@Table(name = "reading_passages")
public class ReadingPassage {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(nullable = false)
  private String title;

  @Column(nullable = false)
  private String content;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private Enums.EnglishLevel level;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private Enums.IeltsModule module = Enums.IeltsModule.BOTH;

  private String topic;
  private Double bandMin;
  private Double bandMax;
  private String source;
  private String license;
  private int estimatedMin = 5;
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
