import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { ApiError, createApiClient } from '../src/index';
import type { AuthResponse, ReviewDto, ReviewListResponse } from '@hifz/contracts';

const base = 'http://api.test/api/v1';
const server = setupServer(
  http.post(`${base}/auth/login`, () =>
    HttpResponse.json({
      user: {
        id: '9b2f6f38-1e63-4c8a-9c1a-3f8c2c2e6c11',
        name: 'A',
        email: 'a@b.com',
        role: 'TEACHER',
      },
      accessToken: 'at',
      refreshToken: 'rt',
    } satisfies AuthResponse),
  ),
  http.post(`${base}/reviews`, () =>
    HttpResponse.json({ error: { code: 'VALIDATION_ERROR', message: 'bad' } }, { status: 400 }),
  ),
  http.get(`${base}/reviews`, () =>
    HttpResponse.json({
      items: [
        {
          id: '0b2f6f38-1e63-4c8a-9c1a-3f8c2c2e6c12',
          studentId: '9b2f6f38-1e63-4c8a-9c1a-3f8c2c2e6c11',
          surahNumber: 1,
          ayahFrom: 1,
          ayahTo: 7,
          quality: 'GOOD',
          loggedAt: '2026-09-18T10:00:00.000Z',
        },
      ],
    } satisfies ReviewListResponse),
  ),
);
beforeAll(() => server.listen());
afterAll(() => server.close());

describe('api-sdk', () => {
  const client = createApiClient({ baseUrl: base, getAccessToken: () => 'at' });

  it('login returns typed AuthResponse', async () => {
    const res = await client.auth.login({ email: 'a@b.com', password: 'pw' });
    expect(res.user.role).toBe('TEACHER');
  });

  it('throws ApiError with envelope code on error status', async () => {
    const err = await client.reviews
      .create({ surahNumber: 1, ayahFrom: 2, ayahTo: 1, quality: 'GOOD' }, 'key')
      .catch((e) => e);
    expect(err).toBeInstanceOf(ApiError);
    expect((err as ApiError).code).toBe('VALIDATION_ERROR');
    expect((err as ApiError).status).toBe(400);
  });

  it('lists reviews and sends bearer + idempotency key', async () => {
    let sawAuth = '';
    let sawIdem = '';
    server.use(
      http.post(`${base}/reviews`, ({ request }) => {
        sawAuth = request.headers.get('authorization') ?? '';
        sawIdem = request.headers.get('idempotency-key') ?? '';
        const dto: ReviewDto = {
          id: '0b2f6f38-1e63-4c8a-9c1a-3f8c2c2e6c12',
          studentId: '9b2f6f38-1e63-4c8a-9c1a-3f8c2c2e6c11',
          surahNumber: 1,
          ayahFrom: 1,
          ayahTo: 7,
          quality: 'GOOD',
          loggedAt: '2026-09-18T10:00:00.000Z',
        };
        return HttpResponse.json(dto, { status: 201 });
      }),
    );
    const created = await client.reviews.create(
      { surahNumber: 1, ayahFrom: 1, ayahTo: 7, quality: 'GOOD' },
      'my-key',
    );
    expect(created.id).toBeTruthy();
    expect(sawAuth).toBe('Bearer at');
    expect(sawIdem).toBe('my-key');
  });

  it('parses list responses', async () => {
    const res = await client.reviews.list();
    expect(res.items).toHaveLength(1);
  });
});
