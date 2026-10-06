package com.edu.english.domain;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OrderBy;
import jakarta.persistence.Table;
import java.util.ArrayList;
import java.util.List;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "questions")
public class Question {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "group_id", nullable = false)
  private QuestionGroup group;

  /** Số câu như trên đề thật (1-40). */
  private int number;

  /** Câu hỏi, hoặc câu có chỗ trống đánh dấu bằng {{blank}}. */
  @Column(nullable = false)
  private String prompt;

  /** Mọi đáp án được chấp nhận. Phần trong ngoặc là tùy chọn: "(the) river bank". */
  @Convert(converter = StringListConverter.class)
  @Column(nullable = false)
  private List<String> acceptedAnswers = new ArrayList<>();

  private String explanation;

  /** Đoạn trong bài chứa đáp án, hiện sau khi nộp. */
  private String evidence;

  @OneToMany(mappedBy = "question", cascade = CascadeType.ALL, orphanRemoval = true)
  @OrderBy("sortOrder ASC")
  private List<QuestionOption> options = new ArrayList<>();
}
