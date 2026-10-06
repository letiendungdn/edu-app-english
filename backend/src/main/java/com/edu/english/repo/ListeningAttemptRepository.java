package com.edu.english.repo;

import com.edu.english.domain.ListeningAttempt;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ListeningAttemptRepository extends JpaRepository<ListeningAttempt, Long> {
  List<ListeningAttempt> findByUserIdOrderBySubmittedAtAsc(Long userId);

  @Query("select distinct a.trackId from ListeningAttempt a where a.userId = :userId")
  List<Long> findTrackIdsDoneBy(@Param("userId") Long userId);
}
