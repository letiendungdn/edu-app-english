'use client';

import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

async function fetchReviewCards() {
  const res = await fetch('/api/vocab/review');
  if (res.status === 401) return [];
  return res.json();
}

async function submitReview(vocabId: number, quality: number) {
  await fetch('/api/vocab/review', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ vocabId, quality }),
  });
}

const QUALITY_LABELS = [
  { q: 0, label: 'Không biết', color: '#ef4444' },
  { q: 2, label: 'Khó', color: '#f97316' },
  { q: 3, label: 'Được', color: '#eab308' },
  { q: 4, label: 'Dễ', color: '#22c55e' },
  { q: 5, label: 'Rất dễ', color: '#3b82f6' },
];

export default function SrsReviewPage() {
  const [index, setIndex] = useState(0);
  const [flipped, setFlipped] = useState(false);
  const [done, setDone] = useState(false);
  const qc = useQueryClient();

  const { data: cards = [], isLoading } = useQuery({
    queryKey: ['srs-review'],
    queryFn: fetchReviewCards,
  });

  const mutation = useMutation({
    mutationFn: ({ vocabId, quality }: { vocabId: number; quality: number }) =>
      submitReview(vocabId, quality),
    onSuccess: () => {
      if (index + 1 >= cards.length) {
        setDone(true);
        qc.invalidateQueries({ queryKey: ['srs-review'] });
      } else {
        setIndex((i) => i + 1);
        setFlipped(false);
      }
    },
  });

  if (isLoading) return <div className="container" style={{ padding: '2rem' }}>Đang tải...</div>;

  if (cards.length === 0) {
    return (
      <div className="container" style={{ padding: '3rem', textAlign: 'center' }}>
        <h2>SRS Review</h2>
        <p style={{ color: 'var(--text-muted)', marginTop: '1rem' }}>
          {cards.length === 0 && !done
            ? 'Không có thẻ nào cần ôn hôm nay. Tiếp tục học từ mới!'
            : 'Đăng nhập để sử dụng SRS Review.'}
        </p>
      </div>
    );
  }

  if (done) {
    return (
      <div className="container" style={{ padding: '3rem', textAlign: 'center' }}>
        <div style={{ fontSize: '3rem' }}>🎉</div>
        <h2 style={{ marginTop: '0.5rem' }}>Xong {cards.length} thẻ!</h2>
        <p style={{ color: 'var(--text-muted)', marginTop: '0.5rem' }}>Không còn thẻ nào cần ôn hôm nay.</p>
        <button className="btn btn-primary" style={{ marginTop: '1.5rem' }} onClick={() => { setIndex(0); setFlipped(false); setDone(false); }}>
          Ôn lại
        </button>
      </div>
    );
  }

  const card = cards[index];
  const vocab = card?.vocab;

  return (
    <div className="container" style={{ padding: '1.5rem 1rem', maxWidth: 600 }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '1rem', color: 'var(--text-muted)', fontSize: '0.85rem' }}>
        <span>SRS Review</span>
        <span>{index + 1} / {cards.length}</span>
      </div>

      {/* Progress bar */}
      <div style={{ height: 4, background: 'var(--border)', borderRadius: 4, marginBottom: '1.5rem', overflow: 'hidden' }}>
        <div style={{ height: '100%', width: `${(index / cards.length) * 100}%`, background: 'var(--accent)', transition: 'width 0.3s' }} />
      </div>

      <div
        className="card"
        style={{ minHeight: 200, display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', textAlign: 'center', cursor: 'pointer', padding: '2rem' }}
        onClick={() => setFlipped(true)}
      >
        <span className={`badge badge-${vocab?.level}`} style={{ marginBottom: '1rem' }}>{vocab?.level}</span>
        <div style={{ fontSize: '2rem', fontWeight: 800, marginBottom: '0.5rem' }}>{vocab?.word}</div>
        {vocab?.phonetic && <div style={{ color: 'var(--text-muted)' }}>{vocab.phonetic}</div>}

        {flipped ? (
          <div style={{ marginTop: '1rem' }}>
            <div style={{ fontSize: '1.2rem', color: 'var(--accent)', fontWeight: 600 }}>{vocab?.meaningVi}</div>
            {vocab?.exampleEn && (
              <div style={{ marginTop: '0.75rem', fontSize: '0.9rem', color: 'var(--text-muted)', fontStyle: 'italic' }}>
                &ldquo;{vocab.exampleEn}&rdquo;
              </div>
            )}
          </div>
        ) : (
          <div style={{ marginTop: '1rem', color: 'var(--text-muted)', fontSize: '0.85rem' }}>Nhấn để lật thẻ</div>
        )}
      </div>

      {flipped && (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(5, 1fr)', gap: '0.5rem', marginTop: '1rem' }}>
          {QUALITY_LABELS.map(({ q, label, color }) => (
            <button
              key={q}
              onClick={() => mutation.mutate({ vocabId: vocab?.id, quality: q })}
              disabled={mutation.isPending}
              style={{
                padding: '0.6rem 0.25rem', borderRadius: 8, border: `2px solid ${color}`,
                background: 'transparent', color, fontWeight: 700, cursor: 'pointer',
                fontSize: '0.75rem', textAlign: 'center',
              }}
            >
              {label}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
