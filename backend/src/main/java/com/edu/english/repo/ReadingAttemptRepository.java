package com.edu.english.repo;

import com.edu.english.domain.ReadingAttempt;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ReadingAttemptRepository extends JpaRepository<ReadingAttempt, Long> {
  List<ReadingAttempt> findByUserIdOrderBySubmittedAtAsc(Long userId);

  long countByUserId(Long userId);

  @Query("select distinct a.passageId from ReadingAttempt a where a.userId = :userId")
  List<Long> findPassageIdsDoneBy(@Param("userId") Long userId);
}
