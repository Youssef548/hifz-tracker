import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { AuthResponse, ReviewDto, ReviewListResponse } from '@hifz/contracts';
import { ApiError, createApiClient, type ApiClient } from '../src/index';

const base = 'http://api.test/api/v1';
const studentId = '9b2f6f38-1e63-4c8a-9c1a-3f8c2c2e6c11';

const reviewDto: ReviewDto = {
  id: '0b2f6f38-1e63-4c8a-9c1a-3f8c2c2e6c12',
  studentId,
  surahNumber: 1,
  ayahFrom: 1,
  ayahTo: 7,
  quality: 'GOOD',
  loggedAt: '2026-09-18T10:00:00.000Z',
};

const server = setupServer(
  http.post(`${base}/auth/login`, () =>
    HttpResponse.json({
      user: { id: studentId, name: 'A', email: 'a@b.com', role: 'TEACHER' },
      accessToken: 'at',
      refreshToken: 'rt',
    } satisfies AuthResponse),
  ),
  http.post(`${base}/reviews`, () =>
    HttpResponse.json({ error: { code: 'VALIDATION_ERROR', message: 'bad' } }, { status: 400 }),
  ),
  http.get(`${base}/reviews`, () =>
    HttpResponse.json({ items: [reviewDto] } satisfies ReviewListResponse),
  ),
);
beforeAll(() => server.listen());
afterAll(() => server.close());

describe('api-sdk', () => {
  // openapi-fetch snapshots `globalThis.fetch` when the client is built, so it
  // has to be built after msw has patched fetch. Production builds one client
  // per request, which is equivalent.
  let client: ApiClient;

  beforeAll(() => {
    client = createApiClient({ baseUrl: base, getAccessToken: () => 'at' });
  });

  it('login returns the parsed AuthResponse', async () => {
    const res = await client.auth.login({ email: 'a@b.com', password: 'pw' });
    expect(res.user.role).toBe('TEACHER');
    expect(res.accessToken).toBe('at');
  });

  it('maps an error envelope to ApiError with its code and status', async () => {
    const err = await client.reviews
      .create({ surahNumber: 1, ayahFrom: 2, ayahTo: 1, quality: 'GOOD' }, 'key')
      .catch((e) => e);
    expect(err).toBeInstanceOf(ApiError);
    expect((err as ApiError).code).toBe('VALIDATION_ERROR');
    expect((err as ApiError).status).toBe(400);
  });

  it('forwards the bearer token and idempotency key on review create', async () => {
    let sawAuth = '';
    let sawIdem = '';
    server.use(
      http.post(`${base}/reviews`, ({ request }) => {
        sawAuth = request.headers.get('authorization') ?? '';
        sawIdem = request.headers.get('idempotency-key') ?? '';
        return HttpResponse.json(reviewDto, { status: 201 });
      }),
    );
    const created = await client.reviews.create(
      { surahNumber: 1, ayahFrom: 1, ayahTo: 7, quality: 'GOOD' },
      'my-key',
    );
    expect(created.id).toBe(reviewDto.id);
    expect(sawAuth).toBe('Bearer at');
    expect(sawIdem).toBe('my-key');
  });

  it('lists reviews, omitting an absent studentId and forwarding a present one', async () => {
    const seen: (string | null)[] = [];
    server.use(
      http.get(`${base}/reviews`, ({ request }) => {
        seen.push(new URL(request.url).searchParams.get('studentId'));
        return HttpResponse.json({ items: [reviewDto] } satisfies ReviewListResponse);
      }),
    );
    expect((await client.reviews.list()).items).toHaveLength(1);
    expect((await client.reviews.list(studentId)).items).toHaveLength(1);
    expect(seen).toEqual([null, studentId]);
  });
});
