package com.edu.english.repo;

import com.edu.english.domain.BandRecord;
import java.time.Instant;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BandRecordRepository extends JpaRepository<BandRecord, Long> {
  List<BandRecord> findByUserIdAndRecordedAtAfterOrderByRecordedAtDesc(Long userId, Instant after);

  List<BandRecord> findByUserIdOrderByRecordedAtAsc(Long userId);
}
