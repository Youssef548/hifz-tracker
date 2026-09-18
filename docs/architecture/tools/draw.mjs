// Shared drawing layer: builds an Excalidraw scene and a matching SVG in lockstep.
import { writeFileSync } from 'node:fs';

const T = Date.now();

export const C = {
  paper: '#FBF8F2',
  ink: '#23272E',
  inkSoft: '#5F6A75',
  inkFaint: '#8A939C',
  panel: '#FFFFFF',
  rule: '#DED7C9',

  green: '#0F6E5C', greenBg: '#E4F2EE', greenDeep: '#0A4F42',
  amber: '#A9660A', amberBg: '#FBF0DC', amberDeep: '#7A4907',
  indigo: '#2F4B7C', indigoBg: '#E6ECF7', indigoDeep: '#20344F',
  clay: '#8A4B2A', clayBg: '#F7E9E0', clayDeep: '#63351D',
  slate: '#55606B', slateBg: '#EEF0F2', slateDeep: '#3C454E',
  red: '#B23A2E', redBg: '#FBEAE7',
};

const SVG_FONT = "'Helvetica Neue', Helvetica, Arial, sans-serif";

let seedN = 1;
const nseed = () => (seedN = (seedN * 1103515245 + 12345) % 2147483648);
let idN = 0;
const rid = () => `el${(++idN).toString(36)}${nseed().toString(36)}`;

// ---------- text metrics ----------
export function textWidth(str, size, weight = 400) {
  let w = 0;
  for (const ch of str) {
    let f;
    if ("iljtfr.,;:!|'`()[]".includes(ch)) f = 0.3;
    else if ('mwMW'.includes(ch)) f = 0.87;
    else if (ch === ' ') f = 0.28;
    else if (ch === '\u2014' || ch === '\u00b7') f = 0.36;
    else if (ch >= 'A' && ch <= 'Z') f = 0.68;
    else if (ch >= '0' && ch <= '9') f = 0.556;
    else f = 0.53;
    w += f * size;
  }
  return w * (weight >= 600 ? 1.06 : 1);
}

export function wrap(str, size, maxW, weight = 400) {
  const words = str.split(' ');
  const out = [];
  let cur = '';
  for (const word of words) {
    const next = cur ? `${cur} ${word}` : word;
    if (textWidth(next, size, weight) > maxW && cur) {
      out.push(cur);
      cur = word;
    } else cur = next;
  }
  if (cur) out.push(cur);
  return out;
}

// ---------- canvas ----------
export class Canvas {
  constructor(width, height, background = C.paper) {
    this.width = width;
    this.height = height;
    this.background = background;
    this._bg = [];   // big panels
    this._mid = [];  // connectors
    this._box = [];  // boxes
    this._text = []; // labels
    this._top = [];  // badges
    this.svg = { bg: [], mid: [], box: [], text: [], top: [], defs: [] };
    this.markers = new Map();
    this.warnings = [];
  }

  warn(msg) {
    this.warnings.push(msg);
  }

  // layer arrays are prefixed to avoid shadowing the shape methods (box, line, ...)
  L(name) {
    return { bg: this._bg, mid: this._mid, box: this._box, text: this._text, top: this._top }[name];
  }

  // --- primitives ---
  rect({ x, y, w, h, stroke = C.rule, fill = C.panel, sw = 1.5, dash = false, radius = 12, layer = 'box' }) {
    const strokeAttr = stroke === 'none' ? 'stroke="none"' : `stroke="${stroke}" stroke-width="${sw}"`;
    const exStroke = stroke === 'none' ? 'transparent' : stroke;
    this.L(layer).push({
      id: rid(), type: 'rectangle', x, y, width: w, height: h, angle: 0,
      strokeColor: exStroke, backgroundColor: fill, fillStyle: 'solid',
      strokeWidth: sw, strokeStyle: dash ? 'dashed' : 'solid', roughness: 0,
      opacity: 100, groupIds: [], frameId: null,
      roundness: radius ? { type: 3 } : null,
      seed: nseed(), version: 1, versionNonce: nseed(), isDeleted: false,
      boundElements: [], updated: T, link: null, locked: false,
    });
    this.svg[layer].push(
      `<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="${radius}" fill="${fill}" ${strokeAttr}` +
      `${dash ? ' stroke-dasharray="7 5"' : ''} />`
    );
  }

  line({ x1, y1, x2, y2, color = C.rule, sw = 1.5, dash = false, layer = 'mid' }) {
    this.L(layer).push({
      id: rid(), type: 'line', x: x1, y: y1, width: Math.abs(x2 - x1), height: Math.abs(y2 - y1),
      angle: 0, strokeColor: color, backgroundColor: 'transparent', fillStyle: 'solid',
      strokeWidth: sw, strokeStyle: dash ? 'dashed' : 'solid', roughness: 0, opacity: 100,
      groupIds: [], frameId: null, roundness: null, seed: nseed(), version: 1,
      versionNonce: nseed(), isDeleted: false, boundElements: [], updated: T, link: null, locked: false,
      points: [[0, 0], [x2 - x1, y2 - y1]], lastCommittedPoint: null,
      startBinding: null, endBinding: null, startArrowhead: null, endArrowhead: null,
    });
    this.svg[layer].push(
      `<line x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}" stroke="${color}" stroke-width="${sw}"` +
      `${dash ? ' stroke-dasharray="7 5"' : ''} stroke-linecap="round" />`
    );
  }

  arrow({ from, to, color = C.inkSoft, sw = 2, dash = false, head = 'arrow', layer = 'mid' }) {
    const pts = Array.isArray(from[0]) ? from : [from, to];
    const [x1, y1] = pts[0];
    const xs = pts.map((p) => p[0]);
    const ys = pts.map((p) => p[1]);
    const minX = Math.min(...xs), minY = Math.min(...ys);
    const rel = pts.map((p) => [p[0] - minX, p[1] - minY]);
    const m = head ? ` marker-end="url(#ah-${this.marker(color)})"` : '';

    this.L(layer).push({
      id: rid(), type: 'arrow', x: minX, y: minY,
      width: Math.max(...xs) - minX, height: Math.max(...ys) - minY, angle: 0,
      strokeColor: color, backgroundColor: 'transparent', fillStyle: 'solid',
      strokeWidth: sw, strokeStyle: dash ? 'dashed' : 'solid', roughness: 0, opacity: 100,
      groupIds: [], frameId: null, roundness: { type: 2 }, seed: nseed(), version: 1,
      versionNonce: nseed(), isDeleted: false, boundElements: [], updated: T, link: null, locked: false,
      points: rel, lastCommittedPoint: null, startBinding: null, endBinding: null,
      startArrowhead: null, endArrowhead: head,
    });
    this.svg[layer].push(
      `<path d="${pts.map((p, i) => `${i ? 'L' : 'M'} ${p[0]} ${p[1]}`).join(' ')}" fill="none" ` +
      `stroke="${color}" stroke-width="${sw}" stroke-linecap="round" stroke-linejoin="round"` +
      `${dash ? ' stroke-dasharray="7 5"' : ''}${m} />`
    );
  }

  marker(color) {
    if (!this.markers.has(color)) {
      const key = this.markers.size;
      this.markers.set(color, key);
      this.svg.defs.push(
        `<marker id="ah-${key}" viewBox="0 0 10 10" refX="8.5" refY="5" markerWidth="5.5" ` +
        `markerHeight="5.5" orient="auto" markerUnits="strokeWidth">` +
        `<path d="M 0 1.2 L 9 5 L 0 8.8 z" fill="${color}" /></marker>`
      );
    }
    return this.markers.get(color);
  }

  // text is anchored at a left edge; cy is the optical vertical centre
  label({ x, cy, str, size = 13, color = C.ink, weight = 400, italic = false, layer = 'text', letter = 0 }) {
    if (!str) return;
    const est = textWidth(str, size, weight);
    this.L(layer).push({
      id: rid(), type: 'text', x, y: cy - size * 0.62, width: est, height: size * 1.25, angle: 0,
      strokeColor: color, backgroundColor: 'transparent', fillStyle: 'solid',
      strokeWidth: 1, strokeStyle: 'solid', roughness: 0, opacity: 100,
      groupIds: [], frameId: null, roundness: null, seed: nseed(), version: 1,
      versionNonce: nseed(), isDeleted: false, boundElements: [], updated: T, link: null, locked: false,
      text: str, fontSize: size, fontFamily: 2, textAlign: 'left', verticalAlign: 'top',
      containerId: null, originalText: str, lineHeight: 1.25, baseline: Math.round(size * 0.9),
    });
    this.svg[layer].push(
      `<text x="${x}" y="${cy + size * 0.35}" font-family="${SVG_FONT}" font-size="${size}" ` +
      `font-weight="${weight}" fill="${color}"${italic ? ' font-style="italic"' : ''}` +
      `${letter ? ` letter-spacing="${letter}"` : ''}>${esc(str)}</text>`
    );
  }

  labelCentered({ cx, cy, str, ...rest }) {
    this.label({ x: cx - textWidth(str, rest.size ?? 13, rest.weight ?? 400) / 2, cy, str, ...rest });
  }

  // stacked text block; `top` is the top edge, returns the bottom edge
  para({ x, cx = null, top, lines, maxW = null, layer = 'text' }) {
    let y = top;
    for (const ln of lines) {
      const size = ln.size ?? 12.5;
      const weight = ln.weight ?? 400;
      const gap = size * (ln.gap ?? 1.45);
      const texts = maxW ? wrap(ln.str, size, maxW, weight) : [ln.str];
      if (ln.spaceBefore) y += ln.spaceBefore;
      for (const t of texts) {
        const cy = y + size * 0.72;
        const anchorX = cx != null ? cx - textWidth(t, size, weight) / 2 : x + (ln.indent ?? 0);
        this.label({ x: anchorX, cy, str: t, size, color: ln.color ?? C.ink, weight, italic: ln.italic, layer });
        y += gap;
      }
    }
    return y;
  }

  // ---------- composite ----------
  box({ x, y, w, h, title, sub = [], stroke, fill, dash = false, radius = 12, ts = 15, ss = 11.5,
        titleColor = C.ink, subColor = C.inkSoft, align = 'center', layer = 'box', badge = null }) {
    this.rect({ x, y, w, h, stroke, fill, dash, radius, layer });
    const inner = [];
    if (title) inner.push({ str: title, size: ts, color: titleColor, weight: 600 });
    for (const s of sub) inner.push({ str: s, size: ss, color: subColor });
    const gap = 1.3;
    const pad = 16;
    const avail = w - pad * 2;
    let total = 0;
    inner.forEach((l) => { total += l.size * gap; });
    inner.forEach((l) => {
      const tw = textWidth(l.str, l.size, l.weight);
      if (tw > avail) this.warn(`"${title}": text ${tw.toFixed(0)}px overflows ${avail}px -> "${l.str}"`);
    });
    if (total > h - 10) this.warn(`"${title}": text block ${total.toFixed(0)}px overflows ${h - 10}px box height`);
    let cy = y + h / 2 - total / 2;
    for (const l of inner) {
      cy += l.size * gap / 2;
      if (align === 'center') this.labelCentered({ cx: x + w / 2, cy, str: l.str, size: l.size, color: l.color, weight: l.weight });
      else this.label({ x: x + 16, cy, str: l.str, size: l.size, color: l.color, weight: l.weight });
      cy += l.size * gap / 2;
    }
    if (badge) {
      const bw = textWidth(badge, 10, 600) + 20;
      this.rect({ x: x + w - bw - 10, y: y + 9, w: bw, h: 20, stroke: C.red, fill: C.redBg, radius: 10, sw: 1, layer: 'top' });
      this.labelCentered({ cx: x + w - bw / 2 - 10, cy: y + 19, str: badge, size: 10, color: C.red, weight: 600, layer: 'top' });
    }
  }

  panel({ x, y, w, h, title, accent = C.slate, fill = C.panel, headerFill = null }) {
    this.rect({ x, y, w, h, stroke: C.rule, fill, sw: 1.5, radius: 14, layer: 'bg' });
    if (headerFill) {
      this.rect({ x, y, w, h: 40, stroke: 'none', fill: headerFill, sw: 0, radius: 14, layer: 'bg' });
      this.rect({ x, y: y + 30, w, h: 10, stroke: 'none', fill, sw: 0, radius: 0, layer: 'bg' });
    }
    this.label({ x: x + 18, cy: y + 20, str: title.toUpperCase(), size: 11.5, color: accent, weight: 600, letter: 1.1 });
    return { x, y, w, h, cx: x + w / 2, body: y + 40 };
  }

  divider({ x1, x2, y, color = C.rule }) {
    this.line({ x1, x2, y1: y, y2: y, color, sw: 1, layer: 'box' });
  }

  // ---------- output ----------
  excalidraw() {
    const elements = [...this._bg, ...this._mid, ...this._box, ...this._text, ...this._top];
    return JSON.stringify({
      type: 'excalidraw', version: 2, source: 'https://excalidraw.com',
      elements,
      appState: { gridSize: null, viewBackgroundColor: this.background },
      files: {},
    }, null, 2);
  }

  svgString() {
    const body = [...this.svg.bg, ...this.svg.mid, ...this.svg.box, ...this.svg.text, ...this.svg.top].join('\n');
    return `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="${this.width}" height="${this.height}" viewBox="0 0 ${this.width} ${this.height}">
  <defs>
${this.svg.defs.join('\n')}
  </defs>
  <rect width="${this.width}" height="${this.height}" fill="${this.background}" />
${body}
</svg>
`;
  }
}

export function esc(s) {
  return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

export function writeScene(canvas, basePath) {
  writeFileSync(`${basePath}.excalidraw`, canvas.excalidraw());
  writeFileSync(`${basePath}.svg`, canvas.svgString());
  if (canvas.warnings.length) {
    console.log(`\n  ${canvas.warnings.length} overflow warning(s):`);
    canvas.warnings.forEach((w) => console.log(`   - ${w}`));
  } else {
    console.log('  no text overflow detected');
  }
}
