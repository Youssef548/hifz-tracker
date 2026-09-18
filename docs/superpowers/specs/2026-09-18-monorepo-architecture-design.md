# Hifz Tracker — Monorepo Architecture Design

- **Date:** 2026-09-18
- **Status:** Approved (design review) — pending implementation plan
- **Path:** Architectural (greenfield project)

## 1. Context

A Quran hifz (memorization) tracking platform with a **student + teacher model**: students log
recitations and reviews of memorized portions; teachers assign portions and track a roster.
The teacher-facing dashboard is the primary web surface alongside a marketing landing page.

Deliverables: **one NestJS backend** serving all clients, a **Flutter mobile app** (first mobile
project for the author; 3 years MERN/NestJS experience), and **one Next.js web app** (landing +
dashboard). Mobile usage happens frequently in mosques with weak connectivity.

Primary architectural goal: **maximize code sharing from day one while keeping apps decoupled** —
boundaries enforced by tooling, not convention.

## 2. Decisions

| # | Decision | Choice | Alternatives considered | Rationale |
|---|----------|--------|------------------------|-----------|
| D1 | Day-1 product shape | Student + Teacher | Solo tracker; masjid program | Teacher console is a first-class surface; schema avoids multi-teacher/cohort complexity for now |
| D2 | Web stack | Next.js for landing + dashboard, **one app** with route groups | Flutter web dashboard; Astro landing + Next dashboard | Matches team strength; one web framework; SSR/SEO for landing; single deploy |
| D3 | Mobile connectivity | **Online-first + queued writes** | Full offline-first sync; online-only | ~80% of offline value at ~20% complexity; right-sized for first Flutter project |
| D4 | API contract | **Nest-first, zod schemas in shared package**; OpenAPI → generated Dart client | Spec-first OpenAPI; GraphQL | Single source of truth; leans on Nest strength; generation only across the language boundary |
| D5 | Monorepo tooling | pnpm workspaces + Turborepo + Melos | Nx; plain pnpm | Low magic; each tool stays in its lane; plays to existing skills |
| D6 | Database | PostgreSQL + Prisma | TypeORM; MongoDB/Mongoose | Domain is relational; typed client + schema-as-code |
| D7 | Mobile state / local store | Riverpod + drift (SQLite) | Bloc; Isar | Riverpod DI fits layered packages; drift gives SQL for cache + outbox |
| D8 | Auth (day 1) | Email/password + JWT access + rotating refresh; roles `student\|teacher\|admin` | Social login immediately | Retrofitting identity is the classic monorepo killer; password-only avoids Apple's "social login ⇒ Sign in with Apple" requirement until we choose to add it |
| D9 | Hosting | VPS + Docker Compose | Managed platforms (Vercel + managed Postgres) | Confirmed during review — matches team background; deployment-only concern, no architectural impact |
| D10 | Desktop | Installable **PWA** (the dashboard web app) | Electron desktop app | Dashboard + browser already covers desktop; Electron adds packaging/maintenance for near-zero day-1 value. Boundary rules allow adding an `apps/desktop` later without rework |
| D11 | UI language | **Mobile: Arabic-first, RTL.** Web: English-only. Content (Quran text, surah names): Arabic everywhere | English UI everywhere | Students (mobile) are Arabic-speaking; teachers' dashboard stays English for now. Flutter l10n + RTL from the scaffold stage — retrofitting RTL is expensive. Web can add locale routing later without structural change |

## 3. Topology

```
hifz-tracker/
├── apps/
│   ├── api/            # NestJS — single backend for all clients
│   ├── web/            # Next.js — (marketing) + (dash)/dashboard route groups
│   └── mobile/         # Flutter app — thin shell: routing, DI wiring, composition only
├── packages/           # TypeScript (pnpm workspace)
│   ├── contracts/      # zod schemas + inferred types + constants + Quran metadata JSON. Depends on nothing.
│   ├── api-sdk/        # Typed fetch wrapper for web (base URL, auth, error envelope)
│   ├── ui/             # Design system: Tailwind + shadcn/ui (web only)
│   └── config/         # Shared tsconfig / eslint / prettier presets
├── dart-packages/      # Managed by melos.yaml
│   ├── core/           # Env config, Result type, error mapping, connectivity
│   ├── api_client/     # GENERATED from OpenAPI spec — never hand-edited
│   ├── data/           # Repositories: generated client + drift cache + write queue (outbox)
│   └── features/       # auth/, hifz_logging/, progress/ … one package per feature
├── docker-compose.yml  # Postgres + Redis for local dev
├── turbo.json
├── melos.yaml
└── pnpm-workspace.yaml
```

## 4. Sharing model

One schema system, three consumers; generation happens **only** across the language boundary.

1. **`packages/contracts` (zod-first).** Every DTO is a zod schema with OpenAPI extensions
   (`zod-openapi` style). Nest validates requests with them via `nestjs-zod`; Next imports the
   *same* schemas for form validation and inferred types. No TypeScript codegen — web and API
   share one repo and one version, so direct imports beat generated indirection.
   - *Fallback trigger:* if `nestjs-zod`'s OpenAPI generation blocks the walking skeleton,
     switch to class-validator DTOs + `@nestjs/swagger`, and generate web types with orval.
     Boundaries are unchanged; one more codegen step.
2. **Flutter client generation.** Nest serves the OpenAPI spec at `/docs-json`;
   `pnpm gen:dart` runs `openapi-generator-cli` (dart-dio) into `dart-packages/api_client`.
   CI regenerates and fails on `git diff --exit-code` — the client can never drift from the API.
3. **Quran metadata.** Surah list (Arabic + transliterated names), ayah counts, Juz/Hizb
   divisions live as one JSON file in `contracts`; a small script generates the Dart constants
   file from it. Single data source; Arabic content is served identically on every surface.

## 5. Dependency rules (enforced, not conventional)

- `apps/*` never import each other. Cross-app communication is the API, exclusively.
- `packages/*` and `dart-packages/*` never import from `apps/*`. Dependencies point inward.
- `contracts` depends on nothing. `api-sdk` depends only on `contracts`.
- `features/*` reach the backend only through `data` repositories.
- Generated packages (`api_client`) are leaves: deletable and regenerable at any time.
- Every package exposes one public entry (`index.ts` / package `exports`); deep imports are
  forbidden. On the TypeScript side, ESLint import boundaries make violations **build errors**;
  on the Dart side, packages keep a single public entry directory and are checked in review
  (custom import lint can be added when the package count grows).

## 6. Backend design (apps/api)

- **Modular monolith.** One Nest module per domain: `auth`, `users`, `students`, `teachers`,
  `assignments`, `reviews`, `progress`. Each module owns its Prisma models; cross-module access
  goes through the owning module's service, never direct model queries.
- **REST** under `/api/v1`. OpenAPI JSON always current (spec emitted from the running app).
- **Auth:** email/password (bcrypt/argon2), short-lived JWT access token, rotating refresh
  tokens, role guard. Passport strategy structure keeps Google/Apple a later drop-in.
- **Idempotent writes:** create endpoints accept an `Idempotency-Key` header (client-generated
  UUID); API dedupes on retry. This is the safety net that makes the mobile outbox safe.
- **Async jobs:** Redis + BullMQ deferred until a real job exists (e.g., review-schedule
  notifications). Not scaffolded empty.

## 7. Mobile design (apps/mobile + dart-packages)

- **Flow:** UI → feature controller (Riverpod) → repository (`data`). Repositories call the
  generated client and own drift tables (read cache + `outbox`).
- **Online:** request passes through; response cached for offline reads.
- **Offline:** writes land in the `outbox` table; UI updates optimistically; a sync worker
  flushes queued items on connectivity change with exponential backoff. Replayed writes are
  made safe by idempotency keys. **No sync engine, no conflict resolution** — concurrent
  two-device edits resolve last-write-wins, accepted for this product.
- **`apps/mobile` is a thin shell.** App skeleton, routing, DI composition. Logic growing in
  the shell is a smell: it belongs in `features/*`.
- **Arabic-first, RTL (D11):** scaffolded from day 1 — `flutter_localizations` + `gen-l10n`
  (arb files), Arabic locale as default with `Directionality.rtl` through Material, Arabic UI
  font and a proper mushaf font for Quran text (font selection itself is feature work).
  Localization assets live with the feature packages that use them.

## 8. Web design (apps/web)

- `src/app/(marketing)/` — landing page: static/ISR, SEO-first.
- `src/app/(dash)/dashboard/**` — teacher console. Server components fetch through `api-sdk`
  (cookie-forwarding); client forms validate with `contracts` zod schemas via react-hook-form
  resolvers.
- Middleware guards `(dash)` by session and role; teachers only.
- Design system in `packages/ui` (Tailwind + shadcn/ui). No page-level components in the
  package — only primitives and composed components.
- **Desktop story = PWA (D10):** the dashboard is installable — web app manifest + service
  worker (Serwist) for an offline app shell. English-only day 1; Next.js locale routing can
  be added later without structural change. Electron is a non-goal until proven otherwise.

## 9. Error handling

- **One error envelope** defined once in `contracts`:
  `{ error: { code: string, message: string, details?: unknown } }` with a stable machine
  `code` per failure (e.g., `AUTH_INVALID_CREDENTIALS`, `REVIEW_DUPLICATE_LOG`).
- **API:** Nest exception filter maps domain errors → envelope + correct HTTP status; zod
  validation failures → `VALIDATION_ERROR` with field details.
- **Web:** `api-sdk` throws typed errors parsed from the envelope; forms surface field errors.
- **Mobile:** `core` maps envelope → typed failures wrapped in a `Result<T, Failure>`;
  repositories never throw for expected failures. Outbox retries only retryable failures
  (network/5xx), never 4xx domain rejections, which are surfaced to the feature.

## 10. Testing strategy

| Layer | Tooling | Focus |
|-------|---------|-------|
| contracts | vitest | schema round-trips; OpenAPI extensions emit correctly |
| api | jest + supertest | unit tests per module; e2e against throwaway Postgres (Docker) |
| web | vitest + testing-library | form validation against contracts schemas; guarded routes |
| mobile | dart test + flutter_test | **outbox/sync worker logic is the riskiest code — highest coverage**; widget test for the log-review flow |
| CI | GitHub Actions + `turbo run --affected` | affected-only builds/tests; OpenAPI→Dart drift check |

## 11. Walking skeleton (first implementation milestone)

Prove every boundary with one vertical slice before any feature work:

1. Repo scaffolded: pnpm + Turborepo + Melos + docker-compose; all three apps boot; mobile
   bootstrapped with Arabic locale + RTL + l10n pipeline (never retrofit).
2. Auth end-to-end: register / login / refresh, role guard.
3. A student logs a review **from the mobile app** — through the outbox, offline-capable, in
   the Arabic RTL UI — and it **appears on the teacher dashboard**.
4. `pnpm gen:dart` wired and CI drift-check green.

Every subsequent feature (assignments, spaced-review scheduling, progress analytics,
notifications) gets its own spec → plan → implement cycle on this skeleton.

## 12. Non-goals / deferred

- No shared UI between Flutter and web (different platforms; forced sharing ages badly).
- No microservices, no GraphQL, no feature-flag system, no analytics, no billing.
- No full offline-first sync engine (queued writes only, by design).
- No Electron desktop app — desktop is the installable PWA dashboard (D10).
- Web i18n deferred: English-only day 1; mobile is Arabic-first RTL from day 1 (D11).

## 13. Open questions

Both review questions are resolved (§2: D9 hosting, D11 UI language). None currently open.
