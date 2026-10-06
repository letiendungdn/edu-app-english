package com.edu.english.service;

import com.edu.english.domain.Enums.ContentType;
import com.edu.english.domain.Enums.IeltsModule;
import com.edu.english.domain.Enums.OwnerType;
import com.edu.english.domain.Enums.RoadmapStatus;
import com.edu.english.domain.Enums.SectionRef;
import com.edu.english.domain.Enums.Skill;
import com.edu.english.domain.Enums.TaskStatus;
import com.edu.english.domain.Enums.TaskType;
import com.edu.english.domain.Enums.TestKind;
import com.edu.english.domain.Enums.WritingTask;
import com.edu.english.domain.IeltsProfile;
import com.edu.english.domain.ListeningTrack;
import com.edu.english.domain.ReadingPassage;
import com.edu.english.domain.Roadmap;
import com.edu.english.domain.RoadmapPhase;
import com.edu.english.domain.RoadmapTask;
import com.edu.english.domain.SpeakingPrompt;
import com.edu.english.domain.StudySession;
import com.edu.english.domain.WritingPrompt;
import com.edu.english.repo.IeltsProfileRepository;
import com.edu.english.repo.IeltsTestRepository;
import com.edu.english.repo.ListeningAttemptRepository;
import com.edu.english.repo.ListeningTrackRepository;
import com.edu.english.repo.ReadingAttemptRepository;
import com.edu.english.repo.ReadingPassageRepository;
import com.edu.english.repo.RoadmapPhaseRepository;
import com.edu.english.repo.RoadmapRepository;
import com.edu.english.repo.RoadmapTaskRepository;
import com.edu.english.repo.SpeakingPromptRepository;
import com.edu.english.repo.SpeakingSubmissionRepository;
import com.edu.english.repo.SrsCardRepository;
import com.edu.english.repo.StudySessionRepository;
import com.edu.english.repo.WritingPromptRepository;
import com.edu.english.repo.WritingSubmissionRepository;
import com.edu.english.web.IeltsModels.PhaseView;
import com.edu.english.web.IeltsModels.RoadmapView;
import com.edu.english.web.IeltsModels.TaskView;
import com.edu.english.web.IeltsModels.TodayView;
import java.time.Clock;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.EnumMap;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class RoadmapService {
  /** Quá số task bị bỏ lỡ này thì lộ trình được sinh lại từ hôm nay. */
  static final int MISSED_TASKS_BEFORE_REPLAN = 3;

  private final IeltsProfileRepository profiles;
  private final RoadmapRepository roadmaps;
  private final RoadmapPhaseRepository phases;
  private final RoadmapTaskRepository tasks;
  private final BandService bands;
  private final QuestionBank questionBank;
  private final ReadingPassageRepository passages;
  private final ReadingAttemptRepository readingAttempts;
  private final ListeningTrackRepository tracks;
  private final ListeningAttemptRepository listeningAttempts;
  private final WritingPromptRepository writingPrompts;
  private final WritingSubmissionRepository writingSubmissions;
  private final SpeakingPromptRepository speakingPrompts;
  private final SpeakingSubmissionRepository speakingSubmissions;
  private final IeltsTestRepository tests;
  private final SrsCardRepository cards;
  private final StudySessionRepository sessions;
  private final RoadmapPlanner.Settings settings;
  private final Clock clock;

  public RoadmapService(
      IeltsProfileRepository profiles,
      RoadmapRepository roadmaps,
      RoadmapPhaseRepository phases,
      RoadmapTaskRepository tasks,
      BandService bands,
      QuestionBank questionBank,
      ReadingPassageRepository passages,
      ReadingAttemptRepository readingAttempts,
      ListeningTrackRepository tracks,
      ListeningAttemptRepository listeningAttempts,
      WritingPromptRepository writingPrompts,
      WritingSubmissionRepository writingSubmissions,
      SpeakingPromptRepository speakingPrompts,
      SpeakingSubmissionRepository speakingSubmissions,
      IeltsTestRepository tests,
      SrsCardRepository cards,
      StudySessionRepository sessions,
      RoadmapPlanner.Settings settings,
      Clock clock) {
    this.profiles = profiles;
    this.roadmaps = roadmaps;
    this.phases = phases;
    this.tasks = tasks;
    this.bands = bands;
    this.questionBank = questionBank;
    this.passages = passages;
    this.readingAttempts = readingAttempts;
    this.tracks = tracks;
    this.listeningAttempts = listeningAttempts;
    this.writingPrompts = writingPrompts;
    this.writingSubmissions = writingSubmissions;
    this.speakingPrompts = speakingPrompts;
    this.speakingSubmissions = speakingSubmissions;
    this.tests = tests;
    this.cards = cards;
    this.sessions = sessions;
    this.settings = settings;
    this.clock = clock;
  }

  /**
   * Sinh lộ trình mới từ hôm nay. Bản cũ chuyển ARCHIVED, task đã làm của bản cũ giữ nguyên làm lịch sử. Việc đã
   * làm hôm nay được đánh dấu xong luôn ở bản mới để người học không phải làm lại.
   */
  @Transactional
  public RoadmapView generate(Long userId) {
    IeltsProfile profile = requireProfile(userId);
    LocalDate today = LocalDate.now(clock);
    RoadmapPlanner.Plan plan =
        RoadmapPlanner.plan(
            new RoadmapPlanner.Input(
                today,
                profile.getExamDate(),
                profile.getCurrentBand(),
                bands.currentSkillBands(userId),
                profile.getTargetBand(),
                profile.getDailyMinutes(),
                profile.getStudyDaysPerWeek()),
            settings);

    Map<TaskType, Integer> doneToday = new EnumMap<>(TaskType.class);
    int version = 1;
    Optional<Roadmap> previous = roadmaps.findFirstByUserIdAndStatusOrderByIdDesc(userId, RoadmapStatus.ACTIVE);
    if (previous.isPresent()) {
      Roadmap old = previous.get();
      version = old.getVersion() + 1;
      old.setStatus(RoadmapStatus.ARCHIVED);
      for (RoadmapTask t : tasks.findByRoadmapIdAndDueDateOrderByIdAsc(old.getId(), today)) {
        if (t.getStatus() == TaskStatus.DONE) doneToday.merge(t.getType(), 1, Integer::sum);
      }
    }

    Roadmap roadmap = new Roadmap();
    roadmap.setUserId(userId);
    roadmap.setStatus(RoadmapStatus.ACTIVE);
    roadmap.setStartDate(plan.start());
    roadmap.setEndDate(plan.end());
    roadmap.setExamDate(profile.getExamDate());
    roadmap.setStartBand(plan.startBand());
    roadmap.setTargetBand(profile.getTargetBand());
    roadmap.setFeasibility(plan.feasibility());
    roadmap.setVersion(version);
    roadmap.setGeneratedAt(clock.instant());
    roadmaps.save(roadmap);

    List<Long> phaseIds = new ArrayList<>();
    for (int i = 0; i < plan.phases().size(); i++) {
      RoadmapPlanner.PhasePlan p = plan.phases().get(i);
      RoadmapPhase phase = new RoadmapPhase();
      phase.setRoadmapId(roadmap.getId());
      phase.setKind(p.kind());
      phase.setStartDate(p.start());
      phase.setEndDate(p.end());
      phase.setGoal(p.goal());
      phase.setSortOrder(i);
      phaseIds.add(phases.save(phase).getId());
    }

    List<RoadmapTask> created = new ArrayList<>();
    for (RoadmapPlanner.TaskPlan t : plan.tasks()) {
      RoadmapTask task = new RoadmapTask();
      task.setRoadmapId(roadmap.getId());
      task.setPhaseId(phaseIds.get(t.phaseIndex()));
      task.setDueDate(t.date());
      task.setType(t.type());
      task.setSkill(t.skill());
      task.setTitle(t.title());
      task.setEstimatedMin(t.minutes());
      if (t.date().equals(today) && doneToday.getOrDefault(t.type(), 0) > 0) {
        doneToday.merge(t.type(), -1, Integer::sum);
        task.setStatus(TaskStatus.DONE);
        task.setCompletedAt(clock.instant());
      }
      created.add(task);
    }
    tasks.saveAll(created);
    return toView(roadmap, userId);
  }

  @Transactional
  public RoadmapView view(Long userId) {
    Roadmap roadmap = activeOrGenerate(userId);
    return toView(roadmap, userId);
  }

  @Transactional
  public TodayView today(Long userId) {
    IeltsProfile profile = requireProfile(userId);
    LocalDate today = LocalDate.now(clock);
    Roadmap roadmap = activeOrGenerate(userId);
    long missed = tasks.countByRoadmapIdAndStatusAndDueDateBefore(roadmap.getId(), TaskStatus.TODO, today);
    if (missed > MISSED_TASKS_BEFORE_REPLAN || roadmap.getEndDate().isBefore(today)) {
      generate(userId);
      roadmap = roadmaps.findFirstByUserIdAndStatusOrderByIdDesc(userId, RoadmapStatus.ACTIVE).orElseThrow();
    }

    List<RoadmapTask> todays = tasks.findByRoadmapIdAndDueDateOrderByIdAsc(roadmap.getId(), today);
    List<RoadmapTask> overdue =
        tasks.findByRoadmapIdAndStatusAndDueDateBetweenOrderByDueDateAscIdAsc(
            roadmap.getId(), TaskStatus.TODO, today.minusDays(3), today.minusDays(1));
    Context ctx = new Context(userId, profile);
    for (RoadmapTask t : todays) resolveContent(t, ctx);
    for (RoadmapTask t : overdue) resolveContent(t, ctx);

    RoadmapPhase phase =
        phases.findByRoadmapIdOrderBySortOrderAsc(roadmap.getId()).stream()
            .filter(p -> !today.isBefore(p.getStartDate()) && !today.isAfter(p.getEndDate()))
            .findFirst()
            .orElse(null);
    int planned = todays.stream().mapToInt(RoadmapTask::getEstimatedMin).sum();
    int done = todays.stream().filter(t -> t.getStatus() == TaskStatus.DONE).mapToInt(RoadmapTask::getEstimatedMin).sum();
    return new TodayView(
        today,
        daysToExam(profile, today),
        roadmap.getFeasibility().name(),
        phase == null ? null : phase.getKind().name(),
        phase == null ? null : phase.getGoal(),
        planned,
        done,
        todays.stream().map(this::toTask).toList(),
        overdue.stream().map(this::toTask).toList(),
        (int) cards.countByUserIdAndContentTypeAndNextReviewAtLessThanEqual(userId, ContentType.VOCABULARY, clock.instant()),
        streak(userId, today),
        bands.summary(userId));
  }

  @Transactional
  public TaskView updateTask(Long userId, Long taskId, String statusValue) {
    RoadmapTask task =
        tasks.findById(taskId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy nhiệm vụ"));
    Roadmap roadmap = roadmaps.findById(task.getRoadmapId()).orElseThrow();
    if (!roadmap.getUserId().equals(userId)) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy nhiệm vụ");
    TaskStatus status;
    try {
      status = TaskStatus.valueOf(statusValue);
    } catch (IllegalArgumentException | NullPointerException ex) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Trạng thái phải là TODO, DONE hoặc SKIPPED");
    }
    task.setStatus(status);
    task.setCompletedAt(status == TaskStatus.DONE ? clock.instant() : null);
    return toTask(task);
  }

  /**
   * Gọi sau khi người học làm xong một việc (ôn từ, nộp bài đọc, nộp Writing...). Đánh dấu xong task phù hợp đầu
   * tiên của hôm nay hoặc 3 ngày trước. Không có hồ sơ IELTS hay lộ trình thì bỏ qua.
   */
  @Transactional
  public void recordProgress(Long userId, TaskType type) {
    if (userId == null) return;
    Optional<Roadmap> roadmap = roadmaps.findFirstByUserIdAndStatusOrderByIdDesc(userId, RoadmapStatus.ACTIVE);
    if (roadmap.isEmpty()) return;
    LocalDate today = LocalDate.now(clock);
    List<RoadmapTask> candidates = new ArrayList<>(tasks.findByRoadmapIdAndDueDateOrderByIdAsc(roadmap.get().getId(), today));
    candidates.addAll(
        tasks.findByRoadmapIdAndStatusAndDueDateBetweenOrderByDueDateAscIdAsc(
            roadmap.get().getId(), TaskStatus.TODO, today.minusDays(3), today.minusDays(1)));
    candidates.stream()
        .filter(t -> t.getStatus() == TaskStatus.TODO && matches(t.getType(), type))
        .findFirst()
        .ifPresent(
            t -> {
              t.setStatus(TaskStatus.DONE);
              t.setCompletedAt(clock.instant());
            });
  }

  /** Nghe chép tính cho task Listening, ôn từ mới tính cho task học từ mới... */
  private static boolean matches(TaskType taskType, TaskType done) {
    if (taskType == done) return true;
    return switch (done) {
      case DICTATION -> taskType == TaskType.LISTENING;
      case READING, LISTENING, WRITING_T1, WRITING_T2, SPEAKING -> taskType == TaskType.REVIEW_MISTAKES;
      case VOCAB_REVIEW -> taskType == TaskType.VOCAB_NEW;
      default -> false;
    };
  }

  private Roadmap activeOrGenerate(Long userId) {
    Optional<Roadmap> active = roadmaps.findFirstByUserIdAndStatusOrderByIdDesc(userId, RoadmapStatus.ACTIVE);
    if (active.isPresent()) return active.get();
    generate(userId);
    return roadmaps.findFirstByUserIdAndStatusOrderByIdDesc(userId, RoadmapStatus.ACTIVE).orElseThrow();
  }

  private IeltsProfile requireProfile(Long userId) {
    return profiles
        .findById(userId)
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.CONFLICT, "Chưa có hồ sơ IELTS. Hãy hoàn thành bước bắt đầu."));
  }

  private RoadmapView toView(Roadmap roadmap, Long userId) {
    List<RoadmapTask> all = tasks.findByRoadmapIdOrderByDueDateAscIdAsc(roadmap.getId());
    Set<Long> userRoadmaps = roadmaps.findByUserId(userId).stream().map(Roadmap::getId).collect(Collectors.toSet());
    long doneAcrossVersions = tasks.countByRoadmapIdInAndStatus(userRoadmaps, TaskStatus.DONE);
    long doneHere = all.stream().filter(t -> t.getStatus() == TaskStatus.DONE).count();
    return new RoadmapView(
        roadmap.getId(),
        roadmap.getVersion(),
        roadmap.getStartDate(),
        roadmap.getEndDate(),
        roadmap.getExamDate(),
        roadmap.getStartBand(),
        roadmap.getTargetBand(),
        roadmap.getFeasibility().name(),
        (int) Math.max(doneHere, Math.min(doneAcrossVersions, all.size())),
        all.size(),
        phases.findByRoadmapIdOrderBySortOrderAsc(roadmap.getId()).stream()
            .map(p -> new PhaseView(p.getId(), p.getKind().name(), p.getStartDate(), p.getEndDate(), p.getGoal()))
            .toList(),
        all.stream().map(this::toTask).toList());
  }

  private TaskView toTask(RoadmapTask t) {
    return new TaskView(
        t.getId(),
        t.getDueDate(),
        t.getType().name(),
        t.getSkill() == null ? null : t.getSkill().name(),
        t.getTitle(),
        t.getEstimatedMin(),
        t.getStatus().name(),
        link(t));
  }

  static String link(RoadmapTask t) {
    Long ref = t.getRefId();
    return switch (t.getType()) {
      case VOCAB_REVIEW -> "/vocab/review";
      case VOCAB_NEW -> "/vocab/flashcard";
      case GRAMMAR -> "/grammar";
      case DICTATION -> "/dictation";
      case READING -> ref == null ? "/reading" : "/reading/" + ref;
      case LISTENING -> ref == null ? "/listening" : "/listening/" + ref;
      case WRITING_T1, WRITING_T2 -> ref == null ? "/writing" : "/writing/" + ref;
      case SPEAKING -> ref == null ? "/speaking" : "/speaking/" + ref;
      case MOCK_TEST -> "/tests";
      case REVIEW_MISTAKES -> "/history";
    };
  }

  /** Dữ liệu chọn bài, tải một lần cho mỗi request. */
  private final class Context {
    final IeltsProfile profile;
    final double band;
    final Set<Long> readDone;
    final Set<Long> listenDone;
    final Set<Long> writingDone;
    final Set<Long> speakingDone;
    final Set<Long> assignedToday = new HashSet<>();

    Context(Long userId, IeltsProfile profile) {
      this.profile = profile;
      Map<Skill, Double> skillBands = bands.currentSkillBands(userId);
      Double overall = BandScale.overall(skillBands.values());
      this.band = profile.getCurrentBand() != null ? profile.getCurrentBand() : overall != null ? overall : RoadmapPlanner.UNKNOWN_BAND;
      this.readDone = new HashSet<>(readingAttempts.findPassageIdsDoneBy(userId));
      this.listenDone = new HashSet<>(listeningAttempts.findTrackIdsDoneBy(userId));
      this.writingDone = new HashSet<>(writingSubmissions.findPromptIdsAttemptedBy(userId));
      this.speakingDone = new HashSet<>(speakingSubmissions.findPromptIdsAttemptedBy(userId));
    }
  }

  /** Chọn bài cụ thể cho task lần đầu được mở, rồi lưu lại để lần sau vẫn là bài đó. */
  private void resolveContent(RoadmapTask task, Context ctx) {
    if (task.getRefId() != null || task.getStatus() != TaskStatus.TODO) return;
    switch (task.getType()) {
      case READING -> pickPassage(ctx).ifPresent(p -> assign(task, SectionRef.READING_PASSAGE, p.getId(), ctx));
      case LISTENING -> pickTrack(ctx).ifPresent(t -> assign(task, SectionRef.LISTENING_TRACK, t.getId(), ctx));
      case WRITING_T1, WRITING_T2 ->
          pickWriting(ctx, task.getType() == TaskType.WRITING_T1 ? WritingTask.TASK1 : WritingTask.TASK2)
              .ifPresent(w -> assign(task, SectionRef.WRITING_PROMPT, w.getId(), ctx));
      case SPEAKING -> pickSpeaking(ctx).ifPresent(s -> assign(task, SectionRef.SPEAKING_PROMPT, s.getId(), ctx));
      case MOCK_TEST -> tests.findFirstByKindAndPublishedTrueOrderBySortOrderAsc(TestKind.MOCK).ifPresent(t -> task.setRefId(t.getId()));
      default -> {}
    }
  }

  private void assign(RoadmapTask task, SectionRef type, Long id, Context ctx) {
    task.setRefType(type);
    task.setRefId(id);
    ctx.assignedToday.add(id * 10 + type.ordinal());
  }

  private boolean taken(Context ctx, SectionRef type, Long id) {
    return ctx.assignedToday.contains(id * 10 + type.ordinal());
  }

  private Optional<ReadingPassage> pickPassage(Context ctx) {
    Map<Long, Long> counts = questionBank.questionCounts(OwnerType.READING_PASSAGE);
    return best(
        passages.findAll().stream()
            .filter(p -> counts.getOrDefault(p.getId(), 0L) > 0)
            .filter(p -> !taken(ctx, SectionRef.READING_PASSAGE, p.getId()))
            .filter(p -> p.getModule() == IeltsModule.BOTH || p.getModule() == ctx.profile.getModule())
            .toList(),
        p -> ctx.readDone.contains(p.getId()),
        p -> bandDistance(ctx.band, p.getBandMin(), p.getBandMax()));
  }

  private Optional<ListeningTrack> pickTrack(Context ctx) {
    Map<Long, Long> counts = questionBank.questionCounts(OwnerType.LISTENING_TRACK);
    return best(
        tracks.findAll().stream()
            .filter(t -> counts.getOrDefault(t.getId(), 0L) > 0)
            .filter(t -> !taken(ctx, SectionRef.LISTENING_TRACK, t.getId()))
            .toList(),
        t -> ctx.listenDone.contains(t.getId()),
        t -> bandDistance(ctx.band, t.getBandMin(), t.getBandMax()));
  }

  private Optional<WritingPrompt> pickWriting(Context ctx, WritingTask task) {
    return best(
        writingPrompts.findAll().stream()
            .filter(w -> w.getTask() == task)
            .filter(w -> w.getModule() == IeltsModule.BOTH || w.getModule() == ctx.profile.getModule())
            .filter(w -> !taken(ctx, SectionRef.WRITING_PROMPT, w.getId()))
            .toList(),
        w -> ctx.writingDone.contains(w.getId()),
        w -> (double) w.getSortOrder());
  }

  private Optional<SpeakingPrompt> pickSpeaking(Context ctx) {
    return best(
        speakingPrompts.findAll().stream().filter(s -> !taken(ctx, SectionRef.SPEAKING_PROMPT, s.getId())).toList(),
        s -> ctx.speakingDone.contains(s.getId()),
        s -> (double) s.getSortOrder());
  }

  /** Ưu tiên bài chưa làm, sau đó bài gần trình độ nhất. */
  private static <T> Optional<T> best(List<T> items, Function<T, Boolean> done, Function<T, Double> distance) {
    return items.stream()
        .min(Comparator.comparing((T item) -> done.apply(item) ? 1 : 0).thenComparing(distance::apply));
  }

  /** Khoảng cách từ band+0.5 (thử thách vừa sức) đến dải band của bài. Bài không ghi band coi như cách 1.0. */
  static double bandDistance(double band, Double min, Double max) {
    double aim = band + 0.5;
    if (min == null && max == null) return 1.0;
    double lo = min == null ? 0 : min;
    double hi = max == null ? 9 : max;
    if (aim < lo) return lo - aim;
    if (aim > hi) return aim - hi;
    return 0;
  }

  private static Integer daysToExam(IeltsProfile profile, LocalDate today) {
    if (profile.getExamDate() == null) return null;
    return (int) ChronoUnit.DAYS.between(today, profile.getExamDate());
  }

  /** Số ngày học liên tiếp tính đến hôm nay (hoặc hôm qua nếu hôm nay chưa học). */
  int streak(Long userId, LocalDate today) {
    Map<LocalDate, Integer> seconds = new HashMap<>();
    for (StudySession s : sessions.findByUserIdOrderByStudyDateAsc(userId)) seconds.put(s.getStudyDate(), s.getSeconds());
    LocalDate day = seconds.getOrDefault(today, 0) > 0 ? today : today.minusDays(1);
    int count = 0;
    while (seconds.getOrDefault(day, 0) > 0) {
      count++;
      day = day.minusDays(1);
    }
    return count;
  }
}
