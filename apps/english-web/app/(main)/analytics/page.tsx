'use client';

import { useQuery } from '@tanstack/react-query';
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, LineChart, Line, CartesianGrid } from 'recharts';
import type { AnalyticsData, ReadingHistoryItem, StudySession } from '@/lib/types';

function fmtSeconds(s: number) {
  const h = Math.floor(s / 3600), m = Math.floor((s % 3600) / 60);
  return h > 0 ? `${h}g ${m}p` : `${m} phút`;
}

function Heatmap({ data }: { data: { date: string; seconds: number }[] }) {
  const map = new Map(data.map((d) => [d.date.slice(0, 10), d.seconds]));
  const today = new Date();
  const cells: { date: string; seconds: number }[] = [];
  for (let i = 364; i >= 0; i--) {
    const d = new Date(today);
    d.setDate(d.getDate() - i);
    const key = d.toISOString().slice(0, 10);
    cells.push({ date: key, seconds: map.get(key) ?? 0 });
  }

  function color(s: number) {
    if (s === 0) return 'var(--border)';
    if (s < 300) return '#1d4ed8';
    if (s < 900) return '#2563eb';
    if (s < 1800) return '#60a5fa';
    return '#93c5fd';
  }

  const weeks: typeof cells[] = [];
  for (let i = 0; i < cells.length; i += 7) weeks.push(cells.slice(i, i + 7));

  return (
    <div style={{ overflowX: 'auto' }}>
      <div style={{ display: 'flex', gap: 3, minWidth: 600 }}>
        {weeks.map((week, wi) => (
          <div key={wi} style={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
            {week.map((cell) => (
              <div key={cell.date} title={`${cell.date}: ${fmtSeconds(cell.seconds)}`}
                style={{ width: 12, height: 12, borderRadius: 2, background: color(cell.seconds) }} />
            ))}
          </div>
        ))}
      </div>
      <div style={{ display: 'flex', gap: 4, alignItems: 'center', marginTop: 8, fontSize: '0.75rem', color: 'var(--text-muted)' }}>
        Ít {[0, 300, 900, 1800].map((s) => <div key={s} style={{ width: 12, height: 12, borderRadius: 2, background: color(s) }} />)} Nhiều
      </div>
    </div>
  );
}

export default function AnalyticsPage() {
  const { data, isLoading, error } = useQuery({
    queryKey: ['analytics'],
    queryFn: async (): Promise<AnalyticsData> => {
      const res = await fetch('/api/analytics');
      if (!res.ok) throw new Error('Unauthorized');
      return res.json();
    },
    retry: false,
  });

  if (isLoading) return <div className="container" style={{ padding: '2rem' }}>Đang tải...</div>;

  if (error || !data) {
    return (
      <div className="container" style={{ padding: '3rem', textAlign: 'center' }}>
        <h2>Tiến độ học</h2>
        <p style={{ color: 'var(--text-muted)', marginTop: '1rem' }}>Đăng nhập để xem tiến độ của bạn.</p>
      </div>
    );
  }

  const { overview, studySessions, readingHistory } = data;

  const stats = [
    { label: 'Tổng thời gian', value: fmtSeconds(overview.totalStudySeconds) },
    { label: 'Ngày đã học', value: String(overview.daysStudied) },
    { label: 'Thẻ đã thuộc', value: String(overview.masteredCards) },
    { label: 'Tổng thẻ', value: String(overview.totalCards) },
    { label: 'Bài đọc', value: String(overview.readingAttempts) },
    { label: 'Bài nghe', value: String(overview.listeningAttempts) },
    { label: 'Nghe chép', value: String(overview.dictationAttempts) },
  ];

  const last30 = studySessions.slice(-30).map((s: StudySession) => {
    const d = new Date(s.date);
    return { date: `${d.getDate()}/${d.getMonth() + 1}`, 'Phút': Math.round(s.seconds / 60) };
  });

  const readingChart = readingHistory.slice(-20).map((r: ReadingHistoryItem) => {
    const d = new Date(r.date);
    return { date: `${d.getDate()}/${d.getMonth() + 1}`, 'Đọc %': r.percent, 'Nghe %': 0 };
  });

  return (
    <div className="container" style={{ padding: '1.5rem 1rem' }}>
      <h1 style={{ marginBottom: '0.25rem' }}>Tiến độ học</h1>
      <p style={{ color: 'var(--text-muted)', marginBottom: '1.75rem' }}>Thống kê toàn bộ quá trình học tiếng Anh</p>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(130px, 1fr))', gap: '0.6rem', marginBottom: '2rem' }}>
        {stats.map(({ label, value }) => (
          <div key={label} className="card" style={{ textAlign: 'center', padding: '1rem 0.75rem' }}>
            <div style={{ fontSize: '1.6rem', fontWeight: 800 }}>{value}</div>
            <div style={{ fontSize: '0.78rem', color: 'var(--text-muted)', marginTop: 4 }}>{label}</div>
          </div>
        ))}
      </div>

      <section className="card" style={{ marginBottom: '1.5rem' }}>
        <h2 style={{ fontSize: '0.95rem', marginBottom: '1rem' }}>Lịch học (365 ngày qua)</h2>
        <Heatmap data={studySessions.map((s: StudySession) => ({ date: s.date, seconds: s.seconds }))} />
      </section>

      {last30.length > 0 && (
        <section className="card" style={{ marginBottom: '1.5rem' }}>
          <h2 style={{ fontSize: '0.95rem', marginBottom: '1rem' }}>Thời gian học (30 ngày)</h2>
          <ResponsiveContainer width="100%" height={200}>
            <BarChart data={last30}>
              <XAxis dataKey="date" tick={{ fontSize: 11 }} />
              <YAxis tick={{ fontSize: 11 }} unit="p" />
              <Tooltip formatter={(v) => [`${v} phút`, 'Học']} />
              <Bar dataKey="Phút" fill="var(--accent)" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </section>
      )}

      {readingChart.length > 0 && (
        <section className="card" style={{ marginBottom: '1.5rem' }}>
          <h2 style={{ fontSize: '0.95rem', marginBottom: '1rem' }}>Điểm bài đọc gần đây</h2>
          <ResponsiveContainer width="100%" height={200}>
            <LineChart data={readingChart}>
              <CartesianGrid strokeDasharray="3 3" stroke="var(--border)" />
              <XAxis dataKey="date" tick={{ fontSize: 11 }} />
              <YAxis domain={[0, 100]} tick={{ fontSize: 11 }} unit="%" />
              <Tooltip formatter={(v) => [`${v}%`, '']} />
              <Line type="monotone" dataKey="Đọc %" stroke="var(--accent)" strokeWidth={2} dot={{ r: 4 }} />
            </LineChart>
          </ResponsiveContainer>
        </section>
      )}

      {last30.length === 0 && readingChart.length === 0 && (
        <div className="card" style={{ textAlign: 'center', padding: '2.5rem', color: 'var(--text-muted)' }}>
          Chưa có dữ liệu. Học và luyện tập để xem thống kê ở đây!
        </div>
      )}
    </div>
  );
}
