import { describe, expect, it } from 'vitest';
import { surahs } from '../src/index';

describe('quran metadata', () => {
  it('has 114 sequentially numbered surahs', () => {
    expect(surahs).toHaveLength(114);
    expect(surahs.map((s) => s.number)).toEqual(Array.from({ length: 114 }, (_, i) => i + 1));
  });
  it('totals 6236 ayahs', () => {
    expect(surahs.reduce((n, s) => n + s.ayahCount, 0)).toBe(6236);
  });
  it('carries Arabic and English names', () => {
    expect(surahs[0].nameAr).toContain('الفاتحة');
    expect(surahs[0].nameEn).toBe('Al-Faatiha');
  });
});
