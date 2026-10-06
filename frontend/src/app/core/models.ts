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

export interface OptionItem {
  key: string;
  text: string;
}

export interface QuestionItem {
  id: number;
  number: number;
  prompt: string;
  options: OptionItem[];
}

export type QuestionType =
  | 'MULTIPLE_CHOICE'
  | 'MULTIPLE_CHOICE_MULTI'
  | 'TRUE_FALSE_NOT_GIVEN'
  | 'YES_NO_NOT_GIVEN'
  | 'MATCHING_HEADINGS'
  | 'MATCHING_INFORMATION'
  | 'MATCHING_FEATURES'
  | 'MATCHING_SENTENCE_ENDINGS'
  | 'SENTENCE_COMPLETION'
  | 'SUMMARY_COMPLETION'
  | 'NOTE_COMPLETION'
  | 'TABLE_COMPLETION'
  | 'FLOW_CHART_COMPLETION'
  | 'DIAGRAM_LABEL'
  | 'SHORT_ANSWER'
  | 'FORM_COMPLETION'
  | 'MAP_LABELLING';

export interface QuestionGroupView {
  id: number;
  type: QuestionType;
  instruction: string;
  wordLimit?: number | null;
  imageUrl?: string | null;
  options: OptionItem[];
  questions: QuestionItem[];
}

export interface PassageListItem {
  id: number;
  title: string;
  level: string;
  module: string;
  topic?: string | null;
  bandMin?: number | null;
  bandMax?: number | null;
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
  groups: QuestionGroupView[];
}

export interface TrackListItem {
  id: number;
  title: string;
  level: string;
  durationSec?: number | null;
  youtubeUrl?: string | null;
  ieltsPart?: number | null;
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
  ieltsPart?: number | null;
  groups: QuestionGroupView[];
}

export interface AnswerResult {
  questionId: number;
  number: number;
  points: number;
  maxPoints: number;
  given?: string | null;
  correctAnswer: string;
  explanation?: string | null;
  evidence?: string | null;
}

export interface SubmitResult {
  percent: number;
  correct: number;
  total: number;
  estimatedBand?: number | null;
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
