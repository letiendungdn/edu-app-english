package com.edu.english.repo;

import com.edu.english.domain.ReadingAttempt;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ReadingAttemptRepository extends JpaRepository<ReadingAttempt, Long> {
  List<ReadingAttempt> findByUserIdOrderBySubmittedAtAsc(Long userId);

  long countByUserId(Long userId);
}
