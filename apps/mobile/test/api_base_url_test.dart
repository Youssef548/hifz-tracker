import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hifz_feature_auth/hifz_feature_auth.dart';
import 'package:hifz_tracker/src/providers.dart';

class _NoTokens implements TokenStorage {
  @override
  Future<({String at, String rt})?> readTokens() async => null;

  @override
  Future<void> saveTokens({required String at, required String rt}) async {}

  @override
  Future<void> clear() async {}
}

/// Records request URIs instead of performing them.
class _RecordingAdapter implements HttpClientAdapter {
  final uris = <Uri>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    uris.add(options.uri);
    return ResponseBody.fromString(
      '{"items":[]}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  // Regression guard: the generated client's paths already carry `/api/v1`, so
  // handing Dio `AppEnv.apiV1` as its base url produced `/api/v1/api/v1/...`.
  test('requests the API with exactly one /api/v1 prefix', () async {
    final container = ProviderContainer(
      overrides: [tokenStorageProvider.overrideWithValue(_NoTokens())],
    );
    addTearDown(container.dispose);

    final dio = container.read(authedDioProvider);
    final adapter = _RecordingAdapter();
    dio.httpClientAdapter = adapter;

    final reviews = container.read(apiClientProvider).getReviewsApi();

    await reviews.reviewsControllerList();
    expect(adapter.uris.last.path, '/api/v1/reviews');

    await reviews.reviewsControllerList(studentId: 'abc');
    expect(adapter.uris.last.path, '/api/v1/reviews');
    expect(adapter.uris.last.queryParameters, {'studentId': 'abc'});
  });
}
