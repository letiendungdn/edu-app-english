package com.edu.english.config;

import com.edu.english.config.SeedModels.ExampleSeed;
import com.edu.english.config.SeedModels.ExerciseSeed;
import com.edu.english.config.SeedModels.GrammarFile;
import com.edu.english.config.SeedModels.GrammarTopicSeed;
import com.edu.english.config.SeedModels.GroupSeed;
import com.edu.english.config.SeedModels.LessonSeed;
import com.edu.english.config.SeedModels.ListeningFile;
import com.edu.english.config.SeedModels.OptionSeed;
import com.edu.english.config.SeedModels.PassageSeed;
import com.edu.english.config.SeedModels.QuestionSeed;
import com.edu.english.config.SeedModels.ReadingFile;
import com.edu.english.config.SeedModels.SectionSeed;
import com.edu.english.config.SeedModels.SpeakingFile;
import com.edu.english.config.SeedModels.SpeakingSeed;
import com.edu.english.config.SeedModels.TestFile;
import com.edu.english.config.SeedModels.TestSeed;
import com.edu.english.config.SeedModels.TopicSeed;
import com.edu.english.config.SeedModels.TrackSeed;
import com.edu.english.config.SeedModels.VocabFile;
import com.edu.english.config.SeedModels.WordSeed;
import com.edu.english.config.SeedModels.WritingFile;
import com.edu.english.config.SeedModels.WritingSeed;
import com.edu.english.domain.Enums.EnglishLevel;
import com.edu.english.domain.Enums.IeltsModule;
import com.edu.english.domain.Enums.OwnerType;
import com.edu.english.domain.Enums.PartOfSpeech;
import com.edu.english.domain.Enums.QuestionType;
import com.edu.english.domain.Enums.Role;
import com.edu.english.domain.Enums.SectionRef;
import com.edu.english.domain.Enums.Skill;
import com.edu.english.domain.Enums.TestKind;
import com.edu.english.domain.Enums.WritingTask;
import com.edu.english.domain.GrammarExample;
import com.edu.english.domain.GrammarExercise;
import com.edu.english.domain.GrammarLesson;
import com.edu.english.domain.GrammarOption;
import com.edu.english.domain.GrammarTopic;
import com.edu.english.domain.IeltsProfile;
import com.edu.english.domain.IeltsTest;
import com.edu.english.domain.ListeningTrack;
import com.edu.english.domain.Question;
import com.edu.english.domain.QuestionGroup;
import com.edu.english.domain.QuestionGroupOption;
import com.edu.english.domain.QuestionOption;
import com.edu.english.domain.ReadingPassage;
import com.edu.english.domain.SpeakingPrompt;
import com.edu.english.domain.StudySession;
import com.edu.english.domain.TestSection;
import com.edu.english.domain.UserAccount;
import com.edu.english.domain.VocabTopic;
import com.edu.english.domain.Vocabulary;
import com.edu.english.domain.WritingPrompt;
import com.edu.english.repo.GrammarTopicRepository;
import com.edu.english.repo.IeltsProfileRepository;
import com.edu.english.repo.IeltsTestRepository;
import com.edu.english.repo.ListeningTrackRepository;
import com.edu.english.repo.QuestionGroupRepository;
import com.edu.english.repo.ReadingPassageRepository;
import com.edu.english.repo.SpeakingPromptRepository;
import com.edu.english.repo.StudySessionRepository;
import com.edu.english.repo.UserRepository;
import com.edu.english.repo.VocabTopicRepository;
import com.edu.english.repo.VocabularyRepository;
import com.edu.english.repo.WritingPromptRepository;
import com.edu.english.service.VocabService;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.IOException;
import java.io.InputStream;
import java.time.Clock;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.io.ClassPathResource;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 * Nạp nội dung mẫu từ resources/content. Mỗi phần chỉ nạp khi còn thiếu (theo tiêu đề hoặc bảng rỗng), nên chạy lại
 * trên database cũ sẽ thêm nội dung mới mà không nhân đôi nội dung đã có.
 */
@Component
public class DataSeeder implements CommandLineRunner {
  private static final Logger log = LoggerFactory.getLogger(DataSeeder.class);
  private static final String DEMO_EMAIL = "demo@edu.app";

  private final VocabularyRepository vocabulary;
  private final VocabTopicRepository topics;
  private final GrammarTopicRepository grammar;
  private final ReadingPassageRepository passages;
  private final ListeningTrackRepository tracks;
  private final QuestionGroupRepository groups;
  private final WritingPromptRepository writingPrompts;
  private final SpeakingPromptRepository speakingPrompts;
  private final IeltsTestRepository tests;
  private final UserRepository users;
  private final IeltsProfileRepository profiles;
  private final StudySessionRepository sessions;
  private final PasswordEncoder encoder;
  private final VocabService vocabService;
  private final ObjectMapper json;
  private final Clock clock;

  public DataSeeder(
      VocabularyRepository vocabulary,
      VocabTopicRepository topics,
      GrammarTopicRepository grammar,
      ReadingPassageRepository passages,
      ListeningTrackRepository tracks,
      QuestionGroupRepository groups,
      WritingPromptRepository writingPrompts,
      SpeakingPromptRepository speakingPrompts,
      IeltsTestRepository tests,
      UserRepository users,
      IeltsProfileRepository profiles,
      StudySessionRepository sessions,
      PasswordEncoder encoder,
      VocabService vocabService,
      ObjectMapper json,
      Clock clock) {
    this.vocabulary = vocabulary;
    this.topics = topics;
    this.grammar = grammar;
    this.passages = passages;
    this.tracks = tracks;
    this.groups = groups;
    this.writingPrompts = writingPrompts;
    this.speakingPrompts = speakingPrompts;
    this.tests = tests;
    this.users = users;
    this.profiles = profiles;
    this.sessions = sessions;
    this.encoder = encoder;
    this.vocabService = vocabService;
    this.json = json;
    this.clock = clock;
  }

  @Override
  @Transactional
  public void run(String... args) {
    if (vocabulary.count() == 0) seedVocabulary();
    if (grammar.count() == 0) seedGrammar();
    seedReading();
    seedListening();
    seedWriting();
    if (speakingPrompts.count() == 0) seedSpeaking();
    if (tests.count() == 0) seedTests();
    seedDemoUser();
  }

  private void seedVocabulary() {
    VocabFile file = read("content/vocab.json", VocabFile.class);
    Map<String, VocabTopic> topicByName = new HashMap<>();
    for (TopicSeed seed : file.topics()) {
      VocabTopic topic = new VocabTopic();
      topic.setName(seed.name());
      topic.setIcon(seed.icon());
      topic.setSortOrder(seed.sortOrder());
      topicByName.put(seed.name(), topics.save(topic));
    }
    for (WordSeed seed : file.words()) {
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
  }

  private void seedGrammar() {
    for (GrammarTopicSeed seed : read("content/grammar.json", GrammarFile.class).topics()) grammar.save(toTopic(seed));
  }

  private void seedReading() {
    for (PassageSeed seed : read("content/reading.json", ReadingFile.class).passages()) {
      if (passages.findFirstByTitle(seed.title()).isPresent()) continue;
      ReadingPassage passage = new ReadingPassage();
      passage.setTitle(seed.title());
      passage.setLevel(EnglishLevel.valueOf(seed.level()));
      passage.setModule(seed.module() == null ? IeltsModule.BOTH : IeltsModule.valueOf(seed.module()));
      passage.setTopic(seed.topic());
      passage.setBandMin(seed.bandMin());
      passage.setBandMax(seed.bandMax());
      passage.setEstimatedMin(seed.estimatedMin());
      passage.setSource(seed.source());
      passage.setLicense(seed.license());
      passage.setContent(seed.content());
      passage.setSortOrder(seed.sortOrder());
      passages.save(passage);
      saveGroups(OwnerType.READING_PASSAGE, passage.getId(), seed.groups());
    }
  }

  private void seedListening() {
    for (TrackSeed seed : read("content/listening.json", ListeningFile.class).tracks()) {
      if (tracks.findFirstByTitle(seed.title()).isPresent()) continue;
      ListeningTrack track = new ListeningTrack();
      track.setTitle(seed.title());
      track.setLevel(EnglishLevel.valueOf(seed.level()));
      track.setIeltsPart(seed.ieltsPart());
      track.setBandMin(seed.bandMin());
      track.setBandMax(seed.bandMax());
      track.setDurationSec(seed.durationSec());
      track.setSortOrder(seed.sortOrder());
      track.setSource(seed.source());
      track.setLicense(seed.license());
      track.setAudioUrl(seed.audioUrl());
      track.setTranscript(seed.transcript());
      tracks.save(track);
      saveGroups(OwnerType.LISTENING_TRACK, track.getId(), seed.groups());
    }
  }

  private void saveGroups(OwnerType ownerType, Long ownerId, List<GroupSeed> seeds) {
    if (seeds == null) return;
    int order = 1;
    for (GroupSeed seed : seeds) {
      QuestionGroup group = new QuestionGroup();
      group.setOwnerType(ownerType);
      group.setOwnerId(ownerId);
      group.setQuestionType(QuestionType.valueOf(seed.type()));
      group.setInstruction(seed.instruction());
      group.setWordLimit(seed.wordLimit());
      group.setImageUrl(seed.imageUrl());
      group.setSortOrder(order++);
      int optionOrder = 1;
      if (seed.options() != null) {
        for (OptionSeed o : seed.options()) {
          QuestionGroupOption option = new QuestionGroupOption();
          option.setGroup(group);
          option.setKey(o.key());
          option.setText(o.text());
          option.setSortOrder(optionOrder++);
          group.getOptions().add(option);
        }
      }
      for (QuestionSeed q : seed.questions()) {
        Question question = new Question();
        question.setGroup(group);
        question.setNumber(q.number());
        question.setPrompt(q.prompt());
        question.setAcceptedAnswers(q.answers());
        question.setExplanation(q.explanation());
        question.setEvidence(q.evidence());
        int i = 1;
        if (q.options() != null) {
          for (OptionSeed o : q.options()) {
            QuestionOption option = new QuestionOption();
            option.setQuestion(question);
            option.setKey(o.key());
            option.setText(o.text());
            option.setSortOrder(i++);
            question.getOptions().add(option);
          }
        }
        group.getQuestions().add(question);
      }
      groups.save(group);
    }
  }

  private void seedWriting() {
    for (WritingSeed seed : read("content/writing.json", WritingFile.class).prompts()) {
      if (writingPrompts.findFirstByTitle(seed.title()).isPresent()) continue;
      WritingPrompt prompt = new WritingPrompt();
      prompt.setModule(IeltsModule.valueOf(seed.module()));
      prompt.setTask(WritingTask.valueOf(seed.task()));
      prompt.setTaskKind(seed.taskKind());
      prompt.setTitle(seed.title());
      prompt.setTopic(seed.topic());
      prompt.setMinWords(seed.minWords());
      prompt.setPrompt(seed.prompt());
      prompt.setChartData(seed.chartData() == null || seed.chartData().isNull() ? null : seed.chartData().toString());
      prompt.setSampleAnswer(seed.sampleAnswer());
      prompt.setSampleBand(seed.sampleBand());
      prompt.setSortOrder(seed.sortOrder());
      writingPrompts.save(prompt);
    }
  }

  private void seedSpeaking() {
    for (SpeakingSeed seed : read("content/speaking.json", SpeakingFile.class).prompts()) {
      SpeakingPrompt prompt = new SpeakingPrompt();
      prompt.setPart(seed.part());
      prompt.setTopic(seed.topic());
      prompt.setQuestion(seed.question());
      prompt.setCueCardPoints(seed.cueCardPoints() == null ? List.of() : seed.cueCardPoints());
      prompt.setSortOrder(seed.sortOrder());
      speakingPrompts.save(prompt);
    }
  }

  private void seedTests() {
    for (TestSeed seed : read("content/tests.json", TestFile.class).tests()) {
      IeltsTest test = new IeltsTest();
      test.setKind(TestKind.valueOf(seed.kind()));
      test.setModule(IeltsModule.valueOf(seed.module()));
      test.setTitle(seed.title());
      test.setDescription(seed.description());
      test.setDurationMin(seed.durationMin());
      test.setSortOrder(seed.sortOrder());
      test.setPublished(true);
      int order = 1;
      boolean complete = true;
      for (SectionSeed s : seed.sections()) {
        SectionRef ref = SectionRef.valueOf(s.refType());
        Optional<Long> refId =
            switch (ref) {
              case READING_PASSAGE -> passages.findFirstByTitle(s.title()).map(ReadingPassage::getId);
              case LISTENING_TRACK -> tracks.findFirstByTitle(s.title()).map(ListeningTrack::getId);
              case WRITING_PROMPT -> writingPrompts.findFirstByTitle(s.title()).map(WritingPrompt::getId);
              case SPEAKING_PROMPT -> Optional.empty();
            };
        if (refId.isEmpty()) {
          log.warn("Test '{}' references missing content '{}'", seed.title(), s.title());
          complete = false;
          continue;
        }
        TestSection section = new TestSection();
        section.setTest(test);
        section.setSkill(Skill.valueOf(s.skill()));
        section.setRefType(ref);
        section.setRefId(refId.get());
        section.setSortOrder(order++);
        test.getSections().add(section);
      }
      if (complete) tests.save(test);
    }
  }

  /** Tài khoản demo có sẵn hồ sơ IELTS để mở app là thấy lộ trình. */
  private void seedDemoUser() {
    if (users.findByEmailIgnoreCase(DEMO_EMAIL).isPresent()) return;
    UserAccount demo = new UserAccount();
    demo.setEmail(DEMO_EMAIL);
    demo.setName("Demo");
    demo.setRole(Role.USER);
    demo.setPasswordHash(encoder.encode("demo123"));
    users.save(demo);
    vocabService.enrollStarterCards(demo.getId());
    LocalDate today = LocalDate.now(clock);
    for (int i = 9; i >= 0; i--) {
      StudySession session = new StudySession();
      session.setUserId(demo.getId());
      session.setStudyDate(today.minusDays(i));
      session.setSeconds(300 + (9 - i) * 40);
      session.setCardsStudied(4);
      sessions.save(session);
    }
    IeltsProfile profile = new IeltsProfile();
    profile.setUserId(demo.getId());
    profile.setModule(IeltsModule.ACADEMIC);
    profile.setCurrentBand(5.5);
    profile.setTargetBand(6.5);
    profile.setExamDate(today.plusWeeks(14));
    profile.setDailyMinutes(90);
    profile.setStudyDaysPerWeek(6);
    profiles.save(profile);
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

  private <T> T read(String path, Class<T> type) {
    try (InputStream in = new ClassPathResource(path).getInputStream()) {
      return json.readValue(in, type);
    } catch (IOException ex) {
      throw new IllegalStateException("Không đọc được " + path, ex);
    }
  }
}
