// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReviewDto extends ReviewDto {
  @override
  final String id;
  @override
  final String studentId;
  @override
  final int surahNumber;
  @override
  final int ayahFrom;
  @override
  final int ayahTo;
  @override
  final ReviewQuality quality;
  @override
  final DateTime loggedAt;

  factory _$ReviewDto([void Function(ReviewDtoBuilder)? updates]) =>
      (ReviewDtoBuilder()..update(updates))._build();

  _$ReviewDto._(
      {required this.id,
      required this.studentId,
      required this.surahNumber,
      required this.ayahFrom,
      required this.ayahTo,
      required this.quality,
      required this.loggedAt})
      : super._();
  @override
  ReviewDto rebuild(void Function(ReviewDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReviewDtoBuilder toBuilder() => ReviewDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReviewDto &&
        id == other.id &&
        studentId == other.studentId &&
        surahNumber == other.surahNumber &&
        ayahFrom == other.ayahFrom &&
        ayahTo == other.ayahTo &&
        quality == other.quality &&
        loggedAt == other.loggedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, studentId.hashCode);
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
    return (newBuiltValueToStringHelper(r'ReviewDto')
          ..add('id', id)
          ..add('studentId', studentId)
          ..add('surahNumber', surahNumber)
          ..add('ayahFrom', ayahFrom)
          ..add('ayahTo', ayahTo)
          ..add('quality', quality)
          ..add('loggedAt', loggedAt))
        .toString();
  }
}

class ReviewDtoBuilder implements Builder<ReviewDto, ReviewDtoBuilder> {
  _$ReviewDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _studentId;
  String? get studentId => _$this._studentId;
  set studentId(String? studentId) => _$this._studentId = studentId;

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

  ReviewDtoBuilder() {
    ReviewDto._defaults(this);
  }

  ReviewDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _studentId = $v.studentId;
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
  void replace(ReviewDto other) {
    _$v = other as _$ReviewDto;
  }

  @override
  void update(void Function(ReviewDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReviewDto build() => _build();

  _$ReviewDto _build() {
    final _$result = _$v ??
        _$ReviewDto._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'ReviewDto', 'id'),
          studentId: BuiltValueNullFieldError.checkNotNull(
              studentId, r'ReviewDto', 'studentId'),
          surahNumber: BuiltValueNullFieldError.checkNotNull(
              surahNumber, r'ReviewDto', 'surahNumber'),
          ayahFrom: BuiltValueNullFieldError.checkNotNull(
              ayahFrom, r'ReviewDto', 'ayahFrom'),
          ayahTo: BuiltValueNullFieldError.checkNotNull(
              ayahTo, r'ReviewDto', 'ayahTo'),
          quality: BuiltValueNullFieldError.checkNotNull(
              quality, r'ReviewDto', 'quality'),
          loggedAt: BuiltValueNullFieldError.checkNotNull(
              loggedAt, r'ReviewDto', 'loggedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
