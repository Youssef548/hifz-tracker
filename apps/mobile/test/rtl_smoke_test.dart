import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hifz_api_client/hifz_api_client.dart';
import 'package:hifz_data/hifz_data.dart';
import 'package:hifz_feature_auth/hifz_feature_auth.dart';
import 'package:hifz_feature_hifz_logging/hifz_feature_hifz_logging.dart';
import 'package:hifz_tracker/main.dart';
import 'package:mocktail/mocktail.dart';

class MockReviewRepository extends Mock implements ReviewRepository {}

class MockSyncWorker extends Mock implements SyncWorker {}

class _LoggedInAuthController extends AuthController {
  _LoggedInAuthController();

  @override
  AsyncValue<AuthUserOutput?> build() => AsyncValue.data(
        AuthUserOutput(
          (builder) => builder
            ..id = '9b2f6f38-1e63-4c8a-9c1a-3f8c2c2e6c11'
            ..name = 'طالب'
            ..email = 'student@test.dev'
            ..role = RoleOutput.STUDENT,
        ),
      );
}

void main() {
  testWidgets('the shell boots Arabic-first, RTL, on the log-review screen', (tester) async {
    final repository = MockReviewRepository();
    final worker = MockSyncWorker();
    when(() => worker.pendingCountStream).thenAnswer((_) => const Stream<int>.empty());
    when(() => repository.listCached()).thenAnswer((_) async => <ReviewRecord>[]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(_LoggedInAuthController.new),
          reviewRepositoryProvider.overrideWithValue(repository),
          syncWorkerProvider.overrideWithValue(worker),
        ],
        child: const HifzTrackerApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('تسجيل مراجعة'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(LogReviewScreen))),
      TextDirection.rtl,
    );
  });
}
