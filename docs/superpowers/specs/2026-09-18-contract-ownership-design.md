# Contract ownership (phase B)

- **Date:** 2026-09-18
- **Status:** Accepted — Option A implemented
- **Path:** Documentation + one package boundary change

## 1. Context

`2026-09-18-web-sdk-codegen-design.md` §9 deferred a change it called phase B:

> Moving the contract so the API owns it and the web consumes generated artifacts. Deferred until
> this codegen loop is proven, because it touches `apps/web`, the dependency-boundary rules, and the
> mobile path. It gets its own spec.

This is that spec. Two things framed the decision:

1. **The deferral condition is met.** The `drift` job now runs and passes in CI. Until 2026-09-18 it
   had never executed — it is gated on `js`, which was failing — so "this codegen loop is proven" was
   true only on a developer machine.
2. **Phase B as worded supersedes an existing decision.** The monorepo architecture spec chose
   *"D4 | API contract | Nest-first, zod schemas in shared package"* and §4.1 says *"No TypeScript
   codegen — web and API share one repo and one version, so direct imports beat generated
   indirection."* Moving the contract so the API owns it and web consumes generated artifacts
   contradicts both. Honouring the wording means amending that spec, not just changing code.

## 2. What was actually duplicated

Measured before choosing:

| Surface | State | Enforced? |
|---|---|---|
| Route / method / request / response types | Generated (phase A for TS, `gen:dart` for Dart) | Yes — CI drift check |
| Zod schemas (api ↔ web) | The same objects from `packages/contracts` | N/A — cannot drift |
| **Error envelope shape** | Declared, but **absent from the OpenAPI document**; no controller documented it, so it was in none of the generated clients | **No** |
| **Error code vocabulary** | `ErrorCodes` was exported and imported by **nothing**; the seven codes were hardcoded in the API filter (7), the web session route (4), the login form (1) and `api-sdk` (1) | **No** |
| **Retry semantics** | Dart re-declared its own vocabulary (`retryableCodes = {'NETWORK','SERVER'}`), where `NETWORK`/`SERVER` exist nowhere on the server. Asserted only in a Dart unit test, while the mobile outbox depends on it | **No** |
| **Quran dataset** | `packages/contracts/quran/surahs.json` lived inside the *wire contract* package; `scripts/gen-quran-dart.mjs` reached into that path | Path coupling only |

So phase B's stated rationale — a second silent declaration of the contract — **was already
eliminated by phase A**. The duplication that remained was the error contract (shape, vocabulary and
retry semantics) and the dataset conflation.

## 3. Options considered

- **Option A — close phase B as unnecessary; fix the real drift in place.** Keep `packages/contracts`
  hand-authored (D4 intact); type the code vocabulary; put the envelope in the OpenAPI document so
  Dart is generated for it; split the dataset into `packages/quran`.
- **Option B — ownership move only.** Author schemas under `apps/api` and emit them into
  `packages/contracts` as generated source. Supersedes D4, adds a codegen loop, and fixes no drift on
  its own (the schemas are one shared object either way).
- **Option C — API-authoritative via the OpenAPI document.** Every client consumes generated
  artifacts. Highest consistency, highest cost. The crux: the web needs zod for `zodResolver`, and
  generating zod from OpenAPI is lossy — it cannot carry `.default('STUDENT')`, the
  `ayahTo >= ayahFrom` refinement, or custom messages. Phase A also explicitly rejected a second zod
  layer.

## 4. Decision

**Option A.** It closes every surface that demonstrably drifts, for a fraction of option C's cost,
and it keeps D4 and the boundary rules intact. It is also the only option that improves the *mobile*
side, where the consequence is real: the outbox retry policy depended on a Dart-only code list that
nothing tied back to the server.

Option C is deferred until something forces it (a third client, or a drift incident this did not
prevent). Option B is rejected as the weakest value per unit of cost: it would not have prevented any
of the drift in §2.

## 5. What was implemented

1. **Typed code vocabulary.** The filter, the web session route, the login form and `api-sdk` now use
   `ErrorCodes.*`; the filter's mapping is typed `ErrorCode`. Literals remain only in
   `packages/contracts/src/error.ts` and in tests — deliberately, since a test asserting the literal
   wire value is what catches an accidental rename of a code's value.
2. **Envelope in the document.** `ErrorEnvelopeDto` (from `ErrorEnvelopeSchema`) documents the error
   responses on every endpoint that can produce them (400/401/403/409 as applicable — not 500, and
   not 403 where `RolesGuard` cannot fire). `ErrorEnvelope` now appears in `components.schemas`, so
   both generated clients carry the shape.
3. **Dart uses the generated model.** `failure_mapper.dart` deserializes through the generated
   `ErrorEnvelope` rather than reading `envelope['code']` by hand, so a change to the envelope breaks
   the build instead of silently reading a missing key. It keeps the status-based fallback for
   malformed bodies — `NETWORK`/`SERVER` remain client-side codes, so `ApiFailure.code` stays a
   `String`.
4. **Dataset split.** New `packages/quran` owns `quran/surahs.json`, the `Surah` type, `surahs`,
   `surahByNumber` and the `quran:data` fetch script. `contracts` no longer exports `./quran`, no
   longer needs `resolveJsonModule`, and the Dart generator reads the new path.
5. **Docs.** Architecture spec §4.3 (dataset moved, with the reason) and §5 (`quran` depends on
   nothing); README package list and `gen:quran` path.
6. **Dead dependency removed.** `packages/ui` declared `@hifz/contracts` but never imported it.

## 6. Verification

- `pnpm turbo run lint typecheck test build` → **19/19** tasks (16 before; `@hifz/quran` adds
  build/test/typecheck).
- `dart run melos run analyze` → no issues in all 6 packages; `melos run test` → all green,
  including `hifz_data`'s envelope-path tests.
- Generation is **deterministic**: three consecutive `gen:dart` + `gen:quran` + `gen:api-types` runs
  produced byte-identical trees.
- `grep -rE "'(VALIDATION_ERROR|…)'" apps packages scripts --include=*.ts --include=*.dart` returns
  hits only inside `packages/contracts/src/error.ts` (production source).
- `ErrorEnvelope` present in `generated/openapi.json`; error statuses documented per endpoint.
- `apps/web` changed only where it had to: one import (`surahByNumber`) and the code constants.

## 7. Risks

- **Superseding D4 was avoided, not resolved.** If a future decision picks option B or C, the
  architecture spec's D4/§4.1 must be amended in the same change — otherwise the repo documents two
  incompatible architectures.
- **Retry semantics remain client-owned.** `retryableCodes` is still a Dart-side policy; only the
  vocabulary is now authoritative. If retryability should be a server contract, that is a separate
  decision (it would need the document to express retryability).
- **Adding a package changes the CI task count**, so any documentation quoting "16 tasks" needs
  updating when packages are added.
