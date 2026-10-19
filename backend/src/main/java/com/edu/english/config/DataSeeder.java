package com.edu.english.config;

import com.fasterxml.jackson.core.type.TypeReference;
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
import com.edu.english.config.SeedModels.PhraseFile;
import com.edu.english.config.SeedModels.PhraseSeed;
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
import com.edu.english.domain.WritingPhrase;
import com.edu.english.domain.UserAccount;
import com.edu.english.domain.VocabTopic;
import com.edu.english.domain.Vocabulary;
import com.edu.english.domain.WritingPrompt;
import com.edu.english.repo.GrammarTopicRepository;
import com.edu.english.repo.IeltsProfileRepository;
import com.edu.english.repo.IeltsTestRepository;
import com.edu.english.repo.WritingPhraseRepository;
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
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
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
  private final WritingPhraseRepository phrases;
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
      WritingPhraseRepository phrases,
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
    this.phrases = phrases;
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
    seedVocabulary();
    seedGrammar();
    seedReading();
    seedListening();
    seedWriting();
    seedSpeaking();
    seedPhrases();
    seedTests();
    seedDemoUser();
  }

  private void seedVocabulary() {
    VocabFile file = read("content/vocab.json", VocabFile.class);
    Map<String, VocabTopic> topicByName = new HashMap<>();
    for (TopicSeed seed : file.topics()) {
      VocabTopic topic =
          topics
              .findByName(seed.name())
              .orElseGet(
                  () -> {
                    VocabTopic created = new VocabTopic();
                    created.setName(seed.name());
                    created.setIcon(seed.icon());
                    created.setSortOrder(seed.sortOrder());
                    return topics.save(created);
                  });
      topicByName.put(seed.name(), topic);
    }
    Map<String, String> pictures = read("content/pictures.json", new TypeReference<Map<String, String>>() {});
    Map<String, Vocabulary> known = new HashMap<>();
    vocabulary.findAll().forEach((row) -> known.put(row.getWord().toLowerCase(), row));
    for (WordSeed seed : file.words()) {
      Vocabulary existing = known.get(seed.word().toLowerCase());
      if (existing != null) {
        boolean changed = false;
        if (seed.phonetic() != null && !seed.phonetic().isBlank() && !seed.phonetic().equals(existing.getPhonetic())) {
          existing.setPhonetic(seed.phonetic());
          changed = true;
        }
        // JSON là nguồn chuẩn cho câu ví dụ và loại từ (đã rà tay trong scripts/vocab-review).
        if (seed.exampleEn() != null && !seed.exampleEn().isBlank()
            && (!seed.exampleEn().equals(existing.getExampleEn())
                || !Objects.equals(seed.exampleVi(), existing.getExampleVi()))) {
          existing.setExampleEn(seed.exampleEn());
          existing.setExampleVi(seed.exampleVi() == null ? "" : seed.exampleVi());
          changed = true;
        }
        PartOfSpeech seedPos = PartOfSpeech.valueOf(seed.partOfSpeech());
        if (seedPos != existing.getPartOfSpeech()) {
          existing.setPartOfSpeech(seedPos);
          changed = true;
        }
        String pictured = pictureUrl(pictures, seed.word());
        if (pictured != null && !pictured.equals(existing.getImageUrl())) {
          existing.setImageUrl(pictured);
          changed = true;
        }
        String nextEn = seed.meaningEn() == null ? "" : seed.meaningEn();
        String currentEn = existing.getMeaningEn() == null ? "" : existing.getMeaningEn();
        if (!nextEn.equals(currentEn)) {
          existing.setMeaningEn(nextEn.isBlank() ? null : nextEn);
          changed = true;
        }
        // JSON là nguồn chuẩn: nghĩa tiếng Việt sửa trong file thì cập nhật vào DB.
        if (seed.meaningVi() != null && !seed.meaningVi().isBlank() && !seed.meaningVi().equals(existing.getMeaningVi())) {
          existing.setMeaningVi(seed.meaningVi());
          changed = true;
        }
        // Từ đang ở nhóm chung (Core, Academic) mà JSON xếp sang chủ đề IELTS thì chuyển theo JSON.
        VocabTopic seedTopic = topicByName.get(seed.topic());
        if (seedTopic != null && existing.getTopic() != null && !seedTopic.getId().equals(existing.getTopic().getId())
            && isGeneralTopic(existing.getTopic().getName())) {
          existing.setTopic(seedTopic);
          changed = true;
        }
        String seedPriority = priorityOf(seed);
        if (!seedPriority.equals(existing.getPriority())) {
          existing.setPriority(seedPriority);
          changed = true;
        }
        if (seed.family() != null && !seed.family().equals(existing.getWordFamily())) {
          existing.setWordFamily(seed.family());
          changed = true;
        }
        if (changed) vocabulary.save(existing);
        continue;
      }
      known.put(seed.word().toLowerCase(), new Vocabulary());
      Vocabulary word = new Vocabulary();
      word.setTopic(topicByName.get(seed.topic()));
      word.setWord(seed.word());
      word.setPhonetic(seed.phonetic());
      word.setMeaningVi(seed.meaningVi());
      word.setMeaningEn(seed.meaningEn());
      word.setLevel(EnglishLevel.valueOf(seed.level()));
      word.setPartOfSpeech(PartOfSpeech.valueOf(seed.partOfSpeech()));
      word.setExampleEn(seed.exampleEn());
      word.setExampleVi(seed.exampleVi());
      word.setSortOrder(seed.sortOrder());
      word.setWordFamily(seed.family());
      word.setPriority(priorityOf(seed));
      String pictured = pictureUrl(pictures, seed.word());
      word.setImageUrl(pictured != null ? pictured : "https://api.dicebear.com/9.x/shapes/svg?seed=" + seed.word());
      vocabulary.save(word);
    }
  }

  /** Nhóm chung theo cấp độ hoặc học thuật: được phép chuyển từ sang chủ đề cụ thể hơn. */
  private static String priorityOf(WordSeed seed) {
    return "EXTRA".equals(seed.priority()) ? "EXTRA" : "CORE";
  }

  private static boolean isGeneralTopic(String name) {
    return name != null && (name.startsWith("Core ") || name.equals("Academic"));
  }

  private void seedGrammar() {
    for (GrammarTopicSeed seed : read("content/grammar.json", GrammarFile.class).topics()) {
      var found = grammar.findFirstByTitle(seed.title());
      if (found.isEmpty()) {
        grammar.save(toTopic(seed));
        continue;
      }
      GrammarTopic topic = found.get();
      Map<String, GrammarLesson> byTitle = new HashMap<>();
      for (GrammarLesson lesson : topic.getLessons()) byTitle.put(lesson.getTitle(), lesson);
      boolean added = false;
      for (LessonSeed lessonSeed : seed.lessons()) {
        GrammarLesson lesson = byTitle.get(lessonSeed.title());
        if (lesson == null) {
          attachLesson(topic, lessonSeed);
          added = true;
          continue;
        }
        if (lessonSeed.examples() != null) {
          Set<String> haveEn = new HashSet<>();
          for (GrammarExample example : lesson.getExamples()) {
            if (example.getEn() != null) haveEn.add(example.getEn());
          }
          for (ExampleSeed exampleSeed : lessonSeed.examples()) {
            if (exampleSeed.en() == null || exampleSeed.en().isBlank() || !haveEn.add(exampleSeed.en())) {
              continue;
            }
            GrammarExample example = new GrammarExample();
            example.setLesson(lesson);
            example.setEn(exampleSeed.en());
            example.setSortOrder(exampleSeed.sortOrder());
            lesson.getExamples().add(example);
            added = true;
          }
        }
        if (lessonSeed.exercises() != null) {
          Set<String> haveQuestion = new HashSet<>();
          for (GrammarExercise exercise : lesson.getExercises()) {
            if (exercise.getQuestion() != null) haveQuestion.add(exercise.getQuestion());
          }
          for (ExerciseSeed exerciseSeed : lessonSeed.exercises()) {
            if (exerciseSeed.question() == null
                || exerciseSeed.question().isBlank()
                || !haveQuestion.add(exerciseSeed.question())) {
              continue;
            }
            GrammarExercise exercise = new GrammarExercise();
            exercise.setLesson(lesson);
            exercise.setQuestion(exerciseSeed.question());
            exercise.setAnswer(exerciseSeed.answer());
            exercise.setExplanation(exerciseSeed.explanation());
            exercise.setSortOrder(exerciseSeed.sortOrder());
            lesson.getExercises().add(exercise);
            int i = 1;
            if (exerciseSeed.options() != null) {
              for (String text : exerciseSeed.options()) {
                GrammarOption option = new GrammarOption();
                option.setExercise(exercise);
                option.setText(text);
                option.setCorrect(text.equals(exerciseSeed.answer()));
                option.setSortOrder(i++);
                exercise.getOptions().add(option);
              }
            }
            added = true;
          }
        }
      }
      if (added) grammar.save(topic);
    }
  }

  private void seedReading() {
    for (PassageSeed seed : read("content/reading.json", ReadingFile.class).passages()) {
      var found = passages.findFirstByTitle(seed.title());
      if (found.isPresent()) {
        saveGroups(OwnerType.READING_PASSAGE, found.get().getId(), seed.groups());
        continue;
      }
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
      var existing = tracks.findFirstByTitle(seed.title());
      if (existing.isPresent()) {
        ListeningTrack track = existing.get();
        if ((track.getAudioUrl() == null || track.getAudioUrl().isBlank())
            && seed.audioUrl() != null
            && !seed.audioUrl().isBlank()) {
          track.setAudioUrl(seed.audioUrl());
          tracks.save(track);
        }
        saveGroups(OwnerType.LISTENING_TRACK, track.getId(), seed.groups());
        continue;
      }
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
    Map<String, QuestionGroup> byPrompt = new HashMap<>();
    int order = 0;
    for (QuestionGroup group : groups.findByOwnerTypeAndOwnerIdOrderBySortOrderAsc(ownerType, ownerId)) {
      order = Math.max(order, group.getSortOrder());
      for (Question question : group.getQuestions()) {
        if (question.getPrompt() != null) byPrompt.put(question.getPrompt(), group);
      }
    }
    for (GroupSeed seed : seeds) {
      if (seed.questions() == null || seed.questions().isEmpty()) continue;
      QuestionGroup matched = null;
      for (QuestionSeed question : seed.questions()) {
        QuestionGroup found = byPrompt.get(question.prompt());
        if (found != null) matched = found;
      }
      if (matched != null) {
        if ((matched.getImageUrl() == null || matched.getImageUrl().isBlank())
            && seed.imageUrl() != null
            && !seed.imageUrl().isBlank()) {
          matched.setImageUrl(seed.imageUrl());
          groups.save(matched);
        }
        continue;
      }
      QuestionGroup group = new QuestionGroup();
      group.setOwnerType(ownerType);
      group.setOwnerId(ownerId);
      group.setQuestionType(QuestionType.valueOf(seed.type()));
      group.setInstruction(seed.instruction());
      group.setWordLimit(seed.wordLimit());
      group.setImageUrl(seed.imageUrl());
      group.setSortOrder(++order);
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
      var existing = writingPrompts.findFirstByTitle(seed.title());
      if (existing.isPresent()) {
        WritingPrompt prompt = existing.get();
        if ((prompt.getSampleAnswer() == null || prompt.getSampleAnswer().isBlank())
            && seed.sampleAnswer() != null
            && !seed.sampleAnswer().isBlank()) {
          prompt.setSampleAnswer(seed.sampleAnswer());
          prompt.setSampleBand(seed.sampleBand());
          writingPrompts.save(prompt);
        }
        continue;
      }
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
      var found = speakingPrompts.findFirstByQuestion(seed.question());
      if (found.isPresent()) {
        SpeakingPrompt existing = found.get();
        if (seed.sampleAnswer() != null
            && !seed.sampleAnswer().isBlank()
            && (existing.getSampleAnswer() == null || !seed.sampleAnswer().equals(existing.getSampleAnswer()))) {
          existing.setSampleAnswer(seed.sampleAnswer());
          speakingPrompts.save(existing);
        }
        continue;
      }
      SpeakingPrompt prompt = new SpeakingPrompt();
      prompt.setPart(seed.part());
      prompt.setTopic(seed.topic());
      prompt.setQuestion(seed.question());
      prompt.setCueCardPoints(seed.cueCardPoints() == null ? List.of() : seed.cueCardPoints());
      prompt.setSampleAnswer(seed.sampleAnswer());
      prompt.setSortOrder(seed.sortOrder());
      speakingPrompts.save(prompt);
    }
  }

  /** Cụm từ mới trong JSON được thêm vào, cụm đã có giữ nguyên. Thứ tự theo vị trí trong file. */
  private void seedPhrases() {
    int order = 0;
    for (PhraseSeed seed : read("content/phrases.json", PhraseFile.class).phrases()) {
      order++;
      if (phrases.existsByCategoryAndPhrase(seed.category(), seed.phrase())) continue;
      WritingPhrase phrase = new WritingPhrase();
      phrase.setTask(seed.task());
      phrase.setCategory(seed.category());
      phrase.setPhrase(seed.phrase());
      phrase.setMeaningVi(seed.meaningVi());
      phrase.setExample(seed.example());
      phrase.setBandMin(seed.bandMin());
      phrase.setSortOrder(order);
      phrases.save(phrase);
    }
  }

  private void seedTests() {
    for (TestSeed seed : read("content/tests.json", TestFile.class).tests()) {
      var found = tests.findFirstByTitle(seed.title());
      if (found.isPresent()) {
        attachMissingSections(found.get(), seed);
        continue;
      }
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
              case SPEAKING_PROMPT -> speakingPrompts.findFirstByQuestion(s.title()).map(SpeakingPrompt::getId);
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

  /** Đề đã có thì chỉ gắn thêm phần mới, để kéo một đề ngắn lên đủ câu mà không tạo đề trùng. */
  private void attachMissingSections(IeltsTest test, TestSeed seed) {
    boolean changed = false;
    if (seed.description() != null && !seed.description().equals(test.getDescription())) {
      test.setDescription(seed.description());
      changed = true;
    }
    if (seed.durationMin() != test.getDurationMin()) {
      test.setDurationMin(seed.durationMin());
      changed = true;
    }
    int order = 0;
    Set<String> linked = new HashSet<>();
    for (TestSection section : test.getSections()) {
      order = Math.max(order, section.getSortOrder());
      linked.add(section.getRefType().name() + ":" + section.getRefId());
    }
    for (SectionSeed s : seed.sections()) {
      SectionRef ref = SectionRef.valueOf(s.refType());
      Optional<Long> refId = resolveRef(ref, s.title());
      if (refId.isEmpty()) {
        log.warn("Test '{}' references missing content '{}'", seed.title(), s.title());
        continue;
      }
      if (!linked.add(ref.name() + ":" + refId.get())) continue;
      TestSection section = new TestSection();
      section.setTest(test);
      section.setSkill(Skill.valueOf(s.skill()));
      section.setRefType(ref);
      section.setRefId(refId.get());
      section.setSortOrder(++order);
      test.getSections().add(section);
      changed = true;
    }
    if (changed) tests.save(test);
  }

  private Optional<Long> resolveRef(SectionRef ref, String title) {
    return switch (ref) {
      case READING_PASSAGE -> passages.findFirstByTitle(title).map(ReadingPassage::getId);
      case LISTENING_TRACK -> tracks.findFirstByTitle(title).map(ListeningTrack::getId);
      case WRITING_PROMPT -> writingPrompts.findFirstByTitle(title).map(WritingPrompt::getId);
      case SPEAKING_PROMPT -> speakingPrompts.findFirstByQuestion(title).map(SpeakingPrompt::getId);
    };
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
    for (LessonSeed lessonSeed : seed.lessons()) attachLesson(topic, lessonSeed);
    return topic;
  }

  private void attachLesson(GrammarTopic topic, LessonSeed lessonSeed) {
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
        exercise.setExplanation(exerciseSeed.explanation());
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

  private String pictureUrl(Map<String, String> pictures, String word) {
    String file = pictures.get(word.toLowerCase());
    if (file == null || file.isBlank()) return null;
    return "/api/media/" + file;
  }

  private <T> T read(String path, Class<T> type) {
    try (InputStream in = new ClassPathResource(path).getInputStream()) {
      return json.readValue(in, type);
    } catch (IOException ex) {
      throw new IllegalStateException("Không đọc được " + path, ex);
    }
  }

  private <T> T read(String path, TypeReference<T> type) {
    try (InputStream in = new ClassPathResource(path).getInputStream()) {
      return json.readValue(in, type);
    } catch (IOException ex) {
      throw new IllegalStateException("Không đọc được " + path, ex);
    }
  }
}
