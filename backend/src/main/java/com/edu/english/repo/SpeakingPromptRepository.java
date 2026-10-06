package com.edu.english.repo;

import com.edu.english.domain.SpeakingPrompt;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SpeakingPromptRepository extends JpaRepository<SpeakingPrompt, Long> {
  List<SpeakingPrompt> findAllByOrderByPartAscSortOrderAsc();
}
