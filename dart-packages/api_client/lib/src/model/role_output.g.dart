// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_output.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RoleOutput _$STUDENT = const RoleOutput._('STUDENT');
const RoleOutput _$TEACHER = const RoleOutput._('TEACHER');
const RoleOutput _$ADMIN = const RoleOutput._('ADMIN');

RoleOutput _$valueOf(String name) {
  switch (name) {
    case 'STUDENT':
      return _$STUDENT;
    case 'TEACHER':
      return _$TEACHER;
    case 'ADMIN':
      return _$ADMIN;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RoleOutput> _$values = BuiltSet<RoleOutput>(const <RoleOutput>[
  _$STUDENT,
  _$TEACHER,
  _$ADMIN,
]);

class _$RoleOutputMeta {
  const _$RoleOutputMeta();
  RoleOutput get STUDENT => _$STUDENT;
  RoleOutput get TEACHER => _$TEACHER;
  RoleOutput get ADMIN => _$ADMIN;
  RoleOutput valueOf(String name) => _$valueOf(name);
  BuiltSet<RoleOutput> get values => _$values;
}

abstract class _$RoleOutputMixin {
  // ignore: non_constant_identifier_names
  _$RoleOutputMeta get RoleOutput => const _$RoleOutputMeta();
}

Serializer<RoleOutput> _$roleOutputSerializer = _$RoleOutputSerializer();

class _$RoleOutputSerializer implements PrimitiveSerializer<RoleOutput> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'STUDENT': 'STUDENT',
    'TEACHER': 'TEACHER',
    'ADMIN': 'ADMIN',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'STUDENT': 'STUDENT',
    'TEACHER': 'TEACHER',
    'ADMIN': 'ADMIN',
  };

  @override
  final Iterable<Type> types = const <Type>[RoleOutput];
  @override
  final String wireName = 'RoleOutput';

  @override
  Object serialize(Serializers serializers, RoleOutput object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RoleOutput deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RoleOutput.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
