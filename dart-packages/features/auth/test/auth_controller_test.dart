import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hifz_api_client/hifz_api_client.dart';
import 'package:hifz_core/hifz_core.dart';
import 'package:hifz_feature_auth/hifz_feature_auth.dart';
import 'package:mocktail/mocktail.dart';

class MockTokenStorage extends Mock implements TokenStorage {}

class MockAuthApiService extends Mock implements AuthApiService {}

AuthUserOutput authUser({String id = 'u1'}) => AuthUserOutput(
      (builder) => builder
        ..id = id
        ..name = 'A'
        ..email = 'a@b.com'
        ..role = RoleOutput.STUDENT,
    );

AuthResponseOutput authResponse({
  String accessToken = 'at',
  String refreshToken = 'rt',
}) =>
    AuthResponseOutput(
      (builder) => builder
        ..user.replace(authUser())
        ..accessToken = accessToken
        ..refreshToken = refreshToken,
    );

class SequencedAdapter implements HttpClientAdapter {
  SequencedAdapter(this.responses);

  final List<ResponseBody> responses;
  int _index = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      responses[_index++];

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonResponse(Object body, int statusCode) => ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

void main() {
  late MockTokenStorage storage;
  late MockAuthApiService api;

  setUp(() {
    storage = MockTokenStorage();
    api = MockAuthApiService();
  });

  ProviderContainer container() => ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(storage),
          authApiServiceProvider.overrideWithValue(api),
        ],
      );

  test('login success stores tokens and sets user state', () async {
    when(() => api.login('a@b.com', 'pw')).thenAnswer((_) async => authResponse());
    when(() => storage.saveTokens(at: any(named: 'at'), rt: any(named: 'rt')))
        .thenAnswer((_) async {});

    final providerContainer = container();
    addTearDown(providerContainer.dispose);
    final controller = providerContainer.read(authControllerProvider.notifier);

    await controller.login('a@b.com', 'pw');

    verify(() => storage.saveTokens(at: 'at', rt: 'rt')).called(1);
    expect(providerContainer.read(authControllerProvider).value?.email, 'a@b.com');
  });

  test('login failure leaves state in error and storage untouched', () async {
    when(() => api.login('a@b.com', 'wrong')).thenThrow(
      const ApiFailure(code: 'INVALID_CREDENTIALS', message: 'x'),
    );

    final providerContainer = container();
    addTearDown(providerContainer.dispose);
    final controller = providerContainer.read(authControllerProvider.notifier);

    await controller.login('a@b.com', 'wrong');

    expect(providerContainer.read(authControllerProvider).hasError, isTrue);
    verifyNever(() => storage.saveTokens(at: any(named: 'at'), rt: any(named: 'rt')));
  });

  test('restore session reads tokens and calls me', () async {
    when(() => storage.readTokens()).thenAnswer((_) async => (at: 'at', rt: 'rt'));
    when(() => api.me()).thenAnswer((_) async => authUser());

    final providerContainer = container();
    addTearDown(providerContainer.dispose);
    final controller = providerContainer.read(authControllerProvider.notifier);

    await controller.restore();

    expect(providerContainer.read(authControllerProvider).value?.id, 'u1');
  });

  test('interceptor refreshes once on 401 and retries', () async {
    when(() => storage.readTokens()).thenAnswer((_) async => (at: 'at', rt: 'rt'));
    when(() => api.refresh('rt')).thenAnswer(
      (_) async => authResponse(accessToken: 'at2', refreshToken: 'rt2'),
    );
    when(() => storage.saveTokens(at: 'at2', rt: 'rt2')).thenAnswer((_) async {});

    final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'))
      ..httpClientAdapter = SequencedAdapter([
        jsonResponse({'error': {'code': 'UNAUTHORIZED', 'message': 'nope'}}, 401),
        jsonResponse({'id': 'u1', 'name': 'A', 'email': 'a@b.com', 'role': 'STUDENT'}, 200),
      ]);

    attachAuthInterceptors(dio, storage: storage, api: api);

    final response = await dio.get('/auth/me');

    expect(response.statusCode, 200);
    verify(() => storage.saveTokens(at: 'at2', rt: 'rt2')).called(1);
  });
}
