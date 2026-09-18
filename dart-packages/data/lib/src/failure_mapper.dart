import 'package:dio/dio.dart';
import 'package:hifz_api_client/hifz_api_client.dart';
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
  final envelope = _parseEnvelope(response.data);
  if (envelope != null) {
    return ApiFailure(
      code: envelope.error.code,
      message: envelope.error.message,
      details: envelope.error.details?.value,
    );
  }
  if (status >= 500) {
    return ApiFailure(code: 'SERVER', message: 'Server error ($status)');
  }
  return ApiFailure(code: 'INTERNAL', message: 'Request failed ($status)');
}

/// Deserializes the error envelope through the *generated* model, so a change to
/// its shape breaks this at compile time rather than silently reading a key that
/// no longer exists. Anything malformed falls back to the status-based mapping.
ErrorEnvelope? _parseEnvelope(Object? data) {
  if (data is! Map) return null;
  try {
    return standardSerializers.deserializeWith(ErrorEnvelope.serializer, data);
  } catch (_) {
    return null;
  }
}
