'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useQuery } from '@tanstack/react-query';
import VocabPicture from '@/components/VocabPicture';

import type { VocabWord, VocabListResponse } from '@/lib/types';

const LEVELS = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'] as const;

async function fetchVocab(level?: string, page = 1) {
  const params = new URLSearchParams({ page: String(page), limit: '30' });
  if (level) params.set('level', level);
  const res = await fetch(`/api/vocab?${params}`);
  return res.json() as Promise<VocabListResponse>;
}

function VocabCard({ w }: { w: VocabWord }) {
  const [flipped, setFlipped] = useState(false);

  return (
    <div
      className="card vocab-list-card"
      style={{ cursor: 'pointer', userSelect: 'none' }}
      onClick={() => setFlipped((f) => !f)}
    >
      <div className="vocab-list-card-inner">
        <VocabPicture
          word={w.word}
          meaning={w.meaningVi}
          imageUrl={w.imageUrl}
          size="sm"
          className="vocab-list-card-picture"
          alt={w.word}
        />
        <div className="vocab-list-card-body">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '0.5rem' }}>
            <span className={`badge badge-${w.level}`}>{w.level}</span>
            {w.partOfSpeech && (
              <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>{w.partOfSpeech}</span>
            )}
          </div>
          <div style={{ fontSize: '1.25rem', fontWeight: 700 }}>{w.word}</div>
          {w.phonetic && (
            <div style={{ fontSize: '0.85rem', color: 'var(--text-muted)', marginBottom: '0.25rem' }}>{w.phonetic}</div>
          )}
          {flipped ? (
            <>
              <div style={{ color: 'var(--accent)', fontWeight: 600, marginTop: '0.5rem' }}>{w.meaningVi}</div>
              {w.exampleEn && (
                <div style={{ fontSize: '0.85rem', color: 'var(--text-muted)', marginTop: '0.4rem', fontStyle: 'italic' }}>
                  &ldquo;{w.exampleEn}&rdquo;
                </div>
              )}
              {w.exampleVi && (
                <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)', marginTop: '0.2rem' }}>→ {w.exampleVi}</div>
              )}
            </>
          ) : (
            <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)', marginTop: '0.5rem' }}>Nhấn để xem nghĩa</div>
          )}
          {w.topic && (
            <div style={{ marginTop: '0.5rem', fontSize: '0.75rem', color: 'var(--text-muted)' }}>
              #{w.topic.name}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default function VocabPage() {
  const [level, setLevel] = useState<string>('');
  const [page, setPage] = useState(1);

  const { data, isLoading } = useQuery({
    queryKey: ['vocab', level, page],
    queryFn: () => fetchVocab(level || undefined, page),
  });

  const totalPages = data ? Math.ceil(data.total / data.limit) : 1;

  return (
    <div className="container" style={{ padding: '1.5rem 1rem' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.25rem', flexWrap: 'wrap', gap: '0.75rem' }}>
        <div>
          <h1 style={{ marginBottom: '0.15rem' }}>Từ vựng</h1>
          {data && <p style={{ color: 'var(--text-muted)', fontSize: '0.85rem' }}>{data.total} từ • nhấn thẻ để xem nghĩa</p>}
        </div>
        <Link href="/vocab/flashcard" className="btn">Flashcard</Link>
        <Link href="/vocab/picture" className="btn">Từ điển tranh</Link>
        <Link href="/vocab/review" className="btn btn-primary">SRS Review →</Link>
      </div>

      <div style={{ display: 'flex', gap: '0.5rem', marginBottom: '1.25rem', flexWrap: 'wrap' }}>
        <button className={`btn${!level ? ' btn-primary' : ''}`} onClick={() => { setLevel(''); setPage(1); }}>Tất cả</button>
        {LEVELS.map((l) => (
          <button key={l} className={`btn${level === l ? ' btn-primary' : ''}`} onClick={() => { setLevel(l); setPage(1); }}>
            {l}
          </button>
        ))}
      </div>

      {isLoading ? (
        <p style={{ color: 'var(--text-muted)' }}>Đang tải...</p>
      ) : data?.words?.length === 0 ? (
        <div className="card" style={{ textAlign: 'center', padding: '3rem', color: 'var(--text-muted)' }}>
          Chưa có từ vựng nào. Thêm data qua seeder hoặc Admin.
        </div>
      ) : (
        <div style={{ display: 'grid', gap: '0.75rem', gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))' }}>
          {data?.words?.map((w) => <VocabCard key={w.id} w={w} />)}
        </div>
      )}

      {totalPages > 1 && (
        <div style={{ display: 'flex', gap: '0.5rem', justifyContent: 'center', marginTop: '1.5rem' }}>
          <button className="btn" disabled={page === 1} onClick={() => setPage((p) => p - 1)}>← Trước</button>
          <span style={{ padding: '0.5rem 1rem', color: 'var(--text-muted)', fontSize: '0.9rem' }}>{page} / {totalPages}</span>
          <button className="btn" disabled={page === totalPages} onClick={() => setPage((p) => p + 1)}>Sau →</button>
        </div>
      )}
    </div>
  );
}
