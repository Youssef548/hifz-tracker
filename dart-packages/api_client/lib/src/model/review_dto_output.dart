//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:hifz_api_client/src/model/review_quality_output.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'review_dto_output.g.dart';

/// ReviewDtoOutput
///
/// Properties:
/// * [id]
/// * [studentId]
/// * [surahNumber]
/// * [ayahFrom]
/// * [ayahTo]
/// * [quality]
/// * [loggedAt]
@BuiltValue()
abstract class ReviewDtoOutput
    implements Built<ReviewDtoOutput, ReviewDtoOutputBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'studentId')
  String get studentId;

  @BuiltValueField(wireName: r'surahNumber')
  int get surahNumber;

  @BuiltValueField(wireName: r'ayahFrom')
  int get ayahFrom;

  @BuiltValueField(wireName: r'ayahTo')
  int get ayahTo;

  @BuiltValueField(wireName: r'quality')
  ReviewQualityOutput get quality;
  // enum qualityEnum {  GOOD,  FAIR,  POOR,  };

  @BuiltValueField(wireName: r'loggedAt')
  DateTime get loggedAt;

  ReviewDtoOutput._();

  factory ReviewDtoOutput([void updates(ReviewDtoOutputBuilder b)]) =
      _$ReviewDtoOutput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReviewDtoOutputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReviewDtoOutput> get serializer =>
      _$ReviewDtoOutputSerializer();
}

class _$ReviewDtoOutputSerializer
    implements PrimitiveSerializer<ReviewDtoOutput> {
  @override
  final Iterable<Type> types = const [ReviewDtoOutput, _$ReviewDtoOutput];

  @override
  final String wireName = r'ReviewDtoOutput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReviewDtoOutput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'studentId';
    yield serializers.serialize(
      object.studentId,
      specifiedType: const FullType(String),
    );
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
      specifiedType: const FullType(ReviewQualityOutput),
    );
    yield r'loggedAt';
    yield serializers.serialize(
      object.loggedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReviewDtoOutput object, {
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
    required ReviewDtoOutputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'studentId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.studentId = valueDes;
          break;
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
            specifiedType: const FullType(ReviewQualityOutput),
          ) as ReviewQualityOutput;
          result.quality = valueDes;
          break;
        case r'loggedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
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
  ReviewDtoOutput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReviewDtoOutputBuilder();
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
