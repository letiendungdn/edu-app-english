import { Injectable, NotFoundException } from "@nestjs/common";
import { EnglishPrismaService } from "@app/prisma-english";
import { parseEnglishLevel } from "../utils/english-level";
import type { EnglishUserPayload } from "../auth/english-current-user.decorator";

@Injectable()
export class EnglishReadingService {
  constructor(private readonly prisma: EnglishPrismaService) {}

  listPassages(levelParam: string | undefined) {
    const level = parseEnglishLevel(levelParam);

    return this.prisma.readingPassage.findMany({
      where: { level },
      include: { _count: { select: { questions: true } } },
      orderBy: [{ level: "asc" }, { sortOrder: "asc" }],
    });
  }

  async getPassageForSubmit(passageId: number) {
    const passage = await this.prisma.readingPassage.findUnique({
      where: { id: passageId },
      include: {
        questions: {
          orderBy: { sortOrder: "asc" },
          include: { options: { orderBy: { sortOrder: "asc" } } },
        },
      },
    });

    if (!passage) {
      throw new NotFoundException("Not found");
    }

    return passage;
  }

  async submitAnswers(
    passageId: number,
    answers: Record<string, string>,
    user: EnglishUserPayload | null | undefined,
  ) {
    const questions = await this.prisma.readingQuestion.findMany({
      where: { passageId },
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
      await this.prisma.readingAttempt.create({
        data: {
          userId: user.id,
          passageId,
          correct,
          total,
          percent,
        },
      });
    }

    return { correct, total, percent, results };
  }
}
