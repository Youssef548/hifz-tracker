// @vitest-environment node
import { describe, expect, it, vi } from 'vitest';
import { POST } from '@/app/api/auth/session/route';

describe('session route', () => {
  it('sets httpOnly at + rt cookies on success', async () => {
    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue(
        new Response(
          JSON.stringify({
            user: {
              id: '9b2f6f38-1e63-4c8a-9c1a-3f8c2c2e6c11',
              name: 'T',
              email: 't@t.dev',
              role: 'TEACHER',
            },
            accessToken: 'at',
            refreshToken: 'rt',
          }),
          { status: 200 },
        ),
      ),
    );
    const req = new Request('http://localhost/api/auth/session', {
      method: 'POST',
      body: JSON.stringify({ email: 't@t.dev', password: 'password123' }),
    });
    const res = await POST(req);
    const setCookie = res.headers.getSetCookie().join('\n');
    expect(setCookie).toContain('at=');
    expect(setCookie).toContain('rt=');
    expect(setCookie).toContain('HttpOnly');
    vi.unstubAllGlobals();
  });
});
