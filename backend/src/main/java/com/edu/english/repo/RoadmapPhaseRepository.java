package com.edu.english.repo;

import com.edu.english.domain.RoadmapPhase;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RoadmapPhaseRepository extends JpaRepository<RoadmapPhase, Long> {
  List<RoadmapPhase> findByRoadmapIdOrderBySortOrderAsc(Long roadmapId);
}
