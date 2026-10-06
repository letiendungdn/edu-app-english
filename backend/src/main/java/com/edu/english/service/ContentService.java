package com.edu.english.service;

import com.edu.english.domain.Enums.BandSource;
import com.edu.english.domain.Enums.EnglishLevel;
import com.edu.english.domain.Enums.IeltsModule;
import com.edu.english.domain.Enums.OwnerType;
import com.edu.english.domain.Enums.Skill;
import com.edu.english.domain.Enums.TaskType;
import com.edu.english.domain.GrammarExercise;
import com.edu.english.domain.GrammarLesson;
import com.edu.english.domain.GrammarTopic;
import com.edu.english.domain.ListeningAttempt;
import com.edu.english.domain.ListeningTrack;
import com.edu.english.domain.ReadingAttempt;
import com.edu.english.domain.ReadingPassage;
import com.edu.english.domain.StudySession;
import com.edu.english.domain.Vocabulary;
import com.edu.english.repo.DictationAttemptRepository;
import com.edu.english.repo.GrammarTopicRepository;
import com.edu.english.repo.IeltsProfileRepository;
import com.edu.english.repo.ListeningAttemptRepository;
import com.edu.english.repo.ListeningTrackRepository;
import com.edu.english.repo.ReadingAttemptRepository;
import com.edu.english.repo.ReadingPassageRepository;
import com.edu.english.repo.SrsCardRepository;
import com.edu.english.repo.StudySessionRepository;
import com.edu.english.repo.VocabularyRepository;
import com.edu.english.web.ApiModels.AnalyticsView;
import com.edu.english.web.ApiModels.DictationWord;
import com.edu.english.web.ApiModels.ExerciseView;
import com.edu.english.web.ApiModels.GrammarDetail;
import com.edu.english.web.ApiModels.GrammarListItem;
import com.edu.english.web.ApiModels.HistoryPoint;
import com.edu.english.web.ApiModels.LessonView;
import com.edu.english.web.ApiModels.Overview;
import com.edu.english.web.ApiModels.PassageDetail;
import com.edu.english.web.ApiModels.PassageListItem;
import com.edu.english.web.ApiModels.StudyPoint;
import com.edu.english.web.ApiModels.SubmitResult;
import com.edu.english.web.ApiModels.TrackDetail;
import com.edu.english.web.ApiModels.TrackListItem;
import com.edu.english.domain.DictationAttempt;
import java.util.List;
import java.util.Map;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class ContentService {
  private final GrammarTopicRepository grammar;
  private final ReadingPassageRepository passages;
  private final ReadingAttemptRepository readingAttempts;
  private final ListeningTrackRepository tracks;
  private final ListeningAttemptRepository listeningAttempts;
  private final VocabularyRepository vocabulary;
  private final DictationAttemptRepository dictations;
  private final SrsCardRepository cards;
  private final StudySessionRepository sessions;
  private final VocabService vocabService;
  private final QuestionBank questionBank;
  private final BandService bands;
  private final RoadmapService roadmap;
  private final IeltsProfileRepository profiles;

  public ContentService(
      GrammarTopicRepository grammar,
      ReadingPassageRepository passages,
      ReadingAttemptRepository readingAttempts,
      ListeningTrackRepository tracks,
      ListeningAttemptRepository listeningAttempts,
      VocabularyRepository vocabulary,
      DictationAttemptRepository dictations,
      SrsCardRepository cards,
      StudySessionRepository sessions,
      VocabService vocabService,
      QuestionBank questionBank,
      BandService bands,
      RoadmapService roadmap,
      IeltsProfileRepository profiles) {
    this.grammar = grammar;
    this.passages = passages;
    this.readingAttempts = readingAttempts;
    this.tracks = tracks;
    this.listeningAttempts = listeningAttempts;
    this.vocabulary = vocabulary;
    this.dictations = dictations;
    this.cards = cards;
    this.sessions = sessions;
    this.vocabService = vocabService;
    this.questionBank = questionBank;
    this.bands = bands;
    this.roadmap = roadmap;
    this.profiles = profiles;
  }

  @Transactional(readOnly = true)
  public List<GrammarListItem> grammarTopics(String levelParam) {
    EnglishLevel level = AuthService.parseLevel(levelParam);
    List<GrammarTopic> topics =
        level == null
            ? grammar.findAllByOrderByLevelAscSortOrderAsc()
            : grammar.findByLevelOrderBySortOrderAsc(level);
    return topics.stream()
        .map(
            t ->
                new GrammarListItem(
                    t.getId(), t.getTitle(), t.getLevel().name(), t.getDescription(), t.getLessons().size()))
        .toList();
  }

  @Transactional(readOnly = true)
  public GrammarDetail grammarTopic(Long id) {
    GrammarTopic topic =
        grammar
            .findById(id)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy chủ đề"));
    return new GrammarDetail(
        topic.getId(),
        topic.getTitle(),
        topic.getLevel().name(),
        topic.getDescription(),
        topic.getLessons().stream().map(this::toLesson).toList());
  }

  @Transactional(readOnly = true)
  public List<PassageListItem> readings(String levelParam) {
    Map<Long, Long> counts = questionBank.questionCounts(OwnerType.READING_PASSAGE);
    return loadPassages(levelParam).stream()
        .map(
            p ->
                new PassageListItem(
                    p.getId(),
                    p.getTitle(),
                    p.getLevel().name(),
                    p.getModule().name(),
                    p.getTopic(),
                    p.getBandMin(),
                    p.getBandMax(),
                    p.getEstimatedMin(),
                    p.getSource(),
                    counts.getOrDefault(p.getId(), 0L)))
        .toList();
  }

  @Transactional(readOnly = true)
  public PassageDetail reading(Long id) {
    ReadingPassage passage = requirePassage(id);
    return new PassageDetail(
        passage.getId(),
        passage.getTitle(),
        passage.getLevel().name(),
        passage.getEstimatedMin(),
        passage.getSource(),
        passage.getContent(),
        questionBank.views(OwnerType.READING_PASSAGE, passage.getId()));
  }

  @Transactional
  public SubmitResult submitReading(Long id, Map<String, String> answers, Long userId) {
    ReadingPassage passage = requirePassage(id);
    QuestionBank.Graded graded = questionBank.grade(OwnerType.READING_PASSAGE, id, answers);
    Double band =
        graded.maxPoints() >= PRACTICE_BAND_MIN_QUESTIONS
            ? bands.convert(Skill.READING, readingModule(passage, userId), graded.points(), graded.maxPoints())
            : null;
    SubmitResult result = toResult(graded, band);
    if (userId != null) {
      ReadingAttempt attempt = new ReadingAttempt();
      attempt.setUserId(userId);
      attempt.setPassageId(id);
      attempt.setCorrectCount(result.correct());
      attempt.setTotal(result.total());
      attempt.setPercent(result.percent());
      readingAttempts.save(attempt);
      vocabService.addStudy(userId, 60, 0);
      if (band != null) bands.record(userId, Skill.READING, band, BandSource.PRACTICE, attempt.getId());
      roadmap.recordProgress(userId, TaskType.READING);
    }
    return result;
  }

  @Transactional(readOnly = true)
  public List<TrackListItem> listenings(String levelParam) {
    Map<Long, Long> counts = questionBank.questionCounts(OwnerType.LISTENING_TRACK);
    return loadTracks(levelParam).stream()
        .map(
            t ->
                new TrackListItem(
                    t.getId(),
                    t.getTitle(),
                    t.getLevel().name(),
                    t.getDurationSec(),
                    t.getYoutubeUrl(),
                    t.getIeltsPart(),
                    counts.getOrDefault(t.getId(), 0L)))
        .toList();
  }

  @Transactional(readOnly = true)
  public TrackDetail listening(Long id) {
    ListeningTrack track = requireTrack(id);
    return new TrackDetail(
        track.getId(),
        track.getTitle(),
        track.getLevel().name(),
        track.getDurationSec(),
        track.getYoutubeUrl(),
        track.getAudioUrl(),
        track.getTranscript(),
        track.getIeltsPart(),
        questionBank.views(OwnerType.LISTENING_TRACK, track.getId()));
  }

  @Transactional
  public SubmitResult submitListening(Long id, Map<String, String> answers, Long userId) {
    requireTrack(id);
    QuestionBank.Graded graded = questionBank.grade(OwnerType.LISTENING_TRACK, id, answers);
    Double band =
        graded.maxPoints() >= PRACTICE_BAND_MIN_QUESTIONS
            ? bands.convert(Skill.LISTENING, IeltsModule.BOTH, graded.points(), graded.maxPoints())
            : null;
    SubmitResult result = toResult(graded, band);
    if (userId != null) {
      ListeningAttempt attempt = new ListeningAttempt();
      attempt.setUserId(userId);
      attempt.setTrackId(id);
      attempt.setCorrectCount(result.correct());
      attempt.setTotal(result.total());
      attempt.setPercent(result.percent());
      listeningAttempts.save(attempt);
      vocabService.addStudy(userId, 60, 0);
      if (band != null) bands.record(userId, Skill.LISTENING, band, BandSource.PRACTICE, attempt.getId());
      roadmap.recordProgress(userId, TaskType.LISTENING);
    }
    return result;
  }

  @Transactional(readOnly = true)
  public List<DictationWord> dictationWords(String levelParam, int limit) {
    EnglishLevel level = AuthService.parseLevel(levelParam);
    int safeLimit = Math.min(Math.max(limit, 1), 50);
    List<Vocabulary> words =
        level == null
            ? vocabulary.findAllByOrderBySortOrderAscIdAsc(PageRequest.of(0, safeLimit))
            : vocabulary.findByLevelOrderBySortOrderAscIdAsc(level, PageRequest.of(0, safeLimit));
    return words.stream()
        .map(w -> new DictationWord(w.getId(), w.getWord(), w.getPhonetic(), w.getMeaningVi(), w.getExampleEn()))
        .toList();
  }

  @Transactional
  public void recordDictation(Long vocabId, String userInput, boolean correct, Long userId) {
    DictationAttempt attempt = new DictationAttempt();
    attempt.setVocabId(vocabId);
    attempt.setUserInput(userInput == null ? "" : userInput);
    attempt.setCorrect(correct);
    attempt.setUserId(userId);
    dictations.save(attempt);
    if (userId != null) {
      vocabService.addStudy(userId, 15, 0);
      roadmap.recordProgress(userId, TaskType.DICTATION);
    }
  }

  @Transactional(readOnly = true)
  public AnalyticsView analytics(Long userId) {
    List<StudySession> study = sessions.findByUserIdOrderByStudyDateAsc(userId);
    int totalSeconds = study.stream().mapToInt(StudySession::getSeconds).sum();
    int days = (int) study.stream().filter(s -> s.getSeconds() > 0).count();
    var reading = readingAttempts.findByUserIdOrderBySubmittedAtAsc(userId);
    var listening = listeningAttempts.findByUserIdOrderBySubmittedAtAsc(userId);
    return new AnalyticsView(
        new Overview(
            totalSeconds,
            days,
            cards.countByUserIdAndRepetitionsGreaterThanEqual(userId, 3),
            cards.countByUserId(userId),
            reading.size(),
            listening.size(),
            dictations.countByUserId(userId)),
        study.stream().map(s -> new StudyPoint(s.getStudyDate(), s.getSeconds())).toList(),
        reading.stream().map(a -> new HistoryPoint(a.getSubmittedAt(), a.getPercent())).toList(),
        listening.stream().map(a -> new HistoryPoint(a.getSubmittedAt(), a.getPercent())).toList());
  }

  private LessonView toLesson(GrammarLesson lesson) {
    return new LessonView(
        lesson.getId(),
        lesson.getTitle(),
        lesson.getExplanation(),
        lesson.getExamples().stream().map(ex -> ex.getEn()).toList(),
        lesson.getExercises().stream().map(this::toExercise).toList());
  }

  private ExerciseView toExercise(GrammarExercise exercise) {
    return new ExerciseView(
        exercise.getId(),
        exercise.getQuestion(),
        exercise.getAnswer(),
        exercise.getExplanation(),
        exercise.getOptions().stream().map(o -> o.getText()).toList());
  }

  private List<ReadingPassage> loadPassages(String levelParam) {
    EnglishLevel level = AuthService.parseLevel(levelParam);
    return level == null
        ? passages.findAllByOrderByLevelAscSortOrderAsc()
        : passages.findByLevelOrderBySortOrderAsc(level);
  }

  private List<ListeningTrack> loadTracks(String levelParam) {
    EnglishLevel level = AuthService.parseLevel(levelParam);
    return level == null
        ? tracks.findAllByOrderByLevelAscSortOrderAsc()
        : tracks.findByLevelOrderBySortOrderAsc(level);
  }

  private ReadingPassage requirePassage(Long id) {
    return passages
        .findById(id)
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy bài đọc"));
  }

  private ListeningTrack requireTrack(Long id) {
    return tracks
        .findById(id)
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy bài nghe"));
  }

  /** Bài luyện ngắn hơn số câu này thì không quy đổi band: đúng 2/3 câu không nói lên band nào cả. */
  static final int PRACTICE_BAND_MIN_QUESTIONS = 10;

  private static SubmitResult toResult(QuestionBank.Graded graded, Double band) {
    int total = graded.maxPoints();
    int percent = total == 0 ? 0 : Math.round(graded.points() * 100f / total);
    return new SubmitResult(graded.points(), total, percent, band, graded.results());
  }

  private IeltsModule readingModule(ReadingPassage passage, Long userId) {
    if (passage.getModule() != IeltsModule.BOTH) return passage.getModule();
    if (userId == null) return IeltsModule.ACADEMIC;
    return profiles.findById(userId).map(p -> p.getModule()).orElse(IeltsModule.ACADEMIC);
  }
}
