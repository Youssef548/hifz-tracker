import { Canvas, C, writeScene } from './draw.mjs';

import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const OUT_DIR = join(HERE, '..');
const OUT = join(OUT_DIR, 'hifz-tracker-architecture');

const W = 2620, H = 1810;
const cv = new Canvas(W, H);

// ---------------------------------------------------------------- header
cv.label({ x: 70, cy: 66, str: 'Hifz Tracker', size: 40, color: C.ink, weight: 600 });
cv.label({
  x: 72, cy: 116, size: 16.5, color: C.inkSoft,
  str: 'Quran memorization tracking on a student + teacher model. One NestJS API serves one Flutter app and one Next.js dashboard.',
});
cv.line({ x1: 70, x2: 2550, y1: 154, y2: 154, color: C.rule, sw: 2, layer: 'bg' });

// ---------------------------------------------------------------- rails
const rail = (cy, str) => cv.label({ x: 70, cy, str, size: 11.5, color: C.inkFaint, weight: 600, letter: 1.4 });
rail(270, 'CLIENTS');
rail(655, 'SHARED PACKAGES');
rail(1215, 'API');
rail(1585, 'DATA');
cv.line({ x1: 190, x2: 190, y1: 190, y2: 1670, color: C.rule, sw: 1.5, layer: 'bg' });

// ---------------------------------------------------------------- clients
cv.box({
  x: 240, y: 195, w: 520, h: 150, stroke: C.green, fill: C.greenBg,
  title: 'apps/mobile', ts: 19, titleColor: C.greenDeep,
  sub: [
    'Flutter · Riverpod · go_router · drift · dio',
    'Arabic-first (ar) with RTL · online-first',
    'thin shell: routing, DI wiring, composition only',
  ],
});
cv.box({
  x: 1420, y: 195, w: 520, h: 150, stroke: C.amber, fill: C.amberBg,
  title: 'apps/web', ts: 19, titleColor: C.amberDeep,
  sub: [
    'Next.js 15.5 · React 19 · Tailwind 4 · Serwist',
    'marketing landing + teacher dashboard',
    'English only · installable PWA',
  ],
});

cv.arrow({ from: [500, 345], to: [500, 401], color: C.green, sw: 2.5 });
cv.arrow({ from: [1680, 345], to: [1680, 401], color: C.amber, sw: 2.5 });

// ---------------------------------------------------------------- dart container
cv.rect({ x: 240, y: 405, w: 520, h: 500, stroke: C.green, fill: '#FFFFFF', sw: 1.5, radius: 14, layer: 'bg' });
cv.label({ x: 268, cy: 430, str: 'dart-packages/', size: 16, color: C.greenDeep, weight: 600 });
cv.label({ x: 268, cy: 452, str: 'Dart · Melos-managed', size: 11.5, color: C.inkFaint });

cv.box({ x: 265, y: 460, w: 470, h: 76, stroke: C.green, fill: C.greenBg, align: 'left', ts: 15,
  title: 'core', titleColor: C.greenDeep, sub: ['env config · Result<T, Failure> · Quran constants'] });
cv.box({ x: 265, y: 548, w: 470, h: 76, stroke: C.slate, fill: C.slateBg, align: 'left', ts: 15, dash: true,
  title: 'api_client', titleColor: C.slateDeep, sub: ['GENERATED from OpenAPI, never hand-edited'] });
cv.box({ x: 265, y: 636, w: 470, h: 76, stroke: C.green, fill: C.greenBg, align: 'left', ts: 15,
  title: 'data', titleColor: C.greenDeep, sub: ['repositories · drift cache · write outbox'] });

cv.rect({ x: 265, y: 724, w: 470, h: 164, stroke: C.green, fill: '#FFFFFF', sw: 1.5, radius: 12, layer: 'bg' });
cv.label({ x: 283, cy: 744, str: 'features/', size: 12, color: C.inkFaint, weight: 600 });
cv.box({ x: 280, y: 764, w: 210, h: 100, stroke: C.green, fill: C.greenBg, ts: 14.5,
  title: 'auth', titleColor: C.greenDeep, sub: ['login flow'] });
cv.box({ x: 505, y: 764, w: 215, h: 100, stroke: C.green, fill: C.greenBg, ts: 14.5,
  title: 'hifz_logging', titleColor: C.greenDeep, sub: ['log + list', 'reviews'] });

// ---------------------------------------------------------------- ts container
cv.rect({ x: 1420, y: 405, w: 520, h: 500, stroke: C.amber, fill: '#FFFFFF', sw: 1.5, radius: 14, layer: 'bg' });
cv.label({ x: 1448, cy: 430, str: 'packages/', size: 16, color: C.amberDeep, weight: 600 });
cv.label({ x: 1448, cy: 452, str: 'TypeScript · pnpm workspace', size: 11.5, color: C.inkFaint });

cv.box({ x: 1445, y: 460, w: 470, h: 76, stroke: C.amber, fill: C.amberBg, align: 'left', ts: 15,
  title: 'contracts', titleColor: C.amberDeep, sub: ['zod DTOs + Quran metadata'], badge: 'SOURCE OF TRUTH' });
cv.box({ x: 1445, y: 548, w: 470, h: 76, stroke: C.amber, fill: C.amberBg, align: 'left', ts: 15,
  title: 'api-sdk', titleColor: C.amberDeep, sub: ['openapi-fetch client + generated types'] });
cv.box({ x: 1445, y: 636, w: 470, h: 76, stroke: C.amber, fill: C.amberBg, align: 'left', ts: 15,
  title: 'ui', titleColor: C.amberDeep, sub: ['Tailwind 4 design system + tokens'] });
cv.box({ x: 1445, y: 724, w: 470, h: 76, stroke: C.amber, fill: C.amberBg, align: 'left', ts: 15,
  title: 'config', titleColor: C.amberDeep, sub: ['shared tsconfig presets'] });
cv.box({ x: 1445, y: 812, w: 470, h: 76, stroke: C.amber, fill: C.amberBg, align: 'left', ts: 15,
  title: 'eslint-config', titleColor: C.amberDeep, sub: ['import-boundary rules'] });

// ---------------------------------------------------------------- bus
cv.arrow({ from: [500, 905], to: [500, 955], color: C.inkFaint, sw: 2 });
cv.arrow({ from: [1680, 905], to: [1680, 955], color: C.inkFaint, sw: 2 });
cv.line({ x1: 500, x2: 1680, y1: 955, y2: 955, color: C.inkFaint, sw: 2, layer: 'mid' });
cv.arrow({ from: [1090, 955], to: [1090, 1005], color: C.inkFaint, sw: 2 });
cv.labelCentered({ cx: 1090, cy: 932, str: 'REST  /api/v1  ·  JWT + Idempotency-Key', size: 12, color: C.inkSoft, weight: 600 });

// ---------------------------------------------------------------- api
cv.rect({ x: 640, y: 1010, w: 900, h: 410, stroke: C.indigo, fill: '#FFFFFF', sw: 2, radius: 14, layer: 'bg' });
cv.label({ x: 672, cy: 1034, str: 'apps/api', size: 20, color: C.indigoDeep, weight: 600 });
cv.label({ x: 672, cy: 1062, str: 'NestJS 11 · Prisma 6 · nestjs-zod (zod 4) · @nestjs/swagger · passport-jwt', size: 12, color: C.inkSoft });

cv.box({ x: 670, y: 1088, w: 280, h: 140, stroke: C.indigo, fill: C.indigoBg, ts: 15, titleColor: C.indigoDeep,
  title: 'AuthModule', sub: ['auth.controller · service', 'token.service · jwt.strategy', 'roles.guard + @Roles'] });
cv.box({ x: 970, y: 1088, w: 280, h: 140, stroke: C.indigo, fill: C.indigoBg, ts: 15, titleColor: C.indigoDeep,
  title: 'ReviewsModule', sub: ['controller · service', 'Idempotency-Key replay', 'writes Review rows'] });
cv.box({ x: 1270, y: 1088, w: 240, h: 140, stroke: C.indigo, fill: C.indigoBg, ts: 15, titleColor: C.indigoDeep,
  title: 'HealthModule', sub: ['GET /api/v1/health'] });

cv.box({ x: 670, y: 1250, w: 200, h: 130, stroke: C.slate, fill: C.slateBg, ts: 14, titleColor: C.slateDeep,
  title: 'config/', sub: ['env validation'] });
cv.box({ x: 890, y: 1250, w: 220, h: 130, stroke: C.slate, fill: C.slateBg, ts: 14, titleColor: C.slateDeep,
  title: 'filters/', sub: ['error envelope'] });
cv.box({ x: 1130, y: 1250, w: 200, h: 130, stroke: C.slate, fill: C.slateBg, ts: 14, titleColor: C.slateDeep,
  title: 'prisma/', sub: ['module + service'] });
cv.box({ x: 1350, y: 1250, w: 160, h: 130, stroke: C.slate, fill: C.slateBg, ts: 14, titleColor: C.slateDeep,
  title: 'spec.ts', sub: ['OpenAPI', 'builder'] });

cv.arrow({ from: [860, 1420], to: [860, 1505], color: C.clay, sw: 2.5 });

// ---------------------------------------------------------------- data
cv.box({ x: 640, y: 1510, w: 430, h: 150, stroke: C.clay, fill: C.clayBg, ts: 17, titleColor: C.clayDeep,
  title: 'PostgreSQL 16', sub: ['docker compose · :5432', 'User · Student · Teacher', 'Review'] });
cv.box({ x: 1110, y: 1510, w: 430, h: 150, stroke: C.slate, fill: C.slateBg, ts: 17, titleColor: C.slateDeep, dash: true,
  title: 'Redis 7', sub: ['in compose, not yet used', 'reserved for BullMQ + notifications'] });

// ---------------------------------------------------------------- legend
const lg = cv.panel({ x: 800, y: 180, w: 580, h: 250, title: 'Legend', accent: C.slate, headerFill: '#F4F5F6' });
const swatches = [
  [C.green, C.greenBg, 'Flutter / Dart', false],
  [C.amber, C.amberBg, 'TypeScript / Next.js', false],
  [C.indigo, C.indigoBg, 'NestJS API', false],
  [C.clay, C.clayBg, 'Data & infrastructure', false],
  [C.slate, C.slateBg, 'Generated, or not yet wired', true],
];
swatches.forEach(([stroke, fill, text, dash], i) => {
  const cy = 245 + i * 33;
  cv.rect({ x: 822, y: cy - 8, w: 16, h: 16, stroke, fill, sw: 1.5, dash, radius: 4, layer: 'box' });
  cv.label({ x: 848, cy, str: text, size: 12.5, color: C.ink });
});
cv.line({ x1: 822, x2: 1358, y1: 412, y2: 412, color: C.rule, sw: 1, layer: 'box' });
cv.arrow({ from: [822, 424], to: [852, 424], color: C.inkSoft, sw: 2 });
cv.label({ x: 862, cy: 424, str: 'runtime call', size: 11.5, color: C.inkSoft });
cv.arrow({ from: [1000, 424], to: [1030, 424], color: C.slate, sw: 2, dash: true });
cv.label({ x: 1040, cy: 424, str: 'codegen or unused', size: 11.5, color: C.inkSoft });

// ---------------------------------------------------------------- contract seam
cv.panel({ x: 800, y: 470, w: 580, h: 435, title: 'The contract seam', accent: C.amberDeep, headerFill: '#FBF0DC' });
cv.para({
  x: 822, top: 515, maxW: 536, lines: [
    { str: 'packages/contracts is the source of truth. Every DTO is a zod schema with inferred TypeScript types; the API validates with them and the web app imports the same schemas for form validation.', size: 12.5 },
    { str: 'OpenAPI is emitted from the controllers and then fanned out to both languages. pnpm gen:dart writes the Dart client; pnpm gen:api-types writes the paths and components types that openapi-fetch consumes in the web SDK.', size: 12.5, spaceBefore: 11 },
    { str: 'Generated types give compile-time safety, the zod schemas stay the runtime guard, and api-sdk/src/contract-check.ts asserts the two still agree so drift fails tsc.', size: 12.5, spaceBefore: 11 },
    { str: 'Apps never import one another. Everything that crosses a boundary is HTTP under /api/v1.', size: 12.5, spaceBefore: 11 },
  ],
});

cv.box({ x: 822, y: 768, w: 150, h: 46, stroke: C.amber, fill: C.amberBg, ts: 12,
  title: 'contracts', titleColor: C.amberDeep, sub: ['zod schemas'] });
cv.arrow({ from: [976, 791], to: [1006, 791], color: C.slate, sw: 2, dash: true });
cv.box({ x: 1010, y: 768, w: 150, h: 46, stroke: C.slate, fill: C.slateBg, ts: 12,
  title: 'OpenAPI', titleColor: C.slateDeep, sub: ['document'] });
cv.arrow({ from: [1164, 791], to: [1194, 791], color: C.slate, sw: 2, dash: true });
cv.box({ x: 1198, y: 768, w: 160, h: 46, stroke: C.slate, fill: C.slateBg, ts: 12,
  title: 'generated types', titleColor: C.slateDeep, sub: ['Dart + TypeScript'] });

cv.para({
  x: 822, top: 838, maxW: 536, lines: [
    { str: 'Generated code is rewritten wholesale, so no hand edit survives. CI regenerates and fails on any diff.', size: 11.5, color: C.inkSoft, italic: true },
  ],
});

// ---------------------------------------------------------------- right rail
cv.panel({ x: 2000, y: 180, w: 560, h: 540, title: 'Code generation', accent: C.slateDeep, headerFill: '#F4F5F6' });

cv.box({ x: 2030, y: 240, w: 500, h: 36, stroke: C.amber, fill: C.amberBg, ts: 12.5, titleColor: C.amberDeep,
  title: 'contracts/quran/surahs.json', sub: [] });
cv.arrow({ from: [2280, 278], to: [2280, 290], color: C.slate, sw: 2, dash: true });
cv.box({ x: 2090, y: 292, w: 380, h: 28, stroke: C.slate, fill: C.slateBg, ts: 12, titleColor: C.slateDeep,
  title: 'pnpm gen:quran', sub: [] });
cv.arrow({ from: [2280, 322], to: [2280, 334], color: C.slate, sw: 2, dash: true });
cv.box({ x: 2030, y: 336, w: 500, h: 36, stroke: C.green, fill: C.greenBg, ts: 12.5, titleColor: C.greenDeep,
  title: 'Dart Surah constants (core)', sub: [] });

cv.divider({ x1: 2030, x2: 2530, y: 400 });

cv.box({ x: 2030, y: 420, w: 500, h: 36, stroke: C.indigo, fill: C.indigoBg, ts: 12.5, titleColor: C.indigoDeep,
  title: 'apps/api controllers + nestjs-zod', sub: [] });
cv.arrow({ from: [2280, 458], to: [2280, 470], color: C.slate, sw: 2, dash: true });
cv.box({ x: 2030, y: 472, w: 500, h: 40, stroke: C.indigo, fill: C.indigoBg, ts: 13, titleColor: C.indigoDeep,
  title: 'generated/openapi.json', sub: [] });

// fan-out to the two generators
cv.line({ x1: 2280, x2: 2280, y1: 512, y2: 526, color: C.slate, sw: 2, dash: true });
cv.line({ x1: 2150, x2: 2410, y1: 526, y2: 526, color: C.slate, sw: 2, dash: true });
cv.arrow({ from: [2150, 526], to: [2150, 540], color: C.slate, sw: 2, dash: true });
cv.arrow({ from: [2410, 526], to: [2410, 540], color: C.slate, sw: 2, dash: true });

cv.box({ x: 2050, y: 542, w: 200, h: 28, stroke: C.slate, fill: C.slateBg, ts: 11.5, titleColor: C.slateDeep,
  title: 'pnpm gen:dart', sub: [] });
cv.box({ x: 2310, y: 542, w: 200, h: 28, stroke: C.slate, fill: C.slateBg, ts: 11.5, titleColor: C.slateDeep,
  title: 'pnpm gen:api-types', sub: [] });

cv.arrow({ from: [2150, 572], to: [2150, 586], color: C.slate, sw: 2, dash: true });
cv.arrow({ from: [2410, 572], to: [2410, 586], color: C.slate, sw: 2, dash: true });

cv.box({ x: 2045, y: 588, w: 210, h: 56, stroke: C.slate, fill: C.slateBg, ts: 13, titleColor: C.slateDeep, dash: true,
  title: 'api_client', sub: ['dart-packages/'] });
cv.box({ x: 2305, y: 588, w: 210, h: 56, stroke: C.slate, fill: C.slateBg, ts: 13, titleColor: C.slateDeep, dash: true,
  title: 'schema.d.ts', sub: ['api-sdk/src/generated'] });

cv.para({
  x: 2030, top: 664, maxW: 500, lines: [
    { str: 'The CI job drift re-runs all three generators and fails on any committed difference.', size: 11.5, color: C.inkSoft, italic: true },
  ],
});

cv.panel({ x: 2000, y: 760, w: 560, h: 280, title: 'Dependency rules', accent: C.red, headerFill: '#FBEAE7' });
const rules = [
  'apps/* never import each other. Cross-app traffic is the API.',
  'packages/* never import from apps/*.',
  'Every package exposes one public entry. Deep imports are forbidden.',
  'ESLint boundaries and the shared tsconfig presets turn a violation into a build error.',
  'turbo (TypeScript) and melos (Dart) order the task graph across both toolchains.',
];
rules.forEach((r, i) => {
  const cy = 808 + i * 46;
  cv.label({ x: 2030, cy, str: '·', size: 12.5, color: C.red, weight: 600 });
  cv.para({ x: 2046, top: cy - 9, maxW: 486, lines: [{ str: r, size: 12.5 }] });
});

cv.panel({ x: 2000, y: 1080, w: 560, h: 380, title: 'Key runtime flows', accent: C.indigoDeep, headerFill: '#E6ECF7' });

const flow = (cy, head) => cv.label({ x: 2030, cy, str: head, size: 13, color: C.indigoDeep, weight: 600 });
const fl = (top, str) => cv.para({ x: 2046, top, maxW: 486, lines: [{ str, size: 12 }] });

flow(1125, 'Auth');
fl(1144, 'POST /auth/login returns an access + refresh JWT pair.');
fl(1162, 'JwtStrategy guards routes; @Roles + RolesGuard enforce the role.');
fl(1180, 'Roles are STUDENT | TEACHER | ADMIN.');

flow(1224, 'Log a review · offline-first');
fl(1243, 'Optimistic write; a client UUID travels as the Idempotency-Key.');
fl(1261, 'A 4xx domain rejection is surfaced to the student and never queued.');
fl(1279, 'A 5xx or network failure goes to the drift outbox and retries with the same key.');

flow(1323, 'Teacher dashboard');
fl(1342, 'Next.js session cookie → api-sdk → GET /api/v1/reviews.');
fl(1360, 'A teacher sees what their students logged from the app.');

cv.line({ x1: 2030, x2: 2530, y1: 1394, y2: 1394, color: C.rule, sw: 1, layer: 'box' });
cv.para({
  x: 2030, top: 1414, maxW: 500, lines: [
    { str: 'Deliberately absent: a full sync engine and conflict resolution. Concurrent edits resolve last-write-wins.', size: 11.5, color: C.inkSoft, italic: true },
  ],
});

cv.panel({ x: 2000, y: 1500, w: 560, h: 250, title: 'CI · .github/workflows/ci.yml', accent: C.greenDeep, headerFill: '#E4F2EE' });
const jobs = [
  ['js', 'Postgres 16 service · turbo run lint typecheck test build'],
  ['dart', 'melos bootstrap · melos run analyze · melos run test'],
  ['drift', 'regenerate every client, then git diff --exit-code'],
];
jobs.forEach(([name, detail], i) => {
  const top = 1548 + i * 58;
  cv.box({ x: 2030, y: top, w: 76, h: 26, stroke: C.green, fill: C.greenBg, ts: 12, titleColor: C.greenDeep, title: name, sub: [] });
  cv.para({ x: 2120, top: top + 4, maxW: 412, lines: [{ str: detail, size: 12 }] });
});

writeScene(cv, OUT);
console.log(`wrote ${OUT}.excalidraw + .svg  (${W}x${H})`);
