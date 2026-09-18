import { readFileSync, writeFileSync } from 'node:fs';

const surahs = JSON.parse(
  readFileSync(new URL('../packages/contracts/quran/surahs.json', import.meta.url), 'utf8'),
);

const entries = surahs
  .map(
    (s) =>
      `  SurahInfo(number: ${s.number}, nameAr: ${JSON.stringify(s.nameAr)}, nameEn: ${JSON.stringify(s.nameEn)}, nameTranslit: ${JSON.stringify(s.nameTranslit)}, ayahCount: ${s.ayahCount}),`,
  )
  .join('\n');

const out = `// GENERATED from packages/contracts/quran/surahs.json — do not edit.
import 'surah_info.dart';

const kSurahs = <SurahInfo>[
${entries}
];
`;

writeFileSync(new URL('../dart-packages/core/lib/src/quran_data.g.dart', import.meta.url), out);
console.log(`generated ${surahs.length} surahs`);
