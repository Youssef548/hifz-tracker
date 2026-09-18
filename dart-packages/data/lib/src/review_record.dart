import 'dart:convert';

/// Data-layer representation of a logged review.
///
/// The generated `hifz_api_client` models are transport types; the cache and
/// the UI need one extra bit (`pendingSync`) that the API does not carry.
class ReviewRecord {
  final String id;
  final String studentId;
  final int surahNumber;
  final int ayahFrom;
  final int ayahTo;
  final String quality;
  final DateTime loggedAt;
  final bool pendingSync;

  const ReviewRecord({
    required this.id,
    required this.studentId,
    required this.surahNumber,
    required this.ayahFrom,
    required this.ayahTo,
    required this.quality,
    required this.loggedAt,
    this.pendingSync = false,
  });

  ReviewRecord copyWith({bool? pendingSync}) => ReviewRecord(
        id: id,
        studentId: studentId,
        surahNumber: surahNumber,
        ayahFrom: ayahFrom,
        ayahTo: ayahTo,
        quality: quality,
        loggedAt: loggedAt,
        pendingSync: pendingSync ?? this.pendingSync,
      );

  Map<String, dynamic> toPayloadJson() => {
        'surahNumber': surahNumber,
        'ayahFrom': ayahFrom,
        'ayahTo': ayahTo,
        'quality': quality,
        'loggedAt': loggedAt.toUtc().toIso8601String(),
      };

  factory ReviewRecord.fromPayloadJson(
    Map<String, dynamic> json, {
    required String id,
    required String studentId,
    bool pendingSync = false,
  }) =>
      ReviewRecord(
        id: id,
        studentId: studentId,
        surahNumber: json['surahNumber'] as int,
        ayahFrom: json['ayahFrom'] as int,
        ayahTo: json['ayahTo'] as int,
        quality: json['quality'] as String,
        loggedAt: DateTime.parse(json['loggedAt'] as String),
        pendingSync: pendingSync,
      );

  String encode() => jsonEncode(toPayloadJson());
}
