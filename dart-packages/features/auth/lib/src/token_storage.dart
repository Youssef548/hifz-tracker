import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the access/refresh token pair in platform secure storage.
abstract class TokenStorage {
  Future<({String at, String rt})?> readTokens();

  Future<void> saveTokens({required String at, required String rt});

  Future<void> clear();
}

class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const _accessKey = 'accessToken';
  static const _refreshKey = 'refreshToken';

  final FlutterSecureStorage _storage;

  @override
  Future<({String at, String rt})?> readTokens() async {
    final at = await _storage.read(key: _accessKey);
    final rt = await _storage.read(key: _refreshKey);
    if (at == null || rt == null) return null;
    return (at: at, rt: rt);
  }

  @override
  Future<void> saveTokens({required String at, required String rt}) async {
    await _storage.write(key: _accessKey, value: at);
    await _storage.write(key: _refreshKey, value: rt);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
