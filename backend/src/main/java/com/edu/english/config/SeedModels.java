package com.edu.english.config;

import com.fasterxml.jackson.databind.JsonNode;
import java.util.List;

/** Hình dạng các file JSON trong resources/content. */
public final class SeedModels {
  private SeedModels() {}

  public record VocabFile(List<TopicSeed> topics, List<WordSeed> words) {}

  public record TopicSeed(String name, String icon, int sortOrder) {}

  public record WordSeed(
      String topic,
      String word,
      String phonetic,
      String meaningVi,
      String level,
      String partOfSpeech,
      String exampleEn,
      String exampleVi,
      int sortOrder) {}

  public record GrammarFile(List<GrammarTopicSeed> topics) {}

  public record GrammarTopicSeed(
      String title, String description, String level, int sortOrder, List<LessonSeed> lessons) {}

  public record LessonSeed(
      String title,
      String level,
      int sortOrder,
      String explanation,
      List<ExampleSeed> examples,
      List<ExerciseSeed> exercises) {}

  public record ExampleSeed(String en, int sortOrder) {}

  public record ExerciseSeed(String question, String answer, int sortOrder, List<String> options) {}

  // Câu hỏi dùng chung cho Reading và Listening.

  public record OptionSeed(String key, String text) {}

  public record QuestionSeed(
      int number,
      String prompt,
      List<String> answers,
      String explanation,
      String evidence,
      List<OptionSeed> options) {}

  public record GroupSeed(
      String type,
      String instruction,
      Integer wordLimit,
      String imageUrl,
      List<OptionSeed> options,
      List<QuestionSeed> questions) {}

  public record ReadingFile(List<PassageSeed> passages) {}

  public record PassageSeed(
      String title,
      String level,
      String module,
      String topic,
      Double bandMin,
      Double bandMax,
      int estimatedMin,
      String source,
      String license,
      int sortOrder,
      String content,
      List<GroupSeed> groups) {}

  public record ListeningFile(List<TrackSeed> tracks) {}

  public record TrackSeed(
      String title,
      String level,
      Integer ieltsPart,
      Double bandMin,
      Double bandMax,
      Integer durationSec,
      int sortOrder,
      String source,
      String license,
      String audioUrl,
      String transcript,
      List<GroupSeed> groups) {}

  public record WritingFile(List<WritingSeed> prompts) {}

  public record WritingSeed(
      String module,
      String task,
      String taskKind,
      String title,
      String topic,
      int minWords,
      String prompt,
      JsonNode chartData,
      String sampleAnswer,
      Double sampleBand,
      int sortOrder) {}

  public record SpeakingFile(List<SpeakingSeed> prompts) {}

  public record SpeakingSeed(int part, String topic, String question, List<String> cueCardPoints, int sortOrder) {}

  public record TestFile(List<TestSeed> tests) {}

  public record TestSeed(
      String kind,
      String module,
      String title,
      String description,
      int durationMin,
      int sortOrder,
      List<SectionSeed> sections) {}

  /** Tham chiếu nội dung theo tiêu đề, vì id phụ thuộc thứ tự nạp. */
  public record SectionSeed(String skill, String refType, String title) {}
}
