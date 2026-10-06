package com.edu.english.service;

import static org.assertj.core.api.Assertions.assertThat;

import com.edu.english.domain.Enums.QuestionType;
import java.util.List;
import org.junit.jupiter.api.Test;

class AnswerGraderTest {
  @Test
  void completionIgnoresCaseSpacesAndEdgePunctuation() {
    List<String> accepted = List.of("river bank");
    assertThat(grade(QuestionType.SENTENCE_COMPLETION, accepted, 2, "  River   Bank. ")).isEqualTo(1);
    assertThat(grade(QuestionType.SENTENCE_COMPLETION, accepted, 2, "riverbank")).isZero();
  }

  @Test
  void completionAcceptsAlternativesAndOptionalWords() {
    List<String> accepted = List.of("(the) town hall", "city hall");
    assertThat(grade(QuestionType.NOTE_COMPLETION, accepted, 3, "the town hall")).isEqualTo(1);
    assertThat(grade(QuestionType.NOTE_COMPLETION, accepted, 3, "town hall")).isEqualTo(1);
    assertThat(grade(QuestionType.NOTE_COMPLETION, accepted, 3, "City Hall")).isEqualTo(1);
  }

  @Test
  void completionOverWordLimitIsWrongEvenIfContentMatches() {
    List<String> accepted = List.of("(very) old bridge");
    assertThat(grade(QuestionType.SUMMARY_COMPLETION, accepted, 2, "old bridge")).isEqualTo(1);
    assertThat(grade(QuestionType.SUMMARY_COMPLETION, accepted, 2, "very old bridge")).isZero();
  }

  @Test
  void numbersIgnoreThousandsSeparatorAndPercentSpacing() {
    assertThat(grade(QuestionType.SHORT_ANSWER, List.of("1500"), 1, "1,500")).isEqualTo(1);
    assertThat(grade(QuestionType.TABLE_COMPLETION, List.of("20%"), 1, "20 %")).isEqualTo(1);
  }

  @Test
  void trueFalseNotGivenAcceptsShortFormsButNotYesNo() {
    List<String> notGiven = List.of("NOT GIVEN");
    assertThat(grade(QuestionType.TRUE_FALSE_NOT_GIVEN, notGiven, null, "NG")).isEqualTo(1);
    assertThat(grade(QuestionType.TRUE_FALSE_NOT_GIVEN, notGiven, null, "not given")).isEqualTo(1);
    assertThat(grade(QuestionType.TRUE_FALSE_NOT_GIVEN, List.of("TRUE"), null, "t")).isEqualTo(1);
    assertThat(grade(QuestionType.TRUE_FALSE_NOT_GIVEN, List.of("TRUE"), null, "YES")).isZero();
    assertThat(grade(QuestionType.YES_NO_NOT_GIVEN, List.of("NO"), null, "False")).isZero();
    assertThat(grade(QuestionType.YES_NO_NOT_GIVEN, List.of("NO"), null, "n")).isEqualTo(1);
  }

  @Test
  void letterAndRomanNumeralKeysAreCaseInsensitive() {
    assertThat(grade(QuestionType.MULTIPLE_CHOICE, List.of("B"), null, "b")).isEqualTo(1);
    assertThat(grade(QuestionType.MATCHING_HEADINGS, List.of("iv"), null, "IV")).isEqualTo(1);
    assertThat(grade(QuestionType.MATCHING_HEADINGS, List.of("iv"), null, "vi")).isZero();
  }

  @Test
  void chooseTwoScoresEachLetterAndPenalisesExtraChoices() {
    List<String> accepted = List.of("A", "D");
    assertThat(AnswerGrader.maxPoints(QuestionType.MULTIPLE_CHOICE_MULTI, accepted)).isEqualTo(2);
    assertThat(grade(QuestionType.MULTIPLE_CHOICE_MULTI, accepted, null, "D,A")).isEqualTo(2);
    assertThat(grade(QuestionType.MULTIPLE_CHOICE_MULTI, accepted, null, "a and c")).isEqualTo(1);
    assertThat(grade(QuestionType.MULTIPLE_CHOICE_MULTI, accepted, null, "AD")).isEqualTo(2);
    assertThat(grade(QuestionType.MULTIPLE_CHOICE_MULTI, accepted, null, "A,B,C,D")).isZero();
  }

  @Test
  void blankAnswerScoresZero() {
    assertThat(grade(QuestionType.SHORT_ANSWER, List.of("tea"), 1, "  ")).isZero();
    assertThat(grade(QuestionType.MULTIPLE_CHOICE, List.of("A"), null, null)).isZero();
  }

  private static int grade(QuestionType type, List<String> accepted, Integer limit, String given) {
    return AnswerGrader.grade(type, accepted, limit, given);
  }
}
