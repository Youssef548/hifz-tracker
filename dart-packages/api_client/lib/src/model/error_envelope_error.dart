//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'error_envelope_error.g.dart';

/// ErrorEnvelopeError
///
/// Properties:
/// * [code]
/// * [message]
/// * [details]
@BuiltValue()
abstract class ErrorEnvelopeError
    implements Built<ErrorEnvelopeError, ErrorEnvelopeErrorBuilder> {
  @BuiltValueField(wireName: r'code')
  String get code;

  @BuiltValueField(wireName: r'message')
  String get message;

  @BuiltValueField(wireName: r'details')
  JsonObject? get details;

  ErrorEnvelopeError._();

  factory ErrorEnvelopeError([void updates(ErrorEnvelopeErrorBuilder b)]) =
      _$ErrorEnvelopeError;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ErrorEnvelopeErrorBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ErrorEnvelopeError> get serializer =>
      _$ErrorEnvelopeErrorSerializer();
}

class _$ErrorEnvelopeErrorSerializer
    implements PrimitiveSerializer<ErrorEnvelopeError> {
  @override
  final Iterable<Type> types = const [ErrorEnvelopeError, _$ErrorEnvelopeError];

  @override
  final String wireName = r'ErrorEnvelopeError';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ErrorEnvelopeError object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
    if (object.details != null) {
      yield r'details';
      yield serializers.serialize(
        object.details,
        specifiedType: const FullType.nullable(JsonObject),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ErrorEnvelopeError object, {
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
    required ErrorEnvelopeErrorBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        case r'details':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.details = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ErrorEnvelopeError deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ErrorEnvelopeErrorBuilder();
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
