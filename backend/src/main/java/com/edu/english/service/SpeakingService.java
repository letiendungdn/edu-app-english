package com.edu.english.service;

import com.edu.english.domain.Enums.BandSource;
import com.edu.english.domain.Enums.Skill;
import com.edu.english.domain.Enums.SubmissionStatus;
import com.edu.english.domain.Enums.TaskType;
import com.edu.english.domain.SpeakingPrompt;
import com.edu.english.domain.SpeakingSubmission;
import com.edu.english.repo.SpeakingPromptRepository;
import com.edu.english.repo.SpeakingSubmissionRepository;
import com.edu.english.service.GradingEvents.SpeakingSubmitted;
import com.edu.english.service.ai.IeltsAiGrader;
import com.edu.english.service.ai.IeltsAiGrader.GradingException;
import com.edu.english.service.ai.IeltsAiGrader.SpeakingAssessment;
import com.edu.english.web.IeltsModels.CriterionScore;
import com.edu.english.web.IeltsModels.SpeakingPromptView;
import com.edu.english.web.IeltsModels.SpeakingSubmissionView;
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
import org.springframework.core.io.Resource;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

@Service
public class SpeakingService {
  static final int MIN_WORDS = 5;
  private static final Logger log = LoggerFactory.getLogger(SpeakingService.class);

  private final SpeakingPromptRepository prompts;
  private final SpeakingSubmissionRepository submissions;
  private final IeltsAiGrader grader;
  private final AiUsage usage;
  private final AudioStorage storage;
  private final BandService bands;
  private final RoadmapService roadmap;
  private final ApplicationEventPublisher events;
  private final TransactionTemplate tx;
  private final ObjectMapper json;
  private final Clock clock;
  private final WritingService writing;

  public SpeakingService(
      SpeakingPromptRepository prompts,
      SpeakingSubmissionRepository submissions,
      IeltsAiGrader grader,
      AiUsage usage,
      AudioStorage storage,
      BandService bands,
      RoadmapService roadmap,
      ApplicationEventPublisher events,
      PlatformTransactionManager transactionManager,
      ObjectMapper json,
      Clock clock,
      WritingService writing) {
    this.prompts = prompts;
    this.submissions = submissions;
    this.grader = grader;
    this.usage = usage;
    this.storage = storage;
    this.bands = bands;
    this.roadmap = roadmap;
    this.events = events;
    this.tx = new TransactionTemplate(transactionManager);
    this.json = json;
    this.clock = clock;
    this.writing = writing;
  }

  @Transactional(readOnly = true)
  public List<SpeakingPromptView> prompts(Long userId) {
    Set<Long> attempted = userId == null ? Set.of() : new HashSet<>(submissions.findPromptIdsAttemptedBy(userId));
    return prompts.findAllByOrderByPartAscSortOrderAsc().stream().map(p -> toView(p, attempted.contains(p.getId()))).toList();
  }

  @Transactional(readOnly = true)
  public SpeakingPromptView prompt(Long id, Long userId) {
    boolean attempted = userId != null && submissions.findPromptIdsAttemptedBy(userId).contains(id);
    return toView(requirePrompt(id), attempted);
  }

  /**
   * transcript do trình duyệt nhận dạng (Web Speech API). Audio là tùy chọn, lưu để người học nghe lại; server chưa
   * tự chuyển giọng nói thành chữ.
   */
  @Transactional
  public SpeakingSubmissionView submit(
      Long userId, Long promptId, String transcript, Integer durationSec, MultipartFile audio) {
    usage.requireQuota(userId);
    SpeakingPrompt prompt = requirePrompt(promptId);
    SpeakingSubmission s = new SpeakingSubmission();
    s.setUserId(userId);
    s.setPromptId(promptId);
    s.setTranscript(transcript == null ? "" : transcript.strip());
    s.setDurationSec(durationSec);
    s.setCreatedAt(clock.instant());
    if (audio != null && !audio.isEmpty()) s.setAudioPath(storage.save(audio));

    if (WritingService.wordCount(s.getTranscript()) < MIN_WORDS) {
      s.setStatus(SubmissionStatus.FAILED);
      s.setError("Không nhận được lời nói. Hãy kiểm tra micro và nói rõ hơn.");
    } else if (!grader.enabled()) {
      s.setStatus(SubmissionStatus.FAILED);
      s.setError("AI chưa được cấu hình (APP_AI_API_KEY). Bài đã được lưu, có thể chấm lại khi bật AI.");
    } else {
      s.setStatus(SubmissionStatus.PENDING);
    }
    submissions.save(s);
    if (s.getStatus() == SubmissionStatus.PENDING) events.publishEvent(new SpeakingSubmitted(s.getId()));
    return toView(s, prompt);
  }

  @Transactional(readOnly = true)
  public SpeakingSubmissionView get(Long userId, Long id) {
    SpeakingSubmission s = requireOwned(userId, id);
    return toView(s, requirePrompt(s.getPromptId()));
  }

  @Transactional(readOnly = true)
  public List<SpeakingSubmissionView> history(Long userId) {
    List<SpeakingSubmission> list = submissions.findTop50ByUserIdOrderByCreatedAtDesc(userId);
    Map<Long, SpeakingPrompt> byId =
        prompts.findAllById(list.stream().map(SpeakingSubmission::getPromptId).collect(Collectors.toSet())).stream()
            .collect(Collectors.toMap(SpeakingPrompt::getId, Function.identity()));
    return list.stream().map(s -> toView(s, byId.get(s.getPromptId()))).toList();
  }

  @Transactional
  public SpeakingSubmissionView regrade(Long userId, Long id) {
    SpeakingSubmission s = requireOwned(userId, id);
    if (s.getStatus() != SubmissionStatus.FAILED) throw new ResponseStatusException(HttpStatus.CONFLICT, "Chỉ chấm lại được bài bị lỗi");
    if (!grader.enabled()) throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE, "AI chưa được cấu hình");
    if (WritingService.wordCount(s.getTranscript()) < MIN_WORDS) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Bài không có lời nói để chấm");
    }
    s.setStatus(SubmissionStatus.PENDING);
    s.setError(null);
    events.publishEvent(new SpeakingSubmitted(s.getId()));
    return toView(s, requirePrompt(s.getPromptId()));
  }

  @Transactional(readOnly = true)
  public Resource audio(Long userId, Long id) {
    SpeakingSubmission s = requireOwned(userId, id);
    if (s.getAudioPath() == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Bài không có ghi âm");
    return storage.open(s.getAudioPath());
  }

  public void grade(Long submissionId) {
    SpeakingSubmission s = submissions.findById(submissionId).orElse(null);
    if (s == null || s.getStatus() != SubmissionStatus.PENDING) return;
    SpeakingPrompt prompt = prompts.findById(s.getPromptId()).orElse(null);
    if (prompt == null) return;
    try {
      SpeakingAssessment a = grader.gradeSpeaking(prompt, s.getTranscript(), s.getDurationSec());
      tx.executeWithoutResult(status -> applyResult(submissionId, a));
    } catch (GradingException ex) {
      log.warn("Speaking {} not graded: {}", submissionId, ex.getMessage());
      tx.executeWithoutResult(status -> fail(submissionId, ex.getMessage()));
    } catch (RuntimeException ex) {
      log.error("Speaking {} grading crashed", submissionId, ex);
      tx.executeWithoutResult(status -> fail(submissionId, "Lỗi không xác định khi chấm."));
    }
  }

  private void applyResult(Long id, SpeakingAssessment a) {
    SpeakingSubmission s = submissions.findById(id).orElseThrow();
    double fc = WritingService.clampScore(a.fluencyCoherence());
    double lr = WritingService.clampScore(a.lexicalResource());
    double gra = WritingService.clampScore(a.grammar());
    s.setScoreFc(fc);
    s.setScoreLr(lr);
    s.setScoreGra(gra);
    s.setBand(BandScale.fromCriteria(fc, lr, gra));
    s.setFeedback(writing.writeFeedback(a.summary(), a.strengths(), a.improvements(), a.corrections()));
    s.setStatus(SubmissionStatus.GRADED);
    s.setGradedAt(clock.instant());
    bands.record(s.getUserId(), Skill.SPEAKING, s.getBand(), BandSource.PRACTICE, s.getId());
    roadmap.recordProgress(s.getUserId(), TaskType.SPEAKING);
  }

  private void fail(Long id, String message) {
    submissions
        .findById(id)
        .ifPresent(
            s -> {
              s.setStatus(SubmissionStatus.FAILED);
              s.setError(message);
            });
  }

  private SpeakingSubmissionView toView(SpeakingSubmission s, SpeakingPrompt prompt) {
    return new SpeakingSubmissionView(
        s.getId(),
        s.getPromptId(),
        prompt == null ? 0 : prompt.getPart(),
        prompt == null ? null : prompt.getQuestion(),
        s.getTranscript(),
        s.getDurationSec(),
        s.getAudioPath() != null,
        s.getStatus().name(),
        List.of(
            new CriterionScore("FC", "Fluency & Coherence", s.getScoreFc()),
            new CriterionScore("LR", "Lexical Resource", s.getScoreLr()),
            new CriterionScore("GRA", "Grammatical Range & Accuracy", s.getScoreGra()),
            new CriterionScore("P", "Pronunciation (chưa chấm được từ văn bản)", s.getScoreP())),
        s.getBand(),
        WritingService.readFeedback(json, s.getFeedback()),
        s.getError(),
        s.getCreatedAt(),
        s.getGradedAt());
  }

  private SpeakingPromptView toView(SpeakingPrompt p, boolean attempted) {
    return new SpeakingPromptView(p.getId(), p.getPart(), p.getTopic(), p.getQuestion(), p.getCueCardPoints(), attempted);
  }

  private SpeakingPrompt requirePrompt(Long id) {
    if (id == null) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Thiếu câu hỏi");
    return prompts.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy câu hỏi"));
  }

  private SpeakingSubmission requireOwned(Long userId, Long id) {
    SpeakingSubmission s =
        submissions.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy bài"));
    if (!s.getUserId().equals(userId)) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy bài");
    return s;
  }
}
