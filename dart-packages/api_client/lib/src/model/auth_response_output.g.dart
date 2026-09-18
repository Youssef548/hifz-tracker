// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response_output.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthResponseOutput extends AuthResponseOutput {
  @override
  final AuthUserOutput user;
  @override
  final String accessToken;
  @override
  final String refreshToken;

  factory _$AuthResponseOutput(
          [void Function(AuthResponseOutputBuilder)? updates]) =>
      (AuthResponseOutputBuilder()..update(updates))._build();

  _$AuthResponseOutput._(
      {required this.user,
      required this.accessToken,
      required this.refreshToken})
      : super._();
  @override
  AuthResponseOutput rebuild(
          void Function(AuthResponseOutputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthResponseOutputBuilder toBuilder() =>
      AuthResponseOutputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthResponseOutput &&
        user == other.user &&
        accessToken == other.accessToken &&
        refreshToken == other.refreshToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, user.hashCode);
    _$hash = $jc(_$hash, accessToken.hashCode);
    _$hash = $jc(_$hash, refreshToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthResponseOutput')
          ..add('user', user)
          ..add('accessToken', accessToken)
          ..add('refreshToken', refreshToken))
        .toString();
  }
}

class AuthResponseOutputBuilder
    implements Builder<AuthResponseOutput, AuthResponseOutputBuilder> {
  _$AuthResponseOutput? _$v;

  AuthUserOutputBuilder? _user;
  AuthUserOutputBuilder get user => _$this._user ??= AuthUserOutputBuilder();
  set user(AuthUserOutputBuilder? user) => _$this._user = user;

  String? _accessToken;
  String? get accessToken => _$this._accessToken;
  set accessToken(String? accessToken) => _$this._accessToken = accessToken;

  String? _refreshToken;
  String? get refreshToken => _$this._refreshToken;
  set refreshToken(String? refreshToken) => _$this._refreshToken = refreshToken;

  AuthResponseOutputBuilder() {
    AuthResponseOutput._defaults(this);
  }

  AuthResponseOutputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _user = $v.user.toBuilder();
      _accessToken = $v.accessToken;
      _refreshToken = $v.refreshToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthResponseOutput other) {
    _$v = other as _$AuthResponseOutput;
  }

  @override
  void update(void Function(AuthResponseOutputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthResponseOutput build() => _build();

  _$AuthResponseOutput _build() {
    _$AuthResponseOutput _$result;
    try {
      _$result = _$v ??
          _$AuthResponseOutput._(
            user: user.build(),
            accessToken: BuiltValueNullFieldError.checkNotNull(
                accessToken, r'AuthResponseOutput', 'accessToken'),
            refreshToken: BuiltValueNullFieldError.checkNotNull(
                refreshToken, r'AuthResponseOutput', 'refreshToken'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'user';
        user.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AuthResponseOutput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
