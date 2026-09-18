import 'package:dio/dio.dart';
import 'package:hifz_api_client/hifz_api_client.dart';

import 'token_storage.dart';

/// Thin wrapper over the generated auth API.
class AuthApiService {
  AuthApiService(this._client);

  final HifzApiClient _client;

  AuthApi get _api => _client.getAuthApi();

  Future<AuthResponseOutput> login(String email, String password) async {
    final response = await _api.authControllerLogin(
      loginRequest: LoginRequest((builder) => builder
        ..email = email
        ..password = password),
    );
    return response.data!;
  }

  Future<AuthUserOutput> me() async => (await _api.authControllerMe()).data!;

  Future<AuthResponseOutput> refresh(String refreshToken) async {
    final response = await _api.authControllerRefresh(
      refreshRequest: RefreshRequest((builder) => builder..refreshToken = refreshToken),
    );
    return response.data!;
  }
}

/// Adds `Authorization` to every request and refreshes once on a 401.
///
/// Concurrent 401s share a single refresh (the lock); a failed refresh gives up
/// and lets the original error through so the caller can sign the user out.
void attachAuthInterceptors(
  Dio dio, {
  required TokenStorage storage,
  required AuthApiService api,
}) {
  final lock = _RefreshLock();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final tokens = await storage.readTokens();
        if (tokens != null) {
          options.headers['Authorization'] = 'Bearer ${tokens.at}';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final tokens = await storage.readTokens();
        if (error.response?.statusCode != 401 || tokens == null) {
          return handler.next(error);
        }
        try {
          final refreshed = await lock.run(() => api.refresh(tokens.rt));
          await storage.saveTokens(at: refreshed.accessToken, rt: refreshed.refreshToken);
          final retried = error.requestOptions
            ..headers['Authorization'] = 'Bearer ${refreshed.accessToken}';
          return handler.resolve(await dio.fetch(retried));
        } catch (_) {
          return handler.next(error);
        }
      },
    ),
  );
}

class _RefreshLock {
  Future<void>? _pending;

  Future<T> run<T>(Future<T> Function() action) async {
    while (_pending != null) {
      await _pending;
    }
    final completer = Future<void>.value();
    _pending = completer;
    try {
      return await action();
    } finally {
      _pending = null;
    }
  }
}
