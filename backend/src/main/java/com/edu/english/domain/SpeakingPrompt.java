package com.edu.english.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.util.ArrayList;
import java.util.List;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "speaking_prompts")
public class SpeakingPrompt {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  /** 1, 2 hoặc 3. */
  private int part;

  @Column(nullable = false)
  private String topic;

  @Column(nullable = false)
  private String question;

  /** Part 2: các gạch đầu dòng "You should say". */
  @Convert(converter = StringListConverter.class)
  private List<String> cueCardPoints = new ArrayList<>();

  private int sortOrder;
}
