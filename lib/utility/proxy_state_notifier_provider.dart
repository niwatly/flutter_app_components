import 'package:flutter/material.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:provider/provider.dart' hide Locator;
import 'package:state_notifier/state_notifier.dart';

class ProxyStateNotifier<T> extends StateNotifier<T?> with LocatorMixin {
  final T Function(Locator locator) create;
  final UpdateShouldNotify<T?>? updateShouldNotify;

  ProxyStateNotifier({
    T? initialValue,
    required this.create,
    this.updateShouldNotify,
  }) : super(initialValue);

  @override
  void initState() {
    super.initState();

    _updateState(read as T Function<T>());
  }

  @override
  void update(T Function<T>() watch) {
    super.update(watch);

    _updateState(watch as T Function<T>());
  }

  void _updateState(Locator locator) {
    final T? oldState = state;
    final newState = create(locator);

    var shouldNotify = false;

    if (updateShouldNotify != null) {
      shouldNotify = updateShouldNotify!(oldState, newState);
    } else {
      shouldNotify = oldState != newState;
    }

    if (shouldNotify) {
      state = newState;
    }
  }
}

/// 型を毎回記述するのが面倒だった
StateNotifierProvider proxyStateNotifierProvider<T>({
  required T Function(Locator locator) create,
  UpdateShouldNotify<T>? updateShouldNotify,
}) {
  return StateNotifierProvider<ProxyStateNotifier<T>, T>(
    create: (context) => ProxyStateNotifier<T>(
      create: create,
      updateShouldNotify: updateShouldNotify,
    ),
  );
}
