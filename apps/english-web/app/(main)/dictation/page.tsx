'use client';

import { useEffect, useRef, useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import type { DictationWord } from '@/lib/types';

function normalize(s: string) {
  return s.trim().toLowerCase().replace(/[.,!?'"]/g, '').replace(/\s+/g, ' ');
}

function speak(text: string) {
  if (typeof window === 'undefined') return;
  window.speechSynthesis.cancel();
  const u = new SpeechSynthesisUtterance(text);
  u.lang = 'en-US';
  u.rate = 0.8;
  window.speechSynthesis.speak(u);
}

const LEVELS = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

export default function DictationPage() {
  const [level, setLevel] = useState('A1');
  const [queue, setQueue] = useState<DictationWord[]>([]);
  const [index, setIndex] = useState(0);
  const [input, setInput] = useState('');
  const [feedback, setFeedback] = useState<'correct' | 'wrong' | null>(null);
  const [score, setScore] = useState({ correct: 0, total: 0 });
  const [revealed, setRevealed] = useState(false);
  const inputRef = useRef<HTMLInputElement>(null);

  const { isLoading, refetch } = useQuery<DictationWord[]>({
    queryKey: ['dictation-words', level],
    queryFn: async () => {
      const res = await fetch(`/api/dictation?level=${level}&limit=20`);
      return res.json();
    },
    enabled: false,
  });

  function startSession() {
    refetch().then(({ data }) => {
      if (!data?.length) return;
      const shuffled = [...data].sort(() => Math.random() - 0.5);
      setQueue(shuffled);
      setIndex(0);
      setScore({ correct: 0, total: 0 });
      setInput('');
      setFeedback(null);
      setRevealed(false);
      setTimeout(() => speak(shuffled[0].word), 300);
    });
  }

  const current = queue[index];
  const isDone = queue.length > 0 && index >= queue.length;

  useEffect(() => {
    if (!feedback && current) inputRef.current?.focus();
  }, [feedback, current, index]);

  function check() {
    if (!current || feedback) return;
    const correct = normalize(input) === normalize(current.word);
    setFeedback(correct ? 'correct' : 'wrong');
    setScore((s) => ({ correct: s.correct + (correct ? 1 : 0), total: s.total + 1 }));
    fetch('/api/dictation', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ vocabId: current.id, userInput: input, correct }),
    }).catch(() => {});
  }

  function next() {
    if (index + 1 >= queue.length) {
      setIndex(queue.length);
    } else {
      setIndex((i) => i + 1);
      setInput('');
      setFeedback(null);
      setRevealed(false);
      setTimeout(() => speak(queue[index + 1].word), 100);
    }
  }

  return (
    <div className="container" style={{ padding: '1.5rem 1rem', maxWidth: 600 }}>
      <h1 style={{ marginBottom: '0.25rem' }}>Nghe chép chính tả</h1>
      <p style={{ color: 'var(--text-muted)', marginBottom: '1.5rem' }}>Nghe từ tiếng Anh → gõ lại chính xác</p>

      {queue.length === 0 && (
        <div className="card">
          <label style={{ display: 'block', marginBottom: '0.5rem', fontWeight: 600 }}>Chọn cấp độ</label>
          <div style={{ display: 'flex', gap: '0.5rem', flexWrap: 'wrap', marginBottom: '1rem' }}>
            {LEVELS.map((l) => (
              <button key={l} className={`btn${level === l ? ' btn-primary' : ''}`} onClick={() => setLevel(l)}>{l}</button>
            ))}
          </div>
          <button className="btn btn-primary" style={{ width: '100%' }} onClick={startSession} disabled={isLoading}>
            Bắt đầu (20 từ)
          </button>
        </div>
      )}

      {isDone && (
        <div className="card" style={{ textAlign: 'center', padding: '2.5rem' }}>
          <div style={{ fontSize: '3rem', fontWeight: 800 }}>{Math.round((score.correct / score.total) * 100)}%</div>
          <div style={{ color: 'var(--text-muted)', margin: '0.5rem 0 1.5rem' }}>{score.correct}/{score.total} từ đúng</div>
          <button className="btn btn-primary" onClick={() => setQueue([])}>Luyện lại</button>
        </div>
      )}

      {current && !isDone && (
        <div>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '0.75rem', fontSize: '0.85rem', color: 'var(--text-muted)' }}>
            <span>{index + 1} / {queue.length}</span>
            <span>✅ {score.correct} ❌ {score.total - score.correct}</span>
          </div>

          <div className="card" style={{ textAlign: 'center', padding: '2rem', marginBottom: '1rem' }}>
            <button onClick={() => speak(current.word)} style={{ fontSize: '3rem', background: 'none', border: 'none', cursor: 'pointer', lineHeight: 1 }} title="Nghe lại">
              🔊
            </button>
            <div style={{ fontSize: '0.85rem', color: 'var(--text-muted)', marginTop: '0.5rem' }}>
              Nghĩa: <strong>{current.meaningVi}</strong>
            </div>
            {current.phonetic && !revealed && (
              <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)', marginTop: '0.25rem' }}>
                {current.phonetic}
              </div>
            )}
            {revealed && (
              <div style={{ marginTop: '0.75rem', fontSize: '1.4rem', fontWeight: 700, color: 'var(--accent)' }}>
                {current.word}
              </div>
            )}
            {current.exampleEn && revealed && (
              <div style={{ fontSize: '0.85rem', color: 'var(--text-muted)', marginTop: '0.25rem', fontStyle: 'italic' }}>
                &ldquo;{current.exampleEn}&rdquo;
              </div>
            )}
          </div>

          <input
            ref={inputRef}
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === 'Enter') {
                if (feedback) next();
                else check();
              }
            }}
            placeholder="Gõ từ bạn nghe được..."
            disabled={!!feedback}
            style={{
              marginBottom: '0.75rem', fontSize: '1.1rem', padding: '0.75rem 1rem',
              border: `2px solid ${feedback === 'correct' ? 'var(--success)' : feedback === 'wrong' ? 'var(--danger)' : 'var(--border)'}`,
            }}
          />

          {feedback && (
            <div style={{
              padding: '0.75rem 1rem', borderRadius: 10, marginBottom: '0.75rem', fontWeight: 600,
              background: feedback === 'correct' ? 'rgba(34,197,94,0.1)' : 'rgba(239,68,68,0.1)',
              color: feedback === 'correct' ? 'var(--success)' : 'var(--danger)',
            }}>
              {feedback === 'correct' ? '✅ Chính xác!' : `❌ Đáp án đúng: "${current.word}"`}
            </div>
          )}

          <div style={{ display: 'flex', gap: '0.5rem' }}>
            {!feedback && (
              <>
                <button className="btn btn-primary" style={{ flex: 1 }} disabled={!input.trim()} onClick={check}>Kiểm tra</button>
                <button className="btn" onClick={() => setRevealed(true)} disabled={revealed}>Gợi ý</button>
              </>
            )}
            {feedback && (
              <button className="btn btn-primary" style={{ flex: 1 }} onClick={next}>
                {index + 1 >= queue.length ? 'Xem kết quả' : 'Tiếp →'}
              </button>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
