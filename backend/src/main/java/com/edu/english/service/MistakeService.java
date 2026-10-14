package com.edu.english.service;

import com.edu.english.domain.Enums.BandSource;
import com.edu.english.domain.Enums.OwnerType;
import com.edu.english.domain.Enums.QuestionType;
import com.edu.english.domain.Enums.Skill;
import com.edu.english.domain.Enums.TaskType;
import com.edu.english.domain.ListeningTrack;
import com.edu.english.domain.PracticeAnswer;
import com.edu.english.domain.Question;
import com.edu.english.domain.QuestionGroup;
import com.edu.english.domain.ReadingPassage;
import com.edu.english.repo.ListeningTrackRepository;
import com.edu.english.repo.PracticeAnswerRepository;
import com.edu.english.repo.QuestionRepository;
import com.edu.english.repo.ReadingPassageRepository;
import com.edu.english.web.ApiModels.MistakeView;
import com.edu.english.web.ApiModels.OptionItem;
import com.edu.english.web.ApiModels.QuestionTypeStat;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Sổ lỗi sai và thống kê theo dạng câu hỏi. Dữ liệu là lịch sử trả lời từng câu (practice_answers), ghi mỗi lần chấm
 * bài luyện, placement hoặc thi thử.
 */
@Service
public class MistakeService {
  /** Thống kê dạng câu chỉ lấy 90 ngày gần nhất: trình độ cũ hơn không còn nói lên điểm yếu hiện tại. */
  static final Duration STATS_WINDOW = Duration.ofDays(90);

  /** Dạng câu cần ít nhất chừng này điểm tối đa mới được coi là "yếu", tránh kết luận từ 1–2 câu. */
  static final int WEAK_MIN_POINTS = 5;

  private final PracticeAnswerRepository answers;
  private final QuestionRepository questions;
  private final ReadingPassageRepository passages;
  private final ListeningTrackRepository tracks;
  private final RoadmapService roadmap;
  private final Clock clock;

  public MistakeService(
      PracticeAnswerRepository answers,
      QuestionRepository questions,
      ReadingPassageRepository passages,
      ListeningTrackRepository tracks,
      RoadmapService roadmap,
      Clock clock) {
    this.answers = answers;
    this.questions = questions;
    this.passages = passages;
    this.tracks = tracks;
    this.roadmap = roadmap;
    this.clock = clock;
  }

  /** Ghi câu trả lời từng câu sau khi chấm. answers: questionId (chuỗi) → câu trả lời. */
  @Transactional
  public void record(
      Long userId,
      OwnerType ownerType,
      Long ownerId,
      BandSource source,
      Long sourceRefId,
      QuestionBank.Graded graded) {
    if (userId == null) return;
    Skill skill = ownerType == OwnerType.LISTENING_TRACK ? Skill.LISTENING : Skill.READING;
    Instant now = clock.instant();
    List<PracticeAnswer> rows = new ArrayList<>();
    graded.results()
        .forEach(
            r -> {
              PracticeAnswer row = new PracticeAnswer();
              row.setUserId(userId);
              row.setQuestionId(r.questionId());
              row.setQuestionType(graded.typeByQuestion().get(r.questionId()));
              row.setSkill(skill);
              row.setOwnerType(ownerType);
              row.setOwnerId(ownerId);
              row.setSource(source);
              row.setSourceRefId(sourceRefId);
              row.setGiven(r.given());
              row.setPoints(r.points());
              row.setMaxPoints(r.maxPoints());
              row.setAnsweredAt(now);
              rows.add(row);
            });
    answers.saveAll(rows);
  }

  /**
   * Câu đang sai: lần trả lời gần nhất của câu đó chưa đủ điểm và người học chưa bấm "Đã hiểu". Làm lại đúng thì câu
   * tự ra khỏi sổ.
   */
  @Transactional(readOnly = true)
  public List<MistakeView> mistakes(Long userId, String skillParam) {
    Skill skill = parseSkill(skillParam);
    List<PracticeAnswer> open =
        answers.findOpenMistakes(userId).stream().filter(a -> skill == null || a.getSkill() == skill).toList();
    if (open.isEmpty()) return List.of();

    Map<Long, Question> byId =
        questions.findAllById(open.stream().map(PracticeAnswer::getQuestionId).toList()).stream()
            .collect(Collectors.toMap(Question::getId, Function.identity()));
    Map<Long, String> readingTitles = titles(open, OwnerType.READING_PASSAGE);
    Map<Long, String> listeningTitles = titles(open, OwnerType.LISTENING_TRACK);

    List<MistakeView> views = new ArrayList<>();
    for (PracticeAnswer a : open) {
      Question q = byId.get(a.getQuestionId());
      if (q == null) continue;
      QuestionGroup g = q.getGroup();
      boolean listening = a.getOwnerType() == OwnerType.LISTENING_TRACK;
      List<OptionItem> options =
          (q.getOptions().isEmpty() ? g.getOptions().stream().map(o -> new OptionItem(o.getKey(), o.getText()))
                  : q.getOptions().stream().map(o -> new OptionItem(o.getKey(), o.getText())))
              .toList();
      views.add(
          new MistakeView(
              q.getId(),
              a.getSkill().name(),
              a.getQuestionType().name(),
              a.getOwnerId(),
              (listening ? listeningTitles : readingTitles).getOrDefault(a.getOwnerId(), ""),
              (listening ? "/listening/" : "/reading/") + a.getOwnerId(),
              q.getNumber(),
              g.getInstruction(),
              q.getPrompt(),
              options,
              a.getGiven(),
              AnswerGrader.display(g.getQuestionType(), q.getAcceptedAnswers()),
              q.getExplanation(),
              q.getEvidence(),
              a.getSource().name(),
              a.getAnsweredAt()));
    }
    return views;
  }

  /** Bấm "Đã hiểu": câu ra khỏi sổ cho tới khi làm sai lại. */
  @Transactional
  public void markReviewed(Long userId, Long questionId) {
    Instant now = clock.instant();
    List<PracticeAnswer> rows = answers.findByUserIdAndQuestionId(userId, questionId);
    rows.stream().filter(a -> a.getReviewedAt() == null).forEach(a -> a.setReviewedAt(now));
    if (!rows.isEmpty()) roadmap.recordProgress(userId, TaskType.REVIEW_MISTAKES);
  }

  /** Độ chính xác theo dạng câu trong 90 ngày, dạng yếu nhất lên đầu. */
  @Transactional(readOnly = true)
  public List<QuestionTypeStat> stats(Long userId) {
    Instant since = clock.instant().minus(STATS_WINDOW);
    Map<QuestionType, int[]> acc = new EnumMap<>(QuestionType.class);
    Map<QuestionType, Skill> skillOf = new EnumMap<>(QuestionType.class);
    for (PracticeAnswer a : answers.findByUserIdAndAnsweredAtAfter(userId, since)) {
      int[] sum = acc.computeIfAbsent(a.getQuestionType(), k -> new int[2]);
      sum[0] += a.getPoints();
      sum[1] += a.getMaxPoints();
      // Dạng câu có ở cả hai kỹ năng thì ghi null: giao diện hiện "Reading + Listening".
      skillOf.merge(a.getQuestionType(), a.getSkill(), (x, y) -> x == y ? x : null);
    }
    return acc.entrySet().stream()
        .filter(e -> e.getValue()[1] > 0)
        .map(
            e -> {
              int points = e.getValue()[0];
              int max = e.getValue()[1];
              int percent = Math.round(points * 100f / max);
              Skill s = skillOf.get(e.getKey());
              return new QuestionTypeStat(
                  e.getKey().name(), s == null ? null : s.name(), points, max, percent, max >= WEAK_MIN_POINTS && percent < 60);
            })
        .sorted(Comparator.comparingInt(QuestionTypeStat::percent).thenComparing(QuestionTypeStat::type))
        .toList();
  }

  @Transactional(readOnly = true)
  public long openCount(Long userId) {
    return answers.countOpenMistakes(userId);
  }

  private Map<Long, String> titles(List<PracticeAnswer> rows, OwnerType type) {
    List<Long> ids = rows.stream().filter(a -> a.getOwnerType() == type).map(PracticeAnswer::getOwnerId).distinct().toList();
    if (ids.isEmpty()) return Map.of();
    if (type == OwnerType.LISTENING_TRACK) {
      return tracks.findAllById(ids).stream().collect(Collectors.toMap(ListeningTrack::getId, ListeningTrack::getTitle));
    }
    return passages.findAllById(ids).stream().collect(Collectors.toMap(ReadingPassage::getId, ReadingPassage::getTitle));
  }

  private static Skill parseSkill(String value) {
    if (value == null || value.isBlank()) return null;
    try {
      return Skill.valueOf(value.trim().toUpperCase());
    } catch (IllegalArgumentException e) {
      return null;
    }
  }
}
