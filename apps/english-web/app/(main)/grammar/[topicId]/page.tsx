'use client';

import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { useParams } from 'next/navigation';
import Link from 'next/link';
import type { GrammarTopicDetail } from '@/lib/types';

export default function GrammarTopicPage() {
  const { topicId } = useParams<{ topicId: string }>();
  const [activeLesson, setActiveLesson] = useState(0);
  const [answers, setAnswers] = useState<Record<number, string>>({});
  const [checked, setChecked] = useState<Record<number, boolean>>({});

  const { data: topic, isLoading } = useQuery<GrammarTopicDetail>({
    queryKey: ['grammar-topic', topicId],
    queryFn: async () => {
      const res = await fetch(`/api/grammar/${topicId}`);
      return res.json();
    },
  });

  if (isLoading) return <div className="container" style={{ padding: '2rem' }}>Đang tải...</div>;
  if (!topic) return <div className="container" style={{ padding: '2rem' }}>Không tìm thấy.</div>;

  const lesson = topic.lessons?.[activeLesson];

  function checkAnswer(exId: number, answer: string) {
    setChecked((c) => ({ ...c, [exId]: true }));
    setAnswers((a) => ({ ...a, [exId]: answer }));
  }

  return (
    <div className="container" style={{ padding: '1.5rem 1rem', maxWidth: 800 }}>
      <Link href="/grammar" style={{ color: 'var(--text-muted)', fontSize: '0.85rem' }}>← Ngữ pháp</Link>

      <div style={{ margin: '1rem 0' }}>
        <span className={`badge badge-${topic.level}`} style={{ marginRight: '0.5rem' }}>{topic.level}</span>
        <h1 style={{ display: 'inline', fontSize: '1.4rem' }}>{topic.title}</h1>
      </div>

      {/* Lesson tabs */}
      {topic.lessons?.length > 1 && (
        <div style={{ display: 'flex', gap: '0.5rem', marginBottom: '1.25rem', overflowX: 'auto', paddingBottom: '0.25rem' }}>
          {topic.lessons.map((l, i) => (
            <button
              key={l.id}
              className={`btn${activeLesson === i ? ' btn-primary' : ''}`}
              style={{ whiteSpace: 'nowrap' }}
              onClick={() => { setActiveLesson(i); setAnswers({}); setChecked({}); }}
            >
              {i + 1}. {l.title}
            </button>
          ))}
        </div>
      )}

      {lesson && (
        <>
          {/* Explanation */}
          <div className="card" style={{ marginBottom: '1.5rem', lineHeight: 1.8 }}>
            <h2 style={{ marginBottom: '0.75rem' }}>{lesson.title}</h2>
            <div style={{ whiteSpace: 'pre-wrap' }}>{lesson.explanation}</div>

            {(lesson.examples as string[])?.length > 0 && (
              <div style={{ marginTop: '1rem', borderLeft: '3px solid var(--accent)', paddingLeft: '1rem' }}>
                <strong style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>Ví dụ:</strong>
                {(lesson.examples as string[]).map((ex: string, i: number) => (
                  <p key={i} style={{ fontSize: '0.9rem', fontStyle: 'italic', marginTop: '0.25rem' }}>{ex}</p>
                ))}
              </div>
            )}
          </div>

          {/* Exercises */}
          {(lesson.exercises?.length ?? 0) > 0 && (
            <div>
              <h2 style={{ marginBottom: '1rem' }}>Bài tập ({lesson.exercises!.length})</h2>
              {lesson.exercises!.map((ex, i) => {
                const isChecked = checked[ex.id];
                const isCorrect = answers[ex.id] === ex.answer;
                const opts = Array.isArray(ex.options)
                  ? ex.options
                  : (JSON.parse(ex.options as string) as string[]);

                return (
                  <div key={ex.id} className="card" style={{
                    marginBottom: '0.75rem',
                    borderLeft: isChecked ? `4px solid ${isCorrect ? 'var(--success)' : 'var(--danger)'}` : '4px solid transparent',
                  }}>
                    <p style={{ fontWeight: 600, marginBottom: '0.75rem' }}>{i + 1}. {ex.question}</p>
                    {opts.length > 0 ? (
                      <div style={{ display: 'flex', flexDirection: 'column', gap: '0.4rem' }}>
                        {opts.map((opt: string) => {
                          const selected = answers[ex.id] === opt;
                          const correct = isChecked && opt === ex.answer;
                          const wrong = isChecked && selected && !correct;
                          return (
                            <label key={opt} style={{
                              display: 'flex', alignItems: 'center', gap: '0.5rem',
                              padding: '0.4rem 0.75rem', borderRadius: 8, cursor: 'pointer',
                              background: correct ? 'rgba(34,197,94,0.1)' : wrong ? 'rgba(239,68,68,0.1)' : selected ? 'var(--accent-soft)' : 'transparent',
                              border: `1px solid ${correct ? 'var(--success)' : wrong ? 'var(--danger)' : selected ? 'var(--accent)' : 'var(--border)'}`,
                            }}>
                              <input
                                type="radio"
                                name={`ex-${ex.id}`}
                                disabled={isChecked}
                                checked={selected}
                                onChange={() => setAnswers((a) => ({ ...a, [ex.id]: opt }))}
                              />
                              {opt}
                            </label>
                          );
                        })}
                        {!isChecked && (
                          <button
                            className="btn btn-primary"
                            style={{ marginTop: '0.5rem', alignSelf: 'flex-start' }}
                            disabled={!answers[ex.id]}
                            onClick={() => checkAnswer(ex.id, answers[ex.id])}
                          >
                            Kiểm tra
                          </button>
                        )}
                      </div>
                    ) : (
                      <div style={{ display: 'flex', gap: '0.5rem' }}>
                        <input
                          placeholder="Điền vào..."
                          value={answers[ex.id] ?? ''}
                          disabled={isChecked}
                          onChange={(e) => setAnswers((a) => ({ ...a, [ex.id]: e.target.value }))}
                          onKeyDown={(e) => e.key === 'Enter' && answers[ex.id] && checkAnswer(ex.id, answers[ex.id])}
                        />
                        {!isChecked && (
                          <button className="btn btn-primary" style={{ flexShrink: 0 }} disabled={!answers[ex.id]} onClick={() => checkAnswer(ex.id, answers[ex.id])}>OK</button>
                        )}
                      </div>
                    )}
                    {isChecked && (
                      <div style={{ marginTop: '0.5rem', fontSize: '0.85rem', color: isCorrect ? 'var(--success)' : 'var(--danger)' }}>
                        {isCorrect ? '✅ Chính xác!' : `❌ Đáp án đúng: ${ex.answer}`}
                        {ex.explanation && <span style={{ color: 'var(--text-muted)', marginLeft: '0.5rem' }}>— {ex.explanation}</span>}
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
          )}
        </>
      )}
    </div>
  );
}
