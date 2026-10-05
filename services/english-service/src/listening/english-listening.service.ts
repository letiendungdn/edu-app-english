import { Injectable, NotFoundException } from "@nestjs/common";
import { EnglishPrismaService } from "@app/prisma-english";
import { parseEnglishLevel } from "../utils/english-level";
import type { EnglishUserPayload } from "../auth/english-current-user.decorator";

@Injectable()
export class EnglishListeningService {
  constructor(private readonly prisma: EnglishPrismaService) {}

  listTracks(levelParam: string | undefined) {
    const level = parseEnglishLevel(levelParam);

    return this.prisma.listeningTrack.findMany({
      where: { level },
      include: { _count: { select: { questions: true } } },
      orderBy: [{ level: "asc" }, { sortOrder: "asc" }],
    });
  }

  async getTrackForSubmit(trackId: number) {
    const track = await this.prisma.listeningTrack.findUnique({
      where: { id: trackId },
      include: {
        questions: {
          orderBy: { sortOrder: "asc" },
          include: { options: { orderBy: { sortOrder: "asc" } } },
        },
      },
    });

    if (!track) {
      throw new NotFoundException("Not found");
    }

    return track;
  }

  async submitAnswers(
    trackId: number,
    answers: Record<string, string>,
    user: EnglishUserPayload | null | undefined,
  ) {
    const questions = await this.prisma.listeningQuestion.findMany({
      where: { trackId },
    });

    const results = questions.map((q) => ({
      questionId: q.id,
      correct: answers[String(q.id)] === q.answer,
      correctAnswer: q.answer,
      explanation: q.explanation,
    }));

    const correct = results.filter((r) => r.correct).length;
    const total = questions.length;
    const percent = total > 0 ? Math.round((correct / total) * 100) : 0;

    if (user) {
      await this.prisma.listeningAttempt.create({
        data: {
          userId: user.id,
          trackId,
          correct,
          total,
          percent,
        },
      });
    }

    return { correct, total, percent, results };
  }
}
