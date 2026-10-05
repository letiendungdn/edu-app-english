import { Injectable } from "@nestjs/common";
import { EnglishPrismaService } from "@app/prisma-english";
import { parseEnglishLevel } from "../utils/english-level";
import type { EnglishUserPayload } from "../auth/english-current-user.decorator";

@Injectable()
export class EnglishDictationService {
  constructor(private readonly prisma: EnglishPrismaService) {}

  listWords(
    levelParam: string | undefined,
    topicIdParam: string | undefined,
    limitParam: string | undefined,
  ) {
    const level = parseEnglishLevel(levelParam);
    const topicId = topicIdParam ? +topicIdParam : undefined;
    const limit = +(limitParam ?? 20);

    return this.prisma.vocabulary.findMany({
      where: { level, topicId },
      select: {
        id: true,
        word: true,
        phonetic: true,
        meaningVi: true,
        exampleEn: true,
      },
      orderBy: { sortOrder: "asc" },
      take: limit,
    });
  }

  recordAttempt(
    vocabId: number,
    userInput: string,
    correct: boolean,
    user: EnglishUserPayload | null | undefined,
  ) {
    return this.prisma.dictationAttempt.create({
      data: {
        vocabId,
        userInput,
        correct,
        userId: user?.id ?? null,
      },
    });
  }
}
