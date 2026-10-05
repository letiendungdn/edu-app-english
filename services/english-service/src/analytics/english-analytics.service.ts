import { Injectable } from "@nestjs/common";
import { EnglishPrismaService } from "@app/prisma-english";

@Injectable()
export class EnglishAnalyticsService {
  constructor(private readonly prisma: EnglishPrismaService) {}

  async getDashboard(userId: number) {
    const [
      totalCards,
      masteredCards,
      readingAttempts,
      listeningAttempts,
      dictationAttempts,
      studySessions,
    ] = await Promise.all([
      this.prisma.srsCard.count({ where: { userId } }),
      this.prisma.srsCard.count({
        where: { userId, repetitions: { gte: 3 } },
      }),
      this.prisma.readingAttempt.findMany({
        where: { userId },
        orderBy: { submittedAt: "asc" },
        select: {
          submittedAt: true,
          correct: true,
          total: true,
          percent: true,
        },
      }),
      this.prisma.listeningAttempt.findMany({
        where: { userId },
        orderBy: { submittedAt: "asc" },
        select: {
          submittedAt: true,
          correct: true,
          total: true,
          percent: true,
        },
      }),
      this.prisma.dictationAttempt.count({ where: { userId } }),
      this.prisma.studySession.findMany({
        where: { userId },
        orderBy: { date: "asc" },
        select: { date: true, seconds: true, cardsStudied: true },
      }),
    ]);

    const totalStudySeconds = studySessions.reduce((a, s) => a + s.seconds, 0);
    const daysStudied = studySessions.filter((s) => s.seconds > 0).length;

    return {
      overview: {
        totalCards,
        masteredCards,
        totalStudySeconds,
        daysStudied,
        dictationAttempts,
        readingAttempts: readingAttempts.length,
        listeningAttempts: listeningAttempts.length,
      },
      studySessions,
      readingHistory: readingAttempts.map((a) => ({
        date: a.submittedAt,
        percent: a.percent,
      })),
      listeningHistory: listeningAttempts.map((a) => ({
        date: a.submittedAt,
        percent: a.percent,
      })),
    };
  }
}
