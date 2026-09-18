//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:hifz_api_client/src/model/role_output.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_user_output.g.dart';

/// AuthUserOutput
///
/// Properties:
/// * [id]
/// * [name]
/// * [email]
/// * [role]
@BuiltValue()
abstract class AuthUserOutput
    implements Built<AuthUserOutput, AuthUserOutputBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'email')
  String get email;

  @BuiltValueField(wireName: r'role')
  RoleOutput get role;
  // enum roleEnum {  STUDENT,  TEACHER,  ADMIN,  };

  AuthUserOutput._();

  factory AuthUserOutput([void updates(AuthUserOutputBuilder b)]) =
      _$AuthUserOutput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthUserOutputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthUserOutput> get serializer =>
      _$AuthUserOutputSerializer();
}

class _$AuthUserOutputSerializer
    implements PrimitiveSerializer<AuthUserOutput> {
  @override
  final Iterable<Type> types = const [AuthUserOutput, _$AuthUserOutput];

  @override
  final String wireName = r'AuthUserOutput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthUserOutput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(RoleOutput),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthUserOutput object, {
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
    required AuthUserOutputBuilder result,
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RoleOutput),
          ) as RoleOutput;
          result.role = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthUserOutput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthUserOutputBuilder();
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
