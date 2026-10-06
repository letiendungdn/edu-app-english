package com.edu.english.service;

import com.edu.english.config.AiProperties;
import com.edu.english.repo.SpeakingSubmissionRepository;
import com.edu.english.repo.WritingSubmissionRepository;
import com.edu.english.service.ai.IeltsAiGrader;
import com.edu.english.web.IeltsModels.AiStatus;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;

/** Giới hạn số lần chấm AI mỗi ngày cho mỗi người học, để kiểm soát chi phí. */
@Component
public class AiUsage {
  private final AiProperties properties;
  private final IeltsAiGrader grader;
  private final WritingSubmissionRepository writing;
  private final SpeakingSubmissionRepository speaking;
  private final Clock clock;

  public AiUsage(
      AiProperties properties,
      IeltsAiGrader grader,
      WritingSubmissionRepository writing,
      SpeakingSubmissionRepository speaking,
      Clock clock) {
    this.properties = properties;
    this.grader = grader;
    this.writing = writing;
    this.speaking = speaking;
    this.clock = clock;
  }

  public int usedToday(Long userId) {
    Instant startOfDay = LocalDate.now(clock).atStartOfDay(clock.getZone()).toInstant();
    return (int) (writing.countByUserIdAndCreatedAtAfter(userId, startOfDay)
        + speaking.countByUserIdAndCreatedAtAfter(userId, startOfDay));
  }

  public void requireQuota(Long userId) {
    if (usedToday(userId) >= properties.getDailyLimit()) {
      throw new ResponseStatusException(
          HttpStatus.TOO_MANY_REQUESTS, "Hôm nay đã chấm đủ " + properties.getDailyLimit() + " bài. Quay lại ngày mai nhé.");
    }
  }

  public AiStatus status(Long userId) {
    return new AiStatus(grader.enabled(), grader.model(), properties.getDailyLimit(), usedToday(userId));
  }
}
