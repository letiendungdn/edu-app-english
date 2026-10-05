export type EnglishLevel = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2';

export type VocabWord = {
  id: number;
  word: string;
  phonetic?: string | null;
  meaningVi: string;
  level: EnglishLevel | string;
  partOfSpeech?: string | null;
  exampleEn?: string | null;
  exampleVi?: string | null;
  imageUrl?: string | null;
  topic?: { name: string; icon?: string | null } | null;
  srs?: { nextReviewAt: string; repetitions: number } | null;
};

export type VocabListResponse = {
  total: number;
  page: number;
  limit: number;
  words: VocabWord[];
};

export type LevelContentItem = {
  id: number;
  level: EnglishLevel | string;
  title: string;
  description?: string | null;
  durationSec?: number | null;
  youtubeUrl?: string | null;
  estimatedMin?: number | null;
  source?: string | null;
  _count: { questions: number };
};

export type GrammarTopicListItem = {
  id: number;
  title: string;
  level: string;
  description?: string | null;
  _count: { lessons: number };
};

export type GrammarTopic = {
  id: number;
  title: string;
  level: string;
  description?: string | null;
};

export type GrammarExercise = {
  question: string;
  answer: string;
  options: string | string[];
  explanation?: string | null;
};

export type GrammarLesson = {
  title: string;
  explanation: string;
  examples?: string[];
  exercises?: GrammarExercise[];
};

export type GrammarExerciseItem = GrammarExercise & {
  id: number;
};

export type GrammarLessonItem = Omit<GrammarLesson, 'exercises'> & {
  id: number;
  exercises?: GrammarExerciseItem[];
};

export type GrammarTopicDetail = GrammarTopic & {
  lessons: GrammarLessonItem[];
};

export type QuestionOption = {
  id: number;
  text: string;
};

export type QuizQuestion = {
  id: number;
  question: string;
  options?: QuestionOption[];
};

export type TrackDetail = {
  id: number;
  level: string;
  title: string;
  durationSec?: number | null;
  youtubeUrl?: string | null;
  audioUrl?: string | null;
  transcript?: string | null;
  estimatedMin?: number | null;
  content?: string | null;
  source?: string | null;
  questions?: QuizQuestion[];
  error?: string;
};

export type PassageDetail = TrackDetail;

export type SubmitResult = {
  percent: number;
  correct: number;
  total: number;
  results?: { questionId: number; correct: boolean; correctAnswer: string; explanation?: string | null }[];
};

export type StudySession = {
  date: string;
  seconds: number;
};

export type ReadingHistoryItem = {
  date: string;
  percent: number;
};

export type AnalyticsData = {
  overview: {
    totalStudySeconds: number;
    daysStudied: number;
    masteredCards: number;
    totalCards: number;
    readingAttempts: number;
    listeningAttempts: number;
    dictationAttempts: number;
  };
  studySessions: StudySession[];
  readingHistory: ReadingHistoryItem[];
  listeningHistory: unknown[];
};

export type DictationWord = {
  id: number;
  word: string;
  meaningVi: string;
  phonetic?: string | null;
  exampleEn?: string | null;
};
