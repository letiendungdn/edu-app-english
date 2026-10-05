package com.edu.english.repo;

import com.edu.english.domain.DictationAttempt;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DictationAttemptRepository extends JpaRepository<DictationAttempt, Long> {
  long countByUserId(Long userId);
}
