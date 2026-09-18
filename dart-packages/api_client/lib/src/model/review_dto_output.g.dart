// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_dto_output.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReviewDtoOutput extends ReviewDtoOutput {
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
  final ReviewQualityOutput quality;
  @override
  final DateTime loggedAt;

  factory _$ReviewDtoOutput([void Function(ReviewDtoOutputBuilder)? updates]) =>
      (ReviewDtoOutputBuilder()..update(updates))._build();

  _$ReviewDtoOutput._(
      {required this.id,
      required this.studentId,
      required this.surahNumber,
      required this.ayahFrom,
      required this.ayahTo,
      required this.quality,
      required this.loggedAt})
      : super._();
  @override
  ReviewDtoOutput rebuild(void Function(ReviewDtoOutputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReviewDtoOutputBuilder toBuilder() => ReviewDtoOutputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReviewDtoOutput &&
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
    return (newBuiltValueToStringHelper(r'ReviewDtoOutput')
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

class ReviewDtoOutputBuilder
    implements Builder<ReviewDtoOutput, ReviewDtoOutputBuilder> {
  _$ReviewDtoOutput? _$v;

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

  ReviewQualityOutput? _quality;
  ReviewQualityOutput? get quality => _$this._quality;
  set quality(ReviewQualityOutput? quality) => _$this._quality = quality;

  DateTime? _loggedAt;
  DateTime? get loggedAt => _$this._loggedAt;
  set loggedAt(DateTime? loggedAt) => _$this._loggedAt = loggedAt;

  ReviewDtoOutputBuilder() {
    ReviewDtoOutput._defaults(this);
  }

  ReviewDtoOutputBuilder get _$this {
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
  void replace(ReviewDtoOutput other) {
    _$v = other as _$ReviewDtoOutput;
  }

  @override
  void update(void Function(ReviewDtoOutputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReviewDtoOutput build() => _build();

  _$ReviewDtoOutput _build() {
    final _$result = _$v ??
        _$ReviewDtoOutput._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'ReviewDtoOutput', 'id'),
          studentId: BuiltValueNullFieldError.checkNotNull(
              studentId, r'ReviewDtoOutput', 'studentId'),
          surahNumber: BuiltValueNullFieldError.checkNotNull(
              surahNumber, r'ReviewDtoOutput', 'surahNumber'),
          ayahFrom: BuiltValueNullFieldError.checkNotNull(
              ayahFrom, r'ReviewDtoOutput', 'ayahFrom'),
          ayahTo: BuiltValueNullFieldError.checkNotNull(
              ayahTo, r'ReviewDtoOutput', 'ayahTo'),
          quality: BuiltValueNullFieldError.checkNotNull(
              quality, r'ReviewDtoOutput', 'quality'),
          loggedAt: BuiltValueNullFieldError.checkNotNull(
              loggedAt, r'ReviewDtoOutput', 'loggedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
