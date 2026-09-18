import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:hifz_api_client/hifz_api_client.dart';
import 'package:hifz_core/hifz_core.dart';
import 'package:uuid/uuid.dart';

import 'client_factory.dart';
import 'database.dart';
import 'failure_mapper.dart';
import 'review_record.dart';

/// Owns the review read cache and the write outbox.
///
/// Online writes go straight through and are cached. Writes that fail for a
/// retryable reason are queued and echoed optimistically with
/// `pendingSync: true`; domain rejections (4xx) are returned as `Err` and are
/// never queued.
class ReviewRepository {
  ReviewRepository({
    required AppDatabase db,
    required ReviewsApiFactory api,
    Uuid uuid = const Uuid(),
  })  : _db = db,
        _api = api,
        _uuid = uuid;

  final AppDatabase _db;
  final ReviewsApiFactory _api;
  final Uuid _uuid;

  Future<Result<ReviewRecord>> logReview(
    CreateReviewRequest request, {
    String? idempotencyKey,
    String? studentId,
  }) async {
    final key = idempotencyKey ?? _uuid.v4();
    try {
      final response = await _api().reviewsControllerCreate(
        body: request,
        headers: {'Idempotency-Key': key},
      );
      final record = _fromDto(response.data!);
      await _cache(record, pendingSync: false);
      return Ok(record);
    } on DioException catch (error) {
      final failure = mapDioException(error);
      if (!failure.isRetryable) return Err(failure);

      final record = ReviewRecord(
        id: localId(key),
        studentId: studentId ?? '',
        surahNumber: request.surahNumber,
        ayahFrom: request.ayahFrom,
        ayahTo: request.ayahTo,
        quality: wireQuality(request.quality),
        loggedAt: request.loggedAt ?? DateTime.now().toUtc(),
        pendingSync: true,
      );
      await _db.into(_db.outboxItems).insert(
            OutboxItemsCompanion.insert(
              idempotencyKey: key,
              payloadJson: record.encode(),
            ),
          );
      await _cache(record, pendingSync: true);
      return Ok(record);
    }
  }

  Future<List<ReviewRecord>> listCached({String? studentId}) async {
    final query = _db.select(_db.cachedReviews)
      ..orderBy([(table) => OrderingTerm.desc(table.loggedAt)]);
    if (studentId != null) {
      query.where((table) => table.studentId.equals(studentId));
    }
    final rows = await query.get();
    return rows.map(_fromRow).toList();
  }

  Future<void> _cache(ReviewRecord record, {required bool pendingSync}) {
    return _db.into(_db.cachedReviews).insertOnConflictUpdate(
          CachedReviewsCompanion.insert(
            id: record.id,
            studentId: record.studentId,
            surahNumber: record.surahNumber,
            ayahFrom: record.ayahFrom,
            ayahTo: record.ayahTo,
            quality: record.quality,
            loggedAt: record.loggedAt,
            pendingSync: Value(pendingSync),
          ),
        );
  }

  ReviewRecord _fromDto(ReviewDto dto) => ReviewRecord(
        id: dto.id,
        studentId: dto.studentId,
        surahNumber: dto.surahNumber,
        ayahFrom: dto.ayahFrom,
        ayahTo: dto.ayahTo,
        quality: wireQuality(dto.quality),
        loggedAt: dto.loggedAt.toUtc(),
      );

  ReviewRecord _fromRow(CachedReview row) => ReviewRecord(
        id: row.id,
        studentId: row.studentId,
        surahNumber: row.surahNumber,
        ayahFrom: row.ayahFrom,
        ayahTo: row.ayahTo,
        quality: row.quality,
        loggedAt: row.loggedAt,
        pendingSync: row.pendingSync,
      );
}

/// Local echo id for a queued write, replaced by the server id once synced.
String localId(String idempotencyKey) => 'local-$idempotencyKey';

/// Wire form of the review quality enum ("GOOD" | "FAIR" | "POOR").
String wireQuality(ReviewQuality quality) {
  final wire = standardSerializers.serializeWith(ReviewQuality.serializer, quality);
  return wire as String;
}

ReviewQuality qualityFromWire(String wire) {
  final value = standardSerializers.deserializeWith(ReviewQuality.serializer, wire);
  return value as ReviewQuality;
}
