import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'async_state.freezed.dart';

@freezed
class AsyncState<T> with _$AsyncState<T> {
  factory AsyncState({
    T? data,
    Object? error,
    DateTime? lastLoadTime,
    @Default(false) bool isLoading,
    @Default(false) bool initialLoadCompleted,
  }) = _Create;
}
