import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hifz_api_client/hifz_api_client.dart';
import 'package:hifz_core/hifz_core.dart';
import 'package:hifz_data/hifz_data.dart';
import 'package:hifz_feature_hifz_logging/hifz_feature_hifz_logging.dart';
import 'package:mocktail/mocktail.dart';

class MockReviewRepository extends Mock implements ReviewRepository {}

class MockSyncWorker extends Mock implements SyncWorker {}

ReviewRecord pendingRecord() => ReviewRecord(
      id: 'local-k1',
      studentId: 'stu',
      surahNumber: 1,
      ayahFrom: 1,
      ayahTo: 7,
      quality: 'GOOD',
      loggedAt: DateTime.utc(2026, 9, 18, 10),
      pendingSync: true,
    );

void main() {
  late MockReviewRepository repository;
  late MockSyncWorker worker;
  late StreamController<int> pendingCounts;

  setUpAll(() {
    registerFallbackValue(
      CreateReviewRequest(
        (builder) => builder
          ..surahNumber = 1
          ..ayahFrom = 1
          ..ayahTo = 1
          ..quality = ReviewQuality.GOOD,
      ),
    );
  });

  setUp(() {
    repository = MockReviewRepository();
    worker = MockSyncWorker();
    pendingCounts = StreamController<int>.broadcast();
    when(() => worker.pendingCountStream).thenAnswer((_) => pendingCounts.stream);
    when(() => repository.listCached()).thenAnswer((_) async => <ReviewRecord>[]);
  });

  Widget harness() => ProviderScope(
        overrides: [
          reviewRepositoryProvider.overrideWithValue(repository),
          syncWorkerProvider.overrideWithValue(worker),
        ],
        child: const MaterialApp(
          locale: Locale('ar'),
          supportedLocales: [Locale('ar')],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: LogReviewScreen(),
        ),
      );

  Future<void> pumpHarness(WidgetTester tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();
    await tester.pump();
  }

  testWidgets('renders Arabic labels and lays the form out RTL', (tester) async {
    await pumpHarness(tester);

    expect(find.text('تسجيل مراجعة'), findsOneWidget);
    expect(find.text('السورة'), findsOneWidget);
    expect(find.text('التقييم'), findsOneWidget);
    expect(find.text('جيد'), findsOneWidget);
    expect(find.text('مقبول'), findsOneWidget);
    expect(find.text('ضعيف'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(LogReviewScreen))),
      TextDirection.rtl,
    );
  });

  testWidgets('offline submit shows a pending entry and outbox badge', (tester) async {
    when(
      () => repository.logReview(any(), studentId: any(named: 'studentId')),
    ).thenAnswer((_) async => Ok(pendingRecord()));

    await pumpHarness(tester);
    pendingCounts.add(1);
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byKey(const Key('submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('بانتظار المزامنة'), findsOneWidget);
    expect(find.byKey(const Key('outbox-badge')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('outbox-badge')),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('invalid range shows the Arabic error and never calls the repository',
      (tester) async {
    await pumpHarness(tester);

    await tester.enterText(find.byKey(const Key('ayah-from-field')), '10');
    await tester.enterText(find.byKey(const Key('ayah-to-field')), '5');
    await tester.tap(find.byKey(const Key('submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('الآية الأخيرة يجب أن تكون بعد الأولى'), findsWidgets);
    verifyNever(
      () => repository.logReview(any(), studentId: any(named: 'studentId')),
    );
  });

  testWidgets('badge disappears once the outbox drains', (tester) async {
    await pumpHarness(tester);
    pendingCounts.add(1);
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('outbox-badge')), findsOneWidget);

    pendingCounts.add(0);
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('outbox-badge')), findsNothing);
  });
}
