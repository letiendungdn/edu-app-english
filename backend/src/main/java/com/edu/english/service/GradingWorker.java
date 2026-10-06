package com.edu.english.service;

import com.edu.english.service.GradingEvents.SpeakingSubmitted;
import com.edu.english.service.GradingEvents.WritingSubmitted;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

/**
 * Chạy chấm AI trên gradingExecutor sau khi bài nộp đã commit. Chạy trước commit thì luồng nền có thể chưa thấy bản
 * ghi; chạy trong request thì người học phải chờ vài chục giây.
 */
@Component
public class GradingWorker {
  private final WritingService writing;
  private final SpeakingService speaking;

  public GradingWorker(WritingService writing, SpeakingService speaking) {
    this.writing = writing;
    this.speaking = speaking;
  }

  @Async("gradingExecutor")
  @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT, fallbackExecution = true)
  public void onWriting(WritingSubmitted event) {
    writing.grade(event.submissionId());
  }

  @Async("gradingExecutor")
  @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT, fallbackExecution = true)
  public void onSpeaking(SpeakingSubmitted event) {
    speaking.grade(event.submissionId());
  }
}
