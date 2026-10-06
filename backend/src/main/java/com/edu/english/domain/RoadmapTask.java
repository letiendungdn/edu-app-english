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

@Getter
@Setter
@Entity
@Table(name = "roadmap_tasks")
public class RoadmapTask {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(nullable = false)
  private Long roadmapId;

  @Column(nullable = false)
  private Long phaseId;

  @Column(nullable = false)
  private LocalDate dueDate;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private Enums.TaskType type;

  @Enumerated(EnumType.STRING)
  private Enums.Skill skill;

  /** Nội dung cụ thể. NULL thì app chọn bài phù hợp lần đầu người học mở task. */
  @Enumerated(EnumType.STRING)
  private Enums.SectionRef refType;

  private Long refId;

  @Column(nullable = false)
  private String title;

  private int estimatedMin;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private Enums.TaskStatus status = Enums.TaskStatus.TODO;

  private Instant completedAt;
}
