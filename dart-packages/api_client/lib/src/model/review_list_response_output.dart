//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:hifz_api_client/src/model/review_dto_output.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'review_list_response_output.g.dart';

/// ReviewListResponseOutput
///
/// Properties:
/// * [items]
@BuiltValue()
abstract class ReviewListResponseOutput
    implements
        Built<ReviewListResponseOutput, ReviewListResponseOutputBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<ReviewDtoOutput> get items;

  ReviewListResponseOutput._();

  factory ReviewListResponseOutput(
          [void updates(ReviewListResponseOutputBuilder b)]) =
      _$ReviewListResponseOutput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReviewListResponseOutputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReviewListResponseOutput> get serializer =>
      _$ReviewListResponseOutputSerializer();
}

class _$ReviewListResponseOutputSerializer
    implements PrimitiveSerializer<ReviewListResponseOutput> {
  @override
  final Iterable<Type> types = const [
    ReviewListResponseOutput,
    _$ReviewListResponseOutput
  ];

  @override
  final String wireName = r'ReviewListResponseOutput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReviewListResponseOutput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(ReviewDtoOutput)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReviewListResponseOutput object, {
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
    required ReviewListResponseOutputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(ReviewDtoOutput)]),
          ) as BuiltList<ReviewDtoOutput>;
          result.items.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReviewListResponseOutput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReviewListResponseOutputBuilder();
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
