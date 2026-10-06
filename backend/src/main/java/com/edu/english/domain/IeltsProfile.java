package com.edu.english.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import java.time.Instant;
import java.time.LocalDate;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "ielts_profiles")
public class IeltsProfile {
  @Id private Long userId;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private Enums.IeltsModule module = Enums.IeltsModule.ACADEMIC;

  /** Band người học tự khai hoặc lấy từ placement. NULL = chưa biết. */
  private Double currentBand;

  @Column(nullable = false)
  private double targetBand;

  private LocalDate examDate;
  private int dailyMinutes = 60;
  private int studyDaysPerWeek = 6;
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
