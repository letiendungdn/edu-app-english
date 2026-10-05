'use client';

import { useMemo, useState } from 'react';
import Image from 'next/image';
import Link from 'next/link';
import { useQuery } from '@tanstack/react-query';

const LEVELS = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'] as const;

type PictureItem = {
  id: number;
  word: string;
  phonetic?: string | null;
  meaningVi: string;
  level: string;
  partOfSpeech?: string | null;
  exampleEn?: string | null;
  topic?: { name: string; icon?: string | null } | null;
  imageUrl: string | null;
};

async function fetchPictures(level?: string, picturesOnly = true) {
  const params = new URLSearchParams({ limit: '200', picturesOnly: String(picturesOnly) });
  if (level) params.set('level', level);
  const res = await fetch(`/api/vocab/picture?${params}`);
  return res.json() as Promise<{ total: number; items: PictureItem[] }>;
}

export default function PictureDictionaryPage() {
  const [level, setLevel] = useState('');
  const [picturesOnly, setPicturesOnly] = useState(true);
  const [selected, setSelected] = useState<PictureItem | null>(null);

  const { data, isLoading } = useQuery({
    queryKey: ['picture-dictionary', level, picturesOnly],
    queryFn: () => fetchPictures(level || undefined, picturesOnly),
  });

  const items = useMemo(() => data?.items ?? [], [data?.items]);

  const grouped = useMemo(() => {
    const map = new Map<string, PictureItem[]>();
    for (const item of items) {
      const key = item.topic?.name ?? 'Khác';
      if (!map.has(key)) map.set(key, []);
      map.get(key)!.push(item);
    }
    return [...map.entries()];
  }, [items]);

  return (
    <div className="container picture-dict-page">
      <div className="picture-dict-header">
        <div>
          <h1>Từ điển hình ảnh</h1>
          <p className="picture-dict-subtitle">
            Học từ vựng qua tranh · {data ? `${items.length} từ` : '...'}
          </p>
        </div>
        <div className="picture-dict-header-actions">
          <Link href="/vocab" className="btn">Danh sách</Link>
          <Link href="/vocab/flashcard" className="btn btn-primary">Flashcard</Link>
        </div>
      </div>

      <div className="picture-dict-filters">
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
        <label className="picture-dict-toggle">
          <input
            type="checkbox"
            checked={picturesOnly}
            onChange={(e) => setPicturesOnly(e.target.checked)}
          />
          Chỉ từ có ảnh
        </label>
      </div>

      {isLoading ? (
        <p className="picture-dict-empty">Đang tải...</p>
      ) : items.length === 0 ? (
        <div className="card picture-dict-empty">
          Chưa có từ nào có hình ảnh. Thử bỏ lọc &quot;Chỉ từ có ảnh&quot; hoặc chọn level khác.
        </div>
      ) : (
        grouped.map(([topic, topicItems]) => (
          <section key={topic} className="picture-dict-section">
            <h2 className="picture-dict-topic">
              {topicItems[0]?.topic?.icon ? `${topicItems[0].topic.icon} ` : ''}
              {topic}
            </h2>
            <div className="picture-dict-grid">
              {topicItems.map((item) => (
                <button
                  key={item.id}
                  type="button"
                  className="picture-card"
                  onClick={() => setSelected(item)}
                >
                  <div className="picture-card-image-wrap">
                    {item.imageUrl ? (
                      <Image src={item.imageUrl} alt={item.word} width={120} height={120} unoptimized />
                    ) : (
                      <div className="picture-card-placeholder">📷</div>
                    )}
                  </div>
                  <div className="picture-card-body">
                    <span className={`badge badge-${item.level}`}>{item.level}</span>
                    <strong>{item.word}</strong>
                    <span>{item.meaningVi}</span>
                  </div>
                </button>
              ))}
            </div>
          </section>
        ))
      )}

      {selected && (
        <div className="picture-modal-backdrop" onClick={() => setSelected(null)}>
          <div className="picture-modal card" onClick={(e) => e.stopPropagation()}>
            <button type="button" className="picture-modal-close" onClick={() => setSelected(null)}>
              ✕
            </button>
            {selected.imageUrl && (
              <Image
                src={selected.imageUrl}
                alt={selected.word}
                width={280}
                height={280}
                unoptimized
                className="picture-modal-image"
              />
            )}
            <span className={`badge badge-${selected.level}`}>{selected.level}</span>
            <h2>{selected.word}</h2>
            {selected.phonetic && <p className="picture-modal-phonetic">{selected.phonetic}</p>}
            <p className="picture-modal-meaning">{selected.meaningVi}</p>
            {selected.exampleEn && (
              <p className="picture-modal-example">&ldquo;{selected.exampleEn}&rdquo;</p>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
