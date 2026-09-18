import 'package:dio/dio.dart';
import 'package:hifz_api_client/hifz_api_client.dart';
import 'package:test/test.dart';

void main() {
  test('client constructs and exposes auth+reviews APIs', () {
    // An origin, not an origin + /api/v1: the generated paths already carry it.
    final client = HifzApiClient(basePathOverride: 'http://localhost:3001');
    expect(client.getAuthApi(), isNotNull);
    expect(client.getReviewsApi(), isNotNull);
  });

  test('generated paths compose with the base path without doubling /api/v1',
      () {
    final client = HifzApiClient(basePathOverride: 'http://localhost:3001');
    final uri = Options(method: 'GET')
        .compose(client.dio.options, '/api/v1/reviews')
        .uri
        .toString();
    expect(uri, 'http://localhost:3001/api/v1/reviews');
  });

  test('generated models are constructible from the OpenAPI schemas', () {
    final request = CreateReviewRequest(
      (b) => b
        ..surahNumber = 1
        ..ayahFrom = 1
        ..ayahTo = 7
        ..quality = ReviewQuality.GOOD,
    );
    expect(request.surahNumber, 1);
    expect(request.quality, ReviewQuality.GOOD);
  });
}
