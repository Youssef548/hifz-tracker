//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:hifz_api_client/src/model/auth_user_output.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_response_output.g.dart';

/// AuthResponseOutput
///
/// Properties:
/// * [user]
/// * [accessToken]
/// * [refreshToken]
@BuiltValue()
abstract class AuthResponseOutput
    implements Built<AuthResponseOutput, AuthResponseOutputBuilder> {
  @BuiltValueField(wireName: r'user')
  AuthUserOutput get user;

  @BuiltValueField(wireName: r'accessToken')
  String get accessToken;

  @BuiltValueField(wireName: r'refreshToken')
  String get refreshToken;

  AuthResponseOutput._();

  factory AuthResponseOutput([void updates(AuthResponseOutputBuilder b)]) =
      _$AuthResponseOutput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthResponseOutputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthResponseOutput> get serializer =>
      _$AuthResponseOutputSerializer();
}

class _$AuthResponseOutputSerializer
    implements PrimitiveSerializer<AuthResponseOutput> {
  @override
  final Iterable<Type> types = const [AuthResponseOutput, _$AuthResponseOutput];

  @override
  final String wireName = r'AuthResponseOutput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthResponseOutput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'user';
    yield serializers.serialize(
      object.user,
      specifiedType: const FullType(AuthUserOutput),
    );
    yield r'accessToken';
    yield serializers.serialize(
      object.accessToken,
      specifiedType: const FullType(String),
    );
    yield r'refreshToken';
    yield serializers.serialize(
      object.refreshToken,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthResponseOutput object, {
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
    required AuthResponseOutputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'user':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AuthUserOutput),
          ) as AuthUserOutput;
          result.user.replace(valueDes);
          break;
        case r'accessToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.accessToken = valueDes;
          break;
        case r'refreshToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.refreshToken = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthResponseOutput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthResponseOutputBuilder();
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
