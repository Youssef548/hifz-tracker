import { Canvas, C, writeScene } from './draw.mjs';

import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const OUT_DIR = join(HERE, '..');
const OUT = join(OUT_DIR, 'repo-structure');

// ---------------------------------------------------------------- data
const GREEN = { s: C.green, f: C.greenBg, d: C.greenDeep };
const AMBER = { s: C.amber, f: C.amberBg, d: C.amberDeep };
const INDIGO = { s: C.indigo, f: C.indigoBg, d: C.indigoDeep };
const CLAY = { s: C.clay, f: C.clayBg, d: C.clayDeep };
const SLATE = { s: C.slate, f: C.slateBg, d: C.slateDeep };

const tree = {
  name: 'hifz-tracker/', desc: 'monorepo root · pnpm workspace + Melos', a: CLAY,
  children: [
    {
      name: 'apps/', desc: 'runnable applications', a: CLAY, children: [
        {
          name: 'api/', desc: 'NestJS 11 + Prisma 6 · REST :3001', a: INDIGO, children: [
            { name: 'src/modules/', desc: 'auth · reviews · health' },
            { name: 'src/config/', desc: 'environment validation' },
            { name: 'src/filters/', desc: 'the { error: {...} } envelope' },
            { name: 'src/prisma/', desc: 'PrismaModule + PrismaService' },
            { name: 'src/spec.ts', desc: 'builds the OpenAPI document' },
            { name: 'prisma/', desc: 'schema.prisma + migrations/' },
            { name: 'test/', desc: 'supertest e2e suite' },
          ],
        },
        {
          name: 'web/', desc: 'Next.js 15.5 + React 19 · :3000', a: AMBER, children: [
            { name: 'src/app/(marketing)/', desc: 'public landing page' },
            { name: 'src/app/(dash)/', desc: 'login + dashboard routes' },
            { name: 'src/app/api/auth/', desc: 'route handlers, session cookie' },
            { name: 'src/lib/session.ts', desc: 'server-side session helpers' },
            { name: 'src/middleware.ts', desc: 'route protection' },
            { name: 'src/manifest.ts + sw.ts', desc: 'installable PWA + service worker' },
          ],
        },
        {
          name: 'mobile/', desc: 'Flutter · Arabic-first, RTL', a: GREEN, children: [
            { name: 'lib/main.dart', desc: 'entry point' },
            { name: 'lib/app_router.dart', desc: 'go_router route table' },
            { name: 'lib/src/providers.dart', desc: 'Riverpod DI wiring' },
            { name: 'lib/src/connectivity_adapter.dart', desc: 'connectivity_plus adapter' },
            { name: 'lib/l10n/', desc: 'Arabic (ar) first, RTL' },
          ],
        },
      ],
    },
    {
      name: 'packages/', desc: 'TypeScript · pnpm workspace', a: AMBER, children: [
        { name: 'contracts/', desc: 'zod DTOs + Quran metadata', badge: 'SOURCE OF TRUTH' },
        {
          name: 'api-sdk/', desc: 'openapi-fetch client for the web app', children: [
            { name: 'src/client.ts', desc: 'openapi-fetch + zod runtime guards' },
            { name: 'src/generated/', desc: 'schema.d.ts, from OpenAPI', badge: 'GENERATED' },
            { name: 'src/contract-check.ts', desc: 'fails tsc when the types drift' },
          ],
        },
        { name: 'ui/', desc: 'Tailwind 4 design system + tokens' },
        { name: 'config/', desc: 'shared tsconfig presets' },
        { name: 'eslint-config/', desc: 'import-boundary rules' },
      ],
    },
    {
      name: 'dart-packages/', desc: 'Dart · Melos-managed', a: GREEN, children: [
        { name: 'core/', desc: 'env · Result<T, Failure> · Quran constants' },
        { name: 'api_client/', desc: 'generated from OpenAPI', badge: 'GENERATED' },
        { name: 'data/', desc: 'repositories · drift cache · write outbox' },
        { name: 'features/', desc: 'auth/ · hifz_logging/' },
      ],
    },
    { name: 'scripts/', desc: 'gen-dart.sh · gen-api-types.sh · gen-quran-dart.mjs', a: SLATE, children: [] },
    { name: 'generated/', desc: 'openapi.json, emitted at build time', a: SLATE, children: [] },
    { name: 'docs/', desc: 'architecture/ · superpowers/plans · specs', a: SLATE, children: [] },
    { name: '.github/workflows/', desc: 'ci.yml: js · dart · drift', a: SLATE, children: [] },
    { name: 'turbo.json · melos.yaml', desc: 'task graph for both toolchains', a: SLATE, children: [] },
    { name: 'docker-compose.yml', desc: 'Postgres 16 (+ Redis 7, unused)', a: SLATE, children: [] },
  ],
};

// ---------------------------------------------------------------- layout
const X0 = 70, PITCH = 370, BOX_W = 340, BOX_H = 46, ROW_GAP = 12;
let leaf = 0;

function layout(node, depth, accent) {
  node.depth = depth;
  node.x = X0 + depth * PITCH;
  node.a = node.a || accent;
  const kids = node.children || [];
  if (!kids.length) {
    node.cy = 0;
    node.leafIndex = leaf++;
  } else {
    kids.forEach((k) => layout(k, depth + 1, node.a));
    node.cy = (kids[0].cy + kids[kids.length - 1].cy) / 2;
  }
  return node;
}

const PITCH_Y = BOX_H + ROW_GAP;
const TOP = 205;
// Post-order: leaves claim the next row, every parent re-centres on its children.
const assign = (n) => {
  const kids = n.children || [];
  if (!kids.length) {
    n.cy = TOP + n.leafIndex * PITCH_Y + BOX_H / 2;
  } else {
    kids.forEach(assign);
    n.cy = (kids[0].cy + kids[kids.length - 1].cy) / 2;
  }
};
layout(tree, 0, CLAY);
assign(tree);

function bounds(n, acc = { max: 0 }) {
  acc.max = Math.max(acc.max, n.depth);
  (n.children || []).forEach((c) => bounds(c, acc));
  return acc;
}
const maxDepth = bounds(tree).max;
const leafCount = leaf;
const W = X0 + maxDepth * PITCH + BOX_W + 70;
const H = TOP + leafCount * PITCH_Y + 60;

const cv = new Canvas(W, H);

// ---------------------------------------------------------------- header
cv.label({ x: 70, cy: 68, str: 'Repository hierarchy', size: 34, color: C.ink, weight: 600 });
cv.label({
  x: 72, cy: 112, size: 15, color: C.inkSoft,
  str: 'Every path below exists on disk. Generated trees are marked; nothing here is aspirational.',
});
cv.line({ x1: 70, x2: W - 70, y1: 146, y2: 146, color: C.rule, sw: 2, layer: 'bg' });

const legend = [[CLAY, 'apps'], [AMBER, 'TypeScript packages'], [GREEN, 'Dart packages'], [SLATE, 'tooling & infra']];
let lx = 72;
for (const [a, text] of legend) {
  cv.rect({ x: lx, y: 162, w: 14, h: 14, stroke: a.s, fill: a.f, sw: 1.5, radius: 4, layer: 'box' });
  cv.label({ x: lx + 22, cy: 169, str: text, size: 12, color: C.inkSoft });
  lx += 22 + text.length * 6.6 + 34;
}

// ---------------------------------------------------------------- edges
function edges(n) {
  for (const c of n.children || []) {
    const px = n.x + BOX_W, py = n.cy;
    const mx = px + 22;
    const pts = py === c.cy ? [[px, py], [c.x, c.cy]] : [[px, py], [mx, py], [mx, c.cy], [c.x, c.cy]];
    cv.arrow({ from: pts, color: c.a.s, sw: 1.5, head: null });
    edges(c);
  }
}
edges(tree);

// ---------------------------------------------------------------- nodes
function draw(n) {
  const a = n.a;
  const isContainer = !!n.children?.length;
  cv.rect({
    x: n.x, y: n.cy - BOX_H / 2, w: BOX_W, h: BOX_H,
    stroke: a.s, fill: a.f, sw: isContainer ? 2 : 1.25, radius: 10, layer: 'box',
  });
  cv.label({ x: n.x + 16, cy: n.cy - 9, str: n.name, size: 14, color: a.d, weight: 600 });
  cv.label({ x: n.x + 16, cy: n.cy + 10, str: n.desc, size: 11, color: C.inkSoft });

  if (n.badge) {
    const bw = n.badge.length * 5.6 + 18;
    cv.rect({ x: n.x + BOX_W - bw - 8, y: n.cy - BOX_H / 2 - 9, w: bw, h: 18, stroke: C.red, fill: C.redBg, sw: 1, radius: 9, layer: 'top' });
    cv.labelCentered({ cx: n.x + BOX_W - bw / 2 - 8, cy: n.cy - BOX_H / 2, str: n.badge, size: 9.5, color: C.red, weight: 600, layer: 'top' });
  }
  (n.children || []).forEach(draw);
}
draw(tree);

writeScene(cv, OUT);
console.log(`wrote ${OUT}.excalidraw + .svg  (${W}x${H}, ${leafCount} leaves, depth ${maxDepth})`);
