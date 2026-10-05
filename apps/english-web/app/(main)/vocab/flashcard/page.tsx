'use client';

import { useCallback, useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { useQuery } from '@tanstack/react-query';
import VocabPicture from '@/components/VocabPicture';
import type { VocabWord } from '@/lib/types';

const LEVELS = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'] as const;

async function fetchVocab(level?: string) {
  const params = new URLSearchParams({ limit: '500' });
  if (level) params.set('level', level);
  const res = await fetch(`/api/vocab?${params}`);
  return res.json() as Promise<{ words: VocabWord[]; total: number }>;
}

function shuffle<T>(items: T[]): T[] {
  const arr = [...items];
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}

function speakWord(word: string) {
  if (typeof window === 'undefined' || !window.speechSynthesis) return;
  window.speechSynthesis.cancel();
  const utterance = new SpeechSynthesisUtterance(word);
  utterance.lang = 'en-US';
  utterance.rate = 0.9;
  window.speechSynthesis.speak(utterance);
}

function FlashcardDeck({ words }: { words: VocabWord[] }) {
  const [index, setIndex] = useState(0);
  const [flipped, setFlipped] = useState(false);
  const current = words[index];

  const goNext = useCallback(() => {
    if (!words.length) return;
    setFlipped(false);
    setTimeout(() => setIndex((i) => (i + 1) % words.length), 150);
  }, [words.length]);

  const goPrev = useCallback(() => {
    if (!words.length) return;
    setFlipped(false);
    setTimeout(() => setIndex((i) => (i - 1 + words.length) % words.length), 150);
  }, [words.length]);

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.target instanceof HTMLInputElement || e.target instanceof HTMLTextAreaElement) return;
      if (e.key === ' ' || e.key === 'Enter') {
        e.preventDefault();
        setFlipped((f) => !f);
      } else if (e.key === 'ArrowRight') goNext();
      else if (e.key === 'ArrowLeft') goPrev();
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [goNext, goPrev]);

  useEffect(() => {
    if (current?.word) speakWord(current.word);
  }, [index, current?.word]);

  const handleSpeak = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (current) speakWord(current.word);
  };

  if (!current) return null;

  return (
    <>
      <p className="flashcard-progress">
        {index + 1} / {words.length}
      </p>

      <div className="flashcard-container">
        <div
          className={`flashcard${flipped ? ' flipped' : ''}`}
          onClick={() => setFlipped((f) => !f)}
          role="button"
          tabIndex={0}
          aria-label="Lật thẻ"
        >
          <div className="flashcard-face flashcard-front">
            <button type="button" className="btn-audio" onClick={handleSpeak} title="Nghe phát âm">
              🔊
            </button>
            <VocabPicture
              word={current.word}
              meaning={current.meaningVi}
              imageUrl={current.imageUrl}
              size="lg"
              className="flashcard-thumb"
              alt={current.word}
            />
            <span className={`badge badge-${current.level}`}>{current.level}</span>
            <span className="flashcard-word">{current.word}</span>
            {current.phonetic && <span className="flashcard-phonetic">{current.phonetic}</span>}
            {current.partOfSpeech && (
              <span className="flashcard-pos">{current.partOfSpeech}</span>
            )}
            <p className="flashcard-hint">Chạm hoặc Space để xem nghĩa</p>
          </div>

          <div className="flashcard-face flashcard-back">
            <button type="button" className="btn-audio" onClick={handleSpeak} title="Nghe phát âm">
              🔊
            </button>
            <span className="flashcard-meaning">{current.meaningVi}</span>
            {current.exampleEn && (
              <p className="flashcard-example">&ldquo;{current.exampleEn}&rdquo;</p>
            )}
            {current.exampleVi && <p className="flashcard-example-vi">→ {current.exampleVi}</p>}
            {current.topic && <span className="flashcard-topic">#{current.topic.name}</span>}
          </div>
        </div>
      </div>

      <div className="flashcard-controls">
        <button type="button" className="btn" onClick={goPrev}>
          ⬅️ Trước
        </button>
        <button type="button" className="btn btn-primary" onClick={() => setFlipped((f) => !f)}>
          {flipped ? 'Ẩn nghĩa' : 'Lật thẻ'}
        </button>
        <button type="button" className="btn" onClick={goNext}>
          Sau ➡️
        </button>
      </div>
    </>
  );
}

export default function FlashcardPage() {
  const [level, setLevel] = useState<string>('');
  const [shuffled, setShuffled] = useState(false);

  const { data, isLoading } = useQuery({
    queryKey: ['vocab-flashcard', level],
    queryFn: () => fetchVocab(level || undefined),
  });

  const words = useMemo(() => {
    const list = data?.words ?? [];
    return shuffled ? shuffle(list) : list;
  }, [data?.words, shuffled]);

  const deckKey = `${level}:${shuffled}:${data?.words?.length ?? 0}`;

  return (
    <div className="container flashcard-page">
      <div className="flashcard-header">
        <div>
          <h1>Flashcard</h1>
          <p className="flashcard-subtitle">
            {data ? `${words.length} từ` : 'Đang tải...'} · Space để lật · ← → chuyển thẻ
          </p>
        </div>
        <div className="flashcard-header-actions">
          <Link href="/vocab" className="btn">Danh sách</Link>
          <Link href="/vocab/review" className="btn btn-primary">SRS Review</Link>
        </div>
      </div>

      <div className="flashcard-filters">
        <button type="button" className={`btn${!level ? ' btn-primary' : ''}`} onClick={() => setLevel('')}>
          Tất cả
        </button>
        {LEVELS.map((l) => (
          <button
            key={l}
            type="button"
            className={`btn${level === l ? ' btn-primary' : ''}`}
            onClick={() => setLevel(l)}
          >
            {l}
          </button>
        ))}
        <button
          type="button"
          className={`btn${shuffled ? ' btn-primary' : ''}`}
          onClick={() => setShuffled((s) => !s)}
          style={{ marginLeft: 'auto' }}
        >
          {shuffled ? '🔀 Đang xáo' : '🔀 Xáo trộn'}
        </button>
      </div>

      {isLoading ? (
        <p style={{ color: 'var(--text-muted)', textAlign: 'center', padding: '3rem' }}>Đang tải...</p>
      ) : !words.length ? (
        <div className="card" style={{ textAlign: 'center', padding: '3rem', color: 'var(--text-muted)' }}>
          Chưa có từ vựng. Thêm data qua seeder hoặc chọn level khác.
        </div>
      ) : (
        <FlashcardDeck key={deckKey} words={words} />
      )}
    </div>
  );
}
