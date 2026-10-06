package com.edu.english.repo;

import com.edu.english.domain.WritingSubmission;
import java.time.Instant;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface WritingSubmissionRepository extends JpaRepository<WritingSubmission, Long> {
  List<WritingSubmission> findTop50ByUserIdOrderByCreatedAtDesc(Long userId);

  List<WritingSubmission> findByAttemptId(Long attemptId);

  long countByUserIdAndCreatedAtAfter(Long userId, Instant after);

  @Query("select distinct s.promptId from WritingSubmission s where s.userId = :userId")
  List<Long> findPromptIdsAttemptedBy(@Param("userId") Long userId);
}
