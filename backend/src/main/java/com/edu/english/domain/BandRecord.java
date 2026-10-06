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
@Table(name = "band_records")
public class BandRecord {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(nullable = false)
  private Long userId;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private Enums.Skill skill;

  private double band;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private Enums.BandSource source;

  private Long sourceRefId;

  @Column(nullable = false)
  private Instant recordedAt;

  @PrePersist
  void onCreate() {
    if (recordedAt == null) recordedAt = Instant.now();
  }
}
