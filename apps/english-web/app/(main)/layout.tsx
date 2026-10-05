'use client';

import Link from 'next/link';
import { usePathname, useSearchParams, useRouter } from 'next/navigation';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { useState, useEffect, Suspense, type ReactNode } from 'react';

const nihongoAppUrl = process.env.NEXT_PUBLIC_NIHONGO_APP_URL ?? 'http://localhost:5173';

function SsoHandler() {
  const params = useSearchParams();
  const router = useRouter();
  useEffect(() => {
    const ssoToken = params.get('sso_token');
    if (!ssoToken) return;
    void (async () => {
      try {
        await fetch('/api/english/auth/set-cookie', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ token: ssoToken }),
          credentials: 'include',
        });
      } catch {
        // ignore — user can log in manually
      } finally {
        const url = new URL(window.location.href);
        url.searchParams.delete('sso_token');
        router.replace(url.pathname + url.search);
      }
    })();
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);
  return null;
}

const nav = [
  { href: '/', label: '🏠 Home', end: true },
  { href: '/vocab', label: '📚 Từ vựng' },
  { href: '/vocab/flashcard', label: '🃏 Flashcard' },
  { href: '/vocab/picture', label: '🖼️ Từ điển tranh' },
  { href: '/vocab/review', label: '🔁 SRS Review' },
  { href: '/grammar', label: '✏️ Ngữ pháp' },
  { href: '/reading', label: '📖 Đọc hiểu' },
  { href: '/listening', label: '🎧 Nghe' },
  { href: '/dictation', label: '🖊️ Nghe chép' },
  { href: '/analytics', label: '📊 Tiến độ' },
];

function NavLink({ href, label, end }: { href: string; label: string; end?: boolean }) {
  const pathname = usePathname() ?? '';
  const active = end ? pathname === href : pathname === href || pathname.startsWith(href + '/');
  return (
    <Link href={href} className={`nav-link${active ? ' active' : ''}`}>
      {label}
    </Link>
  );
}

export default function MainLayout({ children }: { children: ReactNode }) {
  const [qc] = useState(() => new QueryClient());

  return (
    <QueryClientProvider client={qc}>
      <Suspense fallback={null}>
        <SsoHandler />
      </Suspense>
      <div style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column' }}>
        <header style={{ borderBottom: '1px solid var(--border)', padding: '0.75rem 0', background: 'var(--bg)', position: 'sticky', top: 0, zIndex: 100 }}>
          <div className="container" style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', flexWrap: 'wrap' }}>
            <Link href="/" style={{ fontWeight: 800, fontSize: '1.1rem', textDecoration: 'none', color: 'var(--accent)', marginRight: '0.5rem' }}>
              🇬🇧 English
            </Link>
            {nav.map(({ href, label, end }) => (
              <NavLink key={href} href={href} label={label} end={end} />
            ))}
            <a href={nihongoAppUrl} className="nav-link app-switcher" style={{ marginLeft: 'auto' }}>
              🇯🇵 Nihongo
            </a>
          </div>
        </header>

        <main style={{ flex: 1 }}>{children}</main>

        <footer style={{ borderTop: '1px solid var(--border)', padding: '1rem 0', textAlign: 'center', fontSize: '0.8rem', color: 'var(--text-muted)' }}>
          © {new Date().getFullYear()} English Learning App
        </footer>
      </div>
    </QueryClientProvider>
  );
}
