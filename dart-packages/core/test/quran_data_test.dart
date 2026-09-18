import 'package:hifz_core/hifz_core.dart';
import 'package:test/test.dart';

void main() {
  test('114 surahs, sequential', () {
    expect(kSurahs.length, 114);
    expect(kSurahs.first.number, 1);
    expect(kSurahs.last.number, 114);
  });
  test('ayah totals 6236', () {
    expect(kSurahs.fold<int>(0, (n, s) => n + s.ayahCount), 6236);
  });
  test('first surah is Al-Fatihah in Arabic', () {
    expect(kSurahs.first.nameAr, contains('الفاتحة'));
  });
}
