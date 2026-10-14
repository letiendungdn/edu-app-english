package com.edu.english.repo;

import com.edu.english.domain.Enums.EnglishLevel;
import com.edu.english.domain.Vocabulary;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface VocabularyRepository extends JpaRepository<Vocabulary, Long> {
  boolean existsByWordIgnoreCase(String word);

  Page<Vocabulary> findByLevel(EnglishLevel level, Pageable pageable);

  Page<Vocabulary> findByTopicName(String name, Pageable pageable);

  Page<Vocabulary> findByTopicNameAndLevel(String name, EnglishLevel level, Pageable pageable);

  /**
   * q đã được thoát ký tự % và _. Null nghĩa là không lọc chữ. Sắp từ khớp đầu từ lên trước.
   */
  @Query("""
      select v from Vocabulary v
      where (:level is null or v.level = :level)
        and (:topic is null or v.topic.name = :topic)
        and (:q is null
          or lower(v.word) like lower(concat('%', :q, '%')) escape '\\'
          or lower(v.meaningVi) like lower(concat('%', :q, '%')) escape '\\')
      order by
        case
          when :q is null then v.sortOrder
          when lower(v.word) like lower(concat(:q, '%')) escape '\\' then 0
          else 1
        end,
        case when :q is null then v.id else 0 end,
        v.word,
        v.id
      """)
  Page<Vocabulary> search(
      @Param("level") EnglishLevel level,
      @Param("topic") String topic,
      @Param("q") String q,
      Pageable pageable);

  /** Tên, icon, số từ của từng chủ đề, theo thứ tự hiển thị. */
  @Query("select t.name, t.icon, count(v) from Vocabulary v join v.topic t group by t.id, t.name, t.icon, t.sortOrder order by t.sortOrder")
  List<Object[]> countByTopic();

  List<Vocabulary> findByLevelOrderBySortOrderAscIdAsc(EnglishLevel level, Pageable pageable);

  List<Vocabulary> findAllByOrderBySortOrderAscIdAsc(Pageable pageable);
}
