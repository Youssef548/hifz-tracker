import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hifz_data/hifz_data.dart';

/// connectivity_plus is a Flutter plugin, so its adapter lives in the app
/// rather than in `data` (which stays plugin-free and dart-testable).
class ConnectivityPlusChecker implements ConnectivityChecker {
  ConnectivityPlusChecker([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<bool> isOnline() async => _hasConnection(await _connectivity.checkConnectivity());

  @override
  Stream<bool> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map(_hasConnection);

  bool _hasConnection(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);
}
