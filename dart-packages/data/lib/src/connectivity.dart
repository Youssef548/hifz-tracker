/// Connectivity is injected so `data` stays free of Flutter plugins and can be
/// exercised with plain `dart test`.
abstract class ConnectivityChecker {
  Future<bool> isOnline();

  Stream<bool> get onConnectivityChanged;
}

/// Backoff policy for outbox retries.
abstract class DurationGetter {
  Duration next(int attempts);
}

class ExponentialBackoff implements DurationGetter {
  final Duration base;
  final Duration max;

  const ExponentialBackoff({
    this.base = const Duration(seconds: 30),
    this.max = const Duration(minutes: 15),
  });

  @override
  Duration next(int attempts) {
    final exponential = base.inMilliseconds * (1 << attempts.clamp(0, 30));
    return Duration(
      milliseconds: exponential > max.inMilliseconds ? max.inMilliseconds : exponential,
    );
  }
}
