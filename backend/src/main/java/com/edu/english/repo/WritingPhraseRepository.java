package com.edu.english.repo;

import com.edu.english.domain.WritingPhrase;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface WritingPhraseRepository extends JpaRepository<WritingPhrase, Long> {
  List<WritingPhrase> findAllByOrderBySortOrderAscIdAsc();

  boolean existsByCategoryAndPhrase(String category, String phrase);
}
