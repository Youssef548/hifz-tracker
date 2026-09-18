import { Resvg } from '@resvg/resvg-js';
import { readFileSync, writeFileSync } from 'node:fs';

import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const OUT_DIR = join(HERE, '..');
const DIR = OUT_DIR;
const targets = [
  ['hifz-tracker-architecture', 2],
  ['repo-structure', 1.6],
];

for (const [name, zoom] of targets) {
  const svg = readFileSync(`${DIR}/${name}.svg`, 'utf8');
  const resvg = new Resvg(svg, {
    fitTo: { mode: 'zoom', value: zoom },
    font: { loadSystemFonts: true, defaultFontFamily: 'Helvetica' },
    background: '#FBF8F2',
  });
  const png = resvg.render().asPng();
  writeFileSync(`${DIR}/${name}.png`, png);
  console.log(`${name}.png  ${(png.length / 1024).toFixed(0)} KB`);
}
