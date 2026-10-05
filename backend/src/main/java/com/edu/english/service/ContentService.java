package com.edu.english.service;

import com.edu.english.domain.Enums.EnglishLevel;
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
import com.edu.english.repo.ListeningAttemptRepository;
import com.edu.english.repo.ListeningTrackRepository;
import com.edu.english.repo.ReadingAttemptRepository;
import com.edu.english.repo.ReadingPassageRepository;
import com.edu.english.repo.SrsCardRepository;
import com.edu.english.repo.StudySessionRepository;
import com.edu.english.repo.VocabularyRepository;
import com.edu.english.web.ApiModels.AnalyticsView;
import com.edu.english.web.ApiModels.AnswerResult;
import com.edu.english.web.ApiModels.DictationWord;
import com.edu.english.web.ApiModels.ExerciseView;
import com.edu.english.web.ApiModels.GrammarDetail;
import com.edu.english.web.ApiModels.GrammarListItem;
import com.edu.english.web.ApiModels.HistoryPoint;
import com.edu.english.web.ApiModels.LessonView;
import com.edu.english.web.ApiModels.OptionView;
import com.edu.english.web.ApiModels.Overview;
import com.edu.english.web.ApiModels.PassageDetail;
import com.edu.english.web.ApiModels.PassageListItem;
import com.edu.english.web.ApiModels.QuestionView;
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
      VocabService vocabService) {
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
    return loadPassages(levelParam).stream()
        .map(
            p ->
                new PassageListItem(
                    p.getId(),
                    p.getTitle(),
                    p.getLevel().name(),
                    p.getEstimatedMin(),
                    p.getSource(),
                    p.getQuestions().size()))
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
        passage.getQuestions().stream().map(q -> toQuestion(q.getId(), q.getQuestion(), q.getOptions().stream().map(o -> new OptionView(o.getId(), o.getText())).toList())).toList());
  }

  @Transactional
  public SubmitResult submitReading(Long id, Map<String, String> answers, Long userId) {
    ReadingPassage passage = requirePassage(id);
    SubmitResult result = grade(passage.getQuestions().stream().map(q -> new Graded(q.getId(), q.getAnswer(), q.getExplanation())).toList(), answers);
    if (userId != null) {
      ReadingAttempt attempt = new ReadingAttempt();
      attempt.setUserId(userId);
      attempt.setPassageId(id);
      attempt.setCorrectCount(result.correct());
      attempt.setTotal(result.total());
      attempt.setPercent(result.percent());
      readingAttempts.save(attempt);
      vocabService.addStudy(userId, 60, 0);
    }
    return result;
  }

  @Transactional(readOnly = true)
  public List<TrackListItem> listenings(String levelParam) {
    return loadTracks(levelParam).stream()
        .map(
            t ->
                new TrackListItem(
                    t.getId(),
                    t.getTitle(),
                    t.getLevel().name(),
                    t.getDurationSec(),
                    t.getYoutubeUrl(),
                    t.getQuestions().size()))
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
        track.getQuestions().stream()
            .map(q -> toQuestion(q.getId(), q.getQuestion(), q.getOptions().stream().map(o -> new OptionView(o.getId(), o.getText())).toList()))
            .toList());
  }

  @Transactional
  public SubmitResult submitListening(Long id, Map<String, String> answers, Long userId) {
    ListeningTrack track = requireTrack(id);
    SubmitResult result =
        grade(
            track.getQuestions().stream().map(q -> new Graded(q.getId(), q.getAnswer(), q.getExplanation())).toList(),
            answers);
    if (userId != null) {
      ListeningAttempt attempt = new ListeningAttempt();
      attempt.setUserId(userId);
      attempt.setTrackId(id);
      attempt.setCorrectCount(result.correct());
      attempt.setTotal(result.total());
      attempt.setPercent(result.percent());
      listeningAttempts.save(attempt);
      vocabService.addStudy(userId, 60, 0);
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
    if (userId != null) vocabService.addStudy(userId, 15, 0);
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

  private QuestionView toQuestion(Long id, String question, List<OptionView> options) {
    return new QuestionView(id, question, options);
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

  private SubmitResult grade(List<Graded> questions, Map<String, String> answers) {
    Map<String, String> safe = answers == null ? Map.of() : answers;
    List<AnswerResult> results =
        questions.stream()
            .map(
                q -> {
                  String given = safe.get(String.valueOf(q.id()));
                  boolean ok = q.answer().equals(given);
                  return new AnswerResult(q.id(), ok, q.answer(), q.explanation());
                })
            .toList();
    int correct = (int) results.stream().filter(AnswerResult::correct).count();
    int total = questions.size();
    int percent = total == 0 ? 0 : Math.round(correct * 100f / total);
    return new SubmitResult(correct, total, percent, results);
  }

  private record Graded(Long id, String answer, String explanation) {}
}
