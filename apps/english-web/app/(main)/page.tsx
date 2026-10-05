'use client';

import Link from 'next/link';
import { useQuery } from '@tanstack/react-query';
import type { AnalyticsData } from '@/lib/types';

function fmtSeconds(s: number) {
  const h = Math.floor(s / 3600), m = Math.floor((s % 3600) / 60);
  return h > 0 ? `${h}g ${m}p` : `${m}p`;
}

const SECTIONS = [
  { href: '/vocab',           icon: '📚', label: 'Từ vựng',    desc: 'Học và quản lý từ vựng' },
  { href: '/vocab/review',    icon: '🔁', label: 'SRS Review',  desc: 'Ôn tập thẻ đến hạn' },
  { href: '/vocab/flashcard', icon: '🃏', label: 'Flashcard',   desc: 'Luyện nhanh bằng thẻ' },
  { href: '/grammar',         icon: '✏️', label: 'Ngữ pháp',   desc: 'Bài học ngữ pháp theo cấp' },
  { href: '/reading',         icon: '📖', label: 'Đọc hiểu',   desc: 'Bài đọc có câu hỏi kiểm tra' },
  { href: '/listening',       icon: '🎧', label: 'Nghe',        desc: 'Luyện nghe theo level' },
  { href: '/dictation',       icon: '🖊️', label: 'Nghe chép',  desc: 'Tăng kỹ năng chính tả' },
  { href: '/analytics',       icon: '📊', label: 'Tiến độ',    desc: 'Thống kê toàn bộ quá trình' },
];

export default function HomePage() {
  const { data } = useQuery({
    queryKey: ['analytics'],
    queryFn: async (): Promise<AnalyticsData> => {
      const res = await fetch('/api/analytics');
      if (!res.ok) throw new Error('Unauthorized');
      return res.json();
    },
    retry: false,
  });

  const { data: reviewCards = [] } = useQuery<unknown[]>({
    queryKey: ['srs-review'],
    queryFn: async () => {
      const res = await fetch('/api/vocab/review');
      if (res.status === 401) return [];
      return res.json();
    },
    retry: false,
  });

  const overview = data?.overview;
  const dueCount = Array.isArray(reviewCards) ? reviewCards.length : 0;

  const stats = overview
    ? [
        { label: 'Ngày đã học',   value: String(overview.daysStudied) },
        { label: 'Thẻ đã thuộc',  value: String(overview.masteredCards) },
        { label: 'Tổng thẻ',      value: String(overview.totalCards) },
        { label: 'Thời gian',     value: fmtSeconds(overview.totalStudySeconds) },
      ]
    : null;

  return (
    <div className="container" style={{ padding: '2rem 1rem', maxWidth: 800 }}>

      {/* ── Hero ── */}
      <div style={{ marginBottom: '2rem' }}>
        <h1 style={{ fontSize: '1.6rem', fontWeight: 800, marginBottom: '0.25rem' }}>
          🇬🇧 English Learning
        </h1>
        <p style={{ color: 'var(--text-muted)', fontSize: '0.95rem' }}>
          Luyện từ vựng, ngữ pháp, đọc và nghe mỗi ngày.
        </p>
      </div>

      {/* ── SRS due banner ── */}
      {dueCount > 0 && (
        <Link href="/vocab/review" style={{ textDecoration: 'none' }}>
          <div style={{
            display: 'flex', alignItems: 'center', justifyContent: 'space-between',
            padding: '0.9rem 1.2rem', borderRadius: 10, marginBottom: '1.5rem',
            background: 'var(--accent)', color: '#fff', cursor: 'pointer',
          }}>
            <div>
              <div style={{ fontWeight: 700, fontSize: '1rem' }}>
                🔁 {dueCount} thẻ cần ôn hôm nay
              </div>
              <div style={{ fontSize: '0.82rem', opacity: 0.85, marginTop: 2 }}>
                Ôn ngay để không quên kiến thức
              </div>
            </div>
            <span style={{ fontSize: '1.4rem' }}>→</span>
          </div>
        </Link>
      )}

      {/* ── Stats ── */}
      {stats && (
        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fill, minmax(140px, 1fr))',
          gap: '0.6rem',
          marginBottom: '1.75rem',
        }}>
          {stats.map(({ label, value }) => (
            <div key={label} className="card" style={{ textAlign: 'center', padding: '0.9rem 0.5rem' }}>
              <div style={{ fontSize: '1.55rem', fontWeight: 800, fontVariantNumeric: 'tabular-nums' }}>
                {value}
              </div>
              <div style={{ fontSize: '0.76rem', color: 'var(--text-muted)', marginTop: 3 }}>{label}</div>
            </div>
          ))}
        </div>
      )}

      {/* ── Navigation grid ── */}
      <h2 style={{ fontSize: '0.85rem', fontWeight: 700, textTransform: 'uppercase',
        letterSpacing: '0.06em', color: 'var(--text-muted)', marginBottom: '0.75rem' }}>
        Luyện tập
      </h2>
      <div style={{
        display: 'grid',
        gridTemplateColumns: 'repeat(auto-fill, minmax(175px, 1fr))',
        gap: '0.6rem',
      }}>
        {SECTIONS.map(({ href, icon, label, desc }) => (
          <Link key={href} href={href} style={{ textDecoration: 'none' }}>
            <div className="card" style={{
              padding: '1rem',
              cursor: 'pointer',
              transition: 'transform 0.12s, box-shadow 0.12s',
            }}
              onMouseEnter={e => {
                (e.currentTarget as HTMLDivElement).style.transform = 'translateY(-2px)';
                (e.currentTarget as HTMLDivElement).style.boxShadow = '0 4px 16px rgba(0,0,0,0.1)';
              }}
              onMouseLeave={e => {
                (e.currentTarget as HTMLDivElement).style.transform = '';
                (e.currentTarget as HTMLDivElement).style.boxShadow = '';
              }}
            >
              <div style={{ fontSize: '1.5rem', marginBottom: 6 }}>{icon}</div>
              <div style={{ fontWeight: 700, fontSize: '0.92rem', color: 'var(--text)' }}>{label}</div>
              <div style={{ fontSize: '0.78rem', color: 'var(--text-muted)', marginTop: 3 }}>{desc}</div>
            </div>
          </Link>
        ))}
      </div>
    </div>
  );
}
