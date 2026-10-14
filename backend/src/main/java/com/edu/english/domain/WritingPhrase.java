package com.edu.english.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

/** Một cụm từ dùng trong bài Writing: từ nối, câu mở bài, cách mô tả xu hướng... */
@Getter
@Setter
@Entity
@Table(name = "writing_phrases")
public class WritingPhrase {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  /** TASK1, TASK2 hoặc BOTH. */
  @Column(nullable = false)
  private String task;

  @Column(nullable = false)
  private String category;

  @Column(nullable = false)
  private String phrase;

  @Column(nullable = false)
  private String meaningVi;

  @Column(nullable = false)
  private String example;

  /** Band nên dùng từ mức này trở lên. NULL là dùng được ở mọi band. */
  private Double bandMin;

  private int sortOrder;
}
