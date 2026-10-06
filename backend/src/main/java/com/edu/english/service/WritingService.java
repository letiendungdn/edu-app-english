package com.edu.english.service;

import com.edu.english.domain.Enums.BandSource;
import com.edu.english.domain.Enums.IeltsModule;
import com.edu.english.domain.Enums.Skill;
import com.edu.english.domain.Enums.SubmissionStatus;
import com.edu.english.domain.Enums.TaskType;
import com.edu.english.domain.Enums.WritingTask;
import com.edu.english.domain.WritingPrompt;
import com.edu.english.domain.WritingSubmission;
import com.edu.english.repo.IeltsProfileRepository;
import com.edu.english.repo.WritingPromptRepository;
import com.edu.english.repo.WritingSubmissionRepository;
import com.edu.english.service.GradingEvents.AttemptWritingFinished;
import com.edu.english.service.GradingEvents.WritingSubmitted;
import com.edu.english.service.ai.IeltsAiGrader;
import com.edu.english.service.ai.IeltsAiGrader.GradingException;
import com.edu.english.service.ai.IeltsAiGrader.WritingAssessment;
import com.edu.english.web.IeltsModels.Correction;
import com.edu.english.web.IeltsModels.CriterionScore;
import com.edu.english.web.IeltsModels.Feedback;
import com.edu.english.web.IeltsModels.WritingPromptView;
import com.edu.english.web.IeltsModels.WritingSubmissionView;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.time.Clock;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;
import org.springframework.web.server.ResponseStatusException;

@Service
public class WritingService {
  static final int MIN_GRADABLE_WORDS = 20;
  static final int MAX_WORDS = 1000;
  private static final Logger log = LoggerFactory.getLogger(WritingService.class);

  private final WritingPromptRepository prompts;
  private final WritingSubmissionRepository submissions;
  private final IeltsProfileRepository profiles;
  private final IeltsAiGrader grader;
  private final AiUsage usage;
  private final BandService bands;
  private final RoadmapService roadmap;
  private final ApplicationEventPublisher events;
  private final TransactionTemplate tx;
  private final ObjectMapper json;
  private final Clock clock;

  public WritingService(
      WritingPromptRepository prompts,
      WritingSubmissionRepository submissions,
      IeltsProfileRepository profiles,
      IeltsAiGrader grader,
      AiUsage usage,
      BandService bands,
      RoadmapService roadmap,
      ApplicationEventPublisher events,
      PlatformTransactionManager transactionManager,
      ObjectMapper json,
      Clock clock) {
    this.prompts = prompts;
    this.submissions = submissions;
    this.profiles = profiles;
    this.grader = grader;
    this.usage = usage;
    this.bands = bands;
    this.roadmap = roadmap;
    this.events = events;
    this.tx = new TransactionTemplate(transactionManager);
    this.json = json;
    this.clock = clock;
  }

  @Transactional(readOnly = true)
  public List<WritingPromptView> prompts(Long userId) {
    Set<Long> attempted = userId == null ? Set.of() : new HashSet<>(submissions.findPromptIdsAttemptedBy(userId));
    IeltsModule module = userId == null ? null : profiles.findById(userId).map(p -> p.getModule()).orElse(null);
    return prompts.findAllByOrderByTaskAscSortOrderAsc().stream()
        .filter(p -> module == null || p.getModule() == IeltsModule.BOTH || p.getModule() == module)
        .map(p -> toView(p, attempted.contains(p.getId())))
        .toList();
  }

  @Transactional(readOnly = true)
  public WritingPromptView prompt(Long id, Long userId) {
    WritingPrompt p = requirePrompt(id);
    boolean attempted = userId != null && submissions.findPromptIdsAttemptedBy(userId).contains(id);
    return toView(p, attempted);
  }

  @Transactional
  public WritingSubmissionView submit(Long userId, Long promptId, String text, Integer timeSpentSec) {
    usage.requireQuota(userId);
    WritingSubmission saved = create(userId, promptId, null, text, timeSpentSec);
    return toView(saved, requirePrompt(promptId));
  }

  /** Bài viết nộp trong bài thi: không tính hạn mức ngày, để bài thi luôn chấm đủ. */
  @Transactional
  public WritingSubmission submitForAttempt(Long userId, Long attemptId, Long promptId, String text) {
    return create(userId, promptId, attemptId, text == null ? "" : text, null);
  }

  private WritingSubmission create(Long userId, Long promptId, Long attemptId, String text, Integer timeSpentSec) {
    requirePrompt(promptId);
    String body = text == null ? "" : text.strip();
    int words = wordCount(body);
    if (attemptId == null && words < MIN_GRADABLE_WORDS) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Bài quá ngắn để chấm (tối thiểu " + MIN_GRADABLE_WORDS + " từ)");
    }
    if (words > MAX_WORDS) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Bài dài quá " + MAX_WORDS + " từ");
    }
    WritingSubmission s = new WritingSubmission();
    s.setUserId(userId);
    s.setPromptId(promptId);
    s.setAttemptId(attemptId);
    s.setText(body);
    s.setWordCount(words);
    s.setTimeSpentSec(timeSpentSec);
    s.setCreatedAt(clock.instant());
    if (words < MIN_GRADABLE_WORDS) {
      // Bài thi bỏ trống Writing: chấm 0 luôn, không tốn lượt AI.
      s.setStatus(SubmissionStatus.GRADED);
      s.setBand(0.0);
      s.setGrader("RULE");
      s.setError("Bài viết trống hoặc quá ngắn.");
      s.setGradedAt(clock.instant());
      submissions.save(s);
      if (attemptId != null) events.publishEvent(new AttemptWritingFinished(attemptId));
      return s;
    }
    if (!grader.enabled()) {
      s.setStatus(SubmissionStatus.FAILED);
      s.setError("AI chưa được cấu hình (APP_AI_API_KEY). Bài đã được lưu, có thể chấm lại khi bật AI.");
      submissions.save(s);
      if (attemptId != null) events.publishEvent(new AttemptWritingFinished(attemptId));
      return s;
    }
    s.setStatus(SubmissionStatus.PENDING);
    submissions.save(s);
    events.publishEvent(new WritingSubmitted(s.getId()));
    return s;
  }

  @Transactional(readOnly = true)
  public WritingSubmissionView get(Long userId, Long id) {
    WritingSubmission s = requireOwned(userId, id);
    return toView(s, requirePrompt(s.getPromptId()));
  }

  @Transactional(readOnly = true)
  public List<WritingSubmissionView> history(Long userId) {
    List<WritingSubmission> list = submissions.findTop50ByUserIdOrderByCreatedAtDesc(userId);
    Map<Long, WritingPrompt> byId =
        prompts.findAllById(list.stream().map(WritingSubmission::getPromptId).collect(Collectors.toSet())).stream()
            .collect(Collectors.toMap(WritingPrompt::getId, Function.identity()));
    return list.stream().map(s -> toView(s, byId.get(s.getPromptId()))).toList();
  }

  @Transactional
  public WritingSubmissionView regrade(Long userId, Long id) {
    WritingSubmission s = requireOwned(userId, id);
    if (s.getStatus() != SubmissionStatus.FAILED) {
      throw new ResponseStatusException(HttpStatus.CONFLICT, "Chỉ chấm lại được bài bị lỗi");
    }
    if (!grader.enabled()) throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE, "AI chưa được cấu hình");
    s.setStatus(SubmissionStatus.PENDING);
    s.setError(null);
    events.publishEvent(new WritingSubmitted(s.getId()));
    return toView(s, requirePrompt(s.getPromptId()));
  }

  /** Chạy trên luồng nền. Gọi AI ngoài transaction để không giữ kết nối database trong lúc chờ. */
  public void grade(Long submissionId) {
    WritingSubmission s = submissions.findById(submissionId).orElse(null);
    if (s == null || s.getStatus() != SubmissionStatus.PENDING) return;
    WritingPrompt prompt = prompts.findById(s.getPromptId()).orElse(null);
    if (prompt == null) return;
    try {
      WritingAssessment a = grader.gradeWriting(prompt, s.getText(), s.getWordCount());
      tx.executeWithoutResult(status -> applyResult(submissionId, prompt, a));
    } catch (GradingException ex) {
      log.warn("Writing {} not graded: {}", submissionId, ex.getMessage());
      tx.executeWithoutResult(status -> fail(submissionId, ex.getMessage()));
    } catch (RuntimeException ex) {
      log.error("Writing {} grading crashed", submissionId, ex);
      tx.executeWithoutResult(status -> fail(submissionId, "Lỗi không xác định khi chấm."));
    }
  }

  private void applyResult(Long id, WritingPrompt prompt, WritingAssessment a) {
    WritingSubmission s = submissions.findById(id).orElseThrow();
    double ta = clampScore(a.taskResponse());
    double cc = clampScore(a.coherenceCohesion());
    double lr = clampScore(a.lexicalResource());
    double gra = clampScore(a.grammar());
    s.setScoreTa(ta);
    s.setScoreCc(cc);
    s.setScoreLr(lr);
    s.setScoreGra(gra);
    s.setBand(BandScale.fromCriteria(ta, cc, lr, gra));
    s.setFeedback(writeFeedback(a.summary(), a.strengths(), a.improvements(), a.corrections()));
    s.setStatus(SubmissionStatus.GRADED);
    s.setGrader("AI:" + grader.model());
    s.setGradedAt(clock.instant());
    if (s.getAttemptId() != null) {
      events.publishEvent(new AttemptWritingFinished(s.getAttemptId()));
    } else {
      bands.record(s.getUserId(), Skill.WRITING, s.getBand(), BandSource.PRACTICE, s.getId());
      roadmap.recordProgress(s.getUserId(), prompt.getTask() == WritingTask.TASK1 ? TaskType.WRITING_T1 : TaskType.WRITING_T2);
    }
  }

  private void fail(Long id, String message) {
    submissions
        .findById(id)
        .ifPresent(
            s -> {
              s.setStatus(SubmissionStatus.FAILED);
              s.setError(message);
              if (s.getAttemptId() != null) events.publishEvent(new AttemptWritingFinished(s.getAttemptId()));
            });
  }

  public WritingSubmissionView toView(WritingSubmission s, WritingPrompt prompt) {
    return new WritingSubmissionView(
        s.getId(),
        s.getPromptId(),
        prompt == null ? null : prompt.getTitle(),
        prompt == null ? null : prompt.getTask().name(),
        s.getText(),
        s.getWordCount(),
        s.getTimeSpentSec(),
        s.getStatus().name(),
        List.of(
            new CriterionScore("TA", prompt != null && prompt.getTask() == WritingTask.TASK1 ? "Task Achievement" : "Task Response", s.getScoreTa()),
            new CriterionScore("CC", "Coherence & Cohesion", s.getScoreCc()),
            new CriterionScore("LR", "Lexical Resource", s.getScoreLr()),
            new CriterionScore("GRA", "Grammatical Range & Accuracy", s.getScoreGra())),
        s.getBand(),
        readFeedback(json, s.getFeedback()),
        s.getError(),
        s.getCreatedAt(),
        s.getGradedAt());
  }

  private WritingPromptView toView(WritingPrompt p, boolean attempted) {
    return new WritingPromptView(
        p.getId(),
        p.getModule().name(),
        p.getTask().name(),
        p.getTaskKind(),
        p.getTitle(),
        p.getPrompt(),
        p.getChartData(),
        p.getImageUrl(),
        p.getMinWords(),
        p.getTopic(),
        attempted);
  }

  WritingPrompt requirePrompt(Long id) {
    if (id == null) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Thiếu đề bài");
    return prompts.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy đề"));
  }

  private WritingSubmission requireOwned(Long userId, Long id) {
    WritingSubmission s =
        submissions.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy bài"));
    if (!s.getUserId().equals(userId)) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy bài");
    return s;
  }

  /** Đếm từ như giám khảo: chuỗi có chữ hoặc số, ngăn cách bởi khoảng trắng. */
  static int wordCount(String text) {
    if (text == null || text.isBlank()) return 0;
    int count = 0;
    for (String token : text.trim().split("\\s+")) {
      if (token.chars().anyMatch(Character::isLetterOrDigit)) count++;
    }
    return count;
  }

  static double clampScore(int score) {
    return Math.max(0, Math.min(9, score));
  }

  String writeFeedback(
      String summary, List<String> strengths, List<String> improvements, List<IeltsAiGrader.Correction> corrections) {
    Feedback feedback =
        new Feedback(
            summary,
            strengths == null ? List.of() : strengths,
            improvements == null ? List.of() : improvements,
            corrections == null
                ? List.of()
                : corrections.stream().map(c -> new Correction(c.original(), c.suggestion(), c.reason())).toList());
    try {
      return json.writeValueAsString(feedback);
    } catch (JsonProcessingException ex) {
      throw new IllegalStateException(ex);
    }
  }

  static Feedback readFeedback(ObjectMapper json, String value) {
    if (value == null || value.isBlank()) return null;
    try {
      return json.readValue(value, Feedback.class);
    } catch (JsonProcessingException ex) {
      return null;
    }
  }
}
