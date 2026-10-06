package com.edu.english.repo;

import com.edu.english.domain.Enums.OwnerType;
import com.edu.english.domain.QuestionGroup;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface QuestionGroupRepository extends JpaRepository<QuestionGroup, Long> {
  List<QuestionGroup> findByOwnerTypeAndOwnerIdOrderBySortOrderAsc(OwnerType ownerType, Long ownerId);

  @Query(
      "select g.ownerId, count(q) from QuestionGroup g join g.questions q"
          + " where g.ownerType = :ownerType group by g.ownerId")
  List<Object[]> countQuestionsByOwner(@Param("ownerType") OwnerType ownerType);
}
