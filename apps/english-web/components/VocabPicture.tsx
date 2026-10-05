'use client';

import Image from 'next/image';
import { useState } from 'react';
import { resolveVocabImage } from '@edu/vocab-images';

type VocabPictureProps = {
  word?: string | null;
  meaning?: string | null;
  imageUrl?: string | null;
  size?: 'xs' | 'sm' | 'md' | 'lg';
  className?: string;
  alt?: string;
};

const SIZE_PX = { xs: 24, sm: 32, md: 48, lg: 96 } as const;

export default function VocabPicture({
  word,
  meaning,
  imageUrl,
  size = 'md',
  className = '',
  alt = '',
}: VocabPictureProps) {
  const [failed, setFailed] = useState(false);
  const src = resolveVocabImage({ word, meaning, imageUrl });
  const px = SIZE_PX[size];

  if (!src || failed) return null;

  return (
    <Image
      src={src}
      alt={alt || word || 'vocab'}
      width={px}
      height={px}
      unoptimized
      className={`vocab-picture vocab-picture-${size}${className ? ` ${className}` : ''}`}
      onError={() => setFailed(true)}
    />
  );
}
