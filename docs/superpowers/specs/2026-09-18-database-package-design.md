# Hifz Tracker — Database Package Design

- **Date:** 2026-09-18
- **Status:** Approved (design review) — pending implementation plan
- **Path:** Architectural (restructures an existing component boundary)
- **Amends:** [`2026-09-18-monorepo-architecture-design.md`](2026-09-18-monorepo-architecture-design.md) §3 (topology gains one package). §5 dependency rules are unchanged and already permit this move.

## 1. Context

Prisma currently lives inside the backend: `apps/api/prisma/schema.prisma`, `apps/api/prisma/migrations/`, and a Nest-owned `apps/api/src/prisma/{prisma.module,prisma.service}.ts`. The schema is one 55-line file holding the datasource, two enums, and three models.

Two problems drive this change:

1. **The data layer is owned by a consumer.** The schema and its migration history are the most widely-shared artifact in the monorepo — every consumer reads the same tables — yet they sit inside one app. That is backwards, and it will get worse as the model count grows past three.
2. **One file does not scale.** A single `schema.prisma` is fine at three models and painful at thirty: every model edit is a merge conflict in the same file.

The repository is already shaped for the fix. §5 of the monorepo design states that dependencies point inward, `packages/*` never import from `apps/*`, and every package exposes exactly one public entry. ESLint's `boundaries` plugin enforces this as build errors (`packages/eslint-config/index.js`: `{ from: 'app', allow: ['package'] }`). A data package is the natural expression of a rule the repo already lives by, not an exception to it.

This spec extracts a framework-agnostic `@hifz/database` package and splits the schema per model, **without changing the logical schema or touching the database**. It is a move and a re-organisation, nothing more.

## 2. Decisions

| # | Decision | Choice | Alternatives considered | Rationale |
|---|----------|--------|------------------------|-----------|
| D1 | Where the data layer lives | New `packages/database` (`@hifz/database`) | `apps/db` as a deployable DB service; Nest-aware package | `apps/*` may not import each other (§5), so a consumed-by-api layer cannot be an app; a network DB service contradicts §12 "no microservices" and adds a hop the skeleton does not need. |
| D2 | Package coupling | Framework-agnostic: no `@nestjs/*` imports | Nest-aware package exporting `PrismaModule` + `PrismaService` | Keeps the data layer usable from scripts and future consumers; Nest wiring is one file and belongs with the app that owns the DI container. |
| D3 | Consumption shape | tsc-built package consumed like `@hifz/contracts` (`main`/`types`/`exports` → `dist/src/index.js`) | Raw-TS export like `@hifz/ui` | The API is CommonJS and already consumes `@hifz/contracts` as built dist through turbo's `^build`. Matching the sibling Node-runtime package is the lowest-risk path. |
| D4 | Schema layout | `prisma/schema/` folder scanned recursively, one file per model | Single `schema.prisma`; `schema/` split by concern (auth/billing) | Requested; scales without merge conflicts. Confirmed native in Prisma 6.19.3 — `schema?: string` is documented as *"the path to the schema file, or path to a folder that shall be recursively searched for `*.prisma` files"*. No preview flag. |
| D5 | Generated client | Generator keeps **default output**; `src/index.ts` re-exports `@prisma/client` | Explicit `output` inside the package, `exports` pointing straight at the generated client, no tsc build | Option B mirrors `@hifz/contracts` exactly and adds no new build mechanics. Option A is the documented upgrade path (see §7.3) — it becomes attractive when a self-contained deployable image exists (D9). |
| D6 | Migration history | Move `prisma/migrations/` as-is; no squash, no new migration | Squash into a fresh `init` | Names and checksums are unchanged, so `_prisma_migrations` is untouched and no reset is needed. Squashing would force every developer to reset. |
| D7 | Environment | Split: `packages/database/.env` owns migration-time `DATABASE_URL`; `apps/api/.env` keeps runtime config | Single root `.env` | Chosen by the author. `DATABASE_URL` now lives in two files, so a guard is added (§8.3) rather than relying on discipline. |
| D8 | Package name | `@hifz/database` | `@hifz/db` | Matches the existing `@hifz/contracts` / `@hifz/api-sdk` / `@hifz/ui` naming. |

## 3. Target topology

```
packages/database/                 # @hifz/database — framework-agnostic
├── prisma/
│   ├── schema/
│   │   ├── main.prisma            # generator + datasource only
│   │   ├── enums.prisma           # Role, Quality
│   │   ├── User.prisma
│   │   ├── RefreshToken.prisma
│   │   └── ReviewLog.prisma
│   ├── migrations/                # moved verbatim from apps/api/prisma/migrations
│   │   ├── 20260918133841_init/
│   │   └── migration_lock.toml
│   ├── .env                       # DATABASE_URL (gitignored)
│   └── .env.example
├── src/index.ts                   # single public entry
├── prisma.config.ts
├── package.json
├── tsconfig.json
└── tsconfig.build.json
```

`apps/api/src/prisma/` **stays in place** — `prisma.module.ts` and `prisma.service.ts` are Nest's DI wiring, and per D2 they belong to the app. Only the client **import source** changes inside `prisma.service.ts`.

## 4. The package

### 4.1 `package.json`

```json
{
  "name": "@hifz/database",
  "version": "0.1.0",
  "main": "./dist/src/index.js",
  "types": "./dist/src/index.d.ts",
  "exports": {
    ".": {
      "types": "./dist/src/index.d.ts",
      "default": "./dist/src/index.js"
    }
  },
  "scripts": {
    "db:generate": "prisma generate",
    "db:migrate": "node ../../scripts/check-db-env.mjs && prisma migrate dev",
    "db:deploy": "node ../../scripts/check-db-env.mjs && prisma migrate deploy",
    "build": "pnpm db:generate && tsc -p tsconfig.build.json",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "@prisma/client": "^6"
  },
  "devDependencies": {
    "@hifz/config": "workspace:*",
    "dotenv": "^18.0.0",
    "prisma": "^6",
    "typescript": "^5.7.3"
  }
}
```

Notes:

- **No `"type": "module"`.** `@hifz/contracts` omits it and compiles to CommonJS; the API (Nest) requires CJS. `@hifz/api-sdk` sets it because Next consumes it — not our case.
- **Only `build` generates the client.** `typecheck` is a bare `tsc --noEmit` and relies on turbo ordering it after `build` (§7.2) — two concurrent `prisma generate` runs race on the same output path. A standalone `pnpm --filter @hifz/database typecheck` therefore needs `build` to have run first; under turbo and in CI that is guaranteed.
- **No `lint` script**, matching `@hifz/contracts` (which also has none); turbo skips missing tasks.

### 4.2 `tsconfig.json` / `tsconfig.build.json`

Mirrors `@hifz/contracts` exactly:

```json
// tsconfig.json
{
  "extends": "@hifz/config/tsconfig/base.json",
  "include": ["src"]
}
```

```json
// tsconfig.build.json
{
  "extends": "@hifz/config/tsconfig/base.json",
  "compilerOptions": {
    "module": "commonjs",
    "moduleResolution": "node",
    "outDir": "dist",
    "rootDir": ".",
    "composite": false,
    "declaration": true,
    "declarationMap": true
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist"]
}
```

`rootDir: "."` with `include: ["src"]` is what produces `dist/src/index.js`, matching the `main` field, exactly as `@hifz/contracts` does.

### 4.3 `src/index.ts`

```ts
export * from '@prisma/client';
```

One entry, as §5 requires — consumers import `PrismaClient`, the `Prisma` namespace, `Role`, `Quality`, and generated model types from `@hifz/database` and never from `@prisma/client` directly. This is enforced by `import/no-extraneous-dependencies`: `@prisma/client` is a dependency of *this* package, so a direct import from `apps/api` fails lint.

### 4.4 `prisma.config.ts`

```ts
import 'dotenv/config';
import { defineConfig } from 'prisma/config';

export default defineConfig({
  schema: 'prisma/schema',
  migrations: { path: 'prisma/migrations' },
});
```

- `schema: 'prisma/schema'` points at the **folder**, which Prisma scans recursively for `*.prisma` (D4).
- `migrations.path` is load-bearing. A folder schema would otherwise default to `prisma/schema/migrations`, stranding the existing migration history at `prisma/migrations`. Pinning it keeps `20260918133841_init` exactly where it is (D6).
- `import 'dotenv/config'` is **explicit on purpose.** `dotenv` resolves `.env` from the process cwd, which is `packages/database` for every script in §4.1. With a config file present, implicit `.env` loading is not something to rely on — being explicit also documents which file feeds this package.

## 5. Schema layout

`main.prisma` — the only file with infrastructure blocks:

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}
```

| File | Contents moved from today's `schema.prisma` |
|------|---------------------------------------------|
| `main.prisma` | `generator client`, `datasource db` |
| `enums.prisma` | `enum Role`, `enum Quality` |
| `User.prisma` | `model User` (incl. `role Role @default(STUDENT)`, both relation fields) |
| `RefreshToken.prisma` | `model RefreshToken` (incl. `user User @relation`, `onDelete: Cascade`) |
| `ReviewLog.prisma` | `model ReviewLog` (incl. `student User @relation`, `@@index([studentId, loggedAt(sort: Desc)])`) |

Model bodies move **verbatim** — no field, attribute, or index is edited. Prisma merges the folder into one logical schema, so relations resolve across files by type name with no imports and no ordering constraints. That equivalence is the whole safety argument, and §9 verifies it rather than assuming it.

## 6. Consumer changes (`apps/api`)

### 6.1 `src/prisma/prisma.service.ts` — one line

```diff
-import { PrismaClient } from '@prisma/client';
+import { PrismaClient } from '@hifz/database';
```

The class body (`extends PrismaClient implements OnModuleInit, OnModuleDestroy`, `$connect`/`$disconnect`) is unchanged.

### 6.2 `package.json`

- **Add** `"@hifz/database": "workspace:*"` to `dependencies`.
- **Remove** `"@prisma/client": "^6"` from `dependencies`.
- **Remove** `"prisma": "^6"` from `devDependencies`.
- **Remove** the `db:migrate` and `db:deploy` scripts (they move to the package).

Verified safe: `@prisma/client` is imported by exactly one file in the whole API (`prisma.service.ts`, §6.1), and no API file imports Prisma's enums — roles come from `@hifz/contracts` via `roles.decorator.ts`.

### 6.3 Deleted

`apps/api/prisma/` in its entirety — `schema.prisma`, `migrations/20260918133841_init/`, `migrations/migration_lock.toml`. All of it is re-created under `packages/database/prisma/` with identical content.

### 6.4 Unchanged — deliberately

| File | Why it is untouched |
|------|--------------------|
| `src/prisma/prisma.module.ts` | Still Nest's `@Global()` wiring for `PrismaService` (D2). |
| `src/app.module.ts` | Still imports `PrismaModule`. |
| `test/auth.e2e-spec.ts`, `test/reviews.e2e-spec.ts` | Resolve `PrismaService` from `../src/prisma/prisma.service`; they never name the client. |
| `src/config/env.ts` | Split env (D7) means runtime config stays where it is. |
| `src/spec.ts` | Boots the app and writes `generated/openapi.json`; unaffected. |
| `scripts/gen-api-types.sh` | Only runs `pnpm --filter api run spec`; its Prisma dependency is transitive and still satisfied. |

## 7. Build and task wiring

### 7.1 `turbo.json` — one package-scoped override

`build` already declares `outputs: [".next/**", "!.next/cache/**", "dist/**"]`, which covers this package's `dist/`, and `build`/`test`/`typecheck` already declare `dependsOn: ["^build"]`, so turbo builds `@hifz/database` before the API type-checks or builds against it. The dependency topology needed no change — a useful sign it was already right.

One override was added anyway, for the reason §7.2 explains:

```json
"@hifz/database#typecheck": { "dependsOn": ["build"] }
```

### 7.2 Generate exactly once

Because the client is generated on demand (D5), `build` runs `db:generate` before `tsc`. Without it, a cold checkout yields `Module '"@prisma/client"' has no exported member 'PrismaClient'` — the single most confusing failure this design can produce.

The first implementation also put `db:generate` in the `typecheck` script, so that a standalone `pnpm --filter @hifz/database typecheck` would work on a cold checkout. That was wrong, and the reasoning is worth recording: turbo runs sibling tasks in parallel, so `@hifz/database#build` and `@hifz/database#typecheck` invoked `prisma generate` **concurrently against the same output path**, intermittently leaving `apps/api#typecheck` to read a half-written client. It failed perhaps one run in three — the worst kind of defect to leave in a CI task graph, because it teaches people to re-run rather than investigate.

Fixed by making `build` the sole generator and ordering `typecheck` behind it via the §7.1 override. Verified by counting invocations: `prisma generate` now runs **exactly once** per `turbo run typecheck`, and both tasks still work from cold under turbo.

### 7.3 Known cost of D5, and the upgrade path

With the default output under pnpm, the generated client's physical location is decided by pnpm's module resolution (today it lands in the virtual store, shared by version). That is invisible to consumers — `@hifz/database` is the only entry point — but it is an implicit dependency on the linker's behaviour, and it is the reason a future Docker image (D9) would want the generated client inside the package.

Upgrading to option A later is confined to three edits: add `output` to the generator block, repoint `exports` at the generated client, drop the `tsc` build. No consumer changes. Recorded here so the choice is revisited deliberately rather than rediscovered.

## 8. Environment

### 8.1 Files

- **New** `packages/database/.env` — `DATABASE_URL`, used by the Prisma CLI (migrations).
- **New** `packages/database/.env.example` — committed, mirrors the root `DATABASE_URL` default.
- **Unchanged** `apps/api/.env` — `DATABASE_URL` at runtime plus `JWT_*`, `REDIS_URL`, `PORT`.
- **Unchanged** `.gitignore` — the existing `.env` and `.env.*` patterns match at any depth, and `!.env.example` un-ignores the example file. Verified, no rule to add.

Note: the root `.env.example` is currently a stale near-duplicate of `apps/api/.env.example` (it differs in `JWT_ACCESS_SECRET` text and uses `API_PORT` rather than `PORT`). This design leaves it alone — converging app env files is out of scope (§12) and is the subject of an open question (§14).

### 8.2 Why CI is unaffected by the env split

CI never has `.env` files — they are gitignored — and passes `DATABASE_URL` as a real environment variable in both the `js` and `drift` jobs. `dotenv` does not override existing environment variables, so `prisma.config.ts` loads nothing in CI and the job-level value wins. The split is a local-development concern only.

### 8.3 The drift guard

Splitting `DATABASE_URL` across two files means migrating against one database while running against another fails **silently** — the worst failure mode in this design, and the one the author explicitly accepted with eyes open. A ~15-line `scripts/check-db-env.mjs` closes it:

- Reads `packages/database/.env` and `apps/api/.env`.
- If **either** file is absent, exits 0 silently (CI, fresh clones).
- If both exist and their `DATABASE_URL` values differ, prints both and exits non-zero with a message naming the mismatch.
- Skips comments and blank lines; compares the value only.

Wired into `db:migrate` and `db:deploy` — precisely the moments the risk materialises — rather than into a scheduled check nobody runs.

## 9. Zero-migration guarantee

This is a pure text move plus a config file. The set of models, fields, attributes, and indexes is identical, so Prisma's view of the schema is unchanged and **no migration is created**. Consequences:

- `_prisma_migrations` and the `20260918133841_init` row are untouched; no `migrate reset`; no developer loses local data.
- Existing databases are already in sync; `db:deploy` is a no-op.

This is verified, not assumed, using a schema-only diff that needs no database:

```bash
cd packages/database
pnpm exec prisma migrate diff \
  --from-migrations prisma/migrations \
  --to-schema-datamodel prisma/schema \
  --shadow-database-url "$DATABASE_URL" \
  --exit-code
```

Exit 0 with empty output means the migrations and the split schema agree. Any other result means the split changed something and must be reverted.

## 10. CI changes

Three command swaps, no structural change to any job:

| File:line | From | To |
|-----------|------|-----|
| `.github/workflows/ci.yml:35` (`js`) | `pnpm --filter api exec prisma generate` | `pnpm --filter @hifz/database db:generate` |
| `.github/workflows/ci.yml:36` (`js`) | `pnpm --filter api exec prisma migrate deploy` | `pnpm --filter @hifz/database db:deploy` |
| `.github/workflows/ci.yml:81` (`drift`) | `pnpm --filter api exec prisma generate` | `pnpm --filter @hifz/database db:generate` |

The comment above line 80 ("The spec compiles against contracts' built types and the generated Prisma client, neither of which a bare install guarantees") stays accurate and gains a sibling dependency.

`pnpm-lock.yaml` changes as `prisma` / `@prisma/client` move from `apps/api` to `packages/database`. Expected, and the only lockfile churn.

## 11. Documentation updates

Required so the repo does not start lying about itself:

1. **`README.md` — repo tree.** Add a `database/       # Prisma schema + migrations + generated client` line to the `packages/` block, and change the `apps/api` comment from `# NestJS + Prisma — single backend for all clients` to `# NestJS — single backend for all clients`.
2. **`README.md` — getting started.** Add `cp packages/database/.env.example packages/database/.env`; replace `pnpm --filter api exec prisma migrate deploy` with `pnpm --filter @hifz/database db:deploy`.
3. **`README.md` — schema-change guidance.** `pnpm --filter api db:migrate` → `pnpm --filter @hifz/database db:migrate`.
4. **`README.md` — dependency-rules paragraph.** No change needed; the move strengthens it (`packages/*` never import `apps/*` still holds, and now the data layer obeys it too).
5. **`docs/architecture/README.md` — repo-hierarchy mermaid.** `packages/` gains a `database/ — schema + migrations` node. The api node currently reads `src/modules · config · filters<br/>prisma · spec.ts<br/>prisma/ · test/`: keep the bare `prisma` (that is `src/prisma/` — the Nest module, which stays) and drop the `prisma/` (that is the schema and migrations, which move).
6. **`docs/architecture/repo-structure.{excalidraw,svg,png}` + `index.html`** — the same two edits, made in the *generator* rather than the artifact. The generators are committed at `docs/architecture/tools/`, and the tree is plain data in `tools/tree.mjs`, so the `database/` node was added there and the api's `prisma/` entry removed, then everything was regenerated:

   ```bash
   cd docs/architecture/tools
   node tree.mjs    # -> .excalidraw + .svg
   node raster.mjs  # .svg -> .png   (needs @resvg/resvg-js)
   node html.mjs    # re-inline both SVGs into ../index.html
   ```

   Editing the artifacts by hand would have been silently overwritten by the next generator run.
7. **`docs/architecture/hifz-tracker-architecture.*`** — **no change.** Its API box reads "NestJS 11 · Prisma 6", which remains true: the API still uses Prisma 6, just through the package. The system boundary did not move, only the code's. `arch.mjs` was therefore not re-run, leaving those artifacts byte-identical.

## 12. Out of scope

- No repository/DAO abstraction over the client. The package owns the schema, migrations, and client; it does not add a second layer of query wrappers.
- No convergence of the two `.env` files (D7 stands).
- No adoption of the newer ESM `prisma-client` generator; `prisma-client-js` is retained.
- No connection-pooling work (PgBouncer, driver adapters) and no `prisma.config.ts` `datasource` override.
- No squashing of migration history (D6), and no changes to model fields, indexes, or enums.
- No mobile/web/dart changes — they reach the database only through REST.
- No edits to historical records: `.superpowers/sdd/**` and `docs/superpowers/plans/2026-09-18-hifz-walking-skeleton.md` describe what was built at the time and stay as written.
- No fix for the pre-existing `web#typecheck` / `web#build` race surfaced while verifying this change (§14.4). It is real and reproducible, but it belongs to a different subsystem and its repair involves a trade-off the author should choose.

## 13. Verification checklist

Run in order. Steps 1–5 need no database; 6–9 need the compose Postgres up.

1. `pnpm install` — lockfile updates, `packages/database` is linked.
2. `pnpm --filter @hifz/database db:generate` — client generates from the split schema.
3. §9's `prisma migrate diff` — **exit 0, empty output** (the core safety assertion).
4. `pnpm --filter @hifz/database build` — `dist/src/index.js` + `.d.ts` exist.
5. `pnpm --filter @hifz/database typecheck` — clean.
6. `pnpm turbo run lint typecheck test build` — API lint passes, proving the dep move satisfied `import/no-extraneous-dependencies` and that nothing imports `@prisma/client` from `apps/api` any more.
7. `pnpm --filter @hifz/database db:deploy` against a fresh empty database — applies `20260918133841_init`. (Point **both** `.env` files at the fresh database; if you point only the package's, the §8.3 guard will refuse — which is the correct behaviour, not a bug.)
8. `pnpm gen:api-types` — boots the app against a live database, exercising the new `PrismaService` → `@hifz/database` → `@prisma/client` chain end to end.
9. Confirm the drift guard: temporarily point `packages/database/.env` at a different database and confirm `db:migrate` refuses.

## 14. Open questions

1. ~~**Diagram renders.** `repo-structure.svg` / `.png` are generated by scripts that live outside the repo. The `.excalidraw` source and the mermaid can be hand-edited, but the rendered assets cannot be regenerated here. Does the author re-export them from Excalidraw, or accept a temporary stale render?~~ **Resolved during implementation.** The generators turned out to be committed at `docs/architecture/tools/` — this spec's earlier claim that they live outside the repo was wrong, as was an earlier reading of `docs/architecture/README.md`, which had itself been corrected by commit `f69b017` mid-implementation. Because the tree is plain data in `tools/tree.mjs`, all four artifacts were regenerated from the updated data instead of hand-edited. Note `@resvg/resvg-js` is deliberately *not* a declared dependency (the tools README documents adding it ad hoc for PNG rendering); it was installed in a scratch directory, so no dependency was added to the workspace.
2. **Long-term env convergence.** `DATABASE_URL` now has two homes (D7). If "migrate against A, run against B" ever actually bites, revisit a single root `.env` — the guard in §8.3 exists to make that decision data-driven rather than a guess.
3. **Package name.** `@hifz/database` assumed throughout; trivia to change now, churn later.
4. **Pre-existing race in the `web` task graph — found while verifying this change, not caused by it.** `apps/web`'s `typecheck` is `next typegen && tsc --noEmit` and its `build` is `next build`; turbo runs the two concurrently, and `next build` clears `.next/types/**` while `tsc` is reading it, so `web#typecheck` dies with `TS6053: File '.../.next/types/app/(dash)/dashboard/page.ts' not found`. Reproduced 5/5 with `pnpm turbo run typecheck build --filter=web --force`; `web#typecheck` alone passes 2/2, and `apps/web` is untouched by this refactor. Since CI runs `turbo run lint typecheck test build --affected`, this can flake a green build. Two candidate fixes, both with a cost: order `web#typecheck` after `web#build` (every typecheck then pays a full Next build), or point `next typegen` at a directory `next build` does not clear (needs verification against Next 15.5 internals). Left for the author to choose.
