package com.edu.english.repo;

import com.edu.english.domain.Enums.EnglishLevel;
import com.edu.english.domain.ListeningTrack;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ListeningTrackRepository extends JpaRepository<ListeningTrack, Long> {
  List<ListeningTrack> findByLevelOrderBySortOrderAsc(EnglishLevel level);

  List<ListeningTrack> findAllByOrderByLevelAscSortOrderAsc();

  Optional<ListeningTrack> findFirstByTitle(String title);
}
