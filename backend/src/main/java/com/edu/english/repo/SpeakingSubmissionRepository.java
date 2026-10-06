package com.edu.english.repo;

import com.edu.english.domain.SpeakingSubmission;
import java.time.Instant;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface SpeakingSubmissionRepository extends JpaRepository<SpeakingSubmission, Long> {
  List<SpeakingSubmission> findTop50ByUserIdOrderByCreatedAtDesc(Long userId);

  long countByUserIdAndCreatedAtAfter(Long userId, Instant after);

  @Query("select distinct s.promptId from SpeakingSubmission s where s.userId = :userId")
  List<Long> findPromptIdsAttemptedBy(@Param("userId") Long userId);
}
