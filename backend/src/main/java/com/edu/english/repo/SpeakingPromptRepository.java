package com.edu.english.repo;

import com.edu.english.domain.SpeakingPrompt;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SpeakingPromptRepository extends JpaRepository<SpeakingPrompt, Long> {
  List<SpeakingPrompt> findAllByOrderByPartAscSortOrderAsc();

  Optional<SpeakingPrompt> findFirstByQuestion(String question);
}
