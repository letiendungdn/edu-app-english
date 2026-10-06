package com.edu.english.service;

import com.edu.english.domain.Enums.OwnerType;
import com.edu.english.domain.Question;
import com.edu.english.domain.QuestionGroup;
import com.edu.english.repo.QuestionGroupRepository;
import com.edu.english.web.ApiModels.AnswerResult;
import com.edu.english.web.ApiModels.OptionItem;
import com.edu.english.web.ApiModels.QuestionGroupView;
import com.edu.english.web.ApiModels.QuestionItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Hiển thị và chấm câu hỏi của một bài đọc/bài nghe. Đáp án không bao giờ rời khỏi server trước khi nộp. */
@Service
public class QuestionBank {
  private final QuestionGroupRepository groups;

  public QuestionBank(QuestionGroupRepository groups) {
    this.groups = groups;
  }

  public record Graded(int points, int maxPoints, List<AnswerResult> results, Map<Long, Integer> pointsByQuestion) {}

  @Transactional(readOnly = true)
  public List<QuestionGroupView> views(OwnerType ownerType, Long ownerId) {
    return groups.findByOwnerTypeAndOwnerIdOrderBySortOrderAsc(ownerType, ownerId).stream().map(QuestionBank::toView).toList();
  }

  /** Tổng số câu theo bài, để hiện trên danh sách mà không tải từng nhóm. */
  @Transactional(readOnly = true)
  public Map<Long, Long> questionCounts(OwnerType ownerType) {
    Map<Long, Long> counts = new HashMap<>();
    for (Object[] row : groups.countQuestionsByOwner(ownerType)) counts.put((Long) row[0], (Long) row[1]);
    return counts;
  }

  /** answers: questionId (dạng chuỗi) → câu trả lời người học. */
  @Transactional(readOnly = true)
  public Graded grade(OwnerType ownerType, Long ownerId, Map<String, String> answers) {
    Map<String, String> safe = answers == null ? Map.of() : answers;
    List<AnswerResult> results = new ArrayList<>();
    Map<Long, Integer> byQuestion = new HashMap<>();
    int points = 0;
    int max = 0;
    for (QuestionGroup group : groups.findByOwnerTypeAndOwnerIdOrderBySortOrderAsc(ownerType, ownerId)) {
      for (Question q : group.getQuestions()) {
        String given = safe.get(String.valueOf(q.getId()));
        int got = AnswerGrader.grade(group.getQuestionType(), q.getAcceptedAnswers(), group.getWordLimit(), given);
        int qMax = AnswerGrader.maxPoints(group.getQuestionType(), q.getAcceptedAnswers());
        points += got;
        max += qMax;
        byQuestion.put(q.getId(), got);
        results.add(
            new AnswerResult(
                q.getId(),
                q.getNumber(),
                got,
                qMax,
                given,
                AnswerGrader.display(group.getQuestionType(), q.getAcceptedAnswers()),
                q.getExplanation(),
                q.getEvidence()));
      }
    }
    return new Graded(points, max, results, byQuestion);
  }

  static QuestionGroupView toView(QuestionGroup group) {
    return new QuestionGroupView(
        group.getId(),
        group.getQuestionType().name(),
        group.getInstruction(),
        group.getWordLimit(),
        group.getImageUrl(),
        group.getOptions().stream().map(o -> new OptionItem(o.getKey(), o.getText())).toList(),
        group.getQuestions().stream()
            .map(
                q ->
                    new QuestionItem(
                        q.getId(),
                        q.getNumber(),
                        q.getPrompt(),
                        q.getOptions().stream().map(o -> new OptionItem(o.getKey(), o.getText())).toList()))
            .toList());
  }
}
