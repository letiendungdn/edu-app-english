package com.edu.english.repo;

import com.edu.english.domain.Enums.EnglishLevel;
import com.edu.english.domain.Vocabulary;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface VocabularyRepository extends JpaRepository<Vocabulary, Long> {
  Page<Vocabulary> findByLevel(EnglishLevel level, Pageable pageable);

  List<Vocabulary> findByLevelOrderBySortOrderAscIdAsc(EnglishLevel level, Pageable pageable);

  List<Vocabulary> findAllByOrderBySortOrderAscIdAsc(Pageable pageable);
}
