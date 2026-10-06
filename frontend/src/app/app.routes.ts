import { Routes } from '@angular/router';
import { loginGuard, profileGuard } from './core/guards';
import { HomeComponent } from './pages/home.component';
import { AuthComponent } from './pages/auth.component';
import { VocabComponent } from './pages/vocab.component';
import { FlashcardComponent } from './pages/flashcard.component';
import { PictureComponent } from './pages/picture.component';
import { ReviewComponent } from './pages/review.component';
import { GrammarListComponent } from './pages/grammar-list.component';
import { GrammarDetailComponent } from './pages/grammar-detail.component';
import { ReadingListComponent } from './pages/reading-list.component';
import { ReadingDetailComponent } from './pages/reading-detail.component';
import { ListeningListComponent } from './pages/listening-list.component';
import { ListeningDetailComponent } from './pages/listening-detail.component';
import { DictationComponent } from './pages/dictation.component';
import { AnalyticsComponent } from './pages/analytics.component';

export const routes: Routes = [
  { path: '', component: HomeComponent },
  { path: 'login', component: AuthComponent },
  { path: 'vocab', component: VocabComponent },
  { path: 'vocab/flashcard', component: FlashcardComponent },
  { path: 'vocab/picture', component: PictureComponent },
  { path: 'vocab/review', component: ReviewComponent },
  { path: 'grammar', component: GrammarListComponent },
  { path: 'grammar/:id', component: GrammarDetailComponent },
  { path: 'reading', component: ReadingListComponent },
  { path: 'reading/:id', component: ReadingDetailComponent },
  { path: 'listening', component: ListeningListComponent },
  { path: 'listening/:id', component: ListeningDetailComponent },
  { path: 'dictation', component: DictationComponent },
  { path: 'analytics', component: AnalyticsComponent },

  // IELTS: tải khi cần.
  {
    path: 'onboarding',
    canActivate: [loginGuard],
    loadComponent: () => import('./pages/onboarding.component').then((m) => m.OnboardingComponent),
  },
  {
    path: 'roadmap',
    canActivate: [profileGuard],
    loadComponent: () => import('./pages/roadmap.component').then((m) => m.RoadmapComponent),
  },
  {
    path: 'placement',
    canActivate: [loginGuard],
    loadComponent: () => import('./pages/tests.component').then((m) => m.PlacementComponent),
  },
  { path: 'tests', loadComponent: () => import('./pages/tests.component').then((m) => m.TestsComponent) },
  {
    path: 'tests/attempt/:id',
    canActivate: [loginGuard],
    loadComponent: () => import('./pages/test-player.component').then((m) => m.TestPlayerComponent),
  },
  {
    path: 'tests/attempt/:id/result',
    canActivate: [loginGuard],
    loadComponent: () => import('./pages/test-result.component').then((m) => m.TestResultComponent),
  },
  { path: 'writing', loadComponent: () => import('./pages/writing.component').then((m) => m.WritingComponent) },
  {
    path: 'writing/submissions/:id',
    canActivate: [loginGuard],
    loadComponent: () => import('./pages/writing.component').then((m) => m.WritingSubmissionComponent),
  },
  {
    path: 'writing/:id',
    canActivate: [loginGuard],
    loadComponent: () => import('./pages/writing.component').then((m) => m.WritingEditorComponent),
  },
  { path: 'speaking', loadComponent: () => import('./pages/speaking.component').then((m) => m.SpeakingComponent) },
  {
    path: 'speaking/:id',
    canActivate: [loginGuard],
    loadComponent: () => import('./pages/speaking.component').then((m) => m.SpeakingPracticeComponent),
  },
  {
    path: 'history',
    canActivate: [loginGuard],
    loadComponent: () => import('./pages/history.component').then((m) => m.HistoryComponent),
  },
  { path: '**', redirectTo: '' },
];
