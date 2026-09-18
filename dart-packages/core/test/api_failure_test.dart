import 'package:hifz_core/hifz_core.dart';
import 'package:test/test.dart';

void main() {
  test('NETWORK is retryable', () {
    expect(const ApiFailure(code: 'NETWORK', message: 'm').isRetryable, isTrue);
  });
  test('SERVER is retryable', () {
    expect(const ApiFailure(code: 'SERVER', message: 'm').isRetryable, isTrue);
  });
  test('VALIDATION_ERROR is not retryable', () {
    expect(const ApiFailure(code: 'VALIDATION_ERROR', message: 'm').isRetryable, isFalse);
  });
  test('AppEnv derives the v1 base url', () {
    expect(const AppEnv(apiBaseUrl: 'http://localhost:3001').apiV1,
        'http://localhost:3001/api/v1');
  });
}
