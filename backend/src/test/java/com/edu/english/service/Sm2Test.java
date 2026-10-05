package com.edu.english.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.within;

import com.edu.english.domain.SrsCard;
import java.time.Duration;
import java.time.Instant;
import org.junit.jupiter.api.Test;

class Sm2Test {
  @Test
  void firstSuccessSetsIntervalToOneDay() {
    SrsCard card = newCard();
    Instant before = Instant.now();

    Sm2.apply(card, 5);

    assertThat(card.getEaseFactor()).isCloseTo(2.6, within(0.0001));
    assertThat(card.getIntervalDays()).isEqualTo(1);
    assertThat(card.getRepetitions()).isEqualTo(1);
    assertThat(card.getCorrectCount()).isEqualTo(1);
    assertThat(card.getWrongCount()).isZero();
    assertThat(card.getReviewStreak()).isEqualTo(1);
    assertThat(card.isMastered()).isFalse();
    assertThat(card.getNextReviewAt()).isAfterOrEqualTo(before.plus(Duration.ofDays(1)).minusSeconds(2));
    assertThat(card.getLastReviewAt()).isAfterOrEqualTo(before.minusSeconds(2));
  }

  @Test
  void secondAndThirdSuccessFollowSm2Intervals() {
    SrsCard card = newCard();
    Sm2.apply(card, 5);
    Sm2.apply(card, 4);

    assertThat(card.getRepetitions()).isEqualTo(2);
    assertThat(card.getIntervalDays()).isEqualTo(6);
    assertThat(card.getEaseFactor()).isCloseTo(2.6, within(0.0001));
    assertThat(card.isMastered()).isFalse();

    Sm2.apply(card, 5);
    assertThat(card.getRepetitions()).isEqualTo(3);
    assertThat(card.getIntervalDays()).isEqualTo(16);
    assertThat(card.getEaseFactor()).isCloseTo(2.7, within(0.0001));
    assertThat(card.isMastered()).isTrue();
  }

  @Test
  void qualityBelowThreeResetsRepetitionsAndLowersEase() {
    SrsCard card = newCard();
    Sm2.apply(card, 5);
    Sm2.apply(card, 5);
    double easeBeforeFail = card.getEaseFactor();

    Sm2.apply(card, 2);

    assertThat(card.getIntervalDays()).isEqualTo(1);
    assertThat(card.getRepetitions()).isZero();
    assertThat(card.getWrongCount()).isEqualTo(1);
    assertThat(card.getCorrectCount()).isEqualTo(2);
    assertThat(card.getReviewStreak()).isZero();
    assertThat(card.isMastered()).isFalse();
    assertThat(card.getEaseFactor()).isCloseTo(easeBeforeFail - 0.32, within(0.0001));
  }

  @Test
  void qualityIsClampedToZeroThroughFive() {
    SrsCard high = newCard();
    SrsCard five = newCard();
    Sm2.apply(high, 99);
    Sm2.apply(five, 5);
    assertThat(high.getEaseFactor()).isCloseTo(five.getEaseFactor(), within(0.0001));
    assertThat(high.getIntervalDays()).isEqualTo(five.getIntervalDays());

    SrsCard low = newCard();
    SrsCard zero = newCard();
    Sm2.apply(low, -3);
    Sm2.apply(zero, 0);
    assertThat(low.getEaseFactor()).isCloseTo(1.7, within(0.0001));
    assertThat(low.getEaseFactor()).isCloseTo(zero.getEaseFactor(), within(0.0001));
    assertThat(low.getRepetitions()).isZero();
    assertThat(low.getIntervalDays()).isEqualTo(1);
  }

  @Test
  void easeFactorDoesNotDropBelowMinimum() {
    SrsCard card = newCard();
    card.setEaseFactor(1.3);
    Sm2.apply(card, 0);
    assertThat(card.getEaseFactor()).isEqualTo(1.3);
  }

  private static SrsCard newCard() {
    return new SrsCard();
  }
}
