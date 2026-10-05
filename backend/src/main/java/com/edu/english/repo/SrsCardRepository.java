package com.edu.english.repo;

import com.edu.english.domain.Enums.ContentType;
import com.edu.english.domain.SrsCard;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SrsCardRepository extends JpaRepository<SrsCard, Long> {
  List<SrsCard> findByUserIdAndContentTypeAndNextReviewAtLessThanEqualOrderByNextReviewAtAsc(
      Long userId, ContentType contentType, Instant now);

  Optional<SrsCard> findByUserIdAndContentTypeAndContentId(
      Long userId, ContentType contentType, Long contentId);

  List<SrsCard> findByUserIdAndContentType(Long userId, ContentType contentType);

  long countByUserId(Long userId);

  long countByUserIdAndRepetitionsGreaterThanEqual(Long userId, int repetitions);
}
