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

/** Câu trả lời một câu Reading/Listening sau khi chấm. Chỉ thêm, không sửa (trừ reviewedAt). */
@Getter
@Setter
@Entity
@Table(name = "practice_answers")
public class PracticeAnswer {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(nullable = false)
  private Long userId;

  @Column(nullable = false)
  private Long questionId;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private Enums.QuestionType questionType;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private Enums.Skill skill;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private Enums.OwnerType ownerType;

  @Column(nullable = false)
  private Long ownerId;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private Enums.BandSource source;

  private Long sourceRefId;
  private String given;
  private int points;
  private int maxPoints;

  @Column(nullable = false)
  private Instant answeredAt;

  /** Người học đã xem lại và bấm "Đã hiểu". */
  private Instant reviewedAt;

  @PrePersist
  void onCreate() {
    if (answeredAt == null) answeredAt = Instant.now();
  }
}
