package com.edu.english.repo;

import com.edu.english.domain.Enums.TestKind;
import com.edu.english.domain.IeltsTest;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface IeltsTestRepository extends JpaRepository<IeltsTest, Long> {
  List<IeltsTest> findByPublishedTrue();

  Optional<IeltsTest> findFirstByKindAndPublishedTrueOrderBySortOrderAsc(TestKind kind);
}
