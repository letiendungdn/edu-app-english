package com.edu.english.repo;

import com.edu.english.domain.Enums.AttemptStatus;
import com.edu.english.domain.TestAttempt;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TestAttemptRepository extends JpaRepository<TestAttempt, Long> {
  List<TestAttempt> findByUserIdOrderByStartedAtDesc(Long userId);

  Optional<TestAttempt> findFirstByUserIdAndTestIdAndStatusOrderByStartedAtDesc(
      Long userId, Long testId, AttemptStatus status);
}
