package com.edu.english.config;

import java.util.List;

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

  public record ReadingFile(List<PassageSeed> passages) {}

  public record PassageSeed(
      String title,
      String level,
      int estimatedMin,
      String source,
      int sortOrder,
      String content,
      List<QuestionSeed> questions) {}

  public record QuestionSeed(
      String question, String answer, String explanation, int sortOrder, List<String> options) {}

  public record ListeningFile(List<TrackSeed> tracks) {}

  public record TrackSeed(
      String title,
      String level,
      Integer durationSec,
      int sortOrder,
      String transcript,
      List<ListeningQuestionSeed> questions) {}

  public record ListeningQuestionSeed(
      String question, String answer, int sortOrder, List<String> options) {}
}
