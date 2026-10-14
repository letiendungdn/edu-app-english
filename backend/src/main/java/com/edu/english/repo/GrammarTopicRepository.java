package com.edu.english.repo;

import com.edu.english.domain.Enums.EnglishLevel;
import com.edu.english.domain.GrammarTopic;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GrammarTopicRepository extends JpaRepository<GrammarTopic, Long> {
  boolean existsByTitle(String title);

  Optional<GrammarTopic> findFirstByTitle(String title);

  List<GrammarTopic> findByLevelOrderBySortOrderAsc(EnglishLevel level);

  List<GrammarTopic> findAllByOrderByLevelAscSortOrderAsc();
}
