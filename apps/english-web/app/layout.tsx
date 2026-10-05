import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'English Learning App',
  description: 'Luyện tiếng Anh toàn diện — Vocabulary, Grammar, Reading, Listening, Dictation',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="vi" suppressHydrationWarning>
      <body suppressHydrationWarning>{children}</body>
    </html>
  );
}
