export type EnglishLevel = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2';

const ENGLISH_LEVELS = new Set<string>(['A1', 'A2', 'B1', 'B2', 'C1', 'C2']);

export function parseEnglishLevel(value: string | null | undefined): EnglishLevel | undefined {
  if (!value || !ENGLISH_LEVELS.has(value)) return undefined;
  return value as EnglishLevel;
}
