package com.edu.english.repo;

import com.edu.english.domain.ListeningAttempt;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ListeningAttemptRepository extends JpaRepository<ListeningAttempt, Long> {
  List<ListeningAttempt> findByUserIdOrderBySubmittedAtAsc(Long userId);
}
