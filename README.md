# Hifz Tracker

Hifz Tracker is a Quran memorization (hifz) tracking platform with a student + teacher model: students log recitations and reviews of memorized portions in an Arabic-first Flutter mobile app, teachers assign portions and track their roster from a Next.js dashboard, and a single NestJS API backed by PostgreSQL serves all clients.

## Repository layout

| Path | Contents |
| --- | --- |
| `apps/` | Deployable applications: `api` (NestJS), `web` (Next.js), `mobile` (Flutter) |
| `packages/` | Shared TypeScript packages (contracts/schemas, generated clients) |
| `dart-packages/` | Shared Dart packages for the mobile app (Melos-managed; Melos setup happens in Task 14) |

## Getting started

```bash
docker compose up -d
pnpm install
pnpm dev
```
