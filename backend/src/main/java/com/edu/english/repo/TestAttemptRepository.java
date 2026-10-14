package com.edu.english.repo;

import com.edu.english.domain.Enums.AttemptStatus;
import com.edu.english.domain.TestAttempt;
import java.util.List;
import java.util.Optional;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface TestAttemptRepository extends JpaRepository<TestAttempt, Long> {
  List<TestAttempt> findByUserIdOrderByStartedAtDesc(Long userId);

  Optional<TestAttempt> findFirstByUserIdAndTestIdAndStatusOrderByStartedAtDesc(
      Long userId, Long testId, AttemptStatus status);

  /** Khoá dòng: Writing và Speaking chấm xong cùng lúc thì hai luồng lần lượt tính band, không ghi đè nhau. */
  @Lock(LockModeType.PESSIMISTIC_WRITE)
  @Query("select a from TestAttempt a where a.id = :id")
  Optional<TestAttempt> lockById(@Param("id") Long id);
}
