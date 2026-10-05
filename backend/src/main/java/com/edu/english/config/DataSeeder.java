package com.edu.english.config;

import com.edu.english.config.SeedModels.ExampleSeed;
import com.edu.english.config.SeedModels.ExerciseSeed;
import com.edu.english.config.SeedModels.GrammarFile;
import com.edu.english.config.SeedModels.GrammarTopicSeed;
import com.edu.english.config.SeedModels.LessonSeed;
import com.edu.english.config.SeedModels.ListeningFile;
import com.edu.english.config.SeedModels.ListeningQuestionSeed;
import com.edu.english.config.SeedModels.PassageSeed;
import com.edu.english.config.SeedModels.QuestionSeed;
import com.edu.english.config.SeedModels.ReadingFile;
import com.edu.english.config.SeedModels.TopicSeed;
import com.edu.english.config.SeedModels.TrackSeed;
import com.edu.english.config.SeedModels.VocabFile;
import com.edu.english.config.SeedModels.WordSeed;
import com.edu.english.domain.Enums.EnglishLevel;
import com.edu.english.domain.Enums.PartOfSpeech;
import com.edu.english.domain.Enums.Role;
import com.edu.english.domain.GrammarExample;
import com.edu.english.domain.GrammarExercise;
import com.edu.english.domain.GrammarLesson;
import com.edu.english.domain.GrammarOption;
import com.edu.english.domain.GrammarTopic;
import com.edu.english.domain.ListeningOption;
import com.edu.english.domain.ListeningQuestion;
import com.edu.english.domain.ListeningTrack;
import com.edu.english.domain.ReadingOption;
import com.edu.english.domain.ReadingPassage;
import com.edu.english.domain.ReadingQuestion;
import com.edu.english.domain.StudySession;
import com.edu.english.domain.UserAccount;
import com.edu.english.domain.VocabTopic;
import com.edu.english.domain.Vocabulary;
import com.edu.english.repo.GrammarTopicRepository;
import com.edu.english.repo.ListeningTrackRepository;
import com.edu.english.repo.ReadingPassageRepository;
import com.edu.english.repo.StudySessionRepository;
import com.edu.english.repo.UserRepository;
import com.edu.english.repo.VocabTopicRepository;
import com.edu.english.repo.VocabularyRepository;
import com.edu.english.service.VocabService;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.IOException;
import java.io.InputStream;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.io.ClassPathResource;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
public class DataSeeder implements CommandLineRunner {
  private final VocabularyRepository vocabulary;
  private final VocabTopicRepository topics;
  private final GrammarTopicRepository grammar;
  private final ReadingPassageRepository passages;
  private final ListeningTrackRepository tracks;
  private final UserRepository users;
  private final StudySessionRepository sessions;
  private final PasswordEncoder encoder;
  private final VocabService vocabService;
  private final ObjectMapper json;

  public DataSeeder(
      VocabularyRepository vocabulary,
      VocabTopicRepository topics,
      GrammarTopicRepository grammar,
      ReadingPassageRepository passages,
      ListeningTrackRepository tracks,
      UserRepository users,
      StudySessionRepository sessions,
      PasswordEncoder encoder,
      VocabService vocabService,
      ObjectMapper json) {
    this.vocabulary = vocabulary;
    this.topics = topics;
    this.grammar = grammar;
    this.passages = passages;
    this.tracks = tracks;
    this.users = users;
    this.sessions = sessions;
    this.encoder = encoder;
    this.vocabService = vocabService;
    this.json = json;
  }

  @Override
  @Transactional
  public void run(String... args) {
    if (vocabulary.count() > 0) return;

    VocabFile vocabFile = read("content/vocab.json", VocabFile.class);
    Map<String, VocabTopic> topicByName = new HashMap<>();
    for (TopicSeed seed : vocabFile.topics()) {
      VocabTopic topic = new VocabTopic();
      topic.setName(seed.name());
      topic.setIcon(seed.icon());
      topic.setSortOrder(seed.sortOrder());
      topicByName.put(seed.name(), topics.save(topic));
    }
    for (WordSeed seed : vocabFile.words()) {
      Vocabulary word = new Vocabulary();
      word.setTopic(topicByName.get(seed.topic()));
      word.setWord(seed.word());
      word.setPhonetic(seed.phonetic());
      word.setMeaningVi(seed.meaningVi());
      word.setLevel(EnglishLevel.valueOf(seed.level()));
      word.setPartOfSpeech(PartOfSpeech.valueOf(seed.partOfSpeech()));
      word.setExampleEn(seed.exampleEn());
      word.setExampleVi(seed.exampleVi());
      word.setSortOrder(seed.sortOrder());
      word.setImageUrl("https://api.dicebear.com/9.x/shapes/svg?seed=" + seed.word());
      vocabulary.save(word);
    }

    GrammarFile grammarFile = read("content/grammar.json", GrammarFile.class);
    for (GrammarTopicSeed seed : grammarFile.topics()) {
      grammar.save(toTopic(seed));
    }

    ReadingFile readingFile = read("content/reading.json", ReadingFile.class);
    for (PassageSeed seed : readingFile.passages()) {
      passages.save(toPassage(seed));
    }

    ListeningFile listeningFile = read("content/listening.json", ListeningFile.class);
    for (TrackSeed seed : listeningFile.tracks()) {
      tracks.save(toTrack(seed));
    }

    if (users.findByEmailIgnoreCase("demo@edu.app").isEmpty()) {
      UserAccount demo = new UserAccount();
      demo.setEmail("demo@edu.app");
      demo.setName("Demo");
      demo.setRole(Role.USER);
      demo.setPasswordHash(encoder.encode("demo123"));
      users.save(demo);
      vocabService.enrollStarterCards(demo.getId());
      for (int i = 9; i >= 0; i--) {
        StudySession session = new StudySession();
        session.setUserId(demo.getId());
        session.setStudyDate(LocalDate.now().minusDays(i));
        session.setSeconds(300 + (9 - i) * 40);
        session.setCardsStudied(4);
        sessions.save(session);
      }
    }
  }

  private GrammarTopic toTopic(GrammarTopicSeed seed) {
    GrammarTopic topic = new GrammarTopic();
    topic.setTitle(seed.title());
    topic.setDescription(seed.description());
    topic.setLevel(EnglishLevel.valueOf(seed.level()));
    topic.setSortOrder(seed.sortOrder());
    for (LessonSeed lessonSeed : seed.lessons()) {
      GrammarLesson lesson = new GrammarLesson();
      lesson.setTopic(topic);
      lesson.setTitle(lessonSeed.title());
      lesson.setLevel(EnglishLevel.valueOf(lessonSeed.level()));
      lesson.setSortOrder(lessonSeed.sortOrder());
      lesson.setExplanation(lessonSeed.explanation());
      topic.getLessons().add(lesson);
      if (lessonSeed.examples() != null) {
        for (ExampleSeed exampleSeed : lessonSeed.examples()) {
          GrammarExample example = new GrammarExample();
          example.setLesson(lesson);
          example.setEn(exampleSeed.en());
          example.setSortOrder(exampleSeed.sortOrder());
          lesson.getExamples().add(example);
        }
      }
      if (lessonSeed.exercises() != null) {
        for (ExerciseSeed exerciseSeed : lessonSeed.exercises()) {
          GrammarExercise exercise = new GrammarExercise();
          exercise.setLesson(lesson);
          exercise.setQuestion(exerciseSeed.question());
          exercise.setAnswer(exerciseSeed.answer());
          exercise.setSortOrder(exerciseSeed.sortOrder());
          lesson.getExercises().add(exercise);
          int i = 1;
          for (String text : exerciseSeed.options()) {
            GrammarOption option = new GrammarOption();
            option.setExercise(exercise);
            option.setText(text);
            option.setCorrect(text.equals(exerciseSeed.answer()));
            option.setSortOrder(i++);
            exercise.getOptions().add(option);
          }
        }
      }
    }
    return topic;
  }

  private static ReadingPassage toPassage(PassageSeed seed) {
    ReadingPassage passage = new ReadingPassage();
    passage.setTitle(seed.title());
    passage.setLevel(EnglishLevel.valueOf(seed.level()));
    passage.setEstimatedMin(seed.estimatedMin());
    passage.setSource(seed.source());
    passage.setContent(seed.content());
    passage.setSortOrder(seed.sortOrder());
    for (QuestionSeed questionSeed : seed.questions()) {
      ReadingQuestion question = new ReadingQuestion();
      question.setPassage(passage);
      question.setQuestion(questionSeed.question());
      question.setAnswer(questionSeed.answer());
      question.setExplanation(questionSeed.explanation());
      question.setSortOrder(questionSeed.sortOrder());
      passage.getQuestions().add(question);
      int i = 1;
      for (String optionText : questionSeed.options()) {
        ReadingOption option = new ReadingOption();
        option.setQuestion(question);
        option.setText(optionText);
        option.setSortOrder(i++);
        question.getOptions().add(option);
      }
    }
    return passage;
  }

  private static ListeningTrack toTrack(TrackSeed seed) {
    ListeningTrack track = new ListeningTrack();
    track.setTitle(seed.title());
    track.setLevel(EnglishLevel.valueOf(seed.level()));
    track.setDurationSec(seed.durationSec());
    track.setSortOrder(seed.sortOrder());
    track.setTranscript(seed.transcript());
    for (ListeningQuestionSeed questionSeed : seed.questions()) {
      ListeningQuestion question = new ListeningQuestion();
      question.setTrack(track);
      question.setQuestion(questionSeed.question());
      question.setAnswer(questionSeed.answer());
      question.setSortOrder(questionSeed.sortOrder());
      track.getQuestions().add(question);
      int i = 1;
      for (String text : questionSeed.options()) {
        ListeningOption option = new ListeningOption();
        option.setQuestion(question);
        option.setText(text);
        option.setSortOrder(i++);
        question.getOptions().add(option);
      }
    }
    return track;
  }

  private <T> T read(String path, Class<T> type) {
    try (InputStream in = new ClassPathResource(path).getInputStream()) {
      return json.readValue(in, type);
    } catch (IOException ex) {
      throw new IllegalStateException("Không đọc được " + path, ex);
    }
  }
}
