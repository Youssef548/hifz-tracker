import surahsJson from '../quran/surahs.json';

export interface Surah {
  number: number; nameAr: string; nameEn: string; nameTranslit: string; ayahCount: number;
}
export const surahs: readonly Surah[] = Object.freeze(surahsJson);
export function surahByNumber(n: number): Surah | undefined {
  return surahs.find((s) => s.number === n);
}
