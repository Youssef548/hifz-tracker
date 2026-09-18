//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:hifz_api_client/src/model/review_quality.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_review_request.g.dart';

/// CreateReviewRequest
///
/// Properties:
/// * [surahNumber]
/// * [ayahFrom]
/// * [ayahTo]
/// * [quality]
/// * [loggedAt]
@BuiltValue()
abstract class CreateReviewRequest
    implements Built<CreateReviewRequest, CreateReviewRequestBuilder> {
  @BuiltValueField(wireName: r'surahNumber')
  int get surahNumber;

  @BuiltValueField(wireName: r'ayahFrom')
  int get ayahFrom;

  @BuiltValueField(wireName: r'ayahTo')
  int get ayahTo;

  @BuiltValueField(wireName: r'quality')
  ReviewQuality get quality;
  // enum qualityEnum {  GOOD,  FAIR,  POOR,  };

  @BuiltValueField(wireName: r'loggedAt')
  DateTime? get loggedAt;

  CreateReviewRequest._();

  factory CreateReviewRequest([void updates(CreateReviewRequestBuilder b)]) =
      _$CreateReviewRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateReviewRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateReviewRequest> get serializer =>
      _$CreateReviewRequestSerializer();
}

class _$CreateReviewRequestSerializer
    implements PrimitiveSerializer<CreateReviewRequest> {
  @override
  final Iterable<Type> types = const [
    CreateReviewRequest,
    _$CreateReviewRequest
  ];

  @override
  final String wireName = r'CreateReviewRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateReviewRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'surahNumber';
    yield serializers.serialize(
      object.surahNumber,
      specifiedType: const FullType(int),
    );
    yield r'ayahFrom';
    yield serializers.serialize(
      object.ayahFrom,
      specifiedType: const FullType(int),
    );
    yield r'ayahTo';
    yield serializers.serialize(
      object.ayahTo,
      specifiedType: const FullType(int),
    );
    yield r'quality';
    yield serializers.serialize(
      object.quality,
      specifiedType: const FullType(ReviewQuality),
    );
    if (object.loggedAt != null) {
      yield r'loggedAt';
      yield serializers.serialize(
        object.loggedAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateReviewRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateReviewRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'surahNumber':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.surahNumber = valueDes;
          break;
        case r'ayahFrom':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.ayahFrom = valueDes;
          break;
        case r'ayahTo':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.ayahTo = valueDes;
          break;
        case r'quality':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReviewQuality),
          ) as ReviewQuality;
          result.quality = valueDes;
          break;
        case r'loggedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.loggedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateReviewRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateReviewRequestBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}
