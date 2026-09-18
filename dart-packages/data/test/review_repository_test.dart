import 'package:hifz_core/hifz_core.dart';
import 'package:hifz_data/hifz_data.dart';
import 'package:test/test.dart';

import 'fakes.dart';

void main() {
  test('logReview online success caches and leaves outbox empty', () async {
    final db = newDb();
    final api = FakeReviewsApi.returning(makeDto());
    final repo = ReviewRepository(db: db, api: () => api);

    final result = await repo.logReview(request(), idempotencyKey: 'k1', studentId: 'stu');

    expect(result, isA<Ok<ReviewRecord>>());
    expect(await db.select(db.cachedReviews).get(), hasLength(1));
    expect(await db.select(db.outboxItems).get(), isEmpty);
    await db.close();
  });

  test('logReview offline enqueues and echoes pendingSync', () async {
    final db = newDb();
    final api = FakeReviewsApi.throwing(connectionError);
    final repo = ReviewRepository(db: db, api: () => api);

    final result = await repo.logReview(request(), idempotencyKey: 'k2', studentId: 'stu');

    expect(result.when(ok: (record) => record.pendingSync, err: (_) => false), isTrue);
    final outbox = await db.select(db.outboxItems).get();
    expect(outbox, hasLength(1));
    expect(outbox.single.idempotencyKey, 'k2');
    await db.close();
  });

  test('logReview 4xx returns Err without queueing', () async {
    final db = newDb();
    final api = FakeReviewsApi.throwing(() => badResponse('VALIDATION_ERROR'));
    final repo = ReviewRepository(db: db, api: () => api);

    final result = await repo.logReview(request(), idempotencyKey: 'k3');

    expect(result.when(ok: (_) => '', err: (failure) => failure.code), 'VALIDATION_ERROR');
    expect(await db.select(db.outboxItems).get(), isEmpty);
    await db.close();
  });

  test('listCached returns newest first and filters by student', () async {
    final db = newDb();
    final apiA = FakeReviewsApi.returning(makeDto(id: 'r1', studentId: 'a'));
    final apiB = FakeReviewsApi.returning(makeDto(id: 'r2', studentId: 'b'));
    await ReviewRepository(db: db, api: () => apiA)
        .logReview(request(), idempotencyKey: 'k4');
    final repoB = ReviewRepository(db: db, api: () => apiB);
    await repoB.logReview(request(), idempotencyKey: 'k5');

    expect(await repoB.listCached(studentId: 'b'), hasLength(1));
    expect(await repoB.listCached(), hasLength(2));
    await db.close();
  });
}
