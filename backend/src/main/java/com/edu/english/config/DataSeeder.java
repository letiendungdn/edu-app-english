package com.edu.english.config;

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
import java.time.LocalDate;
import org.springframework.boot.CommandLineRunner;
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

  public DataSeeder(
      VocabularyRepository vocabulary,
      VocabTopicRepository topics,
      GrammarTopicRepository grammar,
      ReadingPassageRepository passages,
      ListeningTrackRepository tracks,
      UserRepository users,
      StudySessionRepository sessions,
      PasswordEncoder encoder,
      VocabService vocabService) {
    this.vocabulary = vocabulary;
    this.topics = topics;
    this.grammar = grammar;
    this.passages = passages;
    this.tracks = tracks;
    this.users = users;
    this.sessions = sessions;
    this.encoder = encoder;
    this.vocabService = vocabService;
  }

  @Override
  @Transactional
  public void run(String... args) {
      if (vocabulary.count() > 0) return;

      VocabTopic daily = topics.save(topic("Daily Life", "🏠", 1));
      VocabTopic work = topics.save(topic("Work & Career", "💼", 2));
      VocabTopic travel = topics.save(topic("Travel", "✈️", 3));

      int order = 0;
      word(vocabulary, daily, "hello", "/həˈloʊ/", "xin chào", EnglishLevel.A1, PartOfSpeech.interjection, "Hello, how are you?", "Xin chào, bạn khỏe không?", order++);
      word(vocabulary, daily, "goodbye", "/ˌɡʊdˈbaɪ/", "tạm biệt", EnglishLevel.A1, PartOfSpeech.interjection, "Goodbye, see you tomorrow!", "Tạm biệt, hẹn gặp lại ngày mai!", order++);
      word(vocabulary, daily, "house", "/haʊs/", "ngôi nhà", EnglishLevel.A1, PartOfSpeech.noun, "I live in a small house.", "Tôi sống trong một ngôi nhà nhỏ.", order++);
      word(vocabulary, daily, "water", "/ˈwɔːtər/", "nước", EnglishLevel.A1, PartOfSpeech.noun, "Can I have some water?", "Tôi có thể xin chút nước không?", order++);
      word(vocabulary, daily, "eat", "/iːt/", "ăn", EnglishLevel.A1, PartOfSpeech.verb, "I eat breakfast every morning.", "Tôi ăn sáng mỗi buổi sáng.", order++);
      word(vocabulary, daily, "book", "/bʊk/", "quyển sách", EnglishLevel.A1, PartOfSpeech.noun, "This is a good book.", "Đây là một cuốn sách hay.", order++);
      word(vocabulary, daily, "friend", "/frend/", "bạn bè", EnglishLevel.A1, PartOfSpeech.noun, "She is my best friend.", "Cô ấy là người bạn thân nhất của tôi.", order++);
      word(vocabulary, daily, "happy", "/ˈhæpi/", "vui vẻ, hạnh phúc", EnglishLevel.A1, PartOfSpeech.adjective, "I am very happy today.", "Hôm nay tôi rất vui.", order++);
      word(vocabulary, work, "work", "/wɜːrk/", "làm việc / công việc", EnglishLevel.A1, PartOfSpeech.verb, "I work in an office.", "Tôi làm việc trong văn phòng.", order++);
      word(vocabulary, daily, "school", "/skuːl/", "trường học", EnglishLevel.A1, PartOfSpeech.noun, "My school is near my house.", "Trường tôi gần nhà tôi.", order++);
      word(vocabulary, daily, "although", "/ɔːlˈðoʊ/", "mặc dù", EnglishLevel.A2, PartOfSpeech.conjunction, "Although it was raining, we went out.", "Mặc dù trời mưa, chúng tôi vẫn ra ngoài.", order++);
      word(vocabulary, travel, "journey", "/ˈdʒɜːrni/", "hành trình", EnglishLevel.A2, PartOfSpeech.noun, "The journey took three hours.", "Hành trình mất ba tiếng đồng hồ.", order++);
      word(vocabulary, daily, "describe", "/dɪˈskraɪb/", "mô tả", EnglishLevel.A2, PartOfSpeech.verb, "Can you describe what you saw?", "Bạn có thể mô tả những gì bạn thấy không?", order++);
      word(vocabulary, daily, "popular", "/ˈpɒpjʊlər/", "phổ biến", EnglishLevel.A2, PartOfSpeech.adjective, "This song is very popular.", "Bài hát này rất phổ biến.", order++);
      word(vocabulary, travel, "passport", "/ˈpæspɔːrt/", "hộ chiếu", EnglishLevel.A2, PartOfSpeech.noun, "You need a passport to travel abroad.", "Bạn cần hộ chiếu để đi nước ngoài.", order++);
      word(vocabulary, work, "negotiate", "/nɪˈɡoʊʃieɪt/", "đàm phán, thương lượng", EnglishLevel.B1, PartOfSpeech.verb, "We need to negotiate the contract terms.", "Chúng ta cần thương lượng các điều khoản hợp đồng.", order++);
      word(vocabulary, work, "significant", "/sɪɡˈnɪfɪkənt/", "đáng kể, quan trọng", EnglishLevel.B1, PartOfSpeech.adjective, "There has been a significant improvement.", "Đã có sự cải thiện đáng kể.", order++);
      word(vocabulary, travel, "recommend", "/ˌrekəˈmend/", "đề nghị, giới thiệu", EnglishLevel.B1, PartOfSpeech.verb, "I recommend this restaurant.", "Tôi giới thiệu nhà hàng này.", order++);
      word(vocabulary, work, "efficient", "/ɪˈfɪʃənt/", "hiệu quả", EnglishLevel.B1, PartOfSpeech.adjective, "She is a very efficient worker.", "Cô ấy là một nhân viên rất hiệu quả.", order++);
      word(vocabulary, work, "approximately", "/əˈprɒksɪmətli/", "xấp xỉ, khoảng", EnglishLevel.B1, PartOfSpeech.adverb, "It costs approximately $50.", "Nó có giá khoảng 50 đô la.", order++);

      grammar.save(presentSimple());
      grammar.save(presentContinuous());
      grammar.save(conditionals());

      ReadingPassage routine = passage(
          "My Daily Routine",
          EnglishLevel.A1,
          3,
          null,
          """
          My name is Lan. I am a student. Every day, I wake up at 6 o'clock in the morning. I wash my face and brush my teeth. Then I eat breakfast with my family.

          I go to school at 7 o'clock. I walk to school because my school is near my house. At school, I study Math, English, and Science.

          After school, I go home at 5 o'clock. I do my homework and then I watch TV. I eat dinner at 7 o'clock. I read a book before I sleep. I go to bed at 10 o'clock.
          """);
      question(routine, "What time does Lan wake up?", "6 o'clock", null, 1, "5 o'clock", "6 o'clock", "7 o'clock", "8 o'clock");
      question(routine, "How does Lan go to school?", "She walks", null, 2, "By bus", "By bicycle", "She walks", "By car");
      question(routine, "What does Lan do before sleeping?", "She reads a book", null, 3, "She watches TV", "She does homework", "She reads a book", "She plays games");
      passages.save(routine);

      ReadingPassage benefits = passage(
          "The Benefits of Learning English",
          EnglishLevel.B1,
          5,
          "Adapted from various sources",
          """
          English is one of the most widely spoken languages in the world. More than 1.5 billion people speak English, either as their first or second language. Learning English can open many doors for you in life.

          First, English is the language of international business. Many multinational companies require their employees to speak English. If you can communicate effectively in English, you will have a significant advantage in the job market.

          Second, most scientific research and academic papers are published in English. Students who can read English have access to a much wider range of educational resources.

          Third, English is the primary language of the internet. A large percentage of websites, videos, and online content are in English.

          Finally, learning English can help you understand different cultures and connect with people from all over the world.
          """);
      question(benefits, "According to the passage, how many people speak English?", "More than 1.5 billion", null, 1, "More than 1 billion", "More than 1.5 billion", "More than 2 billion", "About 500 million");
      question(benefits, "Why is English important in business?", "Multinational companies require employees to speak English", "The passage states that many multinational companies require their employees to speak English.", 2, "It is the official language of all countries", "Multinational companies require employees to speak English", "It is easy to learn", "It helps you make more money immediately");
      question(benefits, "What share of the internet is in English?", "A large percentage", null, 3, "50%", "75%", "A large percentage", "Almost all of it");
      passages.save(benefits);

      ListeningTrack track = new ListeningTrack();
      track.setTitle("At the Cafe");
      track.setLevel(EnglishLevel.A1);
      track.setSortOrder(1);
      track.setDurationSec(90);
      track.setTranscript("A: Hi, can I have a coffee, please? B: Sure. Anything else? A: A glass of water, thank you.");
      ListeningQuestion q = new ListeningQuestion();
      q.setTrack(track);
      q.setQuestion("What does the customer order first?");
      q.setAnswer("A coffee");
      q.setSortOrder(1);
      track.getQuestions().add(q);
      option(q, "A tea", 1);
      option(q, "A coffee", 2);
      option(q, "A cake", 3);
      option(q, "A sandwich", 4);
      tracks.save(track);

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

  private static VocabTopic topic(String name, String icon, int order) {
    VocabTopic topic = new VocabTopic();
    topic.setName(name);
    topic.setIcon(icon);
    topic.setSortOrder(order);
    return topic;
  }

  private static void word(
      VocabularyRepository vocabulary,
      VocabTopic topic,
      String text,
      String phonetic,
      String meaning,
      EnglishLevel level,
      PartOfSpeech pos,
      String exampleEn,
      String exampleVi,
      int sortOrder) {
    Vocabulary word = new Vocabulary();
    word.setTopic(topic);
    word.setWord(text);
    word.setPhonetic(phonetic);
    word.setMeaningVi(meaning);
    word.setLevel(level);
    word.setPartOfSpeech(pos);
    word.setExampleEn(exampleEn);
    word.setExampleVi(exampleVi);
    word.setSortOrder(sortOrder);
    word.setImageUrl("https://api.dicebear.com/9.x/shapes/svg?seed=" + text);
    vocabulary.save(word);
  }

  private static GrammarTopic presentSimple() {
    GrammarTopic topic = new GrammarTopic();
    topic.setTitle("Present Simple");
    topic.setDescription("Thì hiện tại đơn — diễn tả thói quen, sự thật chung");
    topic.setLevel(EnglishLevel.A1);
    topic.setSortOrder(1);
    GrammarLesson lesson = lesson(topic, "Cách dùng & cấu trúc", EnglishLevel.A1, 1, """
        Present Simple (Thì hiện tại đơn) dùng để:
        1. Diễn tả thói quen, việc lặp đi lặp lại
           → I drink coffee every morning.
        2. Diễn tả sự thật hiển nhiên, chân lý
           → The sun rises in the east.
        3. Diễn tả lịch trình cố định
           → The train leaves at 8am.

        Cấu trúc:
        (+) S + V(s/es)
        (-) S + don't/doesn't + V
        (?) Do/Does + S + V?

        Lưu ý: Thêm -s/-es với he/she/it""");
    example(lesson, "She speaks English very well.", 1);
    example(lesson, "We don't eat meat on Fridays.", 2);
    example(lesson, "Does he play football?", 3);
    exercise(lesson, "She ___ (work) at a hospital.", "works", 1, "work", "works", "working", "worked");
    exercise(lesson, "They ___ (not/eat) fast food.", "don't eat", 2, "don't eat", "doesn't eat", "not eat", "aren't eat");
    exercise(lesson, "___ he ___ (speak) French?", "Does / speak", 3, "Does / speak", "Do / speaks", "Is / speak", "Has / speak");
    exercise(lesson, "Water ___ (boil) at 100°C.", "boils", 4, "boil", "boils", "is boiling", "boiled");
    return topic;
  }

  private static GrammarTopic presentContinuous() {
    GrammarTopic topic = new GrammarTopic();
    topic.setTitle("Present Continuous");
    topic.setDescription("Thì hiện tại tiếp diễn — đang xảy ra lúc nói");
    topic.setLevel(EnglishLevel.A1);
    topic.setSortOrder(2);
    GrammarLesson lesson = lesson(topic, "Cách dùng & cấu trúc", EnglishLevel.A1, 1, """
        Present Continuous dùng để:
        1. Diễn tả hành động đang xảy ra tại thời điểm nói
           → I am reading a book right now.
        2. Diễn tả sự thay đổi hoặc xu hướng
           → Prices are rising.
        3. Diễn tả kế hoạch trong tương lai gần
           → I am meeting him tomorrow.

        Cấu trúc: S + am/is/are + V-ing""");
    example(lesson, "She is watching TV now.", 1);
    example(lesson, "They aren't working today.", 2);
    exercise(lesson, "Listen! She ___ (sing).", "is singing", 1, "sings", "is singing", "are singing", "was singing");
    exercise(lesson, "We ___ (not/watch) TV right now.", "aren't watching", 2, "aren't watching", "don't watch", "isn't watching", "not watching");
    exercise(lesson, "___ they ___ (study) for the exam?", "Are / studying", 3, "Are / studying", "Do / study", "Is / studying", "Have / studying");
    return topic;
  }

  private static GrammarTopic conditionals() {
    GrammarTopic topic = new GrammarTopic();
    topic.setTitle("Conditional Sentences");
    topic.setDescription("Câu điều kiện loại 1 và loại 2");
    topic.setLevel(EnglishLevel.B1);
    topic.setSortOrder(1);
    GrammarLesson type1 = lesson(topic, "Conditional Type 1", EnglishLevel.B1, 1, """
        Câu điều kiện loại 1 — điều kiện có thể xảy ra ở hiện tại hoặc tương lai.

        Cấu trúc: If + S + V(simple present), S + will + V

        • If it rains, I will stay at home.
        • If you study hard, you will pass the exam.""");
    example(type1, "If I have time, I will call you.", 1);
    exercise(type1, "If it ___ (rain), we ___ (cancel) the picnic.", "rains / will cancel", 1, "rains / will cancel", "rained / would cancel", "will rain / cancel", "rains / cancel");
    exercise(type1, "She ___ (be) angry if you ___ (be) late.", "will be / are", 2, "will be / are", "would be / were", "is / will be", "will be / will be");

    GrammarLesson type2 = lesson(topic, "Conditional Type 2", EnglishLevel.B1, 2, """
        Câu điều kiện loại 2 — giả thuyết không có thật ở hiện tại.

        Cấu trúc: If + S + V(past simple), S + would + V

        Với động từ to be, dùng were cho mọi chủ ngữ.
        • If I were rich, I would travel the world.""");
    example(type2, "If I were you, I would accept the job.", 1);
    exercise(type2, "If I ___ (be) you, I ___ (study) harder.", "were / would study", 1, "were / would study", "was / will study", "am / would study", "were / will study");
    return topic;
  }

  private static GrammarLesson lesson(GrammarTopic topic, String title, EnglishLevel level, int order, String explanation) {
    GrammarLesson lesson = new GrammarLesson();
    lesson.setTopic(topic);
    lesson.setTitle(title);
    lesson.setLevel(level);
    lesson.setSortOrder(order);
    lesson.setExplanation(explanation.strip());
    topic.getLessons().add(lesson);
    return lesson;
  }

  private static void example(GrammarLesson lesson, String en, int order) {
    GrammarExample example = new GrammarExample();
    example.setLesson(lesson);
    example.setEn(en);
    example.setSortOrder(order);
    lesson.getExamples().add(example);
  }

  private static void exercise(GrammarLesson lesson, String question, String answer, int order, String... options) {
    GrammarExercise exercise = new GrammarExercise();
    exercise.setLesson(lesson);
    exercise.setQuestion(question);
    exercise.setAnswer(answer);
    exercise.setSortOrder(order);
    lesson.getExercises().add(exercise);
    int i = 1;
    for (String text : options) {
      GrammarOption option = new GrammarOption();
      option.setExercise(exercise);
      option.setText(text);
      option.setCorrect(text.equals(answer));
      option.setSortOrder(i++);
      exercise.getOptions().add(option);
    }
  }

  private static ReadingPassage passage(String title, EnglishLevel level, int minutes, String source, String content) {
    ReadingPassage passage = new ReadingPassage();
    passage.setTitle(title);
    passage.setLevel(level);
    passage.setEstimatedMin(minutes);
    passage.setSource(source);
    passage.setContent(content.strip());
    passage.setSortOrder(1);
    return passage;
  }

  private static void question(ReadingPassage passage, String text, String answer, String explanation, int order, String... options) {
    ReadingQuestion question = new ReadingQuestion();
    question.setPassage(passage);
    question.setQuestion(text);
    question.setAnswer(answer);
    question.setExplanation(explanation);
    question.setSortOrder(order);
    passage.getQuestions().add(question);
    int i = 1;
    for (String optionText : options) {
      ReadingOption option = new ReadingOption();
      option.setQuestion(question);
      option.setText(optionText);
      option.setSortOrder(i++);
      question.getOptions().add(option);
    }
  }

  private static void option(ListeningQuestion question, String text, int order) {
    ListeningOption option = new ListeningOption();
    option.setQuestion(question);
    option.setText(text);
    option.setSortOrder(order);
    question.getOptions().add(option);
  }
}
