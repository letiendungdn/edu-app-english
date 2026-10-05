import { EnglishLevel } from "@edu/prisma-english/client";

const ENGLISH_LEVELS = new Set<string>(Object.values(EnglishLevel));

export function parseEnglishLevel(
  value: string | null | undefined,
): EnglishLevel | undefined {
  if (!value || !ENGLISH_LEVELS.has(value)) return undefined;
  return value as EnglishLevel;
}
