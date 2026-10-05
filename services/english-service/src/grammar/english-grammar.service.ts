import { Injectable, NotFoundException } from "@nestjs/common";
import { EnglishPrismaService } from "@app/prisma-english";
import { parseEnglishLevel } from "../utils/english-level";

@Injectable()
export class EnglishGrammarService {
  constructor(private readonly prisma: EnglishPrismaService) {}

  listTopics(levelParam: string | undefined) {
    const level = parseEnglishLevel(levelParam);

    return this.prisma.grammarTopic.findMany({
      where: { level },
      include: { _count: { select: { lessons: true } } },
      orderBy: [{ level: "asc" }, { sortOrder: "asc" }],
    });
  }

  async getTopic(topicId: number) {
    const topic = await this.prisma.grammarTopic.findUnique({
      where: { id: topicId },
      include: {
        lessons: {
          orderBy: { sortOrder: "asc" },
          include: {
            exercises: {
              orderBy: { sortOrder: "asc" },
              include: {
                options: { orderBy: { sortOrder: "asc" } },
              },
            },
          },
        },
      },
    });

    if (!topic) {
      throw new NotFoundException("Not found");
    }

    return topic;
  }
}
