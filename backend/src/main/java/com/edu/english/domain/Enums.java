package com.edu.english.domain;

public final class Enums {
  private Enums() {}

  public enum Role {
    USER,
    ADMIN
  }

  public enum EnglishLevel {
    A1,
    A2,
    B1,
    B2,
    C1,
    C2
  }

  public enum PartOfSpeech {
    noun,
    verb,
    adjective,
    adverb,
    preposition,
    conjunction,
    pronoun,
    interjection,
    phrase,
    phrasal_verb
  }

  public enum ContentType {
    VOCABULARY,
    GRAMMAR
  }

  /** Dạng bài IELTS. BOTH dùng cho nội dung và bảng quy đổi chung cho cả hai. */
  public enum IeltsModule {
    ACADEMIC,
    GENERAL,
    BOTH
  }

  public enum Skill {
    LISTENING,
    READING,
    WRITING,
    SPEAKING,
    OVERALL
  }

  public enum BandSource {
    PLACEMENT,
    MOCK,
    PRACTICE,
    SELF_REPORT
  }

  public enum OwnerType {
    READING_PASSAGE,
    LISTENING_TRACK
  }

  public enum QuestionType {
    MULTIPLE_CHOICE,
    MULTIPLE_CHOICE_MULTI,
    TRUE_FALSE_NOT_GIVEN,
    YES_NO_NOT_GIVEN,
    MATCHING_HEADINGS,
    MATCHING_INFORMATION,
    MATCHING_FEATURES,
    MATCHING_SENTENCE_ENDINGS,
    SENTENCE_COMPLETION,
    SUMMARY_COMPLETION,
    NOTE_COMPLETION,
    TABLE_COMPLETION,
    FLOW_CHART_COMPLETION,
    DIAGRAM_LABEL,
    SHORT_ANSWER,
    FORM_COMPLETION,
    MAP_LABELLING;

    /** Người học gõ chữ vào ô trống, chấm theo giới hạn số từ và danh sách đáp án. */
    public boolean isTyped() {
      return switch (this) {
        case SENTENCE_COMPLETION,
            SUMMARY_COMPLETION,
            NOTE_COMPLETION,
            TABLE_COMPLETION,
            FLOW_CHART_COMPLETION,
            DIAGRAM_LABEL,
            SHORT_ANSWER,
            FORM_COMPLETION -> true;
        default -> false;
      };
    }
  }

  public enum WritingTask {
    TASK1,
    TASK2
  }

  public enum SubmissionStatus {
    PENDING,
    GRADED,
    FAILED
  }

  public enum TestKind {
    PLACEMENT,
    MOCK,
    SECTION
  }

  public enum SectionRef {
    READING_PASSAGE,
    LISTENING_TRACK,
    WRITING_PROMPT,
    SPEAKING_PROMPT
  }

  public enum AttemptStatus {
    IN_PROGRESS,
    SUBMITTED
  }

  public enum RoadmapStatus {
    ACTIVE,
    ARCHIVED
  }

  public enum Feasibility {
    ON_TRACK,
    TIGHT,
    AT_RISK
  }

  public enum PhaseKind {
    FOUNDATION,
    SKILL_BUILDING,
    EXAM_PRACTICE,
    FINAL_REVIEW
  }

  public enum TaskType {
    VOCAB_REVIEW,
    VOCAB_NEW,
    GRAMMAR,
    READING,
    LISTENING,
    DICTATION,
    WRITING_T1,
    WRITING_T2,
    SPEAKING,
    MOCK_TEST,
    REVIEW_MISTAKES
  }

  public enum TaskStatus {
    TODO,
    DONE,
    SKIPPED
  }
}
