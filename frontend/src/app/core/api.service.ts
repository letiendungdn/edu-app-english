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

@Injectable({ providedIn: 'root' })
export class ApiService {
  private http = inject(HttpClient);
  private base = 'http://localhost:8080/api';

  login(email: string, password: string) {
    return this.http.post<AuthResponse>(`${this.base}/auth/login`, { email, password });
  }

  register(email: string, password: string, name: string) {
    return this.http.post<AuthResponse>(`${this.base}/auth/register`, { email, password, name });
  }

  me() {
    return this.http.get<UserView>(`${this.base}/auth/me`);
  }

  studySocketUrl(token: string) {
    const httpOrigin = this.base.startsWith('http') ? this.base.replace(/\/api$/, '') : window.location.origin;
    const wsOrigin = httpOrigin.replace(/^http/, 'ws');
    return `${wsOrigin}/ws/study?token=${encodeURIComponent(token)}`;
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
}
