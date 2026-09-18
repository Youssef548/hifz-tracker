// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_envelope_error.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ErrorEnvelopeError extends ErrorEnvelopeError {
  @override
  final String code;
  @override
  final String message;
  @override
  final JsonObject? details;

  factory _$ErrorEnvelopeError(
          [void Function(ErrorEnvelopeErrorBuilder)? updates]) =>
      (ErrorEnvelopeErrorBuilder()..update(updates))._build();

  _$ErrorEnvelopeError._(
      {required this.code, required this.message, this.details})
      : super._();
  @override
  ErrorEnvelopeError rebuild(
          void Function(ErrorEnvelopeErrorBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ErrorEnvelopeErrorBuilder toBuilder() =>
      ErrorEnvelopeErrorBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ErrorEnvelopeError &&
        code == other.code &&
        message == other.message &&
        details == other.details;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jc(_$hash, details.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ErrorEnvelopeError')
          ..add('code', code)
          ..add('message', message)
          ..add('details', details))
        .toString();
  }
}

class ErrorEnvelopeErrorBuilder
    implements Builder<ErrorEnvelopeError, ErrorEnvelopeErrorBuilder> {
  _$ErrorEnvelopeError? _$v;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  JsonObject? _details;
  JsonObject? get details => _$this._details;
  set details(JsonObject? details) => _$this._details = details;

  ErrorEnvelopeErrorBuilder() {
    ErrorEnvelopeError._defaults(this);
  }

  ErrorEnvelopeErrorBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _message = $v.message;
      _details = $v.details;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ErrorEnvelopeError other) {
    _$v = other as _$ErrorEnvelopeError;
  }

  @override
  void update(void Function(ErrorEnvelopeErrorBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ErrorEnvelopeError build() => _build();

  _$ErrorEnvelopeError _build() {
    final _$result = _$v ??
        _$ErrorEnvelopeError._(
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'ErrorEnvelopeError', 'code'),
          message: BuiltValueNullFieldError.checkNotNull(
              message, r'ErrorEnvelopeError', 'message'),
          details: details,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
