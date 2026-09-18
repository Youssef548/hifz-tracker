import { writeFileSync } from 'node:fs';
const res = await fetch('https://api.alquran.cloud/v1/surah');
const { data } = await res.json();
// alquran.cloud returns diacritized names (e.g. "سُورَةُ ٱلْفَاتِحَةِ"); the contracts test
// asserts the undiacritized form ("الفاتحة"), so strip combining marks and normalize
// ALEF WASLA (ٱ, U+0671) to plain ALEF (ا, U+0627).
const normalizeArabic = (s) => s.replace(/\p{M}/gu, '').replace(/\u0671/g, '\u0627');
const surahs = data.map((s) => ({
  number: s.number,
  nameAr: normalizeArabic(s.name),
  nameEn: s.englishName,
  nameTranslit: s.englishNameTranslation,
  ayahCount: s.numberOfAyahs,
}));
writeFileSync(new URL('../quran/surahs.json', import.meta.url), JSON.stringify(surahs, null, 2) + '\n');
console.log(`wrote ${surahs.length} surahs`);
