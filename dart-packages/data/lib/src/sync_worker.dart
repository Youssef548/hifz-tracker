import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:hifz_api_client/hifz_api_client.dart';
import 'package:hifz_core/hifz_core.dart';

import 'client_factory.dart';
import 'connectivity.dart';
import 'database.dart';
import 'failure_mapper.dart';
import 'review_record.dart';
import 'review_repository.dart';

class SyncDeadLetter {
  final OutboxItem item;
  final ApiFailure failure;

  const SyncDeadLetter({required this.item, required this.failure});
}

/// Flushes queued writes when connectivity returns.
///
/// Success and idempotent replays both clear the row and refresh the cache;
/// retryable failures leave the row for a later attempt; 4xx rejections remove
/// the row and surface the item on [deadLetters].
class SyncWorker {
  SyncWorker({
    required AppDatabase db,
    required ReviewsApiFactory api,
    required ConnectivityChecker connectivity,
    DurationGetter backoff = const ExponentialBackoff(),
  })  : _db = db,
        _api = api,
        _connectivity = connectivity,
        _backoff = backoff;

  final AppDatabase _db;
  final ReviewsApiFactory _api;
  final ConnectivityChecker _connectivity;
  final DurationGetter _backoff;

  final _deadLetters = StreamController<SyncDeadLetter>.broadcast();
  final _pendingCounts = StreamController<int>.broadcast();

  StreamSubscription<bool>? _connectivitySubscription;
  Timer? _retryTimer;
  bool _flushing = false;

  Stream<SyncDeadLetter> get deadLetters => _deadLetters.stream;
  Stream<int> get pendingCountStream => _pendingCounts.stream;

  Future<int> pendingCount() async {
    final count = _db.outboxItems.id.count();
    final query = _db.selectOnly(_db.outboxItems)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<void> publishPendingCount() async => _pendingCounts.add(await pendingCount());

  Future<void> start() async {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((online) {
      if (online) unawaited(flush());
    });
    await publishPendingCount();
    if (await _connectivity.isOnline()) {
      await flush();
    }
  }

  Future<void> stop() async {
    _retryTimer?.cancel();
    await _connectivitySubscription?.cancel();
    await _deadLetters.close();
    await _pendingCounts.close();
  }

  Future<void> flush() async {
    if (_flushing) return;
    _flushing = true;
    try {
      final items = await (_db.select(_db.outboxItems)
            ..orderBy([(table) => OrderingTerm.asc(table.id)]))
          .get();

      for (final item in items) {
        final payload = jsonDecode(item.payloadJson) as Map<String, dynamic>;
        final body = CreateReviewRequest(
          (builder) => builder
            ..surahNumber = payload['surahNumber'] as int
            ..ayahFrom = payload['ayahFrom'] as int
            ..ayahTo = payload['ayahTo'] as int
            ..quality = qualityFromWire(payload['quality'] as String)
            ..loggedAt = DateTime.tryParse(payload['loggedAt'] as String? ?? ''),
        );

        try {
          final response = await _api().reviewsControllerCreate(
            body: body,
            headers: {'Idempotency-Key': item.idempotencyKey},
          );
          final dto = response.data!;
          await _replaceLocal(
            localId(item.idempotencyKey),
            ReviewRecord(
              id: dto.id,
              studentId: dto.studentId,
              surahNumber: dto.surahNumber,
              ayahFrom: dto.ayahFrom,
              ayahTo: dto.ayahTo,
              quality: wireQuality(dto.quality),
              loggedAt: dto.loggedAt.toUtc(),
            ),
          );
          await _deleteItem(item);
        } on DioException catch (error) {
          final failure = mapDioException(error);
          if (failure.isRetryable) {
            await _bumpAttempts(item);
            _scheduleRetry(item.attempts + 1);
            return;
          }
          await _deleteItem(item);
          _deadLetters.add(SyncDeadLetter(item: item, failure: failure));
        }
      }
    } finally {
      _flushing = false;
      await publishPendingCount();
    }
  }

  Future<void> _replaceLocal(String localId, ReviewRecord synced) async {
    await (_db.delete(_db.cachedReviews)..where((table) => table.id.equals(localId))).go();
    await _db.into(_db.cachedReviews).insertOnConflictUpdate(
          CachedReviewsCompanion.insert(
            id: synced.id,
            studentId: synced.studentId,
            surahNumber: synced.surahNumber,
            ayahFrom: synced.ayahFrom,
            ayahTo: synced.ayahTo,
            quality: synced.quality,
            loggedAt: synced.loggedAt,
          ),
        );
  }

  Future<void> _deleteItem(OutboxItem item) =>
      (_db.delete(_db.outboxItems)..where((table) => table.id.equals(item.id))).go();

  Future<void> _bumpAttempts(OutboxItem item) =>
      (_db.update(_db.outboxItems)..where((table) => table.id.equals(item.id)))
          .write(OutboxItemsCompanion(attempts: Value(item.attempts + 1)));

  void _scheduleRetry(int attempts) {
    _retryTimer?.cancel();
    _retryTimer = Timer(_backoff.next(attempts), () => unawaited(flush()));
  }
}
