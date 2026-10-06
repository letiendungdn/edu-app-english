package com.edu.english.domain;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OrderBy;
import jakarta.persistence.Table;
import java.util.ArrayList;
import java.util.List;
import lombok.Getter;
import lombok.Setter;

/**
 * Một nhóm câu hỏi chung hướng dẫn, ví dụ "Questions 1-5: TRUE / FALSE / NOT GIVEN". Thuộc về một bài đọc hoặc
 * bài nghe qua cặp (ownerType, ownerId).
 */
@Getter
@Setter
@Entity
@Table(name = "question_groups")
public class QuestionGroup {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private Enums.OwnerType ownerType;

  @Column(nullable = false)
  private Long ownerId;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private Enums.QuestionType questionType;

  @Column(nullable = false)
  private String instruction;

  /** "NO MORE THAN TWO WORDS" → 2. NULL nếu dạng câu hỏi không gõ chữ. */
  private Integer wordLimit;

  private String imageUrl;
  private int sortOrder;

  @OneToMany(mappedBy = "group", cascade = CascadeType.ALL, orphanRemoval = true)
  @OrderBy("sortOrder ASC")
  private List<QuestionGroupOption> options = new ArrayList<>();

  @OneToMany(mappedBy = "group", cascade = CascadeType.ALL, orphanRemoval = true)
  @OrderBy("number ASC")
  private List<Question> questions = new ArrayList<>();
}
