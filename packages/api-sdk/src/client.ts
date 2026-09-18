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
import createClient, { type Middleware } from 'openapi-fetch';
import type { paths } from './generated/schema';

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
  // `baseUrl` keeps its public meaning — it includes `/api/v1`, and the
  // generated path keys carry that prefix too. openapi-fetch joins with
  // `new URL(path, baseUrl)`, which would discard a path prefix, so it gets the
  // origin instead. An origin-only `baseUrl` is a no-op here and still correct.
  const origin = opts.baseUrl.replace(/\/api\/v1\/?$/, '');
  const client = createClient<paths>({ baseUrl: origin });

  const middleware: Middleware = {
    onRequest({ request }) {
      const token = opts.getAccessToken?.();
      if (token) request.headers.set('Authorization', `Bearer ${token}`);
      return request;
    },
    async onResponse({ response }) {
      if (response.ok) return undefined;
      // Response bodies are stateful: read a clone and leave the original alone.
      const body = await response.clone().json().catch(() => null);
      const envelope = ErrorEnvelopeSchema.safeParse(body);
      if (envelope.success) {
        throw new ApiError(
          response.status,
          envelope.data.error.code,
          envelope.data.error.message,
          envelope.data.error.details,
        );
      }
      throw new ApiError(response.status, 'INTERNAL', `Unexpected response (${response.status})`);
    },
  };
  client.use(middleware);

  // The generated types cover the compile-time contract; the contracts schemas
  // stay the runtime guard, so a misbehaving server still raises instead of
  // passing a malformed body through.
  const parse = async <T>(
    call: Promise<{ data?: unknown }>,
    schema: { parse: (value: unknown) => T },
  ): Promise<T> => {
    const { data } = await call;
    return schema.parse(data);
  };

  return {
    auth: {
      register: (input) =>
        parse(client.POST('/api/v1/auth/register', { body: input }), AuthResponseSchema),
      login: (input) => parse(client.POST('/api/v1/auth/login', { body: input }), AuthResponseSchema),
      refresh: (refreshToken) =>
        parse(client.POST('/api/v1/auth/refresh', { body: { refreshToken } }), AuthResponseSchema),
      me: () => parse(client.GET('/api/v1/auth/me'), AuthUserSchema),
    },
    reviews: {
      create: (input, idempotencyKey) =>
        parse(
          client.POST('/api/v1/reviews', {
            body: input,
            headers: { 'Idempotency-Key': idempotencyKey },
          }),
          ReviewDtoSchema,
        ),
      list: (studentId) =>
        parse(
          client.GET('/api/v1/reviews', {
            // The document marks `studentId` required even though the endpoint
            // treats it as optional, so the empty case is built explicitly
            // rather than relying on the serializer to drop `undefined`.
            params: { query: (studentId === undefined ? {} : { studentId }) as { studentId: string } },
          }),
          ReviewListResponseSchema,
        ),
    },
  };
}
