package com.edu.english.repo;

import com.edu.english.domain.Enums.RoadmapStatus;
import com.edu.english.domain.Roadmap;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RoadmapRepository extends JpaRepository<Roadmap, Long> {
  Optional<Roadmap> findFirstByUserIdAndStatusOrderByIdDesc(Long userId, RoadmapStatus status);

  List<Roadmap> findByUserId(Long userId);
}
