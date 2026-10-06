package com.edu.english.repo;

import com.edu.english.domain.Enums.EnglishLevel;
import com.edu.english.domain.ReadingPassage;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ReadingPassageRepository extends JpaRepository<ReadingPassage, Long> {
  List<ReadingPassage> findByLevelOrderBySortOrderAsc(EnglishLevel level);

  List<ReadingPassage> findAllByOrderByLevelAscSortOrderAsc();

  Optional<ReadingPassage> findFirstByTitle(String title);
}
