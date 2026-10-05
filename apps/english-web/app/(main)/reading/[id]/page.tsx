'use client';

import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { useParams } from 'next/navigation';
import Link from 'next/link';
import type { PassageDetail, SubmitResult } from '@/lib/types';

export default function ReadingDetailPage() {
  const { id } = useParams<{ id: string }>();
  const [answers, setAnswers] = useState<Record<string, string>>({});
  const [result, setResult] = useState<SubmitResult | null>(null);
  const [submitting, setSubmitting] = useState(false);

  const { data: passage, isLoading } = useQuery<PassageDetail>({
    queryKey: ['reading-detail', id],
    queryFn: async () => {
      const res = await fetch(`/api/reading/${id}/submit`);
      return res.json();
    },
  });

  if (isLoading) return <div className="container" style={{ padding: '2rem' }}>Đang tải...</div>;
  if (!passage || passage.error) return <div className="container" style={{ padding: '2rem' }}>Không tìm thấy.</div>;

  const allAnswered = passage.questions?.every((q) => answers[q.id] !== undefined);

  async function submit() {
    if (!allAnswered) return;
    setSubmitting(true);
    try {
      const res = await fetch(`/api/reading/${id}/submit`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ answers }),
      });
      setResult(await res.json());
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="container" style={{ padding: '1.5rem 1rem', maxWidth: 760 }}>
      <Link href="/reading" style={{ color: 'var(--text-muted)', fontSize: '0.85rem' }}>← Đọc hiểu</Link>

      <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', margin: '1rem 0 0.25rem' }}>
        <span className={`badge badge-${passage.level}`}>{passage.level}</span>
        <span style={{ color: 'var(--text-muted)', fontSize: '0.8rem' }}>~{passage.estimatedMin} phút</span>
      </div>
      <h1 style={{ marginBottom: '1.25rem' }}>{passage.title}</h1>

      <div className="card" style={{ marginBottom: '2rem', lineHeight: 1.9, whiteSpace: 'pre-wrap', fontSize: '1.05rem' }}>
        {passage.content}
        {passage.source && <p style={{ marginTop: '1rem', fontSize: '0.78rem', color: 'var(--text-muted)' }}>Source: {passage.source}</p>}
      </div>

      {!result ? (
        <div>
          <h2 style={{ marginBottom: '1rem' }}>Câu hỏi ({passage.questions?.length})</h2>
          {passage.questions?.map((q, idx) => (
            <div key={q.id} className="card" style={{ marginBottom: '0.75rem' }}>
              <p style={{ fontWeight: 600, marginBottom: '0.6rem' }}>{idx + 1}. {q.question}</p>
              {q.options?.map((opt) => (
                <label key={opt.id} style={{
                  display: 'flex', alignItems: 'center', gap: '0.5rem', padding: '0.45rem 0.75rem',
                  borderRadius: 8, cursor: 'pointer', marginBottom: '0.35rem',
                  background: answers[q.id] === opt.text ? 'var(--accent-soft)' : 'transparent',
                  border: `1px solid ${answers[q.id] === opt.text ? 'var(--accent)' : 'var(--border)'}`,
                }}>
                  <input type="radio" name={`q-${q.id}`} checked={answers[q.id] === opt.text}
                    onChange={() => setAnswers((a) => ({ ...a, [q.id]: opt.text }))} />
                  {opt.text}
                </label>
              ))}
            </div>
          ))}
          <button className="btn btn-primary" disabled={!allAnswered || submitting} onClick={submit}>
            {submitting ? 'Đang chấm...' : 'Nộp bài'}
          </button>
        </div>
      ) : (
        <div>
          <div className="card" style={{ textAlign: 'center', padding: '2rem', marginBottom: '1.5rem', background: result.percent >= 60 ? 'rgba(34,197,94,0.1)' : 'rgba(239,68,68,0.1)' }}>
            <div style={{ fontSize: '3rem', fontWeight: 800 }}>{result.percent}%</div>
            <div style={{ marginTop: '0.25rem' }}>{result.correct}/{result.total} câu đúng</div>
          </div>
          {passage.questions?.map((q, idx) => {
            const r = result.results?.find((x) => x.questionId === q.id);
            return (
              <div key={q.id} className="card" style={{ marginBottom: '0.6rem', borderLeft: `4px solid ${r?.correct ? 'var(--success)' : 'var(--danger)'}` }}>
                <p style={{ fontWeight: 600, marginBottom: '0.3rem' }}>{idx + 1}. {q.question}</p>
                <p style={{ fontSize: '0.88rem', color: 'var(--text-muted)' }}>
                  Đáp án: <strong>{r?.correctAnswer}</strong>
                  {!r?.correct && <span style={{ color: 'var(--danger)' }}> · Bạn chọn: {answers[q.id]}</span>}
                </p>
                {r?.explanation && <p style={{ fontSize: '0.82rem', color: 'var(--text-muted)', marginTop: '0.2rem' }}>💡 {r.explanation}</p>}
              </div>
            );
          })}
          <button className="btn" onClick={() => { setAnswers({}); setResult(null); }}>Làm lại</button>
        </div>
      )}
    </div>
  );
}
