package com.edu.english.repo;

import com.edu.english.domain.Enums.TaskStatus;
import com.edu.english.domain.RoadmapTask;
import java.time.LocalDate;
import java.util.Collection;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RoadmapTaskRepository extends JpaRepository<RoadmapTask, Long> {
  List<RoadmapTask> findByRoadmapIdOrderByDueDateAscIdAsc(Long roadmapId);

  List<RoadmapTask> findByRoadmapIdAndDueDateOrderByIdAsc(Long roadmapId, LocalDate dueDate);

  List<RoadmapTask> findByRoadmapIdAndStatusAndDueDateBetweenOrderByDueDateAscIdAsc(
      Long roadmapId, TaskStatus status, LocalDate from, LocalDate to);

  long countByRoadmapIdAndStatusAndDueDateBefore(Long roadmapId, TaskStatus status, LocalDate before);

  long countByRoadmapIdInAndStatus(Collection<Long> roadmapIds, TaskStatus status);
}
