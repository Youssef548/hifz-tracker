import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hifz_data/hifz_data.dart';

import 'logging_strings.dart';

/// Wired by the mobile shell, which owns the dio client and the drift database.
final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => throw UnimplementedError('reviewRepositoryProvider must be overridden'),
);

final syncWorkerProvider = Provider<SyncWorker>(
  (ref) => throw UnimplementedError('syncWorkerProvider must be overridden'),
);

final loggingStringsProvider = Provider<LoggingStrings>(
  (ref) => const ArabicLoggingStrings(),
);

/// Number of writes waiting in the outbox, shown as the app-bar badge.
final pendingCountProvider = StreamProvider<int>(
  (ref) => ref.watch(syncWorkerProvider).pendingCountStream,
);
