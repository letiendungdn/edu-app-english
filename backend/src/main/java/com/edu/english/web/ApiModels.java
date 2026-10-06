package com.edu.english.web;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public final class ApiModels {
  private ApiModels() {}

  public record UserView(Long id, String email, String name, String role) {}

  public record AuthResponse(UserView user, String token) {}

  public record TopicView(String name, String icon) {}

  public record SrsView(Instant nextReviewAt, int repetitions) {}

  public record VocabView(
      Long id,
      String word,
      String phonetic,
      String meaningVi,
      String meaningEn,
      String level,
      String partOfSpeech,
      String exampleEn,
      String exampleVi,
      String imageUrl,
      TopicView topic,
      SrsView srs) {}

  public record VocabPage(long total, int page, int limit, List<VocabView> words) {}

  public record PictureItem(
      Long id,
      String word,
      String phonetic,
      String meaningVi,
      String level,
      String partOfSpeech,
      String exampleEn,
      TopicView topic,
      String imageUrl) {}

  public record PicturePage(int total, List<PictureItem> items) {}

  public record ReviewCard(Long id, VocabView vocab) {}

  public record ReviewRequest(Long vocabId, int quality) {}

  public record GrammarListItem(
      Long id, String title, String level, String description, int lessonCount) {}

  public record ExerciseView(
      Long id, String question, String answer, String explanation, List<String> options) {}

  public record LessonView(
      Long id, String title, String explanation, List<String> examples, List<ExerciseView> exercises) {}

  public record GrammarDetail(
      Long id, String title, String level, String description, List<LessonView> lessons) {}

  /** Lựa chọn theo chữ cái/số La Mã: A, B, C hoặc i, ii, iii. */
  public record OptionItem(String key, String text) {}

  public record QuestionItem(Long id, int number, String prompt, List<OptionItem> options) {}

  /** Nhóm câu hỏi chung hướng dẫn. Không bao giờ chứa đáp án. */
  public record QuestionGroupView(
      Long id,
      String type,
      String instruction,
      Integer wordLimit,
      String imageUrl,
      List<OptionItem> options,
      List<QuestionItem> questions) {}

  public record PassageListItem(
      Long id,
      String title,
      String level,
      String module,
      String topic,
      Double bandMin,
      Double bandMax,
      Integer estimatedMin,
      String source,
      long questionCount) {}

  public record PassageDetail(
      Long id,
      String title,
      String level,
      Integer estimatedMin,
      String source,
      String content,
      List<QuestionGroupView> groups) {}

  public record TrackListItem(
      Long id,
      String title,
      String level,
      Integer durationSec,
      String youtubeUrl,
      Integer ieltsPart,
      long questionCount) {}

  public record TrackDetail(
      Long id,
      String title,
      String level,
      Integer durationSec,
      String youtubeUrl,
      String audioUrl,
      String transcript,
      Integer ieltsPart,
      List<QuestionGroupView> groups) {}

  public record SubmitRequest(Map<String, String> answers) {}

  public record AnswerResult(
      Long questionId,
      int number,
      int points,
      int maxPoints,
      String given,
      String correctAnswer,
      String explanation,
      String evidence) {}

  /** estimatedBand chỉ có khi bài đủ dài (từ 10 câu) để quy đổi có ý nghĩa. */
  public record SubmitResult(
      int correct, int total, int percent, Double estimatedBand, List<AnswerResult> results) {}

  public record DictationWord(
      Long id, String word, String phonetic, String meaningVi, String exampleEn) {}

  public record DictationRequest(Long vocabId, String userInput, boolean correct) {}

  public record Overview(
      int totalStudySeconds,
      int daysStudied,
      long masteredCards,
      long totalCards,
      long readingAttempts,
      long listeningAttempts,
      long dictationAttempts) {}

  public record StudyPoint(LocalDate date, int seconds) {}

  public record HistoryPoint(Instant date, double percent) {}

  public record AnalyticsView(
      Overview overview,
      List<StudyPoint> studySessions,
      List<HistoryPoint> readingHistory,
      List<HistoryPoint> listeningHistory) {}
}
