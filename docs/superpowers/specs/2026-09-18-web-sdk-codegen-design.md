# Web SDK generated from OpenAPI

- **Date:** 2026-09-18
- **Status:** Draft — pending review
- **Path:** Architectural (changes an interface `apps/web` depends on)

## 1. Context

`packages/api-sdk` is a hand-written typed fetch client. It re-declares, in TypeScript, every
route the API exposes: path strings, HTTP methods, request shapes, and response shapes. Nothing
mechanically ties it to the API — it is a second, silent declaration of the contract that drifts
whenever a controller changes.

This is the only genuinely duplicated contract surface in the repo. `packages/contracts` is a
single declaration consumed by both sides by design; `apps/api` validates with it through
`nestjs-zod`; `apps/web` uses the same zod schemas for `zodResolver`. The hand-written client is
what breaks the "declare once" story.

The Dart client does not have this problem: `dart-packages/api_client` is generated from the same
OpenAPI document by `pnpm gen:dart`, and CI fails on drift.

**Related defect found while drafting this spec (out of scope, must be fixed separately):** the
generated Dart client's paths already carry the `/api/v1` prefix and its `basePath` is the origin
(`http://localhost`), but `apps/mobile` builds `HifzApiClient` with `baseUrl = AppEnv.apiV1`
(which appends `/api/v1`). That produces `/api/v1/api/v1/...`. The Dart smoke test only asserts
construction, never issues a request, so it passes. This is a live bug in the mobile data path.

## 2. Goal

Replace the hand-written route surface in `packages/api-sdk` with types generated from the API's
OpenAPI document, without changing anything a consumer of `@hifz/api-sdk` can observe.

**Success criteria**

- `apps/web` compiles and its tests pass **unchanged** — no import, no call site, no env change.
- The public surface `createApiClient({ baseUrl, getAccessToken })` and `ApiError` behave exactly
  as today.
- The generated artifact is committed and drift-checked in CI, like the Dart client.
- Route, method, request, and response types are mechanically derived from the API, so a
  controller change surfaces as a type error rather than a runtime surprise.

**Non-goals**

- Moving the contract out of `packages/contracts` (that is phase B, §9).
- Adopting Nestia, typia, `ttsc`, TypeScript 7, or a Go toolchain.
- Generating runtime validators for the web. Zod remains the only validator on the frontend.
- Generating react-query hooks, MSW handlers, or a second zod layer.
- Any change to the API's validation, OpenAPI emission, or the Dart generation path.

## 3. Decision

**`openapi-typescript` (types only) + `openapi-fetch` (6 kB fetch client), behind the existing
hand-written facade.**

Rationale, from the comparison performed during brainstorming:

- **Smallest committed surface.** One `schema.d.ts` rather than a generated tree, which matters
  because the artifact is committed and `git diff --exit-code`'d in CI.
- **Middleware matches our requirements exactly.** `onRequest` sets `Authorization` and
  `Idempotency-Key`; `onResponse` reads the error envelope and throws our `ApiError`. That is the
  whole of the hand-written client, and it stays hand-written — deliberately.
- **No runtime validator on the frontend.** Zod already serves `zodResolver`; generating zod (as
  orval does) would create two validators, which is the outcome this design exists to avoid.
- Rejected: **orval** (react-query hooks and MSW we do not use, a second zod layer, large
  committed surface) and **openapi-generator `typescript-fetch`** (its TypeScript target does not
  support `oneOf`/`anyOf`/`allOf`/union, so it cannot express the schemas we will need).

Cost accepted: a hand-written facade of roughly 40 lines remains. Generating it would add
generated surface to review, not remove hand-written logic.

## 4. Architecture

```
packages/api-sdk/
├── src/generated/schema.d.ts   # generated from generated/openapi.json — never hand-edited
├── src/client.ts               # hand-written facade (auth, idempotency, envelope → ApiError)
└── src/index.ts                # public surface — unchanged
```

- `openapi-typescript` is a **devDependency**; `openapi-fetch` is a **dependency**.
- A new root script `gen:api-types` regenerates the types from `generated/openapi.json`. Because
  producing that document boots the API (env validation plus a Prisma connection), the script
  requires a running Postgres — the same constraint `gen:dart` already has.
- The generated file is committed. CI regenerates it and fails on diff.

### Base URL semantics

The generated path keys include the `/api/v1` prefix (`/api/v1/auth/login`), and the Dart client
already assumes exactly that with an origin-only base path. To keep `apps/web` untouched, the
facade preserves its current public meaning — `baseUrl` **includes** `/api/v1` — and derives the
origin before handing it to `openapi-fetch`:

```ts
const origin = baseUrl.replace(/\/api\/v1\/?$/, '');
```

Callers see no change; the prefix is never sent twice. If a caller passes an origin-only base URL
the replacement is a no-op and the behaviour is still correct, so both forms work.

## 5. Data flow and error handling

Unchanged from any consumer's perspective:

1. `createApiClient({ baseUrl, getAccessToken })` builds an `openapi-fetch` client with the
   derived origin and registers middleware.
2. `onRequest` attaches `Authorization: Bearer <token>` when `getAccessToken()` returns a value,
   and attaches `Idempotency-Key` on the review-create call.
3. `onResponse` inspects non-2xx responses; if the body matches `{ error: { code, message,
   details } }` it throws `ApiError(status, code, message, details)`, otherwise
   `ApiError(status, 'INTERNAL', ...)`. Status and envelope parsing semantics are identical to
   today.
4. Request bodies and response types come from the generated `paths` rather than hand-written
   interfaces.
5. **Runtime response parsing is deliberately retained.** Today the facade validates each response
   with a zod schema from `@hifz/contracts` (`schema.parse`) and throws on mismatch. Dropping that
   for compile-time types alone would silently change behaviour — a malformed response would pass
   instead of raising. The facade therefore keeps parsing responses with the same contracts
   schemas, and the generated types take over the **compile-time** role. Both layers are wanted:
   types catch contract drift at build time, zod catches a misbehaving server at runtime.

   Rejected alternative: drop zod parsing entirely. It is fewer lines and zod is technically
   redundant with the generated types, but it weakens a guarantee the current implementation
   provides, and this spec's success criterion is that no consumer-observable behaviour changes.

Guard: the facade keeps its own `auth` / `reviews` method names and signatures, so the change is
implementation-only.

## 6. Testing

- `packages/api-sdk/test/client.test.ts` is rewritten to test the facade's **behaviour** through
  msw rather than its hand-written typing: bearer header present, `Idempotency-Key` forwarded,
  envelope mapped to `ApiError` with the right `status`/`code`, and error propagation. The suite
  stays at four tests — the current four, rewritten to assert behaviour.
- `apps/web` tests must pass **without modification** — this is the regression check that the
  public surface really is unchanged.
- A drift check is added to CI alongside the Dart one.

## 7. CI

Extend the existing `drift` job (it already provisions Postgres and Java):

1. generate `generated/openapi.json` and the api-sdk types;
2. `git diff --exit-code packages/api-sdk/src/generated/` in addition to `dart-packages/`.

Also add a root `gen:api-types` script
(`openapi-typescript generated/openapi.json -o packages/api-sdk/src/generated/schema.d.ts`)
alongside the existing `gen:dart` and `gen:quran`.

## 8. Risks

| Risk | Mitigation |
|---|---|
| Generated types are absent/stale for typecheck | Types are committed; CI drift check fails on staleness; typecheck depends on `^build` today and will pick them up. |
| `openapi-fetch` middleware subtlety (response bodies are stateful) | Read the envelope via `response.clone()`; covered by the ApiError msw test. |
| Generated output churn between runs | `openapi-typescript` output is deterministic for a fixed spec; the drift job proves it, as it already does for Dart. |
| The facade quietly diverges from the API | Route/enum/body types are generated, so divergence becomes a compile error. |
| Bundle regression on `/login` (client-side) | `openapi-fetch` is 6 kB versus the current client's import of runtime zod parsing; measure First Load JS before/after. |

## 9. Out of scope — phase B

Moving the contract so the API owns it and the web consumes generated artifacts. Deferred until
this codegen loop is proven, because it touches `apps/web`, the dependency-boundary rules, and the
mobile path. It gets its own spec.

## 10. Exit criteria

- `pnpm turbo run lint typecheck test build` → 14/14 tasks.
- `dart run melos run analyze` and `melos run test` → green (unaffected, but proves no collateral damage).
- `git status --short` clean after a full regeneration (`gen:api-types`, `gen:dart`, `gen:quran`).
- `apps/web` source and tests unmodified.
- CI green on all three jobs.
