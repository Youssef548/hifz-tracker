//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:hifz_api_client/src/date_serializer.dart';
import 'package:hifz_api_client/src/model/date.dart';

import 'package:hifz_api_client/src/model/auth_response_output.dart';
import 'package:hifz_api_client/src/model/auth_user_output.dart';
import 'package:hifz_api_client/src/model/create_review_request.dart';
import 'package:hifz_api_client/src/model/error_envelope.dart';
import 'package:hifz_api_client/src/model/error_envelope_error.dart';
import 'package:hifz_api_client/src/model/login_request.dart';
import 'package:hifz_api_client/src/model/refresh_request.dart';
import 'package:hifz_api_client/src/model/register_request.dart';
import 'package:hifz_api_client/src/model/review_dto.dart';
import 'package:hifz_api_client/src/model/review_dto_output.dart';
import 'package:hifz_api_client/src/model/review_list_response_output.dart';
import 'package:hifz_api_client/src/model/review_quality.dart';
import 'package:hifz_api_client/src/model/review_quality_output.dart';
import 'package:hifz_api_client/src/model/role_output.dart';

part 'serializers.g.dart';

@SerializersFor([
  AuthResponseOutput,
  AuthUserOutput,
  CreateReviewRequest,
  ErrorEnvelope,
  ErrorEnvelopeError,
  LoginRequest,
  RefreshRequest,
  RegisterRequest,
  ReviewDto,
  ReviewDtoOutput,
  ReviewListResponseOutput,
  ReviewQuality,
  ReviewQualityOutput,
  RoleOutput,
])
Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(ReviewDtoOutput)]),
        () => ListBuilder<ReviewDtoOutput>(),
      )
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer()))
    .build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
