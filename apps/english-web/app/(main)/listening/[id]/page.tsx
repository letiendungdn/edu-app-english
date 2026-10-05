'use client';

import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { useParams } from 'next/navigation';
import Link from 'next/link';
import type { SubmitResult, TrackDetail } from '@/lib/types';

function getYoutubeEmbed(url: string) {
  const m = url.match(/(?:v=|youtu\.be\/)([A-Za-z0-9_-]{11})/);
  return m ? `https://www.youtube.com/embed/${m[1]}` : null;
}

export default function ListeningDetailPage() {
  const { id } = useParams<{ id: string }>();
  const [answers, setAnswers] = useState<Record<string, string>>({});
  const [result, setResult] = useState<SubmitResult | null>(null);
  const [showTranscript, setShowTranscript] = useState(false);
  const [submitting, setSubmitting] = useState(false);

  const { data: track, isLoading } = useQuery<TrackDetail>({
    queryKey: ['listening-detail', id],
    queryFn: async () => {
      const res = await fetch(`/api/listening/${id}/submit`);
      return res.json();
    },
  });

  if (isLoading) return <div className="container" style={{ padding: '2rem' }}>Đang tải...</div>;
  if (!track || track.error) return <div className="container" style={{ padding: '2rem' }}>Không tìm thấy.</div>;

  const allAnswered = track.questions?.every((q) => answers[q.id] !== undefined);
  const embedUrl = track.youtubeUrl ? getYoutubeEmbed(track.youtubeUrl) : null;

  async function submit() {
    if (!allAnswered) return;
    setSubmitting(true);
    try {
      const res = await fetch(`/api/listening/${id}/submit`, {
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
    <div className="container" style={{ padding: '1.5rem 1rem', maxWidth: 800 }}>
      <Link href="/listening" style={{ color: 'var(--text-muted)', fontSize: '0.85rem' }}>← Luyện nghe</Link>

      <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', margin: '1rem 0 0.25rem' }}>
        <span className={`badge badge-${track.level}`}>{track.level}</span>
        {track.durationSec && <span style={{ color: 'var(--text-muted)', fontSize: '0.8rem' }}>{Math.round(track.durationSec / 60)} phút</span>}
      </div>
      <h1 style={{ marginBottom: '1.25rem' }}>{track.title}</h1>

      {/* Player */}
      {embedUrl ? (
        <div style={{ position: 'relative', paddingBottom: '56.25%', height: 0, marginBottom: '1.5rem', borderRadius: 12, overflow: 'hidden' }}>
          <iframe src={embedUrl} style={{ position: 'absolute', top: 0, left: 0, width: '100%', height: '100%' }} allowFullScreen />
        </div>
      ) : track.audioUrl ? (
        <audio controls src={track.audioUrl} style={{ width: '100%', marginBottom: '1.5rem' }} />
      ) : null}

      {/* Transcript toggle */}
      {track.transcript && (
        <div style={{ marginBottom: '1.5rem' }}>
          <button className="btn" onClick={() => setShowTranscript((s) => !s)}>
            {showTranscript ? 'Ẩn transcript' : 'Xem transcript'}
          </button>
          {showTranscript && (
            <div className="card" style={{ marginTop: '0.75rem', lineHeight: 1.8, whiteSpace: 'pre-wrap', fontSize: '0.95rem' }}>
              {track.transcript}
            </div>
          )}
        </div>
      )}

      {/* Questions */}
      {!result ? (
        <div>
          <h2 style={{ marginBottom: '1rem' }}>Câu hỏi ({track.questions?.length})</h2>
          {track.questions?.map((q, idx) => (
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
          {(track.questions?.length ?? 0) > 0 && (
            <button className="btn btn-primary" disabled={!allAnswered || submitting} onClick={submit}>
              {submitting ? 'Đang chấm...' : 'Nộp bài'}
            </button>
          )}
        </div>
      ) : (
        <div>
          <div className="card" style={{ textAlign: 'center', padding: '2rem', marginBottom: '1.5rem', background: result.percent >= 60 ? 'rgba(34,197,94,0.1)' : 'rgba(239,68,68,0.1)' }}>
            <div style={{ fontSize: '3rem', fontWeight: 800 }}>{result.percent}%</div>
            <div style={{ marginTop: '0.25rem' }}>{result.correct}/{result.total} câu đúng</div>
          </div>
          {track.questions?.map((q, idx) => {
            const r = result.results?.find((x) => x.questionId === q.id);
            return (
              <div key={q.id} className="card" style={{ marginBottom: '0.6rem', borderLeft: `4px solid ${r?.correct ? 'var(--success)' : 'var(--danger)'}` }}>
                <p style={{ fontWeight: 600, marginBottom: '0.3rem' }}>{idx + 1}. {q.question}</p>
                <p style={{ fontSize: '0.88rem', color: 'var(--text-muted)' }}>Đáp án: <strong>{r?.correctAnswer}</strong></p>
              </div>
            );
          })}
          <button className="btn" onClick={() => { setAnswers({}); setResult(null); }}>Làm lại</button>
        </div>
      )}
    </div>
  );
}
