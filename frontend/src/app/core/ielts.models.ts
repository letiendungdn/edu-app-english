import { AnswerResult, QuestionGroupView } from './models';

export type Skill = 'LISTENING' | 'READING' | 'WRITING' | 'SPEAKING';

export interface ProfileRequest {
  module: 'ACADEMIC' | 'GENERAL';
  currentBand: number | null;
  targetBand: number;
  examDate: string | null;
  dailyMinutes: number;
  studyDaysPerWeek: number;
}

export interface ProfileView {
  module: 'ACADEMIC' | 'GENERAL';
  currentBand?: number | null;
  targetBand: number;
  examDate?: string | null;
  daysToExam?: number | null;
  dailyMinutes: number;
  studyDaysPerWeek: number;
  placementDone: boolean;
}

export interface BandPoint {
  skill: string;
  band: number;
  source: string;
  at: string;
}

export interface BandSummary {
  listening?: number | null;
  reading?: number | null;
  writing?: number | null;
  speaking?: number | null;
  overall?: number | null;
  target?: number | null;
  history: BandPoint[];
}

export interface PhaseView {
  id: number;
  kind: 'FOUNDATION' | 'SKILL_BUILDING' | 'EXAM_PRACTICE' | 'FINAL_REVIEW';
  startDate: string;
  endDate: string;
  goal: string;
}

export interface TaskView {
  id: number;
  dueDate: string;
  type: string;
  skill?: Skill | null;
  title: string;
  estimatedMin: number;
  status: 'TODO' | 'DONE' | 'SKIPPED';
  link: string;
}

export interface RoadmapView {
  id: number;
  version: number;
  startDate: string;
  endDate: string;
  examDate?: string | null;
  startBand?: number | null;
  targetBand: number;
  feasibility: 'ON_TRACK' | 'TIGHT' | 'AT_RISK';
  tasksDone: number;
  tasksTotal: number;
  phases: PhaseView[];
  tasks: TaskView[];
}

export interface TodayView {
  date: string;
  daysToExam?: number | null;
  feasibility: string;
  phase?: string | null;
  phaseGoal?: string | null;
  minutesPlanned: number;
  minutesDone: number;
  tasks: TaskView[];
  overdue: TaskView[];
  dueCards: number;
  streakDays: number;
  bands: BandSummary;
}

export interface AttemptSummary {
  id: number;
  status: 'IN_PROGRESS' | 'SUBMITTED';
  startedAt: string;
  submittedAt?: string | null;
  bandListening?: number | null;
  bandReading?: number | null;
  bandWriting?: number | null;
  bandOverall?: number | null;
}

export interface TestListItem {
  id: number;
  kind: 'PLACEMENT' | 'MOCK' | 'SECTION';
  module: string;
  title: string;
  description?: string | null;
  durationMin: number;
  skills: string[];
  lastAttempt?: AttemptSummary | null;
}

export interface WritingPromptView {
  id: number;
  module: string;
  task: 'TASK1' | 'TASK2';
  taskKind: string;
  title: string;
  prompt: string;
  chartData?: string | null;
  imageUrl?: string | null;
  minWords: number;
  topic?: string | null;
  attempted: boolean;
}

export interface SectionView {
  skill: Skill;
  refType: string;
  refId: number;
  title: string;
  body?: string | null;
  audioUrl?: string | null;
  ttsScript?: string | null;
  groups: QuestionGroupView[];
  writing?: WritingPromptView | null;
}

export interface AttemptView {
  id: number;
  testId: number;
  title: string;
  kind: string;
  status: 'IN_PROGRESS' | 'SUBMITTED';
  startedAt: string;
  deadline: string;
  durationMin: number;
  sections: SectionView[];
  answers: Record<string, string>;
  writingDrafts: Record<string, string>;
}

export interface SkillScore {
  raw?: number | null;
  total?: number | null;
  band?: number | null;
}

export interface SectionResult {
  skill: Skill;
  title: string;
  results: AnswerResult[];
}

export interface Correction {
  original: string;
  suggestion: string;
  reason: string;
}

export interface Feedback {
  summary: string;
  strengths: string[];
  improvements: string[];
  corrections: Correction[];
}

export interface CriterionScore {
  code: string;
  name: string;
  score?: number | null;
}

export type SubmissionStatus = 'PENDING' | 'GRADED' | 'FAILED';

export interface WritingSubmissionView {
  id: number;
  promptId: number;
  promptTitle?: string | null;
  task?: string | null;
  text: string;
  wordCount: number;
  timeSpentSec?: number | null;
  status: SubmissionStatus;
  criteria: CriterionScore[];
  band?: number | null;
  feedback?: Feedback | null;
  error?: string | null;
  createdAt: string;
  gradedAt?: string | null;
}

export interface AttemptResult {
  id: number;
  testId: number;
  title: string;
  kind: string;
  status: string;
  submittedAt?: string | null;
  listening?: SkillScore | null;
  reading?: SkillScore | null;
  bandWriting?: number | null;
  bandSpeaking?: number | null;
  bandOverall?: number | null;
  sections: SectionResult[];
  writing: WritingSubmissionView[];
}

export interface SpeakingPromptView {
  id: number;
  part: number;
  topic: string;
  question: string;
  cueCardPoints: string[];
  attempted: boolean;
}

export interface SpeakingSubmissionView {
  id: number;
  promptId: number;
  part: number;
  question?: string | null;
  transcript?: string | null;
  durationSec?: number | null;
  hasAudio: boolean;
  status: SubmissionStatus;
  criteria: CriterionScore[];
  band?: number | null;
  feedback?: Feedback | null;
  error?: string | null;
  createdAt: string;
  gradedAt?: string | null;
}

export interface AiStatus {
  enabled: boolean;
  model: string;
  dailyLimit: number;
  usedToday: number;
}

/** Biểu đồ Writing Task 1 do backend gửi dạng JSON. */
export interface ChartData {
  type: 'line' | 'bar' | 'pie' | 'table' | 'process' | 'map';
  unit?: string;
  labels?: string[];
  series?: { name: string; values: number[] }[];
  steps?: string[];
  before?: string[];
  after?: string[];
}

export const SKILL_LABELS: Record<string, string> = {
  LISTENING: 'Listening',
  READING: 'Reading',
  WRITING: 'Writing',
  SPEAKING: 'Speaking',
  OVERALL: 'Overall',
};

export const PHASE_LABELS: Record<string, string> = {
  FOUNDATION: 'Nền tảng',
  SKILL_BUILDING: 'Luyện kỹ năng',
  EXAM_PRACTICE: 'Luyện đề',
  FINAL_REVIEW: 'Ôn cuối',
};

export const FEASIBILITY_LABELS: Record<string, string> = {
  ON_TRACK: 'Kịp mục tiêu',
  TIGHT: 'Hơi gấp',
  AT_RISK: 'Khó kịp',
};

export const BANDS = [3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9];

export function band(value: number | null | undefined): string {
  return value == null ? '–' : value.toFixed(1);
}
