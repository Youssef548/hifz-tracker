// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_review_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateReviewRequest extends CreateReviewRequest {
  @override
  final int surahNumber;
  @override
  final int ayahFrom;
  @override
  final int ayahTo;
  @override
  final ReviewQuality quality;
  @override
  final DateTime? loggedAt;

  factory _$CreateReviewRequest(
          [void Function(CreateReviewRequestBuilder)? updates]) =>
      (CreateReviewRequestBuilder()..update(updates))._build();

  _$CreateReviewRequest._(
      {required this.surahNumber,
      required this.ayahFrom,
      required this.ayahTo,
      required this.quality,
      this.loggedAt})
      : super._();
  @override
  CreateReviewRequest rebuild(
          void Function(CreateReviewRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateReviewRequestBuilder toBuilder() =>
      CreateReviewRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateReviewRequest &&
        surahNumber == other.surahNumber &&
        ayahFrom == other.ayahFrom &&
        ayahTo == other.ayahTo &&
        quality == other.quality &&
        loggedAt == other.loggedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, surahNumber.hashCode);
    _$hash = $jc(_$hash, ayahFrom.hashCode);
    _$hash = $jc(_$hash, ayahTo.hashCode);
    _$hash = $jc(_$hash, quality.hashCode);
    _$hash = $jc(_$hash, loggedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateReviewRequest')
          ..add('surahNumber', surahNumber)
          ..add('ayahFrom', ayahFrom)
          ..add('ayahTo', ayahTo)
          ..add('quality', quality)
          ..add('loggedAt', loggedAt))
        .toString();
  }
}

class CreateReviewRequestBuilder
    implements Builder<CreateReviewRequest, CreateReviewRequestBuilder> {
  _$CreateReviewRequest? _$v;

  int? _surahNumber;
  int? get surahNumber => _$this._surahNumber;
  set surahNumber(int? surahNumber) => _$this._surahNumber = surahNumber;

  int? _ayahFrom;
  int? get ayahFrom => _$this._ayahFrom;
  set ayahFrom(int? ayahFrom) => _$this._ayahFrom = ayahFrom;

  int? _ayahTo;
  int? get ayahTo => _$this._ayahTo;
  set ayahTo(int? ayahTo) => _$this._ayahTo = ayahTo;

  ReviewQuality? _quality;
  ReviewQuality? get quality => _$this._quality;
  set quality(ReviewQuality? quality) => _$this._quality = quality;

  DateTime? _loggedAt;
  DateTime? get loggedAt => _$this._loggedAt;
  set loggedAt(DateTime? loggedAt) => _$this._loggedAt = loggedAt;

  CreateReviewRequestBuilder() {
    CreateReviewRequest._defaults(this);
  }

  CreateReviewRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _surahNumber = $v.surahNumber;
      _ayahFrom = $v.ayahFrom;
      _ayahTo = $v.ayahTo;
      _quality = $v.quality;
      _loggedAt = $v.loggedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateReviewRequest other) {
    _$v = other as _$CreateReviewRequest;
  }

  @override
  void update(void Function(CreateReviewRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateReviewRequest build() => _build();

  _$CreateReviewRequest _build() {
    final _$result = _$v ??
        _$CreateReviewRequest._(
          surahNumber: BuiltValueNullFieldError.checkNotNull(
              surahNumber, r'CreateReviewRequest', 'surahNumber'),
          ayahFrom: BuiltValueNullFieldError.checkNotNull(
              ayahFrom, r'CreateReviewRequest', 'ayahFrom'),
          ayahTo: BuiltValueNullFieldError.checkNotNull(
              ayahTo, r'CreateReviewRequest', 'ayahTo'),
          quality: BuiltValueNullFieldError.checkNotNull(
              quality, r'CreateReviewRequest', 'quality'),
          loggedAt: loggedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
