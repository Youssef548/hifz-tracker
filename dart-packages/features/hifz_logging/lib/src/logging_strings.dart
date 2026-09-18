/// Feature-local strings.
///
/// The app-level l10n pipeline (arb + gen-l10n) lives in `apps/mobile`; a
/// feature package cannot depend on the app's generated `AppLocalizations`, so
/// the screen takes its strings from an injectable object instead. Arabic is
/// the default, matching the Arabic-first product decision.
abstract class LoggingStrings {
  const LoggingStrings();

  String get title;
  String get surah;
  String get ayahFrom;
  String get ayahTo;
  String get quality;
  String get qualityGood;
  String get qualityFair;
  String get qualityPoor;
  String get submit;
  String get pendingSync;
  String get rangeError;
  String get recentReviews;
  String get emptyRecent;
}

class ArabicLoggingStrings extends LoggingStrings {
  const ArabicLoggingStrings();

  @override
  String get title => 'تسجيل مراجعة';
  @override
  String get surah => 'السورة';
  @override
  String get ayahFrom => 'من الآية';
  @override
  String get ayahTo => 'إلى الآية';
  @override
  String get quality => 'التقييم';
  @override
  String get qualityGood => 'جيد';
  @override
  String get qualityFair => 'مقبول';
  @override
  String get qualityPoor => 'ضعيف';
  @override
  String get submit => 'سجّل';
  @override
  String get pendingSync => 'بانتظار المزامنة';
  @override
  String get rangeError => 'الآية الأخيرة يجب أن تكون بعد الأولى';
  @override
  String get recentReviews => 'المراجعات الأخيرة';
  @override
  String get emptyRecent => 'لا توجد مراجعات بعد';
}

class EnglishLoggingStrings extends LoggingStrings {
  const EnglishLoggingStrings();

  @override
  String get title => 'Log review';
  @override
  String get surah => 'Surah';
  @override
  String get ayahFrom => 'From ayah';
  @override
  String get ayahTo => 'To ayah';
  @override
  String get quality => 'Quality';
  @override
  String get qualityGood => 'Good';
  @override
  String get qualityFair => 'Fair';
  @override
  String get qualityPoor => 'Poor';
  @override
  String get submit => 'Log';
  @override
  String get pendingSync => 'Pending sync';
  @override
  String get rangeError => 'The last ayah must come after the first';
  @override
  String get recentReviews => 'Recent reviews';
  @override
  String get emptyRecent => 'No reviews yet';
}
