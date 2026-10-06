package com.edu.english.service;

/** Sự kiện nội bộ quanh việc chấm AI. Phát trong transaction, xử lý sau khi commit. */
public final class GradingEvents {
  private GradingEvents() {}

  public record WritingSubmitted(Long submissionId) {}

  public record SpeakingSubmitted(Long submissionId) {}

  /** Một bài Writing trong bài thi vừa chấm xong (hoặc lỗi): bài thi cần tính lại band Writing và band tổng. */
  public record AttemptWritingFinished(Long attemptId) {}
}
