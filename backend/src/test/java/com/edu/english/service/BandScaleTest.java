package com.edu.english.service;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.Arrays;
import java.util.List;
import org.junit.jupiter.api.Test;

class BandScaleTest {
  private static final List<BandScale.Range> LISTENING =
      List.of(
          new BandScale.Range(39, 40, 9.0),
          new BandScale.Range(30, 31, 7.0),
          new BandScale.Range(26, 29, 6.5),
          new BandScale.Range(23, 25, 6.0),
          new BandScale.Range(0, 22, 5.0));

  @Test
  void overallRoundsQuartersUp() {
    assertThat(BandScale.roundOverall(6.25)).isEqualTo(6.5);
    assertThat(BandScale.roundOverall(6.75)).isEqualTo(7.0);
    assertThat(BandScale.roundOverall(6.125)).isEqualTo(6.0);
    assertThat(BandScale.roundOverall(6.375)).isEqualTo(6.5);
    assertThat(BandScale.roundOverall(6.625)).isEqualTo(6.5);
    assertThat(BandScale.roundOverall(7.0)).isEqualTo(7.0);
  }

  @Test
  void overallOfFourSkills() {
    // 6.5 + 6.5 + 5.0 + 7.0 = 25 / 4 = 6.25 → 6.5
    assertThat(BandScale.overall(List.of(6.5, 6.5, 5.0, 7.0))).isEqualTo(6.5);
    assertThat(BandScale.overall(Arrays.asList(6.0, null))).isEqualTo(6.0);
    assertThat(BandScale.overall(List.of())).isNull();
  }

  @Test
  void writingWeighsTaskTwoDouble() {
    // (5 + 2 * 6.5) / 3 = 6.0
    assertThat(BandScale.writing(5.0, 6.5)).isEqualTo(6.0);
    assertThat(BandScale.writing(null, 6.5)).isEqualTo(6.5);
    assertThat(BandScale.writing(null, null)).isNull();
  }

  @Test
  void rawScoreUsesTableAndScalesShortTests() {
    assertThat(BandScale.fromRaw(LISTENING, 30, 40)).isEqualTo(7.0);
    assertThat(BandScale.fromRaw(LISTENING, 40, 40)).isEqualTo(9.0);
    // 15/20 tương đương 30/40.
    assertThat(BandScale.fromRaw(LISTENING, 15, 20)).isEqualTo(7.0);
    assertThat(BandScale.fromRaw(LISTENING, 0, 0)).isZero();
  }

  @Test
  void criteriaAverage() {
    assertThat(BandScale.fromCriteria(6, 6, 7, 6)).isEqualTo(6.5);
    assertThat(BandScale.fromCriteria(6, 6, 6)).isEqualTo(6.0);
  }
}
