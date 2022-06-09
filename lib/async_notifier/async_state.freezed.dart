// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'async_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$AsyncState<T> {
  T? get data => throw _privateConstructorUsedError;
  Object? get error => throw _privateConstructorUsedError;
  DateTime? get lastLoadTime => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get initialLoadCompleted => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AsyncStateCopyWith<T, AsyncState<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AsyncStateCopyWith<T, $Res> {
  factory $AsyncStateCopyWith(
          AsyncState<T> value, $Res Function(AsyncState<T>) then) =
      _$AsyncStateCopyWithImpl<T, $Res>;
  $Res call(
      {T? data,
      Object? error,
      DateTime? lastLoadTime,
      bool isLoading,
      bool initialLoadCompleted});
}

/// @nodoc
class _$AsyncStateCopyWithImpl<T, $Res>
    implements $AsyncStateCopyWith<T, $Res> {
  _$AsyncStateCopyWithImpl(this._value, this._then);

  final AsyncState<T> _value;
  // ignore: unused_field
  final $Res Function(AsyncState<T>) _then;

  @override
  $Res call({
    Object? data = freezed,
    Object? error = freezed,
    Object? lastLoadTime = freezed,
    Object? isLoading = freezed,
    Object? initialLoadCompleted = freezed,
  }) {
    return _then(_value.copyWith(
      data: data == freezed
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as T?,
      error: error == freezed ? _value.error : error,
      lastLoadTime: lastLoadTime == freezed
          ? _value.lastLoadTime
          : lastLoadTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isLoading: isLoading == freezed
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      initialLoadCompleted: initialLoadCompleted == freezed
          ? _value.initialLoadCompleted
          : initialLoadCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
abstract class _$$_CreateCopyWith<T, $Res>
    implements $AsyncStateCopyWith<T, $Res> {
  factory _$$_CreateCopyWith(
          _$_Create<T> value, $Res Function(_$_Create<T>) then) =
      __$$_CreateCopyWithImpl<T, $Res>;
  @override
  $Res call(
      {T? data,
      Object? error,
      DateTime? lastLoadTime,
      bool isLoading,
      bool initialLoadCompleted});
}

/// @nodoc
class __$$_CreateCopyWithImpl<T, $Res> extends _$AsyncStateCopyWithImpl<T, $Res>
    implements _$$_CreateCopyWith<T, $Res> {
  __$$_CreateCopyWithImpl(
      _$_Create<T> _value, $Res Function(_$_Create<T>) _then)
      : super(_value, (v) => _then(v as _$_Create<T>));

  @override
  _$_Create<T> get _value => super._value as _$_Create<T>;

  @override
  $Res call({
    Object? data = freezed,
    Object? error = freezed,
    Object? lastLoadTime = freezed,
    Object? isLoading = freezed,
    Object? initialLoadCompleted = freezed,
  }) {
    return _then(_$_Create<T>(
      data: data == freezed
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as T?,
      error: error == freezed ? _value.error : error,
      lastLoadTime: lastLoadTime == freezed
          ? _value.lastLoadTime
          : lastLoadTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isLoading: isLoading == freezed
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      initialLoadCompleted: initialLoadCompleted == freezed
          ? _value.initialLoadCompleted
          : initialLoadCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$_Create<T> with DiagnosticableTreeMixin implements _Create<T> {
  _$_Create(
      {this.data,
      this.error,
      this.lastLoadTime,
      this.isLoading = false,
      this.initialLoadCompleted = false});

  @override
  final T? data;
  @override
  final Object? error;
  @override
  final DateTime? lastLoadTime;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool initialLoadCompleted;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'AsyncState<$T>(data: $data, error: $error, lastLoadTime: $lastLoadTime, isLoading: $isLoading, initialLoadCompleted: $initialLoadCompleted)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'AsyncState<$T>'))
      ..add(DiagnosticsProperty('data', data))
      ..add(DiagnosticsProperty('error', error))
      ..add(DiagnosticsProperty('lastLoadTime', lastLoadTime))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('initialLoadCompleted', initialLoadCompleted));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Create<T> &&
            const DeepCollectionEquality().equals(other.data, data) &&
            const DeepCollectionEquality().equals(other.error, error) &&
            const DeepCollectionEquality()
                .equals(other.lastLoadTime, lastLoadTime) &&
            const DeepCollectionEquality().equals(other.isLoading, isLoading) &&
            const DeepCollectionEquality()
                .equals(other.initialLoadCompleted, initialLoadCompleted));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(data),
      const DeepCollectionEquality().hash(error),
      const DeepCollectionEquality().hash(lastLoadTime),
      const DeepCollectionEquality().hash(isLoading),
      const DeepCollectionEquality().hash(initialLoadCompleted));

  @JsonKey(ignore: true)
  @override
  _$$_CreateCopyWith<T, _$_Create<T>> get copyWith =>
      __$$_CreateCopyWithImpl<T, _$_Create<T>>(this, _$identity);
}

abstract class _Create<T> implements AsyncState<T> {
  factory _Create(
      {final T? data,
      final Object? error,
      final DateTime? lastLoadTime,
      final bool isLoading,
      final bool initialLoadCompleted}) = _$_Create<T>;

  @override
  T? get data => throw _privateConstructorUsedError;
  @override
  Object? get error => throw _privateConstructorUsedError;
  @override
  DateTime? get lastLoadTime => throw _privateConstructorUsedError;
  @override
  bool get isLoading => throw _privateConstructorUsedError;
  @override
  bool get initialLoadCompleted => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$$_CreateCopyWith<T, _$_Create<T>> get copyWith =>
      throw _privateConstructorUsedError;
}
