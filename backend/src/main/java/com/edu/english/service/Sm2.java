package com.edu.english.service;

import com.edu.english.domain.SrsCard;

public final class Sm2 {
  private Sm2() {}

  public static void apply(SrsCard card, int quality) {
    int q = Math.max(0, Math.min(5, quality));
    double ef = card.getEaseFactor();
    double newEf = Math.max(1.3, ef + 0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
    int interval = card.getIntervalDays();
    int reps = card.getRepetitions();

    int newInterval;
    int newReps;
    if (q < 3) {
      newInterval = 1;
      newReps = 0;
      card.setWrongCount(card.getWrongCount() + 1);
      card.setReviewStreak(0);
      card.setMastered(false);
    } else {
      newReps = reps + 1;
      if (reps == 0) newInterval = 1;
      else if (reps == 1) newInterval = 6;
      else newInterval = (int) Math.round(interval * newEf);
      card.setCorrectCount(card.getCorrectCount() + 1);
      card.setReviewStreak(card.getReviewStreak() + 1);
      card.setMastered(newReps >= 3);
    }

    card.setEaseFactor(newEf);
    card.setIntervalDays(newInterval);
    card.setRepetitions(newReps);
    card.setNextReviewAt(java.time.Instant.now().plus(java.time.Duration.ofDays(newInterval)));
    card.setLastReviewAt(java.time.Instant.now());
  }
}
