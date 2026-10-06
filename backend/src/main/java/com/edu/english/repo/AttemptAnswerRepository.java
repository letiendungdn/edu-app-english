package com.edu.english.repo;

import com.edu.english.domain.AttemptAnswer;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AttemptAnswerRepository extends JpaRepository<AttemptAnswer, Long> {
  List<AttemptAnswer> findByAttemptId(Long attemptId);
}
