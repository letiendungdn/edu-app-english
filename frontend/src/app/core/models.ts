export interface UserView {
  id: number;
  email: string;
  name?: string | null;
  role: string;
}

export interface AuthResponse {
  user: UserView;
  token: string;
}

export interface TopicView {
  name: string;
  icon?: string | null;
}

export interface VocabWord {
  id: number;
  word: string;
  phonetic?: string | null;
  meaningVi: string;
  level: string;
  partOfSpeech?: string | null;
  exampleEn?: string | null;
  exampleVi?: string | null;
  imageUrl?: string | null;
  topic?: TopicView | null;
}

export interface VocabPage {
  total: number;
  page: number;
  limit: number;
  words: VocabWord[];
}

export interface PicturePage {
  total: number;
  items: VocabWord[];
}

export interface ReviewCard {
  id: number;
  vocab: VocabWord;
}

export interface GrammarListItem {
  id: number;
  title: string;
  level: string;
  description?: string | null;
  lessonCount: number;
}

export interface ExerciseView {
  id: number;
  question: string;
  answer: string;
  explanation?: string | null;
  options: string[];
}

export interface LessonView {
  id: number;
  title: string;
  explanation: string;
  examples: string[];
  exercises: ExerciseView[];
}

export interface GrammarDetail {
  id: number;
  title: string;
  level: string;
  description?: string | null;
  lessons: LessonView[];
}

export interface OptionView {
  id: number;
  text: string;
}

export interface QuestionView {
  id: number;
  question: string;
  options: OptionView[];
}

export interface PassageListItem {
  id: number;
  title: string;
  level: string;
  estimatedMin?: number | null;
  source?: string | null;
  questionCount: number;
}

export interface PassageDetail {
  id: number;
  title: string;
  level: string;
  estimatedMin?: number | null;
  source?: string | null;
  content: string;
  questions: QuestionView[];
}

export interface TrackListItem {
  id: number;
  title: string;
  level: string;
  durationSec?: number | null;
  youtubeUrl?: string | null;
  questionCount: number;
}

export interface TrackDetail {
  id: number;
  title: string;
  level: string;
  durationSec?: number | null;
  youtubeUrl?: string | null;
  audioUrl?: string | null;
  transcript?: string | null;
  questions: QuestionView[];
}

export interface AnswerResult {
  questionId: number;
  correct: boolean;
  correctAnswer: string;
  explanation?: string | null;
}

export interface SubmitResult {
  percent: number;
  correct: number;
  total: number;
  results: AnswerResult[];
}

export interface DictationWord {
  id: number;
  word: string;
  phonetic?: string | null;
  meaningVi: string;
  exampleEn?: string | null;
}

export interface Overview {
  totalStudySeconds: number;
  daysStudied: number;
  masteredCards: number;
  totalCards: number;
  readingAttempts: number;
  listeningAttempts: number;
  dictationAttempts: number;
}

export interface AnalyticsView {
  overview: Overview;
  studySessions: { date: string; seconds: number }[];
  readingHistory: { date: string; percent: number }[];
  listeningHistory: { date: string; percent: number }[];
}

export const LEVELS = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
