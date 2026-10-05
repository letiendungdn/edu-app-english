package com.edu.english.repo;

import com.edu.english.domain.Enums.EnglishLevel;
import com.edu.english.domain.GrammarTopic;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GrammarTopicRepository extends JpaRepository<GrammarTopic, Long> {
  List<GrammarTopic> findByLevelOrderBySortOrderAsc(EnglishLevel level);

  List<GrammarTopic> findAllByOrderByLevelAscSortOrderAsc();
}
