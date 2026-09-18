import 'package:drift/drift.dart';
import 'package:hifz_data/hifz_data.dart';
import 'package:test/test.dart';

import 'fakes.dart';

Future<void> seedOutbox(AppDatabase db, {String key = 'k1'}) async {
  final record = ReviewRecord(
    id: localId(key),
    studentId: 'stu',
    surahNumber: 1,
    ayahFrom: 1,
    ayahTo: 7,
    quality: 'GOOD',
    loggedAt: DateTime.utc(2026, 9, 18, 10),
    pendingSync: true,
  );
  await db.into(db.outboxItems).insert(
        OutboxItemsCompanion.insert(
          idempotencyKey: key,
          payloadJson: record.encode(),
        ),
      );
  await db.into(db.cachedReviews).insertOnConflictUpdate(
        CachedReviewsCompanion.insert(
          id: record.id,
          studentId: record.studentId,
          surahNumber: record.surahNumber,
          ayahFrom: record.ayahFrom,
          ayahTo: record.ayahTo,
          quality: record.quality,
          loggedAt: record.loggedAt,
          pendingSync: const Value(true),
        ),
      );
}

void main() {
  test('flush happy path clears outbox and upserts cache', () async {
    final db = newDb();
    await seedOutbox(db);
    final api = FakeReviewsApi.returning(makeDto());
    final worker = SyncWorker(
      db: db,
      api: () => api,
      connectivity: FakeConnectivity(),
    );

    await worker.flush();

    expect(await db.select(db.outboxItems).get(), isEmpty);
    final cached = await db.select(db.cachedReviews).get();
    expect(cached, hasLength(1));
    expect(cached.single.id, makeDto().id);
    expect(cached.single.pendingSync, isFalse);
    await worker.stop();
    await db.close();
  });

  test('flush network failure keeps row; retry clears it', () async {
    final db = newDb();
    await seedOutbox(db, key: 'k2');
    final api = FakeReviewsApi.throwing(connectionError);
    final worker = SyncWorker(db: db, api: () => api, connectivity: FakeConnectivity());

    await worker.flush();
    expect(await db.select(db.outboxItems).get(), hasLength(1));

    api.handler = FakeReviewsApi.returning(makeDto(id: 'synced-id')).handler;
    await worker.flush();
    expect(await db.select(db.outboxItems).get(), isEmpty);

    await worker.stop();
    await db.close();
  });

  test('flush treats 200 replay as success', () async {
    final db = newDb();
    await seedOutbox(db, key: 'k3');
    final api = FakeReviewsApi.returning(makeDto(), statusCode: 200);
    final worker = SyncWorker(db: db, api: () => api, connectivity: FakeConnectivity());

    await worker.flush();

    expect(await db.select(db.outboxItems).get(), isEmpty);
    await worker.stop();
    await db.close();
  });

  test('flush 4xx dead-letters the item', () async {
    final db = newDb();
    await seedOutbox(db, key: 'k4');
    final api = FakeReviewsApi.throwing(() => badResponse('VALIDATION_ERROR', statusCode: 422));
    final worker = SyncWorker(db: db, api: () => api, connectivity: FakeConnectivity());
    final letters = <SyncDeadLetter>[];
    final subscription = worker.deadLetters.listen(letters.add);

    await worker.flush();
    await Future<void>.delayed(Duration.zero);

    expect(await db.select(db.outboxItems).get(), isEmpty);
    expect(letters, hasLength(1));
    expect(letters.single.failure.code, 'VALIDATION_ERROR');
    await subscription.cancel();
    await worker.stop();
    await db.close();
  });

  test('pendingCount reflects queued items', () async {
    final db = newDb();
    await seedOutbox(db, key: 'k5');
    final worker = SyncWorker(
      db: db,
      api: () => FakeReviewsApi.throwing(connectionError),
      connectivity: FakeConnectivity(),
    );
    expect(await worker.pendingCount(), 1);
    await worker.stop();
    await db.close();
  });
}
