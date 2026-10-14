package com.edu.english.repo;

import com.edu.english.domain.VocabTopic;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface VocabTopicRepository extends JpaRepository<VocabTopic, Long> {
  Optional<VocabTopic> findByName(String name);
}
