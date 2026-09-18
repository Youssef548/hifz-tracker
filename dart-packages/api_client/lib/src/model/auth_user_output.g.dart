// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_user_output.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthUserOutput extends AuthUserOutput {
  @override
  final String id;
  @override
  final String name;
  @override
  final String email;
  @override
  final RoleOutput role;

  factory _$AuthUserOutput([void Function(AuthUserOutputBuilder)? updates]) =>
      (AuthUserOutputBuilder()..update(updates))._build();

  _$AuthUserOutput._(
      {required this.id,
      required this.name,
      required this.email,
      required this.role})
      : super._();
  @override
  AuthUserOutput rebuild(void Function(AuthUserOutputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthUserOutputBuilder toBuilder() => AuthUserOutputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthUserOutput &&
        id == other.id &&
        name == other.name &&
        email == other.email &&
        role == other.role;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthUserOutput')
          ..add('id', id)
          ..add('name', name)
          ..add('email', email)
          ..add('role', role))
        .toString();
  }
}

class AuthUserOutputBuilder
    implements Builder<AuthUserOutput, AuthUserOutputBuilder> {
  _$AuthUserOutput? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  RoleOutput? _role;
  RoleOutput? get role => _$this._role;
  set role(RoleOutput? role) => _$this._role = role;

  AuthUserOutputBuilder() {
    AuthUserOutput._defaults(this);
  }

  AuthUserOutputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _email = $v.email;
      _role = $v.role;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthUserOutput other) {
    _$v = other as _$AuthUserOutput;
  }

  @override
  void update(void Function(AuthUserOutputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthUserOutput build() => _build();

  _$AuthUserOutput _build() {
    final _$result = _$v ??
        _$AuthUserOutput._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'AuthUserOutput', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'AuthUserOutput', 'name'),
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'AuthUserOutput', 'email'),
          role: BuiltValueNullFieldError.checkNotNull(
              role, r'AuthUserOutput', 'role'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
