# Hifz Tracker — Walking Skeleton Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the walking skeleton that proves every architectural boundary: repo scaffold (pnpm + Turborepo + Melos), auth end-to-end, and a student logging a review from the Arabic-RTL Flutter app (offline-capable via outbox) that appears on the teacher dashboard.

**Architecture:** Single NestJS API serving one Next.js web app (landing + dashboard + PWA) and a Flutter app composed from layered Dart packages. `packages/contracts` (zod schemas) is the single source of truth consumed directly by API and web; OpenAPI → generated `dart-packages/api_client`; `dart-packages/data` owns drift cache + write outbox. Dependency rules enforced by ESLint boundaries (TS) and single public entries (Dart).

**Tech Stack:** pnpm workspaces, Turborepo, Melos; NestJS 11, Prisma 6, PostgreSQL 16, Redis 7 (compose only); Next.js 15 App Router, Tailwind, Serwist PWA; zod 3 + nestjs-zod; Flutter stable, Riverpod, drift, dio, flutter_secure_storage, connectivity_plus; openapi-generator-cli (Java 17 required) with `dart-dio`; GitHub Actions CI.

**Spec:** `docs/superpowers/specs/2026-09-18-monorepo-architecture-design.md`

## Global Constraints

- Node 22 LTS, pnpm via Corepack; Flutter stable channel; all TS packages strict mode.
- `apps/*` never import each other; `packages/*` / `dart-packages/*` never import from `apps/*`; `contracts` depends only on `zod`; no deep imports — every package has one public entry.
- `dart-packages/api_client` is generated — never hand-edit; regenerate with the gen script.
- Error responses always use the envelope `{ error: { code, message, details? } }`.
- Write endpoints that create resources accept `Idempotency-Key` header (client-generated UUID).
- API base path: `/api/v1`. Roles: `STUDENT | TEACHER | ADMIN` (in contracts).
- Mobile UI is Arabic-first RTL (`ar` default locale); web UI is English-only.
- Commits: conventional prefixes (`feat:`, `test:`, `chore:`, `docs:`). TDD: failing test → code → pass → commit. Scaffold tasks verify-by-boot instead of TDD.
- Local infra via `docker compose up -d` (Postgres 16 on `5432`, Redis 7 on `6379`); env vars validated at boot, never committed (`.env.example` only).

---

### Task 1: Repo root scaffold

**Files:**
- Create: `package.json`, `pnpm-workspace.yaml`, `turbo.json`, `.gitignore`, `.node-version`, `.editorconfig`, `README.md`, `docker-compose.yml`, `.env.example`

**Interfaces:**
- Produces: workspace globs `apps/*`, `packages/*`; turbo tasks `build`, `dev`, `lint`, `test`, `typecheck` (all `^`-connected); compose services `db` (postgres:16, db `hifz`, user `hifz`, pass `hifz`) and `redis` (redis:7).

- [ ] **Step 1: Root files**

`pnpm-workspace.yaml`:
```yaml
packages:
  - "apps/*"
  - "packages/*"
```

`package.json`:
```json
{
  "name": "hifz-tracker",
  "private": true,
  "packageManager": "pnpm@9.15.0",
  "scripts": {
    "dev": "turbo run dev",
    "build": "turbo run build",
    "lint": "turbo run lint",
    "test": "turbo run test",
    "typecheck": "turbo run typecheck",
    "gen:dart": "./scripts/gen-dart.sh"
  },
  "devDependencies": {
    "turbo": "^2.3.0"
  }
}
```

`turbo.json`:
```json
{
  "$schema": "https://turbo.build/schema.json",
  "tasks": {
    "build": { "dependsOn": ["^build"], "outputs": [".next/**", "!.next/cache/**", "dist/**"] },
    "dev": { "cache": false, "persistent": true },
    "lint": {},
    "test": { "dependsOn": ["^build"] },
    "typecheck": { "dependsOn": ["^typecheck"] }
  }
}
```

`.gitignore`:
```
node_modules/
dist/
.next/
.turbo/
coverage/
generated/
*.tsbuildinfo
.env
.env.*
!.env.example
apps/mobile/.dart_tool/
apps/mobile/build/
.dart_tool/
melos_staging/
```

`.node-version`: `22`

`docker-compose.yml`:
```yaml
services:
  db:
    image: postgres:16
    environment:
      POSTGRES_DB: hifz
      POSTGRES_USER: hifz
      POSTGRES_PASSWORD: hifz
    ports: ["5432:5432"]
    volumes: [pgdata:/var/lib/postgresql/data]
  redis:
    image: redis:7
    ports: ["6379:6379"]
volumes:
  pgdata:
```

`.env.example` (root, documents conventions only; apps get their own in later tasks):
```
DATABASE_URL=postgresql://hifz:hifz@localhost:5432/hifz
REDIS_URL=redis://localhost:6379
JWT_ACCESS_SECRET=change-me-32-chars-min
JWT_ACCESS_TTL=900
REFRESH_TOKEN_TTL_DAYS=30
API_PORT=3001
WEB_URL=http://localhost:3000
```

`.editorconfig`: root=true, utf-8, lf, final newline, 2-space indent (json/yaml/md), 4-space (dart via editor default).

`README.md`: one paragraph (what the project is), monorepo map (apps/packages/dart-packages), three commands: `docker compose up -d`, `pnpm install`, `pnpm dev`. Note Melos setup happens in Task 14.

- [ ] **Step 2: Verify workspace resolves**

Run: `corepack enable && pnpm install`
Expected: install succeeds; lockfile created; no workspace errors.

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "chore: repo root scaffold (pnpm workspace, turbo, compose)"
```

---

### Task 2: packages/config — TS + ESLint presets with boundary enforcement

**Files:**
- Create: `packages/config/package.json`, `packages/config/tsconfig/base.json`, `packages/config/tsconfig/nest.json`, `packages/config/tsconfig/next.json`, `packages/config/tsconfig/react-lib.json`, `packages/config/eslint/index.js`, `packages/config/eslint/package.json`

**Interfaces:**
- Produces: `@hifz/config/tsconfig/*.json` presets; `@hifz/eslint-config` flat-config factory `defineConfig(options)` where `options.type` is `'app-web' | 'app-api' | 'package'` — boundary rules: files in `apps/` may not import from other `apps/*`; any file under `packages/` may not import from `apps/*`.

- [ ] **Step 1: Package manifests**

`packages/config/package.json`:
```json
{
  "name": "@hifz/config",
  "private": true,
  "files": ["tsconfig/"]
}
```

`packages/config/eslint/package.json`:
```json
{
  "name": "@hifz/eslint-config",
  "private": true,
  "type": "module",
  "main": "index.js",
  "dependencies": {
    "eslint-plugin-boundaries": "^4.1.1",
    "eslint-plugin-import": "^2.31.0"
  },
  "peerDependencies": { "eslint": "^9.0.0" }
}
```

- [ ] **Step 2: TS presets**

`tsconfig/base.json`:
```json
{
  "compilerOptions": {
    "strict": true,
    "target": "ES2023",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "declaration": true,
    "composite": true,
    "declarationMap": true
  }
}
```

`tsconfig/nest.json`: `{ "extends": "./base.json", "compilerOptions": { "module": "commonjs", "moduleResolution": "node", "emitDecoratorMetadata": true, "experimentalDecorators": true, "target": "ES2023", "outDir": "dist" }, "exclude": ["node_modules", "dist"] }`

`tsconfig/next.json`: `{ "extends": "./base.json", "compilerOptions": { "lib": ["dom", "dom.iterable", "ES2023"], "jsx": "preserve", "allowJs": true, "noEmit": true, "incremental": true, "composite": false }, "exclude": ["node_modules", ".next"] }`

`tsconfig/react-lib.json`: `{ "extends": "./base.json", "compilerOptions": { "lib": ["dom", "ES2023"], "jsx": "react-jsx", "noEmit": true, "composite": false } }`

- [ ] **Step 3: ESLint boundaries factory**

`packages/config/eslint/index.js`:
```js
import boundaries from 'eslint-plugin-boundaries';
import importPlugin from 'eslint-plugin-import';

export function defineConfig({ type }) {
  const isApp = type.startsWith('app-');
  const elements = [
    { type: 'app', pattern: 'apps/*' },
    { type: 'package', pattern: 'packages/*' },
    { type: 'dart', pattern: 'dart-packages/*' },
  ];
  const rules = [];
  rules.push({
    files: ['**/*.{ts,tsx}'],
    plugins: { boundaries, import: importPlugin },
    settings: {
      'boundaries/include': ['apps/**', 'packages/**'],
      'boundaries/elements': elements,
    },
    rules: {
      'boundaries/element-types': ['error', { default: 'disallow', rules: [
        { from: 'app', allow: ['package'] },
        { from: 'package', allow: [['package', { from: 'package', not: 'config' }]] },
      ]}],
      'import/no-extraneous-dependencies': 'error',
    },
  });
  if (isApp) {
    rules.push({
      files: ['apps/*/src/**/*.{ts,tsx}'],
      rules: { 'boundaries/no-unknown': 'error' },
    });
  }
  return rules;
}
```
(Exact rule syntax may need minor adjustment to the installed eslint-plugin-boundaries version — the invariant to keep: **apps import only packages; packages never import apps; packages import packages except `@hifz/config`.**)

- [ ] **Step 4: Verify**

Run: `pnpm install`
Expected: workspace links resolve (`pnpm ls -r --depth -1` lists both config packages).

- [ ] **Step 5: Commit**

```bash
git add -A && git commit -m "chore: shared tsconfig + eslint boundary presets"
```

---

### Task 3: packages/contracts — error envelope + auth DTOs (TDD)

**Files:**
- Create: `packages/contracts/package.json`, `packages/contracts/tsconfig.json`, `packages/contracts/vitest.config.ts`, `packages/contracts/src/index.ts`, `packages/contracts/src/error.ts`, `packages/contracts/src/auth.ts`, `packages/contracts/test/auth.test.ts`
- Test: `packages/contracts/test/auth.test.ts`

**Interfaces:**
- Produces (consumed by Tasks 7, 8, 10, 12): `ErrorEnvelopeSchema`, `ErrorCodes`, `RoleSchema`/`Role`, `RegisterRequestSchema` `{ name; email; password; role?: 'STUDENT'|'TEACHER' }`, `LoginRequestSchema` `{ email; password }`, `RefreshRequestSchema` `{ refreshToken }`, `AuthUserSchema` `{ id: uuid; name; email; role }`, `AuthResponseSchema` `{ user; accessToken; refreshToken }`.

- [ ] **Step 1: Package setup**

`package.json`:
```json
{
  "name": "@hifz/contracts",
  "version": "0.1.0",
  "type": "module",
  "exports": { ".": "./src/index.ts" },
  "scripts": { "test": "vitest run", "typecheck": "tsc --noEmit" },
  "dependencies": { "zod": "^3.24.0" },
  "devDependencies": { "typescript": "^5.7.0", "vitest": "^2.1.0" }
}
```
`tsconfig.json`: `{ "extends": "@hifz/config/tsconfig/base.json", "include": ["src", "test"] }`
`vitest.config.ts`: `import { defineConfig } from 'vitest/config'; export default defineConfig({ test: { environment: 'node' } });`

- [ ] **Step 2: Write failing tests** — `test/auth.test.ts`:
```ts
import { describe, expect, it } from 'vitest';
import {
  AuthResponseSchema, ErrorEnvelopeSchema, LoginRequestSchema, RegisterRequestSchema, RoleSchema,
} from '../src/index';

describe('auth contracts', () => {
  it('accepts a valid register payload and defaults role to STUDENT', () => {
    const parsed = RegisterRequestSchema.parse({
      name: 'Ahmad', email: 'a@b.com', password: 'password123',
    });
    expect(parsed.role).toBe('STUDENT');
  });
  it('rejects short passwords and bad emails', () => {
    expect(RegisterRequestSchema.safeParse({ name: 'A', email: 'nope', password: 'short' }).success).toBe(false);
  });
  it('allows only STUDENT or TEACHER self-registration', () => {
    expect(RegisterRequestSchema.safeParse({ name: 'x x', email: 'a@b.com', password: 'password123', role: 'ADMIN' }).success).toBe(false);
    expect(RoleSchema.parse('TEACHER')).toBe('TEACHER');
  });
  it('parses login request', () => {
    expect(LoginRequestSchema.parse({ email: 'a@b.com', password: 'pw' })).toBeTruthy();
  });
  it('parses a full auth response', () => {
    const ok = AuthResponseSchema.safeParse({
      user: { id: '9b2f6f38-1e63-4c8a-9c1a-3f8c2c2e6c11', name: 'A', email: 'a@b.com', role: 'STUDENT' },
      accessToken: 'aa', refreshToken: 'rr',
    });
    expect(ok.success).toBe(true);
  });
  it('parses the error envelope', () => {
    expect(ErrorEnvelopeSchema.parse({ error: { code: 'X', message: 'm' } })).toBeTruthy();
  });
});
```

- [ ] **Step 3: Run tests — expect failure** — Run: `pnpm --filter @hifz/contracts test` → FAIL (cannot resolve `../src/index`).

- [ ] **Step 4: Implement** — `src/error.ts`:
```ts
import { z } from 'zod';

export const ErrorEnvelopeSchema = z.object({
  error: z.object({
    code: z.string(),
    message: z.string(),
    details: z.unknown().optional(),
  }),
});
export type ErrorEnvelope = z.infer<typeof ErrorEnvelopeSchema>;

export const ErrorCodes = {
  VALIDATION_ERROR: 'VALIDATION_ERROR',
  INVALID_CREDENTIALS: 'INVALID_CREDENTIALS',
  UNAUTHORIZED: 'UNAUTHORIZED',
  FORBIDDEN: 'FORBIDDEN',
  NOT_FOUND: 'NOT_FOUND',
  CONFLICT: 'CONFLICT',
  INTERNAL: 'INTERNAL',
} as const;
export type ErrorCode = keyof typeof ErrorCodes;
```

`src/auth.ts`:
```ts
import { z } from 'zod';

export const RoleSchema = z.enum(['STUDENT', 'TEACHER', 'ADMIN']);
export type Role = z.infer<typeof RoleSchema>;

export const RegisterRequestSchema = z.object({
  name: z.string().min(2).max(100),
  email: z.string().email(),
  password: z.string().min(8).max(72),
  role: z.enum(['STUDENT', 'TEACHER']).default('STUDENT'),
});
export type RegisterRequest = z.infer<typeof RegisterRequestSchema>;

export const LoginRequestSchema = z.object({ email: z.string().email(), password: z.string().min(1) });
export type LoginRequest = z.infer<typeof LoginRequestSchema>;

export const RefreshRequestSchema = z.object({ refreshToken: z.string().min(1) });
export type RefreshRequest = z.infer<typeof RefreshRequestSchema>;

export const AuthUserSchema = z.object({
  id: z.string().uuid(),
  name: z.string(),
  email: z.string().email(),
  role: RoleSchema,
});
export type AuthUser = z.infer<typeof AuthUserSchema>;

export const AuthResponseSchema = z.object({
  user: AuthUserSchema,
  accessToken: z.string(),
  refreshToken: z.string(),
});
export type AuthResponse = z.infer<typeof AuthResponseSchema>;
```

`src/index.ts`:
```ts
export * from './error';
export * from './auth';
```

- [ ] **Step 5: Run tests — pass** — Run: `pnpm --filter @hifz/contracts test` → PASS.

- [ ] **Step 6: Commit** — `git add -A && git commit -m "feat(contracts): error envelope + auth DTOs"`

---

### Task 4: packages/contracts — reviews DTOs + idempotency + Quran metadata (TDD)

**Files:**
- Create: `packages/contracts/src/reviews.ts`, `packages/contracts/src/quran.ts`, `packages/contracts/quran/surahs.json`, `packages/contracts/scripts/fetch-quran-metadata.mjs`, `packages/contracts/test/reviews.test.ts`, `packages/contracts/test/quran.test.ts`
- Modify: `packages/contracts/src/index.ts`, `packages/contracts/package.json` (add `quran:data` script)

**Interfaces:**
- Produces: `ReviewQuality` = `'GOOD'|'FAIR'|'POOR'`; `CreateReviewRequestSchema` `{ surahNumber: int 1..114; ayahFrom: int ≥1; ayahTo ≥ ayahFrom; quality; loggedAt?: Date }`; `ReviewDtoSchema` `{ id: uuid; studentId: uuid; surahNumber; ayahFrom; ayahTo; quality; loggedAt: ISO datetime }`; `ReviewListResponseSchema` `{ items: ReviewDto[] }`; `IDEMPOTENCY_KEY_HEADER = 'Idempotency-Key'`; `Surah` type `{ number; nameAr; nameEn; nameTranslit; ayahCount }`; `surahs: readonly Surah[]`.

- [ ] **Step 1: Fetch metadata (one-time seed)**

`scripts/fetch-quran-metadata.mjs`:
```js
import { writeFileSync } from 'node:fs';
const res = await fetch('https://api.alquran.cloud/v1/surah');
const { data } = await res.json();
const surahs = data.map((s) => ({
  number: s.number,
  nameAr: s.name,
  nameEn: s.englishName,
  nameTranslit: s.englishNameTranslation,
  ayahCount: s.numberOfAyahs,
}));
writeFileSync(new URL('../quran/surahs.json', import.meta.url), JSON.stringify(surahs, null, 2) + '\n');
console.log(`wrote ${surahs.length} surahs`);
```
Run: `node packages/contracts/scripts/fetch-quran-metadata.mjs` → writes `quran/surahs.json` (114 entries).
Add script: `"quran:data": "node scripts/fetch-quran-metadata.mjs"`.

- [ ] **Step 2: Failing tests** — `test/reviews.test.ts`:
```ts
import { describe, expect, it } from 'vitest';
import { CreateReviewRequestSchema, IDEMPOTENCY_KEY_HEADER } from '../src/index';

describe('review contracts', () => {
  it('accepts a valid review', () => {
    expect(CreateReviewRequestSchema.safeParse({ surahNumber: 1, ayahFrom: 1, ayahTo: 7, quality: 'GOOD' }).success).toBe(true);
  });
  it('rejects surah out of range and bad quality', () => {
    expect(CreateReviewRequestSchema.safeParse({ surahNumber: 115, ayahFrom: 1, ayahTo: 7, quality: 'GOOD' }).success).toBe(false);
    expect(CreateReviewRequestSchema.safeParse({ surahNumber: 1, ayahFrom: 1, ayahTo: 7, quality: 'GREAT' }).success).toBe(false);
  });
  it('rejects ayahTo < ayahFrom', () => {
    expect(CreateReviewRequestSchema.safeParse({ surahNumber: 2, ayahFrom: 10, ayahTo: 5, quality: 'FAIR' }).success).toBe(false);
  });
  it('exports the idempotency header name', () => {
    expect(IDEMPOTENCY_KEY_HEADER).toBe('Idempotency-Key');
  });
});
```
`test/quran.test.ts`:
```ts
import { describe, expect, it } from 'vitest';
import { surahs } from '../src/index';

describe('quran metadata', () => {
  it('has 114 sequentially numbered surahs', () => {
    expect(surahs).toHaveLength(114);
    expect(surahs.map((s) => s.number)).toEqual(Array.from({ length: 114 }, (_, i) => i + 1));
  });
  it('totals 6236 ayahs', () => {
    expect(surahs.reduce((n, s) => n + s.ayahCount, 0)).toBe(6236);
  });
  it('carries Arabic and English names', () => {
    expect(surahs[0].nameAr).toContain('الفاتحة');
    expect(surahs[0].nameEn).toBe('Al-Faatiha');
  });
});
```

- [ ] **Step 3: Run — expect failure** — Run: `pnpm --filter @hifz/contracts test` → FAIL (missing exports).

- [ ] **Step 4: Implement** — `src/reviews.ts`:
```ts
import { z } from 'zod';
import { AuthUserSchema } from './auth'; // re-exported shape reuse ONLY where needed; do not couple: remove if unused

export const ReviewQualitySchema = z.enum(['GOOD', 'FAIR', 'POOR']);
export type ReviewQuality = z.infer<typeof ReviewQualitySchema>;

export const CreateReviewRequestSchema = z
  .object({
    surahNumber: z.number().int().min(1).max(114),
    ayahFrom: z.number().int().min(1),
    ayahTo: z.number().int().min(1),
    quality: ReviewQualitySchema,
    loggedAt: z.coerce.date().optional(),
  })
  .refine((v) => v.ayahTo >= v.ayahFrom, { message: 'ayahTo must be >= ayahFrom' });
export type CreateReviewRequest = z.infer<typeof CreateReviewRequestSchema>;

export const ReviewDtoSchema = z.object({
  id: z.string().uuid(),
  studentId: z.string().uuid(),
  surahNumber: z.number().int(),
  ayahFrom: z.number().int(),
  ayahTo: z.number().int(),
  quality: ReviewQualitySchema,
  loggedAt: z.string().datetime(),
});
export type ReviewDto = z.infer<typeof ReviewDtoSchema>;

export const ReviewListResponseSchema = z.object({ items: z.array(ReviewDtoSchema) });
export type ReviewListResponse = z.infer<typeof ReviewListResponseSchema>;

export const IDEMPOTENCY_KEY_HEADER = 'Idempotency-Key';
```
(Delete the unused `AuthUserSchema` import — shown only as a note that reviews does NOT depend on auth.)

`src/quran.ts`:
```ts
import surahsJson from '../quran/surahs.json';

export interface Surah {
  number: number; nameAr: string; nameEn: string; nameTranslit: string; ayahCount: number;
}
export const surahs: readonly Surah[] = Object.freeze(surahsJson);
export function surahByNumber(n: number): Surah | undefined {
  return surahs.find((s) => s.number === n);
}
```
Update `src/index.ts`:
```ts
export * from './error';
export * from './auth';
export * from './reviews';
export * from './quran';
```
Add to package.json: `"resolveJsonModule"` is covered by base strict config; ensure tsconfig `include` covers `quran/*.json` (add `"quran"` to include array).

- [ ] **Step 5: Run — pass** — Run: `pnpm --filter @hifz/contracts test` → PASS (all files).

- [ ] **Step 6: Commit** — `git add -A && git commit -m "feat(contracts): review DTOs, idempotency header, quran metadata"`

---

### Task 5: apps/api — Nest scaffold, env validation, envelope filter, health

**Files:**
- Create: `apps/api/**` (Nest scaffold), `apps/api/src/config/env.ts`, `apps/api/src/filters/error-envelope.filter.ts`, `apps/api/src/main.ts`, `apps/api/.env.example`, `apps/api/test/app.e2e-spec.ts`
- Modify: `apps/api/package.json` (scripts), `apps/api/tsconfig.json`, eslint config

**Interfaces:**
- Produces: API bootstrapped with global prefix `/api/v1`, zod validation pipe, error-envelope filter; `GET /api/v1/health` → `{ status: 'ok' }`; `Env` type from `validateEnv()` used by all later tasks (`DATABASE_URL`, `JWT_ACCESS_SECRET`, `JWT_ACCESS_TTL` default 900, `REFRESH_TOKEN_TTL_DAYS` default 30, `PORT` default 3001).

- [ ] **Step 1: Scaffold** — Run:
```bash
pnpm dlx @nestjs/cli@11 new apps/api --package-manager pnpm --strict --skip-git --skip-hc
```
Then `pnpm --filter api add nestjs-zod @nestjs/config` and `pnpm --filter api add -D tsx vitest` (tsx for later spec script).
Set scripts in `apps/api/package.json`: `"dev": "nest start --watch"`, `"build": "nest build"`, `"test": "jest"` (nest default), `"test:e2e": "jest --config ./test/jest-e2e.json"`, `"typecheck": "tsc --noEmit"`, `"spec": "tsx src/spec.ts"` (spec script arrives in Task 9).
Extend `tsconfig.json` from `@hifz/config/tsconfig/nest.json`; set up `eslint.config.mjs` using `defineConfig({ type: 'app-api' })` from `@hifz/eslint-config`.
Add workspace deps: `pnpm --filter api add @hifz/contracts --workspace`.

- [ ] **Step 2: Env validation** — `src/config/env.ts`:
```ts
import { z } from 'zod';

const EnvSchema = z.object({
  DATABASE_URL: z.string().url(),
  JWT_ACCESS_SECRET: z.string().min(32),
  JWT_ACCESS_TTL: z.coerce.number().int().positive().default(900),
  REFRESH_TOKEN_TTL_DAYS: z.coerce.number().int().positive().default(30),
  PORT: z.coerce.number().int().default(3001),
});

export type Env = z.infer<typeof EnvSchema>;

export function validateEnv(): Env {
  const parsed = EnvSchema.safeParse(process.env);
  if (!parsed.success) {
    throw new Error(`Invalid environment:\n${parsed.error.issues.map((i) => `  ${i.path.join('.')}: ${i.message}`).join('\n')}`);
  }
  return parsed.data;
}
```
Copy root `.env.example` values into `apps/api/.env`; validate in `main.ts` before bootstrap.

- [ ] **Step 3: Health controller + envelope filter**

`src/modules/health/health.controller.ts`:
```ts
import { Controller, Get } from '@nestjs/common';

@Controller('health')
export class HealthController {
  @Get()
  check() { return { status: 'ok' }; }
}
```
`src/filters/error-envelope.filter.ts`:
```ts
import { ArgumentsHost, Catch, ExceptionFilter, HttpException, HttpStatus, Logger } from '@nestjs/common';
import { ZodValidationException } from 'nestjs-zod';
import type { Response } from 'express';

@Catch()
export class ErrorEnvelopeFilter implements ExceptionFilter {
  private readonly logger = new Logger(ErrorEnvelopeFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const res = host.switchToHttp().getResponse<Response>();
    const { status, code, message, details } = this.map(exception);
    if (status >= 500) this.logger.error(exception instanceof Error ? exception.stack : String(exception));
    res.status(status).json({ error: { code, message, details } });
  }

  private map(exception: unknown): { status: number; code: string; message: string; details?: unknown } {
    if (exception instanceof ZodValidationException) {
      return { status: HttpStatus.BAD_REQUEST, code: 'VALIDATION_ERROR', message: 'Request validation failed', details: exception.getZodError().issues };
    }
    if (exception instanceof HttpException) {
      const body = exception.getResponse();
      const message = typeof body === 'string' ? body : ((body as { message?: string }).message ?? exception.message);
      const code = exception.getStatus() === 401 ? 'UNAUTHORIZED' : exception.getStatus() === 403 ? 'FORBIDDEN' : exception.getStatus() === 404 ? 'NOT_FOUND' : exception.getStatus() === 409 ? 'CONFLICT' : 'INTERNAL';
      return { status: exception.getStatus(), code, message };
    }
    return { status: HttpStatus.INTERNAL_SERVER_ERROR, code: 'INTERNAL', message: 'Internal server error' };
  }
}
```
`src/main.ts`:
```ts
import { NestFactory } from '@nestjs/core';
import { ZodValidationPipe } from 'nestjs-zod';
import { AppModule } from './app.module';
import { ErrorEnvelopeFilter } from './filters/error-envelope.filter';
import { validateEnv } from './config/env';

async function bootstrap() {
  const env = validateEnv(); // fail fast before anything else runs
  const app = await NestFactory.create(AppModule);
  app.setGlobalPrefix('api/v1');
  app.useGlobalPipes(new ZodValidationPipe());
  app.useGlobalFilters(new ErrorEnvelopeFilter());
  app.enableCors({ origin: process.env.WEB_URL?.split(',') ?? true, credentials: true });
  await app.listen(env.PORT);
}
void bootstrap();
```
(Register `HealthController` in `AppModule`.)

- [ ] **Step 4: E2E test health + envelope** — `test/app.e2e-spec.ts`:
```ts
import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import request from 'supertest';
import { ZodValidationPipe } from 'nestjs-zod';
import { AppModule } from '../src/app.module';
import { ErrorEnvelopeFilter } from '../src/filters/error-envelope.filter';

describe('app (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({ imports: [AppModule] }).compile();
    app = moduleRef.createNestApplication();
    app.setGlobalPrefix('api/v1');
    app.useGlobalPipes(new ZodValidationPipe()) as unknown as ValidationPipe;
    app.useGlobalFilters(new ErrorEnvelopeFilter());
    await app.init();
  });

  afterAll(async () => app.close());

  it('GET /api/v1/health returns ok', async () => {
    const res = await request(app.getHttpServer()).get('/api/v1/health').expect(200);
    expect(res.body).toEqual({ status: 'ok' });
  });

  it('returns the error envelope for unknown routes', async () => {
    const res = await request(app.getHttpServer()).get('/api/v1/nope').expect(404);
    expect(res.body.error).toMatchObject({ code: 'NOT_FOUND' });
  });
});
```
Set jest-e2e env to load `apps/api/.env` (`setupFiles: ['dotenv/config']`).

- [ ] **Step 5: Run** — Run: `pnpm --filter api test:e2e` → PASS (2 tests). Boot check: `pnpm --filter api dev` then `curl localhost:3001/api/v1/health` → `{"status":"ok"}`.

- [ ] **Step 6: Commit** — `git add -A && git commit -m "feat(api): nest scaffold, env validation, envelope filter, health"`

---

### Task 6: apps/api — Prisma schema + migrations

**Files:**
- Create: `apps/api/prisma/schema.prisma`, migration SQL (generated)
- Modify: `apps/api/package.json` (add `prisma` + `@prisma/client` deps, `db:migrate` / `db:deploy` scripts), `apps/api/src/prisma/prisma.module.ts`, `apps/api/src/prisma/prisma.service.ts`

**Interfaces:**
- Produces: Prisma models used by Tasks 7–8: `User { id uuid pk; email unique; passwordHash; name; role Role; createdAt }`, `enum Role { STUDENT TEACHER ADMIN }`, `RefreshToken { id uuid pk; tokenHash unique; userId → User; expiresAt; createdAt }`, `ReviewLog { id uuid pk; studentId → User; surahNumber Int; ayahFrom Int; ayahTo Int; quality Quality; loggedAt DateTime; idempotencyKey String unique; @@index([studentId, loggedAt(sort: Desc)]) }`, `enum Quality { GOOD FAIR POOR }`; global `PrismaModule` exporting `PrismaService`.

- [ ] **Step 1: Schema** — `prisma/schema.prisma`:
```prisma
generator client { provider = "prisma-client-js" }
datasource db { provider = "postgresql"; url = env("DATABASE_URL") }

enum Role { STUDENT TEACHER ADMIN }
enum Quality { GOOD FAIR POOR }

model User {
  id           String   @id @default(uuid())
  email        String   @unique
  passwordHash String
  name         String
  role         Role     @default(STUDENT)
  createdAt    DateTime @default(now())
  refreshTokens RefreshToken[]
  reviewLogs   ReviewLog[]
}

model RefreshToken {
  id        String   @id @default(uuid())
  tokenHash String   @unique
  userId    String
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  expiresAt DateTime
  createdAt DateTime @default(now())
}

model ReviewLog {
  id              String   @id @default(uuid())
  studentId       String
  student         User     @relation(fields: [studentId], references: [id], onDelete: Cascade)
  surahNumber     Int
  ayahFrom        Int
  ayahTo          Int
  quality         Quality
  loggedAt        DateTime @default(now())
  idempotencyKey  String   @unique

  @@index([studentId, loggedAt(sort: Desc)])
}
```

- [ ] **Step 2: Migrate** — Run:
```bash
docker compose up -d
pnpm --filter api exec prisma migrate dev --name init
```
Expected: migration created in `prisma/migrations/`, applied to local `hifz` db.

- [ ] **Step 3: PrismaModule** — `src/prisma/prisma.service.ts`:
```ts
import { Injectable, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  async onModuleInit() { await this.$connect(); }
  async onModuleDestroy() { await this.$disconnect(); }
}
```
`src/prisma/prisma.module.ts`:
```ts
import { Global, Module } from '@nestjs/common';
import { PrismaService } from './prisma.service';

@Global()
@Module({ providers: [PrismaService], exports: [PrismaService] })
export class PrismaModule {}
```
Import in `AppModule`. Add scripts: `"db:migrate": "prisma migrate dev"`, `"db:deploy": "prisma migrate deploy"`.

- [ ] **Step 4: Verify + commit** — Run `pnpm --filter api test:e2e` → PASS (Prisma connects). `git add -A && git commit -m "feat(api): prisma schema + migrations + PrismaModule"`

---

### Task 7: apps/api — auth module (TDD e2e)

**Files:**
- Create: `apps/api/src/modules/auth/auth.module.ts`, `auth.service.ts`, `auth.controller.ts`, `jwt.strategy.ts`, `roles.guard.ts`, `roles.decorator.ts`, `token.service.ts`
- Test: `apps/api/test/auth.e2e-spec.ts`

**Interfaces:**
- Consumes: `@hifz/contracts` schemas (`RegisterRequestSchema`, `LoginRequestSchema`, `RefreshRequestSchema`, `AuthResponseSchema`), `PrismaService`, `Env`.
- Produces: routes `POST /api/v1/auth/register` (201 → `AuthResponse`), `POST /api/v1/auth/login` (200 → `AuthResponse`; failure 401 `INVALID_CREDENTIALS`), `POST /api/v1/auth/refresh` (200 → `AuthResponse`, rotates token), `GET /api/v1/auth/me` (200 → `AuthUser`, JWT-guarded); `@Roles(...roles)` decorator + `RolesGuard`; `request.user = { id, email, role, name }` for later tasks; `TokenService.issue(user): Promise<AuthResponse>` and `TokenService.verify(accessToken): JwtPayload { sub, role, email, name }`.

- [ ] **Step 1: Failing e2e tests** — `test/auth.e2e-spec.ts`:
```ts
import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import request from 'supertest';
import { ZodValidationPipe } from 'nestjs-zod';
import { AppModule } from '../src/app.module';
import { ErrorEnvelopeFilter } from '../src/filters/error-envelope.filter';
import { PrismaService } from '../src/prisma/prisma.service';

describe('auth (e2e)', () => {
  let app: INestApplication;
  let db: PrismaService;
  const email = `skeleton-${Date.now()}@test.dev`;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({ imports: [AppModule] }).compile();
    app = moduleRef.createNestApplication();
    app.setGlobalPrefix('api/v1');
    app.useGlobalPipes(new ZodValidationPipe()) as unknown as ValidationPipe;
    app.useGlobalFilters(new ErrorEnvelopeFilter());
    await app.init();
    db = app.get(PrismaService);
  });
  afterAll(async () => { await db.refreshToken.deleteMany({}); await db.user.deleteMany({}); await app.close(); });

  it('registers a student', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/v1/auth/register')
      .send({ name: 'Test Student', email, password: 'password123' })
      .expect(201);
    expect(res.body.user).toMatchObject({ email, role: 'STUDENT' });
    expect(res.body.accessToken).toBeTruthy();
    expect(res.body.refreshToken).toBeTruthy();
  });

  it('rejects duplicate email with CONFLICT envelope', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/v1/auth/register')
      .send({ name: 'Test Student', email, password: 'password123' })
      .expect(409);
    expect(res.body.error.code).toBe('CONFLICT');
  });

  it('logs in and returns tokens', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ email, password: 'password123' })
      .expect(200);
    expect(res.body.user.email).toBe(email);
  });

  it('rejects wrong password with INVALID_CREDENTIALS', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ email, password: 'wrong-password' })
      .expect(401);
    expect(res.body.error.code).toBe('INVALID_CREDENTIALS');
  });

  it('me returns the authed user', async () => {
    const login = await request(app.getHttpServer()).post('/api/v1/auth/login').send({ email, password: 'password123' });
    const res = await request(app.getHttpServer())
      .get('/api/v1/auth/me')
      .set('Authorization', `Bearer ${login.body.accessToken}`)
      .expect(200);
    expect(res.body.email).toBe(email);
  });

  it('refresh rotates the refresh token', async () => {
    const login = await request(app.getHttpServer()).post('/api/v1/auth/login').send({ email, password: 'password123' });
    const first = login.body.refreshToken as string;
    const res = await request(app.getHttpServer()).post('/api/v1/auth/refresh').send({ refreshToken: first }).expect(200);
    expect(res.body.refreshToken).not.toBe(first);
    await request(app.getHttpServer()).post('/api/v1/auth/refresh').send({ refreshToken: first }).expect(401); // old one is dead
  });
});
```

- [ ] **Step 2: Run — expect failure** — Run: `pnpm --filter api test:e2e -- auth` → FAIL (404s).

- [ ] **Step 3: Implement**

Deps: `pnpm --filter api add @nestjs/jwt @nestjs/passport passport passport-jwt bcrypt` and `-D @types/passport-jwt @types/bcrypt`.

`src/modules/auth/token.service.ts`:
```ts
import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { createHash, randomBytes } from 'node:crypto';
import { PrismaService } from '../../prisma/prisma.service';
import type { AuthResponse, AuthUser } from '@hifz/contracts';

export interface JwtPayload { sub: string; email: string; name: string; role: string }

@Injectable()
export class TokenService {
  constructor(
    private readonly jwt: JwtService,
    private readonly db: PrismaService,
  ) {}

  async issue(user: { id: string; email: string; name: string; role: string }): Promise<AuthResponse> {
    const accessToken = await this.jwt.signAsync<JwtPayload>({ sub: user.id, email: user.email, name: user.name, role: user.role });
    const refreshToken = randomBytes(48).toString('hex');
    const ttlDays = Number(process.env.REFRESH_TOKEN_TTL_DAYS ?? 30);
    await this.db.refreshToken.create({
      data: { tokenHash: this.hash(refreshToken), userId: user.id, expiresAt: new Date(Date.now() + ttlDays * 86_400_000) },
    });
    const authUser: AuthUser = { id: user.id, name: user.name, email: user.email, role: user.role as AuthUser['role'] };
    return { user: authUser, accessToken, refreshToken };
  }

  async rotate(refreshToken: string): Promise<AuthResponse> {
    const record = await this.db.refreshToken.findUnique({ where: { tokenHash: this.hash(refreshToken) }, include: { user: true } });
    if (!record || record.expiresAt < new Date()) throw new InvalidRefreshTokenError();
    await this.db.refreshToken.delete({ where: { id: record.id } });
    return this.issue(record.user);
  }

  private hash(token: string): string {
    return createHash('sha256').update(token).digest('hex');
  }
}

export class InvalidRefreshTokenError extends Error {}
```

`auth.service.ts`:
```ts
import { ConflictException, Injectable, UnauthorizedException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../../prisma/prisma.service';
import { RegisterRequest } from '@hifz/contracts';
import { InvalidRefreshTokenError, TokenService } from './token.service';

@Injectable()
export class AuthService {
  constructor(private readonly db: PrismaService, private readonly tokens: TokenService) {}

  async register(body: RegisterRequest) {
    const existing = await this.db.user.findUnique({ where: { email: body.email } });
    if (existing) throw new ConflictException('Email already registered');
    const user = await this.db.user.create({
      data: { email: body.email, name: body.name, role: body.role, passwordHash: await bcrypt.hash(body.password, 12) },
    });
    return this.tokens.issue(user);
  }

  async login(email: string, password: string) {
    const user = await this.db.user.findUnique({ where: { email } });
    if (!user || !(await bcrypt.compare(password, user.passwordHash))) {
      throw new UnauthorizedException('Invalid credentials');
    }
    return this.tokens.issue(user);
  }

  async refresh(refreshToken: string) {
    try {
      return await this.tokens.rotate(refreshToken);
    } catch (e) {
      if (e instanceof InvalidRefreshTokenError) throw new UnauthorizedException('Invalid refresh token');
      throw e;
    }
  }
}
```

`auth.controller.ts` (nestjs-zod DTO pattern):
```ts
import { Body, Controller, Get, Post, UseGuards, Request } from '@nestjs/common';
import { createZodDto } from 'nestjs-zod';
import { RegisterRequestSchema, LoginRequestSchema, RefreshRequestSchema } from '@hifz/contracts';
import { AuthService } from './auth.service';
import { JwtAuthGuard } from './jwt.strategy';
import { Roles } from './roles.decorator';
import { RolesGuard } from './roles.guard';

class RegisterDto extends createZodDto(RegisterRequestSchema) {}
class LoginDto extends createZodDto(LoginRequestSchema) {}
class RefreshDto extends createZodDto(RefreshRequestSchema) {}

@Controller('auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Post('register')
  register(@Body() body: RegisterDto) { return this.auth.register(body); }

  @Post('login')
  login(@Body() body: LoginDto) { return this.auth.login(body.email, body.password); }

  @Post('refresh')
  refresh(@Body() body: RefreshDto) { return this.auth.refresh(body.refreshToken); }

  @Get('me')
  @UseGuards(JwtAuthGuard, RolesGuard)
  me(@Request() req: { user: { id: string; email: string; name: string; role: string } }) { return req.user; }
}
```

`jwt.strategy.ts`:
```ts
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { AuthGuard, PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import type { JwtPayload } from './token.service';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor() {
    super({ jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(), secretOrKey: process.env.JWT_ACCESS_SECRET });
  }
  validate(payload: JwtPayload) {
    if (!payload?.sub) throw new UnauthorizedException();
    return { id: payload.sub, email: payload.email, name: payload.name, role: payload.role };
  }
}
export class JwtAuthGuard extends AuthGuard('jwt') {}
```

`roles.decorator.ts`:
```ts
import { SetMetadata } from '@nestjs/common';
export const ROLES_KEY = 'roles';
export const Roles = (...roles: string[]) => SetMetadata(ROLES_KEY, roles);
```

`roles.guard.ts`:
```ts
import { CanActivate, ExecutionContext, ForbiddenException, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ROLES_KEY } from './roles.decorator';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}
  canActivate(ctx: ExecutionContext): boolean {
    const required = this.reflector.getAllAndOverride<string[]>(ROLES_KEY, [ctx.getHandler(), ctx.getClass()]);
    if (!required?.length) return true;
    const { user } = ctx.switchToHttp().getRequest();
    if (!required.includes(user?.role)) throw new ForbiddenException();
    return true;
  }
}
```

`auth.module.ts`:
```ts
import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { JwtStrategy } from './jwt.strategy';
import { TokenService } from './token.service';

@Module({
  imports: [JwtModule.register({ secret: process.env.JWT_ACCESS_SECRET, signOptions: { expiresIn: Number(process.env.JWT_ACCESS_TTL ?? 900) } })],
  controllers: [AuthController],
  providers: [AuthService, TokenService, JwtStrategy],
})
export class AuthModule {}
```
Register in `AppModule`. Map `INVALID_CREDENTIALS`: in `ErrorEnvelopeFilter.map`, replace the generic 401 code with: `exception.getStatus() === 401 ? (String((exception.getResponse() as { message?: string }).message).includes('credentials') ? 'INVALID_CREDENTIALS' : 'UNAUTHORIZED') : ...`.

- [ ] **Step 4: Run — pass** — Run: `pnpm --filter api test:e2e` → PASS (all suites).

- [ ] **Step 5: Commit** — `git add -A && git commit -m "feat(api): auth module — register/login/refresh/me with roles"`

---

### Task 8: apps/api — reviews module, idempotent create (TDD e2e)

**Files:**
- Create: `apps/api/src/modules/reviews/reviews.module.ts`, `reviews.service.ts`, `reviews.controller.ts`
- Test: `apps/api/test/reviews.e2e-spec.ts`

**Interfaces:**
- Consumes: `CreateReviewRequestSchema`, `ReviewDtoSchema`, `ReviewListResponseSchema`, `IDEMPOTENCY_KEY_HEADER` from `@hifz/contracts`; guards from Task 7; `PrismaService`.
- Produces: `POST /api/v1/reviews` — role `STUDENT`, requires `Idempotency-Key` header (400 if missing); replays return the **existing** review with 200, first create 201; `GET /api/v1/reviews?studentId=` — `STUDENT` always sees own (param ignored/overridden), `TEACHER` must pass `studentId` (400 if absent) → `{ items: ReviewDto[] }` newest first.

- [ ] **Step 1: Failing e2e tests** — `test/reviews.e2e-spec.ts`:
```ts
import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import request from 'supertest';
import { randomUUID } from 'node:crypto';
import { ZodValidationPipe } from 'nestjs-zod';
import { AppModule } from '../src/app.module';
import { ErrorEnvelopeFilter } from '../src/filters/error-envelope.filter';
import { PrismaService } from '../src/prisma/prisma.service';

describe('reviews (e2e)', () => {
  let app: INestApplication;
  let db: PrismaService;
  let studentToken: string;
  let teacherToken: string;
  let studentId: string;
  const idem = randomUUID();

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({ imports: [AppModule] }).compile();
    app = moduleRef.createNestApplication();
    app.setGlobalPrefix('api/v1');
    app.useGlobalPipes(new ZodValidationPipe()) as unknown as ValidationPipe;
    app.useGlobalFilters(new ErrorEnvelopeFilter());
    await app.init();
    db = app.get(PrismaService);
    const s = await request(app.getHttpServer()).post('/api/v1/auth/register')
      .send({ name: 'Stu Dent', email: `stu-${Date.now()}@t.dev`, password: 'password123' });
    studentToken = s.body.accessToken; studentId = s.body.user.id;
    const t = await request(app.getHttpServer()).post('/api/v1/auth/register')
      .send({ name: 'Tea Cher', email: `tea-${Date.now()}@t.dev`, password: 'password123', role: 'TEACHER' });
    teacherToken = t.body.accessToken;
  });
  afterAll(async () => { await db.refreshToken.deleteMany({}); await db.reviewLog.deleteMany({}); await db.user.deleteMany({}); await app.close(); });

  const payload = { surahNumber: 1, ayahFrom: 1, ayahTo: 7, quality: 'GOOD' as const };

  it('requires an idempotency key', async () => {
    const res = await request(app.getHttpServer()).post('/api/v1/reviews').set('Authorization', `Bearer ${studentToken}`).send(payload).expect(400);
    expect(res.body.error.code).toBe('VALIDATION_ERROR');
  });

  it('creates a review (201) and replays idempotently (200, same id)', async () => {
    const first = await request(app.getHttpServer()).post('/api/v1/reviews')
      .set('Authorization', `Bearer ${studentToken}`).set('Idempotency-Key', idem).send(payload).expect(201);
    const second = await request(app.getHttpServer()).post('/api/v1/reviews')
      .set('Authorization', `Bearer ${studentToken}`).set('Idempotency-Key', idem).send(payload).expect(200);
    expect(second.body.id).toBe(first.body.id);
    expect(first.body).toMatchObject({ surahNumber: 1, quality: 'GOOD', studentId });
  });

  it('students list only their own reviews', async () => {
    const res = await request(app.getHttpServer()).get('/api/v1/reviews').set('Authorization', `Bearer ${studentToken}`).expect(200);
    expect(res.body.items.every((r: { studentId: string }) => r.studentId === studentId)).toBe(true);
  });

  it('teachers must pass studentId', async () => {
    await request(app.getHttpServer()).get('/api/v1/reviews').set('Authorization', `Bearer ${teacherToken}`).expect(400);
    const res = await request(app.getHttpServer()).get(`/api/v1/reviews?studentId=${studentId}`).set('Authorization', `Bearer ${teacherToken}`).expect(200);
    expect(res.body.items.length).toBeGreaterThanOrEqual(1);
  });

  it('students cannot use teacher-only listing of others', async () => {
    await request(app.getHttpServer()).get(`/api/v1/reviews?studentId=${randomUUID()}`).set('Authorization', `Bearer ${studentToken}`).expect(200)
      .then((res) => expect(res.body.items).toHaveLength(1)); // still own data, param ignored
  });
});
```

- [ ] **Step 2: Run — expect failure** — `pnpm --filter api test:e2e -- reviews` → FAIL.

- [ ] **Step 3: Implement** — `reviews.service.ts`:
```ts
import { BadRequestException, Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import type { CreateReviewRequest, ReviewDto } from '@hifz/contracts';

@Injectable()
export class ReviewsService {
  constructor(private readonly db: PrismaService) {}

  async create(studentId: string, idempotencyKey: string, body: CreateReviewRequest): Promise<{ review: ReviewDto; replayed: boolean }> {
    const existing = await this.db.reviewLog.findUnique({ where: { idempotencyKey } });
    if (existing) return { review: this.toDto(existing), replayed: true };
    const created = await this.db.reviewLog.create({
      data: { studentId, idempotencyKey, surahNumber: body.surahNumber, ayahFrom: body.ayahFrom, ayahTo: body.ayahTo, quality: body.quality, loggedAt: body.loggedAt ?? new Date() },
    });
    return { review: this.toDto(created), replayed: false };
  }

  async list(requester: { id: string; role: string }, studentId?: string) {
    let target = studentId;
    if (requester.role === 'STUDENT') target = requester.id;
    else if (!target) throw new BadRequestException('studentId is required for teachers');
    const rows = await this.db.reviewLog.findMany({ where: { studentId: target }, orderBy: { loggedAt: 'desc' }, take: 100 });
    return { items: rows.map((r) => this.toDto(r)) };
  }

  private toDto(r: { id: string; studentId: string; surahNumber: number; ayahFrom: number; ayahTo: number; quality: string; loggedAt: Date }): ReviewDto {
    return { id: r.id, studentId: r.studentId, surahNumber: r.surahNumber, ayahFrom: r.ayahFrom, ayahTo: r.ayahTo, quality: r.quality as ReviewDto['quality'], loggedAt: r.loggedAt.toISOString() };
  }
}
```

`reviews.controller.ts`:
```ts
import { Body, Controller, Get, Headers, Post, Query, Request, UseGuards } from '@nestjs/common';
import { createZodDto } from 'nestjs-zod';
import { CreateReviewRequestSchema, IDEMPOTENCY_KEY_HEADER } from '@hifz/contracts';
import { JwtAuthGuard } from '../auth/jwt.strategy';
import { Roles } from '../auth/roles.decorator';
import { RolesGuard } from '../auth/roles.guard';
import { ReviewsService } from './reviews.service';

class CreateReviewDto extends createZodDto(CreateReviewRequestSchema) {}

@Controller('reviews')
@UseGuards(JwtAuthGuard, RolesGuard)
export class ReviewsController {
  constructor(private readonly reviews: ReviewsService) {}

  @Post()
  @Roles('STUDENT')
  async create(
    @Request() req: { user: { id: string; role: string } },
    @Headers(IDEMPOTENCY_KEY_HEADER) idempotencyKey: string | undefined,
    @Body() body: CreateReviewDto,
  ) {
    if (!idempotencyKey) throw new BadRequestException(`${IDEMPOTENCY_KEY_HEADER} header is required`);
    const { review, replayed } = await this.reviews.create(req.user.id, idempotencyKey, body);
    return review; // status set below
  }

  @Get()
  list(@Request() req: { user: { id: string; role: string } }, @Query('studentId') studentId?: string) {
    return this.reviews.list(req.user, studentId);
  }
}
```
(For 201 vs 200 on replay, add `@HttpCode(200)` default and use `@Res({ passthrough: true })` to set 201 when `!replayed` — simplest: inject response and set `res.status(replayed ? 200 : 201)`; keep the passthrough pattern so interceptors still run.)

`reviews.module.ts`: standard module wiring (controllers + providers), registered in `AppModule`.

- [ ] **Step 4: Run — pass** — `pnpm --filter api test:e2e` → PASS.

- [ ] **Step 5: Commit** — `git add -A && git commit -m "feat(api): idempotent review logging + role-scoped listing"`

---

### Task 9: apps/api — OpenAPI spec export + gen-dart script

**Files:**
- Create: `apps/api/src/spec.ts`, `scripts/gen-dart.sh`, `generated/.gitignore` (ignore contents, keep folder out of git — generated/ is already gitignored; the drift check regenerates in CI)
- Modify: `apps/api/package.json` (script `spec` exists from Task 5)

**Interfaces:**
- Produces: `pnpm --filter api spec` writes `generated/openapi.json` at repo root; `pnpm gen:dart` = spec export → `openapi-generator-cli` dart-dio → `dart-packages/api_client` with `pubName=hifz_api_client` → `dart format`. Requires Java 17 (`brew install --cask temurin` if missing).

- [ ] **Step 1: Spec script** — `apps/api/src/spec.ts`:
```ts
import { writeFileSync, mkdirSync } from 'node:fs';
import { resolve } from 'node:path';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { patchNestJsSwagger } from 'nestjs-zod';
import { AppModule } from './app.module';
import './config/env-load'; // tiny module that calls validateEnv()

patchNestJsSwagger();

async function main() {
  const app = await NestFactory.create(AppModule, { logger: false });
  const config = new DocumentBuilder()
    .setTitle('Hifz Tracker API')
    .setVersion('0.1.0')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, config);
  const out = resolve(__dirname, '../../../generated/openapi.json');
  mkdirSync(resolve(__dirname, '../../../generated'), { recursive: true });
  writeFileSync(out, JSON.stringify(document, null, 2));
  await app.close();
  console.log(`wrote ${out}`);
}
void main();
```
(If `patchNestJsSwagger` cannot resolve a schema (nestjs-zod/swagger mismatch), fall back per spec §4: `class-validator` DTOs + `@nestjs/swagger` decorators for the three affected bodies — record the decision in the PR.)

Add dep: `pnpm --filter api add @nestjs/swagger`.

- [ ] **Step 2: gen-dart script** — `scripts/gen-dart.sh`:
```bash
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
pnpm --filter api run spec
npx @openapitools/openapi-generator-cli generate \
  -i generated/openapi.json \
  -g dart-dio \
  -o dart-packages/api_client \
  --additional-properties=pubName=hifz_api_client \
  --skip-validate-spec
(cd dart-packages/api_client && dart pub get && dart format . >/dev/null && dart fix --apply >/dev/null)
echo "api_client regenerated"
```
`chmod +x scripts/gen-dart.sh`. (Task 14 creates the dart workspace; if run before Task 14 the script stops after writing the spec — fine.)

- [ ] **Step 3: Verify**

Run: `pnpm --filter api run spec && python3 -c "import json;d=json.load(open('generated/openapi.json'));print([p for p in d['paths']])"`
Expected: paths include `/api/v1/auth/register`, `/api/v1/auth/login`, `/api/v1/auth/refresh`, `/api/v1/auth/me`, `/api/v1/reviews`, `/api/v1/health`.

- [ ] **Step 4: Commit** — `git add -A && git commit -m "feat(api): openapi spec export + dart generation script"`

---

### Task 10: packages/api-sdk — typed web client (TDD)

**Files:**
- Create: `packages/api-sdk/package.json`, `packages/api-sdk/tsconfig.json`, `packages/api-sdk/vitest.config.ts`, `packages/api-sdk/src/index.ts`, `packages/api-sdk/src/client.ts`, `packages/api-sdk/test/client.test.ts`

**Interfaces:**
- Consumes: all contracts schemas.
- Produces: `ApiError` class (`status: number; code: string; details?: unknown`); `createApiClient(options: { baseUrl: string; getAccessToken?: () => string | undefined }): ApiClient` where `ApiClient` = `{ auth: { register(input: RegisterRequest): Promise<AuthResponse>; login(input: LoginRequest): Promise<AuthResponse>; refresh(refreshToken: string): Promise<AuthResponse>; me(): Promise<AuthUser> }, reviews: { create(input: CreateReviewRequest, idempotencyKey: string): Promise<ReviewDto>; list(studentId?: string): Promise<ReviewListResponse> } }`. Parses responses with contracts schemas (throws `ApiError('INTERNAL')` on schema mismatch). Base URL already includes `/api/v1`.

- [ ] **Step 1: Failing tests** — `test/client.test.ts` (msw):
```ts
import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { ApiError, createApiClient } from '../src/index';
import type { AuthResponse, ReviewDto, ReviewListResponse } from '@hifz/contracts';

const base = 'http://api.test/api/v1';
const server = setupServer(
  http.post(`${base}/auth/login`, () => HttpResponse.json({
    user: { id: '9b2f6f38-1e63-4c8a-9c1a-3f8c2c2e6c11', name: 'A', email: 'a@b.com', role: 'TEACHER' },
    accessToken: 'at', refreshToken: 'rt',
  } satisfies AuthResponse)),
  http.post(`${base}/reviews`, () => HttpResponse.json({ error: { code: 'VALIDATION_ERROR', message: 'bad' } }, { status: 400 })),
  http.get(`${base}/reviews`, () => HttpResponse.json({ items: [{
    id: '0b2f6f38-1e63-4c8a-9c1a-3f8c2c2e6c12', studentId: '9b2f6f38-1e63-4c8a-9c1a-3f8c2c2e6c11',
    surahNumber: 1, ayahFrom: 1, ayahTo: 7, quality: 'GOOD', loggedAt: '2026-09-18T10:00:00.000Z',
  }] } satisfies ReviewListResponse)),
);
beforeAll(() => server.listen()); afterAll(() => server.close());

describe('api-sdk', () => {
  const client = createApiClient({ baseUrl: base, getAccessToken: () => 'at' });

  it('login returns typed AuthResponse', async () => {
    const res = await client.auth.login({ email: 'a@b.com', password: 'pw' });
    expect(res.user.role).toBe('TEACHER');
  });

  it('throws ApiError with envelope code on error status', async () => {
    const err = await client.reviews.create({ surahNumber: 1, ayahFrom: 2, ayahTo: 1, quality: 'GOOD' }, 'key').catch((e) => e);
    expect(err).toBeInstanceOf(ApiError);
    expect((err as ApiError).code).toBe('VALIDATION_ERROR');
    expect((err as ApiError).status).toBe(400);
  });

  it('lists reviews and sends bearer + idempotency key', async () => {
    let sawAuth = ''; let sawIdem = '';
    server.use(http.post(`${base}/reviews`, ({ request }) => {
      sawAuth = request.headers.get('authorization') ?? '';
      sawIdem = request.headers.get('idempotency-key') ?? '';
      const dto: ReviewDto = {
        id: '0b2f6f38-1e63-4c8a-9c1a-3f8c2c2e6c12', studentId: '9b2f6f38-1e63-4c8a-9c1a-3f8c2c2e6c11',
        surahNumber: 1, ayahFrom: 1, ayahTo: 7, quality: 'GOOD', loggedAt: '2026-09-18T10:00:00.000Z',
      };
      return HttpResponse.json(dto, { status: 201 });
    }));
    const created = await client.reviews.create({ surahNumber: 1, ayahFrom: 1, ayahTo: 7, quality: 'GOOD' }, 'my-key');
    expect(created.id).toBeTruthy();
    expect(sawAuth).toBe('Bearer at');
    expect(sawIdem).toBe('my-key');
  });

  it('parses list responses', async () => {
    const res = await client.reviews.list();
    expect(res.items).toHaveLength(1);
  });
});
```

- [ ] **Step 2: Run — fail** — `pnpm --filter @hifz/api-sdk test` → FAIL.

- [ ] **Step 3: Implement** — `package.json`:
```json
{
  "name": "@hifz/api-sdk",
  "version": "0.1.0",
  "type": "module",
  "exports": { ".": "./src/index.ts" },
  "scripts": { "test": "vitest run", "typecheck": "tsc --noEmit" },
  "dependencies": { "@hifz/contracts": "workspace:*" },
  "devDependencies": { "msw": "^2.6.0", "typescript": "^5.7.0", "vitest": "^2.1.0" }
}
```
`src/client.ts`:
```ts
import {
  AuthResponseSchema, AuthUserSchema, CreateReviewRequest, ErrorEnvelopeSchema, RegisterRequest, LoginRequest,
  ReviewDtoSchema, ReviewListResponseSchema,
} from '@hifz/contracts';

export class ApiError extends Error {
  constructor(readonly status: number, readonly code: string, message: string, readonly details?: unknown) {
    super(message);
  }
}

export interface ApiClientOptions { baseUrl: string; getAccessToken?: () => string | undefined }

async function request<T>(opts: ApiClientOptions, schema: { parse: (v: unknown) => T }, path: string, init: RequestInit): Promise<T> {
  const headers = new Headers(init.headers);
  if (opts.getAccessToken?.()) headers.set('Authorization', `Bearer ${opts.getAccessToken()}`);
  const res = await fetch(`${opts.baseUrl}${path}`, { ...init, headers });
  const body = await res.json().catch(() => null);
  if (!res.ok) {
    const envelope = body && ErrorEnvelopeSchema.safeParse(body);
    if (envelope.success) throw new ApiError(res.status, envelope.data.error.code, envelope.data.error.message, envelope.data.error.details);
    throw new ApiError(res.status, 'INTERNAL', `Unexpected response (${res.status})`);
  }
  return schema.parse(body);
}

export function createApiClient(opts: ApiClientOptions) {
  const json = (method: string, body: unknown): RequestInit => ({ method, headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
  return {
    auth: {
      register: (input: RegisterRequest) => request(opts, AuthResponseSchema, '/auth/register', { ...json('POST', input) }),
      login: (input: LoginRequest) => request(opts, AuthResponseSchema, '/auth/login', { ...json('POST', input) }),
      refresh: (refreshToken: string) => request(opts, AuthResponseSchema, '/auth/refresh', json('POST', { refreshToken })),
      me: () => request(opts, AuthUserSchema, '/auth/me', { method: 'GET' }),
    },
    reviews: {
      create: (input: CreateReviewRequest, idempotencyKey: string) =>
        request(opts, ReviewDtoSchema, '/reviews', { ...json('POST', input), headers: { 'Content-Type': 'application/json', 'Idempotency-Key': idempotencyKey } }),
      list: (studentId?: string) =>
        request(opts, ReviewListResponseSchema, `/reviews${studentId ? `?studentId=${encodeURIComponent(studentId)}` : ''}`, { method: 'GET' }),
    },
  };
}
```
`src/index.ts`: `export * from './client';`
`tsconfig.json`: extends `@hifz/config/tsconfig/react-lib.json` (no DOM APIs beyond fetch types; use base if fetch types missing), include src/test.

- [ ] **Step 4: Run — pass** — `pnpm --filter @hifz/api-sdk test` → PASS.

- [ ] **Step 5: Commit** — `git add -A && git commit -m "feat(api-sdk): typed fetch client with envelope errors"`

---

### Task 11: apps/web — Next scaffold + landing + design tokens

**Files:**
- Create: `apps/web/**` (Next 15 scaffold), `packages/ui/package.json`, `packages/ui/src/index.ts`, `packages/ui/src/button.tsx`, `packages/ui/src/tokens.css`

**Interfaces:**
- Produces: Next app on port 3000 with route groups `src/app/(marketing)/page.tsx` (landing) and `src/app/(dash)/dashboard/page.tsx` (placeholder until Task 13); `@hifz/ui` exporting `Button` and CSS design tokens; Tailwind wired via `packages/ui` preset.

- [ ] **Step 1: Scaffold** — Run:
```bash
pnpm dlx create-next-app@15 apps/web --ts --tailwind --eslint --app --src-dir --use-pnpm --no-import-alias
pnpm --filter web add @hifz/contracts @hifz/api-sdk @hifz/ui --workspace
```
Set `"dev": "next dev -p 3000"`. eslint via `defineConfig({ type: 'app-web' })`.

- [ ] **Step 2: UI package**

`packages/ui/package.json`:
```json
{
  "name": "@hifz/ui",
  "version": "0.1.0",
  "exports": { ".": "./src/index.ts", "./tokens.css": "./src/tokens.css" },
  "scripts": { "typecheck": "tsc --noEmit" },
  "dependencies": { "@hifz/contracts": "workspace:*" },
  "devDependencies": { "typescript": "^5.7.0", "react": "^19.0.0", "@types/react": "^19.0.0" }
}
```
`src/tokens.css`: Tailwind v4 `@theme` block — colors `--color-brand-*` (emerald-based), radii, font stack.
`src/button.tsx`: `'use client';` Button with variants (`primary | ghost`) via Tailwind classes; typed props extends `React.ButtonHTMLAttributes`.
`src/index.ts`: `export * from './button';`

- [ ] **Step 3: Landing + placeholder dashboard**

`src/app/(marketing)/page.tsx`: server component — hero (`Hifz Tracker`), subhead, CTA `Button` linking `/login`, features grid (3 cards: student logging, teacher dashboard, offline queue). No images needed (defer to feature work).
`src/app/(dash)/dashboard/page.tsx`: placeholder `<h1>Dashboard</h1>` with comment `// Task 13 replaces this`.
Remove default `src/app/page.tsx` (root route now lives in route group); keep one root `layout.tsx` importing `@hifz/ui/tokens.css`.

- [ ] **Step 4: Verify + commit** — Run: `pnpm --filter web build` → succeeds; `pnpm --filter web dev` + `curl localhost:3000` → 200 landing. `git add -A && git commit -m "feat(web): next scaffold, landing, ui tokens"`

---

### Task 12: apps/web — session cookies, login page, middleware guard (TDD)

**Files:**
- Create: `apps/web/src/app/api/auth/session/route.ts`, `apps/web/src/middleware.ts`, `apps/web/src/app/(dash)/login/page.tsx`, `apps/web/src/lib/session.ts`
- Test: `apps/web/src/app/(dash)/login/login-form.test.tsx`, session unit test

**Interfaces:**
- Consumes: `@hifz/api-sdk`, `LoginRequestSchema`.
- Produces: `POST /api/auth/session` {email,password} → 204, sets httpOnly cookies `at` (access) + `rt` (refresh, path `/api/auth/session`); `PUT /api/auth/session` rotates; `DELETE /api/auth/session` clears; helper `getSessionTokens()` for server components; middleware: `/dashboard/*` without `at` cookie → redirect `/login`; login page validates with contracts zod + react-hook-form, on success `router.push('/dashboard')`.

- [ ] **Step 1: Failing tests**

`src/app/(dash)/login/login-form.test.tsx` (vitest + testing-library, jsdom; the form itself is a `login-form.tsx` client component so it can render without the page wrapper):
```tsx
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi, beforeEach } from 'vitest';
import { LoginForm } from './login-form';

const push = vi.fn();
vi.mock('next/navigation', () => ({ useRouter: () => ({ push }) }));
const login = vi.fn();
vi.mock('@hifz/api-sdk', () => ({ createApiClient: () => ({ auth: { login: (...a: unknown[]) => login(...a) } }) }));

describe('LoginForm', () => {
  beforeEach(() => { login.mockReset(); push.mockReset(); });

  it('shows a validation error for an invalid email', async () => {
    render(<LoginForm />);
    await userEvent.type(screen.getByLabelText('Email'), 'not-an-email');
    await userEvent.type(screen.getByLabelText('Password'), 'password123');
    await userEvent.click(screen.getByRole('button', { name: 'Sign in' }));
    expect(await screen.findByText(/invalid email/i)).toBeTruthy();
    expect(login).not.toHaveBeenCalled();
  });

  it('submits valid credentials, posts the session, and navigates', async () => {
    login.mockResolvedValue({ user: { id: 'u1', role: 'TEACHER' }, accessToken: 'at', refreshToken: 'rt' });
    render(<LoginForm />);
    await userEvent.type(screen.getByLabelText('Email'), 'teacher@test.dev');
    await userEvent.type(screen.getByLabelText('Password'), 'password123');
    await userEvent.click(screen.getByRole('button', { name: 'Sign in' }));
    await waitFor(() => expect(push).toHaveBeenCalledWith('/dashboard'));
  });
});
```
(The component calls `fetch('/api/auth/session', { method: 'POST', body })` after a successful API login — stub `fetch` in test 2 with a 204 Response.)
`src/lib/session.test.ts`:
```ts
import { describe, expect, it, vi } from 'vitest';
import { POST } from '@/app/api/auth/session/route';

describe('session route', () => {
  it('sets httpOnly at + rt cookies on success', async () => {
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue(new Response(JSON.stringify({
      user: { id: 'u1', name: 'T', email: 't@t.dev', role: 'TEACHER' }, accessToken: 'at', refreshToken: 'rt',
    }), { status: 200 })));
    const req = new Request('http://localhost/api/auth/session', { method: 'POST', body: JSON.stringify({ email: 't@t.dev', password: 'password123' }) });
    const res = await POST(req);
    const setCookie = res.headers.getSetCookie().join('\n');
    expect(setCookie).toContain('at=');
    expect(setCookie).toContain('rt=');
    expect(setCookie).toContain('HttpOnly');
  });
});
```

- [ ] **Step 2: Run — fail** — `pnpm --filter web test` → FAIL.

- [ ] **Step 3: Implement**

`src/lib/session.ts`:
```ts
import { cookies } from 'next/headers';

export const AT_COOKIE = 'at';
export const RT_COOKIE = 'rt';

export async function getSessionTokens(): Promise<{ accessToken?: string; refreshToken?: string }> {
  const jar = await cookies();
  return { accessToken: jar.get(AT_COOKIE)?.value, refreshToken: jar.get(RT_COOKIE)?.value };
}
```

`route.ts` POST (PUT/DELETE follow the same shape — PUT refreshes via the `rt` cookie, DELETE clears both cookies):
```ts
import { NextResponse } from 'next/server';
import { createApiClient } from '@hifz/api-sdk';
import { LoginRequestSchema } from '@hifz/contracts';

const API_URL = process.env.API_URL!;

export async function POST(req: Request) {
  const parsed = LoginRequestSchema.safeParse(await req.json().catch(() => null));
  if (!parsed.success) {
    return NextResponse.json({ error: { code: 'VALIDATION_ERROR', message: 'Invalid payload' } }, { status: 400 });
  }
  try {
    const auth = await createApiClient({ baseUrl: API_URL }).auth.login(parsed.data);
    const res = new NextResponse(null, { status: 204 });
    res.cookies.set('at', auth.accessToken, { httpOnly: true, sameSite: 'lax', maxAge: Number(process.env.JWT_ACCESS_TTL ?? 900) });
    res.cookies.set('rt', auth.refreshToken, { httpOnly: true, sameSite: 'lax', path: '/api/auth/session', maxAge: 30 * 86_400 });
    return res;
  } catch {
    return NextResponse.json({ error: { code: 'INVALID_CREDENTIALS', message: 'Invalid email or password' } }, { status: 401 });
  }
}
```
(`API_URL=http://localhost:3001/api/v1` in `apps/web/.env`; add `secure: true` in production.)

`middleware.ts`:
```ts
import { NextRequest, NextResponse } from 'next/server';

export function middleware(req: NextRequest) {
  const hasSession = req.cookies.has('at') || req.cookies.has('rt');
  if (!hasSession) {
    const url = req.nextUrl.clone();
    url.pathname = '/login';
    url.searchParams.set('next', req.nextUrl.pathname);
    return NextResponse.redirect(url);
  }
  return NextResponse.next();
}
export const config = { matcher: ['/dashboard/:path*'] };
```

Login page: client component; `useForm<LoginRequest>({ resolver: zodResolver(LoginRequestSchema) })` (`@hookform/resolvers` + `react-hook-form`); submit → `api.auth.login` → `POST /api/auth/session` with credentials → `router.push(next ?? '/dashboard')`. Error → banner with envelope message (map `INVALID_CREDENTIALS` → "Invalid email or password").

- [ ] **Step 4: Run — pass + manual flow**

`pnpm --filter web test` → PASS. Manual: `pnpm dev`, register a teacher via curl, login via UI, land on `/dashboard`.

- [ ] **Step 5: Commit** — `git add -A && git commit -m "feat(web): cookie session, login page, dashboard guard"`

---

### Task 13: apps/web — teacher dashboard reviews list + PWA

**Files:**
- Create: `apps/web/src/app/(dash)/dashboard/page.tsx` (replace placeholder), `apps/web/src/app/(dash)/dashboard/loading.tsx`, `apps/web/src/app/manifest.ts`, `apps/web/src/app/sw.ts`
- Modify: `apps/web/next.config.ts` (Serwist), `apps/web/package.json` (dep `@serwist/next`, `serwist`)

**Interfaces:**
- Consumes: `@hifz/api-sdk`, `getSessionTokens()`, `surahs` from contracts.
- Produces: `/dashboard` server component: verifies session (`at` present; on 401 from API redirect `/login`), renders the signed-in teacher's students' recent reviews — table columns: Student, Surah (Arabic name + number), Ayah range, Quality, Logged at; `?studentId=` query filter with `<select>` of students (`GET /reviews?studentId=`). Installable PWA (manifest + Serwist worker with app-shell precache).

- [ ] **Step 1: Dashboard page**

Server component flow: `const { accessToken } = await getSessionTokens(); if (!accessToken) redirect('/login');` → `createApiClient({ baseUrl: process.env.API_URL!, getAccessToken: () => accessToken })` → `searchParams.studentId` → `client.reviews.list(studentId)` → render table; surah cell: `surahByNumber(r.surahNumber)?.nameAr ?? r.surahNumber`. Add `loading.tsx` skeleton. Client interaction for the student `<select>`: small client component navigating `router.push(`/dashboard?studentId=...`)`.

- [ ] **Step 2: PWA**

`pnpm --filter web add @serwist/next serwist`.
`next.config.ts`: wrap with `withSerwist({ swSrc: 'src/app/sw.ts', swDest: 'public/sw.js', disable: process.env.NODE_ENV === 'development' })`.
`src/app/sw.ts`:
```ts
import { defaultCache } from '@serwist/next/worker';
import { PrecacheRoute, precacheAndRoute } from 'serwist';
import { installSerwist } from '@serwist/next/worker';
// eslint-disable-next-line @typescript-eslint/no-require-imports
const manifest = self.__SW_MANIFEST as unknown as { urlEntries?: unknown };
installSerwist();
precacheAndRoute(manifest);
```
(Follow the installed @serwist/next version's canonical `sw.ts` — the invariant is: precache app shell + sensible default runtime caching; adjust imports to what compiles.)
`manifest.ts`: name `Hifz Tracker Dashboard`, theme emerald, icons 192/512 (simple generated PNG placeholders), `display: 'standalone'`, `start_url: '/dashboard'`.

- [ ] **Step 3: Verify + commit** — `pnpm --filter web build` → PASS (sw.js emitted). Manual: login → dashboard shows reviews logged earlier; DevTools → Application → Manifest valid. `git add -A && git commit -m "feat(web): teacher reviews dashboard + installable PWA"`

---

### Task 14: Dart workspace — Melos + core package (TDD)

**Files:**
- Create: `melos.yaml`, `dart-packages/core/pubspec.yaml`, `dart-packages/core/lib/hifz_core.dart`, `dart-packages/core/lib/src/result.dart`, `dart-packages/core/lib/src/api_failure.dart`, `dart-packages/core/lib/src/env.dart`, `dart-packages/core/test/result_test.dart`, `dart-packages/core/test/api_failure_test.dart`

**Interfaces:**
- Produces: `melos bootstrap` links all Dart packages; `package:hifz_core` exports `Result<T>` (`sealed class Result<T>`; `Ok<T>` with `.value`; `Err<T>` with `.failure`), `ApiFailure { String code; String message; Object? details; bool get isRetryable }` (retryable = network/5xx codes: `NETWORK`, `SERVER`), `AppEnv { String apiBaseUrl; String get apiV1 => '$apiBaseUrl/api/v1' }`.

- [ ] **Step 1: Melos** — `dart pub global activate melos`. `melos.yaml`:
```yaml
name: hifz_tracker
packages:
  - apps/mobile
  - dart-packages/**
command:
  bootstrap:
    runPubGetInParallel: true
scripts:
  analyze:
    exec: dart analyze .
  test:
    exec:
      commands:
        - command: dart test
          packageFilters:
            dirExists: test
            flutter: false
        - command: flutter test
          packageFilters:
            dirExists: test
            flutter: true
  gen:dart:
    run: melos run gen:dart:client
    packageFilters:
      scope: "core"
```
(Adjust to installed melos major if schema keys differ — invariant: `bootstrap`, `analyze`, `test` work across the workspace.)

- [ ] **Step 2: Failing tests** — `dart-packages/core/test/result_test.dart`:
```dart
import 'package:hifz_core/hifz_core.dart';
import 'package:test/test.dart';

void main() {
  test('Ok carries value', () {
    expect(const Ok<int>(3).value, 3);
  });
  test('Err carries failure', () {
    final e = Err<int>(const ApiFailure(code: 'X', message: 'm'));
    expect(e.failure.code, 'X');
  });
  test('map transforms Ok', () {
    final r = const Ok<int>(2).map((v) => v * 2);
    expect(r.value, 4); // throws if not Ok — test expects Ok
  });
}
```
`api_failure_test.dart`: `NETWORK` and `SERVER` are retryable; `VALIDATION_ERROR` is not.

- [ ] **Step 3: Run — fail** — `cd dart-packages/core && dart test` → FAIL (package missing).

- [ ] **Step 4: Implement** — `pubspec.yaml`:
```yaml
name: hifz_core
version: 0.1.0
environment:
  sdk: ^3.5.0
dev_dependencies:
  test: ^1.25.0
```
`lib/src/result.dart`:
```dart
sealed class Result<T> {
  const Result();
  R when<R>({required R Function(T value) ok, required R Function(ApiFailure failure) err}) =>
      switch (this) {
        Ok<T>(:final value) => ok(value),
        Err<T>(:final failure) => err(failure),
      };
}

final class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
  Result<R> map<R>(R Function(T) f) => Ok<R>(f(value));
}

final class Err<T> extends Result<T> {
  final ApiFailure failure;
  const Err(this.failure);
}
```
`lib/src/api_failure.dart`:
```dart
class ApiFailure {
  final String code;
  final String message;
  final Object? details;
  const ApiFailure({required this.code, required this.message, this.details});

  static const retryableCodes = {'NETWORK', 'SERVER'};
  bool get isRetryable => retryableCodes.contains(code);
}
```
`lib/src/env.dart`:
```dart
class AppEnv {
  final String apiBaseUrl;
  const AppEnv({required this.apiBaseUrl});
  String get apiV1 => '$apiBaseUrl/api/v1';
}
```
`lib/hifz_core.dart`: export all three source files.

- [ ] **Step 5: Run — pass** — `dart test` in package → PASS; `melos bootstrap` at root → links workspace.

- [ ] **Step 6: Commit** — `git add -A && git commit -m "feat(core): dart workspace + Result/ApiFailure/AppEnv"`

---

### Task 15: Quran Dart codegen (TDD)

**Files:**
- Create: `scripts/gen-quran-dart.mjs`, `dart-packages/core/lib/src/quran_data.g.dart` (generated), `dart-packages/core/test/quran_data_test.dart`

**Interfaces:**
- Produces: `hifz_core` exports `const List<SurahInfo> kSurahs` with `SurahInfo { int number; String nameAr; String nameEn; String nameTranslit; int ayahCount }` generated from `packages/contracts/quran/surahs.json`. Run via root script `pnpm gen:quran`.

- [ ] **Step 1: Failing test** — `dart-packages/core/test/quran_data_test.dart`:
```dart
import 'package:hifz_core/hifz_core.dart';
import 'package:test/test.dart';

void main() {
  test('114 surahs, sequential', () {
    expect(kSurahs.length, 114);
    expect(kSurahs.first.number, 1);
    expect(kSurahs.last.number, 114);
  });
  test('ayah totals 6236', () {
    expect(kSurahs.fold<int>(0, (n, s) => n + s.ayahCount), 6236);
  });
  test('first surah is Al-Fatihah in Arabic', () {
    expect(kSurahs.first.nameAr, contains('الفاتحة'));
  });
}
```

- [ ] **Step 2: Run — fail** — `dart test` → FAIL (kSurahs undefined).

- [ ] **Step 3: Generator** — `scripts/gen-quran-dart.mjs`:
```js
import { readFileSync, writeFileSync } from 'node:fs';

const surahs = JSON.parse(readFileSync(new URL('../packages/contracts/quran/surahs.json', import.meta.url), 'utf8'));
const entries = surahs.map((s) =>
  `  SurahInfo(number: ${s.number}, nameAr: ${JSON.stringify(s.nameAr)}, nameEn: ${JSON.stringify(s.nameEn)}, nameTranslit: ${JSON.stringify(s.nameTranslit)}, ayahCount: ${s.ayahCount}),`,
).join('\n');

const out = `// GENERATED from packages/contracts/quran/surahs.json — do not edit.
import 'surah_info.dart';

const kSurahs = <SurahInfo>[
${entries}
];
`;
writeFileSync(new URL('../dart-packages/core/lib/src/quran_data.g.dart', import.meta.url), out);
console.log(`generated ${surahs.length} surahs`);
```
Add `dart-packages/core/lib/src/surah_info.dart`:
```dart
class SurahInfo {
  final int number;
  final String nameAr;
  final String nameEn;
  final String nameTranslit;
  final int ayahCount;
  const SurahInfo({required this.number, required this.nameAr, required this.nameEn, required this.nameTranslit, required this.ayahCount});
}
```
Export from `hifz_core.dart`: `export 'src/surah_info.dart'; export 'src/quran_data.g.dart';`
Root `package.json` script: `"gen:quran": "node scripts/gen-quran-dart.mjs"`.
Run: `pnpm gen:quran`.

- [ ] **Step 4: Run — pass** — `cd dart-packages/core && dart test` → PASS.

- [ ] **Step 5: Commit** — `git add -A && git commit -m "feat(core): quran surah data generated from contracts JSON"`

---

### Task 16: dart-packages/api_client — generated client + compile smoke

**Files:**
- Create: `dart-packages/api_client/**` (100% generated by `scripts/gen-dart.sh`)

**Interfaces:**
- Produces: `package:hifz_api_client` — dio-based client with typed models (`AuthResponse`, `AuthUser`, `ReviewDto`, `CreateReviewRequest`…) and methods matching the API routes. Deps (from generator): `dio`, `built_value` (or per generator output). Consumed by Task 17 via a thin wrapper `ApiClientFactory.create(AppEnv env, {String? Function() getAccessToken})` defined IN `data` (not in the generated package).

- [ ] **Step 1: Generate**

Prereq: Java 17 (`java -version` else `brew install --cask temurin`). Run: `./scripts/gen-dart.sh`
Expected: `dart-packages/api_client` populated, `dart pub get` + `dart fix --apply` clean.

- [ ] **Step 2: Smoke test the generated package compiles** — create `dart-packages/api_client/test/compile_smoke_test.dart` (committed; regeneration must not delete it — generator output dir excludes `test/` by default, verify after regen):
```dart
import 'package:hifz_api_client/api.dart';
import 'package:test/test.dart';

void main() {
  test('client constructs and exposes auth+reviews', () {
    final client = ApiClient(basePathOverride: 'http://localhost:3001/api/v1');
    expect(client.auth, isNotNull);
    expect(client.reviews, isNotNull);
  });
}
```
(Adapter names come from the generator — inspect `lib/api.dart` and adjust the two property names to actual generated API-class fields; the invariant is: constructing the client with a base path compiles and exposes the auth + reviews APIs.)

- [ ] **Step 3: Run — pass** — `cd dart-packages/api_client && dart test` → PASS.

- [ ] **Step 4: Commit** — `git add -A && git commit -m "feat(api_client): generated dart client from openapi (dart-dio)"`

---

### Task 17: dart-packages/data — repositories, drift cache, outbox sync (TDD)

**Files:**
- Create: `dart-packages/data/pubspec.yaml`, `dart-packages/data/lib/hifz_data.dart`, `dart-packages/data/lib/src/database.dart`, `dart-packages/data/lib/src/tables.dart`, `dart-packages/data/lib/src/review_repository.dart`, `dart-packages/data/lib/src/sync_worker.dart`, `dart-packages/data/lib/src/client_factory.dart`, `dart-packages/data/test/review_repository_test.dart`, `dart-packages/data/test/sync_worker_test.dart`

**Interfaces:**
- Consumes: `hifz_core` (`Result`, `ApiFailure`, `AppEnv`), generated `hifz_api_client`.
- Produces:
  - `ReviewRepository.logReview(CreateReviewRequest req, {String? idempotencyKey})` → `Result<ReviewDto>`: online path calls API and caches to drift; on `DioException` (connection error) enqueues `OutboxItem` and returns `Ok` with optimistic local echo (uuid + `loggedAt` now, marked `pendingSync: true`); on API 4xx returns `Err(ApiFailure)` without queueing. (Type names come from the generated `hifz_api_client` — they mirror the contracts schema names; verify against `lib/api.dart` after Task 16.)
  - `ReviewRepository.listCached(studentId)` → `List<ReviewDto>` from drift (newest first).
  - `SyncWorker.start()` — listens to `connectivity_plus` (injected `ConnectivityChecker` interface for tests), flushes outbox: per item POST with stored `idempotencyKey`; success or replay (200/201) → delete row + upsert cache; network error → stop and wait for next trigger (backoff: injected `DurationGetter`, exponential `min(30s * 2^attempts, 15min)`); non-retryable 4xx → delete row and expose via `Stream<SyncDeadLetter>` (UI can show a toast later).

- [ ] **Step 1: Failing tests** — `review_repository_test.dart` + `sync_worker_test.dart` (drift with `NativeDatabase.memory()`; fake API via injected factory — no real network):
```dart
// review_repository_test.dart — shared fakes at top:
// class FakeReviewsApi implements ReviewsApi {
//   final Object Function()? behavior; // throws or returns dto
//   ...
// }
// AppDatabase newDb() => AppDatabase(NativeDatabase.memory());

test('logReview online success caches and leaves outbox empty', () async {
  final repo = ReviewRepository(db: newDb(), api: () => FakeReviewsApi.returning(dto));
  final result = await repo.logReview(request, idempotencyKey: 'k1');
  expect(result, isA<Ok<ReviewDto>>());
  expect((await db.select(db.cachedReviews).get()), hasLength(1));
  expect((await db.select(db.outboxItems).get()), isEmpty);
});

test('logReview offline enqueues and echoes pendingSync', () async {
  final repo = ReviewRepository(db: newDb(), api: FakeReviewsApi.throwingConnectionError);
  final result = await repo.logReview(request, idempotencyKey: 'k2');
  expect(result.when(ok: (d) => d.pendingSync, err: (_) => false), isTrue);
  final outbox = await db.select(db.outboxItems).get();
  expect(outbox, hasLength(1));
  expect(outbox.single.idempotencyKey, 'k2');
});

test('logReview 4xx returns Err without queueing', () async {
  final repo = ReviewRepository(db: newDb(), api: FakeReviewsApi.throwing400(envelopeCode: 'VALIDATION_ERROR'));
  final result = await repo.logReview(invalidRequest, idempotencyKey: 'k3');
  expect(result.when(ok: (_) => '', err: (f) => f.code), 'VALIDATION_ERROR');
  expect((await db.select(db.outboxItems).get()), isEmpty);
});

// sync_worker_test.dart:
test('flush happy path clears outbox and upserts cache', () async { /* seed outbox row; FakeApi returns dto; run worker.flush(); expect outbox empty + cache row pendingSync=false */ });
test('flush network failure keeps row; retry clears it', () async { /* FakeApi throws connection error → flush → row remains; swap fake to success → trigger (connectivity event) → row gone */ });
test('flush treats 200 replay as success', () async { /* FakeApi returns existing dto with 200 → row removed */ });
test('flush 4xx dead-letters the item', () async { /* FakeApi throws 422 envelope → row removed; deadLetter stream emits that item once */ });
```
(Write the fakes and the four worker tests in full following the shown patterns — arrange on an in-memory `AppDatabase`, act via the class under test, assert on drift tables. The enumerated comments are the required assertions, not suggestions.)

- [ ] **Step 2: Run — fail** — `cd dart-packages/data && dart test` → FAIL.

- [ ] **Step 3: Implement**

`pubspec.yaml`: name `hifz_data`; deps `hifz_core`, `hifz_api_client` (path), `drift`, `connectivity_plus`, `uuid`; dev deps `drift_dev`, `build_runner`, `test`, `mocktail`.
`tables.dart`:
```dart
import 'package:drift/drift.dart';

class CachedReviews extends Table {
  TextColumn get id => text()();
  TextColumn get studentId => text()();
  IntColumn get surahNumber => integer()();
  IntColumn get ayahFrom => integer()();
  IntColumn get ayahTo => integer()();
  TextColumn get quality => text()();
  DateTimeColumn get loggedAt => dateTime()();
  BoolColumn get pendingSync => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class OutboxItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get idempotencyKey => text()();
  TextColumn get payloadJson => text()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
```
`database.dart`: `@DriftDatabase(tables: [CachedReviews, OutboxItems]) class AppDatabase extends _$AppDatabase` with `NativeDatabase` injected (ctor takes `QueryExecutor`); run `build_runner` to generate parts.
`review_repository.dart` / `sync_worker.dart`: implement per Interfaces above; map `DioException` → `ApiFailure` (no response → `code: 'NETWORK'`; response ≥500 → `'SERVER'`; else parse `response.data['error']['code']`).
`client_factory.dart`: `typedef ApiClientFactoryFn = hifz_api_client.ApiClient Function();` — the mobile app (Task 18) supplies dio with auth interceptors; `data` stays UI- and storage-agnostic except drift.

- [ ] **Step 4: Run — pass** — `dart test` → PASS (7 tests).

- [ ] **Step 5: Commit** — `git add -A && git commit -m "feat(data): review repository with drift cache + offline outbox sync worker"`

---

### Task 18: features/auth + mobile shell — login with token refresh (TDD)

**Files:**
- Create: `apps/mobile/**` (flutter scaffold), `dart-packages/features/auth/pubspec.yaml`, `dart-packages/features/auth/lib/hifz_feature_auth.dart`, `dart-packages/features/auth/lib/src/auth_controller.dart`, `dart-packages/features/auth/lib/src/token_storage.dart`, `dart-packages/features/auth/lib/src/auth_api_service.dart`, `dart-packages/features/auth/test/auth_controller_test.dart`
- Modify: `melos.yaml` if package list needs the new folder (glob already covers it)

**Interfaces:**
- Consumes: `hifz_api_client` (generated), `hifz_core`, `flutter_riverpod`, `flutter_secure_storage`.
- Produces: `TokenStorage` (secure read/write/clear of `accessToken` + `refreshToken`); `AuthController extends Notifier<AsyncValue<AuthUserModel?>>` with `login(email, password)` and `logout()`; `authProvider`; dio wrapper `authedApiClientProvider` adding Bearer token + on-401 refresh-once-and-retry interceptor; mobile app shell: `MaterialApp.router` with `ar` locale + RTL + l10n delegates, routes `/login` and `/`.

- [ ] **Step 1: Failing test** — `auth_controller_test.dart` (mocktail fakes for storage + api):
```dart
// Fakes: MockTokenStorage (flutter_secure_storage wrapper), MockAuthApiService.
test('login success stores tokens and sets user state', () async {
  when(() => api.login('a@b.com', 'pw')).thenAnswer((_) async => authResponse);
  final controller = AuthController(api: api, storage: storage);
  await controller.login('a@b.com', 'pw');
  verifyInOrder([
    () => storage.saveTokens(at: 'at', rt: 'rt'),
  ]);
  expect(controller.state.value?.email, 'a@b.com');
});

test('login failure leaves state in error and storage untouched', () async {
  when(() => api.login('a@b.com', 'wrong')).thenThrow(ApiFailure(code: 'INVALID_CREDENTIALS', message: 'x'));
  await controller.login('a@b.com', 'wrong');
  expect(controller.state.hasError, isTrue);
  verifyNever(() => storage.saveTokens(at: any(named: 'at'), rt: any(named: 'rt')));
});

test('restore session reads tokens and calls me', () async {
  when(() => storage.readTokens()).thenAnswer((_) async => (at: 'at', rt: 'rt'));
  when(() => api.me()).thenAnswer((_) async => authUser);
  final controller = AuthController(api: api, storage: storage)..restore();
  await pumpEventQueue();
  expect(controller.state.value?.id, authUser.id);
});

test('interceptor refreshes once on 401 and retries', () async {
  // Stubbed Dio adapter: sequence = [401 on /auth/me, 200 on /auth/refresh, 200 on /auth/me].
  // Assert the original request resolves 200 and storage now holds the NEW tokens.
  final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'))
    ..httpClientAdapter = SequencedAdapter([(401, null), (200, refreshBody), (200, meBody)]);
  attachAuthInterceptors(dio, storage: storage, api: api);
  final res = await dio.get('/auth/me');
  expect(res.statusCode, 200);
  verify(() => storage.saveTokens(at: 'at2', rt: 'rt2')).called(1);
});
```

- [ ] **Step 2: Run — fail** — `cd dart-packages/features/auth && flutter test` (or `dart test` where no widgets used) → FAIL.

- [ ] **Step 3: Implement**

Flutter scaffold: `flutter create --org dev.hifz --project-name hifz_tracker apps/mobile`.
Deps (workspace): `flutter_riverpod`, `flutter_secure_storage`, `go_router`, `google_fonts`; `features/auth` deps: `hifz_api_client`, `hifz_core`, `flutter_riverpod`, `flutter_secure_storage`.
`auth_controller.dart`: `Notifier` reading `AuthApiService` (wraps generated client: `login`, `me`, `refresh`) + `TokenStorage`; `build()` restores session.
Interceptor (in `auth_api_service.dart`): onRequest attach `Authorization`; onError 401 → lock, `refresh(rt)`, persist new tokens, retry original once; second failure → logout event.

- [ ] **Step 4: Run — pass** — `flutter test` in package → PASS (4 tests).

- [ ] **Step 5: Commit** — `git add -A && git commit -m "feat(auth): mobile auth feature with refresh-on-401"`

---

### Task 19: features/hifz_logging + Arabic UI — log review screen with outbox badge (TDD)

**Files:**
- Create: `dart-packages/features/hifz_logging/pubspec.yaml`, `dart-packages/features/hifz_logging/lib/hifz_feature_hifz_logging.dart`, `dart-packages/features/hifz_logging/lib/src/log_review_screen.dart`, `dart-packages/features/hifz_logging/lib/src/hifz_logging_providers.dart`, `dart-packages/features/hifz_logging/lib/src/recent_reviews_list.dart`, `dart-packages/features/hifz_logging/lib/l10n/app_ar.arb`, `dart-packages/features/hifz_logging/test/log_review_screen_test.dart`
- Create: `apps/mobile/lib/l10n/app_ar.arb` + `app_en.arb`, `apps/mobile/lib/app_router.dart`, `apps/mobile/lib/main.dart`

**Interfaces:**
- Consumes: `ReviewRepository`, `SyncWorker`, `kSurahs` (hifz_core), authProvider (features/auth).
- Produces: `LogReviewScreen` — Arabic RTL form: surah dropdown (Arabic names from `kSurahs`), ayah from/to number fields (validated `1..ayahCount`, `to >= from` — mirrors contracts rules client-side), quality choice chips (`GOOD | FAIR | POOR` → جيد / مقبول / ضعيف); submit → `repository.logReview` → optimistic list update; `RecentReviewsList` from cache showing pending-sync badge on `pendingSync` items; outbox count via `SyncWorker.pendingCountStream` shown in app bar; `main.dart` wires `MaterialApp.router` with `locale: Locale('ar')`, RTL, `flutter_localizations` + generated `AppLocalizations` from arb, Cairo font via `google_fonts` (bundling assets deferred to a later increment).

- [ ] **Step 1: Failing widget test** — `log_review_screen_test.dart` (fake repository + fake sync worker via riverpod overrides):
  1. Form renders Arabic labels; directionality is RTL (`tester.platformDispatcher.localeTestValue` + widget finds `Directionality` with `TextDirection.rtl`).
  2. Submitting valid form with repository in offline mode (fake returns Ok + `pendingSync: true`) → new list entry shows pending badge; outbox badge shows `1`.
  3. Invalid range (ayahTo < ayahFrom) → validation error text (Arabic), no repository call.
  4. Simulated flush (fake worker emits cleared pending) → badge disappears.

- [ ] **Step 2: Run — fail** — `flutter test` → FAIL.

- [ ] **Step 3: Implement** — arb keys (`app_ar.arb` in feature package):
```json
{
  "@@locale": "ar",
  "logReviewTitle": "تسجيل مراجعة",
  "surah": "السورة",
  "ayahFrom": "من الآية",
  "ayahTo": "إلى الآية",
  "quality": "التقييم",
  "qualityGood": "جيد",
  "qualityFair": "مقبول",
  "qualityPoor": "ضعيف",
  "submit": "سجّل",
  "pendingSync": "بانتظار المزامنة",
  "rangeError": "الآية الأخيرة يجب أن تكون بعد الأولى",
  "recentReviews": "المراجعات الأخيرة"
}
```
`apps/mobile/lib/l10n/app_en.arb`: English mirror; `l10n.yaml` with `synthetic-package: false` (or default per current Flutter) generating `AppLocalizations`. Screens read `AppLocalizations.of(context)!`.
Router: `/login` → LoginScreen (from features/auth; create its Arabic screen here using the same arb pattern — login title/email/password strings), `/` → LogReviewScreen; redirect rule: no session → `/login`.

- [ ] **Step 4: Run — pass** — `flutter test` in feature package → PASS; `flutter test` in `apps/mobile` → PASS.

- [ ] **Step 5: Commit** — `git add -A && git commit -m "feat(hifz_logging): arabic rtl log-review screen with outbox badge"`

---

### Task 20: Mobile shell polish + RTL/font verification

**Files:**
- Create: `apps/mobile/test/rtl_smoke_test.dart`
- Modify: `apps/mobile/lib/main.dart`

**Interfaces:**
- Produces: Booted app defaults to Arabic RTL with Cairo font; `rtl_smoke_test.dart` pumps `HifzTrackerApp` with faked repos → asserts `Directionality.textDirection == TextDirection.rtl` and Arabic title rendered; manual run instructions for a physical device/emulator.

- [ ] **Step 1: Write the smoke test** — pump app with riverpod overrides (fake auth logged in as student, fake data); expect RTL + `تسجيل مراجعة` text.
- [ ] **Step 2: Run — fail** (any missing wiring) → wire `main.dart` (`GoogleFonts.cairoFontTheme` for light/dark, `supportedLocales: [ar, en]`, `localizationsDelegates` incl. generated).
- [ ] **Step 3: Run — pass** — `cd apps/mobile && flutter test` → PASS.
- [ ] **Step 4: Manual device check** — `flutter run` on an emulator: login (user seeded in Task 13), log review with Wi-Fi off → pending badge; re-enable → badge clears; check dashboard web shows the review. This completes the skeleton's offline proof.
- [ ] **Step 5: Commit** — `git add -A && git commit -m "feat(mobile): arabic-first shell with rtl smoke test"`

---

### Task 21: CI — GitHub Actions with affected-only + drift checks

**Files:**
- Create: `.github/workflows/ci.yml`

**Interfaces:**
- Produces: CI on push/PR to `main`: (1) `js` job — Node 22 + pnpm via corepack, `pnpm install --frozen-lockfile`, `docker compose up -d db`, prisma migrate deploy against CI db, `pnpm turbo run lint typecheck test build --affected` (with `origin/main` base on PRs); (2) `dart` job — Flutter stable + melos, `melos bootstrap`, `melos run test`; (3) `drift` job — needs js+dart: java 17 setup, `./scripts/gen-dart.sh`, `pnpm gen:quran`, `git diff --exit-code dart-packages/ packages/contracts/quran/` (regenerated artifacts must match committed ones).

- [ ] **Step 1: Workflow file** — `.github/workflows/ci.yml`:
```yaml
name: ci
on:
  push: { branches: [main] }
  pull_request:

jobs:
  js:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env: { POSTGRES_DB: hifz_test, POSTGRES_USER: hifz, POSTGRES_PASSWORD: hifz }
        ports: ["5432:5432"]
        options: >-
          --health-cmd pg_isready --health-interval 10s --health-timeout 5s --health-retries 5
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }
      - uses: actions/setup-node@v4
        with: { node-version: 22, cache: pnpm }
      - run: corepack enable
      - run: pnpm install --frozen-lockfile
      - run: pnpm --filter api exec prisma migrate deploy
        env: { DATABASE_URL: postgresql://hifz:hifz@localhost:5432/hifz_test }
      - run: pnpm turbo run lint typecheck test build --affected
        env:
          DATABASE_URL: postgresql://hifz:hifz@localhost:5432/hifz_test
          JWT_ACCESS_SECRET: ci-secret-ci-secret-ci-secret-ci-secret-32
          API_URL: http://localhost:3001/api/v1
  dart:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }
      - uses: dart-lang/setup-dart@v1
      - uses: subosito/flutter-action@v2
        with: { channel: stable, cache: true }
      - run: dart pub global activate melos
      - run: melos bootstrap
      - run: melos run analyze
      - run: melos run test
  drift:
    needs: [js, dart]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 22 }
      - uses: actions/setup-java@v4
        with: { distribution: temurin, java-version: 17 }
      - uses: subosito/flutter-action@v2
        with: { channel: stable }
      - run: corepack enable && pnpm install --frozen-lockfile
      - run: dart pub global activate melos && melos bootstrap
      - run: ./scripts/gen-dart.sh && pnpm gen:quran
      - run: git diff --exit-code dart-packages/ || (echo "::error::generated dart files are stale — run pnpm gen:dart && pnpm gen:quran" && exit 1)
```
(If openapi-generator needs flutter/dart for post-processing, `melos bootstrap` before gen covers it.)

- [ ] **Step 2: Verify locally what CI checks** — Run: `./scripts/gen-dart.sh && pnpm gen:quran && git status --short` → empty (no diff).
Expected: clean tree — committed artifacts are current.

- [ ] **Step 3: Commit** — `git add -A && git commit -m "ci: affected checks + openapi/dart drift detection"`

---

## Completion Checklist (maps to spec §11 walking skeleton)

- [ ] Repo scaffolded: pnpm + Turborepo + Melos + compose; three apps boot (Tasks 1, 5, 11, 14, 18)
- [ ] Mobile bootstrapped Arabic-first RTL, never retrofitted (Tasks 19–20)
- [ ] Auth end-to-end: register/login/refresh, role guard (Tasks 7, 12, 18)
- [ ] Student logs review from mobile through outbox, offline-capable, visible on teacher dashboard (Tasks 8, 13, 17, 19)
- [ ] `pnpm gen:dart` wired; CI drift check green (Tasks 9, 16, 21)
