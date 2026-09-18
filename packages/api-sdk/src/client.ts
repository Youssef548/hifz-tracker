import {
  AuthResponseSchema,
  AuthUserSchema,
  ErrorEnvelopeSchema,
  ReviewDtoSchema,
  ReviewListResponseSchema,
} from '@hifz/contracts';
import type {
  AuthResponse,
  AuthUser,
  CreateReviewRequest,
  LoginRequest,
  RegisterRequest,
  ReviewDto,
  ReviewListResponse,
} from '@hifz/contracts';

export class ApiError extends Error {
  constructor(
    readonly status: number,
    readonly code: string,
    message: string,
    readonly details?: unknown,
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

export interface ApiClientOptions {
  baseUrl: string;
  getAccessToken?: () => string | undefined;
}

async function request<T>(
  opts: ApiClientOptions,
  schema: { parse: (v: unknown) => T },
  path: string,
  init: RequestInit,
): Promise<T> {
  const headers = new Headers(init.headers);
  const token = opts.getAccessToken?.();
  if (token) headers.set('Authorization', `Bearer ${token}`);
  const res = await fetch(`${opts.baseUrl}${path}`, { ...init, headers });
  const body: unknown = await res.json().catch(() => null);
  if (!res.ok) {
    const envelope = ErrorEnvelopeSchema.safeParse(body);
    if (envelope.success) {
      throw new ApiError(
        res.status,
        envelope.data.error.code,
        envelope.data.error.message,
        envelope.data.error.details,
      );
    }
    throw new ApiError(res.status, 'INTERNAL', `Unexpected response (${res.status})`);
  }
  return schema.parse(body);
}

export interface ApiClient {
  auth: {
    register(input: RegisterRequest): Promise<AuthResponse>;
    login(input: LoginRequest): Promise<AuthResponse>;
    refresh(refreshToken: string): Promise<AuthResponse>;
    me(): Promise<AuthUser>;
  };
  reviews: {
    create(input: CreateReviewRequest, idempotencyKey: string): Promise<ReviewDto>;
    list(studentId?: string): Promise<ReviewListResponse>;
  };
}

export function createApiClient(opts: ApiClientOptions): ApiClient {
  const json = (method: string, body: unknown): RequestInit => ({
    method,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  return {
    auth: {
      register: (input) => request(opts, AuthResponseSchema, '/auth/register', json('POST', input)),
      login: (input) => request(opts, AuthResponseSchema, '/auth/login', json('POST', input)),
      refresh: (refreshToken) =>
        request(opts, AuthResponseSchema, '/auth/refresh', json('POST', { refreshToken })),
      me: () => request(opts, AuthUserSchema, '/auth/me', { method: 'GET' }),
    },
    reviews: {
      create: (input, idempotencyKey) =>
        request(opts, ReviewDtoSchema, '/reviews', {
          ...json('POST', input),
          headers: { 'Content-Type': 'application/json', 'Idempotency-Key': idempotencyKey },
        }),
      list: (studentId) =>
        request(
          opts,
          ReviewListResponseSchema,
          `/reviews${studentId ? `?studentId=${encodeURIComponent(studentId)}` : ''}`,
          { method: 'GET' },
        ),
    },
  };
}
