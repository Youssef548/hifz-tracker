//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'role_output.g.dart';

class RoleOutput extends EnumClass {
  @BuiltValueEnumConst(wireName: r'STUDENT')
  static const RoleOutput STUDENT = _$STUDENT;
  @BuiltValueEnumConst(wireName: r'TEACHER')
  static const RoleOutput TEACHER = _$TEACHER;
  @BuiltValueEnumConst(wireName: r'ADMIN')
  static const RoleOutput ADMIN = _$ADMIN;

  static Serializer<RoleOutput> get serializer => _$roleOutputSerializer;

  const RoleOutput._(String name) : super(name);

  static BuiltSet<RoleOutput> get values => _$values;
  static RoleOutput valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class RoleOutputMixin = Object with _$RoleOutputMixin;
