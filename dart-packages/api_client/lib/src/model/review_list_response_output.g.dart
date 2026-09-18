// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_list_response_output.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReviewListResponseOutput extends ReviewListResponseOutput {
  @override
  final BuiltList<ReviewDtoOutput> items;

  factory _$ReviewListResponseOutput(
          [void Function(ReviewListResponseOutputBuilder)? updates]) =>
      (ReviewListResponseOutputBuilder()..update(updates))._build();

  _$ReviewListResponseOutput._({required this.items}) : super._();
  @override
  ReviewListResponseOutput rebuild(
          void Function(ReviewListResponseOutputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReviewListResponseOutputBuilder toBuilder() =>
      ReviewListResponseOutputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReviewListResponseOutput && items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReviewListResponseOutput')
          ..add('items', items))
        .toString();
  }
}

class ReviewListResponseOutputBuilder
    implements
        Builder<ReviewListResponseOutput, ReviewListResponseOutputBuilder> {
  _$ReviewListResponseOutput? _$v;

  ListBuilder<ReviewDtoOutput>? _items;
  ListBuilder<ReviewDtoOutput> get items =>
      _$this._items ??= ListBuilder<ReviewDtoOutput>();
  set items(ListBuilder<ReviewDtoOutput>? items) => _$this._items = items;

  ReviewListResponseOutputBuilder() {
    ReviewListResponseOutput._defaults(this);
  }

  ReviewListResponseOutputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReviewListResponseOutput other) {
    _$v = other as _$ReviewListResponseOutput;
  }

  @override
  void update(void Function(ReviewListResponseOutputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReviewListResponseOutput build() => _build();

  _$ReviewListResponseOutput _build() {
    _$ReviewListResponseOutput _$result;
    try {
      _$result = _$v ??
          _$ReviewListResponseOutput._(
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ReviewListResponseOutput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
