package com.edu.english.service;

import com.edu.english.domain.Enums.Feasibility;
import com.edu.english.domain.Enums.PhaseKind;
import com.edu.english.domain.Enums.Skill;
import com.edu.english.domain.Enums.TaskType;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.EnumMap;
import java.util.EnumSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Sinh lộ trình học: giai đoạn → ngày → nhiệm vụ. Hàm thuần (input → plan), không đọc database, không đọc đồng
 * hồ, để test được với ngày cố định.
 */
public final class RoadmapPlanner {
  /** Band giả định khi người học chưa biết trình độ và chưa làm placement test. */
  static final double UNKNOWN_BAND = 5.0;

  static final int MOCK_TEST_MIN = 150;
  private static final int MIN_FILLER_MIN = 10;

  private RoadmapPlanner() {}

  public record Settings(
      int defaultWeeks,
      int weeksPerHalfBand,
      int baselineDailyMinutes,
      double foundationRatio,
      double skillBuildingRatio,
      double examPracticeRatio,
      double finalReviewRatio) {
    public static Settings defaults() {
      return new Settings(12, 8, 75, 0.25, 0.45, 0.20, 0.10);
    }
  }

  public record Input(
      LocalDate today,
      LocalDate examDate,
      Double currentBand,
      Map<Skill, Double> skillBands,
      double targetBand,
      int dailyMinutes,
      int studyDaysPerWeek) {}

  public record PhasePlan(PhaseKind kind, LocalDate start, LocalDate end, String goal) {}

  public record TaskPlan(LocalDate date, int phaseIndex, TaskType type, Skill skill, String title, int minutes) {}

  public record Plan(
      LocalDate start,
      LocalDate end,
      double startBand,
      double weeksNeeded,
      double weeksAvailable,
      Feasibility feasibility,
      List<PhasePlan> phases,
      List<TaskPlan> tasks) {}

  public static Plan plan(Input in, Settings s) {
    LocalDate start = in.today();
    LocalDate end =
        in.examDate() != null && in.examDate().isAfter(start)
            ? in.examDate().minusDays(1)
            : start.plusWeeks(s.defaultWeeks()).minusDays(1);
    if (end.isBefore(start)) end = start;
    int totalDays = (int) ChronoUnit.DAYS.between(start, end) + 1;

    double startBand = startBand(in);
    double gap = in.targetBand() - startBand;
    double minutesFactor = clamp((double) s.baselineDailyMinutes() / Math.max(15, in.dailyMinutes()), 0.5, 3.0);
    double weeksNeeded = gap <= 0 ? 0 : Math.ceil(gap / 0.5) * s.weeksPerHalfBand() * minutesFactor;
    double weeksAvailable = totalDays / 7.0;
    Feasibility feasibility;
    if (weeksNeeded <= weeksAvailable) feasibility = Feasibility.ON_TRACK;
    else if (weeksNeeded * 0.7 <= weeksAvailable) feasibility = Feasibility.TIGHT;
    else feasibility = Feasibility.AT_RISK;

    List<PhasePlan> phases = phases(start, totalDays, startBand, in.targetBand(), s);
    Set<DayOfWeek> restDays = restDays(in.studyDaysPerWeek());
    Map<Skill, Double> weights = weights(in, startBand);
    Map<Skill, Integer> allocated = new EnumMap<>(Skill.class);
    for (Skill skill : List.of(Skill.LISTENING, Skill.READING, Skill.WRITING, Skill.SPEAKING)) allocated.put(skill, 0);

    List<TaskPlan> tasks = new ArrayList<>();
    for (int p = 0; p < phases.size(); p++) {
      PhasePlan phase = phases.get(p);
      for (LocalDate day = phase.start(); !day.isAfter(phase.end()); day = day.plusDays(1)) {
        if (restDays.contains(day.getDayOfWeek())) continue;
        tasks.addAll(dayTasks(day, p, phase, in, restDays, weights, allocated));
      }
    }
    return new Plan(start, end, startBand, weeksNeeded, weeksAvailable, feasibility, phases, tasks);
  }

  static double startBand(Input in) {
    if (in.currentBand() != null) return in.currentBand();
    Double fromSkills = BandScale.overall(in.skillBands() == null ? List.of() : in.skillBands().values());
    return fromSkills != null ? fromSkills : UNKNOWN_BAND;
  }

  static List<PhasePlan> phases(LocalDate start, int totalDays, double startBand, double target, Settings s) {
    if (totalDays <= 7) {
      return List.of(new PhasePlan(PhaseKind.FINAL_REVIEW, start, start.plusDays(totalDays - 1L), goal(PhaseKind.FINAL_REVIEW, target)));
    }
    int reviewDays = (int) Math.round(totalDays * s.finalReviewRatio());
    reviewDays = Math.max(totalDays >= 28 ? 7 : 3, Math.min(14, reviewDays));
    int remaining = totalDays - reviewDays;

    List<PhaseKind> kinds = new ArrayList<>();
    if (startBand < 6.0) kinds.add(PhaseKind.FOUNDATION);
    kinds.add(PhaseKind.SKILL_BUILDING);
    kinds.add(PhaseKind.EXAM_PRACTICE);
    double ratioSum = kinds.stream().mapToDouble(k -> ratio(k, s)).sum();

    Map<PhaseKind, Integer> days = new EnumMap<>(PhaseKind.class);
    int used = 0;
    for (PhaseKind kind : kinds) {
      int d = (int) Math.floor(remaining * ratio(kind, s) / ratioSum);
      days.put(kind, d);
      used += d;
    }
    days.merge(PhaseKind.SKILL_BUILDING, remaining - used, Integer::sum);
    days.put(PhaseKind.FINAL_REVIEW, reviewDays);

    List<PhasePlan> result = new ArrayList<>();
    LocalDate cursor = start;
    for (PhaseKind kind : List.of(PhaseKind.FOUNDATION, PhaseKind.SKILL_BUILDING, PhaseKind.EXAM_PRACTICE, PhaseKind.FINAL_REVIEW)) {
      int d = days.getOrDefault(kind, 0);
      if (d <= 0) continue;
      LocalDate last = cursor.plusDays(d - 1L);
      result.add(new PhasePlan(kind, cursor, last, goal(kind, target)));
      cursor = last.plusDays(1);
    }
    return result;
  }

  static Set<DayOfWeek> restDays(int studyDaysPerWeek) {
    return switch (Math.max(3, Math.min(7, studyDaysPerWeek))) {
      case 7 -> EnumSet.noneOf(DayOfWeek.class);
      case 6 -> EnumSet.of(DayOfWeek.SUNDAY);
      case 5 -> EnumSet.of(DayOfWeek.SATURDAY, DayOfWeek.SUNDAY);
      case 4 -> EnumSet.of(DayOfWeek.TUESDAY, DayOfWeek.THURSDAY, DayOfWeek.SUNDAY);
      default -> EnumSet.of(DayOfWeek.TUESDAY, DayOfWeek.THURSDAY, DayOfWeek.SATURDAY, DayOfWeek.SUNDAY);
    };
  }

  /** Kỹ năng càng xa mục tiêu càng được nhiều thời gian; tối thiểu 0.25 để không bỏ hẳn kỹ năng nào. */
  static Map<Skill, Double> weights(Input in, double startBand) {
    Map<Skill, Double> weights = new EnumMap<>(Skill.class);
    for (Skill skill : List.of(Skill.LISTENING, Skill.READING, Skill.WRITING, Skill.SPEAKING)) {
      Double band = in.skillBands() == null ? null : in.skillBands().get(skill);
      double gap = in.targetBand() - (band != null ? band : startBand);
      weights.put(skill, Math.max(0.25, gap));
    }
    return weights;
  }

  private static List<TaskPlan> dayTasks(
      LocalDate day,
      int phaseIndex,
      PhasePlan phase,
      Input in,
      Set<DayOfWeek> restDays,
      Map<Skill, Double> weights,
      Map<Skill, Integer> allocated) {
    List<TaskPlan> tasks = new ArrayList<>();
    int budget = in.dailyMinutes();
    List<LocalDate> weekDays = studyDaysOfWeek(day, phase, restDays);
    int position = weekDays.indexOf(day);
    boolean lastOfWeek = position == weekDays.size() - 1;
    long weekNo = ChronoUnit.WEEKS.between(phase.start().with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY)), day);

    if (phase.kind() == PhaseKind.EXAM_PRACTICE && lastOfWeek && weekDays.size() >= 2) {
      tasks.add(task(day, phaseIndex, TaskType.MOCK_TEST, null, MOCK_TEST_MIN));
      return tasks;
    }

    int vocab = budget >= 45 ? 15 : 10;
    tasks.add(task(day, phaseIndex, TaskType.VOCAB_REVIEW, null, vocab));
    budget -= vocab;

    // Mỗi tuần ít nhất một bài Writing và một bài Speaking.
    int writingSlot = Math.min(1, weekDays.size() - 1);
    int speakingSlot = Math.min(2, weekDays.size() - 1);
    if (position == writingSlot) {
      TaskType writing = writingType(phase.kind(), weekNo);
      tasks.add(task(day, phaseIndex, writing, Skill.WRITING, minutes(writing)));
      budget -= minutes(writing);
      allocated.merge(Skill.WRITING, minutes(writing), Integer::sum);
    } else if (position == speakingSlot || (weekDays.size() == 1)) {
      tasks.add(task(day, phaseIndex, TaskType.SPEAKING, Skill.SPEAKING, minutes(TaskType.SPEAKING)));
      budget -= minutes(TaskType.SPEAKING);
      allocated.merge(Skill.SPEAKING, minutes(TaskType.SPEAKING), Integer::sum);
    }
    // Học nhiều (≥ 90 phút) thì thêm bài Writing thứ hai trong tuần.
    if (in.dailyMinutes() >= 90 && position == Math.min(3, weekDays.size() - 1) && position != writingSlot
        && phase.kind() != PhaseKind.FOUNDATION) {
      TaskType second = writingType(phase.kind(), weekNo + 1);
      if (minutes(second) <= budget) {
        tasks.add(task(day, phaseIndex, second, Skill.WRITING, minutes(second)));
        budget -= minutes(second);
        allocated.merge(Skill.WRITING, minutes(second), Integer::sum);
      }
    }

    Set<TaskType> usedToday = EnumSet.noneOf(TaskType.class);
    for (TaskPlan t : tasks) usedToday.add(t.type());
    while (budget >= MIN_FILLER_MIN) {
      TaskType next = pickFiller(phase.kind(), budget, usedToday, weights, allocated);
      if (next == null) break;
      Skill skill = skillOf(next);
      tasks.add(task(day, phaseIndex, next, skill, minutes(next)));
      budget -= minutes(next);
      usedToday.add(next);
      if (skill != null) allocated.merge(skill, minutes(next), Integer::sum);
    }
    return tasks;
  }

  private static TaskType pickFiller(
      PhaseKind phase,
      int budget,
      Set<TaskType> usedToday,
      Map<Skill, Double> weights,
      Map<Skill, Integer> allocated) {
    List<TaskType> candidates =
        switch (phase) {
          case FOUNDATION -> List.of(TaskType.GRAMMAR, TaskType.READING, TaskType.LISTENING, TaskType.VOCAB_NEW, TaskType.DICTATION);
          case SKILL_BUILDING -> List.of(TaskType.READING, TaskType.LISTENING, TaskType.SPEAKING, TaskType.VOCAB_NEW);
          case EXAM_PRACTICE -> List.of(TaskType.REVIEW_MISTAKES, TaskType.READING, TaskType.LISTENING, TaskType.SPEAKING);
          case FINAL_REVIEW -> List.of(TaskType.REVIEW_MISTAKES, TaskType.READING, TaskType.LISTENING, TaskType.SPEAKING);
        };
    // Việc không gắn kỹ năng (ngữ pháp, chữa lỗi, từ mới) làm trước, mỗi ngày một lần.
    for (TaskType type : candidates) {
      if (skillOf(type) == null && !usedToday.contains(type) && minutes(type) <= budget) return type;
    }
    TaskType best = null;
    double bestRatio = Double.MAX_VALUE;
    for (TaskType type : candidates) {
      Skill skill = skillOf(type);
      if (skill == null || minutes(type) > budget) continue;
      // Cùng loại lặp lại trong ngày bị xếp sau, chỉ dùng khi hết lựa chọn khác.
      double ratio = allocated.get(skill) / weights.get(skill) + (usedToday.contains(type) ? 1_000_000 : 0);
      if (ratio < bestRatio) {
        bestRatio = ratio;
        best = type;
      }
    }
    return best;
  }

  private static List<LocalDate> studyDaysOfWeek(LocalDate day, PhasePlan phase, Set<DayOfWeek> restDays) {
    LocalDate monday = day.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
    List<LocalDate> days = new ArrayList<>();
    for (int i = 0; i < 7; i++) {
      LocalDate d = monday.plusDays(i);
      if (d.isBefore(phase.start()) || d.isAfter(phase.end()) || restDays.contains(d.getDayOfWeek())) continue;
      days.add(d);
    }
    return days;
  }

  private static TaskType writingType(PhaseKind phase, long weekNo) {
    if (phase == PhaseKind.FOUNDATION) return TaskType.WRITING_T1;
    return weekNo % 3 == 0 ? TaskType.WRITING_T1 : TaskType.WRITING_T2;
  }

  static Skill skillOf(TaskType type) {
    return switch (type) {
      case READING -> Skill.READING;
      case LISTENING, DICTATION -> Skill.LISTENING;
      case WRITING_T1, WRITING_T2 -> Skill.WRITING;
      case SPEAKING -> Skill.SPEAKING;
      default -> null;
    };
  }

  static int minutes(TaskType type) {
    return switch (type) {
      case VOCAB_REVIEW, VOCAB_NEW, DICTATION -> 10;
      case GRAMMAR, LISTENING, SPEAKING, REVIEW_MISTAKES -> 15;
      case READING -> 20;
      case WRITING_T1 -> 25;
      case WRITING_T2 -> 45;
      case MOCK_TEST -> MOCK_TEST_MIN;
    };
  }

  static String title(TaskType type) {
    return switch (type) {
      case VOCAB_REVIEW -> "Ôn thẻ từ vựng đến hạn";
      case VOCAB_NEW -> "Học từ vựng học thuật mới";
      case GRAMMAR -> "Ngữ pháp nền tảng";
      case READING -> "Luyện một bài Reading";
      case LISTENING -> "Luyện một phần Listening";
      case DICTATION -> "Nghe chép chính tả";
      case WRITING_T1 -> "Viết Task 1";
      case WRITING_T2 -> "Viết Task 2";
      case SPEAKING -> "Luyện nói một câu Speaking";
      case MOCK_TEST -> "Thi thử đầy đủ Listening, Reading, Writing";
      case REVIEW_MISTAKES -> "Xem lại lỗi sai gần đây";
    };
  }

  private static String goal(PhaseKind kind, double target) {
    return switch (kind) {
      case FOUNDATION -> "Củng cố ngữ pháp, từ vựng nền và làm quen các dạng câu hỏi IELTS.";
      case SKILL_BUILDING -> "Luyện từng dạng câu hỏi và từng dạng đề Writing, hướng tới band " + target + ".";
      case EXAM_PRACTICE -> "Mỗi tuần một bài thi thử có giờ, sau đó chữa lỗi.";
      case FINAL_REVIEW -> "Ôn lỗi sai, làm đề ngắn, không học nội dung mới.";
    };
  }

  private static double ratio(PhaseKind kind, Settings s) {
    return switch (kind) {
      case FOUNDATION -> s.foundationRatio();
      case SKILL_BUILDING -> s.skillBuildingRatio();
      case EXAM_PRACTICE -> s.examPracticeRatio();
      case FINAL_REVIEW -> s.finalReviewRatio();
    };
  }

  private static TaskPlan task(LocalDate day, int phaseIndex, TaskType type, Skill skill, int minutes) {
    return new TaskPlan(day, phaseIndex, type, skill != null ? skill : skillOf(type), title(type), minutes);
  }

  private static double clamp(double value, double min, double max) {
    return Math.max(min, Math.min(max, value));
  }
}
