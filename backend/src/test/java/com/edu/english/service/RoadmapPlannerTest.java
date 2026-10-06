package com.edu.english.service;

import static org.assertj.core.api.Assertions.assertThat;

import com.edu.english.domain.Enums.Feasibility;
import com.edu.english.domain.Enums.PhaseKind;
import com.edu.english.domain.Enums.Skill;
import com.edu.english.domain.Enums.TaskType;
import com.edu.english.service.RoadmapPlanner.Input;
import com.edu.english.service.RoadmapPlanner.Plan;
import com.edu.english.service.RoadmapPlanner.PhasePlan;
import com.edu.english.service.RoadmapPlanner.Settings;
import com.edu.english.service.RoadmapPlanner.TaskPlan;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import org.junit.jupiter.api.Test;

class RoadmapPlannerTest {
  /** Thứ Hai, để tuần đầu đủ ngày. */
  private static final LocalDate TODAY = LocalDate.of(2026, 10, 5);

  @Test
  void phasesAreContiguousAndCoverUntilTheDayBeforeTheExam() {
    Plan plan = plan(TODAY.plusWeeks(12), 5.5, 6.5, 60, 6);

    assertThat(plan.end()).isEqualTo(TODAY.plusWeeks(12).minusDays(1));
    List<PhasePlan> phases = plan.phases();
    assertThat(phases.get(0).start()).isEqualTo(TODAY);
    assertThat(phases.get(phases.size() - 1).end()).isEqualTo(plan.end());
    for (int i = 1; i < phases.size(); i++) {
      assertThat(phases.get(i).start()).isEqualTo(phases.get(i - 1).end().plusDays(1));
    }
    assertThat(phases).extracting(PhasePlan::kind)
        .containsExactly(PhaseKind.FOUNDATION, PhaseKind.SKILL_BUILDING, PhaseKind.EXAM_PRACTICE, PhaseKind.FINAL_REVIEW);
    assertThat(phases.get(3).start().until(phases.get(3).end()).getDays() + 1).isGreaterThanOrEqualTo(7);
  }

  @Test
  void strongStartSkipsFoundation() {
    Plan plan = plan(TODAY.plusWeeks(10), 6.5, 7.5, 60, 6);
    assertThat(plan.phases()).extracting(PhasePlan::kind).doesNotContain(PhaseKind.FOUNDATION);
  }

  @Test
  void dailyLoadStaysWithinBudgetExceptMockTests() {
    Plan plan = plan(TODAY.plusWeeks(12), 5.0, 6.5, 60, 6);
    Map<LocalDate, Integer> perDay =
        plan.tasks().stream()
            .filter(t -> t.type() != TaskType.MOCK_TEST)
            .collect(Collectors.groupingBy(TaskPlan::date, Collectors.summingInt(TaskPlan::minutes)));
    assertThat(perDay.values()).allSatisfy(minutes -> assertThat(minutes).isBetween(30, 60));
  }

  @Test
  void restDaysHaveNoTasks() {
    Plan plan = plan(TODAY.plusWeeks(8), 5.5, 6.5, 60, 6);
    assertThat(plan.tasks()).noneMatch(t -> t.date().getDayOfWeek() == DayOfWeek.SUNDAY);

    Plan fiveDays = plan(TODAY.plusWeeks(8), 5.5, 6.5, 60, 5);
    assertThat(fiveDays.tasks())
        .noneMatch(t -> t.date().getDayOfWeek() == DayOfWeek.SATURDAY || t.date().getDayOfWeek() == DayOfWeek.SUNDAY);
  }

  @Test
  void everyFullSkillBuildingWeekHasWritingAndSpeaking() {
    Plan plan = plan(TODAY.plusWeeks(16), 5.5, 6.5, 60, 6);
    PhasePlan skill =
        plan.phases().stream().filter(p -> p.kind() == PhaseKind.SKILL_BUILDING).findFirst().orElseThrow();
    LocalDate monday = skill.start().with(TemporalAdjusters.nextOrSame(DayOfWeek.MONDAY));
    for (; !monday.plusDays(6).isAfter(skill.end()); monday = monday.plusWeeks(1)) {
      LocalDate from = monday;
      List<TaskPlan> week =
          plan.tasks().stream().filter(t -> !t.date().isBefore(from) && !t.date().isAfter(from.plusDays(6))).toList();
      assertThat(week).anyMatch(t -> t.skill() == Skill.WRITING);
      assertThat(week).anyMatch(t -> t.type() == TaskType.SPEAKING);
      assertThat(week.get(0).type()).isEqualTo(TaskType.VOCAB_REVIEW);
    }
  }

  @Test
  void examPracticeHasWeeklyMockTests() {
    Plan plan = plan(TODAY.plusWeeks(16), 5.5, 6.5, 60, 6);
    PhasePlan exam =
        plan.phases().stream().filter(p -> p.kind() == PhaseKind.EXAM_PRACTICE).findFirst().orElseThrow();
    long weeks = (exam.start().until(exam.end()).getDays() + 1) / 7;
    long mocks = plan.tasks().stream().filter(t -> t.type() == TaskType.MOCK_TEST).count();
    assertThat(mocks).isGreaterThanOrEqualTo(weeks);
  }

  @Test
  void weakSkillGetsMoreTime() {
    Input input =
        new Input(TODAY, TODAY.plusWeeks(12), 6.0, Map.of(Skill.LISTENING, 7.0, Skill.READING, 7.0, Skill.WRITING, 5.0, Skill.SPEAKING, 6.0), 7.0, 60, 6);
    Plan plan = RoadmapPlanner.plan(input, Settings.defaults());
    Map<Skill, Integer> minutes =
        plan.tasks().stream()
            .filter(t -> t.skill() != null)
            .collect(Collectors.groupingBy(TaskPlan::skill, Collectors.summingInt(TaskPlan::minutes)));
    assertThat(minutes.get(Skill.WRITING)).isGreaterThan(minutes.get(Skill.READING));
  }

  @Test
  void feasibilityReflectsGapAndTime() {
    assertThat(plan(TODAY.plusWeeks(20), 6.0, 6.5, 75, 6).feasibility()).isEqualTo(Feasibility.ON_TRACK);
    assertThat(plan(TODAY.plusWeeks(4), 5.0, 7.0, 60, 6).feasibility()).isEqualTo(Feasibility.AT_RISK);
  }

  @Test
  void examTomorrowGivesSingleReviewDay() {
    Plan plan = plan(TODAY.plusDays(1), 6.0, 6.5, 60, 7);
    assertThat(plan.phases()).hasSize(1);
    assertThat(plan.phases().get(0).kind()).isEqualTo(PhaseKind.FINAL_REVIEW);
    assertThat(plan.tasks()).allMatch(t -> t.date().equals(TODAY));
  }

  @Test
  void unknownLevelAndNoExamDateUseDefaults() {
    Input input = new Input(TODAY, null, null, Map.of(), 6.5, 60, 6);
    Plan plan = RoadmapPlanner.plan(input, Settings.defaults());
    assertThat(plan.startBand()).isEqualTo(RoadmapPlanner.UNKNOWN_BAND);
    assertThat(plan.end()).isEqualTo(TODAY.plusWeeks(12).minusDays(1));
  }

  private static Plan plan(LocalDate exam, double current, double target, int minutes, int days) {
    return RoadmapPlanner.plan(new Input(TODAY, exam, current, Map.of(), target, minutes, days), Settings.defaults());
  }
}
