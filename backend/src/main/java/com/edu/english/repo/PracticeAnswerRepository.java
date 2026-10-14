package com.edu.english.repo;

import com.edu.english.domain.PracticeAnswer;
import java.time.Instant;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface PracticeAnswerRepository extends JpaRepository<PracticeAnswer, Long> {
  /** Câu đang sai: lần trả lời mới nhất (id lớn nhất) của câu đó chưa đủ điểm và chưa bấm "Đã hiểu". */
  String OPEN_MISTAKES =
      " from PracticeAnswer a where a.userId = :userId and a.points < a.maxPoints and a.reviewedAt is null"
          + " and a.id = (select max(b.id) from PracticeAnswer b where b.userId = a.userId and b.questionId = a.questionId)";

  @Query("select a" + OPEN_MISTAKES + " order by a.answeredAt desc, a.id desc")
  List<PracticeAnswer> findOpenMistakes(@Param("userId") Long userId);

  @Query("select count(a)" + OPEN_MISTAKES)
  long countOpenMistakes(@Param("userId") Long userId);

  List<PracticeAnswer> findByUserIdAndAnsweredAtAfter(Long userId, Instant after);

  List<PracticeAnswer> findByUserIdAndQuestionId(Long userId, Long questionId);
}
