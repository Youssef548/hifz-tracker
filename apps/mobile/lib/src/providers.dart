import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hifz_api_client/hifz_api_client.dart';
import 'package:hifz_core/hifz_core.dart';
import 'package:hifz_data/hifz_data.dart';
import 'package:hifz_feature_auth/hifz_feature_auth.dart';
import 'package:hifz_feature_hifz_logging/hifz_feature_hifz_logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'connectivity_adapter.dart';

const _apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  // Android emulators reach the host loopback through 10.0.2.2.
  defaultValue: 'http://10.0.2.2:3001',
);

final appEnvProvider = Provider<AppEnv>((ref) => const AppEnv(apiBaseUrl: _apiBaseUrl));

/// Local drift database (cache + outbox).
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase(
    LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      return NativeDatabase.createInBackground(File(p.join(dir.path, 'hifz.sqlite')));
    }),
  );
  ref.onDispose(database.close);
  return database;
});

/// Auth requests must not run through the refreshing interceptor, otherwise a
/// failed refresh would recurse.
final authApiServiceProviderOverride = Provider<AuthApiService>(
  (ref) => AuthApiService(
    HifzApiClient(dio: Dio(BaseOptions(baseUrl: ref.watch(appEnvProvider).apiV1))),
  ),
);

final authedDioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl: ref.watch(appEnvProvider).apiV1));
  attachAuthInterceptors(
    dio,
    storage: ref.watch(tokenStorageProvider),
    api: ref.watch(authApiServiceProviderOverride),
  );
  return dio;
});

final apiClientProvider = Provider<HifzApiClient>(
  (ref) => HifzApiClient(dio: ref.watch(authedDioProvider)),
);

/// Overrides every provider a feature package expects the shell to supply.
List<Override> appOverrides() => [
      authApiServiceProvider.overrideWith((ref) => ref.watch(authApiServiceProviderOverride)),
      reviewRepositoryProvider.overrideWith(
        (ref) => ReviewRepository(
          db: ref.watch(databaseProvider),
          api: () => ref.watch(apiClientProvider).getReviewsApi(),
        ),
      ),
      syncWorkerProvider.overrideWith(
        (ref) => SyncWorker(
          db: ref.watch(databaseProvider),
          api: () => ref.watch(apiClientProvider).getReviewsApi(),
          connectivity: ConnectivityPlusChecker(),
        ),
      ),
    ];
