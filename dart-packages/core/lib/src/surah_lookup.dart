import 'quran_data.g.dart';
import 'surah_info.dart';

SurahInfo? surahByNumber(int number) {
  for (final surah in kSurahs) {
    if (surah.number == number) return surah;
  }
  return null;
}
