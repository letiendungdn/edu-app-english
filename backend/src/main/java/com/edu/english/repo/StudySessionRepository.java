package com.edu.english.repo;

import com.edu.english.domain.StudySession;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StudySessionRepository extends JpaRepository<StudySession, Long> {
  Optional<StudySession> findByUserIdAndStudyDate(Long userId, LocalDate studyDate);

  List<StudySession> findByUserIdOrderByStudyDateAsc(Long userId);
}
