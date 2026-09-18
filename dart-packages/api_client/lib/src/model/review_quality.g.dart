// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_quality.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ReviewQuality _$GOOD = const ReviewQuality._('GOOD');
const ReviewQuality _$FAIR = const ReviewQuality._('FAIR');
const ReviewQuality _$POOR = const ReviewQuality._('POOR');

ReviewQuality _$valueOf(String name) {
  switch (name) {
    case 'GOOD':
      return _$GOOD;
    case 'FAIR':
      return _$FAIR;
    case 'POOR':
      return _$POOR;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ReviewQuality> _$values =
    BuiltSet<ReviewQuality>(const <ReviewQuality>[
  _$GOOD,
  _$FAIR,
  _$POOR,
]);

class _$ReviewQualityMeta {
  const _$ReviewQualityMeta();
  ReviewQuality get GOOD => _$GOOD;
  ReviewQuality get FAIR => _$FAIR;
  ReviewQuality get POOR => _$POOR;
  ReviewQuality valueOf(String name) => _$valueOf(name);
  BuiltSet<ReviewQuality> get values => _$values;
}

abstract class _$ReviewQualityMixin {
  // ignore: non_constant_identifier_names
  _$ReviewQualityMeta get ReviewQuality => const _$ReviewQualityMeta();
}

Serializer<ReviewQuality> _$reviewQualitySerializer =
    _$ReviewQualitySerializer();

class _$ReviewQualitySerializer implements PrimitiveSerializer<ReviewQuality> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'GOOD': 'GOOD',
    'FAIR': 'FAIR',
    'POOR': 'POOR',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'GOOD': 'GOOD',
    'FAIR': 'FAIR',
    'POOR': 'POOR',
  };

  @override
  final Iterable<Type> types = const <Type>[ReviewQuality];
  @override
  final String wireName = 'ReviewQuality';

  @override
  Object serialize(Serializers serializers, ReviewQuality object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ReviewQuality deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ReviewQuality.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
