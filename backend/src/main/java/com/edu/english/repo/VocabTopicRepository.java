package com.edu.english.repo;

import com.edu.english.domain.VocabTopic;
import org.springframework.data.jpa.repository.JpaRepository;

public interface VocabTopicRepository extends JpaRepository<VocabTopic, Long> {}
