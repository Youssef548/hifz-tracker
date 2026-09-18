// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_quality_output.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ReviewQualityOutput _$GOOD = const ReviewQualityOutput._('GOOD');
const ReviewQualityOutput _$FAIR = const ReviewQualityOutput._('FAIR');
const ReviewQualityOutput _$POOR = const ReviewQualityOutput._('POOR');

ReviewQualityOutput _$valueOf(String name) {
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

final BuiltSet<ReviewQualityOutput> _$values =
    BuiltSet<ReviewQualityOutput>(const <ReviewQualityOutput>[
  _$GOOD,
  _$FAIR,
  _$POOR,
]);

class _$ReviewQualityOutputMeta {
  const _$ReviewQualityOutputMeta();
  ReviewQualityOutput get GOOD => _$GOOD;
  ReviewQualityOutput get FAIR => _$FAIR;
  ReviewQualityOutput get POOR => _$POOR;
  ReviewQualityOutput valueOf(String name) => _$valueOf(name);
  BuiltSet<ReviewQualityOutput> get values => _$values;
}

abstract class _$ReviewQualityOutputMixin {
  // ignore: non_constant_identifier_names
  _$ReviewQualityOutputMeta get ReviewQualityOutput =>
      const _$ReviewQualityOutputMeta();
}

Serializer<ReviewQualityOutput> _$reviewQualityOutputSerializer =
    _$ReviewQualityOutputSerializer();

class _$ReviewQualityOutputSerializer
    implements PrimitiveSerializer<ReviewQualityOutput> {
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
  final Iterable<Type> types = const <Type>[ReviewQualityOutput];
  @override
  final String wireName = 'ReviewQualityOutput';

  @override
  Object serialize(Serializers serializers, ReviewQualityOutput object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ReviewQualityOutput deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ReviewQualityOutput.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
