# Hifz Tracker

A Quran memorization (*hifz*) tracking platform built around a **student + teacher** model. Students log recitations and reviews of memorized portions from an Arabic-first mobile app; teachers follow their students' progress from a web dashboard. A single NestJS API serves both.

> **Status:** walking skeleton. The vertical slice — repo scaffold, auth end-to-end, a student logging a review from the mobile app through an offline outbox, and it appearing on the teacher dashboard — is implemented and tested. Feature work (assignments, spaced-review scheduling, progress analytics, notifications) comes next.

## Architecture

One API, one web app, one Flutter app, sharing as much code as possible while keeping the apps decoupled — boundaries are enforced by tooling, not convention.

```
hifz-tracker/
├── apps/
│   ├── api/            # NestJS + Prisma — single backend for all clients
│   ├── web/            # Next.js — marketing landing + teacher dashboard (installable PWA)
│   └── mobile/         # Flutter — thin shell: routing, DI wiring, composition only
├── packages/           # TypeScript (pnpm workspace)
│   ├── contracts/      # zod schemas + inferred types + Quran metadata. The source of truth.
│   ├── api-sdk/        # Typed fetch client for web (generated OpenAPI types, auth, error envelope)
│   ├── ui/             # Design system: Tailwind + design tokens
│   └── config/         # Shared tsconfig / eslint presets (boundaries enforcement)
├── dart-packages/      # Dart (Melos-managed)
│   ├── core/           # Env config, Result type, error mapping, Quran constants
│   ├── api_client/     # GENERATED from OpenAPI — never hand-edited
│   ├── data/           # Repositories: generated client + drift cache + write outbox
│   └── features/       # auth/, hifz_logging/ — one package per feature
└── docker-compose.yml  # Postgres 16 (+ Redis 7, not yet used)
```

**Diagrams.** [`docs/architecture/`](docs/architecture/) maps this out visually — the system
diagram and the repository tree, as SVG, PNG, and editable Excalidraw scenes. Open
[`docs/architecture/index.html`](docs/architecture/index.html) for both in one page.

**How sharing works.** `packages/contracts` holds every DTO as a zod schema with inferred TypeScript types. The API validates requests with those schemas and the web app imports the *same* schemas for form validation — one repo, one version, direct imports. Where a hand-written declaration would otherwise duplicate the API, we generate instead: the API emits an OpenAPI document, `pnpm gen:dart` turns it into `dart-packages/api_client`, and `pnpm gen:api-types` turns it into the route types behind `packages/api-sdk`. CI regenerates both and fails on drift, so no generated client can fall behind.

**Dependency rules (enforced as build errors).** `apps/*` never import each other — cross-app communication is the API. `packages/*` never import from `apps/*`. Every package exposes one public entry; deep imports are forbidden. On the TypeScript side ESLint boundaries make violations fail the build.

## Prerequisites

| Tool | Version | Needed for |
| --- | --- | --- |
| Node.js | 22 LTS (see `.node-version`) | API, web, packages |
| pnpm | 9.15 (via Corepack) | JS workspace |
| Docker | any recent | local Postgres (and Redis, unused so far) |
| Flutter | stable (Dart 3.13+) | mobile app and all Dart packages |
| Java | 17 | `pnpm gen:dart` (OpenAPI → Dart) |

Melos is **not** a global install — it is a dev dependency of the root `pubspec.yaml`, so it runs through `dart run melos`.

## Getting started

```bash
docker compose up -d                     # Postgres 16 on :5432
corepack enable && pnpm install
cp apps/api/.env.example apps/api/.env   # JWT_ACCESS_SECRET must be >= 32 chars
cp apps/web/.env.example apps/web/.env
pnpm --filter api exec prisma migrate deploy
pnpm dev                                 # api on :3001, web on :3000
```

Then check <http://localhost:3001/api/v1/health> → `{"status":"ok"}` and <http://localhost:3000>.

For schema changes during development use `pnpm --filter api db:migrate` (creates a migration) rather than `db:deploy`.

The `.env` files are gitignored, so a fresh `git worktree` needs its own `cp` steps before `api#test` will run — without them it fails with `JwtStrategy requires a secret or key`, which reads like a code bug but is pure setup.

### Mobile app

```bash
dart pub get                # root — installs Melos
dart run melos bootstrap    # links all Dart packages
cd apps/mobile
flutter run                 # Android emulator reaches the host via 10.0.2.2 by default
```

Point it elsewhere with `--dart-define=API_BASE_URL=http://localhost:3001` (the iOS simulator uses the plain loopback address).

## Testing

```bash
pnpm turbo run lint typecheck test build    # TypeScript side (API e2e needs Postgres up)
dart run melos run analyze                  # every Dart package
dart run melos run test                     # dart test for pure packages, flutter test for apps
```

The API's `test` task runs its supertest e2e suite, which exercises auth, the error envelope, and idempotent review logging against a real database.

## Code generation

```bash
pnpm gen:dart       # OpenAPI spec -> dart-packages/api_client (requires Java 17)
pnpm gen:api-types  # OpenAPI spec -> packages/api-sdk/src/generated (requires Postgres)
pnpm gen:quran      # packages/contracts/quran/surahs.json -> Dart Surah constants
```

`dart-packages/api_client` and `packages/api-sdk/src/generated/` are fully generated — **do not hand-edit them**. CI regenerates all three and fails if the committed artifacts differ, so run these after touching a controller, a contract schema, or `surahs.json`.

## Conventions

- **Error envelope.** Every failure returns `{ error: { code, message, details? } }`, with a stable machine-readable `code`. Mobile maps it to a typed `ApiFailure` wrapped in `Result<T, Failure>`.
- **Idempotent writes.** Write endpoints that create resources accept an `Idempotency-Key` header (client-generated UUID). Replaying a request returns the original resource instead of creating a duplicate — this is what makes the mobile outbox safe to retry.
- **Offline writes.** The mobile app is online-first with a queued-write outbox: a write that fails for a retryable reason (network/5xx) is stored in drift and echoed optimistically with a pending badge; a 4xx domain rejection is surfaced to the user and never queued. There is deliberately no full sync engine and no conflict resolution — concurrent edits resolve last-write-wins.
- **Arabic-first mobile, English-only web.** Mobile ships `ar` as the default locale with RTL and an Arabic UI font; the web dashboard is English for now.
- **API surface.** REST under `/api/v1`. Roles are `STUDENT | TEACHER | ADMIN`.

## Roadmap

The walking skeleton intentionally excludes: assignments and a teacher/student roster, spaced-review scheduling, progress analytics, notifications (Redis/BullMQ is in compose but unused), social login, and full offline-first sync.

## License

No license has been chosen yet — add one before accepting contributions.
