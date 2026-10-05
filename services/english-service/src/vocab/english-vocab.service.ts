import { Injectable } from "@nestjs/common";
import { ContentType } from "@edu/prisma-english/client";
import { resolveVocabImage } from "@edu/vocab-images";
import { EnglishPrismaService } from "@app/prisma-english";
import { parseEnglishLevel } from "../utils/english-level";
import { sm2 } from "../utils/sm2";
import type { EnglishUserPayload } from "../auth/english-current-user.decorator";

@Injectable()
export class EnglishVocabService {
  constructor(private readonly prisma: EnglishPrismaService) {}

  async list(
    levelParam: string | undefined,
    topicIdParam: string | undefined,
    pageParam: string | undefined,
    limitParam: string | undefined,
    user: EnglishUserPayload | null | undefined,
  ) {
    const level = parseEnglishLevel(levelParam);
    const topicId = topicIdParam ? +topicIdParam : undefined;
    const page = +(pageParam ?? 1);
    const limit = +(limitParam ?? 30);

    const [total, words] = await Promise.all([
      this.prisma.vocabulary.count({ where: { level, topicId } }),
      this.prisma.vocabulary.findMany({
        where: { level, topicId },
        include: { topic: { select: { name: true } } },
        orderBy: [{ sortOrder: "asc" }, { id: "asc" }],
        skip: (page - 1) * limit,
        take: limit,
      }),
    ]);

    let srsMap: Record<number, { nextReviewAt: Date; repetitions: number }> =
      {};
    if (user) {
      const cards = await this.prisma.srsCard.findMany({
        where: { userId: user.id, contentType: ContentType.VOCABULARY },
        select: { contentId: true, nextReviewAt: true, repetitions: true },
      });
      srsMap = Object.fromEntries(
        cards.map((c) => [
          c.contentId,
          { nextReviewAt: c.nextReviewAt, repetitions: c.repetitions },
        ]),
      );
    }

    return {
      total,
      page,
      limit,
      words: words.map((w) => ({ ...w, srs: srsMap[w.id] ?? null })),
    };
  }

  async picture(
    levelParam: string | undefined,
    topicIdParam: string | undefined,
    picturesOnlyParam: string | undefined,
    limitParam: string | undefined,
  ) {
    const level = parseEnglishLevel(levelParam);
    const topicId = topicIdParam ? +topicIdParam : undefined;
    const picturesOnly = picturesOnlyParam === "true";
    const limit = +(limitParam ?? 200);

    const words = await this.prisma.vocabulary.findMany({
      where: { level, topicId },
      include: { topic: { select: { name: true, icon: true } } },
      orderBy: [{ sortOrder: "asc" }, { id: "asc" }],
      take: limit,
    });

    const items = words
      .map((w) => ({
        id: w.id,
        word: w.word,
        phonetic: w.phonetic,
        meaningVi: w.meaningVi,
        level: w.level,
        partOfSpeech: w.partOfSpeech,
        exampleEn: w.exampleEn,
        topic: w.topic,
        imageUrl: resolveVocabImage({
          word: w.word,
          meaning: w.meaningVi,
          imageUrl: w.imageUrl,
        }),
      }))
      .filter((w) => (picturesOnly ? w.imageUrl : true));

    return { total: items.length, items };
  }

  async getReviewQueue(userId: number) {
    const cards = await this.prisma.srsCard.findMany({
      where: {
        userId,
        contentType: ContentType.VOCABULARY,
        nextReviewAt: { lte: new Date() },
      },
      orderBy: { nextReviewAt: "asc" },
      take: 20,
    });

    const vocabIds = cards.map((c) => c.contentId);
    const vocabs = await this.prisma.vocabulary.findMany({
      where: { id: { in: vocabIds } },
    });
    const vocabMap = Object.fromEntries(vocabs.map((v) => [v.id, v]));

    return cards.map((c) => ({
      ...c,
      vocab: vocabMap[c.contentId] ?? null,
    }));
  }

  async submitReview(userId: number, vocabId: number, quality: number) {
    const existing = await this.prisma.srsCard.findUnique({
      where: {
        userId_contentType_contentId: {
          userId,
          contentType: ContentType.VOCABULARY,
          contentId: vocabId,
        },
      },
    });

    const ef = existing?.easeFactor ?? 2.5;
    const interval = existing?.interval ?? 0;
    const reps = existing?.repetitions ?? 0;

    const result = sm2(quality, ef, interval, reps);

    return this.prisma.srsCard.upsert({
      where: {
        userId_contentType_contentId: {
          userId,
          contentType: ContentType.VOCABULARY,
          contentId: vocabId,
        },
      },
      create: {
        userId,
        contentType: ContentType.VOCABULARY,
        contentId: vocabId,
        ...result,
        lastReviewAt: new Date(),
      },
      update: { ...result, lastReviewAt: new Date() },
    });
  }
}
