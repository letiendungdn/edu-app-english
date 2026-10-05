'use client';

import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import Link from 'next/link';
import type { LevelContentItem } from '@/lib/types';

const LEVELS = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

export default function ReadingPage() {
  const [level, setLevel] = useState('');

  const { data: passages = [], isLoading } = useQuery<LevelContentItem[]>({
    queryKey: ['reading', level],
    queryFn: async () => {
      const params = level ? `?level=${level}` : '';
      const res = await fetch(`/api/reading${params}`);
      return res.json();
    },
  });

  const byLevel = passages.reduce<Record<string, LevelContentItem[]>>((acc, p) => {
    (acc[p.level] ??= []).push(p);
    return acc;
  }, {});

  return (
    <div className="container" style={{ padding: '1.5rem 1rem' }}>
      <h1 style={{ marginBottom: '0.25rem' }}>Đọc hiểu</h1>
      <p style={{ color: 'var(--text-muted)', marginBottom: '1.25rem' }}>Luyện đọc và trả lời câu hỏi</p>

      <div style={{ display: 'flex', gap: '0.5rem', marginBottom: '1.25rem', flexWrap: 'wrap' }}>
        <button className={`btn${!level ? ' btn-primary' : ''}`} onClick={() => setLevel('')}>Tất cả</button>
        {LEVELS.map((l) => (
          <button key={l} className={`btn${level === l ? ' btn-primary' : ''}`} onClick={() => setLevel(l)}>{l}</button>
        ))}
      </div>

      {isLoading && <p style={{ color: 'var(--text-muted)' }}>Đang tải...</p>}

      {!isLoading && passages.length === 0 && (
        <div className="card" style={{ textAlign: 'center', padding: '3rem', color: 'var(--text-muted)' }}>
          Chưa có bài đọc nào. Thêm data qua seeder.
        </div>
      )}

      {Object.entries(byLevel).map(([lvl, ps]) => (
        <section key={lvl} style={{ marginBottom: '2rem' }}>
          <h2 style={{ fontSize: '0.9rem', marginBottom: '0.75rem' }}>
            <span className={`badge badge-${lvl}`}>{lvl}</span>
          </h2>
          <div style={{ display: 'grid', gap: '0.75rem', gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))' }}>
            {ps.map((p) => (
              <Link key={p.id} href={`/reading/${p.id}`} className="card" style={{ display: 'block', textDecoration: 'none' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '0.5rem' }}>
                  <span className={`badge badge-${p.level}`}>{p.level}</span>
                  <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>~{p.estimatedMin}p · {p._count.questions} câu</span>
                </div>
                <h3>{p.title}</h3>
                {p.source && <p style={{ fontSize: '0.78rem', color: 'var(--text-muted)', marginTop: '0.25rem' }}>{p.source}</p>}
              </Link>
            ))}
          </div>
        </section>
      ))}
    </div>
  );
}
