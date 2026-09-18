import 'package:dio/dio.dart';
import 'package:hifz_core/hifz_core.dart';

/// Maps a transport failure onto the shared [ApiFailure] vocabulary.
///
/// `NETWORK` / `SERVER` are retryable (the outbox keeps the write); every other
/// code is a domain rejection the caller must surface.
ApiFailure mapDioException(DioException error) {
  final response = error.response;
  if (response == null) {
    return const ApiFailure(code: 'NETWORK', message: 'Network unavailable');
  }
  final status = response.statusCode ?? 0;
  final data = response.data;
  if (data is Map && data['error'] is Map) {
    final envelope = data['error'] as Map;
    return ApiFailure(
      code: envelope['code'] as String? ?? 'INTERNAL',
      message: envelope['message'] as String? ?? 'Request failed',
      details: envelope['details'],
    );
  }
  if (status >= 500) {
    return ApiFailure(code: 'SERVER', message: 'Server error ($status)');
  }
  return ApiFailure(code: 'INTERNAL', message: 'Request failed ($status)');
}
