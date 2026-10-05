export function sm2(
  quality: number,
  ef: number,
  interval: number,
  reps: number,
) {
  const q = Math.max(0, Math.min(5, quality));
  const newEf = Math.max(1.3, ef + 0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));

  let newInterval: number;
  let newReps: number;

  if (q < 3) {
    newInterval = 1;
    newReps = 0;
  } else {
    newReps = reps + 1;
    if (reps === 0) newInterval = 1;
    else if (reps === 1) newInterval = 6;
    else newInterval = Math.round(interval * newEf);
  }

  const nextReviewAt = new Date();
  nextReviewAt.setDate(nextReviewAt.getDate() + newInterval);

  return {
    easeFactor: newEf,
    interval: newInterval,
    repetitions: newReps,
    nextReviewAt,
  };
}
