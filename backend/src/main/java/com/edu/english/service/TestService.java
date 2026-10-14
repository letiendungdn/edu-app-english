package com.edu.english.service;

import com.edu.english.domain.AttemptAnswer;
import com.edu.english.domain.Enums.AttemptStatus;
import com.edu.english.domain.Enums.BandSource;
import com.edu.english.domain.Enums.OwnerType;
import com.edu.english.domain.Enums.SectionRef;
import com.edu.english.domain.Enums.Skill;
import com.edu.english.domain.Enums.SubmissionStatus;
import com.edu.english.domain.Enums.TaskType;
import com.edu.english.domain.Enums.TestKind;
import com.edu.english.domain.Enums.WritingTask;
import com.edu.english.domain.IeltsTest;
import com.edu.english.domain.ListeningTrack;
import com.edu.english.domain.ReadingPassage;
import com.edu.english.domain.TestAttempt;
import com.edu.english.domain.TestSection;
import com.edu.english.domain.WritingPrompt;
import com.edu.english.domain.SpeakingSubmission;
import com.edu.english.domain.WritingSubmission;
import com.edu.english.repo.AttemptAnswerRepository;
import com.edu.english.repo.IeltsProfileRepository;
import com.edu.english.repo.IeltsTestRepository;
import com.edu.english.repo.ListeningTrackRepository;
import com.edu.english.repo.ReadingPassageRepository;
import com.edu.english.repo.TestAttemptRepository;
import com.edu.english.repo.WritingPromptRepository;
import com.edu.english.repo.SpeakingPromptRepository;
import com.edu.english.repo.SpeakingSubmissionRepository;
import com.edu.english.repo.WritingSubmissionRepository;
import com.edu.english.service.GradingEvents.AttemptSpeakingFinished;
import com.edu.english.service.GradingEvents.AttemptWritingFinished;
import com.edu.english.web.IeltsModels.AttemptResult;
import com.edu.english.web.IeltsModels.AttemptSaveRequest;
import com.edu.english.web.IeltsModels.AttemptSummary;
import com.edu.english.web.IeltsModels.AttemptView;
import com.edu.english.web.IeltsModels.SectionResult;
import com.edu.english.web.IeltsModels.SectionView;
import com.edu.english.web.IeltsModels.SkillScore;
import com.edu.english.web.IeltsModels.TestListItem;
import com.edu.english.web.IeltsModels.WritingSubmissionView;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;
import org.springframework.web.server.ResponseStatusException;

@Service
public class TestService {
  /** Mạng chậm hoặc đồng hồ máy lệch: vẫn nhận lần lưu cuối trong khoảng này sau khi hết giờ. */
  static final Duration GRACE = Duration.ofMinutes(2);

  /**
   * Kỹ năng bỏ trống quá nửa số câu thì không quy ra band: bài nộp trắng cho band 0, kéo band hiện tại và lộ trình
   * lệch hẳn. Điểm thô vẫn hiện để người học thấy.
   */
  static final double MIN_ANSWERED_RATIO = 0.5;

  /** WritingService chấm 0 bài viết trống hoặc quá ngắn bằng luật này, không qua AI. */
  static final String BLANK_GRADER = "RULE";

  private static final TypeReference<Map<String, String>> DRAFTS = new TypeReference<>() {};

  private final IeltsTestRepository tests;
  private final TestAttemptRepository attempts;
  private final AttemptAnswerRepository answers;
  private final ReadingPassageRepository passages;
  private final ListeningTrackRepository tracks;
  private final WritingPromptRepository writingPrompts;
  private final WritingSubmissionRepository writingSubmissions;
  private final IeltsProfileRepository profiles;
  private final QuestionBank questionBank;
  private final BandService bands;
  private final WritingService writing;
  private final ProfileService profileService;
  private final RoadmapService roadmap;
  private final MistakeService mistakes;
  private final SpeakingService speaking;
  private final SpeakingSubmissionRepository speakingSubmissions;
  private final SpeakingPromptRepository speakingPrompts;
  private final ObjectMapper json;
  private final Clock clock;

  public TestService(
      IeltsTestRepository tests,
      TestAttemptRepository attempts,
      AttemptAnswerRepository answers,
      ReadingPassageRepository passages,
      ListeningTrackRepository tracks,
      WritingPromptRepository writingPrompts,
      WritingSubmissionRepository writingSubmissions,
      IeltsProfileRepository profiles,
      QuestionBank questionBank,
      BandService bands,
      WritingService writing,
      ProfileService profileService,
      RoadmapService roadmap,
      MistakeService mistakes,
      SpeakingService speaking,
      SpeakingSubmissionRepository speakingSubmissions,
      SpeakingPromptRepository speakingPrompts,
      ObjectMapper json,
      Clock clock) {
    this.tests = tests;
    this.attempts = attempts;
    this.answers = answers;
    this.passages = passages;
    this.tracks = tracks;
    this.writingPrompts = writingPrompts;
    this.writingSubmissions = writingSubmissions;
    this.profiles = profiles;
    this.questionBank = questionBank;
    this.bands = bands;
    this.writing = writing;
    this.profileService = profileService;
    this.roadmap = roadmap;
    this.mistakes = mistakes;
    this.speaking = speaking;
    this.speakingSubmissions = speakingSubmissions;
    this.speakingPrompts = speakingPrompts;
    this.json = json;
    this.clock = clock;
  }

  @Transactional(readOnly = true)
  public List<TestListItem> list(Long userId) {
    Map<Long, TestAttempt> last = new HashMap<>();
    if (userId != null) {
      for (TestAttempt a : attempts.findByUserIdOrderByStartedAtDesc(userId)) last.putIfAbsent(a.getTestId(), a);
    }
    // Thứ tự theo enum (đầu vào → thi thử → một phần), không theo chữ cái.
    return tests.findByPublishedTrue().stream()
        .sorted(Comparator.comparing((IeltsTest t) -> t.getKind().ordinal()).thenComparing(IeltsTest::getSortOrder))
        .map(
            t ->
                new TestListItem(
                    t.getId(),
                    t.getKind().name(),
                    t.getModule().name(),
                    t.getTitle(),
                    t.getDescription(),
                    t.getDurationMin(),
                    t.getSections().stream().map(s -> s.getSkill().name()).distinct().toList(),
                    summary(last.get(t.getId()))))
        .toList();
  }

  @Transactional(readOnly = true)
  public List<AttemptSummary> history(Long userId) {
    return attempts.findByUserIdOrderByStartedAtDesc(userId).stream().map(TestService::summary).toList();
  }

  /** Bắt đầu bài thi, hoặc trả lại bài đang làm dở của chính bài thi đó. */
  @Transactional
  public AttemptView start(Long userId, Long testId) {
    IeltsTest test = requireTest(testId);
    TestAttempt attempt =
        attempts
            .findFirstByUserIdAndTestIdAndStatusOrderByStartedAtDesc(userId, testId, AttemptStatus.IN_PROGRESS)
            .orElseGet(
                () -> {
                  TestAttempt created = new TestAttempt();
                  created.setUserId(userId);
                  created.setTestId(testId);
                  created.setStatus(AttemptStatus.IN_PROGRESS);
                  created.setStartedAt(clock.instant());
                  return attempts.save(created);
                });
    return toView(attempt, test);
  }

  @Transactional
  public AttemptView startPlacement(Long userId) {
    IeltsTest test =
        tests
            .findFirstByKindAndPublishedTrueOrderBySortOrderAsc(TestKind.PLACEMENT)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Chưa có bài kiểm tra đầu vào"));
    return start(userId, test.getId());
  }

  @Transactional(readOnly = true)
  public AttemptView get(Long userId, Long attemptId) {
    TestAttempt attempt = requireOwned(userId, attemptId);
    return toView(attempt, requireTest(attempt.getTestId()));
  }

  /** Lưu tự động trong lúc làm bài. Chỉ ghi các câu được gửi lên, không xoá câu đã lưu trước đó. */
  @Transactional
  public void save(Long userId, Long attemptId, AttemptSaveRequest body) {
    TestAttempt attempt = requireOwned(userId, attemptId);
    if (attempt.getStatus() != AttemptStatus.IN_PROGRESS) {
      throw new ResponseStatusException(HttpStatus.CONFLICT, "Bài đã nộp");
    }
    IeltsTest test = requireTest(attempt.getTestId());
    if (clock.instant().isAfter(deadline(attempt, test).plus(GRACE))) {
      throw new ResponseStatusException(HttpStatus.CONFLICT, "Đã hết giờ làm bài");
    }
    store(attempt, body);
  }

  @Transactional
  public AttemptResult submit(Long userId, Long attemptId, AttemptSaveRequest body) {
    TestAttempt attempt = requireOwned(userId, attemptId);
    IeltsTest test = requireTest(attempt.getTestId());
    if (attempt.getStatus() != AttemptStatus.IN_PROGRESS) return result(userId, attemptId);
    // Bài nộp trễ quá giờ vẫn được chấm phần đã lưu, nhưng không nhận thêm câu trả lời mới.
    if (body != null && !clock.instant().isAfter(deadline(attempt, test).plus(GRACE))) store(attempt, body);

    Map<String, String> given = savedAnswers(attempt.getId());
    Map<Long, AttemptAnswer> rows =
        answers.findByAttemptId(attempt.getId()).stream().collect(Collectors.toMap(AttemptAnswer::getQuestionId, Function.identity()));
    // [điểm, điểm tối đa, số câu đã trả lời, số câu]
    int[] listening = new int[4];
    int[] reading = new int[4];
    for (TestSection section : test.getSections()) {
      OwnerType owner = ownerOf(section.getRefType());
      if (owner == null) continue;
      QuestionBank.Graded graded = questionBank.grade(owner, section.getRefId(), given);
      mistakes.record(
          userId,
          owner,
          section.getRefId(),
          test.getKind() == TestKind.PLACEMENT ? BandSource.PLACEMENT : BandSource.MOCK,
          attempt.getId(),
          graded);
      int[] acc = section.getSkill() == Skill.LISTENING ? listening : reading;
      acc[0] += graded.points();
      acc[1] += graded.maxPoints();
      for (var r : graded.results()) {
        acc[3]++;
        if (r.given() != null && !r.given().isBlank()) acc[2]++;
      }
      graded.pointsByQuestion()
          .forEach(
              (questionId, points) -> {
                AttemptAnswer row = rows.get(questionId);
                if (row != null) row.setPoints(points);
              });
    }
    BandSource source = test.getKind() == TestKind.PLACEMENT ? BandSource.PLACEMENT : BandSource.MOCK;
    if (listening[1] > 0) {
      attempt.setRawListening(listening[0]);
      attempt.setTotalListening(listening[1]);
      if (enoughAnswered(listening)) {
        attempt.setBandListening(bands.convert(Skill.LISTENING, test.getModule(), listening[0], listening[1]));
        bands.record(userId, Skill.LISTENING, attempt.getBandListening(), source, attempt.getId());
      }
    }
    if (reading[1] > 0) {
      attempt.setRawReading(reading[0]);
      attempt.setTotalReading(reading[1]);
      if (enoughAnswered(reading)) {
        attempt.setBandReading(bands.convert(Skill.READING, test.getModule(), reading[0], reading[1]));
        bands.record(userId, Skill.READING, attempt.getBandReading(), source, attempt.getId());
      }
    }
    SpeakingState spoken = speakingState(attempt, test);
    if (!spoken.pending()) settleSpeaking(attempt, test, spoken);
    attempt.setStatus(AttemptStatus.SUBMITTED);
    attempt.setSubmittedAt(clock.instant());

    Map<String, String> drafts = drafts(attempt);
    boolean hasWriting = false;
    for (TestSection section : test.getSections()) {
      if (section.getRefType() != SectionRef.WRITING_PROMPT) continue;
      hasWriting = true;
      writing.submitForAttempt(userId, attempt.getId(), section.getRefId(), drafts.get(String.valueOf(section.getRefId())));
    }
    attempt.setBandOverall(overall(attempt, hasWriting || spoken.pending()));

    if (test.getKind() == TestKind.MOCK) roadmap.recordProgress(userId, TaskType.MOCK_TEST);
    afterResults(userId, test, attempt);
    return result(userId, attemptId);
  }

  /** Writing của bài thi chấm xong: tính band Writing, band tổng, rồi cập nhật hồ sơ và lộ trình. */
  @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT, fallbackExecution = true)
  @Transactional(propagation = Propagation.REQUIRES_NEW)
  public void onWritingFinished(AttemptWritingFinished event) {
    TestAttempt attempt = attempts.lockById(event.attemptId()).orElse(null);
    if (attempt == null || attempt.getStatus() != AttemptStatus.SUBMITTED) return;
    List<WritingSubmission> subs = writingSubmissions.findByAttemptId(attempt.getId());
    if (subs.stream().anyMatch(s -> s.getStatus() == SubmissionStatus.PENDING)) return;
    IeltsTest test = requireTest(attempt.getTestId());
    Map<Long, WritingPrompt> prompts =
        writingPrompts.findAllById(subs.stream().map(WritingSubmission::getPromptId).toList()).stream()
            .collect(Collectors.toMap(WritingPrompt::getId, Function.identity()));
    Double task1 = null;
    Double task2 = null;
    for (WritingSubmission s : subs) {
      if (s.getStatus() != SubmissionStatus.GRADED || s.getBand() == null) continue;
      // Bỏ trống (chấm 0 theo luật, không qua AI) thì coi như không làm, giống Listening/Reading bỏ trống quá nửa.
      if (BLANK_GRADER.equals(s.getGrader())) continue;
      WritingPrompt p = prompts.get(s.getPromptId());
      if (p != null && p.getTask() == WritingTask.TASK1) task1 = s.getBand();
      else task2 = s.getBand();
    }
    Double band = BandScale.writing(task1, task2);
    boolean firstWritingBand = attempt.getBandWriting() == null && band != null;
    boolean firstOverall = attempt.getBandOverall() == null;
    attempt.setBandWriting(band);
    attempt.setBandOverall(overall(attempt, speakingState(attempt, test).pending()));
    if (firstWritingBand) {
      BandSource source = test.getKind() == TestKind.PLACEMENT ? BandSource.PLACEMENT : BandSource.MOCK;
      bands.record(attempt.getUserId(), Skill.WRITING, band, source, attempt.getId());
    }
    // Writing lỗi (AI chưa bật) vẫn chốt band tổng từ các kỹ năng còn lại, để placement có kết quả.
    if (firstOverall && attempt.getBandOverall() != null) afterResults(attempt.getUserId(), test, attempt);
  }

  /** Bài nói trong bài thi chấm xong: chốt band Speaking, rồi band tổng nếu Writing cũng đã xong. */
  @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT, fallbackExecution = true)
  @Transactional(propagation = Propagation.REQUIRES_NEW)
  public void onSpeakingFinished(AttemptSpeakingFinished event) {
    TestAttempt attempt = attempts.lockById(event.attemptId()).orElse(null);
    // Chấm xong trước khi nộp bài thì để lúc nộp tính.
    if (attempt == null || attempt.getStatus() != AttemptStatus.SUBMITTED || attempt.getBandOverall() != null) return;
    IeltsTest test = requireTest(attempt.getTestId());
    SpeakingState spoken = speakingState(attempt, test);
    if (spoken.pending()) return;
    settleSpeaking(attempt, test, spoken);
    boolean writingPending =
        writingSubmissions.findByAttemptId(attempt.getId()).stream().anyMatch(s -> s.getStatus() == SubmissionStatus.PENDING);
    attempt.setBandOverall(overall(attempt, writingPending));
    if (attempt.getBandOverall() != null) afterResults(attempt.getUserId(), test, attempt);
  }

  /** pending: còn bài nói đang chấm. band: trung bình các phần đã chấm, null nếu không có phần nào chấm được. */
  record SpeakingState(boolean hasSection, boolean pending, Double band) {}

  /** Mỗi câu hỏi lấy lần ghi âm cuối cùng: người học được nói lại trong lúc thi. */
  private SpeakingState speakingState(TestAttempt attempt, IeltsTest test) {
    boolean hasSection = test.getSections().stream().anyMatch(sec -> sec.getRefType() == SectionRef.SPEAKING_PROMPT);
    if (!hasSection) return new SpeakingState(false, false, null);
    Map<Long, SpeakingSubmission> latest = new LinkedHashMap<>();
    for (SpeakingSubmission s : speakingSubmissions.findByAttemptIdOrderByCreatedAtAsc(attempt.getId())) latest.put(s.getPromptId(), s);
    boolean pending = latest.values().stream().anyMatch(s -> s.getStatus() == SubmissionStatus.PENDING);
    List<Double> graded =
        latest.values().stream().filter(s -> s.getStatus() == SubmissionStatus.GRADED && s.getBand() != null).map(SpeakingSubmission::getBand).toList();
    return new SpeakingState(true, pending, BandScale.overall(graded));
  }

  /**
   * Đề có phần Speaking và chấm được: band từ chính bài thi, ghi vào lịch sử band. Không có (đề cũ, bỏ qua phần nói,
   * AI chưa bật): lấy band Speaking hiện tại để band tổng vẫn đủ 4 kỹ năng.
   */
  private void settleSpeaking(TestAttempt attempt, IeltsTest test, SpeakingState spoken) {
    if (spoken.band() != null) {
      attempt.setBandSpeaking(spoken.band());
      BandSource source = test.getKind() == TestKind.PLACEMENT ? BandSource.PLACEMENT : BandSource.MOCK;
      bands.record(attempt.getUserId(), Skill.SPEAKING, spoken.band(), source, attempt.getId());
    } else {
      attempt.setBandSpeaking(bands.currentSkillBands(attempt.getUserId()).get(Skill.SPEAKING));
    }
  }

  @Transactional(readOnly = true)
  public AttemptResult result(Long userId, Long attemptId) {
    TestAttempt attempt = requireOwned(userId, attemptId);
    IeltsTest test = requireTest(attempt.getTestId());
    List<SectionResult> sections = new ArrayList<>();
    if (attempt.getStatus() == AttemptStatus.SUBMITTED) {
      Map<String, String> given = savedAnswers(attempt.getId());
      for (TestSection section : test.getSections()) {
        OwnerType owner = ownerOf(section.getRefType());
        if (owner == null) continue;
        sections.add(
            new SectionResult(
                section.getSkill().name(), sectionTitle(section), questionBank.grade(owner, section.getRefId(), given).results()));
      }
    }
    Map<Long, WritingPrompt> prompts =
        writingPrompts.findAllById(test.getSections().stream().filter(s -> s.getRefType() == SectionRef.WRITING_PROMPT).map(TestSection::getRefId).toList())
            .stream()
            .collect(Collectors.toMap(WritingPrompt::getId, Function.identity()));
    List<WritingSubmissionView> writingViews =
        writingSubmissions.findByAttemptId(attempt.getId()).stream().map(s -> writing.toView(s, prompts.get(s.getPromptId()))).toList();
    return new AttemptResult(
        attempt.getId(),
        test.getId(),
        test.getTitle(),
        test.getKind().name(),
        attempt.getStatus().name(),
        attempt.getSubmittedAt(),
        attempt.getTotalListening() == null ? null : new SkillScore(attempt.getRawListening(), attempt.getTotalListening(), attempt.getBandListening()),
        attempt.getTotalReading() == null ? null : new SkillScore(attempt.getRawReading(), attempt.getTotalReading(), attempt.getBandReading()),
        attempt.getBandWriting(),
        attempt.getBandSpeaking(),
        attempt.getBandOverall(),
        sections,
        writingViews,
        speaking.forAttempt(attempt.getId()));
  }

  /**
   * Band tổng của bài thi. Writing hoặc Speaking còn đang chấm thì chưa có. Kỹ năng chưa có band thì band tổng tính
   * trên các kỹ năng đã có.
   */
  private static Double overall(TestAttempt a, boolean gradingPending) {
    if (gradingPending) return null;
    return BandScale.overall(Arrays.asList(a.getBandListening(), a.getBandReading(), a.getBandWriting(), a.getBandSpeaking()));
  }

  private static boolean enoughAnswered(int[] acc) {
    return acc[3] > 0 && acc[2] >= acc[3] * MIN_ANSWERED_RATIO;
  }

  private void afterResults(Long userId, IeltsTest test, TestAttempt attempt) {
    if (profiles.findById(userId).isEmpty()) return;
    // Band Speaking chỉ là band cũ mượn vào: bài đầu vào không có kỹ năng nào làm thật thì không đổi band hồ sơ.
    boolean ownResult = attempt.getBandListening() != null || attempt.getBandReading() != null || attempt.getBandWriting() != null;
    if (test.getKind() == TestKind.PLACEMENT && attempt.getBandOverall() != null && ownResult) {
      profileService.applyPlacement(userId, attempt.getBandOverall());
    }
    if (test.getKind() != TestKind.SECTION) roadmap.generate(userId);
  }

  private void store(TestAttempt attempt, AttemptSaveRequest body) {
    if (body == null) return;
    if (body.answers() != null && !body.answers().isEmpty()) {
      Map<Long, AttemptAnswer> existing =
          answers.findByAttemptId(attempt.getId()).stream().collect(Collectors.toMap(AttemptAnswer::getQuestionId, Function.identity()));
      List<AttemptAnswer> changed = new ArrayList<>();
      for (Map.Entry<String, String> entry : body.answers().entrySet()) {
        Long questionId;
        try {
          questionId = Long.valueOf(entry.getKey());
        } catch (NumberFormatException ex) {
          continue;
        }
        AttemptAnswer row = existing.get(questionId);
        if (row == null) {
          row = new AttemptAnswer();
          row.setAttemptId(attempt.getId());
          row.setQuestionId(questionId);
        }
        String value = entry.getValue() == null ? null : entry.getValue().substring(0, Math.min(500, entry.getValue().length()));
        if (Objects.equals(row.getGiven(), value) && row.getId() != null) continue;
        row.setGiven(value);
        changed.add(row);
      }
      answers.saveAll(changed);
    }
    if (body.writingDrafts() != null && !body.writingDrafts().isEmpty()) {
      Map<String, String> drafts = drafts(attempt);
      drafts.putAll(body.writingDrafts());
      try {
        attempt.setWritingDrafts(json.writeValueAsString(drafts));
      } catch (JsonProcessingException ex) {
        throw new IllegalStateException(ex);
      }
    }
  }

  private Map<String, String> savedAnswers(Long attemptId) {
    Map<String, String> result = new HashMap<>();
    for (AttemptAnswer a : answers.findByAttemptId(attemptId)) {
      if (a.getGiven() != null) result.put(String.valueOf(a.getQuestionId()), a.getGiven());
    }
    return result;
  }

  private Map<String, String> drafts(TestAttempt attempt) {
    if (attempt.getWritingDrafts() == null || attempt.getWritingDrafts().isBlank()) return new LinkedHashMap<>();
    try {
      return new LinkedHashMap<>(json.readValue(attempt.getWritingDrafts(), DRAFTS));
    } catch (JsonProcessingException ex) {
      return new LinkedHashMap<>();
    }
  }

  private AttemptView toView(TestAttempt attempt, IeltsTest test) {
    List<SectionView> sections = new ArrayList<>();
    for (TestSection section : test.getSections()) {
      switch (section.getRefType()) {
        case READING_PASSAGE -> {
          ReadingPassage p = passages.findById(section.getRefId()).orElse(null);
          if (p == null) continue;
          sections.add(
              new SectionView(
                  section.getSkill().name(),
                  section.getRefType().name(),
                  p.getId(),
                  p.getTitle(),
                  p.getContent(),
                  null,
                  null,
                  questionBank.views(OwnerType.READING_PASSAGE, p.getId()),
                  null,
                  null));
        }
        case LISTENING_TRACK -> {
          ListeningTrack t = tracks.findById(section.getRefId()).orElse(null);
          if (t == null) continue;
          sections.add(
              new SectionView(
                  section.getSkill().name(),
                  section.getRefType().name(),
                  t.getId(),
                  sectionTitle(section),
                  null,
                  t.getAudioUrl(),
                  t.getAudioUrl() == null ? t.getTranscript() : null,
                  questionBank.views(OwnerType.LISTENING_TRACK, t.getId()),
                  null,
                  null));
        }
        case WRITING_PROMPT ->
            sections.add(
                new SectionView(
                    section.getSkill().name(),
                    section.getRefType().name(),
                    section.getRefId(),
                    sectionTitle(section),
                    null,
                    null,
                    null,
                    List.of(),
                    writing.prompt(section.getRefId(), null),
                    null));
        case SPEAKING_PROMPT ->
            sections.add(
                new SectionView(
                    section.getSkill().name(),
                    section.getRefType().name(),
                    section.getRefId(),
                    sectionTitle(section),
                    null,
                    null,
                    null,
                    List.of(),
                    null,
                    speaking.promptView(section.getRefId())));
      }
    }
    return new AttemptView(
        attempt.getId(),
        test.getId(),
        test.getTitle(),
        test.getKind().name(),
        attempt.getStatus().name(),
        attempt.getStartedAt(),
        deadline(attempt, test),
        test.getDurationMin(),
        sections,
        savedAnswers(attempt.getId()),
        drafts(attempt),
        speakingSubmissions.findByAttemptIdOrderByCreatedAtAsc(attempt.getId()).stream()
            .map(SpeakingSubmission::getPromptId)
            .distinct()
            .toList());
  }

  private String sectionTitle(TestSection section) {
    return switch (section.getRefType()) {
      case READING_PASSAGE -> passages.findById(section.getRefId()).map(ReadingPassage::getTitle).orElse("Reading");
      case LISTENING_TRACK ->
          tracks
              .findById(section.getRefId())
              .map(t -> (t.getIeltsPart() == null ? "" : "Part " + t.getIeltsPart() + ": ") + t.getTitle())
              .orElse("Listening");
      case WRITING_PROMPT ->
          writingPrompts.findById(section.getRefId()).map(p -> (p.getTask() == WritingTask.TASK1 ? "Task 1" : "Task 2")).orElse("Writing");
      case SPEAKING_PROMPT ->
          speakingPrompts.findById(section.getRefId()).map(p -> "Speaking Part " + p.getPart()).orElse("Speaking");
    };
  }

  private static OwnerType ownerOf(SectionRef ref) {
    return switch (ref) {
      case READING_PASSAGE -> OwnerType.READING_PASSAGE;
      case LISTENING_TRACK -> OwnerType.LISTENING_TRACK;
      default -> null;
    };
  }

  private static Instant deadline(TestAttempt attempt, IeltsTest test) {
    return attempt.getStartedAt().plus(Duration.ofMinutes(test.getDurationMin()));
  }

  private static AttemptSummary summary(TestAttempt a) {
    if (a == null) return null;
    return new AttemptSummary(
        a.getId(),
        a.getStatus().name(),
        a.getStartedAt(),
        a.getSubmittedAt(),
        a.getBandListening(),
        a.getBandReading(),
        a.getBandWriting(),
        a.getBandOverall());
  }

  private IeltsTest requireTest(Long id) {
    return tests.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy bài thi"));
  }

  private TestAttempt requireOwned(Long userId, Long attemptId) {
    TestAttempt a =
        attempts.findById(attemptId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy bài làm"));
    if (!a.getUserId().equals(userId)) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy bài làm");
    return a;
  }
}
