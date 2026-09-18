import 'package:hifz_api_client/hifz_api_client.dart';
import 'package:test/test.dart';

void main() {
  test('client constructs and exposes auth+reviews APIs', () {
    final client =
        HifzApiClient(basePathOverride: 'http://localhost:3001/api/v1');
    expect(client.getAuthApi(), isNotNull);
    expect(client.getReviewsApi(), isNotNull);
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
