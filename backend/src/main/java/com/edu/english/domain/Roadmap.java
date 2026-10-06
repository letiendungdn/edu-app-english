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
import java.time.LocalDate;
import lombok.Getter;
import lombok.Setter;

/** Mỗi lần sinh lại lộ trình là một bản mới; bản cũ chuyển ARCHIVED và giữ nguyên lịch sử task đã làm. */
@Getter
@Setter
@Entity
@Table(name = "roadmaps")
public class Roadmap {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(nullable = false)
  private Long userId;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private Enums.RoadmapStatus status = Enums.RoadmapStatus.ACTIVE;

  @Column(nullable = false)
  private LocalDate startDate;

  @Column(nullable = false)
  private LocalDate endDate;

  private LocalDate examDate;
  private Double startBand;
  private double targetBand;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private Enums.Feasibility feasibility;

  private int version;

  @Column(nullable = false)
  private Instant generatedAt;
}
