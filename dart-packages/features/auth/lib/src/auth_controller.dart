import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hifz_api_client/hifz_api_client.dart';

import 'auth_api_service.dart';
import 'token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => SecureTokenStorage());

final authApiServiceProvider = Provider<AuthApiService>((ref) => throw UnimplementedError(
      'authApiServiceProvider must be overridden with a client bound to AppEnv',
    ));

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<AuthUserOutput?>>(AuthController.new);

class AuthController extends Notifier<AsyncValue<AuthUserOutput?>> {
  AuthController({AuthApiService? api, TokenStorage? storage})
      : _api = api,
        _storage = storage;

  final AuthApiService? _api;
  final TokenStorage? _storage;

  AuthApiService get api => _api ?? ref.read(authApiServiceProvider);
  TokenStorage get storage => _storage ?? ref.read(tokenStorageProvider);

  @override
  AsyncValue<AuthUserOutput?> build() => const AsyncValue.data(null);

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final auth = await api.login(email, password);
      await storage.saveTokens(at: auth.accessToken, rt: auth.refreshToken);
      state = AsyncValue.data(auth.user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> logout() async {
    await storage.clear();
    state = const AsyncValue.data(null);
  }

  Future<void> restore() async {
    final tokens = await storage.readTokens();
    if (tokens == null) {
      state = const AsyncValue.data(null);
      return;
    }
    try {
      state = AsyncValue.data(await api.me());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
