package com.edu.english.config;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;
import java.util.Map;
import org.flywaydb.core.Flyway;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DriverManagerDataSource;

/** V3 chuyển câu hỏi trắc nghiệm cũ (đáp án lưu nguyên văn) sang bảng mới (đáp án là chữ cái). */
class QuestionMigrationTest {
  @Test
  void oldMultipleChoiceQuestionsMoveToQuestionBank() {
    DriverManagerDataSource ds =
        new DriverManagerDataSource("jdbc:h2:mem:migration;MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DB_CLOSE_DELAY=-1", "sa", "");
    Flyway.configure().dataSource(ds).locations("classpath:db/migration").target("2").load().migrate();

    JdbcTemplate jdbc = new JdbcTemplate(ds);
    jdbc.update(
        "insert into reading_passages (id, title, content, level, estimated_min, sort_order) values (1, 'Old', 'Text', 'A1', 3, 1)");
    jdbc.update("insert into reading_questions (id, passage_id, question, answer, sort_order) values (10, 1, 'Q one?', 'Blue', 1)");
    jdbc.update("insert into reading_questions (id, passage_id, question, answer, sort_order) values (11, 1, 'Q two?', 'Cat', 2)");
    jdbc.update("insert into reading_options (question_id, text, sort_order) values (10, 'Red', 1), (10, 'Blue', 2), (10, 'Green', 3)");
    jdbc.update("insert into reading_options (question_id, text, sort_order) values (11, 'Dog', 1), (11, 'Bird', 2), (11, 'Cat', 3)");

    Flyway.configure().dataSource(ds).locations("classpath:db/migration").load().migrate();

    List<Map<String, Object>> groups = jdbc.queryForList("select * from question_groups");
    assertThat(groups).hasSize(1);
    assertThat(groups.get(0).get("owner_type")).isEqualTo("READING_PASSAGE");
    assertThat(groups.get(0).get("question_type")).isEqualTo("MULTIPLE_CHOICE");

    List<Map<String, Object>> questions = jdbc.queryForList("select number, prompt, accepted_answers from questions order by number");
    assertThat(questions).extracting(q -> q.get("accepted_answers")).containsExactly("[\"B\"]", "[\"C\"]");
    assertThat(questions).extracting(q -> q.get("number")).containsExactly(1, 2);
    assertThat(jdbc.queryForObject("select count(*) from question_options", Integer.class)).isEqualTo(6);
    assertThat(jdbc.queryForObject(
            "select o.text from question_options o join questions q on q.id = o.question_id where q.number = 2 and o.option_key = 'C'",
            String.class))
        .isEqualTo("Cat");
  }
}
