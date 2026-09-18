import 'dart:async';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:hifz_api_client/hifz_api_client.dart';
import 'package:hifz_data/hifz_data.dart';

AppDatabase newDb() => AppDatabase(NativeDatabase.memory());

CreateReviewRequest request({int ayahFrom = 1, int ayahTo = 7}) => CreateReviewRequest(
      (builder) => builder
        ..surahNumber = 1
        ..ayahFrom = ayahFrom
        ..ayahTo = ayahTo
        ..quality = ReviewQuality.GOOD,
    );

ReviewDto makeDto({
  String id = '0b2f6f38-1e63-4c8a-9c1a-3f8c2c2e6c12',
  String studentId = '9b2f6f38-1e63-4c8a-9c1a-3f8c2c2e6c11',
}) =>
    ReviewDto(
      (builder) => builder
        ..id = id
        ..studentId = studentId
        ..surahNumber = 1
        ..ayahFrom = 1
        ..ayahTo = 7
        ..quality = ReviewQuality.GOOD
        ..loggedAt = DateTime.utc(2026, 9, 18, 10),
    );

Response<ReviewDto> okResponse(ReviewDto dto, {int statusCode = 201}) => Response<ReviewDto>(
      requestOptions: RequestOptions(path: '/api/v1/reviews'),
      statusCode: statusCode,
      data: dto,
    );

DioException connectionError() => DioException(
      requestOptions: RequestOptions(path: '/api/v1/reviews'),
      type: DioExceptionType.connectionError,
    );

DioException badResponse(String envelopeCode, {int statusCode = 400}) => DioException(
      requestOptions: RequestOptions(path: '/api/v1/reviews'),
      type: DioExceptionType.badResponse,
      response: Response<dynamic>(
        requestOptions: RequestOptions(path: '/api/v1/reviews'),
        statusCode: statusCode,
        data: {
          'error': {'code': envelopeCode, 'message': 'rejected'},
        },
      ),
    );

typedef CreateHandler = Future<Response<ReviewDto>> Function(
  CreateReviewRequest body,
  String? idempotencyKey,
);

class FakeReviewsApi implements ReviewsApi {
  FakeReviewsApi(this.handler);

  CreateHandler handler;

  static FakeReviewsApi returning(ReviewDto dto, {int statusCode = 201}) =>
      FakeReviewsApi((body, key) async => okResponse(dto, statusCode: statusCode));

  static FakeReviewsApi throwing(DioException Function() error) =>
      FakeReviewsApi((body, key) async => throw error());

  @override
  Future<Response<ReviewDto>> reviewsControllerCreate({
    required CreateReviewRequest body,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      handler(body, headers?['Idempotency-Key'] as String?);

  @override
  Future<Response<ReviewListResponseOutput>> reviewsControllerList({
    String? studentId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      throw UnimplementedError();
}

class FakeConnectivity implements ConnectivityChecker {
  FakeConnectivity({bool online = true}) : _online = online;

  bool _online;
  final _controller = StreamController<bool>.broadcast();

  @override
  Future<bool> isOnline() async => _online;

  @override
  Stream<bool> get onConnectivityChanged => _controller.stream;

  void emit(bool online) {
    _online = online;
    _controller.add(online);
  }

  Future<void> dispose() => _controller.close();
}
