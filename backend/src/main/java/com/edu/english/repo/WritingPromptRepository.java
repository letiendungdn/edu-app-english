package com.edu.english.repo;

import com.edu.english.domain.WritingPrompt;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface WritingPromptRepository extends JpaRepository<WritingPrompt, Long> {
  List<WritingPrompt> findAllByOrderByTaskAscSortOrderAsc();

  Optional<WritingPrompt> findFirstByTitle(String title);
}
