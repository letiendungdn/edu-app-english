import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import {
  AnalyticsView,
  AuthResponse,
  DictationWord,
  GrammarDetail,
  GrammarListItem,
  PassageDetail,
  PassageListItem,
  PicturePage,
  ReviewCard,
  SubmitResult,
  TrackDetail,
  TrackListItem,
  UserView,
  VocabPage,
} from './models';
import {
  AiStatus,
  AttemptResult,
  AttemptSummary,
  AttemptView,
  BandSummary,
  ProfileRequest,
  ProfileView,
  RoadmapView,
  SpeakingPromptView,
  SpeakingSubmissionView,
  TaskView,
  TestListItem,
  TodayView,
  WritingPromptView,
  WritingSubmissionView,
} from './ielts.models';

@Injectable({ providedIn: 'root' })
export class ApiService {
  private http = inject(HttpClient);
  /** Luôn cùng origin: ng serve chuyển /api qua proxy.conf.json, bản Docker qua Nginx. */
  private base = '/api';

  login(email: string, password: string) {
    return this.http.post<AuthResponse>(`${this.base}/auth/login`, { email, password });
  }

  register(email: string, password: string, name: string) {
    return this.http.post<AuthResponse>(`${this.base}/auth/register`, { email, password, name });
  }

  me() {
    return this.http.get<UserView>(`${this.base}/auth/me`);
  }

  vocab(level: string, page: number) {
    let params = new HttpParams().set('page', page).set('limit', 30);
    if (level) params = params.set('level', level);
    return this.http.get<VocabPage>(`${this.base}/vocab`, { params });
  }

  picture(level: string) {
    let params = new HttpParams().set('limit', 200);
    if (level) params = params.set('level', level);
    return this.http.get<PicturePage>(`${this.base}/vocab/picture`, { params });
  }

  review() {
    return this.http.get<ReviewCard[]>(`${this.base}/vocab/review`);
  }

  submitReview(vocabId: number, quality: number) {
    return this.http.post(`${this.base}/vocab/review`, { vocabId, quality });
  }

  grammar(level: string) {
    let params = new HttpParams();
    if (level) params = params.set('level', level);
    return this.http.get<GrammarListItem[]>(`${this.base}/grammar`, { params });
  }

  grammarTopic(id: number) {
    return this.http.get<GrammarDetail>(`${this.base}/grammar/${id}`);
  }

  reading(level: string) {
    let params = new HttpParams();
    if (level) params = params.set('level', level);
    return this.http.get<PassageListItem[]>(`${this.base}/reading`, { params });
  }

  readingDetail(id: number) {
    return this.http.get<PassageDetail>(`${this.base}/reading/${id}`);
  }

  submitReading(id: number, answers: Record<string, string>) {
    return this.http.post<SubmitResult>(`${this.base}/reading/${id}/submit`, { answers });
  }

  listening(level: string) {
    let params = new HttpParams();
    if (level) params = params.set('level', level);
    return this.http.get<TrackListItem[]>(`${this.base}/listening`, { params });
  }

  listeningDetail(id: number) {
    return this.http.get<TrackDetail>(`${this.base}/listening/${id}`);
  }

  submitListening(id: number, answers: Record<string, string>) {
    return this.http.post<SubmitResult>(`${this.base}/listening/${id}/submit`, { answers });
  }

  dictation(level: string) {
    return this.http.get<DictationWord[]>(`${this.base}/dictation`, {
      params: { level, limit: 20 },
    });
  }

  recordDictation(vocabId: number, userInput: string, correct: boolean) {
    return this.http.post(`${this.base}/dictation`, { vocabId, userInput, correct });
  }

  analytics() {
    return this.http.get<AnalyticsView>(`${this.base}/analytics`);
  }

  // IELTS: hồ sơ, band, lộ trình ----------------------------------------------

  profile() {
    return this.http.get<ProfileView>(`${this.base}/ielts/profile`);
  }

  saveProfile(body: ProfileRequest) {
    return this.http.put<ProfileView>(`${this.base}/ielts/profile`, body);
  }

  bands() {
    return this.http.get<BandSummary>(`${this.base}/ielts/bands`);
  }

  aiStatus() {
    return this.http.get<AiStatus>(`${this.base}/ielts/ai-status`);
  }

  roadmap() {
    return this.http.get<RoadmapView>(`${this.base}/roadmap`);
  }

  regenerateRoadmap() {
    return this.http.post<RoadmapView>(`${this.base}/roadmap/generate`, {});
  }

  today() {
    return this.http.get<TodayView>(`${this.base}/roadmap/today`);
  }

  updateTask(id: number, status: 'TODO' | 'DONE' | 'SKIPPED') {
    return this.http.patch<TaskView>(`${this.base}/roadmap/tasks/${id}`, { status });
  }

  // Bài thi -------------------------------------------------------------------

  tests() {
    return this.http.get<TestListItem[]>(`${this.base}/tests`);
  }

  startTest(id: number) {
    return this.http.post<AttemptView>(`${this.base}/tests/${id}/attempts`, {});
  }

  startPlacement() {
    return this.http.post<AttemptView>(`${this.base}/tests/placement/attempts`, {});
  }

  attempts() {
    return this.http.get<AttemptSummary[]>(`${this.base}/tests/attempts`);
  }

  attempt(id: number) {
    return this.http.get<AttemptView>(`${this.base}/tests/attempts/${id}`);
  }

  saveAttempt(id: number, answers: Record<string, string>, writingDrafts: Record<string, string>) {
    return this.http.patch(`${this.base}/tests/attempts/${id}`, { answers, writingDrafts });
  }

  submitAttempt(id: number, answers: Record<string, string>, writingDrafts: Record<string, string>) {
    return this.http.post<AttemptResult>(`${this.base}/tests/attempts/${id}/submit`, { answers, writingDrafts });
  }

  attemptResult(id: number) {
    return this.http.get<AttemptResult>(`${this.base}/tests/attempts/${id}/result`);
  }

  // Writing -------------------------------------------------------------------

  writingPrompts() {
    return this.http.get<WritingPromptView[]>(`${this.base}/writing/prompts`);
  }

  writingPrompt(id: number) {
    return this.http.get<WritingPromptView>(`${this.base}/writing/prompts/${id}`);
  }

  submitWriting(promptId: number, text: string, timeSpentSec: number) {
    return this.http.post<WritingSubmissionView>(`${this.base}/writing/submissions`, { promptId, text, timeSpentSec });
  }

  writingSubmissions() {
    return this.http.get<WritingSubmissionView[]>(`${this.base}/writing/submissions`);
  }

  writingSubmission(id: number) {
    return this.http.get<WritingSubmissionView>(`${this.base}/writing/submissions/${id}`);
  }

  regradeWriting(id: number) {
    return this.http.post<WritingSubmissionView>(`${this.base}/writing/submissions/${id}/regrade`, {});
  }

  // Speaking ------------------------------------------------------------------

  speakingPrompts() {
    return this.http.get<SpeakingPromptView[]>(`${this.base}/speaking/prompts`);
  }

  speakingPrompt(id: number) {
    return this.http.get<SpeakingPromptView>(`${this.base}/speaking/prompts/${id}`);
  }

  submitSpeaking(promptId: number, transcript: string, durationSec: number, audio: Blob | null) {
    const form = new FormData();
    form.append('promptId', String(promptId));
    form.append('transcript', transcript);
    form.append('durationSec', String(durationSec));
    if (audio) form.append('audio', audio, 'answer.webm');
    return this.http.post<SpeakingSubmissionView>(`${this.base}/speaking/submissions`, form);
  }

  speakingSubmissions() {
    return this.http.get<SpeakingSubmissionView[]>(`${this.base}/speaking/submissions`);
  }

  speakingSubmission(id: number) {
    return this.http.get<SpeakingSubmissionView>(`${this.base}/speaking/submissions/${id}`);
  }

  speakingAudio(id: number) {
    return this.http.get(`${this.base}/speaking/submissions/${id}/audio`, { responseType: 'blob' });
  }

  regradeSpeaking(id: number) {
    return this.http.post<SpeakingSubmissionView>(`${this.base}/speaking/submissions/${id}/regrade`, {});
  }
}
