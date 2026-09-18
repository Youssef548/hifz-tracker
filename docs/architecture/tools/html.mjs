import { readFileSync, writeFileSync } from 'node:fs';

import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const OUT_DIR = join(HERE, '..');
const DIR = OUT_DIR;

const strip = (s) => s.replace(/<\?xml[^?]*\?>\s*/, '').replace(/<svg /, '<svg class="diagram" ');

const arch = strip(readFileSync(`${DIR}/hifz-tracker-architecture.svg`, 'utf8'));
const tree = strip(readFileSync(`${DIR}/repo-structure.svg`, 'utf8'));

const html = `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>Hifz Tracker — architecture and repository map</title>
<style>
  :root {
    color-scheme: light;
    --paper: #FBF8F2;
    --card: #FFFFFF;
    --ink: #23272E;
    --ink-soft: #5F6A75;
    --ink-faint: #8A939C;
    --rule: #DED7C9;
    --green: #0F6E5C;
    --amber: #A9660A;
    --indigo: #2F4B7C;
  }
  * { box-sizing: border-box; }
  body {
    margin: 0;
    background: var(--paper);
    color: var(--ink);
    font: 16px/1.6 ui-sans-serif, -apple-system, "Segoe UI", Helvetica, Arial, sans-serif;
    -webkit-font-smoothing: antialiased;
  }
  .wrap { max-width: 1400px; margin: 0 auto; padding: 56px 32px 96px; }
  header { border-bottom: 2px solid var(--rule); padding-bottom: 28px; margin-bottom: 40px; }
  .eyebrow {
    font-size: 12px; font-weight: 600; letter-spacing: .14em; text-transform: uppercase;
    color: var(--green); margin: 0 0 14px;
  }
  h1 { font-size: clamp(30px, 4vw, 46px); line-height: 1.1; letter-spacing: -.02em; margin: 0 0 14px; }
  .lede { font-size: 18px; color: var(--ink-soft); max-width: 68ch; margin: 0; }
  section { margin-top: 64px; }
  h2 { font-size: 13px; font-weight: 600; letter-spacing: .12em; text-transform: uppercase; color: var(--ink-faint); margin: 0 0 6px; }
  h3 { font-size: 26px; letter-spacing: -.01em; margin: 0 0 8px; }
  section > p { color: var(--ink-soft); max-width: 76ch; margin: 0 0 22px; }
  .frame {
    background: var(--card); border: 1px solid var(--rule); border-radius: 14px;
    padding: 14px; overflow: auto; box-shadow: 0 1px 2px rgba(35,39,46,.04);
  }
  .diagram { display: block; width: 100%; height: auto; border-radius: 8px; }
  .files { display: flex; flex-wrap: wrap; gap: 8px; margin: 16px 0 0; padding: 0; list-style: none; }
  .files a {
    display: inline-block; padding: 7px 13px; border: 1px solid var(--rule); border-radius: 999px;
    background: var(--card); color: var(--ink-soft); text-decoration: none;
    font-size: 13px; font-variant-numeric: tabular-nums;
  }
  .files a:hover { border-color: var(--green); color: var(--green); }
  .files a:focus-visible { outline: 2px solid var(--green); outline-offset: 2px; }
  .keys { display: grid; grid-template-columns: repeat(auto-fit, minmax(230px, 1fr)); gap: 20px; margin: 0; }
  .keys div { border-left: 3px solid var(--rule); padding-left: 14px; }
  .keys dt { font-size: 13px; font-weight: 600; margin-bottom: 3px; }
  .keys dd { margin: 0; font-size: 14px; color: var(--ink-soft); }
  code {
    font: 13px/1.5 ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
    background: #F1EDE4; padding: 2px 6px; border-radius: 5px;
  }
  footer { margin-top: 72px; padding-top: 22px; border-top: 1px solid var(--rule); color: var(--ink-faint); font-size: 13px; }
</style>
</head>
<body>
<div class="wrap">
  <header>
    <p class="eyebrow">Hifz Tracker</p>
    <h1>Architecture and repository map</h1>
    <p class="lede">
      A Quran memorization platform built on a student and teacher model. One NestJS API serves a
      Flutter app that students use in Arabic and a Next.js dashboard that teachers use in English.
      Every box and path below is taken from the repository as it exists on disk.
    </p>
  </header>

  <section>
    <h2>Diagram 1</h2>
    <h3>System architecture</h3>
    <p>
      Clients sit at the top, the code they share sits beneath them, and everything converges on a
      single API over REST. The right rail covers code generation, the dependency rules that are
      enforced as build errors, the three runtime flows that matter, and CI.
    </p>
    <div class="frame">${arch}</div>
    <ul class="files">
      <li><a href="hifz-tracker-architecture.excalidraw">.excalidraw</a></li>
      <li><a href="hifz-tracker-architecture.svg">.svg</a></li>
      <li><a href="hifz-tracker-architecture.png">.png</a></li>
    </ul>
  </section>

  <section>
    <h2>Diagram 2</h2>
    <h3>Repository hierarchy</h3>
    <p>
      The monorepo laid out as a tree, coloured by branch: clay for the three apps, amber for the
      TypeScript packages, green for the Dart packages, grey for tooling. Generated trees are
      marked so nobody hand-edits them.
    </p>
    <div class="frame">${tree}</div>
    <ul class="files">
      <li><a href="repo-structure.excalidraw">.excalidraw</a></li>
      <li><a href="repo-structure.svg">.svg</a></li>
      <li><a href="repo-structure.png">.png</a></li>
    </ul>
  </section>

  <section>
    <h2>Reading the diagrams</h2>
    <h3>What the colours and lines mean</h3>
    <dl class="keys">
      <div><dt>Green</dt><dd>Flutter app and the Dart packages it composes.</dd></div>
      <div><dt>Amber</dt><dd>Next.js app and the TypeScript packages. Contracts is the source of truth.</dd></div>
      <div><dt>Indigo</dt><dd>The NestJS API and its modules.</dd></div>
      <div><dt>Clay</dt><dd>Postgres and other infrastructure.</dd></div>
      <div><dt>Dashed outline</dt><dd>Generated code, or something not yet wired up.</dd></div>
      <div><dt>Solid arrow</dt><dd>A runtime call. Dashed means codegen or an unused path.</dd></div>
    </dl>
  </section>

  <footer>
    Editable sources are the two <code>.excalidraw</code> files, which open at
    <a href="https://excalidraw.com">excalidraw.com</a>. Both are emitted by the generators in
    <code>tools/</code>; see <a href="README.md">README.md</a> to rebuild them.
  </footer>
</div>
</body>
</html>
`;

writeFileSync(`${DIR}/index.html`, html);
console.log(`index.html  ${(html.length / 1024).toFixed(0)} KB (both SVGs inlined, no network needed)`);
