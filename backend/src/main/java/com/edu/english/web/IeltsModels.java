package com.edu.english.web;

import com.edu.english.web.ApiModels.AnswerResult;
import com.edu.english.web.ApiModels.QuestionGroupView;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

/** Request/response của các API IELTS: hồ sơ, band, lộ trình, bài thi, Writing, Speaking. */
public final class IeltsModels {
  private IeltsModels() {}

  // Hồ sơ và band ----------------------------------------------------------------

  public record ProfileRequest(
      String module,
      Double currentBand,
      Double targetBand,
      LocalDate examDate,
      Integer dailyMinutes,
      Integer studyDaysPerWeek) {}

  public record ProfileView(
      String module,
      Double currentBand,
      double targetBand,
      LocalDate examDate,
      Integer daysToExam,
      int dailyMinutes,
      int studyDaysPerWeek,
      boolean placementDone) {}

  public record BandPoint(String skill, double band, String source, Instant at) {}

  public record BandSummary(
      Double listening,
      Double reading,
      Double writing,
      Double speaking,
      Double overall,
      Double target,
      List<BandPoint> history) {}

  // Lộ trình ---------------------------------------------------------------------

  public record PhaseView(Long id, String kind, LocalDate startDate, LocalDate endDate, String goal) {}

  public record TaskView(
      Long id,
      LocalDate dueDate,
      String type,
      String skill,
      String title,
      int estimatedMin,
      String status,
      String link) {}

  public record RoadmapView(
      Long id,
      int version,
      LocalDate startDate,
      LocalDate endDate,
      LocalDate examDate,
      Double startBand,
      double targetBand,
      String feasibility,
      int tasksDone,
      int tasksTotal,
      List<PhaseView> phases,
      List<TaskView> tasks) {}

  public record TodayView(
      LocalDate date,
      Integer daysToExam,
      String feasibility,
      String phase,
      String phaseGoal,
      int minutesPlanned,
      int minutesDone,
      List<TaskView> tasks,
      List<TaskView> overdue,
      int dueCards,
      int streakDays,
      BandSummary bands) {}

  public record TaskUpdateRequest(String status) {}

  // Bài thi ----------------------------------------------------------------------

  public record AttemptSummary(
      Long id,
      String status,
      Instant startedAt,
      Instant submittedAt,
      Double bandListening,
      Double bandReading,
      Double bandWriting,
      Double bandOverall) {}

  public record TestListItem(
      Long id,
      String kind,
      String module,
      String title,
      String description,
      int durationMin,
      List<String> skills,
      AttemptSummary lastAttempt) {}

  public record SectionView(
      String skill,
      String refType,
      Long refId,
      String title,
      String body,
      String audioUrl,
      /** Lời thoại để trình duyệt đọc bằng giọng máy khi bài nghe chưa có file audio. */
      String ttsScript,
      List<QuestionGroupView> groups,
      WritingPromptView writing) {}

  public record AttemptView(
      Long id,
      Long testId,
      String title,
      String kind,
      String status,
      Instant startedAt,
      Instant deadline,
      int durationMin,
      List<SectionView> sections,
      Map<String, String> answers,
      Map<String, String> writingDrafts) {}

  public record AttemptSaveRequest(Map<String, String> answers, Map<String, String> writingDrafts) {}

  public record SkillScore(Integer raw, Integer total, Double band) {}

  public record SectionResult(String skill, String title, List<AnswerResult> results) {}

  public record AttemptResult(
      Long id,
      Long testId,
      String title,
      String kind,
      String status,
      Instant submittedAt,
      SkillScore listening,
      SkillScore reading,
      Double bandWriting,
      Double bandSpeaking,
      Double bandOverall,
      List<SectionResult> sections,
      List<WritingSubmissionView> writing) {}

  // Writing ----------------------------------------------------------------------

  public record WritingPromptView(
      Long id,
      String module,
      String task,
      String taskKind,
      String title,
      String prompt,
      String chartData,
      String imageUrl,
      int minWords,
      String topic,
      boolean attempted) {}

  public record WritingSubmitRequest(Long promptId, String text, Integer timeSpentSec) {}

  public record Correction(String original, String suggestion, String reason) {}

  public record Feedback(
      String summary, List<String> strengths, List<String> improvements, List<Correction> corrections) {}

  public record CriterionScore(String code, String name, Double score) {}

  public record WritingSubmissionView(
      Long id,
      Long promptId,
      String promptTitle,
      String task,
      String text,
      int wordCount,
      Integer timeSpentSec,
      String status,
      List<CriterionScore> criteria,
      Double band,
      Feedback feedback,
      String error,
      Instant createdAt,
      Instant gradedAt) {}

  // Speaking ---------------------------------------------------------------------

  public record SpeakingPromptView(
      Long id, int part, String topic, String question, List<String> cueCardPoints, boolean attempted) {}

  public record SpeakingSubmissionView(
      Long id,
      Long promptId,
      int part,
      String question,
      String transcript,
      Integer durationSec,
      boolean hasAudio,
      String status,
      List<CriterionScore> criteria,
      Double band,
      Feedback feedback,
      String error,
      Instant createdAt,
      Instant gradedAt) {}

  public record AiStatus(boolean enabled, String model, int dailyLimit, int usedToday) {}
}
